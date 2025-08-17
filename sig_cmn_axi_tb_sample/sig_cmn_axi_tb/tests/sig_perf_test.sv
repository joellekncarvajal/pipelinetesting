import axi_pkg::*;
import sys::*;

class sig_perf_test extends sig_base_test;
   `uvm_component_utils(sig_perf_test)

    function new(string name="", uvm_component parent);
        super.new(name, parent);
    endfunction // new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        $display("_DBG test build phase done");
    endfunction // build_phase

    task wait_num_pending();
        repeat(1000) @(posedge top.clk);

        while (axi_env.mst_agents.slv_model.get_num_pending_total() != 0) begin
            repeat(100) @(posedge top.clk);
            //$display("%0t: mst num_pend=%0d", $time, env.mst_agents.slv_model.get_num_pending_total());
        end
        while (axi_env.slv_agents.slv_model.get_num_pending_total() != 0) begin
            repeat(100) @(posedge top.clk);
            //$display("%0t: slv num_pend=%0d", $time, env.slv_agents.slv_model.get_num_pending_total());
        end
    endtask

    task run_phase(uvm_phase phase);

        int numMasters;
        int numSlaves;
        int num_txns = 1000;
        logic[7:0] tmp_q [$];
        
        sig_axi_req_vseq#(sys::axi_port_ip) axi_req;
        sig_axi_resps_vseq#(sys::axi_port_ep) axi_resp;
        uvm_queue #(sig_axi_req_vseq#(sys::axi_port_ip)) axi_req_queue;

        phase.raise_objection(this);
        $display("%0t:  TEST DBG", $time);

        axi_resp = sig_axi_resps_vseq#(sys::axi_port_ep)::type_id::create("axi_resp", this);
        axi_resp.slv_model = axi_env.slv_agents.slv_model;
        fork
            axi_resp.start(axi_env.slv_vsqrs);
        join_none

        axi_req_queue = new();

        for(int j = 0; j < num_txns; j++) begin
            axi_req = sig_axi_req_vseq#(sys::axi_port_ip)::type_id::create("axi_req", this);
            //axi_req.no_delay_c.constraint_mode(0); //disable no data delay constraint
            axi_req.version = AXI4; 
            axi_req.randomize() with {
                direction == WRITE;
                size == $clog2(sys::axi_port_ip::AXI_DATA_WIDTH/8);     //TODO: remove to randomize; (Narrow transfers -- not yet supported)
                len == 0;
                burst == INCR; //TODO: remove to randomize; (Data mismatch with burst type WRAP -- Low priority)
                //cache == 0;    //TODO: remove to randomize; (Still limited to Non-Bufferable Non-cacheable)
                //addr_delay inside {[0]};
                //foreach (data_delay[n]) { data_delay[n] inside {[0]}; }
            };
            axi_req.wait_done = 0; //1 - to wait for ongoing request to finish; 0 - to not wait before next request
            axi_req_queue.push_back(axi_req);
            axi_req.start(axi_env.mst_vsqrs);
        end

        //Wait for pending transactions before read
        wait_num_pending();

        //Repeat for read sequences with same written address
        for(int k = 0; k < num_txns; k++) begin
            axi_req = axi_req_queue.pop_front(); 
            axi_req.write_to_read();
            axi_req.start(axi_env.mst_vsqrs);
        end

        //Wait for pending transactions
        wait_num_pending();

        while (axi_env.mst_agents.slv_model.get_num_pending_total() > 0) begin
            repeat(20)@(axi_env.slv_agents.awaddr_vif.mon_cb);
        end

        $display("%0t:  TEST DBG WAIT", $time);
        wait (axi_env.mst_vsqrs.is_busy() == 0);
        repeat(1000)@(axi_env.slv_agents.awaddr_vif.mon_cb);
        //axi_env.slv_mem.readMem(32'h55500555, 24, tmp_q);
        phase.drop_objection(this);

    endtask // run_phase
   
endclass // sig_perf_test
