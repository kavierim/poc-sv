// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Structural model. Edit this file before the matching SystemVerilog module.

package PoC_Bus_bus_Arbiter {
    private import ScalarValues::*;
    private import ArchitectureMeta::*;
    private import PoC_Requirements_Bus::*;

    @ArtifactTrace {
        rtlPath = "src/bus/bus_Arbiter.sv";
        verifPath = "";
        fvPath = "";
    }
    part def bus_Arbiter {
        doc /* Structural contract for the SystemVerilog module. RTL follows this part. */
        attribute STRATEGY : String = "RR";
        attribute PORTS : Integer = 1;
        attribute WEIGHTS : Integer = 1;
        attribute OUTPUT_REG : Boolean = false;

        in item Clock;
        in item Reset;
        in item Arbitrate;
        in item RequestVector;
        out item Arbitrated;
        out item GrantVector;
        out item GrantIndex;
        satisfy requirement REQ_bus_Arbiter_001;
        satisfy requirement REQ_bus_Arbiter_002;

    }

    part bus_ArbiterUse : bus_Arbiter;
}
