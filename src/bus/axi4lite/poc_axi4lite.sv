// SPDX-FileCopyrightText: 2025-2026 The PoC-Library Authors
// SPDX-FileCopyrightText: 2026 Kari Vierimaa, Kempele, Finland
// SPDX-License-Identifier: Apache-2.0
//
// Modified: 2026-09-27, Kari Vierimaa, Kempele, Finland.
// Translated from VHDL to SystemVerilog.
// Upstream: https://github.com/VHDL/PoC tag v3.0.0 commit b9040273
// VHDL: PoC/src/bus/axi4lite/axi4lite.pkg.vhdl

`timescale 1ns/1ps

package poc_axi4lite;

  import poc_axi4_common::*;
  import poc_config::POC_VERBOSE;
  import poc_utils::*;
  import poc_config::C_POC_NUL;
  import poc_strings::*;

  localparam bit DEBUG = POC_VERBOSE;

  localparam int ADDRESS_BITS = 32;
  localparam int DATA_BITS    = 32;
  localparam int NAME_LENGTH  = 64;

  typedef enum logic [3:0] {
    ConstantValue,
    ReadOnly,
    ReadOnly_NotRegistered,
    ReadWrite,
    ReadWrite_NotRegistered,
    LatchValue_ClearOnRead,
    LatchValue_ClearOnWrite,
    LatchHighBit_ClearOnRead,
    LatchHighBit_ClearOnWrite,
    LatchLowBit_ClearOnRead,
    LatchLowBit_ClearOnWrite,
    Reserved
  } T_axi4lite_RegisterModes;

  typedef struct {
    string                  Name;
    logic [ADDRESS_BITS-1:0] Address;
    T_axi4lite_RegisterModes RegisterMode;
    logic [DATA_BITS-1:0]   Init_Value;
    logic [DATA_BITS-1:0]   AutoClear_Mask;
    bit                     IsInterruptRegister;
  } T_AXI4_Register;

  // Dynamic register description tables use T_AXI4_Register desc[] in APIs.

  // Package-scope type bundle (structs only) for synthesizable port types.
  class axi4lite_types #(
    parameter int ADDR_W = 32,
    parameter int DATA_W = 32
  );
    localparam int WSTRB_W = div_ceil(DATA_W, 8);

    typedef struct packed {
      logic        AWValid;
      logic [ADDR_W-1:0] AWAddr;
      T_AXI4_Cache AWCache;
      T_AXI4_Protect AWProt;
      logic        WValid;
      logic [DATA_W-1:0] WData;
      logic [WSTRB_W-1:0] WStrb;
      logic        BReady;
      logic        ARValid;
      logic [ADDR_W-1:0] ARAddr;
      T_AXI4_Cache ARCache;
      T_AXI4_Protect ARProt;
      logic        RReady;
    } bus_m2s_t;

    typedef struct packed {
      logic        WReady;
      logic        BValid;
      T_AXI4_Response BResp;
      logic        ARReady;
      logic        AWReady;
      logic        RValid;
      logic [DATA_W-1:0] RData;
      T_AXI4_Response RResp;
    } bus_s2m_t;

    typedef struct packed {
      bus_m2s_t M2S;
      bus_s2m_t S2M;
    } bus_t;
  endclass

  class axi4lite_sized #(
    parameter int ADDR_W = 32,
    parameter int DATA_W = 32
  );
    localparam int WSTRB_W = div_ceil(DATA_W, 8);

    typedef axi4lite_types#(ADDR_W, DATA_W)::bus_m2s_t bus_m2s_t;
    typedef axi4lite_types#(ADDR_W, DATA_W)::bus_s2m_t bus_s2m_t;
    typedef axi4lite_types#(ADDR_W, DATA_W)::bus_t     bus_t;

    typedef bus_m2s_t bus_m2s_vector_t[];
    typedef bus_s2m_t bus_s2m_vector_t[];

    typedef bus_m2s_t T_AXI4LITE_BUS_M2S;
    typedef bus_s2m_t T_AXI4LITE_BUS_S2M;
    typedef bus_t     T_axi4lite_Bus;
    typedef bus_m2s_vector_t T_AXI4LITE_BUS_M2S_VECTOR;
    typedef bus_s2m_vector_t T_AXI4LITE_BUS_S2M_VECTOR;
    typedef bus_m2s_t Sized_M2S;
    typedef bus_s2m_t Sized_S2M;
    typedef bus_m2s_vector_t Sized_M2S_Vector;
    typedef bus_s2m_vector_t Sized_S2M_Vector;

    static function automatic bus_m2s_t enable_transaction_m2s(input bus_m2s_t in_bus, input logic enable);
      bus_m2s_t temp;
      temp        = in_bus;
      temp.AWValid = in_bus.AWValid & enable;
      temp.WValid  = in_bus.WValid & enable;
      temp.BReady  = in_bus.BReady & enable;
      temp.ARValid = in_bus.ARValid & enable;
      temp.RReady  = in_bus.RReady & enable;
      return temp;
    endfunction

    static function automatic bus_s2m_t enable_transaction_s2m(input bus_s2m_t in_bus, input logic enable);
      bus_s2m_t temp;
      temp         = in_bus;
      temp.WReady  = in_bus.WReady & enable;
      temp.BValid  = in_bus.BValid & enable;
      temp.ARReady = in_bus.ARReady & enable;
      temp.AWReady = in_bus.AWReady & enable;
      temp.RValid  = in_bus.RValid & enable;
      return temp;
    endfunction

    static function automatic bus_m2s_t address_translate_m2s(
      input bus_m2s_t in_bus,
      input logic signed [ADDR_W-1:0] offset
    );
      bus_m2s_t temp;
      temp        = in_bus;
      temp.AWAddr = in_bus.AWAddr + offset[ADDR_W-1:0];
      temp.ARAddr = in_bus.ARAddr + offset[ADDR_W-1:0];
      return temp;
    endfunction

    static function automatic bus_m2s_t address_mask_m2s(
      input bus_m2s_t in_bus,
      input logic [ADDR_W-1:0] mask
    );
      bus_m2s_t temp;
      temp        = in_bus;
      temp.AWAddr = in_bus.AWAddr & mask;
      temp.ARAddr = in_bus.ARAddr & mask;
      return temp;
    endfunction

    static function automatic bus_m2s_t initialize_bus_m2s(input logic value = 1'b0);
      bus_m2s_t init;
      init.AWValid = value;
      init.AWCache = {4{value}};
      init.AWAddr  = {ADDR_W{value}};
      init.AWProt  = {3{value}};
      init.WValid  = value;
      init.WData   = {DATA_W{value}};
      init.WStrb   = {WSTRB_W{value}};
      init.BReady  = value;
      init.ARValid = value;
      init.ARCache = {4{value}};
      init.ARAddr  = {ADDR_W{value}};
      init.ARProt  = {3{value}};
      init.RReady  = value;
      return init;
    endfunction

    static function automatic bus_s2m_t initialize_bus_s2m(input logic value = 1'b0);
      bus_s2m_t init;
      init.AWReady = value;
      init.WReady  = value;
      init.BValid  = value;
      init.BResp   = {2{value}};
      init.ARReady = value;
      init.RValid  = value;
      init.RData   = {DATA_W{value}};
      init.RResp   = {2{value}};
      return init;
    endfunction

    static function automatic bus_t initialize_bus();
      bus_t init;
      init.M2S = initialize_bus_m2s();
      init.S2M = initialize_bus_s2m();
      return init;
    endfunction
  endclass

  function automatic bit str_ifind_pat(string str, string pattern);
    if (pattern.len() == 0)
      return 0;
    for (int i = 0; i <= str.len() - pattern.len(); i++) begin
      bit match;
      match = 1'b1;
      for (int j = 0; j < pattern.len(); j++)
        if (str[i+j] != pattern[j])
          match = 1'b0;
      if (match)
        return 1'b1;
    end
    return 1'b0;
  endfunction

  function automatic string str_replace_all_chr(string str, byte pattern, byte replace);
    string r;
    r = str;
    for (int i = 0; i < r.len(); i++)
      if (r[i] == pattern)
        r[i] = replace;
    return r;
  endfunction

  function automatic string reg_to_string(T_AXI4_Register entry);
    string nm;
    nm = resize(entry.Name, NAME_LENGTH);
    nm = str_replace_all_chr(nm, C_POC_NUL, " ");
    return {" Name: ", nm, ", Address: 0x",
            slv_to_str#(ADDRESS_BITS)::to_string(entry.Address, "h", 4),
            ", Init_Value: 0x", slv_to_str#(DATA_BITS)::to_string(entry.Init_Value, "h", 4),
            ", AutoClear_Mask : 0x", slv_to_str#(DATA_BITS)::to_string(entry.AutoClear_Mask, "h", 4),
            ", RegisterMode: ", $sformatf("%0d", entry.RegisterMode)};
  endfunction

  function automatic T_AXI4_Register to_AXI4_Register(
    string                  name,
    logic [ADDRESS_BITS-1:0] address,
    T_axi4lite_RegisterModes register_mode = ReadWrite,
    logic [DATA_BITS-1:0]   init_value = '0,
    logic [DATA_BITS-1:0]   auto_clear_mask = '0,
    bit                     is_interrupt_register = 1'b0
  );
    T_AXI4_Register r;
    r.Name                  = resize(name, NAME_LENGTH);
    r.Address               = address;
    r.RegisterMode          = register_mode;
    r.Init_Value            = init_value;
    r.AutoClear_Mask        = auto_clear_mask;
    r.IsInterruptRegister   = is_interrupt_register;
    return r;
  endfunction

  function automatic void normalize(
    input  T_AXI4_Register desc_in[],
    output T_AXI4_Register desc_out[]
  );
    desc_out = desc_in;
  endfunction

  function automatic void filter_Register_Description_Vector(
    string                  str,
    T_AXI4_Register         description_vector[],
    T_AXI4_Register         filtered_out[]
  );
    T_AXI4_Register temp[];
    int                    pos;
    pos  = 0;
    temp = new[description_vector.size()];
    for (int i = 0; i < description_vector.size(); i++) begin
      string nm;
      nm = resize(description_vector[i].Name, NAME_LENGTH);
      if (str.len() > 0 && nm.substr(0, str.len() - 1) != str) begin
        temp[pos] = description_vector[i];
        pos++;
      end
    end
    filtered_out = new[pos];
    for (int i = 0; i < pos; i++)
      filtered_out[i] = temp[i];
  endfunction

  function automatic void filter_Register_Description_Vector_by_char(
    byte            ch,
    T_AXI4_Register description_vector[],
    T_AXI4_Register filtered_out[]
  );
    T_AXI4_Register temp[];
    int                    pos;
    pos  = 0;
    temp = new[description_vector.size()];
    for (int i = 0; i < description_vector.size(); i++) begin
      string nm;
      nm = resize(description_vector[i].Name, NAME_LENGTH);
      if (nm[0] != ch) begin
        temp[pos] = description_vector[i];
        pos++;
      end
    end
    filtered_out = new[pos];
    for (int i = 0; i < pos; i++)
      filtered_out[i] = temp[i];
  endfunction

  function automatic void add_Prefix(
    string                  prefix,
    T_AXI4_Register         cfg[],
    logic [ADDRESS_BITS-1:0] offset,
    T_AXI4_Register         prefixed_out[]
  );
    T_AXI4_Register temp[];
    temp = new[cfg.size()];
    for (int i = 0; i < cfg.size(); i++) begin
      temp[i]         = cfg[i];
      temp[i].Name    = resize({prefix, cfg[i].Name}, NAME_LENGTH);
      temp[i].Address = cfg[i].Address + offset;
    end
    prefixed_out = temp;
  endfunction

  function automatic logic [ADDRESS_BITS-1:0] get_Addresses(
    T_AXI4_Register description_vector[],
    int               index
  );
    return description_vector[index].Address;
  endfunction

  function automatic logic [DATA_BITS-1:0] get_InitValue(
    T_AXI4_Register description_vector[],
    int               index
  );
    return description_vector[index].Init_Value;
  endfunction

  function automatic logic [DATA_BITS-1:0] get_AutoClearMask(
    T_AXI4_Register description_vector[],
    int               index
  );
    return description_vector[index].AutoClear_Mask;
  endfunction

  function automatic int get_RegisterAddressBits(T_AXI4_Register cfg[]);
    int temp;
    temp = 1;
    for (int i = 0; i < cfg.size(); i++)
      if (cfg[i].Address > temp)
        temp = int'(cfg[i].Address);
    return log2ceil(temp + 1);
  endfunction

  function automatic logic [DATA_BITS-1:0] get_StrobeVector(
    T_AXI4_Register cfg[],
    int             index
  );
    if (cfg[index].RegisterMode == ReadWrite)
      return '0;
    return '1;
  endfunction

  function automatic void Filter_DescriptionVector(
    T_AXI4_Register cfg[],
    logic           filter[],
    T_AXI4_Register filtered_out[]
  );
    T_AXI4_Register temp[];
    int             pos;
    int             n_on;
    n_on = 0;
    for (int i = 0; i < filter.size(); i++)
      if (filter[i] == 1'b1)
        n_on++;
    temp = new[n_on];
    pos  = 0;
    for (int i = 0; i < cfg.size(); i++) begin
      if (filter[i] == 1'b1) begin
        temp[pos] = cfg[i];
        pos++;
      end
    end
    filtered_out = temp;
  endfunction

  function automatic int get_Index(string name, T_AXI4_Register register_vector[]);
    for (int i = 0; i < register_vector.size(); i++)
      if (str_imatch(register_vector[i].Name, name)) begin
        if (DEBUG)
          $display("PoC.axi4lite: get_Index('%s') found at %0d", name, i);
        return i;
      end
    if (DEBUG)
      $warning("PoC.axi4lite: get_Index('%s') no match", name);
`ifndef SYNTHESIS
    else
      $fatal(1, "PoC.axi4lite: get_Index('%s') no match", name);
