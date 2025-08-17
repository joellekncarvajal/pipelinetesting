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
class axi_port_cfg extends uvm_object;
   `uvm_object_utils(axi_port_cfg)

   int min_axready_delay =0, max_axready_delay =0;
   int min_xready_delay  =0, max_xready_delay  =0;
   int min_bready_delay  =0, max_bready_delay  =0;
   int axready_high_cycles =0;
   int xready_high_cycles  =0;
   int bready_high_cycles  =0;

   int wr_resp_min_delay=0, wr_resp_max_delay=0;
   int rd_resp_min_delay=0, rd_resp_max_delay=0; 

   bit mst_has_monitor = 0;
   bit enable_coverage = 0;
   bit enable_rddata_compare = 1;
   uvm_active_passive_enum is_active = UVM_ACTIVE;
   AxiVer version = AXI3;
   bit en_early_addr_sampling = 0;
   bit en_zero_rdata_on_error = 0;
   bit en_axlock_masking = 0;
   bit disable_rd_compare_on_error = 0;
   bit en_rand_while_not_valid = 0;

   bit fifo_en = 0;
   bit [1023:0] fifo_base = '0;
   bit [1023:0] fifo_limit= '1;

   typedef struct {
      bit [255:0] base;
      bit [255:0] limit;
      bit is_readable = 1;
      bit is_writable = 1;
   } axi_addr_pair;

   axi_addr_pair valid_ranges[$];
   axi_addr_pair outside_ranges[$];
   axi_addr_pair secure_ranges[$];

   bit en_address_range_check = 0;
   bit en_secure_range_check = 0;

   bit en_verbose_bw_tracker = 0;
   int verbose_bw_tracker_interval = 100;

   //These enable the outstanding buffers in the slave agent
   bit en_slv_buffers = 0;
   int slv_waddr_buffer_depth = 8;
   int slv_wdata_buffer_depth = 256;
   int slv_raddr_buffer_depth = 8;

   int initial_ready_delay_cycles = 0;
   bit force_awready_low = 0;
   bit force_arready_low = 0;

   bit enable_req_rsp_check = 1;
   bit enable_exclusive_rd_wr_check = 0;

   bit unresponsive_slv_awready = 0; //for slave
   bit unresponsive_slv_arready = 0; //for slave
   bit unresponsive_slv_wready  = 0;  //for slave
   bit unresponsive_mst_bready  = 0;  //for master
   bit unresponsive_mst_rready  = 0;  //for master

   bit rdata_ch_is_unresponsive = 0;
   bit wdata_ch_is_unresponsive = 0;
   bit bresp_ch_is_unresponsive = 0;

   bit pause_bresp_ch = 0;
   bit pause_rdata_ch = 0;

   bit def_mem_data_after_error = 0;

   function new(string name="");
      super.new(name);
   endfunction // new

   function void setDefaults(int awidth, int dwidth, int iwidth);
   endfunction // setDefaults

   function void push_valid_range(bit [255:0] base_in, bit [255:0] limit_in, bit is_read = 1, bit is_write = 1);
      axi_addr_pair vld_range;
      vld_range.base  = base_in;
      vld_range.limit = limit_in;
      vld_range.is_readable = is_read; 
      vld_range.is_writable = is_write;
      valid_ranges.push_back(vld_range);
   endfunction

   function void push_secure_range(bit [255:0] base_in, bit [255:0] limit_in);
      axi_addr_pair sec_range;
      sec_range.base  = base_in;
      sec_range.limit = limit_in;
      secure_ranges.push_back(sec_range);
   endfunction

   function void pop_secure_range(bit [255:0] base_in, bit [255:0] limit_in);
      int index[$];
      index = secure_ranges.find_first_index(sample) with (sample.base == base_in && sample.limit == limit_in);
      //`uvm_fatal("False Flag", $sformatf("Removed secure_ranges entry index %0d [%0x:%0x]", index[0], base_in, limit_in))
      secure_ranges.delete(index[0]);
   endfunction
   
endclass // axi_cfg

class axi_sys_cfg extends uvm_object;
   `uvm_object_utils(axi_sys_cfg)

   int num_mstrs;
   int num_slvs;

   axi_port_cfg mstr_prt_cfg[];
   axi_port_cfg slv_prt_cfg[];

   function new(string name="");
      super.new(name);
   endfunction // new

   function void setDefaultPortCfg(int nmstr, int nslv, int aw=32, int dw=32, int iw=4);
      num_mstrs = nmstr;
      num_slvs = nslv;
      mstr_prt_cfg = new[nmstr];
      slv_prt_cfg = new[nslv];
      foreach (mstr_prt_cfg[i]) begin
	 mstr_prt_cfg[i] = new($sformatf("mstr_prt_cfg_%0d", i));
      end
      foreach (slv_prt_cfg[i]) begin
	 slv_prt_cfg[i] = new($sformatf("slv_prt_cfg_%0d", i));
      end
   endfunction // setDefaultPortCfg
   
endclass // axi_cfg

