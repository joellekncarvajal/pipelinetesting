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
`ifndef sig_axi_env__sv
 `define sig_axi_env__sv

import sys::*;
class sig_axi_env extends uvm_env;
   `uvm_component_utils(sig_axi_env)

   int num_masters;
   int num_slaves;

   axi_sys_cfg sys_cfg;

   axi_slave_agent#(sys::axi_port_32x32x4) slv_agents[];
   axi_master_agent#(sys::axi_port_32x32x4) mstr_agents[];
   axi_virtual_sequencer#(sys::axi_port_32x32x4) vsqrs[];
   axi_system_memory#(sys::axi_port_32x32x4::AXI_ADDR_WIDTH) mem; 

   logic[7:0] SysMem[logic[63:0]];
   
   function new(string name="", uvm_component parent);
      super.new(name, parent);
   endfunction // new

   function void build_phase(uvm_phase phase);
      string str;
      super.build_phase(phase);

      mem = axi_system_memory#(sys::axi_port_32x32x4::AXI_ADDR_WIDTH)::type_id::create("mem", this);

      if (!uvm_config_db#(axi_sys_cfg)::get(this, "*", "axi_system_cfg", sys_cfg)) begin
	 `uvm_info(get_full_name(), "Cannot find system config setting, use defaults", UVM_LOW)
	 sys_cfg = new("sys_cfg");
	 sys_cfg.setDefaultPortCfg(1, 1);
      end
      `uvm_info(get_full_name(), $sformatf("Config DB get for SYS_CFG: num_mstrs = %d", sys_cfg.num_mstrs), UVM_HIGH)

      mstr_agents = new[sys_cfg.num_mstrs];
      slv_agents = new[sys_cfg.num_slvs];
      vsqrs = new[sys_cfg.num_mstrs];

      foreach(mstr_agents[i]) begin
	 str = $sformatf("mstr_agent_%0d", i);
	 $display("Creating axi_master_agent %s", str);
	 mstr_agents[i] = axi_master_agent#(sys::axi_port_32x32x4)::type_id::create(str, this);
	 mstr_agents[i].port_cfg = sys_cfg.mstr_prt_cfg[i];
      end
      foreach(slv_agents[i]) begin
	 str = $sformatf("slv_agent_%0d", i);
	 $display("Creating axi_slave_agent %s", str);
	 slv_agents[i] = axi_slave_agent#(sys::axi_port_32x32x4)::type_id::create(str, this);
	 slv_agents[i].port_cfg = sys_cfg.slv_prt_cfg[i];
      end
      foreach(vsqrs[i]) begin
         str = $sformatf("vsqr_%0d", i);
         vsqrs[i] = axi_virtual_sequencer#(sys::axi_port_32x32x4)::type_id::create(str, this);
      end
      
   endfunction // build_phase

   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      foreach(slv_agents[i]) begin
         slv_agents[i].slv_model.mem = mem;
      end
      foreach(vsqrs[i]) begin
         vsqrs[i].waddr_sqr = mstr_agents[i].axi_waddr_sequencer;
         vsqrs[i].wdata_sqr = mstr_agents[i].axi_wdata_sequencer;
         vsqrs[i].bresp_sqr = slv_agents[i].axi_bresp_sequencer;
         vsqrs[i].raddr_sqr = mstr_agents[i].axi_raddr_sequencer;
         vsqrs[i].rdata_sqr = slv_agents[i].axi_rdata_sequencer;
      end
   endfunction // connect_phase
   
   
endclass // sig_axi_env
`endif //  `ifndef sig_axi_env__sv
