// SPDX-FileCopyrightText: 2007-2015 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Structural model. Edit this file before the matching SystemVerilog module.
// Baseline extracted from src/ on 2026-09-27.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

package PoC_Arith_arith_Shifter_Barrel {
    private import ScalarValues::*;
    private import ArchitectureMeta::*;
    private import PoC_Requirements_Arith::*;

    @ArtifactTrace {
        rtlPath = "src/arith/arith_Shifter_Barrel.sv";
        verifPath = "";
        fvPath = "";
    }
    part def arith_Shifter_Barrel {
        doc /* Structural contract for the SystemVerilog module. RTL follows this part. */
        attribute BITS : Integer = 32;

        in item Input;
        attribute Input_sv : String = "logic [BITS-1:0] Input";
        in item ShiftAmount;
        attribute ShiftAmount_sv : String = "logic [($clog2(BITS) > 0 ? $clog2(BITS) : 1)-1:0] ShiftAmount";
        in item ShiftRotate;
        in item LeftRight;
        in item ArithmeticLogic;
        out item Output;
        attribute Output_sv : String = "logic [BITS-1:0] Output";

        satisfy requirement REQ_arith_Shifter_Barrel_001;
    }

    part arith_Shifter_BarrelUse : arith_Shifter_Barrel;
}
