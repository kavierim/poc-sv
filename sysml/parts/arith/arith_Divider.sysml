// SPDX-FileCopyrightText: 2007-2016 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Structural model. Edit this file before the matching SystemVerilog module.
// Baseline extracted from src/ on 2026-09-27.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

package PoC_Arith_arith_Divider {
    private import ScalarValues::*;
    private import ArchitectureMeta::*;
    private import PoC_Requirements_Arith::*;

    @ArtifactTrace {
        rtlPath = "src/arith/arith_Divider.sv";
        verifPath = "";
        fvPath = "";
    }
    part def arith_Divider {
        doc /* Structural contract for the SystemVerilog module. RTL follows this part. */
        attribute DIVIDEND_BITS : Integer = 32;
        attribute DIVISOR_BITS : Integer = 16;
        attribute RADIX_EXPONENT : Integer = 1;
        attribute PIPELINED : Boolean = false;

        in item Clock;
        in item Reset;
        in item Start;
        out item Ready;
        in item Dividend;
        attribute Dividend_sv : String = "logic [DIVIDEND_BITS-1:0] Dividend";
        in item Divisor;
        attribute Divisor_sv : String = "logic [DIVISOR_BITS-1:0] Divisor";
        out item Quotient;
        attribute Quotient_sv : String = "logic [DIVIDEND_BITS-1:0] Quotient";
        out item Remainder;
        attribute Remainder_sv : String = "logic [DIVISOR_BITS-1:0] Remainder";
        out item DivisionByZero;

        satisfy requirement REQ_arith_Divider_001;
    }

    part arith_DividerUse : arith_Divider;
}
