// SPDX-FileCopyrightText: 2008-2015 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

package poc_ocram;

  import poc_mem::*;

  function automatic logic to_x01_sl(input logic v);
    if (v === 1'b1)
      return 1'b1;
    if (v === 1'b0)
      return 1'b0;
    return 1'bx;
  endfunction

  class address_cmp #(parameter int ADDR_BITS = 1);
    static function automatic logic is_x_addr(input logic [ADDR_BITS-1:0] vec);
      for (int i = 0; i < ADDR_BITS; i++)
        if (vec[i] === 1'bx || vec[i] === 1'bz)
          return 1'b1;
      return 1'b0;
    endfunction

    static function automatic logic is_equal(
      input logic [ADDR_BITS-1:0] addressA,
      input logic [ADDR_BITS-1:0] addressB
    );
      if (is_x_addr(addressA) || is_x_addr(addressB))
        return 1'bx;
      return (addressA == addressB) ? 1'b1 : 1'b0;
    endfunction
  endclass

endpackage
