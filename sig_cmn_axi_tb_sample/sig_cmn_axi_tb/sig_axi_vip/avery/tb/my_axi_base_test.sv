import sig_axi_pkg::*;
import axi_pkg::*;

class my_axi_base_test extends sig_test_base;
    aaxi_log test_log;

    aaxi_uvm_testbench  tb0;
    uvm_table_printer   printer;
    aaxi_protocol_version vers;
    aaxi_cfg_info mcfg;
    aaxi_cfg_info scfg;
    bit my_slave_is_dut = 1;

    uvm_report_server obj;

    `uvm_component_utils( my_axi_base_test )

    function new( string name = "my_axi_base_test", 
	    uvm_component parent= null, 
       `ifdef AVERY_AXI3
	    aaxi_protocol_version vers= AAXI3
       `else
	    aaxi_protocol_version vers= AAXI4
       `endif
     );
	super.new(name, parent);
	this.vers = vers;
        test_log= new("test_log");
    endfunction : new

    virtual function void build_phase(uvm_phase phase); 
	super.build_phase(phase);

        if($test$plusargs("TB_USE_VIP_AS_DUT")) begin
            my_slave_is_dut = 0;
            $display("TB_USE_VIP_AS_DUT plusarg found!");
        end

	// Enable transaction recording for everything
	uvm_config_int::set(this, "*", "recording_detail", UVM_FULL);
	uvm_config_db #(aaxi_protocol_version)::set(uvm_root::get(), "*", "vers", vers);
	$display("BENI: vers = %0s",(vers == AAXI3)?"AAXI3" : "AAXI4");
	// ask the sequencer not to generate random sequence at the beginning
	tb0 = aaxi_uvm_testbench::type_id::create("tb0", this);
	uvm_config_db #(int)::set(null, "tb0.env0.master[0].sequencer.build_phase", "count", 0);
	uvm_config_db #(int)::set(null, "tb0.env0.slave[0].sequencer.build_phase", "count", 0);
    `ifdef AVERY_PASSIVE_SLAVE
	uvm_config_db #(int)::set(null, "tb0.env0.psv_slave[0].sequencer.build_phase", "count", 0);
    `endif
    `ifdef AVERY_PASSIVE_MASTER
	uvm_config_db #(int)::set(null, "tb0.env0.psv_master[0].sequencer.build_phase", "count", 0);
    `endif

	// set up bfm configuration
	bfm_config_set();
	//uvm_config_db #(aaxi_cfg_info)::set(this, "tb0.env0.master[0].driver", "cfg_info", mcfg);
	//uvm_config_db #(aaxi_cfg_info)::set(this, "tb0.env0.slave[0].driver", "cfg_info", scfg);

	uvm_config_db #(virtual aaxi_intf)::set(this, "tb0.env0.master[0].driver", "ports", aaxi_uvm_test_top.axi_if[0]);
        //if (my_slave_is_dut) begin
	    uvm_config_db #(virtual aaxi_intf)::set(this, "tb0.env0.slave[0].driver", "ports", aaxi_uvm_test_top.axi_if[1]);
        //end else begin
        //    uvm_config_db #(virtual aaxi_intf)::set(this, "tb0.env0.slave[0].driver", "ports", aaxi_uvm_test_top.axi_if[0]);
        //end
    `ifdef AVERY_PASSIVE_SLAVE
	uvm_config_db #(virtual aaxi_intf)::set(this, "tb0.env0.psv_slave[0].driver", "ports", aaxi_uvm_test_top.axi_if[0]);
    `endif
    `ifdef AVERY_PASSIVE_MASTER
	uvm_config_db #(virtual aaxi_intf)::set(this, "tb0.env0.psv_master[0].driver", "ports", aaxi_uvm_test_top.axi_if[0]);
    `endif
	// Create a specific depth printer for printing the created topology
	printer = new();
	printer.knobs.depth = 4;

    endfunction : build_phase

    virtual function void connect_phase(uvm_phase phase);
	super.connect_phase(phase);
        for (int i = 0; i < AAXI_INTC_MASTER_CNT; i++ ) begin
            tb0.env0.master[i].driver.cfg_info.data_bus_bytes = aaxi_pkg::AAXI_DATA_WIDTH >> 3;
            tb0.env0.master[i].driver.cfg_info.uvm_resp = 1;    
        `ifdef FOUR_OUTSTANDING
            tb0.env0.master[i].driver.cfg_info.total_outstanding_depth= 4;
            tb0.env0.master[i].driver.cfg_info.id_outstanding_depth   = 4;
        `else
            tb0.env0.master[i].driver.cfg_info.total_outstanding_depth= 1;
            tb0.env0.master[i].driver.cfg_info.id_outstanding_depth   = 1;
        `endif
        `ifdef AVERY_AXI_USER
            tb0.env0.master[i].driver.cfg_info.opt_awuser_enable= 1;
            tb0.env0.master[i].driver.cfg_info.opt_wuser_enable = 1;
            tb0.env0.master[i].driver.cfg_info.opt_buser_enable = 1;
            tb0.env0.master[i].driver.cfg_info.opt_aruser_enable= 1;
            tb0.env0.master[i].driver.cfg_info.opt_ruser_enable = 1;
        `endif
        `ifdef AVERY_PASSIVE_MASTER
            tb0.env0.psv_master[i].driver.cfg_info.data_bus_bytes = aaxi_pkg::AAXI_DATA_WIDTH >> 3;
            tb0.env0.psv_master[i].driver.cfg_info.uvm_resp = 1;
            tb0.env0.psv_master[i].driver.cfg_info.total_outstanding_depth= 1;
            tb0.env0.psv_master[i].driver.cfg_info.id_outstanding_depth   = 1;
            tb0.env0.psv_master[i].driver.cfg_info.passive_mode   = 1;
        `endif
        end

        // initial memory value to be 0 for data comparision on Slave BFM
        for (int i = 0; i < AAXI_INTC_SLAVE_CNT; i++ ) begin
            tb0.env0.slave[i].driver.set("mem_uninitialized_value", 1); // default memory value
            tb0.env0.slave[i].driver.cfg_info.uvm_resp = 1; // response item returned, user shall consume them, otherwise may have memory leak
            tb0.env0.slave[i].driver.cfg_info.base_address[0] = 32'h0000_0000; // memory range of address(base <=> limit)
            tb0.env0.slave[i].driver.cfg_info.limit_address[0] = 32'hFFFF_FFFF;
            tb0.env0.slave[i].driver.cfg_info.data_bus_bytes = aaxi_pkg::AAXI_DATA_WIDTH >> 3; // bytes of data_bus the device is using
//            tb0.env0.slave[i].driver.add_fifo(32'habcc +i, 4); // set fifo memory address
            tb0.env0.slave[i].driver.cfg_info.total_outstanding_depth= 1;
            tb0.env0.slave[i].driver.cfg_info.id_outstanding_depth   = 1;
            tb0.env0.slave[i].driver.cfg_info.passive_mode   = 0; //my_slave_is_dut;
        `ifdef AVERY_PASSIVE_SLAVE
            tb0.env0.psv_slave[i].driver.set("mem_uninitialized_value", 0);
            tb0.env0.psv_slave[i].driver.cfg_info.uvm_resp = 1; // response item returned, user shall consume them, otherwise may have memory leak
            tb0.env0.psv_slave[i].driver.cfg_info.base_address[0] = 32'h0000_0000;
            tb0.env0.psv_slave[i].driver.cfg_info.limit_address[0] = 32'hFFFF_FFFF;
            tb0.env0.psv_slave[i].driver.cfg_info.data_bus_bytes = aaxi_pkg::AAXI_DATA_WIDTH >> 3;
            tb0.env0.psv_slave[i].driver.add_fifo(32'habcc +i, 4);
            tb0.env0.psv_slave[i].driver.cfg_info.total_outstanding_depth= 1;
            tb0.env0.psv_slave[i].driver.cfg_info.id_outstanding_depth   = 1;
            tb0.env0.psv_slave[i].driver.cfg_info.passive_mode   = 1;
        `endif
        `ifdef AVERY_AXI_USER
            tb0.env0.slave[i].driver.cfg_info.opt_awuser_enable= 1;
            tb0.env0.slave[i].driver.cfg_info.opt_wuser_enable = 1;
            tb0.env0.slave[i].driver.cfg_info.opt_buser_enable = 1;
            tb0.env0.slave[i].driver.cfg_info.opt_aruser_enable= 1;
            tb0.env0.slave[i].driver.cfg_info.opt_ruser_enable = 1;
        `endif
        end
    endfunction

    function void bfm_config_set();
        // move to connect_phase
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.phase_done.set_drain_time(this,200);
    endtask

    function void end_of_elaboration_phase(uvm_phase phase);
	`uvm_info(get_type_name(),
	    $psprintf("Printing the test topology :\n%s", this.sprint(printer)), UVM_LOW)
    endfunction : end_of_elaboration_phase

    virtual function void report_phase(uvm_phase phase);
        uvm_report_server rpt = uvm_report_server::get_server();
        int  cnt1 = rpt.get_severity_count(UVM_ERROR);
        int  cnt2 = rpt.get_severity_count(UVM_FATAL);
        int err_cnt,fatal_cnt;
        string test_name1[$];
        
        super.report_phase(phase);

        test_log.merge_coverage(tb0.env0.master[0].driver.log);
        test_log.merge_coverage(tb0.env0.slave[0].driver.log);

        // print out assertion coverage
        test_log.coverage_rpt();

        if (cnt1 || cnt2)                                                                                                                                                                     
            `uvm_info(get_type_name(),
                $psprintf("Test failed due to UVM_ERROR=%0d and UVM_FATAL=%0d", cnt1, cnt2), UVM_LOW);

       obj=_global_reporter.get_report_server();
       err_cnt=obj.get_severity_count(UVM_ERROR);
       fatal_cnt=obj.get_severity_count(UVM_FATAL);
       void'(uvm_cmdline_proc.get_arg_values("+UVM_TESTNAME=",test_name1));
       $display("========================================================================");
       if((err_cnt==0)&&(fatal_cnt==0)) begin
           $display("*--------- TESTCASE PASSED: %s ---------*",test_name1.pop_front);
       end
       else begin
            $display("*-------- TESTCASE FAILED: %s ----------*",test_name1.pop_front);
       end
       $display("========================================================================");

    endfunction : report_phase

endclass: my_axi_base_test
