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
`ifndef axi_master_agent__sv
 `define axi_master_agent__sv

class axi_master_agent #(type T=axi_params) extends uvm_agent;
   `uvm_component_param_utils(axi_master_agent#(T))

   //typedef T::axi_addr_item_t axi_addr_item_type;
   //typedef T::axi_data_item_t axi_data_item_type;
   //typedef T::axi_resp_item_t axi_resp_item_type;
   //typedef T::axi_item_t      axi_item_type;
   //typedef T::addr_if_t addr_if_type;
   //typedef T::data_if_t data_if_type;
   //typedef T::resp_if_t resp_if_type;
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

  typedef virtual axi_addr_inf #( 
    .ID_WIDTH     (T::AXI_ID_WIDTH),
    .ADDR_WIDTH   (T::AXI_ADDR_WIDTH),
    .LEN_WIDTH    (T::AXI_LEN_WIDTH),
    .SIZE_WIDTH   (T::AXI_SIZE_WIDTH),
    .BURST_WIDTH  (T::AXI_BURST_WIDTH),
    .LOCK_WIDTH   (T::AXI_LOCK_WIDTH),
    .CACHE_WIDTH  (T::AXI_CACHE_WIDTH),
    .PROT_WIDTH   (T::AXI_PROT_WIDTH),
    .QOS_WIDTH    (T::AXI_QOS_WIDTH),
    .REGION_WIDTH (T::AXI_REGION_WIDTH),
    .USER_WIDTH   (T::AXI_USER_WIDTH),
    .GPIO_WIDTH   (T::AXI_GPIO_WIDTH)
  ) addr_if_type;

  typedef virtual axi_data_inf #(
    .ID_WIDTH     (T::AXI_ID_WIDTH),
    .DATA_WIDTH   (T::AXI_DATA_WIDTH), 
    .STRB_WIDTH   (T::AXI_STRB_WIDTH),
    .USER_WIDTH   (T::AXI_USER_WIDTH),
    .RESP_WIDTH   (T::AXI_RESP_WIDTH)
  ) data_if_type;

  typedef virtual axi_resp_inf #(
    .ID_WIDTH     (T::AXI_ID_WIDTH),
    .RESP_WIDTH   (T::AXI_RESP_WIDTH),
    .USER_WIDTH   (T::AXI_USER_WIDTH)
  ) resp_if_type;


   uvm_analysis_port#(axi_item_type)      req_ap; //transmits axi wr/rd requests
   uvm_analysis_port#(axi_data_item_type) rdata_ap;
   uvm_analysis_port#(axi_resp_item_type) bresp_ap;

   addr_if_type awaddr_vif;
   data_if_type wdata_vif;
   resp_if_type bresp_vif;

   addr_if_type araddr_vif;
   data_if_type rdata_vif;

   axi_port_cfg port_cfg;
   
   axi_addr_driver#(T)   mstr_waddr_driver;
   axi_data_driver#(T)   mstr_wdata_driver;
   axi_ready_driver#(T)  mstr_brdy_driver;

   axi_addr_driver#(T)   mstr_raddr_driver;
   axi_ready_driver#(T)  mstr_rrdy_driver;
   
   axi_addr_monitor#(T) mstr_waddr_mon;
   axi_data_monitor#(T) mstr_wdata_mon;
   axi_resp_monitor#(T) mstr_bresp_mon;

   axi_addr_monitor#(T) mstr_raddr_mon;
   axi_data_monitor#(T) mstr_rdata_mon;

   axi_model#(T)        slv_model;
   axi_coverage#(T)     axi_cov;

   uvm_sequencer#(axi_addr_item_type) axi_waddr_sequencer;
   uvm_sequencer#(axi_addr_item_type) axi_raddr_sequencer;
   uvm_sequencer#(axi_data_item_type) axi_wdata_sequencer;

   int wfile;

   function new(string name="axi_master_agent", uvm_component parent=null);
      super.new(name, parent);
      req_ap   = new("req_ap", this);
      rdata_ap = new("rdata_ap", this);
      bresp_ap = new("bresp_ap", this);
   endfunction // new

  `protect //begin protected region
   function void print_params();
      $display("%0s params:", get_full_name());
      $display("AXI_ID_WIDTH = %0d",     T::AXI_ID_WIDTH);
      $display("AXI_ADDR_WIDTH = %0d",   T::AXI_ADDR_WIDTH);
      $display("AXI_LEN_WIDTH = %0d",    T::AXI_LEN_WIDTH);
      $display("AXI_SIZE_WIDTH = %0d",   T::AXI_SIZE_WIDTH);
      $display("AXI_BURST_WIDTH = %0d",  T::AXI_BURST_WIDTH);
      $display("AXI_LOCK_WIDTH = %0d",   T::AXI_LOCK_WIDTH);
      $display("AXI_CACHE_WIDTH = %0d",  T::AXI_CACHE_WIDTH);
      $display("AXI_PROT_WIDTH = %0d",   T::AXI_PROT_WIDTH);
      $display("AXI_QOS_WIDTH = %0d",    T::AXI_QOS_WIDTH);
      $display("AXI_REGION_WIDTH = %0d", T::AXI_REGION_WIDTH);
      $display("AXI_USER_WIDTH = %0d",   T::AXI_USER_WIDTH);
      $display("AXI_DATA_WIDTH   = %0d", T::AXI_DATA_WIDTH);  
      $display("AXI_STRB_WIDTH   = %0d", T::AXI_STRB_WIDTH);  
      $display("AXI_RESP_WIDTH   = %0d", T::AXI_RESP_WIDTH);
   endfunction


   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      print_params();
      mstr_waddr_driver = axi_addr_driver#(T)::type_id::create("mstr_waddr_driver", this);
      mstr_wdata_driver = axi_data_driver#(T)::type_id::create("mstr_wdata_driver", this);
      mstr_brdy_driver  = axi_ready_driver#(T)::type_id::create("mstr_brdy_driver", this);
      mstr_raddr_driver = axi_addr_driver#(T)::type_id::create("mstr_raddr_driver", this);
      mstr_rrdy_driver  = axi_ready_driver#(T)::type_id::create("mstr_rrdy_driver", this); 

      if (port_cfg.mst_has_monitor) begin
         mstr_waddr_mon = axi_addr_monitor#(T)::type_id::create("mstr_waddr_mon", this); 
         mstr_raddr_mon = axi_addr_monitor#(T)::type_id::create("mstr_raddr_mon", this);
         mstr_wdata_mon = axi_data_monitor#(T)::type_id::create("mstr_wdata_mon", this);
         mstr_bresp_mon  = axi_resp_monitor#(T)::type_id::create("mstr_bresp_mon", this);
         mstr_rdata_mon = axi_data_monitor#(T)::type_id::create("mstr_rdata_mon", this);
         slv_model     = axi_model#(T)::type_id::create("axi_model", this);
      end

      axi_waddr_sequencer = uvm_sequencer#(axi_addr_item_type)::type_id::create("axi_waddr_sequencer", this);
      axi_raddr_sequencer = uvm_sequencer#(axi_addr_item_type)::type_id::create("axi_raddr_sequencer", this);
      axi_wdata_sequencer = uvm_sequencer#(axi_data_item_type)::type_id::create("axi_wdata_sequencer", this);


      uvm_config_db#(axi_port_cfg)::set(null, "*", "axi_port_cfg", port_cfg);
      if (port_cfg.enable_coverage) begin
         axi_cov = axi_coverage#(T)::type_id::create("axi_cov", this);
      end
      
   endfunction // build_phase

   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if (!uvm_config_db#(addr_if_type)::get(null,
                                             "uvm_test_top",
                                             $sformatf("%s.mstr_waddr_inf", get_name()),
                                             awaddr_vif)) begin
	 `uvm_fatal(get_name(), "No Virtual Master Interface specified for mstr_waddr_inf")
      end
      if (!uvm_config_db#(addr_if_type)::get(null,
                                             "uvm_test_top",
                                             $sformatf("%s.mstr_raddr_inf", get_name()),
                                             araddr_vif)) begin
	 `uvm_fatal(get_name(), "No Virtual Master Interface specified for mstr_raddr_if")
      end
      if (!uvm_config_db#(data_if_type)::get(null,
                                             "uvm_test_top",
                                             $sformatf("%s.mstr_wdata_inf", get_name()),
                                             wdata_vif)) begin
	 `uvm_fatal(get_full_name(), "No Virtual Master Interface specified for mstr_wdata_if")
      end
      if (!uvm_config_db#(data_if_type)::get(null,
                                             "uvm_test_top",
                                             $sformatf("%s.mstr_rdata_inf", get_name()),
                                             rdata_vif)) begin
         `uvm_fatal(get_full_name(), "No Virtual Master Interface specified for mstr_rdata_if")
      end
      if (!uvm_config_db#(resp_if_type)::get(null,
                                             "uvm_test_top",
                                             $sformatf("%s.mstr_resp_inf", get_name()),
                                             bresp_vif)) begin
         `uvm_fatal(get_full_name(), "No Virtual Master Interface specified for mstr_resp_if")
      end

      mstr_waddr_driver.addr_if = awaddr_vif;
      mstr_wdata_driver.data_if = wdata_vif;
      mstr_brdy_driver.resp_if  = bresp_vif;
      mstr_raddr_driver.addr_if = araddr_vif;
      mstr_rrdy_driver.data_if  = rdata_vif;

      mstr_waddr_driver.seq_item_port.connect(axi_waddr_sequencer.seq_item_export);
      mstr_raddr_driver.seq_item_port.connect(axi_raddr_sequencer.seq_item_export);
      mstr_wdata_driver.seq_item_port.connect(axi_wdata_sequencer.seq_item_export);

      mstr_brdy_driver.cfg = port_cfg;
      mstr_rrdy_driver.cfg = port_cfg;
      mstr_wdata_driver.cfg = port_cfg;
      mstr_waddr_driver.cfg = port_cfg;
      mstr_raddr_driver.cfg = port_cfg;

      mstr_waddr_driver.rwType = WRITE;
      mstr_wdata_driver.rwType = WRITE;
      mstr_brdy_driver.channelType = AXI_RESP;
      mstr_brdy_driver.direction = WRITE;
      mstr_raddr_driver.rwType = READ;
      mstr_rrdy_driver.channelType = AXI_DATA;
      mstr_rrdy_driver.direction = READ;

      if (port_cfg.mst_has_monitor) begin   
         mstr_waddr_mon.addr_if = awaddr_vif;
         mstr_wdata_mon.data_if = wdata_vif;
         mstr_bresp_mon.resp_if = bresp_vif;
         mstr_raddr_mon.addr_if = araddr_vif;
         mstr_rdata_mon.data_if = rdata_vif;

         mstr_waddr_mon.rwType = WRITE;
         mstr_wdata_mon.rwType = WRITE;
         mstr_bresp_mon.rwType = BRESP;
         mstr_raddr_mon.rwType = READ;
         mstr_rdata_mon.rwType = READ;

         mstr_waddr_mon.axi_addr_aport.connect(slv_model.waddr_import); 
         mstr_wdata_mon.axi_data_aport.connect(slv_model.wdata_import);
         mstr_bresp_mon.axi_resp_aport.connect(slv_model.bresp_import); 
         mstr_raddr_mon.axi_addr_aport.connect(slv_model.raddr_import);
         mstr_rdata_mon.axi_data_aport.connect(slv_model.rdata_import);
         mstr_wdata_mon.axi_partial_data_aport.connect(slv_model.partial_wdata_import);
         mstr_rdata_mon.axi_dvalid_assert_aport.connect(slv_model.assert_rdata_port);
         mstr_bresp_mon.axi_bvalid_assert_aport.connect(slv_model.assert_bresp_port);

         mstr_wdata_mon.cfg = port_cfg;
         mstr_rdata_mon.cfg = port_cfg;
         slv_model.cfg = port_cfg;
         mstr_waddr_mon.cfg = port_cfg;
         mstr_raddr_mon.cfg = port_cfg;

         slv_model.req_ap.connect(req_ap);
         mstr_rdata_mon.axi_data_aport.connect(rdata_ap);
         mstr_bresp_mon.axi_resp_aport.connect(bresp_ap);
      end
      if (port_cfg.enable_coverage) begin
         slv_model.req_ap.connect(axi_cov.cov_import);
      end
   endfunction // connect_phase

   task run_phase(uvm_phase phase);
      int interval = port_cfg.verbose_bw_tracker_interval;
      if (port_cfg.en_verbose_bw_tracker) begin
         wfile = $fopen($sformatf("sig_axi_bw_%0s.txt", get_name()), "w");
         forever begin
            repeat (interval) @awaddr_vif.mon_cb;
            $fdisplay(wfile, "%12t: wr_bw = %0d", $time, slv_model.get_wr_bw());
            $fdisplay(wfile, "%12t: rd_bw = %0d", $time, slv_model.get_rd_bw());
            $fdisplay(wfile, "%12t: wr_req2rsp_latency = %0t", $time, slv_model.get_wr_latency());
            $fdisplay(wfile, "%12t: rd_req2rsp_latency = %0t", $time, slv_model.get_rd_latency());
         end
      end
   endtask

   function void report_phase(uvm_phase phase);
      if (port_cfg.en_verbose_bw_tracker) begin
         $fclose(wfile);
      end
   endfunction
  
   task sw_reset_all_ch(bit rst_val);
      mstr_waddr_driver.do_sw_reset = rst_val;
      if (port_cfg.mst_has_monitor) begin
      mstr_wdata_mon.do_sw_reset = rst_val;
      mstr_rdata_mon.do_sw_reset = rst_val;
      end
   endtask


   `endprotect //end protected region 
endclass // axi_master_agent
`endif //  `ifndef axi_master_agent__sv
