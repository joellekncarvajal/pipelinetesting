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
class axi_virtual_sequencer#(type T=axi_params) extends uvm_sequencer;
   `uvm_component_param_utils(axi_virtual_sequencer#(T))

   //typedef T::axi_addr_item_t axi_addr_item_type;
   //typedef T::axi_data_item_t axi_data_item_type;
   //typedef T::axi_resp_item_t axi_resp_item_type;
   typedef axi_data_item#(
     .AXI_ID_WIDTH(T::AXI_ID_WIDTH),
     .AXI_DATA_WIDTH(T::AXI_DATA_WIDTH),
     .AXI_STRB_WIDTH(T::AXI_STRB_WIDTH),
     .AXI_RESP_WIDTH(T::AXI_RESP_WIDTH),
     .AXI_USER_WIDTH(T::AXI_USER_WIDTH)
   ) axi_data_item_type;


   typedef axi_addr_item # (
     .AXI_ID_WIDTH     (T::AXI_ID_WIDTH), 
     .AXI_ADDR_WIDTH   (T::AXI_ADDR_WIDTH),
     .AXI_LEN_WIDTH    (T::AXI_LEN_WIDTH),
     .AXI_SIZE_WIDTH   (T::AXI_SIZE_WIDTH),
     .AXI_BURST_WIDTH  (T::AXI_BURST_WIDTH),
     .AXI_LOCK_WIDTH   (T::AXI_LOCK_WIDTH),
     .AXI_CACHE_WIDTH  (T::AXI_CACHE_WIDTH),
     .AXI_PROT_WIDTH   (T::AXI_PROT_WIDTH),
     .AXI_QOS_WIDTH    (T::AXI_QOS_WIDTH),
     .AXI_REGION_WIDTH (T::AXI_REGION_WIDTH),
     .AXI_USER_WIDTH   (T::AXI_USER_WIDTH)
   ) axi_addr_item_type;

   typedef axi_resp_item #(
     .AXI_ID_WIDTH (T::AXI_ID_WIDTH),
     .AXI_RESP_WIDTH (T::AXI_RESP_WIDTH),
     .AXI_USER_WIDTH (T::AXI_USER_WIDTH)
   ) axi_resp_item_type;


   //handles
   uvm_sequencer#(axi_addr_item_type) waddr_sqr;
   uvm_sequencer#(axi_addr_item_type) raddr_sqr;
   uvm_sequencer#(axi_data_item_type) wdata_sqr;
   uvm_sequencer#(axi_data_item_type) rdata_sqr;
   uvm_sequencer#(axi_resp_item_type) bresp_sqr;

   //Status variables
   int unsigned pending_waddr_cnt = 0;
   int unsigned pending_wdata_cnt = 0;
   int unsigned pending_wresp_cnt = 0;
   int unsigned pending_raddr_cnt = 0;
   int unsigned pending_rdata_cnt = 0;

   function new (string name="axi_virtual_sequencer", uvm_component parent=null);
      super.new(name, parent);
   endfunction // new

   function bit is_busy();
      string status;
      is_busy = pending_waddr_cnt || pending_wdata_cnt || pending_wresp_cnt || pending_raddr_cnt || pending_rdata_cnt;
      status = is_busy ? "BUSY" : "IDLE";
//      $display("%0t: %0s is %0s", $time, get_full_name(), status);
   endfunction

endclass
