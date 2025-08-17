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
`uvm_analysis_imp_decl(_cov_imp)

class axi_coverage#(type T=axi_params) extends uvm_component;
   `uvm_component_param_utils(axi_coverage#(T))

   //typedef T::axi_addr_item_t axi_addr_item_type;
   //typedef T::axi_data_item_t axi_data_item_type;
   //typedef T::axi_resp_item_t axi_resp_item_type;
   //typedef T::axi_item_t      axi_item_type;
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

   typedef axi_item # (
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
     .AXI_USER_WIDTH   (T::AXI_USER_WIDTH),
     .AXI_DATA_WIDTH   (T::AXI_DATA_WIDTH),
     .AXI_STRB_WIDTH   (T::AXI_STRB_WIDTH),
     .AXI_RESP_WIDTH   (T::AXI_RESP_WIDTH)
   ) axi_item_type;


   uvm_analysis_imp_cov_imp #(axi_item_type, axi_coverage#(T)) cov_import;
   axi_item_type tr;
   axi_port_cfg cfg;
   int max_len;
   bit is_narrow, is_unaligned;
   RespCode rresp_cov;

   covergroup waddr_ch_cmn_cg;
      option.per_instance = 1;
      option.name = "waddr_ch_cmn_cg";
      AWADDR : coverpoint tr.addr {
         bins addr[5] = {[0:$]};
      }
      AWID : coverpoint tr.id {
         bins id[4] = {[0:$]};
      }
      AWSIZE : coverpoint tr.size {
         bins burst_size[] = {[0:$clog2(T::AXI_DATA_WIDTH/8)]};
      }
      AWBURST : coverpoint tr.burst {
         bins incr = {1};
         bins fixed = {0};
         bins wrap = {2};
         illegal_bins rsvd_burst = {3};
      }
      AWPROT : coverpoint tr.prot {
         bins prot[4] = {[0:$]};
      }
      ALIGNMENT : coverpoint is_unaligned {
         bins aligned = {0};
         bins unaligned  = {1};
      }
      NARROW : coverpoint is_narrow {
         bins full = {0};
         bins narrow = {1};
      }
      ALIGNMENT_x_NARROW  : cross ALIGNMENT, NARROW;
      ALIGNMENT_x_AWBURST : cross ALIGNMENT, AWBURST {
         ignore_bins invalid_comb = ALIGNMENT_x_AWBURST with (ALIGNMENT==1 && AWBURST==2);
      }
      AWBURST_x_AWSIZE : cross AWBURST, AWSIZE;
   endgroup
   covergroup raddr_ch_cmn_cg;
      option.per_instance = 1;
      option.name = "raddr_ch_cmn_cg";
      ARADDR : coverpoint tr.addr {
         bins addr[5] = {[0:$]};
      }
      ARID : coverpoint tr.id {
         bins id[4] = {[0:$]};
      }
      ARSIZE : coverpoint tr.size {
         bins burst_size[] = {[0:$clog2(T::AXI_DATA_WIDTH/8)]};
      }
      ARBURST : coverpoint tr.burst {
         bins incr = {1};
         bins fixed = {0};
         bins wrap = {2};
         illegal_bins rsvd_burst = {3};
      }
      ARPROT : coverpoint tr.prot {
         bins prot[4] = {[0:$]};
      }
      ALIGNMENT : coverpoint is_unaligned {
         bins aligned = {0};
         bins unaligned  = {1};
      }
      NARROW : coverpoint is_narrow {
         bins full = {0};
         bins narrow = {1};
      }
      ALIGNMENT_x_NARROW : cross ALIGNMENT, NARROW;
      ALIGNMENT_x_ARBURST : cross ALIGNMENT, ARBURST{
         illegal_bins invalid_comb = ALIGNMENT_x_ARBURST with (ALIGNMENT==1 && ARBURST==2);
      }
      ARBURST_x_ARSIZE : cross ARBURST, ARSIZE;
      //TYPE_x_LEN : cross ARBURST, ARLEN{
      //   illegal_bins invalid_fixed = TYPE_x_LEN with (ARBURST==0 && ARLEN>15);
      //   illegal_bins invalid_wrap  = TYPE_x_LEN with (ARBURST==2 && !(ARLEN inside {1,3,7,15}));
      //}
   endgroup

   covergroup waddr_ch_axi3_cg;
      option.per_instance = 1;
      option.name = "waddr_ch_axi3_cg";
      AWLOCK : coverpoint tr.lock {
         bins normal = {0};
         bins exclusive = {1};
         bins locked = {2};
         illegal_bins rsvd_lock = {3};
      } //axi3%axi4
      AWCACHE : coverpoint tr.cache {
         bins dev_non_bufferable = {'b0000};
         bins dev_bufferable ={'b0001};
         bins normal_non_cache_non_buff = {'b0010};
         bins normal_non_cache_bufferable = {'b0011};
         bins write_through_read_or_no__allocate={'b0110};
         bins write_though_write_allocate={'b1010};
         bins write_through_read_and_write_allocate={'b1110};
         bins write_back_no_or_read_allocate= {'b0111};
         bins write_back_write_allocate = {'b1011};
         bins write_back_read_write_allocate = {'b1111};
         illegal_bins rsvd_cache = default;
      } //axi3&axi4
            AWLEN : coverpoint tr.len {
         bins zero = {0};
         bins mid  = {[1:14]};
         bins max  = {15};
      }
   endgroup

   covergroup raddr_ch_axi3_cg;
      option.per_instance = 1;
      option.name = "raddr_ch_axi3_cg";
      ARLOCK : coverpoint tr.lock {
         bins normal = {0};
         bins exclusive = {1};
         bins locked = {2};
         illegal_bins rsvd_lock = {3};
      } //axi3%axi4
      ARCACHE : coverpoint tr.cache {
         bins dev_non_bufferable = {'b0000};
         bins dev_bufferable ={'b0001};
         bins normal_non_cache_non_buff = {'b0010};
         bins normal_non_cache_bufferable = {'b0011};
         bins write_through_no_allocate={'b1010};
         bins write_through_read_allocate={'b0110};
         bins write_through_write_allocate={'b1010};
         bins write_through_read_and_write_allocate={'b1110};
         bins write_back_no_or_write_allocate={'b1011};
         bins write_back_read_allocate={'b0111};
         // duplicate //bins write_back_write_allocate={'b1011};
         bins write_back_read_write_allocate={'b1111};
         illegal_bins rsvd_cache=default;
      } //axi3&axi4
            ARLEN : coverpoint tr.len {
         bins zero = {0};
         bins mid  = {[1:14]};
         bins max  = {15};
      }
   endgroup

   covergroup waddr_ch_axi4_cg;
      option.per_instance = 1;
      option.name = "waddr_ch_axi4_cg";
      AWLEN : coverpoint tr.len {
         bins zero = {0};
         bins mid  = {[1:254]};
         bins max  = {255};
      }
      AWLOCK : coverpoint tr.lock {
         bins normal = {0};
         bins exclusive = {1};
         illegal_bins rsvd_lock = default; //{2,3};
      } //axi3%axi4

      AWCACHE : coverpoint tr.cache {
         bins dev_non_bufferable = {'b0000};
         bins dev_bufferable ={'b0001}; 
         bins normal_non_cache_non_buff = {'b0010};
         bins normal_non_cache_bufferable = {'b0011};
         bins write_through_read_or_no__allocate={'b0110};
         bins write_through_read_and_write_allocate={'b1110};
         bins write_back_no_or_read_allocate= {'b0111};
         bins write_back_read_write_allocate = {'b1111};
         illegal_bins rsvd_cache = default;
      } //axi3&axi4
      AWQOS : coverpoint tr.qos {
         bins qos[4] = {[0:$]};
      } //axi4
      AWREGION : coverpoint tr.region {
         bins region[4] = {[0:$]};
      } //axi4
      AWUSER : coverpoint tr.axuser {
         bins user[4] = {[0:$]};
      } //axi4
   endgroup

   covergroup raddr_ch_axi4_cg;
      option.per_instance = 1;
      option.name = "raddr_ch_axi4_cg";
      ARLEN : coverpoint tr.len {
         bins zero = {0};
         bins mid  = {[1:254]};
         bins max  = {255};
      }
      ARLOCK : coverpoint tr.lock {
         bins normal = {0};
         bins exclusive = {1};
         illegal_bins rsvd_lock = default; //{2,3};
      } //axi3%axi4
      ARCACHE : coverpoint tr.cache {
         bins dev_non_bufferable = {'b0000};
         bins dev_bufferable ={'b0001};
         bins normal_non_cache_non_buff = {'b0010};
         bins normal_non_cache_bufferable = {'b0011};
         bins write_through_no_allocate={'b1010};
         bins write_through_read_allocate={'b1110};
         bins write_through_write_allocate={'b1010};
         bins write_through_read_and_write_allocate={'b1110};
         bins write_back_no_or_write_allocate={'b1011};
         bins write_back_read_and_or_write_allocate={'b1111};
         //duplicate //bins write_back_write_allocate={'b1011};
         //duplicate //bins write_back_read_write_allocate={'b1111};
         illegal_bins rsvd_cache=default;
      } //axi3&axi4
      ARQOS : coverpoint tr.qos {
         bins qos[4] = {[0:$]};
      } //axi4
      ARREGION : coverpoint tr.region {
         bins region[4] = {[0:$]};
      } //axi4
      ARUSER : coverpoint tr.axuser {
         bins user[4] = {[0:$]};
      } //axi4
   endgroup

   covergroup wresp_ch_cg;
      option.per_instance = 1;
      option.name = "wresp_ch_cg";
      BRESP : coverpoint tr.bresp {
         bins OKAY = {0};
         bins EXOKAY = {1};
         bins SLVERR = {2};
         bins DECERR = {3};
      }
   endgroup

   covergroup rresp_ch_cg;
      option.per_instance = 1;
      option.name = "rresp_ch_cg";
      RRESP : coverpoint rresp_cov {
         bins OKAY = {0};
         bins EXOKAY = {1};
         bins SLVERR = {2};
         bins DECERR = {3};
      }
   endgroup

/*
   covergroup wdata_ch_cg;
      option.per_instance = 1;
      option.name = "";
   endgroup

   covergroup wresp_ch_cg;
      option.per_instance = 1;
      option.name = "";
   endgroup

   covergroup raddr_ch_cg;
      option.per_instance = 1;
      option.name = "";
   endgroup

   covergroup rdata_ch_cg;
      option.per_instance = 1;
      option.name = "";
   endgroup
*/

   function new(string name, uvm_component parent);
      super.new(name, parent);
      cov_import = new("cov_import", this);
      uvm_config_db#(axi_port_cfg)::get(this, "*", "axi_port_cfg", cfg);

      waddr_ch_cmn_cg = new();
      wresp_ch_cg = new();
      raddr_ch_cmn_cg = new();
      rresp_ch_cg = new();
      if (cfg.version == AXI3) begin
         waddr_ch_axi3_cg = new();
         raddr_ch_axi3_cg = new();
      end else if (cfg.version == AXI4) begin
         waddr_ch_axi4_cg = new();
         raddr_ch_axi4_cg = new();
      end
   endfunction

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
   endfunction

  function void write_cov_imp(axi_item_type txn);
     bit [T::AXI_DATA_WIDTH-1:0] addr_mask;
     //tr = axi_item_type::type_id::create("tr", this);
     $cast(tr, txn.clone());

     addr_mask = (({T::AXI_DATA_WIDTH{1'b0}} + 1)<<tr.size) - 1;
     is_narrow = (tr.size == $clog2(T::AXI_DATA_WIDTH/8)) ? 1 : 0;
//     is_unaligned = (tr.addr[$clog2(T::AXI_DATA_WIDTH/8)-1:0] == '0) ? 0 : 1;
     is_unaligned = ((tr.addr & addr_mask) == '0) ?  0 : 1;
     if (tr.sample_type == FULL_TRANS && tr.rwType == WRITE) begin
        waddr_ch_cmn_cg.sample();
        wresp_ch_cg.sample();
        if (cfg.version == AXI3) begin
           waddr_ch_axi3_cg.sample();
        end else if (cfg.version == AXI4) begin
           waddr_ch_axi4_cg.sample();
        end
     end else if (tr.sample_type == FULL_TRANS && tr.rwType == READ) begin
        raddr_ch_cmn_cg.sample();
        //$display("tr.rresp.size= %0d", tr.rresp.size());
        foreach (tr.rresp[i]) begin
           //$display("[%0d] tr.rresp=%0d rresp_cov=%0d", i, tr.rresp[i], rresp_cov);
           rresp_cov = tr.rresp[i];
           rresp_ch_cg.sample();
        end
        if (cfg.version == AXI3) begin
           raddr_ch_axi3_cg.sample();
        end else if (cfg.version == AXI4) begin
           raddr_ch_axi4_cg.sample();
        end
     end
  endfunction



endclass
