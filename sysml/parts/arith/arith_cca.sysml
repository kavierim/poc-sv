// SPDX-FileCopyrightText: 2007-2016 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Structural model. Edit this file before the matching SystemVerilog module.
// Baseline extracted from src/ on 2026-09-27.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

package PoC_Arith_arith_cca {
    private import ScalarValues::*;
    private import ArchitectureMeta::*;
    private import PoC_Requirements_Arith::*;

    @ArtifactTrace {
        rtlPath = "src/arith/arith_cca.sv";
        verifPath = "";
        fvPath = "";
    }
    part def arith_cca {
        doc /* Structural contract for the SystemVerilog module. RTL follows this part. */
        attribute BITS : Integer = 32;
        attribute L : Integer = 20;
        attribute X : Integer = 0;

        in item a;
        attribute a_sv : String = "logic [BITS-1:0] a";
        in item b;
        attribute b_sv : String = "logic [BITS-1:0] b";
        in item c;
        out item s;
        attribute s_sv : String = "logic [BITS-1:0] s";

        satisfy requirement REQ_arith_cca_001;
    }

    part arith_ccaUse : arith_cca;
}
