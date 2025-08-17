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
import sig_axi_pkg::*;
import sys::*;

class sig_axi_write_interleaved_test extends sig_test_base;
   `uvm_component_utils(sig_axi_write_interleaved_test)

   typedef sys::axi_port_32x32x4::axi_data_item_t axi_data_item_type;
   typedef sys::axi_port_32x32x4::axi_resp_item_t axi_resp_item_type;

   function new(string name="", uvm_component parent);
      super.new(name, parent);
   endfunction // new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      $display("_DBG test build phase done");
   endfunction // build_phase

   task run_phase(uvm_phase phase);

      axi_data_item_type read_resp;
      axi_resp_item_type write_resp;
      
      sig_axi_req_vseq#(sys::axi_port_32x32x4) axi_req[];
      sig_axi_resps_vseq#(sys::axi_port_32x32x4) axi_resp;
      
      phase.raise_objection(this);
      $display("%0t:  TEST DBG", $time);

      //Reactive response sequence
      axi_resp = sig_axi_resps_vseq#(sys::axi_port_32x32x4)::type_id::create("axi_resp", this);

      fork
        axi_resp.slv_model = axi_env.slv_agents[0].slv_model;
        axi_resp.start(axi_env.vsqrs[0]);
      join_none

      //Issue 4 interleaved write transactions
      axi_req = new[4];
      foreach (axi_req[i]) begin
         axi_req[i] = sig_axi_req_vseq#(sys::axi_port_32x32x4)::type_id::create($sformatf("axi_req_%0d",i), this);
         axi_req[i].wait_done = 0;
         axi_req[i].not_last = 1;
         axi_req[i].data_len = 2; //master will only issue 2 transfers per burst
         axi_req[i].randomize() with {
            direction == WRITE;
            addr == 32'h1000_0000 * (i + 1);
            len == 15; //16 transfers
            id == i;
            size == $clog2(sys::axi_port_32x32x4::AXI_DATA_WIDTH/8);
            burst == INCR;
            addr_delay == 0;
         };
         axi_req[i].start(axi_env.vsqrs[0]);
      end
      //Interleave remaining 14 transfers for each burst
      for(int j=0; j<14; j++) begin
         foreach (axi_req[i]) begin
            axi_req[i].wait_done = 0;
            axi_req[i].not_last = (j < 13) ? 1 : 0;
            axi_req[i].data_len = 1; //master will only issue 1 transfer
            axi_req[i].just_data = 1;
            axi_req[i].start(axi_env.vsqrs[0]);
         end
      end



//      for (int i=0; i<16; i++) begin
//         axi_req = sig_axi_req_vseq#(sys::axi_port_32x32x4)::type_id::create("axi_req", this);
//         axi_req.randomize() with {
//            direction == WRITE;
//            addr == 32'h1234_0000 + 32'h1000 * i + i;
//            len == i;
//            id == i;
//            size == $clog2(sys::axi_port_32x32x4::AXI_DATA_WIDTH/8);
//            burst == INCR;
//            addr_delay == 0;
//         };
//         $display("direction = %0s, addr=0x%0x, data.size()=%0d", axi_req.direction.name(), axi_req.addr, axi_req.data.size());
//         axi_req.wait_done = 1;
//         axi_req.start(axi_env.vsqrs[0]);
//   
//         axi_req.direction = READ;
//         axi_req.addr_delay = 0;
//         axi_req.start(axi_env.vsqrs[0]); 
//      end

      wait (axi_env.vsqrs[0].is_busy() == 0);
      repeat(10)@(axi_env.slv_agents[0].awaddr_vif.mon_cb);

      phase.drop_objection(this);

   endtask // run_phase
   
endclass // sig_axi_write_interleaved_test
