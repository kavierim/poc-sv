// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2007-2016 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Structural model. Edit this file before the matching SystemVerilog module.
// Baseline extracted from src/ on 2026-09-27.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

package PoC_Arith_arith_Convert_Binary2BCD {
    private import ScalarValues::*;
    private import ArchitectureMeta::*;
    private import PoC_Requirements_Arith::*;

    @ArtifactTrace {
        rtlPath = "src/arith/arith_Convert_Binary2BCD.sv";
        verifPath = "";
        fvPath = "";
    }
    part def arith_Convert_Binary2BCD {
        doc /* Structural contract for the SystemVerilog module. RTL follows this part. */
        attribute BITS : Integer = 8;
        attribute DIGITS : Integer = 3;
        attribute RADIX : Integer = 2;
        attribute REGISTER_OUTPUT : Boolean = false;

        in item Clock;
        in item Reset;
        in item Start;
        out item Busy;
        in item Binary;
        attribute Binary_sv : String = "logic [BITS-1:0] Binary";
        in item IsSigned;
        out item BCDDigits;
        attribute BCDDigits_sv : String = "poc_utils::bcd_t BCDDigits [DIGITS]";
        out item Sign;

        satisfy requirement REQ_arith_Convert_Binary2BCD_001;
    }

    part arith_Convert_Binary2BCDUse : arith_Convert_Binary2BCD;
}
