// axi_if[0] - I/F of Avery AXI Master
// axi_if[1] - I/F of Avery AXI Slave

/*
   +-------+             +-------+
   |  SIG  |===[WADDR]==>| AVERY |
   |  MST  |===[WDATA]==>|  SLV  |
   |       |<==[BRESP]===|       |
   |       |             |       |
   |       |===[RADDR]==>|       |
   |       |<==[RDATA]===|       |
   +-------+             +-------+
   axi_mstr*             axi_if[1]
*/

assign axi_if[1].slave_port.AWVALID  = axi_mstr_waddr_inf[0].AxVALID;
assign axi_if[1].slave_port.AWID     = axi_mstr_waddr_inf[0].AxID;
assign axi_if[1].slave_port.AWADDR   = axi_mstr_waddr_inf[0].AxADDR;
assign axi_if[1].slave_port.AWLEN    = axi_mstr_waddr_inf[0].AxLEN;
assign axi_if[1].slave_port.AWSIZE   = axi_mstr_waddr_inf[0].AxSIZE;
assign axi_if[1].slave_port.AWBURST  = axi_mstr_waddr_inf[0].AxBURST;
assign axi_if[1].slave_port.AWLOCK   = axi_mstr_waddr_inf[0].AxLOCK;
assign axi_if[1].slave_port.AWCACHE  = axi_mstr_waddr_inf[0].AxCACHE;
assign axi_if[1].slave_port.AWPROT   = axi_mstr_waddr_inf[0].AxPROT;
assign axi_if[1].slave_port.AWQOS    = axi_mstr_waddr_inf[0].AxQOS;
assign axi_if[1].slave_port.AWREGION = axi_mstr_waddr_inf[0].AxREGION;
assign axi_if[1].slave_port.AWUSER   = axi_mstr_waddr_inf[0].AxUSER;
assign axi_mstr_waddr_inf[0].AxREADY    = axi_if[1].slave_port.AWREADY;

assign axi_if[1].slave_port.WVALID   = axi_mstr_wdata_inf[0].xVALID;
assign axi_if[1].slave_port.WID      = axi_mstr_wdata_inf[0].xID;
assign axi_if[1].slave_port.WDATA    = axi_mstr_wdata_inf[0].xDATA;
assign axi_if[1].slave_port.WSTRB    = axi_mstr_wdata_inf[0].xSTRB;
assign axi_if[1].slave_port.WLAST    = axi_mstr_wdata_inf[0].xLAST;
assign axi_if[1].slave_port.WUSER    = axi_mstr_wdata_inf[0].xUSER;
assign axi_mstr_wdata_inf[0].xREADY     = axi_if[1].slave_port.WREADY;

assign axi_mstr_resp_inf[0].BVALID      = axi_if[1].slave_port.BVALID;
assign axi_mstr_resp_inf[0].BID         = axi_if[1].slave_port.BID;
assign axi_mstr_resp_inf[0].BRESP       = axi_if[1].slave_port.BRESP;
assign axi_mstr_resp_inf[0].BUSER       = axi_if[1].slave_port.BUSER;
assign axi_if[1].slave_port.BREADY   = axi_mstr_resp_inf[0].BREADY;

assign axi_if[1].slave_port.ARVALID  = axi_mstr_raddr_inf[0].AxVALID;
assign axi_if[1].slave_port.ARID     = axi_mstr_raddr_inf[0].AxID;
assign axi_if[1].slave_port.ARADDR   = axi_mstr_raddr_inf[0].AxADDR;
assign axi_if[1].slave_port.ARLEN    = axi_mstr_raddr_inf[0].AxLEN;
assign axi_if[1].slave_port.ARSIZE   = axi_mstr_raddr_inf[0].AxSIZE;
assign axi_if[1].slave_port.ARBURST  = axi_mstr_raddr_inf[0].AxBURST;
assign axi_if[1].slave_port.ARLOCK   = axi_mstr_raddr_inf[0].AxLOCK;
assign axi_if[1].slave_port.ARCACHE  = axi_mstr_raddr_inf[0].AxCACHE;
assign axi_if[1].slave_port.ARPROT   = axi_mstr_raddr_inf[0].AxPROT;
assign axi_if[1].slave_port.ARQOS    = axi_mstr_raddr_inf[0].AxQOS;
assign axi_if[1].slave_port.ARREGION = axi_mstr_raddr_inf[0].AxREGION;
assign axi_if[1].slave_port.ARUSER   = axi_mstr_raddr_inf[0].AxUSER;
assign axi_mstr_raddr_inf[0].AxREADY    = axi_if[1].slave_port.ARREADY;

assign axi_mstr_rdata_inf[0].xVALID     = axi_if[1].slave_port.RVALID;
assign axi_mstr_rdata_inf[0].xID        = axi_if[1].slave_port.RID;
assign axi_mstr_rdata_inf[0].xDATA      = axi_if[1].slave_port.RDATA;
assign axi_mstr_rdata_inf[0].xLAST      = axi_if[1].slave_port.RLAST;
assign axi_mstr_rdata_inf[0].xUSER      = axi_if[1].slave_port.RUSER;
assign axi_mstr_rdata_inf[0].xRESP      = axi_if[1].slave_port.RRESP;
assign axi_if[1].slave_port.RREADY   = axi_mstr_rdata_inf[0].xREADY;

