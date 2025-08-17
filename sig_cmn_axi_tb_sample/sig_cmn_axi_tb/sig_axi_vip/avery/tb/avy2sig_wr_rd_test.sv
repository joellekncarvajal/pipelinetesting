class avy2sig_wr_rd_test extends my_axi_base_test;
   `uvm_component_utils(avy2sig_wr_rd_test)

   function new(string name="", uvm_component parent);
      super.new(name, parent);
   endfunction // new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      $display("BENI_DBG test build phase done");
   endfunction // build_phase

   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);

      //====================================================================
      //Modify config to set response delay minimum and maximum values
      //====================================================================
      sys_cfg.slv_prt_cfg[0].wr_resp_min_delay=5;
      sys_cfg.slv_prt_cfg[0].wr_resp_max_delay=5;
      sys_cfg.slv_prt_cfg[0].rd_resp_min_delay=10;
      sys_cfg.slv_prt_cfg[0].rd_resp_max_delay=20;

      //====================================================================
      //Modify config to set ready signal delay minimum and maximum values
      //====================================================================
      sys_cfg.slv_prt_cfg[0].min_axready_delay=0;    //wr & rd addr ch ready
      sys_cfg.slv_prt_cfg[0].max_axready_delay=1;
      sys_cfg.slv_prt_cfg[0].axready_high_cycles=2;  //Number of clock cycles is ready before negating

      sys_cfg.slv_prt_cfg[0].min_xready_delay=1;     //wr data ch  ready
      sys_cfg.slv_prt_cfg[0].max_xready_delay=1;
      sys_cfg.slv_prt_cfg[0].xready_high_cycles=6;   //Number of clock cycles is ready before negating

   endfunction 

   task run_phase(uvm_phase phase);

      int numMasters;
      int numSlaves;
      logic[7:0] tmp_q [$];
      bit ok;

      //SIG_AXI VIP slave response sequence      
      sig_axi_resps_vseq#(sys::axi_port_32x32x4) axi_resp;

      //Avery VIP master request sequence
      single_wr_seq wseq;
      single_rd_seq rseq;
      
      numMasters = sys_cfg.num_mstrs;
      numSlaves = sys_cfg.num_slvs;

      
      phase.raise_objection(this);
      $display("%0t: BENI TEST DBG", $time);

      axi_resp = sig_axi_resps_vseq#(sys::axi_port_32x32x4)::type_id::create("axi_resp", this);
      fork
        axi_resp.slv_model = axi_env.slv_agents[0].slv_model;
        axi_resp.start(axi_env.vsqrs[0]);
      join_none

      wseq = new(, tb0.env0.slave[0].sequencer);
      ok = wseq.randomize() with {
          s_addr == 'h100;
          s_len  == 3;
          s_size == 2;
      };
      assert (ok) else `uvm_fatal(get_type_name(), "Randomization Failed.");
      wseq.start(tb0.env0.master[0].sequencer, null);

      wseq = new(, tb0.env0.slave[0].sequencer);
      ok = wseq.randomize() with {
          s_addr == 'h246;
          s_user == 0;
          s_len  == 5;
          s_size == 2;
      };
      wseq.s_data.delete();
      wseq.s_data.push_back(32'h03020100);
      wseq.s_data.push_back(32'h07060504);
      assert (ok) else `uvm_fatal(get_type_name(), "Randomization Failed.");
      wseq.start(tb0.env0.master[0].sequencer, null);

      for (int i=0; i<16; i++) begin
         wseq = new(, tb0.env0.slave[0].sequencer);
         ok = wseq.randomize() with {
             s_addr == 'h100*i + i;
             s_len  == (7+i) % 16;
             s_size == i % 3;
         };
         assert (ok) else `uvm_fatal(get_type_name(), "Randomization Failed.");
         wseq.start(tb0.env0.master[0].sequencer, null);
      end

      for (int i=0; i<16; i++) begin
         rseq = new(, tb0.env0.slave[0].sequencer);
         ok = rseq.randomize() with {
             s_addr == 'h100*i + i;
             s_len  == (7+i) % 16;
             s_size == i % 3;
         };
         assert (ok) else `uvm_fatal(get_type_name(), "Randomization Failed.");
         rseq.start(tb0.env0.master[0].sequencer, null);
      end

      $display("%0t: BENI TEST DBG WAIT", $time);
      wait (axi_env.vsqrs[0].is_busy() == 0);
      repeat(10)@(axi_env.slv_agents[0].awaddr_vif.mon_cb);
      phase.drop_objection(this);

   endtask // run_phase


endclass
