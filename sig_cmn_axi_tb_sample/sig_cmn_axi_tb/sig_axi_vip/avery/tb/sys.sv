package sys;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import axi_pkg::*;

// `include "axi_item_seq.sv"
 `include "axi_params.sv"
//  `include "vsys.sv"
//
  //extend axi_params class and overwrite parameters 
  class axi_port_32x32x4 extends axi_params;
    parameter AXI_ADDR_WIDTH = 32;
    parameter AXI_DATA_WIDTH = 32;
    parameter AXI_STRB_WIDTH = AXI_DATA_WIDTH/8;
    parameter AXI_ID_WIDTH = 4;

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
     .AXI_RESP_WIDTH(AXI_RESP_WIDTH)
   ) axi_data_item_t;
 
   //Used by write response channel
   typedef axi_resp_item #(
     .AXI_ID_WIDTH(AXI_ID_WIDTH),
     .AXI_RESP_WIDTH(AXI_RESP_WIDTH),
     .AXI_USER_WIDTH(AXI_USER_WIDTH)
   ) axi_resp_item_t;

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
      .USER_WIDTH   (AXI_USER_WIDTH)
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

endpackage
