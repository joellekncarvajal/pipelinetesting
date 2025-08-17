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

class sig_axi_error_response_test extends sig_test_base;
   `uvm_component_utils(sig_axi_error_response_test)

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

      int numMasters;
      int numSlaves;

      axi_data_item_type read_resp;
      axi_resp_item_type write_resp;
      
      sig_axi_req_vseq#(sys::axi_port_32x32x4) axi_req;
      sig_axi_resps_vseq#(sys::axi_port_32x32x4) axi_resp;
      
      numMasters = sys_cfg.num_mstrs;
      numSlaves = sys_cfg.num_slvs;

      phase.raise_objection(this);
      $display("%0t:  TEST DBG", $time);

      //Reactive response sequence:
      //To control the response from reactive sequence, user needs to fill 
      //user_bresp_q and user_rresp_q queues for write and read responses respectively.
      //These queues are popped every time the reactive sequence detects it needs to send a response.
      //If these queues are empty, the sequence sends default response.

      axi_resp = sig_axi_resps_vseq#(sys::axi_port_32x32x4)::type_id::create("axi_resp", this);

      //Ex #1: User wants bresp for 1st transaction to be DECERR
      write_resp = axi_resp_item_type::type_id::create("write_resp", this);
      write_resp.randomize () with {
         resp == DECERR;
         user == 'hf;
         delay == 0;
      };
      axi_resp.user_bresp_q.push_back(write_resp);

      //Ex #2: User wants to delay response by 20 cycles
      write_resp = axi_resp_item_type::type_id::create("write_resp", this);
      write_resp.randomize () with {
         resp == OKAY;
         user == 'h7;
         delay == 20;
      };
      axi_resp.user_bresp_q.push_back(write_resp);

      //Ex #3. User wants to change/corrupt the read data
      read_resp = axi_data_item_type::type_id::create("read_resp", this);
      read_resp.randomize () with {
         data.size() == 1;
         foreach (data[i]) { data[i] == 'hffff;}
      };
      axi_resp.user_rresp_q.push_back(read_resp);

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
            len == i;
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
   
endclass // sig_axi_error_response_test
