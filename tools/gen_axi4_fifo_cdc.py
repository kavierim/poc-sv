#!/usr/bin/env python3
from pathlib import Path

src = Path(__file__).resolve().parents[1] / "src/bus/axi4/axi4_FIFO.sv"
dst = Path(__file__).resolve().parents[1] / "src/bus/axi4/axi4_FIFO_CDC.sv"
text = src.read_text(encoding="utf-8")
text = text.replace("axi4_FIFO", "axi4_FIFO_CDC", 1)
text = text.replace(
    "module axi4_FIFO_CDC #(",
    "module axi4_FIFO_CDC #(\n  parameter bit DATA_REG = 1'b0,\n  parameter bit OUTPUT_REG = 1'b0,",
)
text = text.replace(
    "  input  logic Clock,\n  input  logic Reset,\n\n  input",
    "  input  logic In_Clock,\n  input  logic In_Reset,\n\n  input",
)
text = text.replace(
    "  output poc_axi4_full",
    "  input  logic Out_Clock,\n  input  logic Out_Reset,\n\n  output poc_axi4_full",
    1,
)
text = text.replace("  input  poc_axi4_full", "  input  poc_axi4_full", 1)
# Fix port section manually in output
text = text.replace("In_Clock,\n  input  logic In_Reset,\n\n  input", "In_Clock,\n  input  logic In_Reset,\n\n  input", 1)
text = text.replace(".Clock   (Clock)", ".Write_Clock(In_Clock)\n        .Write_Reset(In_Reset)")
text = text.replace(".Reset   (Reset)", ".Read_Clock (Out_Clock)\n        .Read_Reset (Out_Reset)")
text = text.replace("fifo_cc_got #(", "fifo_ic_got #(")
text = text.replace(".STATE_REG(1'b1)\n      ) DataFifo (", ".DATA_REG(DATA_REG),\n        .OUTPUT_REG(OUTPUT_REG)\n      ) DataFifo (")
text = text.replace("fifo_Stage #(", "fifo_Stage #(")  # same clock both sides for stage path - use In_Clock
text = text.replace(".Clock  (Clock)", ".Clock  (In_Clock)")
text = text.replace(".Reset  (Reset)", ".Reset  (In_Reset)")
# ic_got port names differ - fix DataFifo block
text = text.replace(
    """      fifo_ic_got #(
        .DATA_BITS(CH_W),
        .MIN_DEPTH(CH_MIN),
        .DATA_REG(DATA_REG),
        .OUTPUT_REG(OUTPUT_REG)
      ) DataFifo (
        .Write_Clock(In_Clock)
        .Write_Reset(In_Reset)
        .Put     (DataFIFO_put),
        .DataIn  (DataFIFO_DataIn_i),
        .Full    (DataFIFO_Full),
        .Got     (DataFIFO_got),
        .DataOut (DataFIFO_DataOut_i),
        .Valid   (DataFIFO_Valid),
        .EmptyState('0),
        .FillState('0)
      );""",
    """      fifo_ic_got #(
        .DATA_BITS(CH_W),
        .MIN_DEPTH(CH_MIN),
        .DATA_REG(DATA_REG),
        .OUTPUT_REG(OUTPUT_REG)
      ) DataFifo (
        .Write_Clock (In_Clock),
        .Write_Reset (In_Reset),
        .Write_Put   (DataFIFO_put),
        .Write_DataIn(DataFIFO_DataIn_i),
        .Write_Full  (DataFIFO_Full),
        .Read_Clock  (Out_Clock),
        .Read_Reset  (Out_Reset),
        .Read_Got    (DataFIFO_got),
        .Read_DataOut(DataFIFO_DataOut_i),
        .Read_Valid  (DataFIFO_Valid),
        .Write_EmptyState('0),
        .Read_FillState('0)
      );""",
)
dst.write_text(text, encoding="utf-8", newline="\n")
print(f"Wrote {dst}")
