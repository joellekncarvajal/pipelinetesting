`timescale 1ps/1ps

import sys::*;

parameter number_of_ports = 1;
parameter number_of_masters = number_of_ports;
parameter number_of_slaves = number_of_ports;

//`define WITH_BURST_LIMITER
//`define WITH_ID_TRANS

module top;
    `include "uvm_macros.svh"
    import uvm_pkg::*;

    reg clk;
    reg resetn;

    // generate clock
    initial begin
        clk = 0;
        forever begin
          #1000ps;
          clk = ~clk;
        end
    end

    // generate reset
    initial begin
        resetn = 0;
        repeat  (5) @ (posedge clk);
        resetn = 1;
    end

    // Write master IFs
    axi_addr_inf #(
        .ID_WIDTH     (sys::axi_port_ip::AXI_ID_WIDTH),
        .ADDR_WIDTH   (sys::axi_port_ip::AXI_ADDR_WIDTH),
        .USER_WIDTH   (sys::axi_port_ip::AXI_USER_WIDTH)
    ) axi_mst_waddr_inf (
        .clk(clk),
        .resetn(resetn)
    );
    axi_data_inf #(
        .ID_WIDTH     (sys::axi_port_ip::AXI_ID_WIDTH),
        .DATA_WIDTH   (sys::axi_port_ip::AXI_DATA_WIDTH),
        .STRB_WIDTH   (sys::axi_port_ip::AXI_STRB_WIDTH),
        .USER_WIDTH   (sys::axi_port_ip::AXI_USER_WIDTH)
    ) axi_mst_wdata_inf (
        .clk(clk),
        .resetn(resetn)
    );
    axi_resp_inf #(
        .ID_WIDTH     (sys::axi_port_ip::AXI_ID_WIDTH),
        .USER_WIDTH   (sys::axi_port_ip::AXI_USER_WIDTH)
    ) axi_mst_resp_inf (
        .clk(clk),
        .resetn(resetn)
    );

    // Read master IFs
    axi_addr_inf #(
        .ID_WIDTH     (sys::axi_port_ip::AXI_ID_WIDTH),
        .ADDR_WIDTH   (sys::axi_port_ip::AXI_ADDR_WIDTH),
        .USER_WIDTH   (sys::axi_port_ip::AXI_USER_WIDTH)
    ) axi_mst_raddr_inf (
        .clk(clk),
        .resetn(resetn)
    );
    axi_data_inf #(
        .ID_WIDTH     (sys::axi_port_ip::AXI_ID_WIDTH),
        .DATA_WIDTH   (sys::axi_port_ip::AXI_DATA_WIDTH),
        .STRB_WIDTH   (sys::axi_port_ip::AXI_STRB_WIDTH),
        .USER_WIDTH   (sys::axi_port_ip::AXI_USER_WIDTH)
    ) axi_mst_rdata_inf (
        .clk(clk),
        .resetn(resetn)
    );

    // Write slave IFs
    axi_addr_inf #( 
        .ID_WIDTH     (sys::axi_port_ep::AXI_ID_WIDTH),
        .ADDR_WIDTH   (sys::axi_port_ep::AXI_ADDR_WIDTH),
        .USER_WIDTH   (sys::axi_port_ep::AXI_USER_WIDTH)
    ) axi_slv_waddr_inf (
        .clk(clk),
        .resetn(resetn)
    );
    axi_data_inf #(
        .ID_WIDTH     (sys::axi_port_ep::AXI_ID_WIDTH),
        .DATA_WIDTH   (sys::axi_port_ep::AXI_DATA_WIDTH),
        .STRB_WIDTH   (sys::axi_port_ep::AXI_STRB_WIDTH),
        .USER_WIDTH   (sys::axi_port_ep::AXI_USER_WIDTH)
    ) axi_slv_wdata_inf (
        .clk(clk),
        .resetn(resetn)
    );
    axi_resp_inf #(
        .ID_WIDTH     (sys::axi_port_ep::AXI_ID_WIDTH),
        .USER_WIDTH   (sys::axi_port_ep::AXI_USER_WIDTH)
    ) axi_slv_resp_inf (
        .clk(clk),
        .resetn(resetn)
    );

    // READ slave IFs
    axi_addr_inf #(
        .ID_WIDTH     (sys::axi_port_ep::AXI_ID_WIDTH),
        .ADDR_WIDTH   (sys::axi_port_ep::AXI_ADDR_WIDTH),
        .USER_WIDTH   (sys::axi_port_ep::AXI_USER_WIDTH)
    ) axi_slv_raddr_inf (
        .clk(clk),
        .resetn(resetn)
    );

    axi_data_inf #(
        .ID_WIDTH     (sys::axi_port_ep::AXI_ID_WIDTH),
        .DATA_WIDTH   (sys::axi_port_ep::AXI_DATA_WIDTH),
        .STRB_WIDTH   (sys::axi_port_ep::AXI_STRB_WIDTH),
        .USER_WIDTH   (sys::axi_port_ep::AXI_USER_WIDTH)
    ) axi_slv_rdata_inf (
        .clk(clk),
        .resetn(resetn)
    );

    sig_cmn_axi_sample #(
	    .ADDR_WIDTH ('AXI_ADDR_WIDTH),
		.DATA_WIDTH ('AXI_IN_DATA_WIDTH),
		.ID_WIDTH   ('AXI_IN_RD_ID_WIDTH),
		.USER_WIDTH (`AXI_USER_DATA_WIDTH),
		.NUM_STAGES (1)
    ) u_dut (
        .ACLK               (clk),
        .ARESETN            (resetn),
        .mst_ARID            (axi_mst_raddr_inf.AxID),  
        .mst_ARADDR          (axi_mst_raddr_inf.AxADDR),  
        .mst_ARLEN           (axi_mst_raddr_inf.AxLEN),  
        .mst_ARSIZE          (axi_mst_raddr_inf.AxSIZE),  
        .mst_ARBURST         (axi_mst_raddr_inf.AxBURST),  
        .mst_ARLOCK          (axi_mst_raddr_inf.AxLOCK),  
        .mst_ARCACHE         (axi_mst_raddr_inf.AxCACHE),  
        .mst_ARPROT          (axi_mst_raddr_inf.AxPROT),  
        .mst_ARUSER          (axi_mst_raddr_inf.AxUSER),  
        .mst_RDATA           (axi_mst_rdata_inf.xDATA),  
        .mst_RID             (axi_mst_rdata_inf.xID),  
        .mst_RRESP           (axi_mst_rdata_inf.xRESP),  
        .mst_RLAST          (axi_mst_rdata_inf.xLAST),  
        .mst_RUSER           (axi_mst_rdata_inf.xUSER),  
        .mst_RVALID          (axi_mst_rdata_inf.xVALID),  
        .mst_RREADY          (axi_mst_rdata_inf.xREADY),  
        .mst_AWID            (axi_mst_waddr_inf.AxID),  
        .mst_AWADDR          (axi_mst_waddr_inf.AxADDR),  
        .mst_AWLEN           (axi_mst_waddr_inf.AxLEN),  
        .mst_AWSIZE          (axi_mst_waddr_inf.AxSIZE),  
        .mst_AWBURST         (axi_mst_waddr_inf.AxBURST),  
        .mst_AWLOCK          (axi_mst_waddr_inf.AxLOCK),  
        .mst_AWCACHE         (axi_mst_waddr_inf.AxCACHE),  
        .mst_AWPROT          (axi_mst_waddr_inf.AxPROT),  
        .mst_AWUSER          (axi_mst_waddr_inf.AxUSER),  
        .mst_WDATA           (axi_mst_wdata_inf.xDATA),  
        .mst_WSTRB           (axi_mst_wdata_inf.xSTRB),	
        .mst_WLAST           (axi_mst_wdata_inf.xLAST),	
        .mst_WUSER           (axi_mst_wdata_inf.xUSER),	
        .mst_WVALID          (axi_mst_wdata_inf.xVALID),	
        .mst_WREADY          (axi_mst_wdata_inf.xREADY),	
        .mst_BID             (axi_mst_resp_inf.BID),	
        .mst_BRESP           (axi_mst_resp_inf.BRESP),	
        .mst_BVALID          (axi_mst_resp_inf.BVALID),	
        .mst_BREADY          (axi_mst_resp_inf.BREADY),  
        .mst_BUSER           (axi_mst_resp_inf.BUSER),  
        .mst_ARQOS           (axi_mst_raddr_inf.AxQOS),  
        .mst_ARREGION        (axi_mst_raddr_inf.AxREGION),  
        .mst_AWQOS          (axi_mst_waddr_inf.AxQOS),  
        .mst_AWREGION        (axi_mst_waddr_inf.AxREGION),  
        .mst_ARVALID         (axi_mst_raddr_inf.AxVALID),  
        .mst_AWVALID         (axi_mst_waddr_inf.AxVALID),  
        .mst_ARREADY         (axi_mst_raddr_inf.AxREADY),  
        .mst_AWREADY         (axi_mst_waddr_inf.AxREADY),
		
        .slv_ARID           (axi_slv_raddr_inf.AxID),  
        .slv_ARADDR         (axi_slv_raddr_inf.AxADDR),  
        .slv_ARLEN          (axi_slv_raddr_inf.AxLEN),  
        .slv_ARSIZE         (axi_slv_raddr_inf.AxSIZE),  
        .slv_ARBURST        (axi_slv_raddr_inf.AxBURST),  
        .slv_ARLOCK         (axi_slv_raddr_inf.AxLOCK),  
        .slv_ARCACHE        (axi_slv_raddr_inf.AxCACHE),  
        .slv_ARPROT         (axi_slv_raddr_inf.AxPROT),  
        .slv_ARUSER         (axi_slv_raddr_inf.AxUSER),  
        .slv_RDATA	        (axi_slv_rdata_inf.xDATA),  
        .slv_RID	        (axi_slv_rdata_inf.xID),  
        .slv_RRESP	        (axi_slv_rdata_inf.xRESP),  
        .slv_RLAST	        (axi_slv_rdata_inf.xLAST),  
        .slv_RUSER	        (axi_slv_rdata_inf.xUSER),  
        .slv_RVALID	        (axi_slv_rdata_inf.xVALID),  
        .slv_RREADY         (axi_slv_rdata_inf.xREADY),  
        .slv_AWID           (axi_slv_waddr_inf.AxID),  
        .slv_AWADDR         (axi_slv_waddr_inf.AxADDR),  
        .slv_AWLEN          (axi_slv_waddr_inf.AxLEN),  
        .slv_AWSIZE         (axi_slv_waddr_inf.AxSIZE),  
        .slv_AWBURST        (axi_slv_waddr_inf.AxBURST),  
        .slv_AWLOCK         (axi_slv_waddr_inf.AxLOCK),  
        .slv_AWCACHE        (axi_slv_waddr_inf.AxCACHE),  
        .slv_AWPROT         (axi_slv_waddr_inf.AxPROT),  
        .slv_AWUSER         (axi_slv_waddr_inf.AxUSER),  
        .slv_WDATA          (axi_slv_wdata_inf.xDATA),  
        .slv_WSTRB          (axi_slv_wdata_inf.xSTRB),  
        .slv_WLAST          (axi_slv_wdata_inf.xLAST),  
        .slv_WUSER          (axi_slv_wdata_inf.xUSER),  
        .slv_WVALID         (axi_slv_wdata_inf.xVALID),  
        .slv_WREADY	        (axi_slv_wdata_inf.xREADY),  
        .slv_BID	        (axi_slv_resp_inf.BID),  
        .slv_BRESP	        (axi_slv_resp_inf.BRESP),  
        .slv_BVALID	        (axi_slv_resp_inf.BVALID),  
        .slv_BREADY         (axi_slv_resp_inf.BREADY),  
        .slv_BUSER          (axi_slv_resp_inf.BUSER),  
        .slv_ARQOS          (axi_slv_raddr_inf.AxQOS),  
        .slv_ARREGION       (axi_slv_raddr_inf.AxREGION),  
        .slv_AWQOS          (axi_slv_waddr_inf.AxQOS),  
        .slv_AWREGION       (axi_slv_waddr_inf.AxREGION),  
        .slv_ARVALID        (axi_slv_raddr_inf.AxVALID),	
        .slv_AWVALID        (axi_slv_waddr_inf.AxVALID),  
        .slv_ARREADY	    (axi_slv_raddr_inf.AxREADY),	
        .slv_AWREADY        (axi_slv_waddr_inf.AxREADY)
    );

    //assign axi_mst_rdata_inf.xUSER   = '0 ;  
    //assign axi_mst_resp_inf.BUSER	 = '0 ;  
    //assign axi_slv_raddr_inf.AxUSER  = '0 ;  
    //assign axi_slv_waddr_inf.AxUSER	 = '0 ;  
    //assign axi_slv_wdata_inf.xUSER	 = '0 ;

    assign axi_slv_wdata_inf.xID     = '0 ;//axi3 only
    assign axi_slv_rdata_inf.xSTRB = '0;
    assign axi_slv_wdata_inf.xRESP = '0;
    assign axi_mst_rdata_inf.xSTRB = '0;
    assign axi_mst_wdata_inf.xRESP = '0;

    string env_name = "axi_env";

    initial begin
        uvm_config_db #(sys::axi_port_ip::addr_if_t)::set(null, "uvm_test_top",
                                            $sformatf("mst_agent.mstr_waddr_inf"),
                                            axi_mst_waddr_inf);
        uvm_config_db #(sys::axi_port_ip::addr_if_t)::set(null, "uvm_test_top",
                                            $sformatf("mst_agent.mstr_raddr_inf"),
                                            axi_mst_raddr_inf);
        uvm_config_db #(sys::axi_port_ip::data_if_t)::set(null, "uvm_test_top",
                                            $sformatf("mst_agent.mstr_wdata_inf"),
                                            axi_mst_wdata_inf);
        uvm_config_db #(sys::axi_port_ip::data_if_t)::set(null, "uvm_test_top",
                                            $sformatf("mst_agent.mstr_rdata_inf"),
                                            axi_mst_rdata_inf);
        uvm_config_db #(sys::axi_port_ip::resp_if_t)::set(null, "uvm_test_top",
                                            $sformatf("mst_agent.mstr_resp_inf"),
                                            axi_mst_resp_inf);

        uvm_config_db #(sys::axi_port_ep::addr_if_t)::set(null, "uvm_test_top", 
                                $sformatf("slv_agent.slv_waddr_inf"),
                                axi_slv_waddr_inf);
        uvm_config_db #(sys::axi_port_ep::addr_if_t)::set(null, "uvm_test_top",
                                $sformatf("slv_agent.slv_raddr_inf"),
                                axi_slv_raddr_inf);
        uvm_config_db #(sys::axi_port_ep::data_if_t)::set(null, "uvm_test_top",
                                $sformatf("slv_agent.slv_wdata_inf"),
                                axi_slv_wdata_inf);
        uvm_config_db #(sys::axi_port_ep::data_if_t)::set(null, "uvm_test_top",
                                $sformatf("slv_agent.slv_rdata_inf"),
                                axi_slv_rdata_inf);
        uvm_config_db #(sys::axi_port_ep::resp_if_t)::set(null, "uvm_test_top",
                                $sformatf("slv_agent.slv_resp_inf"),
                                axi_slv_resp_inf);
    end


    initial begin
        // AXI Configurations
        uvm_config_db #(integer)::set(null, "", "number_of_masters", number_of_masters);
        uvm_config_db #(integer)::set(null, "", "number_of_slaves", number_of_slaves);
    end

    initial begin
        run_test();
    end

    initial begin
    `ifdef DUMP_VPD
        $vcdplusfile("top.vpd");
        $vcdpluson(0, top);
        $vcdplusmemon();
    `endif
    `ifdef DUMP_VCD
        $dumpfile("top.vcd");
        $dumpvars(0, top);
    `endif
    `ifdef DUMP_FSDB
        $fsdbDumpfile("top.fsdb");
        $fsdbDumpvars(0, top, "+all");
        $fsdbDumpvars("+struct");
        $fsdbDumpvars("+mda");
        $fsdbDumpon;
    `endif
    end
endmodule
