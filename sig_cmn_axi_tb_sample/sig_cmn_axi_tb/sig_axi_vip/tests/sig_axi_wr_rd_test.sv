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

class sig_axi_wr_rd_test extends sig_test_base;
   `uvm_component_utils(sig_axi_wr_rd_test)

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
      logic[7:0] tmp_q [$];
      
      sig_axi_req_vseq#(sys::axi_port_32x32x4) axi_req;
      sig_axi_resps_vseq#(sys::axi_port_32x32x4) axi_resp;
      
      numMasters = sys_cfg.num_mstrs;
      numSlaves = sys_cfg.num_slvs;

      phase.raise_objection(this);
      $display("%0t:  TEST DBG", $time);

      axi_resp = sig_axi_resps_vseq#(sys::axi_port_32x32x4)::type_id::create("axi_resp", this);
      fork
        axi_resp.slv_model = axi_env.slv_agents[0].slv_model;
        axi_resp.start(axi_env.vsqrs[0]);
      join_none

      axi_req = sig_axi_req_vseq#(sys::axi_port_32x32x4)::type_id::create("axi_req", this);
      axi_req.randomize() with {
         direction == WRITE;
         addr == 32'h1234;
         len == 7;
         size == 0;
         burst == INCR;
         addr_delay == 0;
      };
      $display("direction = %0s, addr=0x%0x, data.size()=%0d", axi_req.direction.name(), axi_req.addr, axi_req.data.size());
      axi_req.wait_done = 0;
      axi_req.start(axi_env.vsqrs[0]);

      axi_req.direction = READ;
      axi_req.addr_delay = 10;
      axi_req.start(axi_env.vsqrs[0]); 

      axi_req = sig_axi_req_vseq#(sys::axi_port_32x32x4)::type_id::create("axi_req", this);
      axi_req.randomize() with {
         direction == WRITE;
         addr == 32'h98765;
         len == 8;
         size == 1;
         burst == INCR;
         addr_delay == 0;
      };
      $display("direction = %0s, addr=0x%0x, data.size()=%0d", axi_req.direction.name(), axi_req.addr, axi_req.data.size());
      axi_req.wait_done = 0;
      axi_req.start(axi_env.vsqrs[0]);

      axi_req.direction = READ;
      axi_req.addr_delay = 10;
      axi_req.start(axi_env.vsqrs[0]);

      axi_req = sig_axi_req_vseq#(sys::axi_port_32x32x4)::type_id::create("axi_req", this);
      axi_req.randomize() with {
         direction == WRITE;
         addr == 32'h888B;
         id == 2;
         len == 15;
         size == 2;
         burst == INCR;
         addr_delay == 0;
      };
      $display("direction = %0s, addr=0x%0x, data.size()=%0d", axi_req.direction.name(), axi_req.addr, axi_req.data.size());
      axi_req.wait_done = 0;
      axi_req.start(axi_env.vsqrs[0]);

      axi_req.direction = READ;
      axi_req.addr_delay = 20;
      axi_req.start(axi_env.vsqrs[0]);

      axi_req = sig_axi_req_vseq#(sys::axi_port_32x32x4)::type_id::create("axi_req", this);
      axi_req.randomize() with {
         direction == WRITE;
         addr == 32'hC3C3C3C3;
         id == 3;
         len == 0;
         burst == INCR;
         addr_delay == 20;
      };
      $display("direction = %0s, addr=0x%0x, data.size()=%0d", axi_req.direction.name(), axi_req.addr, axi_req.data.size());
      axi_req.wait_done = 0;
      axi_req.start(axi_env.vsqrs[0]);

      axi_req = sig_axi_req_vseq#(sys::axi_port_32x32x4)::type_id::create("axi_req", this);
      axi_req.randomize() with {
         direction == WRITE;
         addr == 32'h4d4d4d4d;
         id == 3;
         len == 5;
         burst == INCR;
         addr_delay == 5;
      };
      $display("direction = %0s, addr=0x%0x, data.size()=%0d", axi_req.direction.name(), axi_req.addr, axi_req.data.size());
      axi_req.wait_done = 1;
      axi_req.start(axi_env.vsqrs[0]);

      axi_req.direction = READ;
      axi_req.start(axi_env.vsqrs[0]);

      axi_req = sig_axi_req_vseq#(sys::axi_port_32x32x4)::type_id::create("axi_req", this);
      axi_req.randomize() with {
         direction == WRITE;
         addr == 32'h55500555;
         id == 3;
         len == 5;
         burst == INCR;
         addr_delay == 0;
      };
      $display("direction = %0s, addr=0x%0x, data.size()=%0d", axi_req.direction.name(), axi_req.addr, axi_req.data.size());
      axi_req.wait_done = 1;
      axi_req.start(axi_env.vsqrs[0]);

      axi_req.direction = READ;
      axi_req.start(axi_env.vsqrs[0]);

      $display("%0t:  TEST DBG WAIT", $time);
      wait (axi_env.vsqrs[0].is_busy() == 0);
      repeat(10)@(axi_env.slv_agents[0].awaddr_vif.mon_cb);
      axi_env.mem.readMem(32'h55500555, 24, tmp_q);
      phase.drop_objection(this);

   endtask // run_phase
   
endclass // sig_axi_wr_rd_test
