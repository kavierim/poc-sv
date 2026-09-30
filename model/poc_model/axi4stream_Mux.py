# SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
# SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
# SPDX-License-Identifier: Apache-2.0

"""AXI4-Stream multiplexer behavioral model.

Satisfies REQ-axi4stream_Mux-001 (merged beats preserve Data/Last/Keep) and
REQ-axi4stream_Mux-002 (multi-beat packets stay ordered under Out back-pressure).

Arbitration follows RTL ``axi4stream_Mux``: round-robin among requesting inputs,
with a granted port held through ``tlast`` (packet lock) before the next grant.
"""

from __future__ import annotations

from kernel.beat import StreamBeat
from kernel.block import Block
from kernel.channel import Channel


def _keep_width(data_bits: int, keep_bits: int) -> int:
    if keep_bits > 0:
        return keep_bits
    return (data_bits + 7) // 8


def _port_idx_bits(ports: int) -> int:
    if ports <= 1:
        return 1
    n = ports - 1
    w = 0
    while n:
        n >>= 1
        w += 1
    return max(w, 1)


class axi4stream_Mux(Block):
    """AXI4-Stream mux with packet-locked round-robin (PoC ``axi4stream_Mux``).

    Input ports are ``In_0`` .. ``In_{PORTS-1}``; output is ``Out``. All are
    ``kind="axis"``. ``MuxControl`` masks requests when ``USE_CONTROL_VECTOR``.
    """

    def __init__(
        self,
        name: str,
        *,
        PORTS: int = 2,
        DATA_BITS: int = 32,
        USER_BITS: int = 1,
        DEST_BITS: int = 1,
        ID_BITS: int = 1,
        KEEP_BITS: int = 0,
        USE_CONTROL_VECTOR: bool = False,
        APPEND_DEST_BITS: bool = False,
        MuxControl: int | None = None,
        clk_hz: int | None = None,
    ) -> None:
        super().__init__(name)
        if PORTS < 1:
            raise ValueError("PORTS must be >= 1")
        self.PORTS = PORTS
        self.DATA_BITS = DATA_BITS
        self.USER_BITS = USER_BITS
        self.DEST_BITS = DEST_BITS
        self.ID_BITS = ID_BITS
        self.KEEP_BITS = KEEP_BITS
        self.USE_CONTROL_VECTOR = USE_CONTROL_VECTOR
        self.APPEND_DEST_BITS = APPEND_DEST_BITS
        self._port_idx_w = _port_idx_bits(PORTS)
        # All ports enabled when control vector is unused or unspecified.
        self.MuxControl = (1 << PORTS) - 1 if MuxControl is None else MuxControl

        keep_w = _keep_width(DATA_BITS, KEEP_BITS)
        kw = dict(
            kind="axis",
            data_width=DATA_BITS,
            keep_width=keep_w,
            id_width=ID_BITS,
            dest_width=DEST_BITS,
            user_width=USER_BITS,
            clk_hz=clk_hz,
            depth=1,
        )
        self._ins = [Channel(**kw) for _ in range(PORTS)]
        self.Out = Channel(**kw)

        # Matches RTL ChannelPointer_d reset: one-hot at port PORTS-1.
        self._rr_ptr = PORTS - 1
        self._grant: int | None = None

    def ports(self) -> dict[str, Channel]:
        result: dict[str, Channel] = {
            f"In_{i}": self._ins[i] for i in range(self.PORTS)
        }
        result["Out"] = self.Out
        return result

    def _control_allows(self, port: int) -> bool:
        if not self.USE_CONTROL_VECTOR:
            return True
        return bool(self.MuxControl & (1 << port))

    def _requesting(self, port: int) -> bool:
        return bool(self._ins[port]._slots) and self._control_allows(port)

    def _arbitrate(self) -> int | None:
        """Round-robin next grant after ``_rr_ptr`` (RTL ChannelPointer_nxt)."""
        if not any(self._requesting(i) for i in range(self.PORTS)):
            return None
        for i in range(self._rr_ptr + 1, self.PORTS):
            if self._requesting(i):
                return i
        for i in range(0, self._rr_ptr + 1):
            if self._requesting(i):
                return i
        return None

    def _append_dest(self, port: int, tdest: int) -> int:
        """Pack ``{port_idx, Dest}`` into ``DEST_BITS`` (RTL APPEND_DEST_BITS)."""
        idx_w = min(self._port_idx_w, self.DEST_BITS)
        dest_w = self.DEST_BITS - idx_w
        port_part = (port & ((1 << idx_w) - 1)) << dest_w
        dest_part = (tdest & ((1 << dest_w) - 1)) if dest_w > 0 else 0
        return port_part | dest_part

    def step(self) -> None:
        """Grant one input when Out can take a beat; hold through tlast."""
        if not self.Out.ready:
            return

        if self._grant is None:
            self._grant = self._arbitrate()
            if self._grant is None:
                return

        src = self._ins[self._grant]
        if not src._slots:
            return

        beat = src.take()
        if beat is None:
            return
        assert isinstance(beat, StreamBeat)

        if self.APPEND_DEST_BITS:
            out_beat = StreamBeat(
                tdata=beat.tdata,
                tkeep=beat.tkeep,
                tlast=beat.tlast,
                tid=beat.tid,
                tdest=self._append_dest(self._grant, beat.tdest),
                tuser=beat.tuser,
            )
        else:
            out_beat = beat

        if not self.Out.accept(out_beat):
            # Restore so a failed accept cannot drop the beat.
            src._slots.appendleft(beat)
            return

        if beat.tlast:
            self._rr_ptr = self._grant
            self._grant = None