`endif
    return 0;
  endfunction

  function automatic int get_NumberOfIndexes(string name, T_AXI4_Register register_vector[]);
    int temp;
    temp = 0;
    for (int i = 0; i < register_vector.size(); i++)
      if (str_ifind_pat(register_vector[i].Name, name))
        temp++;
    return temp;
  endfunction

  function automatic int get_IndexRange(
    string            name,
    T_AXI4_Register   register_vector[],
    int               out_indexes[]
  );
    int pos;
    pos = 0;
    for (int i = 0; i < register_vector.size(); i++)
      if (str_ifind_pat(register_vector[i].Name, name)) begin
        out_indexes[pos] = i;
        pos++;
      end
    return pos;
  endfunction

  function automatic logic [ADDRESS_BITS-1:0] get_Address(
    string            name,
    T_AXI4_Register   register_vector[]
  );
    for (int i = 0; i < register_vector.size(); i++)
      if (str_imatch(register_vector[i].Name, name))
        return register_vector[i].Address;
    if (DEBUG)
      $warning("PoC.axi4lite: get_Address('%s') no match", name);
`ifndef SYNTHESIS
    else
      $fatal(1, "PoC.axi4lite: get_Address('%s') no match", name);
`endif
    return {ADDRESS_BITS{1'b1}};
  endfunction

  function automatic string get_Name(
    logic [ADDRESS_BITS-1:0] address,
    T_AXI4_Register          register_vector[]
  );
    for (int i = 0; i < register_vector.size(); i++)
      if (register_vector[i].Address == address)
        return register_vector[i].Name;
    if (DEBUG)
      $warning("PoC.axi4lite: get_Name no match");
`ifndef SYNTHESIS
    else
      $fatal(1, "PoC.axi4lite: get_Name no match");
