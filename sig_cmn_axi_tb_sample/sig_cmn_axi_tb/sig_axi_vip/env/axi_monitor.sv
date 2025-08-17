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
`ifndef axi_monitor__sv
 `define axi_monitor__sv

`include "axi_hdr.svh"

class axi_addr_monitor #(type T=axi_params) extends uvm_monitor;
   `uvm_component_param_utils(axi_addr_monitor#(T))

   //typedef T::axi_addr_item_t axi_addr_item_type;
   //typedef T::addr_if_t addr_if_type;
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

   addr_if_type addr_if;
   OpType   rwType;
   int 	   addr_width;
   bit prev_vld, prev_rdy;
   realtime vld_time;
   axi_port_cfg cfg;
   uvm_analysis_port#(axi_addr_item_type) axi_addr_aport;
   
   int bandwidth_cnt = 0;
   int backpressure_cnt = 0;

   `protect //begin protected region
   // [PJAP] -- added this fxn for performance metrics
   function int get_bandwidth_count();
      return bandwidth_cnt;
   endfunction

   // [PJAP] -- added this fxn for performance metrics
   function int get_backpressure_count();
      return backpressure_cnt;
   endfunction

   // [PJAP] -- added this fxn for performance metrics
   function void reset_bandwidth_count();
      bandwidth_cnt = 0;
   endfunction

   // [PJAP] -- added this fxn for performance metrics
   function void reset_backpressure_count();
      backpressure_cnt = 0;
   endfunction

   function new(string name="axi_addr_monitor", uvm_component parent=null);
      super.new(name, parent);
   endfunction // new

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      axi_addr_aport = new("axi_addr_aport", this);
   endfunction // build_phase
   
   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
   endfunction // connect_phase
   
   task reset_phase(uvm_phase phase);
//      phase.raise_objection(this);
      super.reset_phase(phase);
      
      //wait(addr_if.mon_cb.resetn == 1'b1);
      //repeat(10) @(addr_if.mon_cb);
      //`uvm_info(get_name(), "AXI_RESET_N deasserts", UVM_LOW)
//      phase.drop_objection(this);
   endtask // reset_phase

   task run_phase(uvm_phase phase);
      super.run_phase(phase);
      forever begin
	      @(addr_if.mon_cb);
      
         // [PJAP] Added section for performance metrics (bandwidth & backpressure counting)
         if(addr_if.mon_cb.AxVALID && addr_if.mon_cb.AxREADY && addr_if.mon_cb.resetn) begin
            bandwidth_cnt++;
         end
         if(addr_if.mon_cb.AxVALID && !addr_if.mon_cb.AxREADY && addr_if.mon_cb.resetn) begin
            backpressure_cnt++;
         end
         // [PJAP] End section

         if ((prev_vld == 0 && addr_if.mon_cb.AxVALID == 1) || (prev_vld==1 && prev_rdy==1 && addr_if.mon_cb.AxVALID == 1)) begin
            vld_time = $realtime/1ns;
         end
         if (addr_if.mon_cb.resetn == 1'b0) begin
            axi_addr_item_type tr;
            tr = axi_addr_item_type::type_id::create("tr", this);
            tr.rwType = AXI_RST;
            tr.start_time = $realtime/1ns;
            axi_addr_aport.write(tr);
 	 //end else if (addr_if.mon_cb.resetn == 1'b1 && addr_if.mon_cb.AxREADY == 1'b1 &&
         //addr_if.mon_cb.AxVALID == 1'b1) begin
         end else if (addr_if.mon_cb.resetn == 1'b1) begin
            if (cfg.en_early_addr_sampling == 0) begin
               if (addr_if.mon_cb.AxREADY == 1'b1 && addr_if.mon_cb.AxVALID == 1'b1) begin
                  sample_if();
               end
            end else begin
               if ((prev_vld == 0 && addr_if.mon_cb.AxVALID == 1) || (prev_vld==1 && prev_rdy==1 && addr_if.mon_cb.AxVALID == 1)) begin
                  sample_if();
               end
            end
	 end
         prev_vld = addr_if.mon_cb.AxVALID;
         prev_rdy = addr_if.mon_cb.AxREADY;
      end //forever
   endtask // run_phase
   task sample_if();
               axi_addr_item_type tr;
               tr = axi_addr_item_type::type_id::create("tr", this);
               tr.rwType = rwType;
               tr.id    = addr_if.mon_cb.AxID;
               tr.addr   = addr_if.mon_cb.AxADDR;
               tr.len    = addr_if.mon_cb.AxLEN;
               tr.size   = addr_if.mon_cb.AxSIZE;
               tr.burst  = addr_if.mon_cb.AxBURST;
               if (cfg.en_axlock_masking == 1) begin 
                  tr.lock   = 0;
               end else begin
                  tr.lock   = addr_if.mon_cb.AxLOCK;
               end
               tr.cache  = addr_if.mon_cb.AxCACHE;
               tr.prot   = addr_if.mon_cb.AxPROT;
               tr.qos    = addr_if.mon_cb.AxQOS;
               tr.region = addr_if.mon_cb.AxREGION;
               tr.user   = addr_if.mon_cb.AxUSER;
	       tr.gpio   = addr_if.mon_cb.AxGPIO;
               tr.busSize = T::AXI_ADDR_WIDTH; //addr_width;
               //$display("%0t: AXI_ADDR_MON: aport.write addr=0x%0x", $time, tr.addr);
               tr.start_time = $realtime/1ns;
               tr.vld_time = vld_time;
               axi_addr_aport.write(tr);
   endtask 
   `endprotect //end protected region
endclass // axi_addr_monitor

class axi_data_monitor #(type T=axi_params) extends uvm_monitor;
   `uvm_component_param_utils(axi_data_monitor#(T))

   //typedef T::axi_data_item_t axi_data_item_type;
   //typedef T::data_if_t data_if_type;
   typedef axi_data_item#(
     .AXI_ID_WIDTH(T::AXI_ID_WIDTH),
     .AXI_DATA_WIDTH(T::AXI_DATA_WIDTH),
     .AXI_STRB_WIDTH(T::AXI_STRB_WIDTH),
     .AXI_RESP_WIDTH(T::AXI_RESP_WIDTH),
     .AXI_USER_WIDTH(T::AXI_USER_WIDTH)
   ) axi_data_item_type;
  typedef virtual axi_data_inf #(
    .ID_WIDTH     (T::AXI_ID_WIDTH),
    .DATA_WIDTH   (T::AXI_DATA_WIDTH), 
    .STRB_WIDTH   (T::AXI_STRB_WIDTH),
    .USER_WIDTH   (T::AXI_USER_WIDTH),
    .RESP_WIDTH   (T::AXI_RESP_WIDTH)
  ) data_if_type;

   data_if_type data_if;
   OpType   rwType;
   int 	   data_width;
   axi_port_cfg cfg;
   bit prev_vld, prev_rdy;
   realtime vld_time;
   
   int bandwidth_cnt = 0;
   int backpressure_cnt = 0;
   bit do_sw_reset = 0;
   
   uvm_analysis_port#(axi_data_item_type) axi_data_aport;
   uvm_analysis_port#(axi_data_item_type) axi_partial_data_aport;
   uvm_analysis_port#(axi_data_item_type) axi_dvalid_assert_aport;

   `protect //begin protected region
   // [PJAP] -- added this fxn for performance metrics
   function int get_bandwidth_count();
      return bandwidth_cnt;
   endfunction

   // [PJAP] -- added this fxn for performance metrics
   function int get_backpressure_count();
      return backpressure_cnt;
   endfunction

   // [PJAP] -- added this fxn for performance metrics
   function void reset_bandwidth_count();
      bandwidth_cnt = 0;
   endfunction

   // [PJAP] -- added this fxn for performance metrics
   function void reset_backpressure_count();
      backpressure_cnt = 0;
   endfunction


   function new(string name="axi_data_monitor", uvm_component parent=null);
      super.new(name, parent);
   endfunction // new

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      axi_data_aport = new("axi_data_aport", this);
      axi_partial_data_aport = new("axi_partial_data_aport", this);
      axi_dvalid_assert_aport = new("axi_dvalid_assert_aport", this);
   endfunction // build_phase
   
   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
   endfunction // connect_phase
   
   task reset_phase(uvm_phase phase);
//      phase.raise_objection(this);
      //super.reset_phase(phase);
      //wait(data_if.mon_cb.resetn == 1'b1);
      //repeat(10) @(data_if.mon_cb);
      //`uvm_info(get_name(), "AXI_RESET_N deasserts", UVM_LOW)
//      phase.drop_objection(this);
   endtask // reset_phase

   task reset_monitor();
      while(data_if.mon_cb.resetn == 1) begin
         @(data_if.mon_cb);
      end
      //reset flags
   endtask

   task sw_reset_seq();
      while (do_sw_reset == 0) begin
         @(data_if.mon_cb);
      end
      //do_sw_reset = 0;
   endtask

   task run_phase(uvm_phase phase);
      @(data_if.mon_cb);
      forever begin
         fork
            begin
               fork
                  reset_monitor();
                  sample_data();
                  sw_reset_seq();
               join_any
            end //fork
         join
         disable fork;
         while(data_if.mon_cb.resetn !== 1 || do_sw_reset == 1) begin
            @(data_if.mon_cb);
         end
      end //forever
   endtask

   task sample_data();
      axi_data_item_type data_q[$], data_obj, partial_obj, assert_obj;
      int idx[$];
      RespCode resp;
      bit last_detected = 1;

      data_q.delete();

      forever begin
         @(data_if.mon_cb);
      
         // [PJAP] Added section for performance metrics (bandwidth & backpressure counting)
         if(data_if.mon_cb.xVALID && data_if.mon_cb.xREADY && data_if.mon_cb.resetn) begin
            bandwidth_cnt++;
         end
         if(data_if.mon_cb.xVALID && !data_if.mon_cb.xREADY && data_if.mon_cb.resetn) begin
            backpressure_cnt++;
         end
         // [PJAP] End section

         if (data_if.mon_cb.resetn) begin
            if ((prev_vld == '0 && data_if.mon_cb.xVALID == '1) || (prev_vld == '1 && prev_rdy == '1 && data_if.mon_cb.xVALID == '1)) begin
               assert_obj = axi_data_item_type::type_id::create("assert_obj", this);
               assert_obj.rwType = rwType;
               assert_obj.id = (cfg.version == AXI4 && rwType == WRITE) ? '0 : data_if.mon_cb.xID;
               idx.delete();
               idx = data_q.find_first_index(x) with (x.id == assert_obj.id);
               //$display("%0t: %0s DBG_axi_dvld: id=0x%0x, idx.size=%0d", $time, get_full_name(), assert_obj.id, idx.size()); 
               if (idx.size() == 0) begin
                  axi_dvalid_assert_aport.write(assert_obj);
                  //$display("%0t: %0s DBG_axi_dvalid_assert_aport: rwType=%0s, id=0x%0x", $time, get_full_name(), assert_obj.rwType, assert_obj.id);
               end
            end // vld_asserted
            if ((prev_vld == 0 && data_if.mon_cb.xVALID == 1 && last_detected) || 
            (prev_vld==1 && prev_rdy==1 && data_if.mon_cb.xVALID == 1 && last_detected)) begin
               last_detected = 0;
               vld_time = $realtime/1ns;
               //$display("%0t %0s: set vld_time=%0t", $time, get_full_name(), vld_time);
            end
            if (data_if.mon_cb.xREADY == 1'b1 && data_if.mon_cb.xVALID == 1'b1) begin
               //$display("%0t: AXI_MON: VLD_RDY id=0x%0x, data=0x%0x", $time, data_if.mon_cb.xID, data_if.mon_cb.xDATA);
               $cast(resp, data_if.mon_cb.xRESP);
               partial_obj = axi_data_item_type::type_id::create("partial_obj", this);
               partial_obj.rwType = rwType;
               partial_obj.data.push_back(data_if.mon_cb.xDATA);
               partial_obj.user.push_back(data_if.mon_cb.xUSER);
               partial_obj.id = (cfg.version == AXI4 && rwType == WRITE) ? '0 : data_if.mon_cb.xID;
               partial_obj.strb.push_back(data_if.mon_cb.xSTRB);
               partial_obj.resp.push_back(resp);
               partial_obj.not_last = (data_if.mon_cb.xLAST) ? 0 : 1;
               partial_obj.start_time = $realtime/1ns;
               partial_obj.vld_time = vld_time;
               axi_partial_data_aport.write(partial_obj);
               last_detected = (data_if.mon_cb.xLAST) ? 1 : 0; 
               idx.delete();
               idx = data_q.find_first_index(x) with (x.id == partial_obj.id);//data_if.mon_cb.xID);
               if (idx.size() == 0) begin // IF DATA IS 1ST BEAT OF DIFFERENT BURST
                  $cast(resp, data_if.mon_cb.xRESP);
                  data_obj = axi_data_item_type::type_id::create("data_obj", this);
                  data_obj.rwType = rwType;
                  data_obj.data.push_back(data_if.mon_cb.xDATA);
                  data_obj.user.push_back(data_if.mon_cb.xUSER);
                  data_obj.id = (cfg.version == AXI4 && rwType == WRITE) ? '0 : data_if.mon_cb.xID;
                  data_obj.strb.push_back(data_if.mon_cb.xSTRB);
                  data_obj.resp.push_back(resp);
                  data_obj.start_time = $realtime/1ns;
                  data_obj.vld_time = vld_time;
                  if (data_if.mon_cb.xLAST) begin
                     data_obj.end_time = $realtime/1ns;
                     axi_data_aport.write(data_obj);
                  end else begin
                     data_q.push_back(data_obj);
                  end //if last
               end else begin // IF DATA IS SUCCEEDING BEAT OF EXISTING BURST
                  //$display("%0t: %0s: SUCCEEDING BEAT LAST=%0d", $time, get_full_name(), data_if.mon_cb.xLAST);
                  $cast(resp, data_if.mon_cb.xRESP);
                  data_q[idx[0]].data.push_back(data_if.mon_cb.xDATA); 
                  data_q[idx[0]].user.push_back(data_if.mon_cb.xUSER);
                  data_q[idx[0]].strb.push_back(data_if.mon_cb.xSTRB);
                  data_q[idx[0]].resp.push_back(resp);
                  if (data_if.mon_cb.xLAST) begin
                     data_q[idx[0]].end_time = $realtime/1ns;
                     axi_data_aport.write(data_q[idx[0]]);//data_obj);
                     data_q.delete(idx[0]);
                  end else begin
                    //data_q.push_back(data_obj);
                  end //if last
               end //if idx
            end //if vld-rdy handshake
         end // if not reset
         prev_vld = data_if.mon_cb.xVALID;
         prev_rdy = data_if.mon_cb.xREADY;
      end //forever
   endtask
   `endprotect //end protected region   
endclass // axi_slv_data_monitor

class axi_resp_monitor #(type T=axi_params) extends uvm_monitor;
   `uvm_component_param_utils(axi_resp_monitor#(T))

   //typedef T::axi_resp_item_t axi_resp_item_type;
   //typedef T::resp_if_t resp_if_type;
  typedef virtual axi_resp_inf #(
    .ID_WIDTH     (T::AXI_ID_WIDTH),
    .RESP_WIDTH   (T::AXI_RESP_WIDTH),
    .USER_WIDTH   (T::AXI_USER_WIDTH)
  ) resp_if_type;
   typedef axi_resp_item #(
     .AXI_ID_WIDTH (T::AXI_ID_WIDTH),
     .AXI_RESP_WIDTH (T::AXI_RESP_WIDTH),
     .AXI_USER_WIDTH (T::AXI_USER_WIDTH)
   ) axi_resp_item_type;


   resp_if_type resp_if;
   OpType   rwType;
   int 	   id_width;
   bit prev_vld, prev_rdy;
   realtime vld_time;
   
   int bandwidth_cnt = 0;
   int backpressure_cnt = 0;
   
   uvm_analysis_port#(axi_resp_item_type) axi_resp_aport;
   uvm_analysis_port#(axi_resp_item_type) axi_bvalid_assert_aport;

   `protect //begin protected region
   // [PJAP] -- added this fxn for performance metrics
   function int get_bandwidth_count();
      return bandwidth_cnt;
   endfunction

   // [PJAP] -- added this fxn for performance metrics
   function int get_backpressure_count();
      return backpressure_cnt;
   endfunction

   // [PJAP] -- added this fxn for performance metrics
   function void reset_bandwidth_count();
      bandwidth_cnt = 0;
   endfunction

   // [PJAP] -- added this fxn for performance metrics
   function void reset_backpressure_count();
      backpressure_cnt = 0;
   endfunction


   function new(string name="axi_resp_monitor", uvm_component parent=null);
      super.new(name, parent);
   endfunction // new

   function void print_params();
      $display("%0s params:", get_full_name());
      $display("AXI_ID_WIDTH   = %0d",    T::AXI_ID_WIDTH);
      $display("AXI_RESP_WIDTH = %0d",T::AXI_RESP_WIDTH);
      $display("AXI_USERWIDTH = %0d",T::AXI_USER_WIDTH);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      //print_params();
      axi_resp_aport = new("axi_resp_aport", this);
      axi_bvalid_assert_aport = new("axi_bvalid_assert_aport", this);
   endfunction // build_phase
   
   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
   endfunction // connect_phase
   
   task reset_phase(uvm_phase phase);
//      phase.raise_objection(this);
      //super.reset_phase(phase);
      //wait(resp_if.mon_cb.resetn == 1'b1);
      //repeat(10) @(resp_if.mon_cb);
      //`uvm_info(get_name(), "AXI_RESET_N deasserts", UVM_LOW)
//      phase.drop_objection(this);
   endtask // reset_phase

   task run_phase(uvm_phase phase);
      axi_resp_item_type tr;

      super.run_phase(phase);
      forever begin
	      @(resp_if.mon_cb);
      
         // [PJAP] Added section for performance metrics (bandwidth & backpressure counting)
         if(resp_if.mon_cb.BVALID && resp_if.mon_cb.BREADY && resp_if.mon_cb.resetn) begin
            bandwidth_cnt++;
         end
         if(resp_if.mon_cb.BVALID && !resp_if.mon_cb.BREADY && resp_if.mon_cb.resetn) begin
            backpressure_cnt++;
         end
         // [PJAP] End section

         if (resp_if.mon_cb.resetn && ((prev_vld == 0 && resp_if.mon_cb.BVALID == 1) || (prev_vld==1 && prev_rdy==1 && resp_if.mon_cb.BVALID == 1))) begin
            vld_time = $realtime/1ns;
            tr = axi_resp_item_type::type_id::create("tr", this);
            tr.rwType = rwType;
            tr.id = resp_if.mon_cb.BID;
            axi_bvalid_assert_aport.write(tr);
         end
	 if (resp_if.mon_cb.resetn == 1'b1 && resp_if.mon_cb.BREADY == 1'b1 &&
	    resp_if.mon_cb.BVALID == 1'b1) begin
	    tr = axi_resp_item_type::type_id::create("tr", this);
	    tr.rwType = rwType;
	    tr.id = resp_if.mon_cb.BID;
	    $cast(tr.resp,resp_if.mon_cb.BRESP);
            tr.user = resp_if.mon_cb.BUSER;
            tr.start_time = $realtime/1ns;
            tr.vld_time = vld_time;
	    axi_resp_aport.write(tr);
	 end
         prev_vld = resp_if.mon_cb.BVALID;
         prev_rdy = resp_if.mon_cb.BREADY;
      end
   endtask // run_phase
   `endprotect //end protected region   
endclass // axi_slv_addr_monitor

`endif
