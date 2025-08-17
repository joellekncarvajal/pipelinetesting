/*
   ######################################################################################
 *      Signature IP Corporation Confidential and Proprietary Information               #
 *      Copyright 2022 Signature IP Corporation                                         #
 *      All Rights Reserved.                                                            #
 *      This is UNPUBLISHED PROPRIETARY SOURCE CODE OF Signature IP Corporation         #
 *      The copyright notice above does not evidence any actual or intended publication #
 *      of such source code.                                                            #
 * ######################################################################################

*/
`ifndef axi_item_seq__sv
 `include "axi_hdr.svh"

class axi_base_item  extends uvm_sequence_item;

   OpType			  rwType;
   bit is_done = 0;
   rand AxGPIO                         gpio;   
   
   `uvm_object_param_utils_begin(axi_base_item)
      `uvm_field_enum(OpType, rwType, UVM_DEFAULT)
      `uvm_field_int(gpio.pressure, UVM_DEFAULT)
      `uvm_field_int(gpio.hurry, UVM_DEFAULT)
   `uvm_object_utils_end

   function new(string name="");
      super.new(name);
   endfunction // new
   
endclass // axi_base

class axi_item # (
  int AXI_ID_WIDTH     = `AXI_ID_WIDTH,
  int AXI_ADDR_WIDTH   = `AXI_ADDR_WIDTH,
  int AXI_LEN_WIDTH    = `AXI_LEN_WIDTH,
  int AXI_SIZE_WIDTH   = `AXI_SIZE_WIDTH,
  int AXI_BURST_WIDTH  = `AXI_BURST_WIDTH,
  int AXI_LOCK_WIDTH   = `AXI_LOCK_WIDTH,
  int AXI_CACHE_WIDTH  = `AXI_CACHE_WIDTH,
  int AXI_PROT_WIDTH   = `AXI_PROT_WIDTH,
  int AXI_QOS_WIDTH    = `AXI_QOS_WIDTH,
  int AXI_REGION_WIDTH = `AXI_REGION_WIDTH,
  int AXI_USER_WIDTH   = `AXI_USER_WIDTH,
  int AXI_DATA_WIDTH   = `AXI_DATA_WIDTH,
  int AXI_STRB_WIDTH   = `AXI_STRB_WIDTH,
  int AXI_RESP_WIDTH   = `AXI_RESP_WIDTH
) extends axi_base_item;

  `protect //begin protected region
  typedef axi_item #(
    AXI_ID_WIDTH,
    AXI_ADDR_WIDTH,
    AXI_LEN_WIDTH,
    AXI_SIZE_WIDTH,
    AXI_BURST_WIDTH,
    AXI_LOCK_WIDTH,
    AXI_CACHE_WIDTH,
    AXI_PROT_WIDTH,
    AXI_QOS_WIDTH,
    AXI_REGION_WIDTH,
    AXI_USER_WIDTH,
    AXI_DATA_WIDTH,
    AXI_STRB_WIDTH,
    AXI_RESP_WIDTH
  ) this_axi_item_t;

   typedef struct {
      logic [AXI_ADDR_WIDTH-1:0] low;
      logic [AXI_ADDR_WIDTH-1:0] high;
   } addr_range_t;
   `endprotect //end protected region

   rand logic [AXI_ID_WIDTH-1:0]     id;
   rand logic [AXI_ADDR_WIDTH-1:0]   addr;
   rand logic [AXI_LEN_WIDTH-1:0]    len;
   rand logic [AXI_SIZE_WIDTH-1:0]   size;
   rand BurstType                    burst;
   rand LockType                     lock;
   rand logic [AXI_CACHE_WIDTH-1:0]  cache;
   rand logic [AXI_PROT_WIDTH-1:0]   prot;
   rand logic [AXI_QOS_WIDTH-1:0]    qos;
   rand logic [AXI_REGION_WIDTH-1:0] region;
   rand logic [AXI_USER_WIDTH-1:0]   axuser;

   rand logic [AXI_DATA_WIDTH-1:0] data[$];
   rand logic [AXI_STRB_WIDTH-1:0] strb[$];
   rand logic [AXI_USER_WIDTH-1:0] xuser[$];
   rand logic [AXI_USER_WIDTH-1:0] buser;
   rand RespCode rresp[$];
   rand RespCode bresp;

   logic [AXI_ADDR_WIDTH-1:0] wrap_addr0, wrap_addr1;
   logic [AXI_LEN_WIDTH-1:0]  wrap_len0, wrap_len1;
   int wrap_cnt;

   //Flags and switches
   bit is_complete = 0;
   bit is_full_data = 0;
   bit is_first_req = 0;
   logic [AXI_ADDR_WIDTH-1:0] low_addr;
   logic [AXI_ADDR_WIDTH-1:0] high_addr;
   logic [AXI_ADDR_WIDTH-1:0] transfer_addr;
   SampleType sample_type;
   realtime addr_start_time;
   realtime data_start_time;
   realtime data_end_time;
   realtime resp_start_time;
   realtime addr_vld_time;
   realtime data_vld_time;
   realtime resp_vld_time;
   int count;
   int transfer_count; 
   addr_range_t taken_ranges[$];
   integer src_id = 'x;
   int total_bytes;

  `protect //begin protected region
   `uvm_object_param_utils_begin(this_axi_item_t)
      `uvm_field_int(id, UVM_DEFAULT)
      `uvm_field_int(addr, UVM_DEFAULT)
      `uvm_field_int(len, UVM_DEFAULT)
      `uvm_field_int(size, UVM_DEFAULT)
      `uvm_field_enum(BurstType,burst, UVM_DEFAULT)
      `uvm_field_enum(LockType,lock, UVM_DEFAULT)
      `uvm_field_int(cache, UVM_DEFAULT)
      `uvm_field_int(prot, UVM_DEFAULT)
      `uvm_field_int(qos, UVM_DEFAULT)
      `uvm_field_int(region, UVM_DEFAULT)
      `uvm_field_int(axuser, UVM_DEFAULT)
      `uvm_field_queue_int(data, UVM_DEFAULT)
      `uvm_field_queue_int(strb, UVM_DEFAULT)
      `uvm_field_queue_int(xuser, UVM_DEFAULT)
      `uvm_field_int(buser, UVM_DEFAULT)
      `uvm_field_queue_enum(RespCode, rresp, UVM_DEFAULT)
      `uvm_field_enum(RespCode, bresp, UVM_DEFAULT)
      `uvm_field_enum(SampleType, sample_type, UVM_DEFAULT)
      `uvm_field_int(transfer_count, UVM_DEFAULT)
   `uvm_object_utils_end

   function new(string name="axi_item");
      super.new(name);
      taken_ranges.delete();
   endfunction // new

   function void add_taken_range(logic [AXI_ADDR_WIDTH-1:0] low_addr, logic [AXI_ADDR_WIDTH-1:0] high_addr);
      addr_range_t addr_range;
      addr_range.low = low_addr;
      addr_range.high = high_addr;
      taken_ranges.push_back(addr_range);
      //$display("Added Range [0x%0x - 0x%0x", low_addr, high_addr);
   endfunction
    
  function string print_packet(string header = "", AxiVer version, integer src_dev=0, integer dst_dev=0);
    string out = "";
    if(sample_type.name() == "ADDR_ONLY" && rwType.name() == "WRITE") begin
      out = {out, header, " AW Channel:"};
      out = {out, $sformatf("  Protocol:%0s", version.name())};
      out = {out, $sformatf("  Src_Dev:%0d", src_dev)};
      out = {out, $sformatf("  Dst_Dev:%0d", dst_dev)};
      out = {out, $sformatf("  Addr:0x%x", addr)};
      if(version == AXI4 || version == AXI3) begin
        out = {out, $sformatf("  ID:0x%x", id)};
        out = {out, $sformatf("  Len:0x%0x", len)};
        out = {out, $sformatf("  Size:0x%0x", size)};
        out = {out, $sformatf("  QOS:0x%x", qos)};
        out = {out, $sformatf("  Burst:%0s", burst.name())};
        out = {out, $sformatf("  Lock:0x%0x", lock)};
        out = {out, $sformatf("  Cache:0x%0x", cache)};
        out = {out, $sformatf("  Region:0x%0x", region)};
      end
      out = {out, $sformatf("  Prot:0x%x", prot)};
      out = {out, "\n"};
      out = {out, "\n"};
    end else if (sample_type.name() == "FULL_REQ" && rwType.name() == "WRITE") begin
      out = {out, header, " W Channel:"};
      out = {out, $sformatf("  Protocol:%0s", version.name())};
      if(version == AXI3) begin
        out = {out, $sformatf("  ID:0x%x", id)};
      end
      out = {out, $sformatf("  Payload_Size:%0d (transfer_count:%0d, len=0x%0x)", data.size() * (AXI_DATA_WIDTH/8), data.size(),data.size()-1)};
      foreach(data[i]) begin
        out = {out, "\n"};
        out = {out, $sformatf("  Data %3d:<%x> %x", i, strb[i], data[i])};
      end
      out = {out, "\n"};
      out = {out, "\n"};
    end else if ((sample_type.name() == "FULL_TRANS" && rwType.name() == "WRITE") || 
                 (sample_type.name() == "RESP_ONLY" && rwType.name() == "WRITE")
    ) begin
      out = {out, header, " B Channel:"};
      out = {out, $sformatf("  Protocol:%0s", version.name())};
      if(version == AXI4 || version == AXI3) begin
        out = {out, $sformatf("  ID:0x%x", id)};
      end
      out = {out, $sformatf("  Resp:%0s", bresp.name())};
      out = {out, "\n"};
      out = {out, "\n"};
    end else if (sample_type.name() == "FULL_REQ" && rwType.name() == "READ") begin
      out = {out, header, " AR Channel:"};
      out = {out, $sformatf("  Protocol:%0s", version.name())};
      out = {out, $sformatf("  Src_Dev:%0d", src_dev)};
      out = {out, $sformatf("  Dst_Dev:%0d", dst_dev)};
      out = {out, $sformatf("  Addr:0x%x", addr)};
      if(version == AXI4 || version == AXI3) begin
        out = {out, $sformatf("  ID:0x%x", id)};
        out = {out, $sformatf("  Len:0x%0x", len)};
        out = {out, $sformatf("  Size:0x%0x", size)};
        out = {out, $sformatf("  QOS:0x%x", qos)};
        out = {out, $sformatf("  Burst:%0s", burst.name())};
        out = {out, $sformatf("  Lock:0x%0x", lock)};
        out = {out, $sformatf("  Cache:0x%0x", cache)};
        out = {out, $sformatf("  Region:0x%0x", region)};
      end
      out = {out, $sformatf("  Prot:0x%x", prot)};
      out = {out, "\n"};
      out = {out, "\n"};
    end else if ((sample_type.name() == "FULL_TRANS" && rwType.name() == "READ") || 
                 (sample_type.name() == "RESP_ONLY" && rwType.name() == "READ")
    ) begin
      out = {out, header, " R Channel:"};
      out = {out, $sformatf("  Protocol:%0s", version.name())};
      if(version == AXI4 || version == AXI3) begin
        out = {out, $sformatf("  ID:0x%x", id)};
      end
      out = {out, $sformatf("  Payload_Size:%0d (transfer_count:%0d, len=0x%0x)", data.size() * (AXI_DATA_WIDTH/8),data.size(), data.size()-1)};
      out = {out, "\n"};
      foreach(data[i]) begin
        out = {out, $sformatf("  Data %3d:%x", i, data[i])};
        out = {out, $sformatf("  Resp:%0s", rresp[i].name())};
        out = {out, "\n"};
      end
      out = {out, "\n"};
    end

    return out;
  endfunction
  `endprotect //end protected region
