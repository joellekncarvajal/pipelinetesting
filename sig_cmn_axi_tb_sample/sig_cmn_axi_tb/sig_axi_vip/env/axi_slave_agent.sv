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
`ifndef axi_slave_agent__sv
 `define axi_slave_agent__sv

class axi_slave_agent #(type T=axi_params) extends uvm_agent;
   `uvm_component_param_utils(axi_slave_agent#(T))

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
   
   axi_addr_monitor#(T) slv_waddr_mon;
   axi_data_monitor#(T) slv_wdata_mon;
   axi_resp_monitor#(T) slv_bresp_mon;

   axi_addr_monitor#(T) slv_raddr_mon;
   axi_data_monitor#(T) slv_rdata_mon;
  
   axi_ready_driver#(T) slv_awrdy_driver; 
   axi_ready_driver#(T) slv_wrdy_driver;
   axi_resp_driver#(T)  slv_bresp_driver;

   axi_ready_driver#(T) slv_arrdy_driver;
   axi_data_driver#(T)  slv_rdata_driver;

   axi_model#(T)        slv_model;
   axi_coverage#(T)     axi_cov;
   
   uvm_sequencer#(axi_data_item_type) axi_rdata_sequencer;
   uvm_sequencer#(axi_resp_item_type) axi_bresp_sequencer;
   int wfile;

   function new(string name="axi_slave_agent", uvm_component parent=null);
      super.new(name, parent);
      req_ap   = new("req_ap", this);
      rdata_ap = new("rdata_ap", this);
      bresp_ap = new("bresp_ap", this);
   endfunction // new

  `protect //begin protected region
   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      slv_waddr_mon = axi_addr_monitor#(T)::type_id::create("slv_waddr_mon", this);
      slv_wdata_mon = axi_data_monitor#(T)::type_id::create("slv_wdata_mon", this);
      slv_bresp_mon = axi_resp_monitor#(T)::type_id::create("slv_bresp_mon", this);
      slv_raddr_mon = axi_addr_monitor#(T)::type_id::create("slv_raddr_mon", this);
      slv_rdata_mon = axi_data_monitor#(T)::type_id::create("slv_rdata_mon", this);
      slv_model     = axi_model#(T)::type_id::create("axi_model", this);
      if (port_cfg.is_active == UVM_ACTIVE) begin
         slv_awrdy_driver = axi_ready_driver#(T)::type_id::create("slv_awrdy_driver", this);
         slv_wrdy_driver  = axi_ready_driver#(T)::type_id::create("slv_wrdy_driver", this);   
         slv_bresp_driver  = axi_resp_driver#(T)::type_id::create("slv_bresp_driver", this);
         slv_arrdy_driver = axi_ready_driver#(T)::type_id::create("slv_arrdy_driver", this);
         slv_rdata_driver = axi_data_driver#(T)::type_id::create("slv_rdata_driver", this);
         axi_rdata_sequencer = uvm_sequencer#(axi_data_item_type)::type_id::create("axi_rdata_sequencer", this);
         axi_bresp_sequencer = uvm_sequencer#(axi_resp_item_type)::type_id::create("axi_bresp_sequencer", this);
      end
      
      uvm_config_db#(axi_port_cfg)::set(null, "*", "axi_port_cfg", port_cfg);
      if (port_cfg.enable_coverage) begin
         axi_cov = axi_coverage#(T)::type_id::create("axi_cov", this);
      end
   endfunction // build_phase

   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if (!uvm_config_db#(addr_if_type)::get(null,
                                             "uvm_test_top",
                                             $sformatf("%s.slv_waddr_inf", get_name()),
                                             awaddr_vif)) begin
         `uvm_fatal(get_full_name(), "No Virtual Master Interface specified for slv_saddr_if")
      end
      if (!uvm_config_db#(data_if_type)::get(null,
                                             "uvm_test_top",
                                             $sformatf("%s.slv_wdata_inf", get_name()),
                                             wdata_vif)) begin
         `uvm_fatal(get_full_name(), "No Virtual Master Interface specified for slv_data_if")
      end
      if (!uvm_config_db#(addr_if_type)::get(null,
                                             "uvm_test_top",
                                             $sformatf("%s.slv_raddr_inf", get_name()),
                                             araddr_vif)) begin
         `uvm_fatal(get_full_name(), "No Virtual Master Interface specified for slv_saddr_if")
      end
      if (!uvm_config_db#(data_if_type)::get(null,
                                             "uvm_test_top",
                                             $sformatf("%s.slv_rdata_inf", get_name()),
                                             rdata_vif)) begin
         `uvm_fatal(get_full_name(), "No Virtual Master Interface specified for slv_rdata_if")
      end
      if (!uvm_config_db#(resp_if_type)::get(null,
                                             "uvm_test_top",
                                             $sformatf("%s.slv_resp_inf", get_name()),
                                             bresp_vif)) begin
         `uvm_fatal(get_full_name(), "No Virtual Master Interface specified for slv_resp_if")
      end

      //pass vif to drivers and monitors
      slv_waddr_mon.addr_if = awaddr_vif;
      slv_wdata_mon.data_if = wdata_vif;
      slv_bresp_mon.resp_if = bresp_vif;
      slv_raddr_mon.addr_if = araddr_vif;
      slv_rdata_mon.data_if = rdata_vif;

      slv_waddr_mon.rwType = WRITE;
      slv_wdata_mon.rwType = WRITE;
      slv_bresp_mon.rwType = BRESP;
      slv_raddr_mon.rwType = READ;
      slv_rdata_mon.rwType = READ;

      slv_rdata_mon.cfg = port_cfg;
      slv_wdata_mon.cfg = port_cfg;
   
      if (port_cfg.is_active == UVM_ACTIVE) begin  
         slv_awrdy_driver.addr_if = awaddr_vif; 
         slv_wrdy_driver.data_if  = wdata_vif;
         slv_bresp_driver.resp_if = bresp_vif;
         slv_arrdy_driver.addr_if = araddr_vif;
         slv_rdata_driver.data_if = rdata_vif;
         slv_rdata_driver.cfg = port_cfg;
         slv_bresp_driver.cfg = port_cfg;

         slv_awrdy_driver.min_ready_delay   = port_cfg.min_axready_delay; 
         slv_awrdy_driver.max_ready_delay   = port_cfg.max_axready_delay;
         slv_awrdy_driver.ready_high_cycles = port_cfg.axready_high_cycles;
         slv_awrdy_driver.cfg = port_cfg;

         slv_wrdy_driver.min_ready_delay    = port_cfg.min_xready_delay; 
         slv_wrdy_driver.max_ready_delay    = port_cfg.max_xready_delay;
         slv_wrdy_driver.ready_high_cycles  = port_cfg.xready_high_cycles;
         slv_wrdy_driver.cfg = port_cfg;

         slv_arrdy_driver.min_ready_delay   = port_cfg.min_axready_delay; 
         slv_arrdy_driver.max_ready_delay   = port_cfg.max_axready_delay;
         slv_arrdy_driver.ready_high_cycles = port_cfg.axready_high_cycles;
         slv_arrdy_driver.cfg = port_cfg;
   
         slv_rdata_driver.seq_item_port.connect(axi_rdata_sequencer.seq_item_export);
         slv_bresp_driver.seq_item_port.connect(axi_bresp_sequencer.seq_item_export);
  
         slv_awrdy_driver.channelType = AXI_ADDR; 
         slv_wrdy_driver.channelType  = AXI_DATA;
         slv_bresp_driver.rwType      = BRESP;
         slv_arrdy_driver.channelType = AXI_ADDR;
         slv_rdata_driver.rwType      = READ;

         slv_awrdy_driver.direction = WRITE;
         slv_wrdy_driver.direction  = WRITE;
         slv_arrdy_driver.direction = READ;
         slv_awrdy_driver.slv_model = slv_model;
         slv_wrdy_driver.slv_model  = slv_model;
         slv_arrdy_driver.slv_model = slv_model;
      end

      slv_waddr_mon.axi_addr_aport.connect(slv_model.waddr_import); 
      slv_wdata_mon.axi_data_aport.connect(slv_model.wdata_import);
      slv_bresp_mon.axi_resp_aport.connect(slv_model.bresp_import); 
      slv_raddr_mon.axi_addr_aport.connect(slv_model.raddr_import);
      slv_rdata_mon.axi_data_aport.connect(slv_model.rdata_import);
      slv_wdata_mon.axi_partial_data_aport.connect(slv_model.partial_wdata_import);
      slv_rdata_mon.axi_dvalid_assert_aport.connect(slv_model.assert_rdata_port);
      slv_bresp_mon.axi_bvalid_assert_aport.connect(slv_model.assert_bresp_port);
      slv_rdata_mon.axi_partial_data_aport.connect(slv_model.partial_rdata_import);

      slv_model.req_ap.connect(req_ap);
      slv_rdata_mon.axi_data_aport.connect(rdata_ap);
      slv_bresp_mon.axi_resp_aport.connect(bresp_ap); 

      slv_waddr_mon.cfg = port_cfg;
      slv_raddr_mon.cfg = port_cfg;
      slv_model.cfg = port_cfg;   
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
      slv_wdata_mon.do_sw_reset = rst_val;
      slv_rdata_mon.do_sw_reset = rst_val;
   endtask
   `endprotect //end protected region
   
endclass // axi_slave_agent
`endif //  `ifndef axi_slave_agent__sv
