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
class axi_fifo#(int DATA_WIDTH =32);
  `protect //begin protected region
   logic [DATA_WIDTH-1:0] fifo [$];
  `endprotect //end protected region
endclass

class axi_system_fifo#(int ADDR_WIDTH=64, int DATA_WIDTH =32) extends uvm_component;
   `uvm_component_param_utils(axi_system_fifo#(ADDR_WIDTH, DATA_WIDTH))

   function new(string name="", uvm_component parent=null);
      super.new(name, parent);
   endfunction

  `protect //begin protected region
   axi_fifo#(DATA_WIDTH) fifos [logic[ADDR_WIDTH-1:0]];

   function void writeFifo(bit[ADDR_WIDTH-1:0] addr, bit[DATA_WIDTH-1:0] wdata, bit[DATA_WIDTH/8-1:0]strb);
      axi_fifo#(DATA_WIDTH) fifo_obj;
      bit [DATA_WIDTH-1:0] mask;

      if(!fifos.exists(addr)) begin
         fifo_obj = new();
         fifos[addr] = fifo_obj;
      end
      mask = '0;
      for (int i=0; i<DATA_WIDTH/8; i++) begin
         mask = mask >> 8;
         mask[DATA_WIDTH-1:DATA_WIDTH-8] = {8{strb[i]}};
      end
      //$display("%0t: %0s: writeFifo: addr=0x%0x, mask=0x%0x, data=0x%0x, strb=0x%0x", $time, get_full_name(), addr, mask, wdata,strb);
      //if (strb != '0) begin
         fifos[addr].fifo.push_back(wdata & mask);
      //end
   endfunction

   function bit[DATA_WIDTH-1:0] readFifo(bit[ADDR_WIDTH-1:0] addr);
      bit[DATA_WIDTH-1:0] rdata;
      if(fifos.exists(addr)) begin
         if(fifos[addr].fifo.size() > 0) begin
            rdata = fifos[addr].fifo.pop_front();
         end else begin
            rdata = '0;
         end
      end else begin
         rdata = '0;
      end
      return rdata;
   endfunction
/*
   function void writeFifo(bit[ADDR_WIDTH-1:0] start_addr, logic[7:0] wdata[$], bit strb[$]);
      axi_fifo fifo_obj;
      $display("%0t: %0s: writeFifo addr=0x%0x, data.size=%0d strb.size=%0d", $time, get_full_name(), start_addr, wdata.size(), strb.size());
      foreach (wdata[i]) begin
        //$display(" - [%0d] addr = 0x%0x, wdata = 0x%0x, strb = %0x", i, start_addr+i, wdata[i], strb[i]);
        if (!fifos.exists(start_addr+i)) begin
           fifo_obj = new();
           fifos[start_addr+i] = fifo_obj;
        end
        if (strb[i] == 1'b1) begin
           fifos[start_addr+i].fifo.push_back(wdata[i]);
        end 
        //else begin
        //   fifos[start_addr+i].fifo.push_back('0);
        //end
      end
   endfunction

   function void readFifo(bit[ADDR_WIDTH-1:0] start_addr, int byte_count, ref logic[7:0] rdata [$]);
      rdata.delete();
      $display("%0t: readFifo addr=0x%0x, byte_count=%0d", $time, start_addr, byte_count);
      for (int i=0; i<byte_count; i++) begin
         if (fifos.exists(start_addr+i)) begin
            if(fifos[start_addr+i].fifo.size() > 0) begin
               $display("read_from_fifo");
               rdata.push_back(fifos[start_addr+i].fifo.pop_front);
            end else begin
               rdata.push_back('0);
               $display("read_from_none1");
            end
            //$display("[%0d] 0x%0x", i, mem[start_addr+i]);
         end else begin
            rdata.push_back('0);
            $display("read_from_none2");
            //$display("[%0d] 0x%0x", i, 0);
         end
      end
   endfunction
*/
  `endprotect //end protected region
endclass

class axi_system_memory#(int ADDR_WIDTH=64) extends uvm_component;
   `uvm_component_param_utils(axi_system_memory#(ADDR_WIDTH))

   function new(string name="", uvm_component parent=null);
      super.new(name, parent);
   endfunction

  `protect //begin protected region
   logic [7:0] mem [logic[ADDR_WIDTH-1:0]];
   logic [7:0] default_byte = '0;

   function void writeMem(bit[ADDR_WIDTH-1:0] start_addr, logic[7:0] wdata[$], bit strb[$]);
      //$display("%0t: writeMem addr=0x%0x, data.size=%0d strb.size=%0d", $time, start_addr, wdata.size(), strb.size());
      foreach (wdata[i]) begin
        //$display(" - [%0d] addr = 0x%0x, wdata = 0x%0x, strb = %0x", i, start_addr+i, wdata[i], strb[i]);
        if (strb[i] == 1'b1) begin
            mem[start_addr+i] = wdata[i];
        end     
      end   
   endfunction

   function void readMem(bit[ADDR_WIDTH-1:0] start_addr, int byte_count, ref logic[7:0] rdata [$]);
      rdata.delete();
      //$display("%0t: readMem addr=0x%0x, byte_count=%0d", $time, start_addr, byte_count);
      for (int i=0; i<byte_count; i++) begin
         if (mem.exists(start_addr+i)) begin
            rdata.push_back(mem[start_addr+i]);
            //$display("[%0d] 0x%0x", i, mem[start_addr+i]);
         end else begin
            rdata.push_back(default_byte);
            //$display("[%0d] 0x%0x", i, 0);
         end
      end
   endfunction
  `endprotect //end protected region

endclass
