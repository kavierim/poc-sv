// SPDX-FileCopyrightText: 2007-2017 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Structural model. Edit this file before the matching SystemVerilog module.
// Baseline extracted from src/ on 2026-09-27.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

package PoC_Arith_arith_TRNG {
    private import ScalarValues::*;
    private import ArchitectureMeta::*;
    private import PoC_Requirements_Arith::*;

    @ArtifactTrace {
        rtlPath = "src/arith/arith_TRNG.sv";
        verifPath = "";
        fvPath = "";
    }
    part def arith_TRNG {
        doc /* Structural contract for the SystemVerilog module. RTL follows this part. */
        attribute BITS : Integer = 8;

        in item Clock;
        out item Value;
        attribute Value_sv : String = "logic [BITS-1:0] Value";

        satisfy requirement REQ_arith_TRNG_001;
    }

    part arith_TRNGUse : arith_TRNG;
}
