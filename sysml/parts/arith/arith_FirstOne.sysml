// SPDX-FileCopyrightText: 2007-2015 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Structural model. Edit this file before the matching SystemVerilog module.
// Baseline extracted from src/ on 2026-09-27.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

package PoC_Arith_arith_FirstOne {
    private import ScalarValues::*;
    private import ArchitectureMeta::*;
    private import PoC_Requirements_Arith::*;

    @ArtifactTrace {
        rtlPath = "src/arith/arith_FirstOne.sv";
        verifPath = "sim/arith/arith_FirstOne_tb.sv";
        fvPath = "";
    }
    part def arith_FirstOne {
        doc /* Structural contract for the SystemVerilog module. RTL follows this part. */
        attribute BITS : Integer = 8;

        in item TokenIn;
        in item Request;
        attribute Request_sv : String = "logic [BITS-1:0] Request";
        out item Grant;
        attribute Grant_sv : String = "logic [BITS-1:0] Grant";
        out item TokenOut;
        out item Index;
        attribute Index_sv : String = "logic [($clog2(BITS) > 0 ? $clog2(BITS) : 1)-1:0] Index";

        satisfy requirement REQ_arith_FirstOne_001;
        satisfy requirement REQ_arith_FirstOne_002;
        satisfy requirement REQ_arith_FirstOne_003;
    }

    part arith_FirstOneUse : arith_FirstOne;
}
