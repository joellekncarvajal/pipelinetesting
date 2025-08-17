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
`include "axi_hdr.svh"
import axi_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

interface axi_if_pramed #(type T=axi_params)(
   input logic clk,
   input logic resetn
);

   wire                    AxREADY;
   wire                    AxVALID;
   wire [T::AXI_ID_WIDTH-1:0]     AxID;
   wire [T::AXI_ADDR_WIDTH-1:0]   AxADDR;
   wire [T::AXI_LEN_WIDTH-1:0]    AxLEN;   // number of beats per burst
   wire [T::AXI_SIZE_WIDTH-1:0]   AxSIZE;  // size of burst beat
   wire [T::AXI_BURST_WIDTH-1:0]  AxBURST; // burst type
   wire [T::AXI_LOCK_WIDTH-1:0]   AxLOCK;
   wire [T::AXI_CACHE_WIDTH-1:0]  AxCACHE;
   wire [T::AXI_PROT_WIDTH-1:0]   AxPROT;
   wire [T::AXI_QOS_WIDTH-1:0]    AxQOS;
   wire [T::AXI_REGION_WIDTH-1:0] AxREGION;
   wire [T::AXI_USER_WIDTH-1:0]   AxUSER;


endinterface

interface axi_addr_inf (
   input logic clk,
   input logic resetn
);
   parameter ID_WIDTH     = `AXI_ID_WIDTH; 
   parameter ADDR_WIDTH   = `AXI_ADDR_WIDTH; 
   parameter LEN_WIDTH    = `AXI_LEN_WIDTH;
   parameter SIZE_WIDTH   = `AXI_SIZE_WIDTH;
   parameter BURST_WIDTH  = `AXI_BURST_WIDTH;
   parameter LOCK_WIDTH   = `AXI_LOCK_WIDTH;
   parameter CACHE_WIDTH  = `AXI_CACHE_WIDTH;
   parameter PROT_WIDTH   = `AXI_PROT_WIDTH;
   parameter QOS_WIDTH    = `AXI_QOS_WIDTH;
   parameter REGION_WIDTH = `AXI_REGION_WIDTH;
   parameter USER_WIDTH   = `AXI_USER_WIDTH;
   parameter GPIO_WIDTH   = `AXI_GPIO_WIDTH;

   wire                    AxREADY;
   wire                    AxVALID;
   wire [ID_WIDTH-1:0]     AxID;
   wire [ADDR_WIDTH-1:0]   AxADDR;
   wire [LEN_WIDTH-1:0]    AxLEN;   // number of beats per burst
   wire [SIZE_WIDTH-1:0]   AxSIZE;  // size of burst beat
   wire [BURST_WIDTH-1:0]  AxBURST; // burst type
   wire [LOCK_WIDTH-1:0]   AxLOCK;
   wire [CACHE_WIDTH-1:0]  AxCACHE;
   wire [PROT_WIDTH-1:0]   AxPROT;
   wire [QOS_WIDTH-1:0]    AxQOS;
   wire [REGION_WIDTH-1:0] AxREGION;
   wire [USER_WIDTH-1:0]   AxUSER;
   wire [GPIO_WIDTH-1:0]   AxGPIO;

   bit disable_assert = 0;
   string if_name = "axi_addr_if";
   bit[31:0] total_bytes;

   assign total_bytes = (AxVALID == 1) ? (AxLEN+1) * (1<<AxSIZE) : '0;

   // source of requests (i.e. write and read masters)
   clocking src_drv_cb @(posedge clk);
      default input #1 output#1;
      input  resetn;
      input  AxREADY;
      output AxVALID;
      output AxID;
      output AxADDR;
      output AxLEN;   
      output AxSIZE;  
      output AxBURST; 
      output AxLOCK;
      output AxCACHE;
      output AxPROT;
      output AxQOS;
      output AxREGION;
      output AxUSER;
      output AxGPIO;
     endclocking

   // destination of requests (i.e. write and read slaves)
   clocking dst_drv_cb @(posedge clk);
      default input #1 output#1;
      input  resetn;
      output AxREADY;
      input  AxVALID;
      input  AxID;
      input  AxADDR;
      input  AxLEN;
      input  AxSIZE;
      input  AxBURST;
      input  AxLOCK;
      input  AxCACHE;
      input  AxPROT;
      input  AxQOS;
      input  AxREGION;
      input  AxUSER;
      input  AxGPIO;
   endclocking

   //monitor; purely passive
   clocking mon_cb @(posedge clk);
      default input #1 output#1;
      input  resetn;
      input  AxREADY;
      input  AxVALID;
      input  AxID;
      input  AxADDR;
      input  AxLEN;
      input  AxSIZE;
      input  AxBURST;
      input  AxLOCK;
      input  AxCACHE;
      input  AxPROT;
      input  AxQOS;
      input  AxREGION;
      input  AxUSER;
      input  AxGPIO;
   endclocking

   axvalid_x_check: assert property( 
     @(posedge clk) disable iff (!resetn || disable_assert)
     (resetn) |-> (!$isunknown(AxVALID))
   ) else
     `uvm_error({if_name,"_","axvalid_x_check"}, "AxVALID signal is unknown value");

   addr_ch_x_check: assert property( 
     @(posedge clk) disable iff (!resetn || disable_assert)
     (AxVALID) |-> (!$isunknown(AxADDR) && !$isunknown(AxID) && !$isunknown(AxLEN) && !$isunknown(AxSIZE) && !$isunknown(AxBURST) && !$isunknown(AxCACHE) && !$isunknown(AxPROT) && !$isunknown(AxREADY) && !$isunknown(AxQOS) && !$isunknown(AxREGION) && !$isunknown(AxUSER))
   ) else
     `uvm_error({if_name,"_","addr_ch_x_check"},"A3.2.1 : A signal in AXI address channel is unknown while AVALID is 1");
 
   axvalid_negation_check: assert property (
     @(posedge clk) disable iff (!resetn || disable_assert)
     (!$isunknown($past(AxREADY,1)) && $fell(AxVALID) && !$isunknown($past(AxVALID,1)) && $past(resetn,1)) |-> ($past(AxREADY,1))
   ) else
     `uvm_error({if_name,"_","axvalid_negation_check"},"A3.2.1 : AxVALID negated without AxVALID-AxREADY handshake");
 
   axvalid_reset_check: assert property(
     @(posedge clk) disable iff (disable_assert)
     (!resetn) |-> ##1 (AxVALID == 0)
   ) else
     `uvm_error({if_name,"_","axvalid_reset_check"},"A3.1.2 : AxVALID is not zero while reset is asserted");

   axid_retention_check: assert property (
     @(posedge clk) disable iff (!resetn || disable_assert)
     (AxID != $past(AxID,1)) && $past(AxVALID,1) |-> $past(AxREADY,1)
   ) else begin
     `uvm_error({if_name,"_","axid_retention_check"},"A3.2.1 : AxID should not change value before AxVALID-AxREADY handshake occurs");
   end

   axaddr_retention_check: assert property (
     @(posedge clk) disable iff (!resetn || disable_assert)
     (AxADDR != $past(AxADDR,1)) && $past(AxVALID,1) |-> $past(AxREADY,1)
   ) else begin
     `uvm_error({if_name,"_","axaddr_retention_check"},"A3.2.1: AxADDR should not change value before AxVALID-AxREADY handshake occurs");
   end

   axlen_retention_check: assert property (
     @(posedge clk) disable iff (!resetn || disable_assert)
     (AxLEN != $past(AxLEN,1)) && $past(AxVALID,1) |-> $past(AxREADY,1)
   ) else begin
     `uvm_error({if_name,"_","axlen_retention_check"},"A3.2.1: AxLEN should not change value before AxVALID-AxREADY handshake occurs");
   end

   axsize_retention_check: assert property (
     @(posedge clk) disable iff (!resetn || disable_assert)
     (AxSIZE != $past(AxSIZE,1)) && $past(AxVALID,1) |-> $past(AxREADY,1)
   ) else begin
     `uvm_error({if_name,"_","axsize_retention_check"},"A3.2.1: AxSIZE should not change value before AxVALID-AxREADY handshake occurs");
   end

   axburst_retention_check: assert property (
     @(posedge clk) disable iff (!resetn || disable_assert)
     (AxBURST != $past(AxBURST,1)) && $past(AxVALID,1) |-> $past(AxREADY,1)
   ) else begin
     `uvm_error({if_name,"_","axburst_retention_check"},"A3.2.1: AxBURST should not change value before AxVALID-AxREADY handshake occurs");
   end

   axlock_retention_check: assert property (
     @(posedge clk) disable iff (!resetn || disable_assert)
     (AxLOCK != $past(AxLOCK,1)) && $past(AxVALID,1) |-> $past(AxREADY,1)
   ) else begin
     `uvm_error({if_name,"_","axlock_retention_check"},"A3.2.1: AxLOCK should not change value before AxVALID-AxREADY handshake occurs");
   end

   axcache_retention_check: assert property (
     @(posedge clk) disable iff (!resetn || disable_assert)
     (AxCACHE != $past(AxCACHE,1)) && $past(AxVALID,1) |-> $past(AxREADY,1)
   ) else begin
     `uvm_error({if_name,"_","axcache_retention_check"},"A3.2.1: AxCACHE should not change value before AxVALID-AxREADY handshake occurs");
   end

   axprot_retention_check: assert property (
     @(posedge clk) disable iff (!resetn || disable_assert)
     (AxPROT != $past(AxPROT,1)) && $past(AxVALID,1) |-> $past(AxREADY,1)
   ) else begin
     `uvm_error({if_name,"_","axprot_retention_check"},"A3.2.1: AxPROT should not change value before AxVALID-AxREADY handshake occurs");
   end

   axqos_retention_check: assert property (
     @(posedge clk) disable iff (!resetn || disable_assert)
     (AxQOS != $past(AxQOS,1)) && $past(AxVALID,1) |-> $past(AxREADY,1)
   ) else begin
     `uvm_error({if_name,"_","axqos_retention_check"},"A3.2.1: AxQOS should not change value before AxVALID-AxREADY handshake occurs");
   end

   axregion_retention_check: assert property (
     @(posedge clk) disable iff (!resetn || disable_assert)
     (AxREGION != $past(AxREGION,1)) && $past(AxVALID,1) |-> $past(AxREADY,1)
   ) else begin
     `uvm_error({if_name,"_","axregion_retention_check"},"A3.2.1: AxREGION should not change value before AxVALID-AxREADY handshake occurs")
   end

   axuser_retention_check: assert property (
     @(posedge clk) disable iff (!resetn || disable_assert)
     (AxUSER != $past(AxUSER,1)) && $past(AxVALID,1) |-> $past(AxREADY,1)
   ) else begin
     `uvm_error({if_name,"_","axuser_retention_check"},"A3.2.1: AxUSER should not change value before AxVALID-AxREADY handshake occurs")
   end

   exclusive_total_bytes_check : assert property (
     @(posedge clk) disable iff (!resetn || disable_assert)
     (AxVALID == 1 && AxLOCK == 1) |-> (total_bytes <= 128) && ((total_bytes & (total_bytes -1)) == '0)
   ) else begin
     `uvm_error({if_name,"_","exclusive_total_bytes_check"},"A7.2.4: Total bytes during exclusive access should be power of 2 and less than or equal to 128")
   end

   exclusive_addr_alignment_check : assert property (
     @(posedge clk) disable iff (!resetn || disable_assert)
     (AxVALID == 1 && AxLOCK == 1) |-> (AxADDR % total_bytes == '0)
   ) else begin
     `uvm_error({if_name,"_","exclusive_addr_alignment_check"},"A7.2.4: Address should be aligned to total bytes during exclusive access")
   end

   exclusive_len_check : assert property (
     @(posedge clk) disable iff (!resetn || disable_assert)
     (AxVALID == 1 && AxLOCK == 1) |-> (AxLEN <= 15)
   ) else begin
     `uvm_error({if_name,"_","exclusive_lent_check"},"A7.2.4: Burst length should be less than or equal to 16 (0x15) beats during exclusive access")
   end



endinterface // axi_addr_inf

interface axi_data_inf (
   input clk,
   input resetn
);
   parameter ID_WIDTH     = `AXI_ID_WIDTH;
   parameter DATA_WIDTH   = `AXI_DATA_WIDTH;
   parameter STRB_WIDTH   = `AXI_STRB_WIDTH;
   parameter USER_WIDTH   = `AXI_USER_WIDTH;
   parameter RESP_WIDTH   = `AXI_RESP_WIDTH;

   wire                      xREADY;
   wire                      xVALID;
   wire [ID_WIDTH-1:0]       xID;
   wire [DATA_WIDTH-1:0]     xDATA;
   wire [STRB_WIDTH-1:0]     xSTRB;
   wire                      xLAST;
   wire [RESP_WIDTH-1:0]     xRESP;
   wire [USER_WIDTH-1:0]     xUSER; 

   bit disable_assert = 0;
   string if_name = "axi_data_if";

   // source of data (i.e. write master, read slave)
   clocking src_drv_cb @(posedge clk);
      default input #1 output#1;
      input  resetn;
      input  xREADY;
      output xVALID;
      output xID;
      output xDATA;
      output xSTRB; //for write only
      output xLAST;
      output xUSER;
      output xRESP; //for read only
   endclocking

   // destination of data (i.e. write slave, read master)
   clocking dst_drv_cb @(posedge clk);
      default input #1 output#1;
      input  resetn;
      output xREADY;
      input  xVALID;
      input  xID;
      input  xDATA;
      input  xSTRB; // for write only
      input  xLAST;
      input  xUSER;
      input  xRESP; // for read only
   endclocking

   //monitor, purely passive
   clocking mon_cb @(posedge clk);
      default input #1 output#1;
      input  resetn;
      input  xREADY;
      input  xVALID;
      input  xID;
      input  xDATA;
      input  xSTRB;
      input  xLAST;
      input  xUSER;
      input  xRESP; // for read only
   endclocking

   xvalid_x_check: assert property( 
     @(posedge clk) disable iff (!resetn || disable_assert)
     (resetn) |-> (!$isunknown(xVALID))
   ) else
     `uvm_error({if_name,"_","xvalid_x_check"}, "xVALID signal is unknown value");

   //xdata_ch_x_check: assert property( 
   //  @(posedge clk) disable iff (!resetn || disable_assert)
   //  (xVALID) |-> (!$isunknown(xREADY) && !$isunknown(xID) && !$isunknown(xRESP) && !$isunknown(xUSER) && !$isunknown(xDATA) && !$isunknown(xSTRB))
   //) else
   //  `uvm_error({if_name,"_","bresp_ch_x_check"},"A3.2.1 : A signal in AXI data channel is unknown while xVALID is 1");

   xvalid_negation_check: assert property (
     @(posedge clk) disable iff (!resetn || disable_assert)
     (!$isunknown($past(xREADY,1)) && $fell(xVALID) && !$isunknown($past(xVALID,1)) && $past(resetn,1)) |-> ($past(xREADY,1))
   ) else
     `uvm_error({if_name,"_","xvalid_negation_check"},"A3.2.1 : xVALID negated without xVALID-xREADY handshake");

   xdata_ch_x_check: assert property( 
     @(posedge clk) disable iff (!resetn || disable_assert)
     (xVALID) |-> (!$isunknown(xREADY) && !$isunknown(xID) && !$isunknown(xRESP) && !$isunknown(xUSER) && !$isunknown(xDATA) && !$isunknown(xSTRB))
   ) else
     `uvm_error({if_name,"_","xdata_ch_x_check"},"A3.2.1 : A signal in AXI data channel is unknown while xVALID is 1");

   xdata_retention_check: assert property (
     @(posedge clk) disable iff (!resetn || disable_assert)
     (xDATA != $past(xDATA,1)) && $past(xVALID,1) && $past(resetn,1) |-> $past(xREADY,1)
   ) else begin
     `uvm_error({if_name,"_","xdata_retention_check"},"A3.2.1: xDATA should not change value before xVALID-xREADY handshake occurs");
   end

   xid_retention_check: assert property (
     @(posedge clk) disable iff (!resetn || disable_assert)
     (xID != $past(xID,1)) && $past(xVALID,1) && $past(resetn,1) |-> $past(xREADY,1)
   ) else begin
     `uvm_error({if_name,"_","xid_retention_check"},"A3.2.1: xID should not change value before xVALID-xREADY handshake occurs");
   end

   xstrb_retention_check: assert property (
     @(posedge clk) disable iff (!resetn || disable_assert)
     (xSTRB != $past(xSTRB,1)) && $past(xVALID,1) && $past(resetn,1) |-> $past(xREADY,1)
   ) else begin
     `uvm_error({if_name,"_","xstrb_retention_check"},"A3.2.1: xSTRB should not change value before xVALID-xREADY handshake occurs");
   end

   xlast_retention_check: assert property (
     @(posedge clk) disable iff (!resetn || disable_assert)
     (xLAST != $past(xLAST,1)) && $past(xVALID,1) && $past(resetn,1) |-> $past(xREADY,1)
   ) else begin
     `uvm_error({if_name,"_","xlast_retention_check"},"A3.2.1: xLAST should not change value before xVALID-xREADY handshake occurs");
   end

   xresp_retention_check: assert property (
     @(posedge clk) disable iff (!resetn || disable_assert)
     (xRESP != $past(xRESP,1)) && $past(xVALID,1) && $past(resetn,1) |-> $past(xREADY,1)
   ) else begin
     `uvm_error({if_name,"_","xresp_retention_check"},"A3.2.1: xRESP should not change value before xVALID-xREADY handshake occurs");
   end

   xuser_retention_check: assert property (
     @(posedge clk) disable iff (!resetn || disable_assert)
     (xUSER != $past(xUSER,1)) && $past(xVALID,1) && $past(resetn,1) |-> $past(xREADY,1)
   ) else begin
     `uvm_error({if_name,"_","xuser_retention_check"},"A3.2.1: xUSER should not change value before xVALID-xREADY handshake occurs");
   end

endinterface // axi_data_inf

interface axi_resp_inf 
   (input clk,
    input resetn);

   parameter ID_WIDTH     = `AXI_ID_WIDTH; 
   parameter RESP_WIDTH   = `AXI_RESP_WIDTH;
   parameter USER_WIDTH   = `AXI_USER_WIDTH;

   wire BVALID;
   wire BREADY;
   wire [RESP_WIDTH-1:0] BRESP;
   wire [ID_WIDTH-1:0]   BID;
   wire [USER_WIDTH-1:0] BUSER;

   bit disable_assert = 0;
   string if_name = "axi_resp_if";

   // source of write resp (i.e. write slave)
   clocking src_drv_cb @(posedge clk);
      default input #1 output#1;
      input  resetn;
      input  BREADY;
      output BVALID;
      output BRESP;
      output BID;
      output BUSER;
   endclocking

   // destination of write resp (i.e. write master)
   clocking dst_drv_cb @(posedge clk);
      default input #1 output#1;
      input   resetn;
      output  BREADY;
      input   BVALID;
      input   BRESP;
      input   BID;
      input   BUSER;
   endclocking

   //monitor; purely passive
   clocking mon_cb @(posedge clk);
      default input #1 output#1;
      input  resetn;
      input  BREADY;
      input  BVALID;
      input  BRESP;
      input  BID;
      input  BUSER;
   endclocking

   bvalid_x_check: assert property( 
     @(posedge clk) disable iff (!resetn || disable_assert)
     (resetn) |-> (!$isunknown(BVALID))
   ) else
     `uvm_error({if_name,"_","bvalid_x_check"}, "BVALID signal is unknown value");

   bresp_ch_x_check: assert property( 
     @(posedge clk) disable iff (!resetn || disable_assert)
     (BVALID) |-> (!$isunknown(BREADY) && !$isunknown(BID) && !$isunknown(BRESP) && !$isunknown(BUSER))
   ) else
     `uvm_error({if_name,"_","bresp_ch_x_check"},"A3.2.1 : A signal in AXI WRITE response channel is unknown while BVALID is 1");
 
   bvalid_negation_check: assert property (
     @(posedge clk) disable iff (!resetn || disable_assert)
     (!$isunknown($past(BREADY,1)) && $fell(BVALID) && !$isunknown($past(BVALID,1)) && $past(resetn,1)) |-> ($past(BREADY,1))
   ) else
     `uvm_error({if_name,"_","bvalid_negation_check"},"A3.2.1 : BVALID negated without BVALID-BREADY handshake");
 
   bvalid_reset_check: assert property(
     @(posedge clk) disable iff (disable_assert)
     (!resetn) |-> ##1 (BVALID == 0)
   ) else
     `uvm_error({if_name,"_","bvalid_reset_check"},"A3.1.2 : BVALID is not zero while reset is asserted");
 
   bresp_retention_check: assert property (
     @(posedge clk) disable iff (!resetn || disable_assert)
     (BRESP != $past(BRESP,1)) && $past(BVALID,1) |-> $past(BREADY,1)
   ) else begin
     `uvm_error({if_name,"_","bresp_retention_check"},"A3.2.1 : BRESP should not change value before BVALID-BREADY handshake occurs");
   end

   bid_retention_check: assert property (
     @(posedge clk) disable iff (!resetn || disable_assert)
     (BID != $past(BID,1)) && $past(BVALID,1) |-> $past(BREADY,1)
   ) else begin
     `uvm_error({if_name,"_","bid_retention_check"},"A3.2.1 : BID should not change value before BVALID-BREADY handshake occurs");
   end

   buser_retention_check: assert property (
     @(posedge clk) disable iff (!resetn || disable_assert)
     (BUSER != $past(BUSER,1)) && $past(BVALID,1) |-> $past(BREADY,1)
   ) else begin
     `uvm_error({if_name,"_","buser_retention_check"},"A3.2.1 : BUSER should not change value before BVALID-BREADY handshake occurs");
   end

endinterface // axi_resp_inf


					

					   
