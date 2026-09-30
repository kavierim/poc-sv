// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Ancillary repository file (not Covered Source).
// Mirrors packed structs bus_m2s_t / bus_s2m_t from src/bus/axi4/poc_axi4_full.sv.

package PoC_Types_Axi4 {
    private import ScalarValues::*;

    item def axi4_m2s {
        doc /* Packed AXI4-Full manager-to-subordinate bus (bus_m2s_t). */
        attribute AWID;
        attribute AWID_bits : String = "ID_BITS";
        attribute AWAddr;
        attribute AWAddr_bits : String = "ADDRESS_BITS";
        attribute AWLen { doc /* Fixed 8-bit burst length. */ }
        attribute AWSize { doc /* Fixed 3-bit T_AXI4_Size. */ }
        attribute AWBurst { doc /* Fixed 2-bit T_AXI4_Burst. */ }
        attribute AWLock : Boolean;
        attribute AWQOS { doc /* Fixed 4-bit T_AXI4_QoS. */ }
        attribute AWRegion { doc /* Fixed 4-bit T_AXI4_Region. */ }
        attribute AWUser;
        attribute AWUser_bits : String = "USER_BITS";
        attribute AWValid : Boolean;
        attribute AWCache { doc /* Fixed 4-bit T_AXI4_Cache. */ }
        attribute AWProt { doc /* Fixed 3-bit T_AXI4_Protect. */ }
        attribute WValid : Boolean;
        attribute WLast : Boolean;
        attribute WUser;
        attribute WUser_bits : String = "USER_BITS";
        attribute WData;
        attribute WData_bits : String = "DATA_BITS";
        attribute WStrb { doc /* Width ceil(DATA_BITS/8). */ }
        attribute WStrb_bits : String = "DATA_BITS";
        attribute BReady : Boolean;
        attribute ARValid : Boolean;
        attribute ARAddr;
        attribute ARAddr_bits : String = "ADDRESS_BITS";
        attribute ARCache { doc /* Fixed 4-bit T_AXI4_Cache. */ }
        attribute ARProt { doc /* Fixed 3-bit T_AXI4_Protect. */ }
        attribute ARID;
        attribute ARID_bits : String = "ID_BITS";
        attribute ARLen { doc /* Fixed 8-bit burst length. */ }
        attribute ARSize { doc /* Fixed 3-bit T_AXI4_Size. */ }
        attribute ARBurst { doc /* Fixed 2-bit T_AXI4_Burst. */ }
        attribute ARLock : Boolean;
        attribute ARQOS { doc /* Fixed 4-bit T_AXI4_QoS. */ }
        attribute ARRegion { doc /* Fixed 4-bit T_AXI4_Region. */ }
        attribute ARUser;
        attribute ARUser_bits : String = "USER_BITS";
        attribute RReady : Boolean;
    }

    item def axi4_s2m {
        doc /* Packed AXI4-Full subordinate-to-manager bus (bus_s2m_t). */
        attribute AWReady : Boolean;
        attribute WReady : Boolean;
        attribute BValid : Boolean;
        attribute BResp { doc /* Fixed 2-bit T_AXI4_Response. */ }
        attribute BID;
        attribute BID_bits : String = "ID_BITS";
        attribute BUser;
        attribute BUser_bits : String = "USER_BITS";
        attribute ARReady : Boolean;
        attribute RValid : Boolean;
        attribute RData;
        attribute RData_bits : String = "DATA_BITS";
        attribute RResp { doc /* Fixed 2-bit T_AXI4_Response. */ }
        attribute RID;
        attribute RID_bits : String = "ID_BITS";
        attribute RLast : Boolean;
        attribute RUser;
        attribute RUser_bits : String = "USER_BITS";
    }

    item axi4M2sUse : axi4_m2s;
    item axi4S2mUse : axi4_s2m;
}