/*
   +-------+             +-------+
   | AVERY |===[WADDR]==>|  SIG  |
   |  MST  |===[WDATA]==>|  SLV  |
   |       |<==[BRESP]===|       |
   |       |             |       |
   |       |===[RADDR]==>|       |
   |       |<==[RDATA]===|       |
   +-------+             +-------+
   axi_if[0]             axi_slv_*
*/

assign axi_slv_waddr_inf[0].AxVALID      = axi_if[0].master_port.AWVALID;
assign axi_slv_waddr_inf[0].AxID         = axi_if[0].master_port.AWID;
assign axi_slv_waddr_inf[0].AxADDR       = axi_if[0].master_port.AWADDR;
assign axi_slv_waddr_inf[0].AxLEN        = axi_if[0].master_port.AWLEN;
assign axi_slv_waddr_inf[0].AxSIZE       = axi_if[0].master_port.AWSIZE;
assign axi_slv_waddr_inf[0].AxBURST      = axi_if[0].master_port.AWBURST;
assign axi_slv_waddr_inf[0].AxLOCK       = axi_if[0].master_port.AWLOCK;
assign axi_slv_waddr_inf[0].AxCACHE      = axi_if[0].master_port.AWCACHE;
assign axi_slv_waddr_inf[0].AxPROT       = axi_if[0].master_port.AWPROT;
assign axi_slv_waddr_inf[0].AxQOS        = axi_if[0].master_port.AWQOS;
assign axi_slv_waddr_inf[0].AxREGION     = axi_if[0].master_port.AWREGION;
assign axi_slv_waddr_inf[0].AxUSER       = axi_if[0].master_port.AWUSER;
assign axi_if[0].master_port.AWREADY  = axi_slv_waddr_inf[0].AxREADY; 

assign axi_slv_wdata_inf[0].xVALID       = axi_if[0].master_port.WVALID;
assign axi_slv_wdata_inf[0].xID          = axi_if[0].master_port.WID;
assign axi_slv_wdata_inf[0].xDATA        = axi_if[0].master_port.WDATA;
assign axi_slv_wdata_inf[0].xSTRB        = axi_if[0].master_port.WSTRB;
assign axi_slv_wdata_inf[0].xLAST        = axi_if[0].master_port.WLAST;
assign axi_slv_wdata_inf[0].xUSER        = axi_if[0].master_port.WUSER;
assign axi_if[0].master_port.WREADY   = axi_slv_wdata_inf[0].xREADY;

assign axi_if[0].master_port.BVALID   = axi_slv_resp_inf[0].BVALID;
assign axi_if[0].master_port.BID      = axi_slv_resp_inf[0].BID;
assign axi_if[0].master_port.BRESP    = axi_slv_resp_inf[0].BRESP;
assign axi_if[0].master_port.BUSER    = axi_slv_resp_inf[0].BUSER;
assign axi_slv_resp_inf[0].BREADY        = axi_if[0].master_port.BREADY;

assign axi_slv_raddr_inf[0].AxVALID      = axi_if[0].master_port.ARVALID;
assign axi_slv_raddr_inf[0].AxID         = axi_if[0].master_port.ARID;
assign axi_slv_raddr_inf[0].AxADDR       = axi_if[0].master_port.ARADDR;
assign axi_slv_raddr_inf[0].AxLEN        = axi_if[0].master_port.ARLEN; 
assign axi_slv_raddr_inf[0].AxSIZE       = axi_if[0].master_port.ARSIZE;
assign axi_slv_raddr_inf[0].AxBURST      = axi_if[0].master_port.ARBURST;
assign axi_slv_raddr_inf[0].AxLOCK       = axi_if[0].master_port.ARLOCK;
assign axi_slv_raddr_inf[0].AxCACHE      = axi_if[0].master_port.ARCACHE;
assign axi_slv_raddr_inf[0].AxPROT       = axi_if[0].master_port.ARPROT;
assign axi_slv_raddr_inf[0].AxQOS        = axi_if[0].master_port.ARQOS;
assign axi_slv_raddr_inf[0].AxREGION     = axi_if[0].master_port.ARREGION;
assign axi_slv_raddr_inf[0].AxUSER       = axi_if[0].master_port.ARUSER;
assign axi_if[0].master_port.ARREADY  = axi_slv_raddr_inf[0].AxREADY;

assign axi_if[0].master_port.RVALID   = axi_slv_rdata_inf[0].xVALID;
assign axi_if[0].master_port.RID      = axi_slv_rdata_inf[0].xID;
assign axi_if[0].master_port.RDATA    = axi_slv_rdata_inf[0].xDATA;
assign axi_if[0].master_port.RLAST    = axi_slv_rdata_inf[0].xLAST;
assign axi_if[0].master_port.RUSER    = axi_slv_rdata_inf[0].xUSER;
assign axi_if[0].master_port.RRESP    = axi_slv_rdata_inf[0].xRESP;
assign axi_slv_rdata_inf[0].xREADY       = axi_if[0].master_port.RREADY;
