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
module axi_assertions (
   axi_addr_inf waddr,
   axi_data_inf wdata,
   axi_resp_inf bresp,
   axi_addr_inf raddr,
   axi_data_inf rdata
);
   `protect //begin protected region
   import uvm_pkg::*;
`include "uvm_macros.svh"

bit disable_assert = 0;
string if_name = "axi_if";

  waddr_ch_x_check: assert property(
    @(posedge waddr.clk) disable iff (!waddr.resetn || disable_assert)
    (waddr.AxVALID) |-> (!$isunknown(waddr.AxADDR) && !$isunknown(waddr.AxID) && !$isunknown(waddr.AxLEN) && !$isunknown(waddr.AxSIZE) && !$isunknown(waddr.AxBURST) && !$isunknown(waddr.AxCACHE) && !$isunknown(waddr.AxPROT) && !$isunknown(waddr.AxREADY) && !$isunknown(waddr.AxQOS) && !$isunknown(waddr.AxREGION) && !$isunknown(waddr.AxUSER))
  ) else
    `uvm_error({if_name,"_","addr_ch_x_check"},"A3.2.1 : A signal in AXI WRITE address channel is unknown while AWVALID is 1");

  raddr_ch_x_check: assert property(
    @(posedge raddr.clk) disable iff (!raddr.resetn || disable_assert)
    (raddr.AxVALID) |-> (!$isunknown(raddr.AxADDR) && !$isunknown(raddr.AxID) && !$isunknown(raddr.AxLEN) && !$isunknown(raddr.AxSIZE) && !$isunknown(raddr.AxBURST) && !$isunknown(raddr.AxCACHE) && !$isunknown(raddr.AxPROT) && !$isunknown(raddr.AxREADY) && !$isunknown(raddr.AxQOS) && !$isunknown(raddr.AxREGION) && !$isunknown(raddr.AxUSER))
  ) else
    `uvm_error({if_name,"_","addr_ch_x_check"},"A3.2.1 : A signal in AXI READ address channel is unknown while ARVALID is 1");

  wdata_ch_x_check: assert property(
    @(posedge wdata.clk) disable iff (!wdata.resetn || disable_assert)
    (wdata.xVALID) |-> (!$isunknown(wdata.xREADY) && !$isunknown(wdata.xID) && !$isunknown(wdata.xDATA) && !$isunknown(wdata.xSTRB) && !$isunknown(wdata.xLAST) && !$isunknown(wdata.xRESP) && !$isunknown(wdata.xUSER))
  ) else
    `uvm_error({if_name,"_","wdata_ch_x_check"},"A3.2.1 : A signal in AXI WRITE data channel is unknown while WVALID is 1");

  rdata_ch_x_check: assert property(
    @(posedge rdata.clk) disable iff (!rdata.resetn || disable_assert)
    (rdata.xVALID) |-> (!$isunknown(rdata.xREADY) && !$isunknown(rdata.xID) && !$isunknown(rdata.xDATA) && !$isunknown(rdata.xSTRB) && !$isunknown(rdata.xLAST) && !$isunknown(rdata.xRESP) && !$isunknown(rdata.xUSER))
  ) else
    `uvm_error({if_name,"_","rdata_ch_x_check"},"A3.2.1 : A signal in AXI READ data channel is unknown while RVALID is 1");

  bresp_ch_x_check: assert property(
    @(posedge bresp.clk) disable iff (!bresp.resetn || disable_assert)
    (bresp.BVALID) |-> (!$isunknown(bresp.BREADY) && !$isunknown(bresp.BID) && !$isunknown(bresp.BRESP) && !$isunknown(bresp.BUSER))
  ) else
    `uvm_error({if_name,"_","bresp_ch_x_check"},"A3.2.1 : A signal in AXI WRITE response channel is unknown while BVALID is 1");

  awvalid_negation_check: assert property (
    @(posedge waddr.clk) disable iff (!waddr.resetn || disable_assert)
    (!$isunknown($past(waddr.AxREADY,1)) && $fell(waddr.AxVALID)) |-> ($past(waddr.AxREADY,1))
  ) else 
    `uvm_error({if_name,"_","awvalid_negation_check"},"A3.2.1 : AWVALID negated without AWVALID-AWREADY handshake");

  wvalid_negation_check: assert property (
    @(posedge wdata.clk) disable iff (!wdata.resetn || disable_assert)
    (!$isunknown($past(wdata.xREADY,1)) && $fell(wdata.xVALID)) |-> ($past(wdata.xREADY,1))
  ) else 
    `uvm_error({if_name,"_","wvalid_negation_check"},"A3.2.1 : WVALID negated without WVALID-WREADY handshake");

  bvalid_negation_check: assert property (
    @(posedge bresp.clk) disable iff (!bresp.resetn || disable_assert)
    (!$isunknown($past(bresp.BREADY,1)) && $fell(bresp.BVALID)) |-> ($past(bresp.BREADY,1))
  ) else 
    `uvm_error({if_name,"_","bvalid_negation_check"},"A3.2.1 : BVALID negated without BVALID-BREADY handshake");

  arvalid_negation_check: assert property (
    @(posedge raddr.clk) disable iff (!raddr.resetn || disable_assert)
    (!$isunknown($past(raddr.AxREADY,1)) && $fell(raddr.AxVALID)) |-> ($past(raddr.AxREADY,1))
  ) else
    `uvm_error({if_name,"_","awvalid_negation_check"},"A3.2.1 : ARVALID negated without ARVALID-ARREADY handshake");

  rvalid_negation_check: assert property (
    @(posedge rdata.clk) disable iff (!rdata.resetn || disable_assert)
    (!$isunknown($past(rdata.xREADY,1)) && $fell(rdata.xVALID)) |-> ($past(rdata.xREADY,1))
  ) else
    `uvm_error({if_name,"_","rvalid_negation_check"},"A3.2.1 : RVALID negated without RVALID-RREADY handshake");

  awvalid_reset_check: assert property(
    @(posedge waddr.clk) disable iff (disable_assert)
    (!waddr.resetn) |-> ##1 (waddr.AxVALID == 0)
  ) else
    `uvm_error({if_name,"_","awvalid_reset_check"},"A3.1.2 : AWVALID is not zero while reset is asserted");

  arvalid_reset_check: assert property(
    @(posedge raddr.clk) disable iff (disable_assert)
    (!raddr.resetn) |-> ##1 (raddr.AxVALID == 0)
  ) else
    `uvm_error({if_name,"_","arvalid_reset_check"},"A3.1.2 : ARVALID is not zero while reset is asserted");

  wvalid_reset_check: assert property(
    @(posedge wdata.clk) disable iff (disable_assert)
    (!wdata.resetn) |-> ##1 (wdata.xVALID == 0)
  ) else
    `uvm_error({if_name,"_","wvalid_reset_check"},"A3.1.2 : WVALID is not zero while reset is asserted");

  rvalid_reset_check: assert property(
    @(posedge rdata.clk) disable iff (disable_assert)
    (!rdata.resetn) |-> ##1 (rdata.xVALID == 0)
  ) else
    `uvm_error({if_name,"_","rvalid_reset_check"},"A3.1.2 : RVALID is not zero while reset is asserted");

  bvalid_reset_check: assert property(
    @(posedge bresp.clk) disable iff (disable_assert)
    (!bresp.resetn) |-> ##1 (bresp.BVALID == 0)
  ) else
    `uvm_error({if_name,"_","bvalid_reset_check"},"A3.1.2 : BVALID is not zero while reset is asserted");
   `endprotect //end protected region
endmodule
