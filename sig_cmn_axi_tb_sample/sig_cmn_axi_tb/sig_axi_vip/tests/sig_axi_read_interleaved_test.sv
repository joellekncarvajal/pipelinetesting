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
import sig_axi_pkg::*;
import sys::*;

class sig_axi_read_interleaved_test extends sig_test_base;
   `uvm_component_utils(sig_axi_read_interleaved_test)

   typedef sys::axi_port_32x32x4::axi_data_item_t axi_data_item_type;
   typedef sys::axi_port_32x32x4::axi_resp_item_t axi_resp_item_type;

   function new(string name="", uvm_component parent);
      super.new(name, parent);
   endfunction // new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      $display("_DBG test build phase done");
   endfunction // build_phase

   task run_phase(uvm_phase phase);

      axi_data_item_type read_resp;
      axi_resp_item_type write_resp;
      
      sig_axi_req_vseq#(sys::axi_port_32x32x4) axi_req;
      sig_axi_resps_vseq#(sys::axi_port_32x32x4) axi_resp;
      
      phase.raise_objection(this);
      $display("%0t:  TEST DBG", $time);

      //Modify model config to set response delay minimum and maximum values
      sys_cfg.slv_prt_cfg[0].wr_resp_min_delay=5;
      sys_cfg.slv_prt_cfg[0].wr_resp_max_delay=5;
      sys_cfg.slv_prt_cfg[0].rd_resp_min_delay=10;
      sys_cfg.slv_prt_cfg[0].rd_resp_max_delay=20;

      //Reactive response sequence
      axi_resp = sig_axi_resps_vseq#(sys::axi_port_32x32x4)::type_id::create("axi_resp", this);
      axi_resp.enable_interleaved = 1;

      fork
        axi_resp.slv_model = axi_env.slv_agents[0].slv_model;
        axi_resp.start(axi_env.vsqrs[0]);
      join_none

      //Issue back-to-back wr-rd transactions 16 times;
      for (int i=0; i<16; i++) begin
         axi_req = sig_axi_req_vseq#(sys::axi_port_32x32x4)::type_id::create("axi_req", this);
         axi_req.randomize() with {
            direction == WRITE;
            addr == 32'h1234_0000 + 32'h1000 * i + i;
            len == 15-i;
            id == i;
            size == $clog2(sys::axi_port_32x32x4::AXI_DATA_WIDTH/8);
            burst == INCR;
            addr_delay == 0;
         };
         $display("direction = %0s, addr=0x%0x, data.size()=%0d", axi_req.direction.name(), axi_req.addr, axi_req.data.size());
         axi_req.wait_done = 1;
         axi_req.start(axi_env.vsqrs[0]);
   
         axi_req.direction = READ;
         axi_req.addr_delay = 0;
         axi_req.start(axi_env.vsqrs[0]); 
      end

      wait (axi_env.vsqrs[0].is_busy() == 0);
      repeat(10)@(axi_env.slv_agents[0].awaddr_vif.mon_cb);

      phase.drop_objection(this);

   endtask // run_phase
   
endclass // sig_axi_read_interleaved_test
