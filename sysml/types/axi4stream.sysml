// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Ancillary repository file (not Covered Source).
// Mirrors packed structs m2s_t / s2m_t from src/bus/axi4stream/poc_axi4stream.sv.

package PoC_Types_Axi4Stream {
    private import ScalarValues::*;

    item def axi4stream_m2s {
        doc /* Packed manager-to-subordinate AXI4-Stream beat (m2s_t). */
        attribute Valid : Boolean;
        attribute Data;
        attribute Data_bits : String = "DATA_BITS";
        attribute Keep;
        attribute Keep_bits : String = "KEEP_BITS";
        attribute Last : Boolean;
        attribute User;
        attribute User_bits : String = "USER_BITS";
        attribute Dest;
        attribute Dest_bits : String = "DEST_BITS";
        attribute ID;
        attribute ID_bits : String = "ID_BITS";
    }

    item def axi4stream_s2m {
        doc /* Packed subordinate-to-manager AXI4-Stream handshake (s2m_t). */
        attribute Ready : Boolean;
        attribute User;
        attribute User_bits : String = "REV_USER_BITS";
    }

    item axi4streamM2sUse : axi4stream_m2s;
    item axi4streamS2mUse : axi4stream_s2m;
}
