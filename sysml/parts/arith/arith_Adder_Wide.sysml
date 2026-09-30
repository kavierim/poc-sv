// SPDX-FileCopyrightText: 2007-2015 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Structural model. Edit this file before the matching SystemVerilog module.
// Baseline extracted from src/ on 2026-09-27.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

package PoC_Arith_arith_Adder_Wide {
    private import ScalarValues::*;
    private import ArchitectureMeta::*;
    private import PoC_Requirements_Arith::*;

    @ArtifactTrace {
        rtlPath = "src/arith/arith_Adder_Wide.sv";
        verifPath = "";
        fvPath = "";
    }
    part def arith_Adder_Wide {
        doc /* Structural contract for the SystemVerilog module. RTL follows this part. */
        attribute BITS : Integer = 32;
        attribute BLOCKS : Integer = 4;
        attribute ARCH : String = "AAM";
        attribute BLOCKING : String = "DFLT";
        attribute SKIPPING : String = "CCC";
        attribute P_INCLUSIVE : Boolean = false;

        in item A;
        attribute A_sv : String = "logic [BITS-1:0] A";
        in item B;
        attribute B_sv : String = "logic [BITS-1:0] B";
        in item CarryIn;
        out item Sum;
        attribute Sum_sv : String = "logic [BITS-1:0] Sum";
        out item CarryOut;

        satisfy requirement REQ_arith_Adder_Wide_001;
    }

    part arith_Adder_WideUse : arith_Adder_Wide;
}
