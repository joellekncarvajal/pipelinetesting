`include "sig_axi_vseq_lib.sv"
import axi_pkg::*;
import sys::*;

class sig_base_test extends uvm_test;
    `uvm_component_utils(sig_base_test)

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

        sys_cfg.setDefaultPortCfg(num_masters, num_slaves, );
        foreach (sys_cfg.mstr_prt_cfg[i]) begin
            sys_cfg.mstr_prt_cfg[i].mst_has_monitor = 1;
            sys_cfg.mstr_prt_cfg[i].version = AXI4;
        end
        foreach (sys_cfg.slv_prt_cfg[i]) begin
            sys_cfg.slv_prt_cfg[i].version = AXI4;
        end
        
        uvm_config_db#(axi_sys_cfg)::set(null, "*", "axi_system_cfg", sys_cfg);
        
    endfunction // build_phase
   
endclass // sig_base_test

