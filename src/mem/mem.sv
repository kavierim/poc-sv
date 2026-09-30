// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2008-2015 Technische Universitaet Dresden
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273

`timescale 1ns/1ps

package poc_mem;

`ifndef SYNTHESIS
  import poc_strings::str_length;
  import poc_strings::str_to_lower;
`endif

  typedef enum int unsigned {
    MEM_FILEFORMAT_INTEL_HEX,
    MEM_FILEFORMAT_LATTICE_MEM,
    MEM_FILEFORMAT_XILINX_MEM
  } mem_fileformat_t;

  typedef enum int unsigned {
    MEM_CONTENT_BINARY,
    MEM_CONTENT_DECIMAL,
    MEM_CONTENT_HEX
  } mem_content_t;

  typedef enum int unsigned {
    RAM_TYPE_AUTO,
    RAM_TYPE_OPTIMIZED,
    RAM_TYPE_LUT_RAM,
    RAM_TYPE_BLOCK_RAM,
    RAM_TYPE_ULTRA_RAM
  } ram_type_t;

`ifndef SYNTHESIS
  function automatic string mem_FileExtension(string filename);
    for (int i = filename.len() - 1; i >= 0; i--) begin
      if (filename[i] == ".")
        return str_to_lower(filename.substr(i + 1, filename.len() - 1));
    end
    return "";
  endfunction

  function automatic string get_ramstyle_string(ram_type_t ram_style);
    if (ram_style == RAM_TYPE_LUT_RAM)
      return "no_rw_check";
    return "no_rw_check";
  endfunction

  function automatic string get_ram_style_string(ram_type_t ram_style);
    if (ram_style == RAM_TYPE_BLOCK_RAM)
      return "block";
    return "";
  endfunction

`endif

  class ram_type_split;
    static function automatic void get_ram_type_vec(input int a, input int d, output int depth[2]);
      int reminder;
      depth[0] = 0;
      depth[1] = 0;
      reminder = d;

      if (a <= 8)
        return;

      if (a == 9) begin
        depth[1] = reminder / 36;
        reminder = reminder - (depth[1] * 36);
        if (reminder > 28)
          depth[1] = depth[1] + 1;
      end else if (a == 10) begin
        depth[1] = reminder / 18;
        reminder = reminder - (depth[1] * 18);
        if (reminder > 14)
          depth[1] = depth[1] + 1;
      end else if (a == 11) begin
        depth[1] = reminder / 9;
        reminder = reminder - (depth[1] * 9);
        if (reminder > 6)
          depth[1] = depth[1] + 1;
      end else if (a == 12) begin
        depth[0] = reminder / 72;
        reminder = reminder - (depth[0] * 72);
        if (reminder > 57)
          depth[0] = depth[0] + 1;
        else begin
          depth[1] = reminder / 4;
          reminder = reminder - (depth[1] * 4);
          if (reminder > 2)
            depth[1] = depth[1] + 1;
        end
      end else if (a == 13) begin
        depth[0] = reminder / 72;
        reminder = reminder - (depth[0] * 72);
        if (reminder > 57)
          depth[0] = depth[0] + 1;
        else begin
          depth[1] = reminder / 2;
          reminder = reminder - (depth[1] * 2);
          if (reminder > 0)
            depth[1] = depth[1] + 1;
        end
      end else if (a == 14) begin
        depth[0] = reminder / 72;
        reminder = reminder - (depth[0] * 72);
        if (reminder > 57)
          depth[0] = depth[0] + 1;
        else
          depth[1] = reminder;
      end else begin
        depth[0] = -1;
        depth[1] = -1;
      end
    endfunction
  endclass

  function automatic int get_BRAM_half_width(input int a);
    case (a)
      9: return 36;
      10: return 18;
      11: return 9;
      12: return 4;
      13: return 2;
      14: return 1;
      default: return -1;
    endcase
  endfunction

  function automatic int get_BRAM_full_width(input int a);
    case (a)
      9: return 72;
      10: return 36;
      11: return 18;
      12: return 9;
      13: return 4;
      14: return 2;
      15: return 1;
      default: return -1;
    endcase
  endfunction

`ifndef SYNTHESIS
  class ram_init #(parameter int WORDS = 1, parameter int DATA_BITS = 8);
    static function automatic void init_words(
      ref logic [DATA_BITS-1:0] mem[0:WORDS-1],
      input string              file_path
    );
      for (int i = 0; i < WORDS; i++)
        mem[i] = '0;
      if (str_length(file_path) == 0)
        return;

      if (mem_FileExtension(file_path) == "mem") begin
        int    fd;
        string header_line;
        fd = $fopen(file_path, "r");
        if (fd == 0) begin
          $fatal(1, "poc_mem: cannot open memory file '%s'", file_path);
          return;
        end
        if ($fgets(header_line, fd) == 0)
          $warning("poc_mem: Xilinx .mem file '%s' is empty", file_path);
        else if (header_line.len() == 0)
          $warning("poc_mem: Xilinx .mem header line empty in '%s'", file_path);
        $fclose(fd);
      end

      $readmemh(file_path, mem);
    endfunction
  endclass
`endif


endpackage
