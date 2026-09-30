// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Structural model. Edit this file before the matching SystemVerilog module.

package PoC_Bus_Axi4Stream_axi4stream_FIFO_TempGot {
    private import ScalarValues::*;
    private import ArchitectureMeta::*;
    private import PoC_Types_Axi4Stream::*;
    private import PoC_Requirements_Bus::*;

    @ArtifactTrace {
        rtlPath = "src/bus/axi4stream/axi4stream_FIFO_TempGot.sv";
        verifPath = "sim/bus/axi4stream/axi4stream_FIFO_TempGot_tb.sv";
        fvPath = "";
    }
    part def axi4stream_FIFO_TempGot {
        doc /* Structural contract for the SystemVerilog module. RTL follows this part. */
        attribute FRAMES : Integer = 2;
        attribute MAX_PACKET_DEPTH : Integer = 8;
        attribute METADATA_IS_DYNAMIC : Boolean = true;
        attribute DATA_BITS : Integer = 32;
        attribute USER_BITS : Integer = 1;
        attribute DEST_BITS : Integer = 1;
        attribute ID_BITS : Integer = 1;
        attribute KEEP_BITS : Integer = 0;
        attribute m2s_t : String = "axi4stream_sized#(DATA_BITS, USER_BITS, DEST_BITS, ID_BITS, KEEP_BITS)::m2s_t";
        attribute s2m_t : String = "axi4stream_sized#(DATA_BITS, USER_BITS, DEST_BITS, ID_BITS, KEEP_BITS)::s2m_t";

        in item Clock;
        in item Reset;
        in item In_m2s : axi4stream_m2s;
        out item In_s2m : axi4stream_s2m;
        out item Out_m2s : axi4stream_m2s;
        in item Out_s2m : axi4stream_s2m;
        in item Out_Commit;
        in item Out_Rollback;
        satisfy requirement REQ_axi4stream_FIFO_TempGot_001;

    }

    part axi4stream_FIFO_TempGotUse : axi4stream_FIFO_TempGot;
}
