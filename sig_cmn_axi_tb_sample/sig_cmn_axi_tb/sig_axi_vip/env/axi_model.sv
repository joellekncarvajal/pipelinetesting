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
`ifndef axi_model__sv
 `define axi_model__sv

`uvm_analysis_imp_decl(_waddr_port)
`uvm_analysis_imp_decl(_wdata_port)
`uvm_analysis_imp_decl(_bresp_port)
`uvm_analysis_imp_decl(_raddr_port)
`uvm_analysis_imp_decl(_rdata_port)
`uvm_analysis_imp_decl(_partial_wdata_port)
`uvm_analysis_imp_decl(_assert_rdata_port)
`uvm_analysis_imp_decl(_assert_bresp_port)
`uvm_analysis_imp_decl(_partial_rdata_port)

class axi_model#(type T=axi_params) extends uvm_component;
   `uvm_component_param_utils(axi_model#(T))

  `protect //begin protected region
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

   uvm_analysis_imp_waddr_port #(axi_addr_item_type, axi_model#(T)) waddr_import;
   uvm_analysis_imp_wdata_port #(axi_data_item_type, axi_model#(T)) wdata_import;
   uvm_analysis_imp_bresp_port #(axi_resp_item_type, axi_model#(T)) bresp_import;
   uvm_analysis_imp_raddr_port #(axi_addr_item_type, axi_model#(T)) raddr_import;
   uvm_analysis_imp_rdata_port #(axi_data_item_type, axi_model#(T)) rdata_import;
   uvm_analysis_imp_partial_wdata_port #(axi_data_item_type, axi_model#(T)) partial_wdata_import;
   uvm_analysis_imp_assert_rdata_port#(axi_data_item_type, axi_model#(T)) assert_rdata_port;
   uvm_analysis_imp_assert_bresp_port#(axi_resp_item_type, axi_model#(T)) assert_bresp_port;
   uvm_analysis_imp_partial_rdata_port #(axi_data_item_type, axi_model#(T)) partial_rdata_import;

   uvm_analysis_port#(axi_item_type) trans_ap; //transmits complete axi transactions
   uvm_analysis_port#(axi_item_type) req_ap; //transmits axi wr/rd requests

   axi_port_cfg cfg;

   axi_addr_item_type raddr_Q[$];
   axi_addr_item_type waddr_Q[$], wreq_Q[$];
   
   axi_data_item_type wdata_Q[$], mon_wdata_q[$];
   axi_data_item_type rdata_Q[$];

   axi_resp_item_type resp_Q[$];

   axi_resp_item_type outbound_bresp_Q[$];
   axi_data_item_type outbound_rresp_Q[$];
   axi_item_type      outbound_axi_trans_Q[$];

   axi_resp_item_type received_wresps_q[$];
   axi_data_item_type received_rresps_q[$];

   axi_item_type pending_wr_reqs[$];
   axi_item_type pending_rd_reqs[$];
   int unsigned max_pending_wr_cnt = 0;
   int unsigned max_pending_rd_cnt = 0;

   axi_item_type mon_waddr_q[$];

   axi_addr_item_type current_waddr;
   semaphore wr_key;
   
   event waddr_evt;
   event raddr_evt;
   event wdata_evt;
   event partial_wdata_evt;
   event assert_rdata_evt;
   event assert_bresp_evt;
   event rdata_evt;
   event bresp_evt;
   event partial_rdata_evt;

   axi_addr_item_type waddr_tr;
   axi_addr_item_type raddr_tr;
   axi_data_item_type wdata_tr;
   axi_data_item_type partial_wdata_tr;
   axi_data_item_type assert_rdata_tr;
   axi_resp_item_type assert_bresp_tr;
   axi_data_item_type rdata_tr;
   axi_resp_item_type bresp_tr;
   axi_data_item_type partial_rdata_tr;

   realtime  wr_start_time = 0, rd_start_time = 0;
   bit[63:0] wr_byte_count = 0, rd_byte_count = 0;
   bit[63:0] wr_cmd_count = 0, rd_cmd_count = 0;
   bit[63:0] wr_bw = 0, rd_bw = 0;
   bit wr_started = 0, rd_started = 0;
   realtime wr_latency = 0, rd_latency = 0;
   realtime wr_latency_last2resp = 0;
   realtime rd_latency_req2data = 0;
   bit[63:0] wr_trans_cnt =0, rd_trans_cnt =0;
   bit[63:0] outstanding_wr_count = 0, outstanding_rd_count = 0;
   bit is_1st_bresp = 1, is_1st_rresp = 1;

//   logic[7:0] SysMem[logic[63:0]];
   axi_system_memory#(T::AXI_ADDR_WIDTH) mem;
   axi_system_fifo#(T::AXI_ADDR_WIDTH, T::AXI_DATA_WIDTH) fifo;
   axi_system_fifo#(T::AXI_ADDR_WIDTH, T::AXI_DATA_WIDTH) exp_fifo;
   logic[63:0] AddrIDMap[logic[9:0]]; // map ID to addr

   AxiVer version;

   typedef struct {
      bit[T::AXI_ADDR_WIDTH-1:0] lo_addr;
      bit[T::AXI_ADDR_WIDTH-1:0] hi_addr;
      bit[T::AXI_ID_WIDTH-1:0]   axid;
      bit                        is_written;
   } st_exclusive;

   //st_exclusive excl_tracker_q[$];
   axi_addr_item_type excl_tracker_q[$];
   
   function new(string name="", uvm_component parent=null);
      super.new(name, parent);
      current_waddr = null;
      wr_key = new(1);
   endfunction // new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      waddr_import = new("waddr_import", this);
      raddr_import = new("raddr_import", this);
      wdata_import = new("wdata_import", this);
      rdata_import = new("rdata_import", this);
      bresp_import = new("bresp_import", this);
      trans_ap     = new("trans_ap", this);
      req_ap       = new("req_ap", this);
      partial_wdata_import = new("partial_wdata_import", this);
      assert_rdata_port = new("assert_rdata_port", this);
      assert_bresp_port = new("assert_bresp_port", this);
      fifo     = axi_system_fifo#(T::AXI_ADDR_WIDTH, T::AXI_DATA_WIDTH)::type_id::create("fifo", this);
      exp_fifo = axi_system_fifo#(T::AXI_ADDR_WIDTH, T::AXI_DATA_WIDTH)::type_id::create("exp_fifo", this);
      partial_rdata_import = new("partial_rdata_import", this);
   endfunction // build_phase

   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
   endfunction // connect_phase

   task run_phase(uvm_phase phase);
      super.run_phase(phase);

      $display("%0s: cfg.valid_ranges.size= %0d", get_full_name(), cfg.valid_ranges.size());
      foreach(cfg.valid_ranges[i]) begin
         $display("%0s: valid: base[%0d]=0x%0x limit[%0d]=0x%0x", get_full_name(), i, cfg.valid_ranges[i].base, i, cfg.valid_ranges[i].limit);
      end
      foreach (cfg.secure_ranges[i]) begin
         $display("%0s: secure: base[%0d]=0x%0x limit[%0d]=0x%0x", get_full_name(), i, cfg.secure_ranges[i].base, i, cfg.secure_ranges[i].limit);
      end

   endtask // run_phase

   function void match_rreq_rresp(axi_data_item_type resp);
      axi_item_type trans;
      axi_data_item_type  rdata, exp_rresp;
      axi_addr_item_type  raddr;
      int idx[$];
      bit [T::AXI_DATA_WIDTH-1:0] exp_data, actual_data, strb_mask;
      automatic int divisor;
      RespCode act_resp, exp_resp;
      bit is_outside=0, is_protected=0;

      //$display("%0t: %0s_match_rreq_rresp: resp_id=%0x", $time, get_full_name(), resp.id);
      if (pending_rd_reqs.size() > 0) begin
         idx = pending_rd_reqs.find_first_index(x) with (x.id == resp.id);
         if (idx.size() > 0) begin
            //Found matching request for this response
            //Assemble complete axi transaction and send to AP
            trans = pending_rd_reqs[idx[0]];
            exp_rresp = axi_data_item_type::type_id::create("exp_rresp", this);
            exp_rresp.resp.delete();
            foreach (trans.rresp[i]) exp_rresp.resp.push_back(trans.rresp[i]);
            pending_rd_reqs.delete(idx[0]);
            trans.sample_type = FULL_TRANS;
	    trans.is_complete = 1;
            trans.rwType = READ;
            trans.data.delete();
            trans.xuser.delete();
            trans.rresp.delete();
            trans.strb.delete();
            foreach (resp.data[i]) trans.data.push_back(resp.data[i]);
            foreach (resp.user[i]) trans.xuser.push_back(resp.user[i]);
            foreach (resp.resp[i]) trans.rresp.push_back(resp.resp[i]);
            trans.data_start_time  = resp.start_time;
            trans.data_end_time    = resp.end_time;
            trans.data_vld_time    = resp.vld_time;
            //$display("%0t: Found matching read request. addr=0x%0x, id=%0d, data[0]=0x%0x, xuser[0]=0x%0x, rresp[0]=0x%0x", $time, trans.addr, trans.id, trans.data[0], trans.xuser[0], trans.rresp[0]);
            //Read Bandwidth
            rd_cmd_count++;
            rd_byte_count = rd_byte_count + ((trans.len+1)*(1<<trans.size));
            rd_bw = rd_byte_count/(trans.data_end_time - rd_start_time)*1000000000/1000000;
            rd_trans_cnt++;
            divisor = rd_trans_cnt;
            rd_latency = (rd_latency + (trans.data_end_time - trans.addr_start_time));
            rd_latency_req2data = rd_latency_req2data + (trans.data_start_time-trans.addr_start_time);
            //$display("%0t: %0s: READreq2data: %0t", $time, get_full_name(), rd_latency_req2data/rd_trans_cnt);
            //$display("%0t: %0s: READ_BW = %0d MB/s (transferred bytes: %0d)", $time, get_full_name(), rd_bw, rd_byte_count);
            //$display("%0t: %0s: READ_LATENCY: ave=%0t sample=%0t (req=%0t, rsp=%0t, cnt=%0d)", $time, get_full_name(), rd_latency/divisor, (trans.data_end_time - trans.addr_start_time), trans.addr_start_time, trans.data_end_time, divisor);
            if (uvm_report_enabled(UVM_HIGH)) begin
               $display("%0t: %0s: READ_BW = %0d MB/s (transferred bytes: %0d)", $time, get_full_name(), rd_bw, rd_byte_count);
            end
            //Check data integrity
            raddr = axi_addr_item_type::type_id::create("raddr", this);
            raddr.addr = trans.addr;
            raddr.len = trans.len;
            raddr.size = trans.size;
            raddr.burst = trans.burst;
            raddr.id = trans.id;
            //$display("%0t %0s: MATCH_DBG: addr=0x%0x, len=%0d, data.size = %0d", $time, get_full_name, trans.addr, trans.len, resp.data.size());
            //trans.print();
            if (raddr.len+1 != resp.data.size()) begin
               if (cfg.enable_req_rsp_check) begin
               `uvm_error($sformatf("%0s.%0s", get_full_name(),"ERROR_009"), $sformatf("ARLEN and actual number of returned read data transfers do not match. ARLEN+1=%0d, RDATA transfers = %0d", raddr.len+1, resp.data.size()));
               trans.print();
               end
            end
            rdata = get_rdata(raddr, 1);
            foreach (rdata.strb[i]) trans.strb.push_back(rdata.strb[i]);
            for (int k=0; k<=raddr.len; k++) begin
               strb_mask = '0;
               for (int l=0; l<T::AXI_STRB_WIDTH; l++) begin
                  strb_mask = (strb_mask<<8) + {8{rdata.strb[k][T::AXI_STRB_WIDTH-1-l]}};
               end
               if ((resp.resp[k] == 2 || resp.resp[k] == 3) && cfg.en_zero_rdata_on_error) begin
                  exp_data = '0;
               end else begin
                  exp_data   = rdata.data[k] & strb_mask;
               end
               actual_data = resp.data[k] & strb_mask;
               if (exp_data != actual_data && cfg.enable_rddata_compare && cfg.enable_req_rsp_check && (cfg.disable_rd_compare_on_error==0 || (cfg.disable_rd_compare_on_error==1 && resp.resp[k] === 0) )) begin
                  `uvm_error($sformatf("%0s.%0s", get_full_name(),"ERROR_005"), $sformatf("Read data compare error detected on transfer #%0d of burst with starting address 0x%0x", k, trans.addr));
                  $display(" - Actual Data = 0x%0x; Expected Data = 0x%0x", actual_data, exp_data);
                  trans.print();
                  resp.print();
               end 
               //else $display(" - PASS: Actual Data = 0x%0x; Expected Data = 0x%0x", actual_data, exp_data);
            end
            trans_ap.write(trans);
            req_ap.write(trans);
            //$display("%0t: %0s_VLD_SAMP_RD_FULL: AxVALID=%0t, xDVALID=%0t", $time, get_full_name(), trans.addr_vld_time, trans.data_vld_time);
            if (cfg.en_address_range_check && cfg.en_secure_range_check) begin
               is_outside = 0;
               if (cfg.en_address_range_check == 1) begin
                  is_outside = 1;
                  foreach (cfg.valid_ranges[i]) begin
                     if (trans.addr inside {[cfg.valid_ranges[i].base:cfg.valid_ranges[i].limit]} && cfg.valid_ranges[i].is_readable) begin
                        is_outside = 0;
                        break;
                     end
                  end
               end
               is_protected = 0;
               if (cfg.en_secure_range_check == 1) begin
                  foreach (cfg.secure_ranges[i]) begin
                     if (trans.prot[1] == 1 && trans.addr inside {[cfg.secure_ranges[i].base:cfg.secure_ranges[i].limit]}) begin
                        is_protected = 1;
                     end
                  end
               end
               if ((is_outside || is_protected) && cfg.enable_req_rsp_check) begin
                  for (int k=0; k<=trans.len; k++) begin
                     exp_resp = exp_rresp.resp[k];
                     act_resp = resp.resp[k];
                     if (act_resp !== exp_resp) begin
                        `uvm_error($sformatf("%0s.%0s", get_full_name(),"ERROR_010"), $sformatf("RRESP compare error detected on transfer #%0d of burst with starting address 0x%0x", k, trans.addr));
                        $display(" - Actual RREESP = 0x%0x (%0s); Expected RRESP = 0x%0x (%0s)", act_resp, act_resp.name(), exp_resp, exp_resp.name());
                     end
                     //else begin
                     //   $display("RRESP_CHECK_PASS 0x%0x (%0s)", act_resp, act_resp.name());
                     //end
                  end
               end
            end
         end else begin
            if (cfg.enable_req_rsp_check) begin
               //Insert error message
               `uvm_error($sformatf("%0s.%0s", get_full_name(),"ERROR_001"), "Detected read data/response that has no matching read request...");
               resp.print();
            end 
            trans = axi_item_type::type_id::create("trans", this);
            trans.sample_type = RESP_ONLY;
            trans.is_complete = 0;
            trans.rwType = READ;
            trans.data.delete();
            trans.xuser.delete();
            trans.rresp.delete();
            trans.strb.delete();
            trans.id = resp.id;
            foreach (resp.data[i]) trans.data.push_back(resp.data[i]);
            foreach (resp.user[i]) trans.xuser.push_back(resp.user[i]);
            foreach (resp.resp[i]) trans.rresp.push_back(resp.resp[i]);
            trans.data_start_time  = resp.start_time;
            trans.data_end_time    = resp.end_time;
            trans.data_vld_time    = resp.vld_time;
            trans_ap.write(trans);
            req_ap.write(trans);
         end
      end else begin
         if (cfg.enable_req_rsp_check) begin
            //Insert error message
            `uvm_error($sformatf("%0s.%0s", get_full_name(),"ERROR_002"), "Detected read data/response but there are no pending read requests...");
            resp.print();
         end
         trans = axi_item_type::type_id::create("trans", this);
         trans.sample_type = RESP_ONLY;
         trans.is_complete = 0;
         trans.rwType = READ;
         trans.data.delete();
         trans.xuser.delete();
         trans.rresp.delete();
         trans.strb.delete();
         trans.id = resp.id;
         foreach (resp.data[i]) trans.data.push_back(resp.data[i]);
         foreach (resp.user[i]) trans.xuser.push_back(resp.user[i]);
         foreach (resp.resp[i]) trans.rresp.push_back(resp.resp[i]);
         trans.data_start_time  = resp.start_time;
         trans.data_end_time    = resp.end_time;
         trans.data_vld_time    = resp.vld_time;
         trans_ap.write(trans);
         req_ap.write(trans);
      end
   endfunction

   function void match_wreq_wresp(axi_resp_item_type resp);
      axi_item_type trans;
      axi_addr_item_type waddr_err; 
      axi_data_item_type wdata_err;
      int idx[$];
      automatic int divisor;
      bit is_outside =0, is_protected =0;
      RespCode act_resp, exp_resp;

      //$display("%0t: %0s_match_wreq_wresp: resp_id=%0x, count=%0d", $time, get_full_name(), resp.id, pending_wr_reqs.size());
      if (pending_wr_reqs.size() > 0) begin
         idx = pending_wr_reqs.find_first_index(x) with (x.id == resp.id);
         if (idx.size() > 0) begin
            //Found matching request for this response
            //Assemble complete axi transaction and send to AP
            trans = pending_wr_reqs[idx[0]];

            //check bresp
            if (cfg.en_address_range_check && cfg.en_secure_range_check) begin
               is_outside = 0;
               if (cfg.en_address_range_check == 1) begin
                  is_outside = 1;
                  foreach (cfg.valid_ranges[i]) begin
                     if (trans.addr inside {[cfg.valid_ranges[i].base:cfg.valid_ranges[i].limit]} && cfg.valid_ranges[i].is_writable) begin
                        is_outside = 0;
                        break;
                     end
                  end
               end
               is_protected = 0;
               if (cfg.en_secure_range_check == 1) begin
                  foreach (cfg.secure_ranges[i]) begin
                     if (trans.prot[1] == 1 && trans.addr inside {[cfg.secure_ranges[i].base:cfg.secure_ranges[i].limit]}) begin
                        is_protected = 1;
                     end
                  end
               end
               if (is_outside || is_protected) begin
                  exp_resp = trans.bresp;
                  act_resp = resp.resp;
                  if (act_resp !== exp_resp) begin
                     `uvm_error($sformatf("%0s.%0s", get_full_name(),"ERROR_011"), $sformatf("BRESP compare error detected on burst with starting address 0x%0x", trans.addr));
                     $display(" - Actual BRESP = 0x%0x (%0s); Expected BRESP = 0x%0x (%0s)", act_resp, act_resp.name(), exp_resp, exp_resp.name());
                  end
                  //else begin
                  //   $display("BRESP_CHECK_PASS 0x%0x (%0s)", act_resp, act_resp.name());
                  //end
               end
            end

            trans.sample_type = FULL_TRANS;
            trans.rwType = WRITE;
            trans.is_complete = 1;
            pending_wr_reqs.delete(idx[0]);
            trans.buser = resp.user; 
            trans.bresp = resp.resp;
            trans.resp_start_time = resp.start_time;
            trans.resp_vld_time = resp.vld_time;
            //$display("%0t: Found matching write request. addr=0x%0x, id=%0d, buser=0x%0x, bresp=0x%0x", $time, trans.addr, trans.id, trans.buser, trans.bresp);
            wr_cmd_count++;
            wr_byte_count = wr_byte_count + ((trans.len+1)*(1<<trans.size));
            wr_bw = wr_byte_count/(trans.resp_start_time - wr_start_time)*1000000000/1000000;
            wr_trans_cnt++;
            divisor = wr_trans_cnt;
            wr_latency = (wr_latency + (trans.resp_start_time - trans.addr_start_time));
            wr_latency_last2resp = (wr_latency_last2resp + (trans.resp_start_time-trans.data_end_time));
            //$display("%0t: %0s: wr_latency_last2resp = %0t", $time, get_full_name(),wr_latency_last2resp/wr_trans_cnt);
            //$display("%0t: %0s: WRITE_BW = %0d MB/s (transferred bytes: %0d)", $time, get_full_name(), wr_bw, wr_byte_count);
            //$display("%0t: %0s: WRITE_LATENCY: ave=%0t sample=%0t (req=%0t, rsp=%0t, cnt=%0d)", $time, get_full_name(), wr_latency/divisor, (trans.resp_start_time - trans.addr_start_time), trans.addr_start_time, trans.resp_start_time, divisor);
            if (uvm_report_enabled(UVM_HIGH)) begin
               $display("%0t: %0s: WRITE_BW = %0d MB/s (transferred bytes: %0d)", $time, get_full_name(), wr_bw, wr_byte_count);
            end
            if (cfg.def_mem_data_after_error && resp.resp inside {SLVERR, DECERR}) begin
               waddr_err = axi_addr_item_type::type_id::create("waddr_err", this);;
               wdata_err = axi_data_item_type::type_id::create("wdata_err", this);;
               waddr_err.id     = trans.id;
               waddr_err.addr   = trans.addr;
               waddr_err.len    = trans.len;
               waddr_err.size   = trans.size;
               waddr_err.burst  = trans.burst;
               waddr_err.lock   = trans.lock;
               waddr_err.cache  = trans.cache;
               waddr_err.prot   = trans.prot;
               waddr_err.qos    = trans.qos;
               waddr_err.region = trans.region;
               wdata_err.data_len = trans.data.size();
               wdata_err.id       = trans.id;
               wdata_err.data.delete();
               wdata_err.strb.delete();
               foreach (trans.strb[zz]) begin
                  wdata_err.data.push_back('0);
                  wdata_err.strb.push_back(trans.strb[zz]);
               end
              process_waddr_wdata(waddr_err,wdata_err,1);
            end
            trans_ap.write(trans);
            req_ap.write(trans);
            //$display("%0t: %0s_VLD_SAMP_WR_FULL: AxVALID=%0t, xDVALID=%0t", $time, get_full_name(), trans.addr_vld_time, trans.data_vld_time);
         end else begin
            if (cfg.enable_req_rsp_check) begin
               //Insert error message
               `uvm_error($sformatf("%0s.%0s", get_full_name(),"ERROR_003"), "Detected write response that has no matching write request...");
               resp.print();
            end
            trans = axi_item_type::type_id::create("trans", this);
            trans.sample_type = RESP_ONLY;
            trans.rwType = WRITE;
            trans.is_complete = 1;
            trans.buser = resp.user;
            trans.bresp = resp.resp;
            trans.resp_start_time = resp.start_time;
            trans.resp_vld_time = resp.vld_time;
            trans_ap.write(trans);
            req_ap.write(trans);
         end
      end else begin
         if (cfg.enable_req_rsp_check) begin
            //Insert error message
            `uvm_error($sformatf("%0s.%0s", get_full_name(),"ERROR_004"), "Detected write response but there are no pednding write requests...");
            resp.print();
         end
         trans = axi_item_type::type_id::create("trans", this);
         trans.sample_type = RESP_ONLY;
         trans.rwType = WRITE;
         trans.is_complete = 1;
         trans.buser = resp.user;
         trans.bresp = resp.resp;
         trans.resp_start_time = resp.start_time;
         trans.resp_vld_time = resp.vld_time;
         trans_ap.write(trans);
         req_ap.write(trans);
      end
   endfunction

   function void push_req_wr(axi_addr_item_type waddr);
      axi_item_type wreq;
      bit [T::AXI_ADDR_WIDTH-1:0] start_addr, lower_addr, upper_addr;
      int       wrap_size,  burst_size;
      int       loop_cnt, wrap_len;

      wreq  = axi_item_type::type_id::create("wreq", this);
      wreq.rwType = WRITE;
      wreq.sample_type = ADDR_ONLY;
      wreq.randomize() with {
         wreq.addr         == waddr.addr;
         wreq.id           == waddr.id;
         wreq.len          == waddr.len;
         wreq.size         == waddr.size;
         wreq.burst        == waddr.burst;
         wreq.lock         == waddr.lock;
         wreq.cache        == waddr.cache;
         wreq.prot         == waddr.prot;
         wreq.qos          == waddr.qos;
         wreq.region       == waddr.region;
         wreq.axuser       == waddr.user;
	 wreq.gpio         == waddr.gpio;
         wreq.data.size()  == 0;
         wreq.strb.size()  == 0;
         wreq.xuser.size() == 0;
      };
      wreq.addr_start_time = waddr.start_time;
      wreq.addr_vld_time = waddr.vld_time;
      wreq.src_id = waddr.src_id;
      wreq.total_bytes = waddr.total_bytes;
      if (waddr.burst == WRAP) begin
         start_addr = waddr.addr;
         burst_size = (1 << waddr.size);
         wrap_size = (waddr.len+1) * (burst_size);
         lower_addr = start_addr / wrap_size * wrap_size;
         upper_addr = lower_addr + wrap_size - 1;
         loop_cnt = (lower_addr == start_addr) ? 1 : 2;
         wreq.wrap_len0 = (upper_addr - start_addr + 1)/burst_size -1;
         wreq.wrap_len1 = (start_addr - lower_addr)/burst_size -1;
         wreq.wrap_addr0 = start_addr;
         wreq.wrap_addr1 = lower_addr;
         wreq.wrap_cnt   = loop_cnt;
         //$display("WRAP_DBG: cnt=%0d, addr0=%0x, addr1=%0x, len0=%0x, len1=%0x", wreq.wrap_cnt, wreq.wrap_addr0,wreq.wrap_addr1,wreq.wrap_len0,wreq.wrap_len1);
      end
      mon_waddr_q.push_back(wreq);
      //$display("%0t: %0s_push_req_wr: mon_waddr_q.size=%0d", $time, get_full_name(), mon_waddr_q.size());
      req_ap.write(wreq);
      //$display("%0t: %0s_VLD_SAMP_WR_ADDR_ONLY: AxVALID=%0t, xDVALID=%0t", $time, get_full_name(), wreq.addr_vld_time, wreq.data_vld_time);
      match_waddr_partial_wdata();
   endfunction

   function void match_waddr_partial_wdata();
      automatic int idx[$];
      automatic bit is_last = 0;
      automatic axi_item_type txn;
      automatic bit [T::AXI_ADDR_WIDTH-1:0] trans_addr;
      //$display("%0t: %0s_match_waddr_partial_wdata: mon_waddr_q.size=%0d, mon_wdata_q.size()=%0d", $time, get_full_name(), mon_waddr_q.size(), mon_wdata_q.size());
      if (mon_waddr_q.size() > 0 && mon_wdata_q.size() > 0) begin
         for (int i=0; i < mon_wdata_q.size(); i++) begin
//         while (mon_waddr_q.size() > 0 && mon_wdata_q.size() > 0) begin
           if (cfg.version == AXI3) begin
               idx.delete();
               idx = mon_waddr_q.find_first_index(x) with (x.id == mon_wdata_q[i].id);
            end else begin
               idx.delete();
               idx.push_back(0);
            end //if version
            if (idx.size() > 0) begin
               //process addr and data
               mon_waddr_q[idx[0]].transfer_count++;
	       if (mon_waddr_q[idx[0]].data.size() == 0) begin
                  mon_waddr_q[idx[0]].data_start_time = mon_wdata_q[i].start_time;
                  mon_waddr_q[idx[0]].data_vld_time = mon_wdata_q[i].vld_time;
                  trans_addr = mon_waddr_q[idx[0]].addr;
                  if(mon_wdata_q[i].not_last == 0) begin
                     mon_waddr_q[idx[0]].sample_type = DATA_SINGLE;
                     mon_waddr_q[idx[0]].data_end_time = mon_wdata_q[i].start_time;
                     is_last = 1;
                  end else begin
                     mon_waddr_q[idx[0]].sample_type = DATA_START;
                  end
               end else begin
                  trans_addr = mon_waddr_q[idx[0]].addr / (1<<mon_waddr_q[idx[0]].size) * (1<<mon_waddr_q[idx[0]].size);
                  trans_addr = trans_addr + ((1<<mon_waddr_q[idx[0]].size)*(mon_waddr_q[idx[0]].transfer_count-1));
                  if(mon_wdata_q[i].not_last == 0) begin
                     mon_waddr_q[idx[0]].sample_type = DATA_END;
                     mon_waddr_q[idx[0]].data_end_time = mon_wdata_q[i].start_time;
                     is_last = 1;
                  end else begin
                     mon_waddr_q[idx[0]].sample_type = DATA_CONT;
                  end
               end
               //$display("TRANS_ADDR = 'h%0x, TRANS_COUNT = %0d, size='h%0x,", trans_addr, mon_waddr_q[idx[0]].transfer_count, mon_waddr_q[idx[0]].size);
               mon_waddr_q[idx[0]].data.delete();
               mon_waddr_q[idx[0]].strb.delete();
               mon_waddr_q[idx[0]].xuser.delete();

               mon_waddr_q[idx[0]].data.push_back(mon_wdata_q[i].data[0]);
               mon_waddr_q[idx[0]].strb.push_back(mon_wdata_q[i].strb[0]);
               mon_waddr_q[idx[0]].xuser.push_back(mon_wdata_q[i].user[0]);
               //mon_waddr_q[idx[0]].data_start_time = mon_wdata_q[i].start_time;
               txn  = axi_item_type::type_id::create("txn", this);
               txn.rwType = WRITE;
               txn.sample_type = mon_waddr_q[idx[0]].sample_type;
               txn.randomize() with {
                  txn.addr         == mon_waddr_q[idx[0]].addr;
                  txn.id           == mon_waddr_q[idx[0]].id;
                  txn.len          == mon_waddr_q[idx[0]].len;
                  txn.size         == mon_waddr_q[idx[0]].size;
                  txn.burst        == mon_waddr_q[idx[0]].burst;
                  txn.lock         == mon_waddr_q[idx[0]].lock;
                  txn.cache        == mon_waddr_q[idx[0]].cache;
                  txn.prot         == mon_waddr_q[idx[0]].prot;
                  txn.qos          == mon_waddr_q[idx[0]].qos;
                  txn.region       == mon_waddr_q[idx[0]].region;
                  txn.axuser       == mon_waddr_q[idx[0]].axuser;
		  txn.gpio         == mon_waddr_q[idx[0]].gpio;
                  txn.data.size()  == mon_waddr_q[idx[0]].data.size();
                  txn.strb.size()  == mon_waddr_q[idx[0]].strb.size();
                  txn.xuser.size() == mon_waddr_q[idx[0]].xuser.size();
               };
               foreach (txn.data[i])  txn.data[i]  = mon_waddr_q[idx[0]].data[i];
               foreach (txn.strb[i])  txn.strb[i]  = mon_waddr_q[idx[0]].strb[i];
               foreach (txn.xuser[i]) txn.xuser[i] = mon_waddr_q[idx[0]].xuser[i];
               txn.transfer_addr = trans_addr;
               txn.transfer_count = mon_waddr_q[idx[0]].transfer_count;
//               if (txn.sample_type == DATA_START || txn.sample_type == DATA_SINGLE) begin
               txn.data_start_time = mon_waddr_q[idx[0]].data_start_time;
               txn.data_end_time = mon_waddr_q[idx[0]].data_end_time;
               txn.data_vld_time = mon_waddr_q[idx[0]].data_vld_time;
//               end
               //$display("%0t: %0s_match_waddr_partial_wdata: TRANSMIT: %0s", $time, get_full_name(), txn.sprint());
               req_ap.write(txn);
	       //delete used addr and data
               mon_wdata_q.delete(i--);
               if(is_last == 1) begin
                  mon_waddr_q.delete(idx[0]);
                  break;
               end
            end //if found addr index
         end //for
      end
      
   endfunction    

   function void match_waddr_wdata();
      axi_data_item_type wdata;
      int idx[$];
      int count;

      //$display("%0t: match_waddr_wdata", $time);
      count = 0;
      if (waddr_Q.size() > 0 && wdata_Q.size() > 0) begin
         for (int i=0; i < wdata_Q.size(); i++) begin
            //$display("%0t: %0s MWAWD: wdata_Q[%0d].id = %0x, version=%0s",$time, get_full_name(), i, wdata_Q[i].id, cfg.version.name());
            //find index in addr queue
            if (cfg.version == AXI3) begin
               idx.delete();
               idx = waddr_Q.find_first_index(x) with (x.id == wdata_Q[i].id);
            end else begin
               idx.delete();
               idx.push_back(0);
            end //if version
            //if there is addr-data match; break from for loop
            if (idx.size() > 0) begin
               //process addr and data
               process_waddr_wdata(waddr_Q[idx[0]], wdata_Q[i]);
               //delete used addr and data
               waddr_Q.delete(idx[0]);
               wdata_Q.delete(i);
               break;
            end //if found addr index
         end //for loop
      end //if addr-data
   endfunction

   function void set_pending_rresp(axi_addr_item_type raddr);
      axi_item_type       rreq;
      axi_data_item_type  rdata, tmp_rdata;
      bit is_outside, is_protected, is_readable;

      //$display("%0t: %0s set_pending_rresp addr = 0x%0x, lock=0x%0x", $time,get_full_name(), raddr.addr, raddr.lock);
      rdata = get_rdata(raddr, 0);
      //rdata.print();

      if ((1<<raddr.size) > (T::AXI_DATA_WIDTH/8)) begin
         `uvm_error($sformatf("%0s.%0s", get_full_name(),"ERROR_014"), $sformatf("A3.4.1 : The size of any transfer must not exceed the data bus width. Transfer size = %0d bytes. Data Width = %0d bytes",(1<<raddr.size), (T::AXI_DATA_WIDTH/8)))
      end

      is_outside = 0;
      if (cfg.en_address_range_check == 1) begin
         is_outside = 1;
         is_readable = 1;
         //$display("%0t: %0s: cfg.valid_ranges.size=%0d", $time, get_full_name(), cfg.valid_ranges.size());
         foreach (cfg.valid_ranges[i]) begin
         //$display("  - 0x%0x - 0x%0x", cfg.valid_ranges[i].base, cfg.valid_ranges[i].limit);
            if (raddr.addr inside {[cfg.valid_ranges[i].base:cfg.valid_ranges[i].limit]} ) begin
               is_outside = 0;
               is_readable = cfg.valid_ranges[i].is_readable;
               break;
            end
         end
      end
      is_protected = 0;
      if (cfg.en_secure_range_check == 1) begin
         foreach (cfg.secure_ranges[i]) begin
            if (raddr.prot[1] == 1 && raddr.addr inside {[cfg.secure_ranges[i].base:cfg.secure_ranges[i].limit]}) begin
               is_protected = 1;
            end
         end
      end

      tmp_rdata = axi_data_item_type::type_id::create("tmp_rdata", this);
      tmp_rdata.randomize() with {
         tmp_rdata.delay.size() == raddr.len + 1;
         foreach (tmp_rdata.delay[i]) {tmp_rdata.delay[i] <= cfg.rd_resp_max_delay && tmp_rdata.delay[i] >= cfg.rd_resp_min_delay; }
      };

      rreq = axi_item_type::type_id::create("rreq", this);
      rreq.rwType = READ;
      rreq.sample_type = FULL_REQ;
      rreq.randomize() with {
         rreq.id           == raddr.id;
         rreq.addr         == raddr.addr;
         rreq.len          == raddr.len;
         rreq.size         == raddr.size;
         rreq.burst        == raddr.burst;
         rreq.lock         == raddr.lock;
         rreq.cache        == raddr.cache;
         rreq.prot         == raddr.prot;
         rreq.qos          == raddr.qos;
         rreq.region       == raddr.region;
         rreq.axuser       == raddr.user;
	 rreq.gpio         == raddr.gpio;
         rreq.data.size()  == rdata.data.size(); 
         rreq.rresp.size() == rdata.data.size();
         rreq.xuser.size() == rdata.data.size();
      };
      rreq.src_id = raddr.src_id;
      rreq.total_bytes = raddr.total_bytes;
      foreach (rreq.data[i]) rreq.data[i] = rdata.data[i];
      //$display("%0t: %0s: rreq.rresp.size = %0d, out=%0d, prot=%0d, read=%0d", $time, get_full_name(), rreq.rresp.size, is_outside, is_protected, is_readable);
      foreach (rreq.rresp[i]) begin //rreq.rresp[i] = (is_outside == 0 &&  is_protected == 0) ? ((is_readable == 0) ? SLVERR : OKAY) : DECERR;
         if (is_outside == 0 &&  is_protected == 0) begin
            if (is_readable == 0) begin
               rreq.rresp[i] = SLVERR;
            end else begin
               if (raddr.lock == 'h1) begin
                  //$display("%0t: %0s: setting rresp to EXOKAY", $time, get_full_name());
                  rreq.rresp[i] = EXOKAY;
               end else begin
                  rreq.rresp[i] = OKAY;
               end
            end
         end else begin
            rreq.rresp[i] = DECERR;
         end
      end
      rdata.delay.delete();
      foreach(tmp_rdata.delay[i]) rdata.delay.push_back(tmp_rdata.delay[i]);
      rreq.addr_start_time = raddr.start_time;
      rreq.data_start_time = rdata.start_time; 
      rreq.data_end_time   = rdata.end_time; 
      rreq.addr_vld_time   = raddr.vld_time;
      rreq.data_vld_time   = rdata.vld_time;
      pending_rd_reqs.push_back(rreq);
      outbound_rresp_Q.push_back(rdata);
      outbound_axi_trans_Q.push_back(rreq);
      req_ap.write(rreq);
      //$display("%0t: %0s_VLD_SAMP_RD_REQ: AxVALID=%0t, xDVALID=%0t, ARADDR=0x%0x", $time, get_full_name(), rreq.addr_vld_time, rreq.data_vld_time, rreq.addr);

   endfunction

   function void set_pending_bresp(axi_addr_item_type waddr, axi_data_item_type wdata, bit is_outside, bit is_protected, bit is_writable);
      axi_item_type wreq;
      axi_resp_item_type bresp;
      int idx[$];

      wreq  = axi_item_type::type_id::create("wreq", this);
      bresp = axi_resp_item_type::type_id::create("bresp", this);
      //$display("%0t: %0s_set_pending_bresp, addr=%0x, id=%0x, %0d, %0d, writa=%0d", $time, get_full_name(), waddr.addr, waddr.id, axi_item_type::AXI_ID_WIDTH, axi_addr_item_type::AXI_ID_WIDTH, is_writable);
      wreq.rwType = WRITE;
      wreq.sample_type = FULL_REQ;
      wreq.randomize() with {
         wreq.addr         == waddr.addr;
         wreq.id           == waddr.id;
         wreq.len          == waddr.len;
         wreq.size         == waddr.size;
         wreq.burst        == waddr.burst;
         wreq.lock         == waddr.lock;
         wreq.cache        == waddr.cache;
         wreq.prot         == waddr.prot;
         wreq.qos          == waddr.qos;
         wreq.region       == waddr.region;
         wreq.axuser       == waddr.user;
	 wreq.gpio         == waddr.gpio;
         wreq.data.size()  == wdata.data.size();
         wreq.strb.size()  == wdata.strb.size();
         wreq.xuser.size() == wdata.user.size();
         wreq.bresp        == OKAY; //(is_outside==0 && is_protected==0) ? OKAY : DECERR;
      };
      wreq.src_id = waddr.src_id;
      wreq.total_bytes = waddr.total_bytes;
      wreq.bresp = (is_outside==0 && is_protected==0) ? OKAY : DECERR;
      wreq.bresp = (is_writable == 1) ? wreq.bresp : SLVERR;
      foreach (wreq.data[i]) wreq.data[i] = wdata.data[i];
      foreach (wreq.strb[i]) wreq.strb[i] = wdata.strb[i];
      foreach (wreq.xuser[i]) wreq.xuser[i] = wdata.user[i];
      wreq.addr_start_time = waddr.start_time;
      wreq.data_start_time = wdata.start_time;
      wreq.data_end_time   = wdata.end_time;
      wreq.addr_vld_time   = waddr.vld_time;
      wreq.data_vld_time   = wdata.vld_time;

      bresp.randomize() with {
         bresp.id    == waddr.id;
         bresp.user  == 0; //waddr.user;
         bresp.resp  == OKAY;
         bresp.delay >= cfg.wr_resp_min_delay;
         bresp.delay <= cfg.wr_resp_max_delay;
      };
      if (waddr.lock == 'h1) begin
         idx = excl_tracker_q.find_first_index(x) with (x.id == waddr.id);
         if (idx.size() > 0) begin
            bresp.resp  = EXOKAY;
            excl_tracker_q.delete(idx[0]);
         end
      end

                 
      pending_wr_reqs.push_back(wreq);
      wreq_Q.push_back(waddr);
      outbound_bresp_Q.push_back(bresp);
      outbound_axi_trans_Q.push_back(wreq);
      req_ap.write(wreq);
      //$display("%0t: %0s_VLD_SAMP_WR_REQ: AxVALID=%0t, xDVALID=%0t", $time, get_full_name(), wreq.addr_vld_time, wreq.data_vld_time);

   endfunction

   function void process_waddr_wdata(axi_addr_item_type waddr, axi_data_item_type wdata, bit for_error_handling = 0);
      bit [T::AXI_ADDR_WIDTH-1:0] start_addr, lower_addr, upper_addr, daligned_addr;
      bit [$clog2(T::AXI_ADDR_WIDTH/8)-1:0] byte_addr;
      bit [7:0] data_q [$];
      bit       strb_q [$];
      int       byte_count, wrap_size, byte_pos, byte_lane, burst_size;
      int       loop_cnt, wrap_len;
      bit       is_outside, is_protected, is_writable;

      //$display("%0t: %0s: process_waddr_wdata addr=0x%0x, data.size=%0d id=0x%0x", $time, get_full_name(), waddr.addr, wdata.data.size(), waddr.id);
      //waddr.print();
      //wdata.print();
      data_q.delete();
      strb_q.delete();
      start_addr = waddr.addr;
      daligned_addr = waddr.addr / (T::AXI_DATA_WIDTH/8) * (T::AXI_DATA_WIDTH/8);
      burst_size = (1 << waddr.size);
      if (waddr.len+1 != wdata.data.size()) begin
         `uvm_error($sformatf("%0s.%0s", get_full_name(),"ERROR_008"), $sformatf("AWLEN and actual number of write data transfers do not match. AWLEN+1=%0d, WDATA transfers = %0d", waddr.len+1, wdata.data.size()));
      end 
      //byte_pos = position within the data bus width
      //byte_lane = position within burst size
      
      is_outside = 0; //(cfg.valid_ranges.size() > 0 && cfg.en_address_range_check) ? 1 : 0;
      is_writable = 1;
      if (cfg.en_address_range_check == 1) begin
         is_outside = 1;
         foreach (cfg.valid_ranges[i]) begin
            if (waddr.addr inside {[cfg.valid_ranges[i].base:cfg.valid_ranges[i].limit]} && cfg.valid_ranges[i].is_writable) begin
               is_outside = 0;
               break;
            end
         end
         foreach (cfg.valid_ranges[i]) begin
            if (waddr.addr inside {[cfg.valid_ranges[i].base:cfg.valid_ranges[i].limit]} && cfg.valid_ranges[i].is_writable==0) begin
               is_writable = 0;
               break;
            end
         end
      end
      is_protected = 0;
      if (cfg.en_secure_range_check == 1) begin
         foreach (cfg.secure_ranges[i]) begin
            if (waddr.prot[1] == 1 && waddr.addr inside {[cfg.secure_ranges[i].base:cfg.secure_ranges[i].limit]}) begin
               is_protected = 1;
            end
         end
      end
      if (for_error_handling == 0) begin
         set_pending_bresp(waddr, wdata, is_outside, is_protected, is_writable);
      end
      if (waddr.burst == INCR) begin
         byte_pos = start_addr[$clog2(T::AXI_DATA_WIDTH/8)-1:0];
         byte_lane = byte_pos % burst_size;
         byte_addr =  waddr.addr[$clog2(T::AXI_DATA_WIDTH/8)-1:0];
         for (int i=0; i<= waddr.len; i++) begin
           //Check Strobe 
           //$display("%0t: %0s STRBDBG: addr=0x%0x, len=%0d, AXI_STRB_WIDTH=%0d, byte_pos=%0d, strb=0x%0x [%0d]", $time, get_full_name(), start_addr,waddr.len,T::AXI_STRB_WIDTH, byte_pos, wdata.strb[i], i);
           for (int si=0; si<T::AXI_STRB_WIDTH; si++) begin
              if (si < byte_pos) begin
                 if (wdata.strb[i][si] != 0) begin
                    `uvm_error($sformatf("%0s.%0s", get_full_name(),"ERROR_006"), $sformatf("Strobe is not aligned to address. STROBE = 'h%0x ADDR = 'h%0x ('h%0x)", wdata.strb[i],  waddr.addr, byte_pos));
                 end
              end else if (si > ((byte_pos/burst_size*burst_size)+burst_size)) begin
                 //$display("si=%0d, val=%0d, byte_pos=0x%0x", si, ((byte_pos/burst_size*burst_size)+burst_size), byte_pos);
                 if (wdata.strb[i][si] != 0) begin
                    `uvm_error($sformatf("%0s.%0s", get_full_name(),"ERROR_007"), $sformatf("Strobe is not aligned to burst size. STROBE = 'h%0x SIZE = 'h%0x", wdata.strb[i],  waddr.size));
                 end
              end
           end
           byte_addr = ((byte_addr/burst_size*burst_size)+burst_size);
           //Check Strobe end
           if (cfg.fifo_en == 1 && daligned_addr inside{[cfg.fifo_base:cfg.fifo_limit]}) begin
              //if (wdata.strb[i] != '0) begin
                 //$display("%0t %0s: INCR_FIFO addr=0x%0x, wdata=0x%0x, wstrb=0x%0x", $time, get_full_name(), daligned_addr, wdata.data[i], wdata.strb[i]);
                 fifo.writeFifo(daligned_addr, wdata.data[i], wdata.strb[i]);
                 exp_fifo.writeFifo(daligned_addr, wdata.data[i], wdata.strb[i]);
              //end
           daligned_addr = daligned_addr + (1 << waddr.size);
           end else begin
              for (int j=byte_lane; j<burst_size; j++) begin
                 data_q.push_back(wdata.data[i][(byte_pos+j-byte_lane)*8 +: 8]);
                 strb_q.push_back(wdata.strb[i][(byte_pos+j-byte_lane) +: 1]); 
                 //byte_pos++;
              end
           end
           byte_pos = ((byte_pos/burst_size * burst_size)+burst_size) % (T::AXI_DATA_WIDTH/8);
           byte_lane = byte_pos % burst_size;
         end
         //WRITE TO MEM
         //$display("%0t: mem.writeMem, T::AXI_ADDR_WIDTH=%0d, start_addr=0x%0x, waddr.addr=0x%0x, data_q.size=%0d", $time, T::AXI_ADDR_WIDTH, start_addr, waddr.addr, data_q.size());
         if ((!(cfg.fifo_en == 1 && daligned_addr inside{[cfg.fifo_base:cfg.fifo_limit]})) &&
             (is_outside == 0 && is_protected == 0) 
         ) begin
            mem.writeMem(start_addr, data_q, strb_q);
         end
      end else if (waddr.burst == WRAP) begin
         //$display("ENTERED_WRAP");
         wrap_size = (waddr.len+1) * (burst_size);
         lower_addr = start_addr / wrap_size * wrap_size;
         upper_addr = lower_addr + wrap_size - 1;
         byte_pos = lower_addr[$clog2(T::AXI_DATA_WIDTH/8)-1:0];
         loop_cnt = (lower_addr == start_addr) ? 1 : 2;
         //$display("%0t: start_addr=0x%0x, lower_addr=0x%0x, upper_addr=0x%0x, wrap_size=%0d, loop_cnt=%0d", $time, start_addr,lower_addr,upper_addr,wrap_size,loop_cnt);
         for (int h=0; h<loop_cnt; h++) begin
            byte_pos = (h==0) ? (start_addr[$clog2(T::AXI_DATA_WIDTH/8)-1:0]) : (lower_addr[$clog2(T::AXI_DATA_WIDTH/8)-1:0]);
            byte_lane = byte_pos % burst_size;
            if (h==0) begin
               wrap_len = (upper_addr - start_addr + 1)/burst_size;
            end else begin
               wrap_len = (start_addr - lower_addr)/burst_size;
            end
            // $display("h=%0d, wrap_len=%0d, burst_size=%0d", h, wrap_len, burst_size);
            for (int i=0; i< wrap_len; i++) begin
              for (int j=byte_lane; j<burst_size; j++) begin
                //$display("i=%0d, j=%0d, byte_pos=%0d, byte_lane=%0d", i,j,byte_pos,byte_lane);
                data_q.push_back(wdata.data[0][(byte_pos+j-byte_lane)*8 +: 8]);
                strb_q.push_back(wdata.strb[0][(byte_pos+j-byte_lane) +: 1]);
                //byte_pos++;
              end
              byte_pos = ((byte_pos/burst_size * burst_size)+burst_size) % (T::AXI_DATA_WIDTH/8);
              byte_lane = byte_pos % burst_size;
              wdata.data.push_back(wdata.data.pop_front());
              wdata.strb.push_back(wdata.strb.pop_front());
            end
         
            //WRITE TO MEM
            if (is_outside == 0 && is_protected == 0) begin
               if (h==0) begin //use start_addr
                  mem.writeMem(start_addr, data_q, strb_q);
               end else begin  //use lower_addr
                  mem.writeMem(lower_addr, data_q, strb_q);
               end
            end
            data_q.delete();
            strb_q.delete();
         end
      end else if (waddr.burst == FIXED) begin
         byte_pos = start_addr[$clog2(T::AXI_DATA_WIDTH/8)-1:0];
         byte_lane = byte_pos % burst_size;
         for (int i=0; i<= waddr.len; i++) begin
            if (cfg.fifo_en == 1 && daligned_addr inside{[cfg.fifo_base:cfg.fifo_limit]}) begin
               //if (wdata.strb[i] != '0) begin
                  //$display("%0t: %0s: addr=0x%0x, wdata=0x%0x, wstrb=0x%0x", $time, get_full_name(), daligned_addr, wdata.data[i], wdata.strb[i]);  
                  fifo.writeFifo(daligned_addr, wdata.data[i], wdata.strb[i]);
                  exp_fifo.writeFifo(daligned_addr, wdata.data[i], wdata.strb[i]);
               //end
            end
            else begin 
               for (int j=byte_lane; j<burst_size; j++) begin
                  data_q.push_back(wdata.data[i][(byte_pos+j-byte_lane)*8 +: 8]);
                  strb_q.push_back(wdata.strb[i][(byte_pos+j-byte_lane) +: 1]); 
                  //byte_pos++;
               end
               //WRITE TO MEM
               if (is_outside == 0 && is_protected == 0) begin
                  mem.writeMem(start_addr, data_q, strb_q);
               end
               //if (wdata.strb[i] != '0) begin
               //   fifo.writeFifo(start_addr, data_q, strb_q);
               //   exp_fifo.writeFifo(start_addr, data_q, strb_q);
               //end
            end
            data_q.delete();
            strb_q.delete();
            byte_pos = start_addr[$clog2(T::AXI_DATA_WIDTH/8)-1:0];
         end
      end else begin
      end

   endfunction

   function axi_data_item_type get_rdata(axi_addr_item_type raddr, bit for_check = 0);
      bit [T::AXI_ADDR_WIDTH-1:0] start_addr, lower_addr, upper_addr, transfer_addr, limit_addr;
      logic [T::AXI_DATA_WIDTH-1:0] bus_data, rmask;
      logic [7:0] data_q [$];
      bit       strb_q [$];
      int       byte_count, wrap_size, byte_pos, byte_lane, burst_size;
      int       loop_cnt, wrap_len;
      axi_data_item_type rdata;

      bit[T::AXI_STRB_WIDTH-1:0] strb_val;
      bit[T::AXI_ADDR_WIDTH-1:0] tmp_addr;
      int strb_pos, strb_lane, offset;

      //$display("%0t: get_rdata addr=0x%0x, len=%0d, size=%0d",$time, raddr.addr, raddr.len, raddr.size);
      data_q.delete();
      rdata = axi_data_item_type::type_id::create("rdata", this);
      burst_size = (1 << raddr.size);
      rmask = '0;

      rdata.id = raddr.id;
      if (raddr.burst == INCR) begin
         rdata.data.delete();
         start_addr = raddr.addr / (T::AXI_DATA_WIDTH/8) * (T::AXI_DATA_WIDTH/8);
         tmp_addr = raddr.addr;
         strb_pos = tmp_addr[$clog2(T::AXI_DATA_WIDTH/8)-1:0];
         strb_lane = strb_pos % burst_size;
         for (int i=0; i<= raddr.len; i++) begin
            if (cfg.fifo_en == 1 && start_addr inside{[cfg.fifo_base:cfg.fifo_limit]}) begin
               if (for_check == 0) begin
                  bus_data = fifo.readFifo(start_addr);
               end else begin
                  bus_data = exp_fifo.readFifo(start_addr);
               end
            end else begin
               //READ FROM MEM
               data_q.delete();
               mem.readMem(start_addr, (T::AXI_DATA_WIDTH/8), data_q);
               for (int j=0; j<(T::AXI_DATA_WIDTH/8); j++) begin
                  bus_data[8*j +: 8] = data_q.pop_front();
               end
            end
            //$display("%0t: get_rdata :: bus_data=0x%0x", $time, bus_data);
            //rdata.data.push_back(bus_data); //DBG_RDATA_VALID_ONLY
            if (raddr.lock == 'h1) begin
               rdata.resp.push_back(EXOKAY);
            end else begin
               rdata.resp.push_back(OKAY);
            end
            rdata.user.push_back('0);
            rdata.delay.push_back('0);
            //Strobe calculation; used to determine which data will be compared
            offset = (i==0) ? strb_lane : '0;
            strb_val = '1;
            strb_val = strb_val >> (T::AXI_STRB_WIDTH - burst_size);
            strb_val = (strb_val >> offset) << strb_pos;
            rdata.strb.push_back(strb_val);
            //DBG_RDATA_VALID_ONLY
            for (int a=0; a<T::AXI_STRB_WIDTH; a++) begin
               rmask = rmask >> 8;
               if (strb_val[a] == 1) begin
                  rmask[T::AXI_DATA_WIDTH-1:T::AXI_DATA_WIDTH-8] = 8'hff;
               end else begin
                  rmask[T::AXI_DATA_WIDTH-1:T::AXI_DATA_WIDTH-8] = 8'h00;
               end
            end
            rdata.data.push_back(bus_data & rmask); //DBG_RDATA_VALID_ONLY

            //For next iter
            start_addr = raddr.addr + (burst_size*(i+1));
            start_addr = start_addr / (T::AXI_DATA_WIDTH/8) * (T::AXI_DATA_WIDTH/8);
            strb_pos = ((strb_pos/burst_size * burst_size)+burst_size) % (T::AXI_DATA_WIDTH/8);
            strb_lane = strb_pos % burst_size;
         end
      end else if (raddr.burst == WRAP) begin
         start_addr = raddr.addr;
         wrap_size = (raddr.len+1) * (burst_size);
         lower_addr = start_addr / wrap_size * wrap_size;
         upper_addr = lower_addr + wrap_size - 1;
         byte_pos = lower_addr[$clog2(T::AXI_DATA_WIDTH/8)-1:0];
         loop_cnt = (lower_addr == start_addr) ? 1 : 2;
         for (int h=0; h<loop_cnt; h++) begin
            if (h==0) begin
               wrap_len = (upper_addr - start_addr + 1)/burst_size;
               transfer_addr = start_addr / (T::AXI_DATA_WIDTH/8) * (T::AXI_DATA_WIDTH/8);
               limit_addr = upper_addr;
               tmp_addr = start_addr;
            end else begin
               wrap_len = (start_addr - lower_addr)/burst_size;
               transfer_addr = lower_addr / (T::AXI_DATA_WIDTH/8) * (T::AXI_DATA_WIDTH/8);
               limit_addr = start_addr-1;
               tmp_addr = lower_addr;
            end
            strb_pos = tmp_addr[$clog2(T::AXI_DATA_WIDTH/8)-1:0];
            strb_lane = strb_pos % burst_size;
            for (int i=0; i< wrap_len; i++) begin
               data_q.delete();
               mem.readMem(transfer_addr, (T::AXI_DATA_WIDTH/8), data_q);
               for (int j=0; j<(T::AXI_DATA_WIDTH/8); j++) begin
                  bus_data[8*j +: 8] = data_q.pop_front();
               end
               rdata.resp.push_back(OKAY);
               rdata.user.push_back('0);
               rdata.delay.push_back('0);
               //Strobe calculation; used to determine which data will be compared
               offset = (i==0) ? strb_lane : '0;
               strb_val = '1;
               strb_val = strb_val >> (T::AXI_STRB_WIDTH - burst_size);
               strb_val = (strb_val >> offset) << strb_pos;
               rdata.strb.push_back(strb_val);
               strb_pos = ((strb_pos/burst_size * burst_size)+burst_size) % (T::AXI_DATA_WIDTH/8);
               strb_lane = strb_pos % burst_size;
               //$display("DBG_raddr.addr=0x%0x, strb_val=0x%8x, i=%0d, strb_pos=%0d, rmask=0x%0x", raddr.addr, strb_val, i, strb_pos, rmask);
               //DBG_RDATA_VALID_ONLY
               for (int a=0; a<T::AXI_STRB_WIDTH; a++) begin
                  rmask = rmask >> 8;
                  if (strb_val[a] == 1) begin
                     rmask[T::AXI_DATA_WIDTH-1:T::AXI_DATA_WIDTH-8] = 8'hff;
                  end else begin
                     rmask[T::AXI_DATA_WIDTH-1:T::AXI_DATA_WIDTH-8] = 8'h00;
                  end
               end
               rdata.data.push_back(bus_data & rmask);
               if (h==0) begin
                  transfer_addr = start_addr + (burst_size*(i+1));
               end else begin
                  transfer_addr = lower_addr + (burst_size*(i+1));
               end
               transfer_addr = transfer_addr / (T::AXI_DATA_WIDTH/8) * (T::AXI_DATA_WIDTH/8);
            end
         end
      end else if (raddr.burst == FIXED) begin
         rdata.data.delete();
         start_addr = raddr.addr / (T::AXI_DATA_WIDTH/8) * (T::AXI_DATA_WIDTH/8);
         for (int i=0; i<= raddr.len; i++) begin
            if (cfg.fifo_en == 1 && start_addr inside{[cfg.fifo_base:cfg.fifo_limit]}) begin
               if (for_check == 0) begin
                  bus_data = fifo.readFifo(start_addr);
               end else begin
                  bus_data = exp_fifo.readFifo(start_addr);
               end
            end else begin
               //READ FROM MEM
               data_q.delete();
               mem.readMem(start_addr, (T::AXI_DATA_WIDTH/8), data_q);
               for (int j=0; j<(T::AXI_DATA_WIDTH/8); j++) begin
                  bus_data[8*j +: 8] = data_q.pop_front();
               end
            end
            //$display("%0t: get_rdata :: bus_data=0x%0x", $time, bus_data);
            rdata.resp.push_back(OKAY);
            rdata.user.push_back('0);
            rdata.delay.push_back('0);
            tmp_addr = raddr.addr;
            strb_pos = tmp_addr[$clog2(T::AXI_DATA_WIDTH/8)-1:0];
            strb_lane = strb_pos % burst_size;
            //Strobe calculation; used to determine which data will be compared
            offset = strb_lane; //(i==0) ? strb_lane : '0;
            strb_val = '1;
            strb_val = strb_val >> (T::AXI_STRB_WIDTH - burst_size);
            strb_val = (strb_val >> offset) << strb_pos;
            rdata.strb.push_back(strb_val);
            //DBG_RDATA_VALID_ONLY
            for (int a=0; a<T::AXI_STRB_WIDTH; a++) begin
               rmask = rmask >> 8;
               if (strb_val[a] == 1) begin
                  rmask[T::AXI_DATA_WIDTH-1:T::AXI_DATA_WIDTH-8] = 8'hff;
               end else begin
                  rmask[T::AXI_DATA_WIDTH-1:T::AXI_DATA_WIDTH-8] = 8'h00;
               end
            end
            //$display("%0t: %0s: DBG_raddr.addr=0x%0x, strb_val=0x%8x, i=%0d, strb_pos=%0d, rmask=0x%0x, bus_data=0x%0x, strb_lane=%0d, offset=%0d",$time, get_full_name(),  raddr.addr, strb_val, i, strb_pos, rmask, bus_data, strb_lane,offset);
            rdata.data.push_back(bus_data & rmask);
            start_addr = raddr.addr;
            start_addr = start_addr / (T::AXI_DATA_WIDTH/8) * (T::AXI_DATA_WIDTH/8);
         end
      end
      return rdata;

   endfunction

   function void write_waddr_port(axi_addr_item_type tr);
      if (tr.rwType == AXI_RST) begin
         reset_model();
      end else begin
         `uvm_info(get_full_name(), $sformatf("Push to SB WADDR pkt: %s", tr.sprint()), UVM_DEBUG)
         if (wr_started == 0) begin
            wr_started = 1;
            wr_start_time = tr.start_time;
         end
         waddr_Q.push_back(tr);
         //wreq_Q.push_back(tr);
         push_req_wr(tr);

         waddr_tr = new tr;
         -> waddr_evt;

         track_exlcusive_write(tr);
         match_waddr_wdata();
         outstanding_wr_count++;
         max_pending_wr_cnt = (max_pending_wr_cnt < outstanding_wr_count) ? outstanding_wr_count : max_pending_wr_cnt;
         //$display("%0t: MAXWR: %0s: max_pending_wr_cnt = %0d, outstanding_wr_count=%0d", $time, get_full_name(), max_pending_wr_cnt, outstanding_wr_count);
      end
   endfunction // write_waddr_port
   
   function void write_raddr_port(axi_addr_item_type tr);
      if (tr.rwType == AXI_RST) begin
         reset_model();
      end else begin
         `uvm_info(get_full_name(), $sformatf("Push to SB RADDR pkt: %s", tr.sprint()), UVM_DEBUG)
         if (rd_started == 0) begin
            rd_started = 1;
            rd_start_time = tr.start_time;
         end
         raddr_Q.push_back(tr);

         raddr_tr = new tr;
         -> raddr_evt;
         if (cfg.rdata_ch_is_unresponsive == '0) begin
         track_exlcusive_read(tr);
         set_pending_rresp(tr);
         outstanding_rd_count++;
         max_pending_rd_cnt = (max_pending_rd_cnt < outstanding_rd_count) ? outstanding_rd_count : max_pending_rd_cnt;
         //$display("%0t: MAXRD: %0s: max_pending_rd_cnt = %0d, outstanding_rd_count=%0d", $time, get_full_name(), max_pending_rd_cnt, outstanding_rd_count);
         end
      end
   endfunction // write_raddr_port
   
   function void write_wdata_port(axi_data_item_type tr);
      `uvm_info(get_full_name(), $sformatf("Push to SB WDATA pkt: %s", tr.sprint()), UVM_DEBUG)
      //wr_key.get(1);
      wdata_Q.push_back(tr);

      wdata_tr = new tr;
      -> wdata_evt;

      match_waddr_wdata();
      //wr_key.put(1);
   endfunction // write_wdata_port

   function void write_partial_wdata_port(axi_data_item_type tr);
      `uvm_info(get_full_name(), $sformatf("write_partial_wdata_port: %s", tr.sprint()),UVM_DEBUG)
      mon_wdata_q.push_back(tr);

      partial_wdata_tr = new tr;
      -> partial_wdata_evt;

      match_waddr_partial_wdata();
   endfunction // write_wdata_port

   function void write_partial_rdata_port(axi_data_item_type tr);
      `uvm_info(get_full_name(), $sformatf("write_partial_rdata_port: %s", tr.sprint()),UVM_DEBUG)

      partial_rdata_tr = new tr;
      -> partial_rdata_evt;
   endfunction // write_wdata_port


   function void write_assert_rdata_port(axi_data_item_type tr);
      int idx[$];
      //$display("%0t: %0s_write_assert_rdata_port", $time, get_full_name);
      //tr.print();

      assert_rdata_tr = new tr;
      -> assert_rdata_evt;

      idx = raddr_Q.find_first_index(x) with (x.id == tr.id);
      if (idx.size() == 0) begin
         `uvm_error($sformatf("%0s.%0s", get_full_name(),"ERROR_012"), $sformatf("RVALID (RID=0x%0x) asserted without a prior request on read address channel", tr.id))
      end
      else begin
         raddr_Q.delete(idx[0]);
      end
   endfunction // 

   function void write_assert_bresp_port(axi_resp_item_type tr);
      int idx[$];
      //$display("%0t: %0s_write_assert_bresp_port", $time, get_full_name);
      //tr.print();

      assert_bresp_tr = new tr;
      -> assert_bresp_evt;

      idx = wreq_Q.find_first_index(x) with (x.id == tr.id);
      if (idx.size() == 0) begin
         `uvm_error($sformatf("%0s.%0s", get_full_name(),"ERROR_013"), $sformatf("BVALID (BID=0x%0x) asserted without a prior request on write address channel", tr.id))
      end
      else begin
         wreq_Q.delete(idx[0]);
      end
   endfunction // 

   
   function void write_rdata_port(axi_data_item_type tr);
      `uvm_info(get_full_name(), $sformatf("Push to SB RDATA pkt: %s", tr.sprint()), UVM_DEBUG)
      rdata_Q.push_back(tr);
      received_rresps_q.push_back(tr);

      rdata_tr = new tr;
      -> rdata_evt;

      match_rreq_rresp(tr);
      outstanding_rd_count--;
      `ifdef SIG_AXI_DBG_PRINT
      if (is_1st_rresp) begin
         $display("%0t: MAXRD_b4_resp: %0s: max_pending_rd_cnt = %0d, outstanding_rd_count=%0d", $time, get_full_name(), max_pending_rd_cnt, outstanding_rd_count);
         is_1st_rresp = 0;
      end
      `endif
      //$display("%0t: MAXRD_DEC: %0s: max_pending_rd_cnt = %0d, outstanding_rd_count=%0d", $time, get_full_name(), max_pending_rd_cnt, outstanding_rd_count);
   endfunction // write_rdata_port
   
   function void write_bresp_port(axi_resp_item_type tr);
      `uvm_info(get_full_name(), $sformatf("Push to SB RESP pkt: %s", tr.sprint()), UVM_DEBUG)
      resp_Q.push_back(tr);
      received_wresps_q.push_back(tr);

      bresp_tr = new tr;
      -> bresp_evt;

      match_wreq_wresp(tr);
      outstanding_wr_count--;
      `ifdef SIG_AXI_DBG_PRINT
      if (is_1st_bresp) begin
         $display("%0t: MAXWR_b4_resp: %0s: max_pending_wr_cnt = %0d, outstanding_wr_count=%0d", $time, get_full_name(), max_pending_wr_cnt, outstanding_wr_count);
         is_1st_bresp = 0;
      end
      `endif
      //$display("%0t: MAXWR_DEC: %0s: max_pending_wr_cnt = %0d, outstanding_wr_count=%0d", $time, get_full_name(), max_pending_wr_cnt, outstanding_wr_count);
   endfunction // write_bresp_port

//   function void reset_model(axi_addr_item_type tr);
   function void reset_model();
      axi_item_type trans;

      raddr_Q.delete();
      waddr_Q.delete();
      wdata_Q.delete();
      mon_wdata_q.delete();
      rdata_Q.delete();
      resp_Q.delete();
      outbound_bresp_Q.delete();
      outbound_rresp_Q.delete();
      outbound_axi_trans_Q.delete();
      pending_wr_reqs.delete();
      pending_rd_reqs.delete();
      mon_waddr_q.delete();
      outstanding_wr_count = 0;
      outstanding_rd_count = 0;

      trans = axi_item_type::type_id::create("trans", this);
      trans.rwType = AXI_RST;
      trans.sample_type = AXI_RST_ASSERTED;
      req_ap.write(trans);
   endfunction

   function void report_phase(uvm_phase phase);
      super.report_phase(phase);
      $display("//=======================================================");
      $display("// AXI VIP BANDWIDTH SUMMARY");
      $display("//  - instance: %0s", get_full_name());
      $display("//  - WRITE:");
      $display("//    - Bandwidth   : %0d MB/s; WRITE Commands: %0d (%0d Bytes)", wr_bw, wr_cmd_count, wr_byte_count );
      $display("//    - Ave. Latency: %0t ns", wr_latency/wr_trans_cnt); 
      $display("//    - LAST2RESP   : %0t ns", wr_latency_last2resp/wr_trans_cnt);
      $display("//  - READ:");
      $display("//    - Bandwidth   : %0d MB/s; READ Commands: %0d (%0d Bytes)", rd_bw, rd_cmd_count, rd_byte_count );
      $display("//    - Ave. Latency: %0t ns", rd_latency/rd_trans_cnt);
      $display("//    - REQ2DATAstart: %0t ns", rd_latency_req2data/rd_trans_cnt);
      $display("//=======================================================");
   endfunction

   function bit[63:0] get_wr_bw();
      return wr_bw;
   endfunction

   function bit[63:0] get_rd_bw();
      return rd_bw;
   endfunction

   function realtime get_wr_latency();
      if (wr_trans_cnt != 0) begin
         return wr_latency/wr_trans_cnt;
      end else begin
         return 0;
      end
   endfunction

   function realtime get_rd_latency();
      if (rd_trans_cnt != 0) begin
         return rd_latency/rd_trans_cnt;
      end else begin
         return 0;
      end
   endfunction

   function int unsigned get_num_pending_wr();
      int unsigned pending_wr;
      pending_wr = outstanding_wr_count; //pending_wr_reqs.size();
      return pending_wr;
   endfunction

   function int unsigned get_num_pending_rd();
      int unsigned pending_rd;
      pending_rd = outstanding_rd_count; //pending_rd_reqs.size();
      return pending_rd;
   endfunction

   function int unsigned get_num_pending_total();
      int unsigned pending_total;
      pending_total = get_num_pending_wr() + get_num_pending_rd();
      return pending_total;
   endfunction

   function void reset_bw();
      wr_started = '0;
      wr_byte_count = '0;
      rd_started = '0;
      rd_byte_count = '0;
   endfunction
   function int unsigned get_max_outstanding_wr();
      return max_pending_wr_cnt;
   endfunction
   function int unsigned get_max_outstanding_rd();
      return max_pending_rd_cnt;
   endfunction

   function void track_exlcusive_read(axi_addr_item_type raddr);
//      st_exclusive rd_item;
      axi_addr_item_type rd_item;
      int idx[$];
      if(raddr.lock == 'h1) begin
         idx = excl_tracker_q.find_first_index(x) with (x.id == raddr.id);
         if (idx.size() > 0) begin
            excl_tracker_q.delete(idx[0]);
         end
         $cast(rd_item, raddr.clone()); 
         //rd_item.axid = raddr.id;
         //rd_item.is_written = '0;
         //{rd_item.lo_addr,rd_item.hi_addr} = get_lohi_addr(raddr);
         excl_tracker_q.push_back(rd_item);
      end
   endfunction

   function void track_exlcusive_write(axi_addr_item_type waddr);
      st_exclusive wr_item;
      int idx[$];
      if(waddr.lock == 'h1 && cfg.enable_exclusive_rd_wr_check == '1) begin
         idx = excl_tracker_q.find_first_index(x) with (x.id == waddr.id);
         if (idx.size() == 0) begin
            `uvm_error($sformatf("%0s.%0s", get_full_name(),"ERROR_015"), $sformatf("Received exclusive write with AWID=0x%0x has no matching exclusive read with the same ARID.",waddr.id))
         end else begin
            if (excl_tracker_q[idx[0]].addr != waddr.addr) begin
               `uvm_error($sformatf("%0s.%0s", get_full_name(),"ERROR_015.addr"),$sformatf("Mismatch AxADDR between exclusive read and write with AxID=%0d.", waddr.addr))
            end else if (excl_tracker_q[idx[0]].len != waddr.len) begin
               `uvm_error($sformatf("%0s.%0s", get_full_name(),"ERROR_015.len"),$sformatf("Mismatch AxLEN between exclusive read and write with AxID=%0d.", waddr.len))
            end else if (excl_tracker_q[idx[0]].size != waddr.size) begin
               `uvm_error($sformatf("%0s.%0s", get_full_name(),"ERROR_015.size"),$sformatf("Mismatch AxSIZE between exclusive read and write with AxID=%0d.", waddr.size))
            end else if (excl_tracker_q[idx[0]].burst != waddr.burst) begin
               `uvm_error($sformatf("%0s.%0s", get_full_name(),"ERROR_015.burst"),$sformatf("Mismatch AxBURST between exclusive read and write with AxID=%0d.", waddr.burst))
            end else if (excl_tracker_q[idx[0]].lock != waddr.lock) begin
               `uvm_error($sformatf("%0s.%0s", get_full_name(),"ERROR_015.lock"),$sformatf("Mismatch AxLOCK between exclusive read and write with AxID=%0d.", waddr.lock))
            end else if (excl_tracker_q[idx[0]].cache != waddr.cache) begin
               `uvm_error($sformatf("%0s.%0s", get_full_name(),"ERROR_015.cache"),$sformatf("Mismatch AxCACHE between exclusive read and write with AxID=%0d.", waddr.cache))
            end else if (excl_tracker_q[idx[0]].prot != waddr.prot) begin
               `uvm_error($sformatf("%0s.%0s", get_full_name(),"ERROR_015.prot"),$sformatf("Mismatch AxPROT between exclusive read and write with AxID=%0d.", waddr.prot))
            end else if (excl_tracker_q[idx[0]].qos != waddr.qos) begin
               `uvm_error($sformatf("%0s.%0s", get_full_name(),"ERROR_015.qos"),$sformatf("Mismatch AxQOS between exclusive read and write with AxID=%0d.", waddr.qos))
            end else if (excl_tracker_q[idx[0]].region != waddr.region) begin
               `uvm_error($sformatf("%0s.%0s", get_full_name(),"ERROR_015.region"),$sformatf("Mismatch AxREGION between exclusive read and write with AxID=%0d.", waddr.region))
            end else if (excl_tracker_q[idx[0]].user != waddr.user) begin
               `uvm_error($sformatf("%0s.%0s", get_full_name(),"ERROR_015.user"),$sformatf("Mismatch AxUSER between exclusive read and write with AxID=%0d.", waddr.user))
            end else begin
               $display("%0t: %0s: Detected exclusive write with matching exclusive read. AxID=0x%0x", $time, get_full_name(), waddr.id);
            end
         end
      end
   endfunction
   
   function bit[T::AXI_ADDR_WIDTH*2-1:0] get_lohi_addr(axi_addr_item_type raddr);
      bit[T::AXI_ADDR_WIDTH-1:0] low_addr;
      bit[T::AXI_ADDR_WIDTH-1:0] high_addr;
      
      if (raddr.burst == INCR) begin
         low_addr = raddr.addr;
         high_addr = raddr.addr/(1<<raddr.size)*(1<<raddr.size);
         high_addr = high_addr+((1<<raddr.size)*(raddr.len+1));
      end else if (raddr.burst == FIXED) begin
         low_addr = raddr.addr;
         high_addr = raddr.addr/(1<<raddr.size)*(1<<raddr.size);
         high_addr = high_addr+(1<<raddr.size);
      end else if (raddr.burst == WRAP) begin
         low_addr = raddr.addr/((1<<raddr.size)*(raddr.len+1))*((1<<raddr.size)*(raddr.len+1));
         high_addr = low_addr + ((1<<raddr.size)*(raddr.len+1));
      end
      return {low_addr,high_addr};
   endfunction

  `endprotect //end protected region
endclass // axi_model

`endif
