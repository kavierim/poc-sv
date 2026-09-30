// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Ancillary repository file (not Covered Source).
// Mirrors packed structs bus_m2s_t / bus_s2m_t from src/bus/axi4lite/poc_axi4lite.sv.

package PoC_Types_Axi4Lite {
    private import ScalarValues::*;

    item def axi4lite_m2s {
        doc /* Packed AXI4-Lite manager-to-subordinate bus (bus_m2s_t). */
        attribute AWValid : Boolean;
        attribute AWAddr;
        attribute AWAddr_bits : String = "ADDRESS_BITS";
        attribute AWCache { doc /* Fixed 4-bit T_AXI4_Cache. */ }
        attribute AWProt { doc /* Fixed 3-bit T_AXI4_Protect. */ }
        attribute WValid : Boolean;
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
        attribute RReady : Boolean;
    }

    item def axi4lite_s2m {
        doc /* Packed AXI4-Lite subordinate-to-manager bus (bus_s2m_t). */
        attribute WReady : Boolean;
        attribute BValid : Boolean;
        attribute BResp { doc /* Fixed 2-bit T_AXI4_Response. */ }
        attribute ARReady : Boolean;
        attribute AWReady : Boolean;
        attribute RValid : Boolean;
        attribute RData;
        attribute RData_bits : String = "DATA_BITS";
        attribute RResp { doc /* Fixed 2-bit T_AXI4_Response. */ }
    }

    item axi4liteM2sUse : axi4lite_m2s;
    item axi4liteS2mUse : axi4lite_s2m;
}
