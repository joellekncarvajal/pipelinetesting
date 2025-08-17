`ifndef sig_axi_env__sv
`define sig_axi_env__sv

import sys::*;
class sig_axi_env extends uvm_env;
    `uvm_component_utils(sig_axi_env)

    axi_sys_cfg sys_cfg;

    axi_slave_agent#(sys::axi_port_ep)  slv_agents;
    axi_master_agent#(sys::axi_port_ip) mst_agents;
    axi_virtual_sequencer#(sys::axi_port_ip) mst_vsqrs;
    axi_virtual_sequencer#(sys::axi_port_ep) slv_vsqrs;
    axi_system_memory#(sys::axi_port_ip::AXI_ADDR_WIDTH) mst_mem; 
    axi_system_memory#(sys::axi_port_ep::AXI_ADDR_WIDTH) slv_mem; 

    logic[7:0] SysMem[logic[63:0]];

    function new(string name="", uvm_component parent);
        super.new(name, parent);
    endfunction // new

    function void build_phase(uvm_phase phase);
        string str;
        super.build_phase(phase);

        mst_mem = axi_system_memory#(sys::axi_port_ip::AXI_ADDR_WIDTH)::type_id::create("mst_mem", this);
        slv_mem = axi_system_memory#(sys::axi_port_ep::AXI_ADDR_WIDTH)::type_id::create("slv_mem", this);

        if (!uvm_config_db#(axi_sys_cfg)::get(this, "*", "axi_system_cfg", sys_cfg)) begin
            `uvm_info(get_full_name(), "Cannot find system config setting, use defaults", UVM_LOW)
            sys_cfg = new("sys_cfg");
            sys_cfg.setDefaultPortCfg(1, 1);
        end
        `uvm_info(get_full_name(), $sformatf("Config DB get for SYS_CFG: num_msts = %d", sys_cfg.num_mstrs), UVM_HIGH)

        str = $sformatf("mst_agent");
        $display("Creating axi_master_agent %s", str);
        mst_agents = axi_master_agent#(sys::axi_port_ip)::type_id::create(str, this);
        mst_agents.port_cfg = sys_cfg.mstr_prt_cfg[0];

        str = $sformatf("slv_agent");
        $display("Creating axi_slave_agent %s", str);
        slv_agents = axi_slave_agent#(sys::axi_port_ep)::type_id::create(str, this);
        slv_agents.port_cfg = sys_cfg.slv_prt_cfg[0];

        str = $sformatf("mst_vsqr");
        mst_vsqrs = axi_virtual_sequencer#(sys::axi_port_ip)::type_id::create(str, this);
        
        str = $sformatf("slv_vsqr");
        slv_vsqrs = axi_virtual_sequencer#(sys::axi_port_ep)::type_id::create(str, this);
        
    endfunction // build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        slv_agents.slv_model.mem = slv_mem;
        mst_agents.slv_model.mem = mst_mem;

        mst_vsqrs.waddr_sqr = mst_agents.axi_waddr_sequencer;
        mst_vsqrs.wdata_sqr = mst_agents.axi_wdata_sequencer;
        mst_vsqrs.raddr_sqr = mst_agents.axi_raddr_sequencer;

        slv_vsqrs.bresp_sqr = slv_agents.axi_bresp_sequencer;
        slv_vsqrs.rdata_sqr = slv_agents.axi_rdata_sequencer;
    endfunction // connect_phase

endclass // sig_axi_env
`endif //  `ifndef sig_axi_env__sv
