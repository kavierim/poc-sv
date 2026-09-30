# SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
# SPDX-License-Identifier: Apache-2.0

"""Contract tests for poc_model.axi4stream_FIFO (REQ-axi4stream_FIFO-001)."""

from __future__ import annotations

import pytest

from kernel import Block, Channel, ConnectError, StreamBeat, System
from poc_model.axi4stream_FIFO import axi4stream_FIFO


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
    """Match axi4stream_FIFO defaults: ID_BITS=DEST_BITS=USER_BITS=1."""
    return Channel(
        "axis",
        data_width=data_bits,
        keep_width=keep_width,
        id_width=id_width,
        dest_width=dest_width,
        user_width=user_width,
        **kw,
    )


def test_fifo_preserves_beat_order_and_tlast() -> None:
    """REQ-axi4stream_FIFO-001: In packet emerges Out in same beat order with matching Data/Last."""
    payload = [
        _beat(0xA0, tlast=False, tid=1, tdest=2, tuser=1),
        _beat(0xA1, tlast=False, tid=1, tdest=2, tuser=0),
        _beat(0xA2, tlast=True, tid=1, tdest=2, tuser=1),
        _beat(0xB0, tlast=True, tid=3, tdest=0, tuser=0),
    ]
    dut = axi4stream_FIFO(
        "fifo",
        FRAMES=2,
        MAX_PACKET_DEPTH=8,
        DATA_BITS=32,
        KEEP_BITS=4,
        ID_BITS=4,
        DEST_BITS=4,
        USER_BITS=2,
    )
    src = _AxisSource(
        "src",
        _axis_ch(32, 4, id_width=4, dest_width=4, user_width=2),
        payload,
    )
    dst = _AxisSink(
        "dst",
        _axis_ch(32, 4, id_width=4, dest_width=4, user_width=2),
    )
    system = System()
    system.add(src)
    system.add(dut)
    system.add(dst)
    system.connect(src, "out", dut, "In")
    system.connect(dut, "Out", dst, "in")
    system.run(40)

    assert len(dst.received) == len(payload)
    for got, exp in zip(dst.received, payload, strict=True):
        assert got.tdata == exp.tdata
        assert got.tkeep == exp.tkeep
        assert got.tlast == exp.tlast
        assert got.tid == exp.tid
        assert got.tdest == exp.tdest
        assert got.tuser == exp.tuser


def test_full_fifo_backpressures_without_corruption() -> None:
    """Full In (depth == capacity) deasserts ready; no beats dropped or reordered."""
    # FRAMES=2, MAX_PACKET_DEPTH=2 → stage FIFO capacity = 2.
    capacity = 2
    dut = axi4stream_FIFO(
        "fifo",
        FRAMES=2,
        MAX_PACKET_DEPTH=2,
        DATA_BITS=32,
        KEEP_BITS=4,
    )
    assert dut.ports()["In"].depth == capacity

    n = 8
    payload = [_beat(0x10 + i, tlast=(i == n - 1)) for i in range(n)]
    src = _AxisSource("src", _axis_ch(), payload)
    dst = _AxisSink("dst", _axis_ch(), stall_cycles=20)
    system = System()
    system.add(src)
    system.add(dut)
    system.add(dst)
    system.connect(src, "out", dut, "In")
    system.connect(dut, "Out", dst, "in")

    system.run(12)
    assert not dut.In.ready  # full → backpressure

    system.run(80)
    assert [b.tdata for b in dst.received] == [0x10 + i for i in range(n)]
    assert [b.tlast for b in dst.received] == [i == n - 1 for i in range(n)]
    assert src._beats == []


def test_connect_rejects_data_width_mismatch() -> None:
    narrow = axi4stream_FIFO("n", DATA_BITS=32, KEEP_BITS=4)
    wide = axi4stream_FIFO("w", DATA_BITS=64, KEEP_BITS=8)
    system = System()
    system.add(narrow)
    system.add(wide)
    with pytest.raises(ConnectError):
        system.connect(narrow, "Out", wide, "In")


def test_steady_state_one_beat_per_cycle_bytes_match_keep() -> None:
    """Never-full FIFO moves one beat/cycle; bytes/cycle matches tkeep popcount."""
    tkeep = 0b0111
    nbytes = tkeep.bit_count()
    n = 64
    payload = [_beat(i, tkeep=tkeep, tlast=(i == n - 1)) for i in range(n)]
    dut = axi4stream_FIFO(
        "fifo",
        FRAMES=4,
        MAX_PACKET_DEPTH=16,
        DATA_BITS=32,
        KEEP_BITS=4,
    )
    src = _AxisSource("src", _axis_ch(), payload)
    dst = _AxisSink("dst", _axis_ch())
    system = System()
    system.add(src)
    system.add(dut)
    system.add(dst)
    system.connect(src, "out", dut, "In")
    system.connect(dut, "Out", dst, "in")

    # Continuous offer: N beats plus a few cycles of pipeline fill/drain.
    report = system.run(n + 8)

    assert len(dst.received) == n
    assert [b.tdata for b in dst.received] == list(range(n))
    assert report.bytes["fifo.Out"] == n * nbytes
    # Steady: nearly one accepted beat per cycle on Out once streaming.
    assert report.beats["fifo.Out"] / report.cycles["fifo.Out"] == pytest.approx(
        1.0, abs=0.15
    )
    assert report.bytes_per_cycle["fifo.Out"] == pytest.approx(nbytes, abs=0.6)
