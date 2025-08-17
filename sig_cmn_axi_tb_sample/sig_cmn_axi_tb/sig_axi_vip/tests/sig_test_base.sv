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
`include "sig_axi_vseq_lib.sv"
import sig_axi_pkg::*;
import axi_pkg::*;

class sig_test_base extends uvm_test;
   `uvm_component_utils(sig_test_base)

   axi_sys_cfg sys_cfg;
   sig_axi_env axi_env;
   
   function new(string name="", uvm_component parent);
      super.new(name, parent);
   endfunction // new
   
   function void build_phase(uvm_phase phase);
      int num_masters;
      int num_slaves;
      int awidth;
      int dwidth;
      int iwidth;
      
      super.build_phase(phase);
      axi_env = sig_axi_env::type_id::create("axi_env", this);
      sys_cfg = axi_sys_cfg::type_id::create("sys_cfg", this);

      if (!uvm_config_db#(integer)::get(this, "*", "number_of_masters", num_masters))
	num_masters = 1;
      if (!uvm_config_db#(integer)::get(this, "*", "number_of_slaves", num_slaves))
	num_slaves = 1;

      sys_cfg.setDefaultPortCfg(num_masters, num_slaves);

      uvm_config_db#(axi_sys_cfg)::set(null, "*", "axi_system_cfg", sys_cfg);
      
   endfunction // build_phase
   
endclass // sig_test_base
