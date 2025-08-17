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
`timescale 1ns/1ps
import sys::*;
//typedef sys::axi_port_32x32x4::data_if_t data_if_type;	    

parameter number_of_ports = 2;
parameter number_of_masters = number_of_ports;
parameter number_of_slaves = number_of_ports;

module dut(axi_addr_inf axi_mstr_waddr_inf[number_of_masters],
	   axi_addr_inf axi_mstr_raddr_inf[number_of_masters],
	   axi_addr_inf axi_slv_waddr_inf[number_of_slaves],
	   axi_addr_inf axi_slv_raddr_inf[number_of_slaves],
	   axi_data_inf axi_mstr_wdata_inf[number_of_masters],
	   axi_data_inf axi_mstr_rdata_inf[number_of_masters],
	   axi_data_inf axi_slv_wdata_inf[number_of_slaves],
	   axi_data_inf axi_slv_rdata_inf[number_of_slaves],
	   axi_resp_inf axi_mstr_resp_inf[number_of_masters],
	   axi_resp_inf axi_slv_resp_inf[number_of_slaves]);


   genvar i;
   generate
      for (i=0; i<number_of_ports; i++) begin
	 
	 assign axi_mstr_waddr_inf[i].AxREADY = axi_slv_waddr_inf[i].AxREADY;
	 assign axi_slv_waddr_inf[i].AxID = axi_mstr_waddr_inf[i].AxID;
	 assign axi_slv_waddr_inf[i].AxVALID = axi_mstr_waddr_inf[i].AxVALID;
	 assign axi_slv_waddr_inf[i].AxADDR = axi_mstr_waddr_inf[i].AxADDR;
	 assign axi_slv_waddr_inf[i].AxLEN = axi_mstr_waddr_inf[i].AxLEN;
	 assign axi_slv_waddr_inf[i].AxSIZE = axi_mstr_waddr_inf[i].AxSIZE;
	 assign axi_slv_waddr_inf[i].AxBURST = axi_mstr_waddr_inf[i].AxBURST;
	 assign axi_slv_waddr_inf[i].AxLOCK = axi_mstr_waddr_inf[i].AxLOCK;
	 assign axi_slv_waddr_inf[i].AxCACHE = axi_mstr_waddr_inf[i].AxCACHE;
	 assign axi_slv_waddr_inf[i].AxPROT = axi_mstr_waddr_inf[i].AxPROT;
	 assign axi_slv_waddr_inf[i].AxQOS = axi_mstr_waddr_inf[i].AxQOS;
         assign axi_slv_waddr_inf[i].AxUSER = axi_mstr_waddr_inf[i].AxUSER;
         assign axi_slv_waddr_inf[i].AxREGION = axi_mstr_waddr_inf[i].AxREGION;
	 
	 assign axi_mstr_raddr_inf[i].AxREADY = axi_slv_raddr_inf[i].AxREADY;
	 assign axi_slv_raddr_inf[i].AxID = axi_mstr_raddr_inf[i].AxID;
	 assign axi_slv_raddr_inf[i].AxVALID = axi_mstr_raddr_inf[i].AxVALID;
	 assign axi_slv_raddr_inf[i].AxADDR = axi_mstr_raddr_inf[i].AxADDR;
	 assign axi_slv_raddr_inf[i].AxLEN = axi_mstr_raddr_inf[i].AxLEN;
	 assign axi_slv_raddr_inf[i].AxSIZE = axi_mstr_raddr_inf[i].AxSIZE;
	 assign axi_slv_raddr_inf[i].AxBURST = axi_mstr_raddr_inf[i].AxBURST;
	 assign axi_slv_raddr_inf[i].AxLOCK = axi_mstr_raddr_inf[i].AxLOCK;
	 assign axi_slv_raddr_inf[i].AxCACHE = axi_mstr_raddr_inf[i].AxCACHE;
	 assign axi_slv_raddr_inf[i].AxPROT = axi_mstr_raddr_inf[i].AxPROT;
	 assign axi_slv_raddr_inf[i].AxQOS = axi_mstr_raddr_inf[i].AxQOS;
         assign axi_slv_raddr_inf[i].AxUSER = axi_mstr_raddr_inf[i].AxUSER;
         assign axi_slv_raddr_inf[i].AxREGION = axi_mstr_raddr_inf[i].AxREGION;
	 
	 assign axi_mstr_wdata_inf[i].xREADY = axi_slv_wdata_inf[i].xREADY;
	 assign axi_slv_wdata_inf[i].xVALID = axi_mstr_wdata_inf[i].xVALID;
	 assign axi_slv_wdata_inf[i].xDATA = axi_mstr_wdata_inf[i].xDATA;
	 assign axi_slv_wdata_inf[i].xLAST = axi_mstr_wdata_inf[i].xLAST;
	 assign axi_slv_wdata_inf[i].xSTRB = axi_mstr_wdata_inf[i].xSTRB;
         assign axi_slv_wdata_inf[i].xID = axi_mstr_wdata_inf[i].xID;
         assign axi_slv_wdata_inf[i].xUSER = axi_mstr_wdata_inf[i].xUSER;
	 
	 assign axi_slv_rdata_inf[i].xREADY = axi_mstr_rdata_inf[i].xREADY;
	 assign axi_mstr_rdata_inf[i].xVALID = axi_slv_rdata_inf[i].xVALID;
	 assign axi_mstr_rdata_inf[i].xID = axi_slv_rdata_inf[i].xID;
	 assign axi_mstr_rdata_inf[i].xDATA = axi_slv_rdata_inf[i].xDATA;
	 assign axi_mstr_rdata_inf[i].xLAST = axi_slv_rdata_inf[i].xLAST;
	 assign axi_mstr_rdata_inf[i].xRESP = axi_slv_rdata_inf[i].xRESP;
         assign axi_mstr_rdata_inf[i].xUSER = axi_slv_rdata_inf[i].xUSER;
	 
	 assign axi_slv_resp_inf[i].BREADY = axi_mstr_resp_inf[i].BREADY;
	 assign axi_mstr_resp_inf[i].BVALID = axi_slv_resp_inf[i].BVALID;
	 assign axi_mstr_resp_inf[i].BID = axi_slv_resp_inf[i].BID;
	 assign axi_mstr_resp_inf[i].BRESP = axi_slv_resp_inf[i].BRESP;
         assign axi_mstr_resp_inf[i].BUSER = axi_slv_resp_inf[i].BUSER;
	 
      end // for (i=0; i<number_of_ports; i++)
      
   endgenerate
   
endmodule // dut


module top;

   import uvm_pkg::*;
   `include "uvm_macros.svh"
   
   bit clk;
   bit rsn;

   initial begin
      clk = 1'b0;
      forever
	#100 clk = ~clk;
   end

   initial begin
      rsn = 1'b0;
      repeat(10) @(posedge clk);
      rsn = 1'b1;
   end

   // Write master IFs
   axi_addr_inf #(
      .ID_WIDTH     (sys::axi_port_32x32x4::AXI_ID_WIDTH),
      .ADDR_WIDTH   (sys::axi_port_32x32x4::AXI_ADDR_WIDTH)
   ) axi_mstr_waddr_inf[number_of_masters-1:0](
      .clk(clk),
      .resetn(rsn)
   );
   axi_data_inf #(
      .ID_WIDTH     (sys::axi_port_32x32x4::AXI_ID_WIDTH),
      .DATA_WIDTH   (sys::axi_port_32x32x4::AXI_DATA_WIDTH),
      .STRB_WIDTH   (sys::axi_port_32x32x4::AXI_STRB_WIDTH)
   ) axi_mstr_wdata_inf[number_of_masters-1:0](
      .clk(clk),
      .resetn(rsn)
   );
   axi_resp_inf #(
      .ID_WIDTH     (sys::axi_port_32x32x4::AXI_ID_WIDTH)
   ) axi_mstr_resp_inf[number_of_masters-1:0](
      .clk(clk),
      .resetn(rsn)
   );

   // Read master IFs
   axi_addr_inf #(
      .ID_WIDTH     (sys::axi_port_32x32x4::AXI_ID_WIDTH),
      .ADDR_WIDTH   (sys::axi_port_32x32x4::AXI_ADDR_WIDTH)
   ) axi_mstr_raddr_inf[number_of_masters-1:0](
      .clk(clk),
      .resetn(rsn)
   );
   axi_data_inf #(
      .ID_WIDTH     (sys::axi_port_32x32x4::AXI_ID_WIDTH),
      .DATA_WIDTH   (sys::axi_port_32x32x4::AXI_DATA_WIDTH),
      .STRB_WIDTH   (sys::axi_port_32x32x4::AXI_STRB_WIDTH)
   ) axi_mstr_rdata_inf[number_of_masters-1:0](
      .clk(clk),
      .resetn(rsn)
   );

   // Write slave IFs
   axi_addr_inf #( 
      .ID_WIDTH     (sys::axi_port_32x32x4::AXI_ID_WIDTH),
      .ADDR_WIDTH   (sys::axi_port_32x32x4::AXI_ADDR_WIDTH)
   )axi_slv_waddr_inf[number_of_slaves-1:0](.clk(clk), .resetn(rsn));
   axi_data_inf #(
      .ID_WIDTH     (sys::axi_port_32x32x4::AXI_ID_WIDTH),
      .DATA_WIDTH   (sys::axi_port_32x32x4::AXI_DATA_WIDTH),
      .STRB_WIDTH   (sys::axi_port_32x32x4::AXI_STRB_WIDTH)
     ) axi_slv_wdata_inf[number_of_slaves-1:0](.clk(clk), .resetn(rsn));
   axi_resp_inf #(
      .ID_WIDTH     (sys::axi_port_32x32x4::AXI_ID_WIDTH)
   ) axi_slv_resp_inf[number_of_slaves-1:0](.clk(clk), .resetn(rsn));
   
   // READ slave IFs
   axi_addr_inf #(
      .ID_WIDTH     (sys::axi_port_32x32x4::AXI_ID_WIDTH),
      .ADDR_WIDTH   (sys::axi_port_32x32x4::AXI_ADDR_WIDTH)
   ) axi_slv_raddr_inf[number_of_slaves-1:0](.clk(clk), .resetn(rsn));

   axi_data_inf #(
      .ID_WIDTH     (sys::axi_port_32x32x4::AXI_ID_WIDTH),
      .DATA_WIDTH   (sys::axi_port_32x32x4::AXI_DATA_WIDTH),
      .STRB_WIDTH   (sys::axi_port_32x32x4::AXI_STRB_WIDTH)
   ) axi_slv_rdata_inf[number_of_slaves-1:0](.clk(clk),	.resetn(rsn));

   dut dut_inst(axi_mstr_waddr_inf,
		axi_mstr_raddr_inf,
		axi_slv_waddr_inf ,
		axi_slv_raddr_inf ,
		axi_mstr_wdata_inf,
		axi_mstr_rdata_inf,
		axi_slv_wdata_inf ,
		axi_slv_rdata_inf ,
		axi_mstr_resp_inf ,
		axi_slv_resp_inf  );

   string env_name = "axi_env";

   genvar i;
   generate
      for (i=0; i<number_of_masters; i++) begin
	 initial begin
	    uvm_config_db #(sys::axi_port_32x32x4::addr_if_t)::set(null, "uvm_test_top",
						                   $sformatf("mstr_agent_%0d.mstr_waddr_inf", i),
						                   axi_mstr_waddr_inf[i]);
	    uvm_config_db #(sys::axi_port_32x32x4::addr_if_t)::set(null, "uvm_test_top",
						                   $sformatf("mstr_agent_%0d.mstr_raddr_inf", i),
						                   axi_mstr_raddr_inf[i]);
	    uvm_config_db #(sys::axi_port_32x32x4::data_if_t)::set(null, "uvm_test_top",
						                   $sformatf("mstr_agent_%0d.mstr_wdata_inf", i),
						                   axi_mstr_wdata_inf[i]);
	    uvm_config_db #(sys::axi_port_32x32x4::data_if_t)::set(null, "uvm_test_top",
						                   $sformatf("mstr_agent_%0d.mstr_rdata_inf", i),
						                   axi_mstr_rdata_inf[i]);
	    uvm_config_db #(sys::axi_port_32x32x4::resp_if_t)::set(null, "uvm_test_top",
						                   $sformatf("mstr_agent_%0d.mstr_resp_inf", i),
						                   axi_mstr_resp_inf[i]);
	 end // initial begin
      end // for (i=0; i<number_of_masters; i++)
   endgenerate
   generate
      for (i=0; i<number_of_slaves; i++) begin
	 initial begin
	    uvm_config_db #(sys::axi_port_32x32x4::addr_if_t)::set(null, "uvm_test_top", 
						      $sformatf("slv_agent_%0d.slv_waddr_inf", i),
						      axi_slv_waddr_inf[i]);
	    uvm_config_db #(sys::axi_port_32x32x4::addr_if_t)::set(null, "uvm_test_top",
						      $sformatf("slv_agent_%0d.slv_raddr_inf", i),
						      axi_slv_raddr_inf[i]);
	    uvm_config_db #(sys::axi_port_32x32x4::data_if_t)::set(null, "uvm_test_top",
						      $sformatf("slv_agent_%0d.slv_wdata_inf", i),
						      axi_slv_wdata_inf[i]);
	    uvm_config_db #(sys::axi_port_32x32x4::data_if_t)::set(null, "uvm_test_top",
						      $sformatf("slv_agent_%0d.slv_rdata_inf", i),
						      axi_slv_rdata_inf[i]);
	    uvm_config_db #(sys::axi_port_32x32x4::resp_if_t)::set(null, "uvm_test_top",
						      $sformatf("slv_agent_%0d.slv_resp_inf", i),
						      axi_slv_resp_inf[i]);
	 end // initial begin
      end // for (i=0; i<number_of_slaves; i++)
   endgenerate

   initial begin
      // AXI Configurations
      uvm_config_db #(integer)::set(null, "", "number_of_masters", number_of_masters);
      uvm_config_db #(integer)::set(null, "", "number_of_slaves", number_of_slaves);
   end
   
   `include "sig_tests.svh"
   
   initial
     run_test();
   
endmodule // top
