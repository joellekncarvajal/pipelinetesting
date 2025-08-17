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
//`include "axi_item_seq.sv"

virtual class axi_params;
  parameter AXI_ID_WIDTH     = `AXI_ID_WIDTH; 
  parameter AXI_ADDR_WIDTH   = `AXI_ADDR_WIDTH; 
  parameter AXI_LEN_WIDTH    = `AXI_LEN_WIDTH;
  parameter AXI_SIZE_WIDTH   = `AXI_SIZE_WIDTH;
  parameter AXI_BURST_WIDTH  = `AXI_BURST_WIDTH;
  parameter AXI_LOCK_WIDTH   = `AXI_LOCK_WIDTH;
  parameter AXI_CACHE_WIDTH  = `AXI_CACHE_WIDTH;
  parameter AXI_PROT_WIDTH   = `AXI_PROT_WIDTH;
  parameter AXI_QOS_WIDTH    = `AXI_QOS_WIDTH;
  parameter AXI_REGION_WIDTH = `AXI_REGION_WIDTH;
  parameter AXI_USER_WIDTH   = `AXI_USER_WIDTH;
  parameter AXI_DATA_WIDTH   = `AXI_DATA_WIDTH;
  parameter AXI_STRB_WIDTH   = `AXI_STRB_WIDTH;
  parameter AXI_RESP_WIDTH   = `AXI_RESP_WIDTH;
  parameter READY_TIMEOUT    = 1000;
  parameter AXI_WR_ID_WIDTH  = AXI_ID_WIDTH;
  parameter AXI_RD_ID_WIDTH  = AXI_ID_WIDTH;
  parameter AXI_GPIO_WIDTH   = `AXI_GPIO_WIDTH;

  function void print_params();
     $display("AXI_ID_WIDTH     = %0d", AXI_ID_WIDTH);  
     $display("AXI_ADDR_WIDTH   = %0d", AXI_ADDR_WIDTH);  
     $display("AXI_LEN_WIDTH    = %0d", AXI_LEN_WIDTH);  
     $display("AXI_SIZE_WIDTH   = %0d", AXI_SIZE_WIDTH);  
     $display("AXI_BURST_WIDTH  = %0d", AXI_BURST_WIDTH);  
     $display("AXI_LOCK_WIDTH   = %0d", AXI_LOCK_WIDTH);  
     $display("AXI_CACHE_WIDTH  = %0d", AXI_CACHE_WIDTH);  
     $display("AXI_PROT_WIDTH   = %0d", AXI_PROT_WIDTH);  
     $display("AXI_QOS_WIDTH    = %0d", AXI_QOS_WIDTH);  
     $display("AXI_REGION_WIDTH = %0d", AXI_REGION_WIDTH);  
     $display("AXI_USER_WIDTH   = %0d", AXI_USER_WIDTH);  
     $display("AXI_DATA_WIDTH   = %0d", AXI_DATA_WIDTH);  
     $display("AXI_STRB_WIDTH   = %0d", AXI_STRB_WIDTH);  
     $display("AXI_RESP_WIDTH   = %0d", AXI_RESP_WIDTH);  
  endfunction

  //Used by write and read address channels
  typedef axi_addr_item #(
    .AXI_ID_WIDTH(AXI_ID_WIDTH),
    .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
    .AXI_LEN_WIDTH(AXI_LEN_WIDTH),
    .AXI_SIZE_WIDTH(AXI_SIZE_WIDTH),
    .AXI_BURST_WIDTH(AXI_BURST_WIDTH),
    .AXI_LOCK_WIDTH(AXI_LOCK_WIDTH),
    .AXI_CACHE_WIDTH(AXI_CACHE_WIDTH),
    .AXI_PROT_WIDTH(AXI_PROT_WIDTH),
    .AXI_QOS_WIDTH(AXI_QOS_WIDTH),
    .AXI_REGION_WIDTH(AXI_REGION_WIDTH),
    .AXI_USER_WIDTH(AXI_USER_WIDTH)
  ) axi_addr_item_t;

  //Used by write and read data channels
  typedef axi_data_item #(
    .AXI_ID_WIDTH(AXI_ID_WIDTH),
    .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
    .AXI_STRB_WIDTH(AXI_STRB_WIDTH),
    .AXI_RESP_WIDTH(AXI_RESP_WIDTH),
    .AXI_USER_WIDTH(AXI_USER_WIDTH)
  ) axi_data_item_t;

  //Used by write response channel
  typedef axi_resp_item #(
    .AXI_ID_WIDTH(AXI_ID_WIDTH),
    .AXI_RESP_WIDTH(AXI_RESP_WIDTH),
    .AXI_USER_WIDTH(AXI_USER_WIDTH)
  ) axi_resp_item_t;

  //Complete axi seq_item
  //Used by axi_model
  typedef axi_item #(
    .AXI_ID_WIDTH(AXI_ID_WIDTH),
    .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
    .AXI_LEN_WIDTH(AXI_LEN_WIDTH),
    .AXI_SIZE_WIDTH(AXI_SIZE_WIDTH),
    .AXI_BURST_WIDTH(AXI_BURST_WIDTH),
    .AXI_LOCK_WIDTH(AXI_LOCK_WIDTH),
    .AXI_CACHE_WIDTH(AXI_CACHE_WIDTH),
    .AXI_PROT_WIDTH(AXI_PROT_WIDTH),
    .AXI_QOS_WIDTH(AXI_QOS_WIDTH),
    .AXI_REGION_WIDTH(AXI_REGION_WIDTH),
    .AXI_USER_WIDTH(AXI_USER_WIDTH),
    .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
    .AXI_STRB_WIDTH(AXI_STRB_WIDTH),
    .AXI_RESP_WIDTH(AXI_RESP_WIDTH)
  ) axi_item_t;

  typedef virtual axi_addr_inf #( 
    .ID_WIDTH     (AXI_ID_WIDTH),
    .ADDR_WIDTH   (AXI_ADDR_WIDTH),
    .LEN_WIDTH    (AXI_LEN_WIDTH),
    .SIZE_WIDTH   (AXI_SIZE_WIDTH),
    .BURST_WIDTH  (AXI_BURST_WIDTH),
    .LOCK_WIDTH   (AXI_LOCK_WIDTH),
    .CACHE_WIDTH  (AXI_CACHE_WIDTH),
    .PROT_WIDTH   (AXI_PROT_WIDTH),
    .QOS_WIDTH    (AXI_QOS_WIDTH),
    .REGION_WIDTH (AXI_REGION_WIDTH),
    .USER_WIDTH   (AXI_USER_WIDTH),
    .GPIO_WIDTH   (AXI_GPIO_WIDTH)
  ) addr_if_t;

  typedef virtual axi_data_inf #(
    .ID_WIDTH     (AXI_ID_WIDTH),
    .DATA_WIDTH   (AXI_DATA_WIDTH), 
    .STRB_WIDTH   (AXI_STRB_WIDTH),
    .USER_WIDTH   (AXI_USER_WIDTH),
    .RESP_WIDTH   (AXI_RESP_WIDTH)
  ) data_if_t;

  typedef virtual axi_resp_inf #(
    .ID_WIDTH     (AXI_ID_WIDTH),
    .RESP_WIDTH   (AXI_RESP_WIDTH),
    .USER_WIDTH   (AXI_USER_WIDTH)
  ) resp_if_t;

endclass

