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

class sig_axi_mst_timing_test extends sig_test_base;
   `uvm_component_utils(sig_axi_mst_timing_test)

   function new(string name="", uvm_component parent);
      super.new(name, parent);
   endfunction // new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      $display("_DBG test build phase done");
   endfunction // build_phase

   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      //====================================================================
      //Modify config to set ready signal delay minimum and maximum values
      //====================================================================
      sys_cfg.mstr_prt_cfg[0].min_bready_delay=1;    //wr resp ch ready
      sys_cfg.mstr_prt_cfg[0].max_bready_delay=25;
      sys_cfg.mstr_prt_cfg[0].bready_high_cycles=2;  //Number of clock cycles is ready before negating

      sys_cfg.mstr_prt_cfg[0].min_xready_delay=1;     //rd data ch  ready
      sys_cfg.mstr_prt_cfg[0].max_xready_delay=10;
      sys_cfg.mstr_prt_cfg[0].xready_high_cycles=1;   //Number of clock cycles is ready before negating
   endfunction

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

      // No Delay for both addr and data (default behavior)
      axi_req = sig_axi_req_vseq#(sys::axi_port_32x32x4)::type_id::create("axi_req", this);
      axi_req.randomize() with {
         direction == WRITE;
         addr == 32'h1234_5678;
         len == 7;
         burst == INCR;
         addr_delay == 0;
      };
      $display("direction = %0s, addr=0x%0x, data.size()=%0d", axi_req.direction.name(), axi_req.addr, axi_req.data.size());
      axi_req.wait_done = 0;
      axi_req.start(axi_env.vsqrs[0]);

      axi_req = sig_axi_req_vseq#(sys::axi_port_32x32x4)::type_id::create("axi_req", this);
      axi_req.randomize() with {
         direction == WRITE;
         addr == 32'ha1a1_a1a1;
         len == 0;
         burst == INCR;
         addr_delay == 0;
      };
      $display("direction = %0s, addr=0x%0x, data.size()=%0d", axi_req.direction.name(), axi_req.addr, axi_req.data.size());
      axi_req.wait_done = 0;
      axi_req.start(axi_env.vsqrs[0]);

      // Fixed delay in address channel; no delay in data channel (default behavior)
      axi_req = sig_axi_req_vseq#(sys::axi_port_32x32x4)::type_id::create("axi_req", this);
      axi_req.no_delay_c.constraint_mode(0); //disable delay constraint to allow randomization
      axi_req.randomize() with {
         direction == WRITE;
         addr == 32'hB2B2_2222;
         len == 4;
         burst == INCR;
         addr_delay == 10; //Fix addr delay to 10 cycles
         foreach (data_delay[i]) {data_delay[i] == 0;} //Fix data delay to zero
      };
      $display("direction = %0s, addr=0x%0x, data.size()=%0d", axi_req.direction.name(), axi_req.addr, axi_req.data.size());
      axi_req.wait_done = 0;
      axi_req.start(axi_env.vsqrs[0]);

      // Random delay in address channel; random delay in data channel
      axi_req = sig_axi_req_vseq#(sys::axi_port_32x32x4)::type_id::create("axi_req", this);
      axi_req.no_delay_c.constraint_mode(0); //disable data delay constraint to allow randomization
      axi_req.randomize() with {
         direction == WRITE;
         addr == 32'h3c3c_3c3c;
         len == 15;
         burst == INCR;
         addr_delay < 20 && addr_delay > 10; //Removed constraint for addr_delay to randomize it
         foreach (data_delay[i]) {data_delay[i] < 10; } //Constrain data_Delay to be less than 10 cycles
      };
      $display("direction = %0s, addr=0x%0x, data.size()=%0d", axi_req.direction.name(), axi_req.addr, axi_req.data.size());
      axi_req.wait_done = 1; //set wait done to 1 to block next sequence; this makes sure all writes are done before starting read sequence
      axi_req.start(axi_env.vsqrs[0]);


      axi_req.direction = READ;
      axi_req.addr_delay = 10;
      axi_req.start(axi_env.vsqrs[0]); 

      $display("%0t:  TEST DBG WAIT", $time);
      wait (axi_env.vsqrs[0].is_busy() == 0);
      repeat(10)@(axi_env.slv_agents[0].awaddr_vif.mon_cb);
      phase.drop_objection(this);

   endtask // run_phase
   
endclass // sig_axi_mst_timing_test
