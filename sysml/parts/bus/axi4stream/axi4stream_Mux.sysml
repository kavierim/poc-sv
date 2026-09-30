// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Structural model. Edit this file before the matching SystemVerilog module.

package PoC_Bus_Axi4Stream_axi4stream_Mux {
    private import ScalarValues::*;
    private import ArchitectureMeta::*;
    private import PoC_Types_Axi4Stream::*;
    private import PoC_Requirements_Bus::*;

    @ArtifactTrace {
        rtlPath = "src/bus/axi4stream/axi4stream_Mux.sv";
        verifPath = "sim/bus/axi4stream/axi4stream_Mux_tb.sv";
        fvPath = "";
    }
    part def axi4stream_Mux {
        doc /* Structural contract for the SystemVerilog module. RTL follows this part. */
        attribute USE_CONTROL_VECTOR : Boolean = false;
        attribute APPEND_DEST_BITS : Boolean = false;
        attribute PORTS : Integer = 2;
        attribute DATA_BITS : Integer = 32;
        attribute USER_BITS : Integer = 1;
        attribute DEST_BITS : Integer = 1;
        attribute ID_BITS : Integer = 1;
        attribute KEEP_BITS : Integer = 0;
        attribute m2s_t : String = "axi4stream_sized#(DATA_BITS, USER_BITS, DEST_BITS, ID_BITS, KEEP_BITS)::m2s_t";
        attribute s2m_t : String = "axi4stream_sized#(DATA_BITS, USER_BITS, DEST_BITS, ID_BITS, KEEP_BITS)::s2m_t";

        in item Clock;
        in item Reset;
        in item MuxControl;
        in item In_M2S : axi4stream_m2s;
        out item In_S2M : axi4stream_s2m;
        out item Out_M2S : axi4stream_m2s;
        in item Out_S2M : axi4stream_s2m;
        satisfy requirement REQ_axi4stream_Mux_001;
        satisfy requirement REQ_axi4stream_Mux_002;

    }

    part axi4stream_MuxUse : axi4stream_Mux;
}
