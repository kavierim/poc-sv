// SPDX-FileCopyrightText: 2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Structural model. Edit this file before the matching SystemVerilog module.
// Baseline extracted from src/ on 2026-09-30.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

package PoC_Fifo_fifo_ic_assembly {
    private import ScalarValues::*;
    private import ArchitectureMeta::*;
    private import PoC_Requirements_Fifo::*;

    @ArtifactTrace {
        rtlPath = "src/fifo/fifo_ic_assembly.sv";
        verifPath = "";
        fvPath = "";
    }
    part def fifo_ic_assembly {
        doc /* Structural contract for the SystemVerilog module. RTL follows this part. */
        attribute D_BITS : Integer = 8;
        attribute A_BITS : Integer = 8;
        attribute G_BITS : Integer = 2;

        in item clk_wr;
        in item rst_wr;
        out item base;
        attribute base_sv : String = "logic [A_BITS-1:0] base";
        out item failed;
        in item addr;
        attribute addr_sv : String = "logic [A_BITS-1:0] addr";
        in item din;
        attribute din_sv : String = "logic [D_BITS-1:0] din";
        in item put;
        in item clk_rd;
        in item rst_rd;
        out item dout;
        attribute dout_sv : String = "logic [D_BITS-1:0] dout";
        out item vld;
        in item got;
        satisfy requirement REQ_fifo_ic_assembly_001;

    }

    part fifo_ic_assemblyUse : fifo_ic_assembly;
}
