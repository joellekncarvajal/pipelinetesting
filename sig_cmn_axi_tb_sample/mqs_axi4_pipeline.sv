module mqs_axi4_pipeline #(
    //tag::generic_parameters
	parameter ADDR_WIDTH = 64,
	parameter DATA_WIDTH = 64,
	parameter ID_WIDTH = 8,
	parameter USER_WIDTH =1, 
	parameter NUM_STAGES =1)
(
    input     ACLK,
	input     ARESETn,
	
	// *******************************************
	//                  MASTER 
	// *******************************************
	//AW channel
	input                [ID_WIDTH-1:0] mst_AWID,
	input              [ADDR_WIDTH-1:0] mst_AWADDR,
	input                         [7:0] mst_AWLEN,
	input                         [2:0] mst_AWSIZE,
	input                         [1:0] mst_AWBURST,
	input                         [1:0] mst_AWLOCK,
	input                         [3:0] mst_AWCACHE,
	input                         [2:0] mst_AWPROT,
	input                         [3:0] mst_AWQOS,
	input                         [3:0] mst_AWREGION, 
	input              [USER_WIDTH-1:0] mst_AWUSER,
	input                               mst_AWVALID,
	output logic                        mst_AWREADY, 
	
	//W channel
	input              [DATA_WIDTH-1:0] mst_WDATA,
	input          [(DATA_WIDTH/8)-1:0] mst_WSTRB,
	input                               mst_WLAST,
	input              [USER_WIDTH-1:0] mst_WUSER,
	input                               mst_WVALID,
	output logic                        mst_WREADY,
	
	//B channel
	output logic         [ID_WIDTH-1:0] mst_BID,
	output logic                  [1:0] mst_BRESP,
	output logic       [USER_WIDTH-1:0] mst_BUSER,
	output logic                        mst_BVALID,
	input                               mst_BREADY,
	
	//AR channel
	input                [ID_WIDTH-1:0] mst_ARID,
	input              [ADDR_WIDTH-1:0] mst_ARADDR,
	input                         [7:0] mst_ARLEN,
	input                         [2:0] mst_ARSIZE,
	input                         [1:0] mst_ARBURST,
	input                         [1:0] mst_ARLOCK,
	input                         [3:0] mst_ARCACHE,
	input                         [2:0] mst_ARPROT,
	input                         [3:0] mst_ARQOS,
	input                         [3:0] mst_ARREGION,
	input              [USER_WIDTH-1:0] mst_ARUSER,
	input                               mst_ARVALID,
	output logic                        mst_ARREADY,
	
	//R channel 
	output logic         [ID_WIDTH-1:0] mst_RID,
	output logic       [DATA_WIDTH-1:0] mst_RDATA,
	output logic                  [1:0] mst_RRESP,
	output logic                        mst_RLAST,
	output logic       [USER_WIDTH-1:0] mst_RUSER,
	output logic                        mst_RVALID,
	input                               mst_RREADY,
	
	// **********************************************
	//                    SLAVE 
	// **********************************************
    // AW channel
	output logic         [ID_WIDTH-1:0] slv_AWID,
	output logic       [ADDR_WIDTH-1:0] slv_AWADDR,
	output logic                  [7:0] slv_AWLEN,
	output logic                  [2:0] slv_AWSIZE,
	output logic                  [1:0] slv_AWBURST,
	output logic                  [1:0] slv_AWLOCK,
	output logic                  [3:0] slv_AWCACHE,
	output logic                  [2:0] slv_AWPROT,
	output logic                  [3:0] slv_AWQOS,
	output logic                  [3:0] slv_AWREGION, 
	output logic       [USER_WIDTH-1:0] slv_AWUSER,
	output logic                        slv_AWVALID,
	input                               slv_AWREADY, 
	
	//W channel
	output logic       [DATA_WIDTH-1:0] slv_WDATA,
	output logic   [(DATA_WIDTH/8)-1:0] slv_WSTRB,
	output logic                        slv_WLAST,
	output logic       [USER_WIDTH-1:0] slv_WUSER,
	output logic                        slv_WVALID,
	input                               slv_WREADY,
	
	//B channel
	input                [ID_WIDTH-1:0] slv_BID,
	input                         [1:0] slv_BRESP,
	input              [USER_WIDTH-1:0] slv_BUSER,
	input                               slv_BVALID,
	output logic                        slv_BREADY,
	
	//AR channel
	output logic         [ID_WIDTH-1:0] slv_ARID, 
	output logic       [ADDR_WIDTH-1:0] slv_ARADDR,
	output logic                  [7:0] slv_ARLEN,
	output logic                  [2:0] slv_ARSIZE,
	output logic                  [1:0] slv_ARBURST,
	output logic                  [1:0] slv_ARLOCK,
	output logic                  [3:0] slv_ARCACHE,
	output logic                  [2:0] slv_ARPROT,
	output logic                  [3:0] slv_ARQOS,
	output logic                  [3:0] slv_ARREGION,
	output logic       [USER_WIDTH-1:0] slv_ARUSER,
	output logic                        slv_ARVALID,
	input                               slv_ARREADY,
	
	//R channel 
	input                [ID_WIDTH-1:0] slv_RID,
	input              [DATA_WIDTH-1:0] slv_RDATA,
	input                         [1:0] slv_RRESP,
	input                               slv_RLAST,
	input              [USER_WIDTH-1:0] slv_RUSER,
	input                               slv_RVALID,
	output logic                        slv_RREADY
);




    //**************
	//compute widths
	//**************
	localparam WIDTH_ADDR = $bits({
		mst_AWID,
	    mst_AWADDR,
	    mst_AWLEN,
		mst_AWSIZE,
		mst_AWBURST,
		mst_AWLOCK,
		mst_AWCACHE,
		mst_AWPROT,
		mst_AWQOS,
		mst_AWREGION,
		mst_AWUSER
	});
	localparam WIDTH_WR = $bits({mst_WDATA,
	    mst_WSTRB,
		mst_WLAST,
		mst_WUSER
	});
	
	localparam WIDTH_B = $bits({
	    slv_BID,
		slv_BRESP,
		slv_BUSER
	});
		
	localparam WIDTH_RD = $bits({
	    slv_RID,
		slv_RDATA,
		slv_RRESP,
		slv_RLAST,
		slv_RUSER
    });




    //AW Channel Pipeline
    sig_cmn_pipeline_rv #(
	    .DWIDTH         (WIDTH_ADDR),
		.NUM_STAGES     (NUM_STAGES))
	i_addr_wr_pipeline(
	    .clk            (ACLK),
	    .reset_n        (ARESETn),
	    .valid_in       (mst_AWVALID),
	    .ready_out      (mst_AWREADY),
		.data_in        ({
		                    mst_AWID,
			                mst_AWADDR,
			                mst_AWLEN,
			                mst_AWSIZE,
			                mst_AWBURST,
			                mst_AWLOCK,
			                mst_AWCACHE,
			                mst_AWPROT,
			                mst_AWQOS,
			                mst_AWREGION,
			                mst_AWUSER}),
		.valid_out      (slv_AWVALID),
		.ready_in       (slv_AWREADY),
		.data_out       ({
		                    slv_AWID,
	                        slv_AWADDR,
	                        slv_AWLEN,
		                    slv_AWSIZE,
		                    slv_AWBURST,
		                    slv_AWLOCK,
		                    slv_AWCACHE,
		                    slv_AWPROT,
		                    slv_AWQOS,
		                    slv_AWREGION,
		                    slv_AWUSER}));
	
    //W Channel Pipeline
	sig_cmn_pipeline_rv #(
	    .DWIDTH         (WIDTH_WR),
		.NUM_STAGES     (NUM_STAGES))
	i_wr_pipeline(
	    .clk            (ACLK),
	    .reset_n        (ARESETn),
	    .valid_in       (mst_WVALID),
	    .ready_out      (mst_WREADY),
		.data_in        ({
		                    mst_WDATA,
	                        mst_WSTRB,
		                    mst_WLAST,
		                    mst_WUSER}),
		.valid_out      (slv_WVALID),
		.ready_in       (slv_WREADY),
		.data_out       ({
		                    slv_WDATA,
	                        slv_WSTRB,
		                    slv_WLAST,
		                    slv_WUSER}));
	
    //B Channel Pipeline
    sig_cmn_pipeline_rv #(
	    .DWIDTH         (WIDTH_B),
		.NUM_STAGES     (NUM_STAGES))
	i_bresp_pipeline (
	    .clk            (ACLK),
	    .reset_n        (ARESETn),
	    .valid_in       (slv_BVALID),
	    .ready_out      (slv_BREADY),
		.data_in        ({
	                        slv_BID,
		                    slv_BRESP,
		                    slv_BUSER}),
		.valid_out      (mst_BVALID),
		.ready_in       (mst_BREADY),
		.data_out       ({
	                        mst_BID,
		                    mst_BRESP,
		                    mst_BUSER}));
	
    //AR Channel Pipeline
	sig_cmn_pipeline_rv #(
	    .DWIDTH         (WIDTH_ADDR),
		.NUM_STAGES     (NUM_STAGES))
	i_addr_rd_pipeline (
	    .clk            (ACLK),
	    .reset_n        (ARESETn),
	    .valid_in       (mst_ARVALID),
	    .ready_out      (mst_ARREADY),
		.data_in        ({
		                    mst_ARID,
	                        mst_ARADDR,
	                        mst_ARLEN,
		                    mst_ARSIZE,
		                    mst_ARBURST,
		                    mst_ARLOCK,
		                    mst_ARCACHE,
		                    mst_ARPROT,
		                    mst_ARQOS,
		                    mst_ARREGION,
		                    mst_ARUSER}),
		.valid_out      (slv_ARVALID),
		.ready_in       (slv_ARREADY),
		.data_out       ({
		                    slv_ARID,
	                        slv_ARADDR,
	                        slv_ARLEN,
		                    slv_ARSIZE,
		                    slv_ARBURST,
		                    slv_ARLOCK,
		                    slv_ARCACHE,
		                    slv_ARPROT,
		                    slv_ARQOS,
		                    slv_ARREGION,
		                    slv_ARUSER}));
	
	//R Channel Pipeline
	sig_cmn_pipeline_rv #(
	    .DWIDTH         (WIDTH_RD),
		.NUM_STAGES     (NUM_STAGES)) 
	i_rd_pipeline (
	    .clk            (ACLK),
	    .reset_n        (ARESETn),
	    .valid_in       (slv_RVALID),
	    .ready_out      (slv_RREADY),
		.data_in        ({
	                        slv_RID,
		                    slv_RDATA,
		                    slv_RRESP,
		                    slv_RLAST,
		                    slv_RUSER}),
		.valid_out      (mst_RVALID),
		.ready_in       (mst_RREADY),
		.data_out       ({
	                        mst_RID,
		                    mst_RDATA,
		                    mst_RRESP,
		                    mst_RLAST,
		                    mst_RUSER}));


	
	