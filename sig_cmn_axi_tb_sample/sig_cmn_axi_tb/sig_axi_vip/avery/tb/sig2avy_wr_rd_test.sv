class sig2avy_wr_rd_test extends my_axi_base_test;
   `uvm_component_utils(sig2avy_wr_rd_test)

   function new(string name="", uvm_component parent);
      super.new(name, parent);
   endfunction // new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      $display("BENI_DBG test build phase done");
   endfunction // build_phase

   task run_phase(uvm_phase phase);

      int numMasters;
      int numSlaves;
      logic[7:0] tmp_q [$];
      
      sig_axi_req_vseq#(sys::axi_port_32x32x4) axi_req;
      sig_axi_resps_vseq#(sys::axi_port_32x32x4) axi_resp;
      
      numMasters = sys_cfg.num_mstrs;
      numSlaves = sys_cfg.num_slvs;

//      axi_req = new[numMasters];
      
      phase.raise_objection(this);
      $display("%0t: BENI TEST DBG", $time);

//      axi_resp = sig_axi_resps_vseq#(sys::axi_port_32x32x4)::type_id::create("axi_resp", this);
//      fork
//        axi_resp.slv_model = axi_env.slv_agents[0].slv_model;
//        axi_resp.start(axi_env.vsqrs[0]);
//      join_none

      axi_req = sig_axi_req_vseq#(sys::axi_port_32x32x4)::type_id::create("axi_req", this);
      axi_req.randomize() with {
         direction == WRITE;
         addr == 32'h4000_1234;
         id == 0;
         alock == 0;  
         len == 7;
         size == 0;
         burst == INCR;
         addr_delay == 0;
      };
      $display("direction = %0s, addr=0x%0x, data.size()=%0d", axi_req.direction.name(), axi_req.addr, axi_req.data.size());
      axi_req.wait_done = 1;
      axi_req.start(axi_env.vsqrs[0]);

      axi_req.direction = READ;
      axi_req.addr_delay = 10;
      axi_req.start(axi_env.vsqrs[0]); 

      axi_req = sig_axi_req_vseq#(sys::axi_port_32x32x4)::type_id::create("axi_req", this);
      axi_req.randomize() with {
         direction == WRITE;
         addr == 32'h320098765;
         id == 1;
         alock == 0;  
         len == 8;
         size == 1;
         burst == INCR;
         addr_delay == 0;
      };
      $display("direction = %0s, addr=0x%0x, data.size()=%0d", axi_req.direction.name(), axi_req.addr, axi_req.data.size());
      axi_req.wait_done = 1;
      axi_req.start(axi_env.vsqrs[0]);

      axi_req.direction = READ;
      axi_req.addr_delay = 10;
      axi_req.start(axi_env.vsqrs[0]);

      axi_req = sig_axi_req_vseq#(sys::axi_port_32x32x4)::type_id::create("axi_req", this);
      axi_req.randomize() with {
         direction == WRITE;
         addr == 32'h2222888B;
         id == 2;
         len == 15;
         alock == 0;  
         size == 2;
         burst == INCR;
         addr_delay == 0;
      };
      $display("direction = %0s, addr=0x%0x, data.size()=%0d", axi_req.direction.name(), axi_req.addr, axi_req.data.size());
      axi_req.wait_done = 1;
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
         alock == 0;  
         burst == INCR;
         addr_delay == 20;
      };
      $display("direction = %0s, addr=0x%0x, data.size()=%0d", axi_req.direction.name(), axi_req.addr, axi_req.data.size());
      axi_req.wait_done = 1;
      axi_req.start(axi_env.vsqrs[0]);

      axi_req = sig_axi_req_vseq#(sys::axi_port_32x32x4)::type_id::create("axi_req", this);
      axi_req.randomize() with {
         direction == WRITE;
         addr == 32'h4d4d4d4d;
         id == 4;
         len == 5;
         alock == 0;  
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
         id == 5;
         len == 5;
         alock == 0;  
         burst == INCR;
         addr_delay == 0;
      };
      $display("direction = %0s, addr=0x%0x, data.size()=%0d", axi_req.direction.name(), axi_req.addr, axi_req.data.size());
      axi_req.wait_done = 1;
      axi_req.start(axi_env.vsqrs[0]);

      axi_req.direction = READ;
      axi_req.start(axi_env.vsqrs[0]);

      $display("%0t: BENI TEST DBG WAIT", $time);
      wait (axi_env.vsqrs[0].is_busy() == 0);
      repeat(10)@(axi_env.slv_agents[0].awaddr_vif.mon_cb);
      phase.drop_objection(this);

   endtask // run_phase


endclass
