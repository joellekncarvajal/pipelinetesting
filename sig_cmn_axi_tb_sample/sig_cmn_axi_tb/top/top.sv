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
        .AXI_IN_DATA_WIDTH  (`AXI_IN_DATA_WIDTH),
        .AXI_OUT_DATA_WIDTH (`AXI_OUT_DATA_WIDTH),
        .AXI_ADDR_WIDTH     (`AXI_ADDR_WIDTH),
        .AXI_IN_RD_ID_WIDTH (`AXI_IN_RD_ID_WIDTH),
        .AXI_IN_WR_ID_WIDTH (`AXI_IN_WR_ID_WIDTH),
        .AXI_OUT_RD_ID_WIDTH(`AXI_OUT_RD_ID_WIDTH),
        .AXI_OUT_WR_ID_WIDTH(`AXI_OUT_WR_ID_WIDTH),
        .AXI_USER_REQ_WIDTH (`AXI_USER_REQ_WIDTH),
        .AXI_USER_DATA_WIDTH(`AXI_USER_DATA_WIDTH),
        .AXI_USER_RESP_WIDTH(`AXI_USER_RESP_WIDTH)
    ) u_dut (
        .aclk               (clk),
        .aresetn            (resetn),
        .arid_in            (axi_mst_raddr_inf.AxID),  
        .araddr_in          (axi_mst_raddr_inf.AxADDR),  
        .arlen_in           (axi_mst_raddr_inf.AxLEN),  
        .arsize_in          (axi_mst_raddr_inf.AxSIZE),  
        .arburst_in         (axi_mst_raddr_inf.AxBURST),  
        .arlock_in          (axi_mst_raddr_inf.AxLOCK),  
        .arcache_in         (axi_mst_raddr_inf.AxCACHE),  
        .arprot_in          (axi_mst_raddr_inf.AxPROT),  
        .aruser_in          (axi_mst_raddr_inf.AxUSER),  
        .rdata_in           (axi_mst_rdata_inf.xDATA),  
        .rid_in             (axi_mst_rdata_inf.xID),  
        .rresp_in           (axi_mst_rdata_inf.xRESP),  
        .rlast_in           (axi_mst_rdata_inf.xLAST),  
        .ruser_in           (axi_mst_rdata_inf.xUSER),  
        .rvalid_in          (axi_mst_rdata_inf.xVALID),  
        .rready_in          (axi_mst_rdata_inf.xREADY),  
        .awid_in            (axi_mst_waddr_inf.AxID),  
        .awaddr_in          (axi_mst_waddr_inf.AxADDR),  
        .awlen_in           (axi_mst_waddr_inf.AxLEN),  
        .awsize_in          (axi_mst_waddr_inf.AxSIZE),  
        .awburst_in         (axi_mst_waddr_inf.AxBURST),  
        .awlock_in          (axi_mst_waddr_inf.AxLOCK),  
        .awcache_in         (axi_mst_waddr_inf.AxCACHE),  
        .awprot_in          (axi_mst_waddr_inf.AxPROT),  
        .awuser_in          (axi_mst_waddr_inf.AxUSER),  
        .wdata_in           (axi_mst_wdata_inf.xDATA),  
        .wstrb_in           (axi_mst_wdata_inf.xSTRB),	
        .wlast_in           (axi_mst_wdata_inf.xLAST),	
        .wuser_in           (axi_mst_wdata_inf.xUSER),	
        .wvalid_in          (axi_mst_wdata_inf.xVALID),	
        .wready_in          (axi_mst_wdata_inf.xREADY),	
        .bid_in             (axi_mst_resp_inf.BID),	
        .bresp_in           (axi_mst_resp_inf.BRESP),	
        .bvalid_in          (axi_mst_resp_inf.BVALID),	
        .bready_in          (axi_mst_resp_inf.BREADY),  
        .buser_in           (axi_mst_resp_inf.BUSER),  
        .arqos_in           (axi_mst_raddr_inf.AxQOS),  
        .arregion_in        (axi_mst_raddr_inf.AxREGION),  
        .awqos_in           (axi_mst_waddr_inf.AxQOS),  
        .awregion_in        (axi_mst_waddr_inf.AxREGION),  
        .arvalid_in         (axi_mst_raddr_inf.AxVALID),  
        .awvalid_in         (axi_mst_waddr_inf.AxVALID),  
        .arready_in         (axi_mst_raddr_inf.AxREADY),  
        .awready_in         (axi_mst_waddr_inf.AxREADY),      
        .arid_out           (axi_slv_raddr_inf.AxID),  
        .araddr_out         (axi_slv_raddr_inf.AxADDR),  
        .arlen_out          (axi_slv_raddr_inf.AxLEN),  
        .arsize_out         (axi_slv_raddr_inf.AxSIZE),  
        .arburst_out        (axi_slv_raddr_inf.AxBURST),  
        .arlock_out         (axi_slv_raddr_inf.AxLOCK),  
        .arcache_out        (axi_slv_raddr_inf.AxCACHE),  
        .arprot_out         (axi_slv_raddr_inf.AxPROT),  
        .aruser_out         (axi_slv_raddr_inf.AxUSER),  
        .rdata_out	        (axi_slv_rdata_inf.xDATA),  
        .rid_out	        (axi_slv_rdata_inf.xID),  
        .rresp_out	        (axi_slv_rdata_inf.xRESP),  
        .rlast_out	        (axi_slv_rdata_inf.xLAST),  
        .ruser_out	        (axi_slv_rdata_inf.xUSER),  
        .rvalid_out	        (axi_slv_rdata_inf.xVALID),  
        .rready_out         (axi_slv_rdata_inf.xREADY),  
        .awid_out           (axi_slv_waddr_inf.AxID),  
        .awaddr_out         (axi_slv_waddr_inf.AxADDR),  
        .awlen_out          (axi_slv_waddr_inf.AxLEN),  
        .awsize_out         (axi_slv_waddr_inf.AxSIZE),  
        .awburst_out        (axi_slv_waddr_inf.AxBURST),  
        .awlock_out         (axi_slv_waddr_inf.AxLOCK),  
        .awcache_out        (axi_slv_waddr_inf.AxCACHE),  
        .awprot_out         (axi_slv_waddr_inf.AxPROT),  
        .awuser_out         (axi_slv_waddr_inf.AxUSER),  
        .wdata_out          (axi_slv_wdata_inf.xDATA),  
        .wstrb_out          (axi_slv_wdata_inf.xSTRB),  
        .wlast_out          (axi_slv_wdata_inf.xLAST),  
        .wuser_out          (axi_slv_wdata_inf.xUSER),  
        .wvalid_out         (axi_slv_wdata_inf.xVALID),  
        .wready_out	        (axi_slv_wdata_inf.xREADY),  
        .bid_out	        (axi_slv_resp_inf.BID),  
        .bresp_out	        (axi_slv_resp_inf.BRESP),  
        .bvalid_out	        (axi_slv_resp_inf.BVALID),  
        .bready_out         (axi_slv_resp_inf.BREADY),  
        .buser_out          (axi_slv_resp_inf.BUSER),  
        .arqos_out          (axi_slv_raddr_inf.AxQOS),  
        .arregion_out       (axi_slv_raddr_inf.AxREGION),  
        .awqos_out          (axi_slv_waddr_inf.AxQOS),  
        .awregion_out       (axi_slv_waddr_inf.AxREGION),  
        .arvalid_out        (axi_slv_raddr_inf.AxVALID),	
        .awvalid_out        (axi_slv_waddr_inf.AxVALID),  
        .arready_out	    (axi_slv_raddr_inf.AxREADY),	
        .awready_out        (axi_slv_waddr_inf.AxREADY)
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
