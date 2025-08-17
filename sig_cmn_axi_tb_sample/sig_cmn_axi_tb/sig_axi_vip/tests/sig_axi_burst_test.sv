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

class sig_axi_burst_test extends sig_test_base;
   `uvm_component_utils(sig_axi_burst_test)

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

      //Tests AxLEN, AxSIZE, AxBURST=INCR
      for (int i=0; i<16; i++) begin
         axi_req = sig_axi_req_vseq#(sys::axi_port_32x32x4)::type_id::create("axi_req", this);
         axi_req.randomize() with {
            direction == WRITE;
            addr == 32'h1234;
            len == i;
            id == i;
            size == i % ($clog2(sys::axi_port_32x32x4::AXI_DATA_WIDTH/8));
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
   
      //TESTS 16<=AxLEN<=128
      for (int i=0; i<8; i++) begin
         axi_req = sig_axi_req_vseq#(sys::axi_port_32x32x4)::type_id::create("axi_req", this);
         axi_req.version = AXI4;
         axi_req.randomize() with {
            direction == WRITE;
            addr == 32'h1000_0000 + 32'h1000*i + i;
            len == i*16+15;
            id == i;
            size == i % ($clog2(sys::axi_port_32x32x4::AXI_DATA_WIDTH/8)+1);
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
   
      for (int i=0; i<20; i++) begin
         axi_req = sig_axi_req_vseq#(sys::axi_port_32x32x4)::type_id::create("axi_req", this);
         axi_req.randomize() with {
            direction == WRITE;
            addr == 32'h2000_0000 + 32'h1000*i + (1<<axi_req.size);
            len == (i<16) ? i : (i-15)*16;
            id == i%16;
            size == i % ($clog2(sys::axi_port_32x32x4::AXI_DATA_WIDTH/8)+1);
            burst == FIXED;
            addr_delay == 0;
         };
         $display("direction = %0s, addr=0x%0x, data.size()=%0d", axi_req.direction.name(), axi_req.addr, axi_req.data.size());
         axi_req.wait_done = 1;
         axi_req.start(axi_env.vsqrs[0]);
   
         axi_req.direction = READ;
         axi_req.addr_delay = 0;
         axi_req.start(axi_env.vsqrs[0]);
      end
   
      for (int i=0; i<16; i++) begin
         axi_req = sig_axi_req_vseq#(sys::axi_port_32x32x4)::type_id::create("axi_req", this);
         axi_req.randomize() with {
            direction == WRITE;
            //addr == 32'h1234;
            addr == 32'hF000_0000 + 32'h1000*i + (1<< size);
            id == i;
            size == i % ($clog2(sys::axi_port_32x32x4::AXI_DATA_WIDTH/8)+1);
            burst == WRAP;
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
   
endclass // sig_axi_burst_test
