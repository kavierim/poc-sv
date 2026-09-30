# SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
#
# Verilator build lists for sim/bus/axi4lite/* testbenches.

# OCRAM + Register (no axi4 entity RTL beyond packages/converter).
-f verilator/files/common.f
-f verilator/files/sync.f
-f verilator/files/mem.f
-f verilator/files/fifo.f
-f verilator/files/bus_axi_pkg.f
-f verilator/files/bus_axi4lite.f
