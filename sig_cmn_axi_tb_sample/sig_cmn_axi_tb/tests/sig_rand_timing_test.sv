import axi_pkg::*;
import sys::*;

class sig_rand_timing_test extends sig_base_test;
   `uvm_component_utils(sig_rand_timing_test)

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
      int num_txns = 5;
      logic[7:0] tmp_q [$];
      
      sig_axi_req_vseq#(sys::axi_port_ip) axi_req;
      sig_axi_resps_vseq#(sys::axi_port_ep) axi_resp;
      
      numMasters = sys_cfg.num_mstrs;
      numSlaves = sys_cfg.num_slvs;

      phase.raise_objection(this);
      $display("%0t:  TEST DBG", $time);

      axi_resp = sig_axi_resps_vseq#(sys::axi_port_ep)::type_id::create("axi_resp", this);
      axi_resp.slv_model = axi_env.slv_agents.slv_model;
      fork
         axi_resp.start(axi_env.slv_vsqrs);
      join_none

      axi_req = sig_axi_req_vseq#(sys::axi_port_ip)::type_id::create("axi_req", this);
      axi_req.version = AXI4;
      axi_req.randomize() with {
         direction == WRITE;
         addr == 32'had9b;
         len == 3;
         size == 4;
         burst == INCR;
         addr_delay == 0;
      };
      $display("direction = %0s, addr=0x%0x, data.size()=%0d", axi_req.direction.name(), axi_req.addr, axi_req.data.size());
      axi_req.wait_done = 1;
      axi_req.start(axi_env.mst_vsqrs);

      axi_req.direction = READ;
      axi_req.addr_delay = 10;
      axi_req.start(axi_env.mst_vsqrs); 

      repeat(50)@(axi_env.slv_agents.awaddr_vif.mon_cb);

      //loop num_txns
      for(int i=0; i<num_txns; i++) begin
         axi_req = sig_axi_req_vseq#(sys::axi_port_ip)::type_id::create("axi_req", this);
         axi_req.version = AXI4;
         axi_req.randomize() with {
            id[3:0] == i;
            id[7:4] == 4'ha;
            direction == WRITE;
            burst == INCR;
            size == 5;
            len == 0;
            addr_delay == 0;
         };
         $display("direction = %0s, addr=0x%0x, data.size()=%0d", axi_req.direction.name(), axi_req.addr, axi_req.data.size());
         axi_req.wait_done = 1;
         axi_req.start(axi_env.mst_vsqrs);

         axi_req.direction = READ;
         axi_req.start(axi_env.mst_vsqrs);
      end

      repeat(50)@(axi_env.slv_agents.awaddr_vif.mon_cb);

      //loop num_txns
      for(int i=0; i<num_txns; i++) begin
         axi_req = sig_axi_req_vseq#(sys::axi_port_ip)::type_id::create("axi_req", this);
         axi_req.version = AXI4;
         axi_req.randomize() with {
            id[3:0] == i;
            id[7:4] == 4'hb;
            direction == WRITE;
            burst == INCR;
            size == i%4;
            len == 0;
            addr_delay == 0;
         };
         $display("direction = %0s, addr=0x%0x, data.size()=%0d", axi_req.direction.name(), axi_req.addr, axi_req.data.size());
         axi_req.wait_done = 1;
         axi_req.start(axi_env.mst_vsqrs);

         axi_req.direction = READ;
         axi_req.start(axi_env.mst_vsqrs);
      end

            repeat(50)@(axi_env.slv_agents.awaddr_vif.mon_cb);

      //loop num_txns
      for(int i=0; i<100; i++) begin
         axi_req = sig_axi_req_vseq#(sys::axi_port_ip)::type_id::create("axi_req", this);
         axi_req.version = AXI4;
         axi_req.randomize() with {
            direction == WRITE;
            burst == INCR;
            len == 0;
            addr_delay == 0;
         };
         $display("direction = %0s, addr=0x%0x, data.size()=%0d", axi_req.direction.name(), axi_req.addr, axi_req.data.size());
         axi_req.wait_done = 1;
         axi_req.start(axi_env.mst_vsqrs);

         axi_req.direction = READ;
         axi_req.start(axi_env.mst_vsqrs);
      end

      $display("%0t:  TEST DBG WAIT", $time);
      wait (axi_env.mst_vsqrs.is_busy() == 0);
      repeat(1000)@(axi_env.slv_agents.awaddr_vif.mon_cb);
      //axi_env.slv_mem.readMem(32'h55500555, 24, tmp_q);
      phase.drop_objection(this);

   endtask // run_phase
   
endclass // sig_rand_timing_test
