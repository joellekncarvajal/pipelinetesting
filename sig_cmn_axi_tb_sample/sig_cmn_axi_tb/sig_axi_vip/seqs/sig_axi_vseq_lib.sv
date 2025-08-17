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
`ifndef sig_axi_vseq_lib__sv
 `define sig_axi_vseq_lib__sv

import uvm_pkg::*;
`include "uvm_macros.svh"
//import sig_axi_pkg::*;

class sig_axi_data_seq#(type T=sys::axi_params) extends uvm_sequence;
   `uvm_object_param_utils(sig_axi_data_seq#(T))

   //typedef T::axi_data_item_t axi_data_item_type;
   typedef axi_data_item#(
     .AXI_ID_WIDTH(T::AXI_ID_WIDTH),
     .AXI_DATA_WIDTH(T::AXI_DATA_WIDTH),
     .AXI_STRB_WIDTH(T::AXI_STRB_WIDTH),
     .AXI_RESP_WIDTH(T::AXI_RESP_WIDTH),
     .AXI_USER_WIDTH(T::AXI_USER_WIDTH)
   ) axi_data_item_type;

   rand OpType                        seq_direction;
   rand int unsigned                  seq_data_len;
   rand logic [T::AXI_ID_WIDTH-1:0]   seq_id;
   rand logic [T::AXI_DATA_WIDTH-1:0] seq_data[];
   rand logic [T::AXI_STRB_WIDTH-1:0] seq_strb[];
   rand logic [T::AXI_USER_WIDTH-1:0] seq_user[];
   rand RespCode                      seq_resp[];
   rand int unsigned                  seq_delay[];

   //Switches
   bit not_last = 0;

   constraint constant_ruser_c {
     foreach(seq_user[i]){
       seq_user[i] == seq_user[0];
     }
   }

   function new (string name="");
      super.new(name);
   endfunction // new

   virtual task body();
      axi_data_item_type data_item;
      bit ok;

      data_item = axi_data_item_type::type_id::create(.name("data_item"), .contxt(get_full_name()));
      start_item(data_item);
      ok = data_item.randomize() with {
         data_item.data_len     == seq_data_len;
         data_item.id           == seq_id;
         data_item.data.size()  == seq_data.size();
         data_item.strb.size()  == seq_strb.size();
         data_item.user.size()  == seq_user.size();
         data_item.resp.size()  == seq_resp.size();
         data_item.delay.size() == seq_delay.size();
      };
      foreach (data_item.data[i])  data_item.data[i]  = seq_data[i];
      foreach (data_item.strb[i])  data_item.strb[i]  = seq_strb[i];
      foreach (data_item.user[i])  data_item.user[i]  = seq_user[i];
      foreach (data_item.delay[i]) data_item.delay[i] = seq_delay[i];
      foreach (data_item.resp[i])  data_item.resp[i]  = seq_resp[i];
      data_item.not_last = not_last;
      finish_item(data_item);
   endtask

endclass