endclass //axi_item

class axi_addr_item # (
  int AXI_ID_WIDTH     = `AXI_ID_WIDTH, 
  int AXI_ADDR_WIDTH   = `AXI_ADDR_WIDTH,
  int AXI_LEN_WIDTH    = `AXI_LEN_WIDTH,
  int AXI_SIZE_WIDTH   = `AXI_SIZE_WIDTH,
  int AXI_BURST_WIDTH  = `AXI_BURST_WIDTH,
  int AXI_LOCK_WIDTH   = `AXI_LOCK_WIDTH,
  int AXI_CACHE_WIDTH  = `AXI_CACHE_WIDTH,
  int AXI_PROT_WIDTH   = `AXI_PROT_WIDTH,
  int AXI_QOS_WIDTH    = `AXI_QOS_WIDTH,
  int AXI_REGION_WIDTH = `AXI_REGION_WIDTH,
  int AXI_USER_WIDTH   = `AXI_USER_WIDTH
) extends axi_base_item;

  `protect //begin protected region
  typedef axi_addr_item #(
    AXI_ID_WIDTH, 
    AXI_ADDR_WIDTH, 
    AXI_LEN_WIDTH, 
    AXI_SIZE_WIDTH, 
    AXI_BURST_WIDTH, 
    AXI_LOCK_WIDTH, 
    AXI_CACHE_WIDTH, 
    AXI_PROT_WIDTH, 
    AXI_QOS_WIDTH, 
    AXI_REGION_WIDTH, 
    AXI_USER_WIDTH
  ) this_axi_addr_item_t;
  `endprotect //end protected region
   
  rand logic [AXI_ID_WIDTH-1:0]     id;
  rand logic [AXI_ADDR_WIDTH-1:0]   addr;
  rand logic [AXI_LEN_WIDTH-1:0]    len;
  rand logic [AXI_SIZE_WIDTH-1:0]   size;
  rand BurstType                    burst;
  rand LockType                     lock;
  rand logic [AXI_CACHE_WIDTH-1:0]  cache;
  rand logic [AXI_PROT_WIDTH-1:0]   prot;
  rand logic [AXI_QOS_WIDTH-1:0]    qos;
  rand logic [AXI_REGION_WIDTH-1:0] region;
  rand logic [AXI_USER_WIDTH-1:0]   user;
  rand int unsigned                 delay;

  int                               busSize;
  realtime                          start_time;
  realtime                          vld_time;
  integer                           src_id = 'x;
  int                               total_bytes;

  `protect //begin protected region
  `uvm_object_param_utils_begin(this_axi_addr_item_t)
     `uvm_field_int(busSize, UVM_DEFAULT)
     `uvm_field_int(id, UVM_DEFAULT)
     `uvm_field_int(addr, UVM_DEFAULT)
     `uvm_field_int(len, UVM_DEFAULT)
     `uvm_field_int(size, UVM_DEFAULT)
     `uvm_field_enum(BurstType,burst, UVM_DEFAULT)
     `uvm_field_enum(LockType,lock, UVM_DEFAULT)
     `uvm_field_int(cache, UVM_DEFAULT)
     `uvm_field_int(prot, UVM_DEFAULT)
     `uvm_field_int(qos, UVM_DEFAULT)
     `uvm_field_int(region, UVM_DEFAULT)
     `uvm_field_int(user, UVM_DEFAULT)
     `uvm_field_int(delay, UVM_DEFAULT)
  `uvm_object_utils_end

  function new(string name="axi_req");
     super.new(name);
     busSize = AXI_ADDR_WIDTH;
  endfunction // new
  `endprotect //end protected region      
