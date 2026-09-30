// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
//
// Ancillary repository file (not Covered Source). RTL is under Apache-2.0; see NOTICE.
//
// Library index. Nested packages re-export the part definitions.
// Stable URI: sysml://PoC::<Domain>::<module>

package PoC {
    doc /*
     * Nested re-export of part packages.
     * Example: sysml://PoC::Bus_Axi4Stream::axi4stream_FIFO
     */

    package Arith {
        public import PoC_Arith_arith_Adder_Wide::*;
        public import PoC_Arith_arith_CarryChain_inc::*;
        public import PoC_Arith_arith_Convert_Binary2BCD::*;
        public import PoC_Arith_arith_Counter_BCD::*;
        public import PoC_Arith_arith_Counter_Free::*;
        public import PoC_Arith_arith_Counter_Gray::*;
        public import PoC_Arith_arith_Counter_Ring::*;
        public import PoC_Arith_arith_Divider::*;
        public import PoC_Arith_arith_FirstOne::*;
        public import PoC_Arith_arith_PRNG::*;
        public import PoC_Arith_arith_Prefix_And::*;
        public import PoC_Arith_arith_Prefix_Or::*;
        public import PoC_Arith_arith_Same::*;
        public import PoC_Arith_arith_Scaler::*;
        public import PoC_Arith_arith_Shifter_Barrel::*;
        public import PoC_Arith_arith_SquareRoot::*;
        public import PoC_Arith_arith_TRNG::*;
        public import PoC_Arith_arith_cca::*;
    }

    package Bus {
        public import PoC_Bus_bus_Arbiter::*;
    }

    package Bus_Axi4 {
        public import PoC_Bus_Axi4_axi4_AXI4Lite_Converter::*;
        public import PoC_Bus_Axi4_axi4_DeMux::*;
        public import PoC_Bus_Axi4_axi4_FIFO::*;
        public import PoC_Bus_Axi4_axi4_FIFO_CDC::*;
        public import PoC_Bus_Axi4_axi4_Mux::*;
        public import PoC_Bus_Axi4_axi4_Sink::*;
        public import PoC_Bus_Axi4_axi4_Termination_Manager::*;
        public import PoC_Bus_Axi4_axi4_Termination_Subordinate::*;
    }

    package Bus_Axi4Lite {
        public import PoC_Bus_Axi4Lite_axi4lite_DeMux::*;
        public import PoC_Bus_Axi4Lite_axi4lite_FIFO::*;
        public import PoC_Bus_Axi4Lite_axi4lite_FIFO_CDC::*;
        public import PoC_Bus_Axi4Lite_axi4lite_OCRAM_Adapter::*;
        public import PoC_Bus_Axi4Lite_axi4lite_Register::*;
        public import PoC_Bus_Axi4Lite_axi4lite_Termination_Manager::*;
        public import PoC_Bus_Axi4Lite_axi4lite_Termination_Subordinate::*;
    }

    package Bus_Axi4Stream {
        public import PoC_Bus_Axi4Stream_axi4stream_DeMux::*;
        public import PoC_Bus_Axi4Stream_axi4stream_FIFO::*;
        public import PoC_Bus_Axi4Stream_axi4stream_FIFO_CDC::*;
        public import PoC_Bus_Axi4Stream_axi4stream_FIFO_TempGot::*;
        public import PoC_Bus_Axi4Stream_axi4stream_FIFO_TempPut::*;
        public import PoC_Bus_Axi4Stream_axi4stream_Mux::*;
        public import PoC_Bus_Axi4Stream_axi4stream_Pause::*;
        public import PoC_Bus_Axi4Stream_axi4stream_Stage::*;
        public import PoC_Bus_Axi4Stream_axi4stream_Termination_Receiver::*;
        public import PoC_Bus_Axi4Stream_axi4stream_Termination_Transmitter::*;
    }

    package Dstruct {
        public import PoC_Dstruct_dstruct_OutOfOrderBuffer::*;
    }

    package Fifo {
        public import PoC_Fifo_fifo_Shift::*;
        public import PoC_Fifo_fifo_Stage::*;
        public import PoC_Fifo_fifo_cc_got::*;
        public import PoC_Fifo_fifo_cc_got_tempgot::*;
        public import PoC_Fifo_fifo_cc_got_tempput::*;
        public import PoC_Fifo_fifo_ic_assembly::*;
        public import PoC_Fifo_fifo_ic_got::*;
    }

    package Mem {
        public import PoC_Mem_ocram_EnhancedSimpleDualPort::*;
        public import PoC_Mem_ocram_SimpleDualPort::*;
        public import PoC_Mem_ocram_SimpleDualPort_Optimized::*;
        public import PoC_Mem_ocram_SimpleDualPort_WriteFirst::*;
        public import PoC_Mem_ocram_SinglePort::*;
        public import PoC_Mem_ocram_TrueDualPort::*;
        public import PoC_Mem_ocram_TrueDualPort_Simulation::*;
        public import PoC_Mem_ocram_TrueDualPort_WriteFirst::*;
    }

    package Sync {
        public import PoC_Sync_sync_Bits::*;
        public import PoC_Sync_sync_Command::*;
        public import PoC_Sync_sync_Pulse::*;
        public import PoC_Sync_sync_Reset::*;
        public import PoC_Sync_sync_Strobe::*;
        public import PoC_Sync_sync_Vector::*;
    }

}