class sig_axi_resp_seq#(type T=sys::axi_params) extends uvm_sequence;
   `uvm_object_param_utils(sig_axi_resp_seq#(T))

//   typedef T::axi_resp_item_t axi_resp_item_type;
   typedef axi_resp_item #(
     .AXI_ID_WIDTH (T::AXI_ID_WIDTH),
     .AXI_RESP_WIDTH (T::AXI_RESP_WIDTH),
     .AXI_USER_WIDTH (T::AXI_USER_WIDTH)
   ) axi_resp_item_type;
   rand logic [T::AXI_ID_WIDTH-1:0]   seq_id;
   rand logic [T::AXI_USER_WIDTH-1:0] seq_user;
   rand RespCode                      seq_resp;
   rand int unsigned                  seq_delay;

   function new (string name="");
      super.new(name);
   endfunction // new

   virtual task body();
      axi_resp_item_type resp_item;
      bit ok;

      resp_item = axi_resp_item_type::type_id::create(.name("resp_item"), .contxt(get_full_name()));
      start_item(resp_item);
      ok = resp_item.randomize() with {
         resp_item.id    == seq_id; 
         resp_item.user  == seq_user;
         resp_item.resp  == seq_resp; 
         resp_item.delay == seq_delay;
      };
      finish_item(resp_item);
   endtask
endclass

class sig_axi_addr_seq#(type T=sys::axi_params) extends uvm_sequence;
   `uvm_object_param_utils(sig_axi_addr_seq#(T))

//   typedef T::axi_addr_item_t axi_addr_item_type;
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

   rand OpType                          seq_direction;
   rand logic [T::AXI_ID_WIDTH-1:0]     seq_id;
   rand logic [T::AXI_ADDR_WIDTH-1:0]   seq_addr;
   rand logic [T::AXI_LEN_WIDTH-1:0]    seq_len;
   rand logic [T::AXI_SIZE_WIDTH-1:0]   seq_size;
   rand BurstType                       seq_burst;
   rand LockType                        seq_lock;
   rand logic [T::AXI_CACHE_WIDTH-1:0]  seq_cache;
   rand logic [T::AXI_PROT_WIDTH-1:0]   seq_prot;
   rand logic [T::AXI_QOS_WIDTH-1:0]    seq_qos;
   rand logic [T::AXI_REGION_WIDTH-1:0] seq_region;
   rand logic [T::AXI_USER_WIDTH-1:0]   seq_auser;
   rand int unsigned                    seq_delay;
   rand AxGPIO                          seq_gpio;

   function new (string name="");
      super.new(name);
   endfunction // new

   virtual task body();
      axi_addr_item_type addr_item;
      bit ok;

      addr_item = axi_addr_item_type::type_id::create(.name("addr_item"), .contxt(get_full_name()));
      start_item(addr_item);
      ok = addr_item.randomize() with {
         addr_item.id     == seq_id;
         addr_item.addr   == seq_addr; 
         addr_item.len    == seq_len; 
         addr_item.size   == seq_size; 
         addr_item.burst  == seq_burst; 
         addr_item.lock   == seq_lock; 
         addr_item.cache  == seq_cache; 
         addr_item.prot   == seq_prot; 
         addr_item.qos    == seq_qos;
         addr_item.region == seq_region;
         addr_item.user   == seq_auser;
         addr_item.delay  == seq_delay; 
	 addr_item.gpio   == seq_gpio;
      };
      finish_item(addr_item);
   endtask

endclass

class sig_axi_req_vseq#(type T=sys::axi_params) extends uvm_sequence;
   `uvm_object_param_utils(sig_axi_req_vseq#(T))
   `uvm_declare_p_sequencer(axi_virtual_sequencer#(T))

   //typedef T::axi_addr_item_t axi_addr_item_type;
   //typedef T::axi_data_item_t axi_data_item_type;
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
   typedef axi_data_item#(
     .AXI_ID_WIDTH(T::AXI_ID_WIDTH),
     .AXI_DATA_WIDTH(T::AXI_DATA_WIDTH),
     .AXI_STRB_WIDTH(T::AXI_STRB_WIDTH),
     .AXI_RESP_WIDTH(T::AXI_RESP_WIDTH),
     .AXI_USER_WIDTH(T::AXI_USER_WIDTH)
   ) axi_data_item_type;

   rand OpType direction;
   rand logic [T::AXI_ID_WIDTH-1:0]     id;
   rand logic [T::AXI_ADDR_WIDTH-1:0]   addr;
   rand logic [T::AXI_LEN_WIDTH-1:0]    len;
   rand logic [T::AXI_SIZE_WIDTH-1:0]   size;
   rand BurstType                       burst;
   rand LockType                        alock;
   rand logic [T::AXI_CACHE_WIDTH-1:0]  cache;
   rand logic [T::AXI_PROT_WIDTH-1:0]   prot;
   rand logic [T::AXI_QOS_WIDTH-1:0]    qos;
   rand logic [T::AXI_REGION_WIDTH-1:0] region;
   rand logic [T::AXI_USER_WIDTH-1:0]   auser;
   rand int unsigned                    addr_delay;

   rand logic [T::AXI_DATA_WIDTH-1:0] data[];
   rand logic [T::AXI_STRB_WIDTH-1:0] strb[];
   rand logic [T::AXI_ID_WIDTH-1:0]   data_id; //[];
   rand logic [T::AXI_USER_WIDTH-1:0] duser[];
   rand int unsigned                  data_delay[];
   rand int unsigned                  total_bytes;
   rand AxGPIO                        gpio;

//   axi_system_memory#(T::AXI_ADDR_WIDTH) mem;

   //Switches
   bit is_interleaved = 0;
   bit not_last = 0;
   bit just_data = 0;
   int data_len = 0;
   AxiVer version = AXI3;
   bit enable_sparse_strb = '0;
   bit enable_const_ruser = 0;
   bit enable_const_wuser = 0;

   //Flags
   bit wait_done = 0;

   constraint exclusive_constraints {
      total_bytes == (len+1)*(1<<size);
   //alock len size addr
      if (alock == 'h1) {
         total_bytes <= 128;
         total_bytes != 0;
         len <= 15;
         (total_bytes & (total_bytes -1)) == '0;
         addr % total_bytes == '0;
      }
   }

   constraint addr_4k_constraints {
      (addr % 4096) + ((len+1) << size) <= 4096;
   }

   constraint axi3_constraints {
      if (version == AXI3) {
         len < 16;
         alock inside {0,1,2};
	 gpio == '0;
         if (direction == WRITE) {
            cache inside {'b0000,'b0001,'b0010,'b0011,'b0110,'b1010,'b1110,'b0111,'b1011,'b1111};
         } else {
            cache inside {'b0000,'b0001,'b0010,'b0011,'b1010,'b0110,'b1010,'b1110,'b1011,'b0111,'b1111};
         }
      }
   }

   constraint axi4_constraints {
      if (version == AXI4) {
         if (burst == INCR) {
            len < 256;
         } else {
            len < 16;
         }
         alock inside {0,1};
         if (direction == WRITE) {
            cache inside {'b0000,'b0001,'b0010,'b0011,'b0110,'b1110,'b0111,'b1111};
         } else {
            cache inside {'b0000,'b0001,'b0010,'b0011,'b1010,'b1110,'b1010,'b1110,'b1011,'b1111};
         }
      }
   }

   constraint axi4_lite_constraints {
      if (version == AXI4_LITE) {
         id == 0;
         len == 0;
         burst == 1;
         alock == 0;
         cache == 0;
	 gpio  == '0;
         size==$clog2(T::AXI_DATA_WIDTH/8);
      }
   }


   constraint axi_common_constraints {
      burst != RESERVED_burst;
      if (burst == WRAP) {
         addr % (1 << size) == 0;
         len inside {1, 3, 7, 15};
      }
   }

   constraint array_size_c {
      if (direction == WRITE) {
         data.size()       == (len+1);
         strb.size()       == (len+1);
         duser.size()      == (len+1);
         data_delay.size() == (len+1);
      } else {
         data.size()       == 0;
         strb.size()       == 0;
         duser.size()      == 0;
         data_delay.size() == 0;
      }
      data_id == id;
      size <= $clog2(T::AXI_DATA_WIDTH/8);
   }

   constraint no_delay_c {
     soft foreach (data_delay[i]) { data_delay[i] == '0; }
     soft addr_delay == 0;
   }

   constraint default_lock_c {
      alock == 0;
   }

   constraint default_prot_c {
      prot == 0;
   }

   constraint wuser_constant_c {
     if(enable_const_wuser) {
       foreach (duser[i]){
         duser[i] == duser[0];
       }
     }
   }

   constraint exclusive_c {
      if (alock == 'h1) {
         len < 16;
         (len+1)*(1<<size) inside {1,2,4,8,16,32,64,128};
      }
   }

   //re-randomize and constrain for write transaction to read transaction
   function void write_to_read();
      bit [3:0] arcache;
      
      if(direction == WRITE) begin
         direction = READ;
         case(cache)
            4'b0110 : if(version == AXI3) begin
                         std::randomize(arcache) with {arcache inside {4'b1010,4'b0110};}; 
                      end else begin
                         std::randomize(arcache) with {arcache inside {4'b1010,4'b1110};}; 
                      end
            4'b1110 : std::randomize(arcache) with {arcache inside {4'b1010,4'b1110};};
            4'b0111 : if(version == AXI3) begin
                         std::randomize(arcache) with {arcache inside {4'b1011,4'b0111};}; 
                      end else begin
                         std::randomize(arcache) with {arcache inside {4'b1011,4'b1111};}; 
                      end
            4'b1111 : std::randomize(arcache) with {arcache inside {4'b1011,4'b1111};};
            default : arcache = cache; 
         endcase
         cache = arcache;

         data.delete();
         strb.delete();
         duser.delete();
         data_delay.delete();
      end
   endfunction

   function new (string name="");
      super.new(name);
   endfunction // new

   function void post_randomize();
      bit[T::AXI_STRB_WIDTH-1:0] strb_val;
      bit[T::AXI_ADDR_WIDTH-1:0] tmp_addr, lower_addr, upper_addr;
      int burst_size, byte_pos, byte_lane, offset;
      int wrap_size, loop_cnt, wrap_len, wrap_cnt=0;

   if (burst == INCR) begin
      tmp_addr = addr;
      burst_size = (1 << size);
      byte_pos = tmp_addr[$clog2(T::AXI_DATA_WIDTH/8)-1:0];
      byte_lane = byte_pos % burst_size;

      foreach (strb[i]) begin
         offset = (i==0) ? byte_lane : '0;
         strb_val = '1;
         strb_val = strb_val >> (T::AXI_STRB_WIDTH - burst_size);
         strb_val = (strb_val >> offset) << byte_pos;
         strb[i]  = (enable_sparse_strb) ? (strb[i] & strb_val) : strb_val;
	 //$display("%0t: addr=0x%0x - burst_size=%0d - byte_pos=%0d -byte_lane=%0d- strb_val[%0d]=0x%0x(4'b%4b)", $time, addr, burst_size, byte_pos, byte_lane, i, strb_val, strb_val);
         byte_pos = ((byte_pos/burst_size * burst_size)+burst_size) % (T::AXI_DATA_WIDTH/8);
         byte_lane = byte_pos % burst_size;
      end
   end else if (burst == FIXED) begin
      tmp_addr = addr;
      burst_size = (1 << size);
      byte_pos = tmp_addr[$clog2(T::AXI_DATA_WIDTH/8)-1:0];
      byte_lane = byte_pos % burst_size;
      offset = byte_lane;
      strb_val = '1;
      strb_val = strb_val >> (T::AXI_STRB_WIDTH - burst_size);
      strb_val = (strb_val >> offset) << byte_pos;
      foreach (strb[i]) begin
         //strb[i]  = strb_val;
         strb[i]  = (enable_sparse_strb) ? (strb[i] & strb_val) : strb_val;
      end
   end else if (burst == WRAP) begin
      wrap_cnt = 0;
      burst_size = (1 << size);
      wrap_size = (len+1)*(1<<size);
      tmp_addr = addr;
      lower_addr = addr / wrap_size * wrap_size;
      upper_addr = lower_addr + wrap_size - 1;
      loop_cnt = (lower_addr == addr) ? 1 : 2;
      //$display("burst=%0d, addr=%0x, lower_addr=%0x, upper_addr=%0x, loop_cnt=%0d", burst, addr,lower_addr,upper_addr,loop_cnt );
      for (int h=0; h<loop_cnt; h++) begin
         byte_pos = (h==0) ? (tmp_addr[$clog2(T::AXI_DATA_WIDTH/8)-1:0]) : (lower_addr[$clog2(T::AXI_DATA_WIDTH/8)-1:0]);
         byte_lane = byte_pos % burst_size;
         if (h==0) begin
            wrap_len = (upper_addr - tmp_addr + 1)/burst_size;
         end else begin
            wrap_len = (tmp_addr - lower_addr)/burst_size;
         end
         //$display(" - byte_pos=%0d, byte_lane=%0d, wrap_len=%0d", byte_pos, byte_lane, wrap_len);
         for (int g=0; g<wrap_len; g++) begin
               offset = (g==0) ? byte_lane : '0;
               strb_val = '1;
               strb_val = strb_val >> (T::AXI_STRB_WIDTH - burst_size);
               strb_val = (strb_val >> offset) << byte_pos;
               //strb[wrap_cnt] = strb_val;
               strb[wrap_cnt] = (enable_sparse_strb) ? (strb[wrap_cnt] & strb_val) : strb_val;
               //$display(" - offset");
               wrap_cnt++;
               byte_pos = ((byte_pos/burst_size * burst_size)+burst_size) % (T::AXI_DATA_WIDTH/8);
               byte_lane = byte_pos % burst_size;
         end
      end
   end
      if (direction == WRITE && (T::AXI_ID_WIDTH > T::AXI_WR_ID_WIDTH)) begin
         for(int i=0; i<T::AXI_ID_WIDTH-T::AXI_WR_ID_WIDTH; i++) begin
            id[T::AXI_WR_ID_WIDTH+i +: 1] = '0;
         end
      end else if (direction == READ && (T::AXI_ID_WIDTH > T::AXI_RD_ID_WIDTH)) begin
         for(int i=0; i<T::AXI_ID_WIDTH-T::AXI_RD_ID_WIDTH; i++) begin
            id[T::AXI_RD_ID_WIDTH+i +: 1] = '0;
         end
      end
   endfunction

   function void bkdr_write_to_mem(axi_system_memory#(T::AXI_ADDR_WIDTH) mem, bit invert_data);
      bit[7:0] data_w[$];
      bit      strb_w[$];
      bit[T::AXI_ADDR_WIDTH-1:0] beat_addr, next_addr;
      bit[7:0] data_byte;

      beat_addr = addr / T::AXI_STRB_WIDTH * T::AXI_STRB_WIDTH;
      next_addr = ((addr >> size) << size);
      foreach (data[i]) begin
         data_w.delete();
         strb_w.delete();
         for (int j=0; j<T::AXI_STRB_WIDTH; j++) begin
            data_byte = (invert_data) ? ~data[i][(j*8) +: 8] : data[i][(j*8) +: 8];
            data_w.push_back(data_byte);
            strb_w.push_back(strb[i][j]);
         end
         //$display("%0t: bkdr_write_to_mem: addr=0x%0x", $time, beat_addr);
         mem.writeMem(beat_addr,data_w,strb_w);
         if (burst == INCR) begin
            next_addr = ((addr >> size) << size) + ((1<<size)*(i+1));
            beat_addr = next_addr / T::AXI_STRB_WIDTH * T::AXI_STRB_WIDTH;
//            beat_addr = beat_addr + (T::AXI_STRB_WIDTH);
         end else if (burst == FIXED) begin
         end else if (burst == WRAP) begin
            next_addr = ((addr >> size) << size) + ((1<<size)*(i+1));
            if ((next_addr) > (addr/((1<<size)*(len+1))*((1<<size)*(len+1)) + ((1<<size)*(len+1))) ) begin
               next_addr = (addr/((1<<size)*(len+1))*((1<<size)*(len+1)));
            end
            beat_addr = next_addr / T::AXI_STRB_WIDTH * T::AXI_STRB_WIDTH;
//            beat_addr = beat_addr + (T::AXI_STRB_WIDTH);
//            if ((beat_addr) > (addr/((1<<size)*(len+1))*((1<<size)*(len+1)) + ((1<<size)*(len+1))) ) begin
//               beat_addr = (addr/((1<<size)*(len+1))*((1<<size)*(len+1)));
//            end
         end
      end
   endfunction

   virtual task body();
      sig_axi_addr_seq#(T) addr_seq;
      sig_axi_data_seq#(T) data_seq;
      bit addr_done = 0, data_done = 0;

      fork
         begin
            if (just_data == 0) begin
               addr_done = 0;
               addr_seq = sig_axi_addr_seq#(T)::type_id::create(.name("addr_seq"), .contxt(get_full_name()));
               addr_seq.randomize() with {
                  addr_seq.seq_direction == direction; 
                  addr_seq.seq_id        == id;
                  addr_seq.seq_addr      == addr; 
                  addr_seq.seq_len       == len;
                  addr_seq.seq_size      == size; 
                  addr_seq.seq_burst     == burst; 
                  addr_seq.seq_lock      == alock; 
                  addr_seq.seq_cache     == cache; 
                  addr_seq.seq_prot      == prot; 
                  addr_seq.seq_qos       == qos; 
                  addr_seq.seq_region    == region; 
                  addr_seq.seq_auser     == auser; 
                  addr_seq.seq_delay     == addr_delay;
		  addr_seq.seq_gpio      == gpio; 
               };
	       //$display("DBG Mike: addr_seq.pressure = %0d, addr_seq.hurry = %0d, gpio = %0d", addr_seq.seq_gpio[3:0], addr_seq.seq_gpio[4], gpio); 
               if (direction == WRITE) begin
                  p_sequencer.pending_waddr_cnt++;
                  addr_seq.start(p_sequencer.waddr_sqr);
                  p_sequencer.pending_waddr_cnt--;
                  addr_done = 1;
               end else begin
                  p_sequencer.pending_raddr_cnt++;
                  addr_seq.start(p_sequencer.raddr_sqr);
                  p_sequencer.pending_raddr_cnt--;
                  addr_done = 1;
               end
            end // just data
         end //branch 1
         begin
            data_done = 0;
            if (direction == WRITE) begin
               data_seq = sig_axi_data_seq#(T)::type_id::create(.name("data_seq"), .contxt(get_full_name()));
               if(!enable_const_ruser) begin
                  data_seq.constant_ruser_c.constraint_mode(0);
               end
               data_seq.not_last = not_last;
               data_len = (not_last || just_data) ? data_len : len+1;
               data_seq.randomize() with {
                  data_seq.seq_direction    == WRITE;
                  data_seq.seq_data_len     == data_len;
                  data_seq.seq_id           == data_id;     //.size()    == data_id.size();
                  data_seq.seq_data.size()  == data.size();
                  data_seq.seq_strb.size()  == strb.size();
                  data_seq.seq_user.size()  == duser.size();
                  data_seq.seq_delay.size() == data_delay.size();
               };
               //$display("DBG: data_seq.seq_data_len = %0d, not_last=%0d, data_len=%0d", data_seq.seq_data_len, not_last, data_len); 
               foreach (data_seq.seq_data[i])  data_seq.seq_data[i] = data[i];
               foreach (data_seq.seq_strb[i])  data_seq.seq_strb[i] = strb[i];
               foreach (data_seq.seq_user[i])  data_seq.seq_user[i] = duser[i];
               foreach (data_seq.seq_delay[i]) data_seq.seq_delay[i] = data_delay[i];
               p_sequencer.pending_wdata_cnt++;
               data_seq.start(p_sequencer.wdata_sqr);
               p_sequencer.pending_wdata_cnt--;
               data_done = 1;
            end else begin
               data_done = 1;
            end 
         end //2nd branch
      join_none

      //$display("%0t: WAIT_DONE is set to %0d. %0s mode", $time, wait_done, direction.name());
      if (wait_done == 1) begin
         fork
            begin
               wait (addr_done == 1);         
               //$display("%0t: ADDR_DONE %0s", $time, direction.name());
            end
            begin
               wait (data_done == 1);
               //$display("%0t: DATA_DONE %0s", $time, direction.name());
            end
         join
      end
   endtask // body
endclass // sig_axi_req_vseq

class sig_axi_resps_vseq#(type T=sys::axi_params) extends uvm_sequence;
   `uvm_object_param_utils(sig_axi_resps_vseq#(T))
   `uvm_declare_p_sequencer(axi_virtual_sequencer#(T))

   //typedef T::axi_data_item_t axi_data_item_type;
   //typedef T::axi_resp_item_t axi_resp_item_type;
   typedef axi_data_item#(
     .AXI_ID_WIDTH(T::AXI_ID_WIDTH),
     .AXI_DATA_WIDTH(T::AXI_DATA_WIDTH),
     .AXI_STRB_WIDTH(T::AXI_STRB_WIDTH),
     .AXI_RESP_WIDTH(T::AXI_RESP_WIDTH),
     .AXI_USER_WIDTH(T::AXI_USER_WIDTH)
   ) axi_data_item_type;
   typedef axi_resp_item #(
     .AXI_ID_WIDTH (T::AXI_ID_WIDTH),
     .AXI_RESP_WIDTH (T::AXI_RESP_WIDTH),
     .AXI_USER_WIDTH (T::AXI_USER_WIDTH)
   ) axi_resp_item_type;

   axi_data_item_type user_rresp_q[$], rresp;
   axi_resp_item_type user_bresp_q[$], bresp;
   
   axi_model#(T) slv_model;

   rand OpType direction;
   rand logic [T::AXI_ID_WIDTH-1:0]     id;
   bit enable_interleaved = 0;
   bit enable_out_of_order = 0;
   bit randomize_user_signal = 1;
   bit loop_user_resp = 0, shuffle_user_resp = 0;
   int rresp_ooo_limit, rresp_ooo_cnt, rresp_ooo_threshold;
   int wresp_ooo_limit, wresp_ooo_cnt, wresp_ooo_threshold;
   int ooo_timeout = 1000;
   bit [T::AXI_ID_WIDTH-1:0] rid_q[$], wid_q[$];
   int initial_rresp_dly=0, initial_bresp_dly=0;
   bit enable_const_ruser = 0;

   function new (string name="");
      super.new(name);
   endfunction // new

   function push_user_bresp(RespCode bresp_val, bit[T::AXI_USER_WIDTH-1:0] user_val='0, int delay_val='0);
      axi_resp_item_type user_bresp;
      user_bresp  = axi_resp_item_type::type_id::create("user_bresp");
      user_bresp.resp  = bresp_val;
      user_bresp.user  = user_val;
      user_bresp.delay = delay_val;
      user_bresp_q.push_back(user_bresp);
   endfunction

   function push_user_rresp(RespCode rresp_val[]);
      axi_data_item_type user_rresp;
      user_rresp  = axi_data_item_type::type_id::create("user_rresp");
      foreach(rresp_val[i]) begin
         user_rresp.resp.push_back(rresp_val[i]);
      end
      user_rresp_q.push_back(user_rresp);
   endfunction

   task return_interleaved_rresp();
      sig_axi_data_seq#(T) rresp_seq;
      axi_data_item_type   user_rresp;

      forever begin
         wait (slv_model.outbound_rresp_Q.size() >0);
         //foreach (slv_model.outbound_rresp_Q[i]) begin
         for (int i=0; i<slv_model.outbound_rresp_Q.size(); i++) begin
            rresp_seq = sig_axi_data_seq#(T)::type_id::create(.name("rresp_seq"), .contxt(get_full_name()));
            if(!enable_const_ruser) begin
               rresp_seq.constant_ruser_c.constraint_mode(0);
            end
            rresp_seq.randomize() with {
               rresp_seq.seq_direction    == READ;
               rresp_seq.seq_data_len     == 1;
               rresp_seq.seq_id           == slv_model.outbound_rresp_Q[i].id;
               rresp_seq.seq_data.size()  == 1;
               rresp_seq.seq_user.size()  == 1;
               rresp_seq.seq_resp.size()  == 1;
               rresp_seq.seq_delay.size() == 1;
            };
            rresp_seq.not_last = (slv_model.outbound_rresp_Q[i].data.size() > 1) ? 1 : 0;
            rresp_seq.seq_data[0]  = slv_model.outbound_rresp_Q[i].data.pop_front();
            rresp_seq.seq_user[0]  = slv_model.outbound_rresp_Q[i].user.pop_front();
            rresp_seq.seq_resp[0]  = slv_model.outbound_rresp_Q[i].resp.pop_front();
            rresp_seq.seq_delay[0] = slv_model.outbound_rresp_Q[i].delay.pop_front(); 
            p_sequencer.pending_rdata_cnt++;
            rresp_seq.start(p_sequencer.rdata_sqr);
            p_sequencer.pending_rdata_cnt--;
            if (slv_model.outbound_rresp_Q[i].data.size() == 0) begin
               slv_model.outbound_rresp_Q.delete(i--);
            end
         end
      end
   endtask

   task return_rresp();
      sig_axi_data_seq#(T) rresp_seq;
      axi_data_item_type   user_rresp;
      bit initial_dly_done = 0;

      forever begin
         wait (slv_model.outbound_rresp_Q.size() >0);
         rresp = slv_model.outbound_rresp_Q.pop_front();
         //$display("%0t: return_rresp - rresp is below:", $time);
         //rresp.print();
         //modify rresp based on user input
         if (user_rresp_q.size() >0) begin
           if (shuffle_user_resp) begin
              user_rresp_q.shuffle();
           end
           user_rresp = user_rresp_q.pop_front();
           if (loop_user_resp) begin
              user_rresp_q.push_back(user_rresp);
           end
           if (user_rresp.data.size() > 0) begin
              foreach (user_rresp.data[i]) rresp.data[i] = user_rresp.data[i];
           end
           if (user_rresp.user.size() > 0) begin
              foreach (user_rresp.user[i]) rresp.user[i] = user_rresp.user[i];
           end
           if (user_rresp.resp.size() > 0) begin
              //foreach (user_rresp.resp[i]) rresp.resp[i] = user_rresp.resp[i];
              foreach (rresp.resp[i]) rresp.resp[i] = user_rresp.resp[i];
           end
         end
         rresp_seq = sig_axi_data_seq#(T)::type_id::create(.name("rresp_seq"), .contxt(get_full_name()));
         if(!enable_const_ruser) begin
            rresp_seq.constant_ruser_c.constraint_mode(0);
         end
         rresp_seq.randomize() with {
            rresp_seq.seq_direction    == READ;
            rresp_seq.seq_data_len     == rresp.data.size();
            rresp_seq.seq_id           == rresp.id;
            rresp_seq.seq_data.size()  == rresp.data.size();
            rresp_seq.seq_user.size()  == rresp.data.size();
            rresp_seq.seq_resp.size()  == rresp.data.size();
            rresp_seq.seq_delay.size() == rresp.data.size();
         };
         foreach (rresp_seq.seq_data[i])  rresp_seq.seq_data[i]  = rresp.data[i];
         if(!randomize_user_signal) begin
           foreach (rresp_seq.seq_user[i])  rresp_seq.seq_user[i]  = rresp.user[i];
         end
         foreach (rresp_seq.seq_resp[i])  rresp_seq.seq_resp[i]  = rresp.resp[i];
         foreach (rresp_seq.seq_delay[i]) rresp_seq.seq_delay[i] = rresp.delay[i];
         if (initial_dly_done == 0 && initial_rresp_dly != 0) begin
            rresp_seq.seq_delay[0] = initial_rresp_dly;
            initial_dly_done = 1;
         end
         p_sequencer.pending_rdata_cnt++;
         rresp_seq.start(p_sequencer.rdata_sqr);
         p_sequencer.pending_rdata_cnt--;
      end
   endtask

   task return_ooo_rresp();
      sig_axi_data_seq#(T) rresp_seq;
      axi_data_item_type   user_rresp;
      axi_data_item_type   shuffle_q[$], out_q[$];
      int uniq_idx[$], q_size;
      bit [T::AXI_ID_WIDTH-1:0] rslt_q[$];
      bit [T::AXI_ID_WIDTH-1:0] uniq_rid_q[$];
      bit is_timeout, stop_timeout;
      int count = 0;
      int shuffled_count;
      int insert_index;
      int idx[$];
      shuffled_count = 0;
      forever begin
         is_timeout = 0;
         stop_timeout = 0;
         count = 0;
      if (shuffled_count == 0) begin
         if (rresp_ooo_cnt <= (rresp_ooo_limit-rresp_ooo_threshold)) begin
            wait (slv_model.outbound_rresp_Q.size() > 0);
            fork
               begin
                  wait (slv_model.outbound_rresp_Q.size() > rresp_ooo_threshold || is_timeout);
                  stop_timeout=1;
               end
               begin
                  //$display("%0t: %0s wait ooo_timeout(%0d)", $time, get_full_name(), ooo_timeout);
                  while (count < ooo_timeout && stop_timeout==0) begin
                     #1ns;
                     count++;
                  end
                  //$display("%0t: %0s STOP_OOO wait ooo_timeout(%0d)", $time, get_full_name(), ooo_timeout);
                  is_timeout=1; 
               end
            join
            is_timeout = 0;
            stop_timeout = 0;
            count = 0;
         end else begin
            wait (slv_model.outbound_rresp_Q.size() > 0);
         end
         rid_q.delete();
         uniq_idx.delete();
         shuffle_q.delete();
         out_q.delete();
         uniq_rid_q.delete();
         foreach (slv_model.outbound_rresp_Q[i]) begin
            //$display("%0t: %0s: rid_q.push_back(%0d)", $time, get_full_name(), slv_model.outbound_rresp_Q[i].id);
            rid_q.push_back(slv_model.outbound_rresp_Q[i].id);
         end
         uniq_rid_q = rid_q.unique();
         uniq_rid_q.shuffle();
         //$display("%0t: %0s: uniq_rid_q = %p", $time, get_full_name(), uniq_rid_q);
         //if (en_interleaved) begin
             while (slv_model.outbound_rresp_Q.size() > 0) begin
                //$display("%0t: %0s: slv_model.outbound_rresp_Q.size = %0d", $time, get_full_name(), slv_model.outbound_rresp_Q.size());
                foreach (uniq_rid_q[i]) begin
                   idx.delete();
                   idx = slv_model.outbound_rresp_Q.find_first_index with (item.id == uniq_rid_q[i]);
                   //$display(" - idx.size = %0d", idx.size());
                   if (idx.size() > 0) begin
                      out_q.push_back(slv_model.outbound_rresp_Q[idx[0]]);
                      slv_model.outbound_rresp_Q.delete(idx[0]);
                   end
                end
             end
         //end else begin
         //end
////         uniq_idx = rid_q.unique_index();
//         foreach (rid_q[i]) begin
//            rslt_q = rid_q.find with (item == rid_q[i]);
//            if (rslt_q.size() == 1) begin
//               uniq_idx.push_back(i);
//            end
//         end
//         $display("uniq_idx.size=%0d, [%p]", uniq_idx.size(), uniq_idx);
//         q_size = slv_model.outbound_rresp_Q.size();
//         for (int i = 0; i < q_size; i++) begin
//            if (i inside uniq_idx) begin
//               shuffle_q.push_back(slv_model.outbound_rresp_Q.pop_front());
//            end else begin
//               out_q.push_back(slv_model.outbound_rresp_Q.pop_front());
//            end
//         end
//         shuffle_q.shuffle();
//         q_size = shuffle_q.size();
//         $display("shuffle_q.size=%0d, out_q.size()", shuffle_q.size(), out_q.size());
//         for (int i=0; i<q_size; i++) begin
//            if (out_q.size() == 0) begin
//               out_q.push_back(shuffle_q.pop_front());
//            end else begin
//               insert_index = $urandom_range(out_q.size()-1, 0);
//               out_q.insert(insert_index, shuffle_q.pop_front());
//            end
//         end
         //$display("%0t[%0s]: outbound_rresp_Q.size=%0d", $time, get_full_name(), slv_model.outbound_rresp_Q.size());
         q_size = out_q.size();
         for (int i = 0; i<q_size; i++) begin
            slv_model.outbound_rresp_Q.push_back(out_q.pop_front());
         end
         shuffled_count = slv_model.outbound_rresp_Q.size();
         //$display("%0t[%0s]: shuffled_count is set to %0d", $time, get_full_name(),shuffled_count);
      end
         //$display("%0t[%0s]: outbound_rresp_Q.size=%0d", $time, get_full_name(), slv_model.outbound_rresp_Q.size());
         rresp = slv_model.outbound_rresp_Q.pop_front();
         shuffled_count--;
         //$display("%0t: return_rresp - shuffled_count = %0d:", $time, shuffled_count);
         //rresp.print();
         //modify rresp based on user input
         if (user_rresp_q.size() >0) begin
           if (shuffle_user_resp) begin
              user_rresp_q.shuffle();
           end
           user_rresp = user_rresp_q.pop_front();
           if (loop_user_resp) begin
              user_rresp_q.push_back(user_rresp);
           end
           if (user_rresp.data.size() > 0) begin
              foreach (user_rresp.data[i]) rresp.data[i] = user_rresp.data[i];
           end
           if (user_rresp.user.size() > 0) begin
              foreach (user_rresp.user[i]) rresp.user[i] = user_rresp.user[i];
           end
           if (user_rresp.resp.size() > 0) begin
              foreach (user_rresp.resp[i]) rresp.resp[i] = user_rresp.resp[i];
           end
         end
         rresp_seq = sig_axi_data_seq#(T)::type_id::create(.name("rresp_seq"), .contxt(get_full_name()));
         if(!enable_const_ruser) begin
            rresp_seq.constant_ruser_c.constraint_mode(0);
         end
         rresp_seq.randomize() with {
            rresp_seq.seq_direction    == READ;
            rresp_seq.seq_data_len     == rresp.data.size();
            rresp_seq.seq_id           == rresp.id;
            rresp_seq.seq_data.size()  == rresp.data.size();
            rresp_seq.seq_user.size()  == rresp.data.size();
            rresp_seq.seq_resp.size()  == rresp.data.size();
            rresp_seq.seq_delay.size() == rresp.data.size();
         };
         foreach (rresp_seq.seq_data[i])  rresp_seq.seq_data[i]  = rresp.data[i];
         foreach (rresp_seq.seq_user[i])  rresp_seq.seq_user[i]  = rresp.user[i];
         foreach (rresp_seq.seq_resp[i])  rresp_seq.seq_resp[i]  = rresp.resp[i];
         foreach (rresp_seq.seq_delay[i]) rresp_seq.seq_delay[i] = rresp.delay[i];
         p_sequencer.pending_rdata_cnt++;
         rresp_seq.start(p_sequencer.rdata_sqr);
         p_sequencer.pending_rdata_cnt--;
         rresp_ooo_cnt++;
      end
   endtask

   task return_bresp();
      sig_axi_resp_seq#(T) bresp_seq;
      axi_resp_item_type   user_bresp;
      bit initial_dly_done = 0;

      forever begin
         wait (slv_model.outbound_bresp_Q.size() > 0);
         bresp = slv_model.outbound_bresp_Q.pop_front();
         if (user_bresp_q.size() >0) begin
            if (shuffle_user_resp) begin
               user_bresp_q.shuffle();
            end
            //modify bresp based on user input
            user_bresp = user_bresp_q.pop_front();
            bresp.resp = user_bresp.resp;
            bresp.user = user_bresp.user;
            bresp.delay = user_bresp.delay;
            if (loop_user_resp) begin
               user_bresp_q.push_back(user_bresp);
            end
         end
         bresp_seq = sig_axi_resp_seq#(T)::type_id::create(.name("bresp_seq"), .contxt(get_full_name()));
         bresp_seq.randomize() with {
            bresp_seq.seq_id    == bresp.id;
            if(!randomize_user_signal){
              bresp_seq.seq_user  == bresp.user;
            }
            bresp_seq.seq_resp  == bresp.resp;
            bresp_seq.seq_delay == bresp.delay;
         };
         if (initial_dly_done == 0 && initial_bresp_dly != 0) begin
            bresp_seq.seq_delay = initial_bresp_dly;
            initial_dly_done = 1;
         end
         p_sequencer.pending_wresp_cnt++;
         //$display("%0t: RETURN_BRESP ID=0x%0x RESP=0x%0x",$time, bresp_seq.seq_id, bresp_seq.seq_resp);
         bresp_seq.start(p_sequencer.bresp_sqr);
         p_sequencer.pending_wresp_cnt--;
      end
   endtask

   task return_ooo_bresp();
      sig_axi_resp_seq#(T) bresp_seq;
      axi_resp_item_type   user_bresp;
      axi_resp_item_type   shuffle_q[$], out_q[$];
      bit is_timeout = 0;
      bit stop_timeout = 0;
      int count = 0;
      int wresp_cnt;

fork
   begin
      wait (slv_model.outbound_bresp_Q.size() > 0);
      forever begin
         is_timeout = 0;
         stop_timeout = 0;
         count = 0;
         if (wresp_ooo_cnt <= (wresp_ooo_limit-wresp_ooo_threshold)) begin
            //$display("%0t: ENTERED_IF_OOO: %0s", $time, get_full_name());
            //wait (slv_model.outbound_bresp_Q.size() > 0);
            fork
               begin
                  wait (slv_model.outbound_bresp_Q.size() >= wresp_ooo_threshold || is_timeout);
                  stop_timeout=1;
               end
               begin
                  while (count < ooo_timeout && stop_timeout==0) begin
                        #1ns;
                        count++;
                  end
                  //$display("%0t: %0s STOP_OOO wait ooo_timeout(%0d)", $time, get_full_name(), ooo_timeout);
                  is_timeout=1; 
               end
            join
            wresp_cnt = (slv_model.outbound_bresp_Q.size() >= wresp_ooo_threshold) ? wresp_ooo_threshold : slv_model.outbound_bresp_Q.size();
            for (int i=0; i<wresp_cnt; i++) begin
               shuffle_q.push_back(slv_model.outbound_bresp_Q.pop_front());
            end
            shuffle_q.shuffle();
            //foreach (shuffle_q[i]) begin
            //   out_q.push_back(shuffle_q.pop_front());
            //end
            for (int i=0; i<shuffle_q.size(); i++) begin
               out_q.push_back(shuffle_q[i]);
            end
            shuffle_q.delete();
            //$display("%0t: IF_OOO: %0s out_q.size = %0d wresp_ooo_cnt=%0d, slv_model.outbound_bresp_Q.size=%0d", $time, get_full_name(), out_q.size(), wresp_ooo_cnt, slv_model.outbound_bresp_Q.size());
         end else begin
            //$display("%0t: ENTERED_ELSE_OOO: %0s", $time, get_full_name());
            wait (slv_model.outbound_bresp_Q.size() > 0);
            out_q.push_back(slv_model.outbound_bresp_Q.pop_front());
            //$display("%0t: ELSE_OOO: %0s out_q.size = %0d wresp_ooo_cnt=%0d", $time, get_full_name(), out_q.size(), wresp_ooo_cnt);
         end
      end //forever
   end //fork branch
   begin
      forever begin
         //if (wresp_ooo_cnt <= (wresp_ooo_limit-wresp_ooo_threshold)) begin
         //   wait (slv_model.outbound_bresp_Q.size() >= wresp_ooo_threshold);
         //end else begin
         //   wait (slv_model.outbound_bresp_Q.size() > 0);
         //end
         //slv_model.outbound_bresp_Q.shuffle();
         //bresp = slv_model.outbound_bresp_Q.pop_front();
         wait (out_q.size() > 0);
         //$display("%0t: DBG_OOO: %0s out_q.size=%0d wresp_ooo_cnt=%0d", $time, get_full_name(), out_q.size(), wresp_ooo_cnt);
         bresp = out_q.pop_front();
         if (user_bresp_q.size() >0) begin
            if (shuffle_user_resp) begin
               user_bresp_q.shuffle();
            end
            //modify bresp based on user input
            user_bresp = user_bresp_q.pop_front();
            bresp.resp = user_bresp.resp;
            bresp.user = user_bresp.user;
            bresp.delay = user_bresp.delay;
            if (loop_user_resp) begin
               user_bresp_q.push_back(user_bresp);
            end
         end
         bresp_seq = sig_axi_resp_seq#(T)::type_id::create(.name("bresp_seq"), .contxt(get_full_name()));
         bresp_seq.randomize() with {
            bresp_seq.seq_id    == bresp.id;
            bresp_seq.seq_user  == bresp.user;
            bresp_seq.seq_resp  == bresp.resp;
            bresp_seq.seq_delay == bresp.delay;
         };
         p_sequencer.pending_wresp_cnt++;
         bresp_seq.start(p_sequencer.bresp_sqr);
         wresp_ooo_cnt++;
         p_sequencer.pending_wresp_cnt--;
      end
   end
join
   endtask

   virtual task body();
      fork
      begin
         if (enable_out_of_order) begin
            return_ooo_bresp();
         end else begin
            return_bresp();
         end
      end
      begin
         if (enable_interleaved) begin
            return_interleaved_rresp();
         end else if (enable_out_of_order) begin
            return_ooo_rresp();
         end else begin
            return_rresp();
         end
      end
      join
   endtask

endclass




`endif
