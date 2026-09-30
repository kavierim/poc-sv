// SPDX-FileCopyrightText: 2007-2016 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Structural model. Edit this file before the matching SystemVerilog module.
// Baseline extracted from src/ on 2026-09-27.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

package PoC_Arith_arith_Scaler {
    private import ScalarValues::*;
    private import ArchitectureMeta::*;
    private import PoC_Requirements_Arith::*;

    @ArtifactTrace {
        rtlPath = "src/arith/arith_Scaler.sv";
        verifPath = "";
        fvPath = "";
    }
    part def arith_Scaler {
        doc /* Structural contract for the SystemVerilog module. RTL follows this part. */
        attribute MUL_COUNT : Integer = 1;
        attribute DIV_COUNT : Integer = 1;
        attribute MUL0 : Integer = 1;
        attribute MUL1 : Integer = 1;
        attribute MUL2 : Integer = 1;
        attribute MUL3 : Integer = 1;
        attribute DIV0 : Integer = 1;
        attribute DIV1 : Integer = 1;
        attribute DIV2 : Integer = 1;
        attribute DIV3 : Integer = 1;
        attribute BITS : Integer = 32;

        in item Clock;
        in item Reset;
        in item Start;
        in item Operand;
        attribute Operand_sv : String = "logic [BITS-1:0] Operand";
        in item MultiplierSelect;
        attribute MultiplierSelect_sv : String = "logic [($clog2(MUL_COUNT) > 0 ? $clog2(MUL_COUNT) : 1)-1:0] MultiplierSelect";
        in item DivisorSelect;
        attribute DivisorSelect_sv : String = "logic [($clog2(DIV_COUNT) > 0 ? $clog2(DIV_COUNT) : 1)-1:0] DivisorSelect";
        out item Result;
        attribute Result_sv : String = "logic [BITS-1:0] Result";
        out item Done;

        satisfy requirement REQ_arith_Scaler_001;
    }

    part arith_ScalerUse : arith_Scaler;
}