endclass // axi_addr_item

class axi_data_item # (
  int AXI_ID_WIDTH   = `AXI_ID_WIDTH,
  int AXI_DATA_WIDTH = `AXI_DATA_WIDTH,
  int AXI_STRB_WIDTH = `AXI_STRB_WIDTH,
  int AXI_RESP_WIDTH = `AXI_RESP_WIDTH,
  int AXI_USER_WIDTH = `AXI_USER_WIDTH
) extends axi_base_item;

  `protect //begin protected region
  typedef axi_data_item#(
    AXI_ID_WIDTH,
    AXI_DATA_WIDTH,
    AXI_STRB_WIDTH,
    AXI_RESP_WIDTH,
    AXI_USER_WIDTH
  ) this_axi_data_item_t;
  `endprotect //end protected region

   int 	busSize;
   rand int unsigned data_len;
   rand logic [AXI_ID_WIDTH-1:0] id;
   rand logic [AXI_DATA_WIDTH-1:0] data[$];
   rand logic [AXI_STRB_WIDTH-1:0] strb[$];
   rand logic [AXI_USER_WIDTH-1:0] user[$];
   rand RespCode resp[$];
   rand int idle_btwn_trans;
   rand int unsigned delay[$];

   //Switches and flags
   bit not_last = 0;
   int remaining_transfer = 0;
   realtime                          start_time;
   realtime                          end_time;
   realtime                          vld_time;

  `protect //begin protected region
   `uvm_object_param_utils_begin(this_axi_data_item_t)
      `uvm_field_int(busSize, UVM_DEFAULT)
      `uvm_field_int(data_len, UVM_DEFAULT)
      `uvm_field_int(id, UVM_DEFAULT)
      `uvm_field_queue_int(strb, UVM_DEFAULT)
      `uvm_field_queue_int(data, UVM_DEFAULT)
      `uvm_field_queue_int(user, UVM_DEFAULT)
      `uvm_field_queue_enum(RespCode, resp, UVM_DEFAULT)
      `uvm_field_int(idle_btwn_trans, UVM_DEFAULT)
      `uvm_field_queue_int(delay, UVM_DEFAULT)
   `uvm_object_utils_end

   constraint idle_btwn { idle_btwn_trans == 0; }
   function new(string name="axi_data_item");
      super.new(name);
      busSize = AXI_DATA_WIDTH;
   endfunction // new
  `endprotect //end protected region      
