// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2007-2016 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

package poc_sync;

  localparam int SYNC_DEPTH_MIN = 2;
  localparam int SYNC_DEPTH_MAX = 16;

  typedef enum logic [1:0] {
    SYNC_MODE_UNORDERED,
    SYNC_MODE_ORDERED,
    SYNC_MODE_STRICTLY_ORDERED
  } sync_mode_t;

  function automatic logic [255:0] init_resized(
    input logic [31:0] init,
    input int          width
  );
    logic [255:0] result;
    result = '0;
    for (int i = 0; i < width; i++)
      if (i < 32)
        result[i] = init[i];
    return result;
  endfunction

endpackage
