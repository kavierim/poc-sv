# SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
#
# Verilator build lists for sim/bus/axi4stream/* testbenches.

-f verilator/files/common.f
-f verilator/files/arith.f
-f verilator/files/mem.f
-f verilator/files/sync.f
-f verilator/files/fifo.f
-f verilator/files/dstruct.f
-f verilator/files/bus.f
-f verilator/files/bus_axi_pkg.f
-f verilator/files/bus_axi4stream.f
