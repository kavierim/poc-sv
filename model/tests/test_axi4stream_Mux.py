# SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
# SPDX-License-Identifier: Apache-2.0

"""Contract tests for poc_model.axi4stream_Mux (REQ-axi4stream_Mux-001/002).

RTL ``axi4stream_Mux`` holds the grant until ``tlast`` is accepted on Out
(ST_DATAFLOW + ChannelPointer_en only when Ready & Last). Tests assert that
packet-lock rule: two inputs must not interleave inside a packet.
"""

from __future__ import annotations

import pytest

from kernel import Block, Channel, ConnectError, StreamBeat, System
from poc_model.axi4stream_Mux import axi4stream_Mux


class _AxisSource(Block):
    """Pushes queued AXIS beats onto an output channel, one per cycle."""

    def __init__(self, name: str, out: Channel, beats: list[StreamBeat]) -> None:
        super().__init__(name)
        self._out = out
        self._beats = list(beats)

    def ports(self) -> dict[str, Channel]:
        return {"out": self._out}

    def step(self) -> None:
        if not self._beats:
            return
        if self._out.accept(self._beats[0]):
            self._beats.pop(0)


class _AxisSink(Block):
    """Drains an AXIS input; optional stall before accepting."""

    def __init__(
        self,
        name: str,
        inp: Channel,
        *,
        stall_cycles: int = 0,
    ) -> None:
        super().__init__(name)
        self._in = inp
        self._stall_left = stall_cycles
        self.received: list[StreamBeat] = []

    def ports(self) -> dict[str, Channel]:
        return {"in": self._in}

    def step(self) -> None:
        if self._stall_left > 0:
            self._stall_left -= 1
            return
        beat = self._in.take()
        if beat is not None:
            self.received.append(beat)


def _beat(
    tdata: int,
    *,
    tkeep: int = 0b1111,
    tlast: bool = False,
    tid: int = 0,
    tdest: int = 0,
    tuser: int = 0,
) -> StreamBeat:
    return StreamBeat(
        tdata=tdata,
        tkeep=tkeep,
        tlast=tlast,
        tid=tid,
        tdest=tdest,
        tuser=tuser,
    )


def _axis_ch(
    data_bits: int = 32,
    keep_width: int = 4,
    *,
    id_width: int = 1,
    dest_width: int = 1,
    user_width: int = 1,
    **kw,
) -> Channel:
    """Match axi4stream_Mux defaults: ID_BITS=DEST_BITS=USER_BITS=1."""
    return Channel(
        "axis",
        data_width=data_bits,
        keep_width=keep_width,
        id_width=id_width,
        dest_width=dest_width,
        user_width=user_width,
        **kw,
    )


def test_mux_forwards_granted_manager_unchanged() -> None:
    """REQ-axi4stream_Mux-001: Out preserves Data/Last/Keep (and ID/Dest/User) from the grant."""
    pkt = [
        _beat(0x11, tkeep=0b1111, tlast=False, tid=5, tdest=1, tuser=1),
        _beat(0x22, tkeep=0b0011, tlast=True, tid=5, tdest=1, tuser=0),
    ]
    dut = axi4stream_Mux(
        "mux",
        PORTS=2,
        DATA_BITS=32,
        KEEP_BITS=4,
        ID_BITS=4,
        DEST_BITS=4,
        USER_BITS=2,
    )
    src0 = _AxisSource(
        "src0",
        _axis_ch(32, 4, id_width=4, dest_width=4, user_width=2),
        pkt,
    )
    src1 = _AxisSource(
        "src1",
        _axis_ch(32, 4, id_width=4, dest_width=4, user_width=2),
        [],
    )
    dst = _AxisSink(
        "dst",
        _axis_ch(32, 4, id_width=4, dest_width=4, user_width=2),
    )
    system = System()
    for b in (src0, src1, dut, dst):
        system.add(b)
    system.connect(src0, "out", dut, "In_0")
    system.connect(src1, "out", dut, "In_1")
    system.connect(dut, "Out", dst, "in")
    system.run(20)

    assert len(dst.received) == 2
    for got, exp in zip(dst.received, pkt, strict=True):
        assert got.tdata == exp.tdata
        assert got.tkeep == exp.tkeep
        assert got.tlast == exp.tlast
        assert got.tid == exp.tid
        assert got.tdest == exp.tdest
        assert got.tuser == exp.tuser