`endif
    return resize("", NAME_LENGTH);
  endfunction

  function automatic int get_Interrupt_count(T_AXI4_Register register_vector[]);
    int temp;
    temp = 0;
    for (int i = 0; i < register_vector.size(); i++)
      if (register_vector[i].IsInterruptRegister)
        temp++;
    return temp;
  endfunction

  function automatic void get_Interrupt_range(
    input  T_AXI4_Register register_vector[],
    output int           out_range[]
  );
    int count;
    count = 0;
    out_range = new[get_Interrupt_count(register_vector)];
    for (int i = 0; i < register_vector.size(); i++)
      if (register_vector[i].IsInterruptRegister) begin
        out_range[count] = i;
        count++;
      end
  endfunction

  function automatic int get_Interrupt_range_index(
    input T_AXI4_Register register_vector[],
    input int             irq_slot
  );
    int temp[];
    get_Interrupt_range(register_vector, temp);
    return temp[irq_slot];
  endfunction

  function automatic bit write_csv_file(string file_name, T_AXI4_Register entries[]);
    int fh;
    fh = $fopen(file_name, "w");
    if (fh == 0)
      return 1'b0;
    $fwrite(fh, "Automatically generated File from PoC_sv Library\n");
    $fwrite(fh, "Poc.axi4lite.T_AXI4_Register\n");
    $fwrite(fh, "Config(i) ; Name ; Address ; Init_Value ; AutoClear_Mask ; RegisterMode ; IsInterruptRegister\n");
    for (int i = 0; i < entries.size(); i++)
      $fwrite(fh, "%0d ; %s ; 0x%h ; 0x%h ; 0x%h ; %0d ; %0b\n", i,
              resize(entries[i].Name, NAME_LENGTH), entries[i].Address, entries[i].Init_Value,
              entries[i].AutoClear_Mask, entries[i].RegisterMode, entries[i].IsInterruptRegister);
    $fclose(fh);
    return 1'b1;
  endfunction

  function automatic void read_csv_file(string file_name, T_AXI4_Register entries[]);
    entries = new[0];
    $display("poc_axi4lite.read_csv_file: experimental CSV import not ported; returning empty vector (%s)",
             file_name);
  endfunction

  task automatic Create_AtomicRegister(
    input  logic                  reset,
    input  logic [DATA_BITS-1:0]  register_file_read_port[4],
    ref logic [DATA_BITS-1:0]     register_file_write_port[4],
    input  logic [3:0]            register_file_read_port_hit,
    input  logic [DATA_BITS-1:0]  pl_write_value,
    input  logic                  pl_write_strobe,
    input  logic [DATA_BITS-1:0]  value_reg,
    output logic [DATA_BITS-1:0]  next_value_reg
  );
    logic [DATA_BITS-1:0] new_value;
    register_file_write_port[0] = value_reg;
    register_file_write_port[1] = pl_write_value;
    register_file_write_port[2] = '0;
    register_file_write_port[3] = '0;
    new_value = pl_write_strobe ? pl_write_value : value_reg;
    if (reset == 1'b1)
      new_value = '0;
    else if (register_file_read_port_hit[0] == 1'b1)
      new_value = register_file_read_port[0];
    else if (register_file_read_port_hit[1] == 1'b1)
      new_value = new_value | register_file_read_port[1];
    else if (register_file_read_port_hit[2] == 1'b1)
      new_value = new_value & ~register_file_read_port[2];
    else if (register_file_read_port_hit[3] == 1'b1)
      new_value = new_value ^ register_file_read_port[3];
    next_value_reg = new_value;
  endtask

  task automatic Create_IORegister(
    input  logic                  reset,
    input  logic [DATA_BITS-1:0]  register_file_read_port[8],
    ref logic [DATA_BITS-1:0]     register_file_write_port[8],
    input  logic [7:0]            register_file_read_port_hit,
    input  logic [DATA_BITS-1:0]  input_val,
    output logic [DATA_BITS-1:0]  output_val,
    output logic [DATA_BITS-1:0]  tristate,
    input  logic [DATA_BITS-1:0]  io_reg,
    output logic [DATA_BITS-1:0]  next_io_reg,
    input  logic [DATA_BITS-1:0]  t_reg,
    output logic [DATA_BITS-1:0]  next_t_reg
  );
    logic [DATA_BITS-1:0] rf_read[4];
    logic [DATA_BITS-1:0] rf_write[4];
    logic [3:0]             rf_hit;
    output_val = io_reg;
    for (int i = 0; i < 4; i++) begin
      rf_read[i] = register_file_read_port[i];
      rf_hit[i]  = register_file_read_port_hit[i];
    end
    Create_AtomicRegister(
      reset, rf_read, rf_write, rf_hit, input_val, 1'b1, io_reg, next_io_reg
    );
    for (int i = 0; i < 4; i++)
      register_file_write_port[i] = rf_write[i];
    tristate = t_reg;
    for (int i = 0; i < 4; i++) begin
      rf_read[i] = register_file_read_port[i + 4];
      rf_hit[i]  = register_file_read_port_hit[i + 4];
    end
    Create_AtomicRegister(reset, rf_read, rf_write, rf_hit, '0, 1'b0, t_reg, next_t_reg);
    for (int i = 0; i < 4; i++)
      register_file_write_port[i + 4] = rf_write[i];
  endtask

  function automatic void atomic_register_description_vector(T_AXI4_Register v[]);
    v    = new[4];
    v[0] = to_AXI4_Register("ATOMIC_Value", 32'h0, ReadWrite_NotRegistered);
    v[1] = to_AXI4_Register("ATOMIC_BitTgl", 32'h4, ReadWrite_NotRegistered);
    v[2] = to_AXI4_Register("ATOMIC_BitSet", 32'h8, ReadWrite_NotRegistered);
    v[3] = to_AXI4_Register("ATOMIC_BitClr", 32'hC, ReadWrite_NotRegistered);
  endfunction

  function automatic void io_register_description_vector(T_AXI4_Register merged[]);
    T_AXI4_Register atomic[];
    T_AXI4_Register io[];
    T_AXI4_Register t[];
    atomic_register_description_vector(atomic);
    add_Prefix("IO.", atomic, '0, io);
    add_Prefix("T.", atomic, 32'(atomic.size() * 4), t);
    merged = new[io.size() + t.size()];
    for (int i = 0; i < io.size(); i++)
      merged[i] = io[i];
    for (int i = 0; i < t.size(); i++)
      merged[io.size() + i] = t[i];
  endfunction

  function automatic void Atomic_RegisterDescription_Vector(T_AXI4_Register v[]);
    atomic_register_description_vector(v);
  endfunction

  function automatic void IO_RegisterDescription_Vector(T_AXI4_Register v[]);
    io_register_description_vector(v);
  endfunction

  typedef axi4lite_types#(ADDRESS_BITS, DATA_BITS)::bus_m2s_t T_AXI4Lite_Bus_M2S;
  typedef axi4lite_types#(ADDRESS_BITS, DATA_BITS)::bus_s2m_t T_AXI4Lite_Bus_S2M;
  typedef axi4lite_types#(ADDRESS_BITS, DATA_BITS)::bus_t     T_axi4lite_Bus_Alias;

  function automatic T_AXI4Lite_Bus_M2S initialize_axi4lite_bus_m2s(input logic value = 1'b0);
    return axi4lite_sized#(ADDRESS_BITS, DATA_BITS)::initialize_bus_m2s(value);
  endfunction

  function automatic T_AXI4Lite_Bus_S2M initialize_axi4lite_bus_s2m(input logic value = 1'b0);
    return axi4lite_sized#(ADDRESS_BITS, DATA_BITS)::initialize_bus_s2m(value);
  endfunction

endpackage