endclass // axi_data

class axi_resp_item #(
  int AXI_ID_WIDTH = `AXI_ID_WIDTH,
  int AXI_RESP_WIDTH = `AXI_RESP_WIDTH,
  int AXI_USER_WIDTH = `AXI_USER_WIDTH
) extends axi_base_item;

  `protect //begin protected region
  typedef axi_resp_item#(AXI_ID_WIDTH, AXI_RESP_WIDTH, AXI_USER_WIDTH) this_axi_resp_item_t;
  `endprotect //end protected region

   rand logic[AXI_ID_WIDTH-1:0] id;
   rand logic [AXI_USER_WIDTH-1:0] user;
   rand RespCode resp;
   rand int unsigned delay;
   realtime                          start_time;
   realtime                          vld_time;

  `protect //begin protected region
   `uvm_object_param_utils_begin(this_axi_resp_item_t)
      `uvm_field_int(id, UVM_DEFAULT)
      `uvm_field_enum(RespCode, resp, UVM_DEFAULT)
      `uvm_field_int(user, UVM_DEFAULT)
      `uvm_field_int(delay, UVM_DEFAULT)
   `uvm_object_utils_end

   function new(string name="axi_resp_item");
      super.new(name);
   endfunction // new
  `endprotect //end protected region
      
endclass // axi_resp

`endif