def test_mux_no_interleave_inside_packet_tlast_bounds_grant() -> None:
    """RTL packet-lock: grant held until tlast; inputs do not interleave mid-packet.

    Matches axi4stream_Mux.sv ST_DATAFLOW: ChannelPointer updates only when
    Out Ready & Last (REQ-axi4stream_Mux-002 ordering under contention).
    """
    # Concurrent multi-beat packets on both managers.
    pkt0 = [
        _beat(0xA0, tlast=False),
        _beat(0xA1, tlast=False),
        _beat(0xA2, tlast=True),
    ]
    pkt1 = [
        _beat(0xB0, tlast=False),
        _beat(0xB1, tlast=True),
    ]
    dut = axi4stream_Mux("mux", PORTS=2, DATA_BITS=32, KEEP_BITS=4)
    src0 = _AxisSource("src0", _axis_ch(), pkt0)
    src1 = _AxisSource("src1", _axis_ch(), pkt1)
    dst = _AxisSink("dst", _axis_ch())
    system = System()
    for b in (src0, src1, dut, dst):
        system.add(b)
    system.connect(src0, "out", dut, "In_0")
    system.connect(src1, "out", dut, "In_1")
    system.connect(dut, "Out", dst, "in")
    system.run(40)

    data = [b.tdata for b in dst.received]
    assert set(data) == {0xA0, 0xA1, 0xA2, 0xB0, 0xB1}
    assert len(data) == 5

    # Entire packet of one source before the other (no mid-packet interleave).
    a_idxs = [data.index(x) for x in (0xA0, 0xA1, 0xA2)]
    b_idxs = [data.index(x) for x in (0xB0, 0xB1)]
    assert a_idxs == sorted(a_idxs)
    assert b_idxs == sorted(b_idxs)
    a_span = range(min(a_idxs), max(a_idxs) + 1)
    b_span = range(min(b_idxs), max(b_idxs) + 1)
    assert set(a_span).isdisjoint(b_idxs)
    assert set(b_span).isdisjoint(a_idxs)

    # tlast only on packet tails in order of appearance.
    lasts = [b.tlast for b in dst.received]
    assert lasts[max(a_idxs)] is True
    assert lasts[max(b_idxs)] is True
    assert sum(1 for x in lasts if x) == 2


def test_connect_rejects_data_width_mismatch() -> None:
    mux32 = axi4stream_Mux("m32", PORTS=1, DATA_BITS=32, KEEP_BITS=4)
    mux64 = axi4stream_Mux("m64", PORTS=1, DATA_BITS=64, KEEP_BITS=8)
    system = System()
    system.add(mux32)
    system.add(mux64)
    with pytest.raises(ConnectError):
        system.connect(mux32, "Out", mux64, "In_0")


def test_steady_state_single_source_one_beat_per_cycle() -> None:
    """Single-source mux that is never contended moves one beat/cycle; bytes match keep."""
    tkeep = 0b1111
    nbytes = tkeep.bit_count()
    n = 64
    payload = [_beat(i, tkeep=tkeep, tlast=(i == n - 1)) for i in range(n)]
    dut = axi4stream_Mux("mux", PORTS=2, DATA_BITS=32, KEEP_BITS=4)
    src0 = _AxisSource("src0", _axis_ch(), payload)
    src1 = _AxisSource("src1", _axis_ch(), [])
    dst = _AxisSink("dst", _axis_ch())
    system = System()
    for b in (src0, src1, dut, dst):
        system.add(b)
    system.connect(src0, "out", dut, "In_0")
    system.connect(src1, "out", dut, "In_1")
    system.connect(dut, "Out", dst, "in")

    report = system.run(n + 8)

    assert len(dst.received) == n
    assert [b.tdata for b in dst.received] == list(range(n))
    assert report.bytes["mux.Out"] == n * nbytes
    assert report.beats["mux.Out"] / report.cycles["mux.Out"] == pytest.approx(
        1.0, abs=0.15
    )
    assert report.bytes_per_cycle["mux.Out"] == pytest.approx(nbytes, abs=0.6)
