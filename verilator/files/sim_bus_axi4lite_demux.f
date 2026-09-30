# SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
#
# DeMux testbench additionally requires axi4_DeMux (wave 3 axi4 entities).

-f verilator/files/sim_bus_axi4lite.f
-f verilator/files/dstruct.f
-f verilator/files/arith.f
-f verilator/files/bus_axi4stream.f
-f verilator/files/bus_axi4.f
-f verilator/files/bus_axi4lite_demux.f
