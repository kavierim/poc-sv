# SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
# SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
# SPDX-License-Identifier: Apache-2.0

"""Same-clock AXI4-Stream packet FIFO behavioral model.

Satisfies REQ-axi4stream_FIFO-001: a packet pushed In emerges Out in the same
beat order with matching Data/Last (StreamBeat tdata/tlast).
"""

from __future__ import annotations

from kernel.block import Block
from kernel.channel import Channel


def _keep_width(data_bits: int, keep_bits: int) -> int:
    if keep_bits > 0:
        return keep_bits
    return (data_bits + 7) // 8


def _fifo_capacity(frames: int, max_packet_depth: int) -> int:
    """Match RTL storage sizing (fifo_cc_got vs fifo_Stage)."""
    if frames > 2 or max_packet_depth > 2:
        return max_packet_depth * frames
    return frames


class axi4stream_FIFO(Block):
    """Same-clock AXI4-Stream FIFO (PoC ``axi4stream_FIFO``).

    Ports ``In`` / ``Out`` are ``kind="axis"``. Valid/Ready is the channel
    handshake; beat fields are ``StreamBeat`` (tdata/tkeep/tlast/tid/tdest/tuser
    ← RTL Data/Keep/Last/ID/Dest/User).
    """

    def __init__(
        self,
        name: str,
        *,
        FRAMES: int = 2,
        MAX_PACKET_DEPTH: int = 8,
        DATA_BITS: int = 32,
        USER_BITS: int = 1,
        DEST_BITS: int = 1,
        ID_BITS: int = 1,
        KEEP_BITS: int = 0,
        clk_hz: int | None = None,
    ) -> None:
        super().__init__(name)
        self.FRAMES = FRAMES
        self.MAX_PACKET_DEPTH = MAX_PACKET_DEPTH
        self.DATA_BITS = DATA_BITS
        self.USER_BITS = USER_BITS
        self.DEST_BITS = DEST_BITS
        self.ID_BITS = ID_BITS
        self.KEEP_BITS = KEEP_BITS

        keep_w = _keep_width(DATA_BITS, KEEP_BITS)
        capacity = _fifo_capacity(FRAMES, MAX_PACKET_DEPTH)

        # In.depth == capacity → Channel.ready is low when the FIFO is full.
        self.In = Channel(
            "axis",
            data_width=DATA_BITS,
            keep_width=keep_w,
            id_width=ID_BITS,
            dest_width=DEST_BITS,
            user_width=USER_BITS,
            clk_hz=clk_hz,
            depth=capacity,
        )
        self.Out = Channel(
            "axis",
            data_width=DATA_BITS,
            keep_width=keep_w,
            id_width=ID_BITS,
            dest_width=DEST_BITS,
            user_width=USER_BITS,
            clk_hz=clk_hz,
            depth=1,
        )

    def ports(self) -> dict[str, Channel]:
        return {"In": self.In, "Out": self.Out}

    def step(self) -> None:
        """Move at most one beat from In to Out when the output can accept it."""
        if not self.Out.ready:
            return
        beat = self.In.take()
        if beat is None:
            return
        self.Out.accept(beat)
