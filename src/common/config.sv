// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2007-2016 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

// Thin replacement for PoC config + project_configuration (generic Verilator port).
package poc_config;

  typedef enum int unsigned {
    SYNTHESIS_TOOL_UNKNOWN           = 0,
    SYNTHESIS_TOOL_GENERIC           = 1,
    SYNTHESIS_TOOL_ALTERA_QUARTUS2   = 2,
    SYNTHESIS_TOOL_LATTICE_LSE       = 3,
    SYNTHESIS_TOOL_SYNOPSIS          = 4,
    SYNTHESIS_TOOL_XILINX_XST        = 5,
    SYNTHESIS_TOOL_XILINX_VIVADO     = 6
  } synthesis_tool_t;

  localparam bit POC_VERBOSE = 1'b0;

  // Upstream uses NUL except on Quartus synthesis; this port is generic-only.
  localparam byte C_POC_NUL = 8'h00;

  function automatic synthesis_tool_t synthesis_tool(string device = "");
    if (POC_VERBOSE && device != "")
      device = device;
    return SYNTHESIS_TOOL_GENERIC;
  endfunction

  function automatic string normalize_path(string path);
    string temp;
    int    last;
    temp = path;
    for (int i = 0; i < temp.len(); i++) begin
      if (temp[i] == "\\")
        temp[i] = "/";
    end
    last = temp.len() - 1;
    if (last >= 0 && temp[last] == "/")
      return temp;
    return {temp, "/"};
  endfunction

endpackage
