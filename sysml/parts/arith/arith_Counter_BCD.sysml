// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2007-2016 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Structural model. Edit this file before the matching SystemVerilog module.
// Baseline extracted from src/ on 2026-09-27.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

package PoC_Arith_arith_Counter_BCD {
    private import ScalarValues::*;
    private import ArchitectureMeta::*;
    private import PoC_Requirements_Arith::*;

    @ArtifactTrace {
        rtlPath = "src/arith/arith_Counter_BCD.sv";
        verifPath = "";
        fvPath = "";
    }
    part def arith_Counter_BCD {
        doc /* Structural contract for the SystemVerilog module. RTL follows this part. */
        attribute DIGITS : Integer = 2;

        in item Clock;
        in item Reset;
        in item Increment;
        out item Value;
        attribute Value_sv : String = "poc_utils::bcd_t Value [DIGITS]";

        satisfy requirement REQ_arith_Counter_BCD_001;
    }

    part arith_Counter_BCDUse : arith_Counter_BCD;
}
