module sig_cmn_axi_sample #(
    parameter AXI_ADDR_WIDTH       = 52 ,

    parameter AXI_IN_DATA_WIDTH    = 512,
    parameter AXI_IN_RD_ID_WIDTH   = 8  ,
    parameter AXI_IN_WR_ID_WIDTH   = 8  ,

    parameter AXI_OUT_DATA_WIDTH   = 512,
    parameter AXI_OUT_RD_ID_WIDTH  = 8  ,
    parameter AXI_OUT_WR_ID_WIDTH  = 8  ,
    
    parameter AXI_USER_REQ_WIDTH   = 16 ,
    parameter AXI_USER_DATA_WIDTH  = 16 ,
    parameter AXI_USER_RESP_WIDTH  = 16
) (
    input                                                 aclk       ,
    input                                                 aresetn    ,

    // read address channel signals - coming from the sim
    input         [AXI_IN_RD_ID_WIDTH-1:0]                arid_in    , 
    input         [AXI_ADDR_WIDTH-1:0]                    araddr_in  , 
    input         [7:0]                                   arlen_in   ,         
    input         [2:0]                                   arsize_in  ,     
    input         [1:0]                                   arburst_in ,     
    input         [1:0]                                   arlock_in  ,     
    input         [3:0]                                   arcache_in ,    
    input         [2:0]                                   arprot_in  ,     
    input         [3:0]                                   arqos_in   ,         
    input         [3:0]                                   arregion_in, 
    input         [AXI_USER_REQ_WIDTH-1:0]                aruser_in  , 
    input                                                 arvalid_in ,            
    output logic                                          arready_in ,

    // read address channel signals - going to the target device
    output logic [AXI_OUT_RD_ID_WIDTH-1:0]                arid_out     , 
    output logic [AXI_ADDR_WIDTH-1:0]                     araddr_out   , 
    output logic [7:0]                                    arlen_out    ,         
    output logic [2:0]                                    arsize_out   ,     
    output logic [1:0]                                    arburst_out  ,     
    output logic [1:0]                                    arlock_out   ,     
    output logic [3:0]                                    arcache_out  ,    
    output logic [2:0]                                    arprot_out   ,     
    output logic [3:0]                                    arqos_out    ,         
    output logic [3:0]                                    arregion_out , 
    output logic [AXI_USER_REQ_WIDTH-1:0]                 aruser_out    , 
    output logic                                          arvalid_out  ,    
    input                                                 arready_out  ,

    // read completion data incoming (coming from the target device)
    input          [AXI_OUT_DATA_WIDTH-1:0]               rdata_out  , 
    input          [AXI_OUT_RD_ID_WIDTH-1:0]              rid_out    ,    
    input          [1:0]                                  rresp_out  , 
    input                                                 rlast_out  ,          
    input          [AXI_USER_DATA_WIDTH-1:0]              ruser_out  ,
    input                                                 rvalid_out ,     
    output logic                                          rready_out ,

    // read completion data outgoing (to the sim)
    output logic [AXI_IN_DATA_WIDTH-1:0]                  rdata_in , 
    output logic [AXI_IN_RD_ID_WIDTH-1:0]                 rid_in   ,    
    output logic [1:0]                                    rresp_in , 
    output logic                                          rlast_in ,          
    output logic [AXI_USER_DATA_WIDTH-1:0]                ruser_in ,
    output logic                                          rvalid_in,     
    input                                                 rready_in,

    // write address channel signals - incoming (coming from larger dwidth)
    input         [AXI_IN_WR_ID_WIDTH-1:0]                awid_in    , 
    input         [AXI_ADDR_WIDTH-1:0]                    awaddr_in  , 
    input         [7:0]                                   awlen_in   ,         
    input         [2:0]                                   awsize_in  ,     
    input         [1:0]                                   awburst_in ,     
    input         [1:0]                                   awlock_in  ,     
    input         [3:0]                                   awcache_in ,    
    input         [2:0]                                   awprot_in  ,     
    input         [3:0]                                   awqos_in   ,         
    input         [3:0]                                   awregion_in, 
    input         [AXI_USER_REQ_WIDTH-1:0]                awuser_in  , 
    input                                                 awvalid_in ,            
    output logic                                          awready_in ,

    // write address channel signals - outgoing to the target device
    output logic [AXI_OUT_WR_ID_WIDTH-1:0]                awid_out     , 
    output logic [AXI_ADDR_WIDTH-1:0]                     awaddr_out   , 
    output logic [7:0]                                    awlen_out    ,         
    output logic [2:0]                                    awsize_out   ,     
    output logic [1:0]                                    awburst_out  ,     
    output logic [1:0]                                    awlock_out   ,     
    output logic [3:0]                                    awcache_out  ,    
    output logic [2:0]                                    awprot_out   ,     
    output logic [3:0]                                    awqos_out    ,         
    output logic [3:0]                                    awregion_out , 
    output logic [AXI_USER_REQ_WIDTH-1:0]                 awuser_out    , 
    output logic                                          awvalid_out  ,    
    input                                                 awready_out  ,

    // write data channel coming from the sim
    input         [AXI_IN_DATA_WIDTH-1:0]                 wdata_in , 
    input         [AXI_IN_DATA_WIDTH/8-1:0]               wstrb_in ,          
    input                                                 wlast_in ,          
    input          [AXI_USER_DATA_WIDTH-1:0]              wuser_in ,
    input                                                 wvalid_in,                   
    output logic                                          wready_in, 

    // write data channel going to the target device
    output logic [AXI_OUT_DATA_WIDTH-1:0]                 wdata_out  , 
    output logic [AXI_OUT_DATA_WIDTH/8-1:0]               wstrb_out  ,          
    output logic                                          wlast_out  ,          
    output logic [AXI_USER_DATA_WIDTH-1:0]                wuser_out  ,
    output logic                                          wvalid_out ,                   
    input                                                 wready_out ,         

    // wr response coming from the target device
    input        [AXI_OUT_WR_ID_WIDTH-1:0]                bid_out    ,         
    input        [1:0]                                    bresp_out  ,         
    input        [AXI_USER_RESP_WIDTH-1:0]                buser_out  ,
    input                                                 bvalid_out ,     
    output logic                                          bready_out ,

    // wr response going to the sim
    output logic [AXI_IN_WR_ID_WIDTH-1:0]                 bid_in   ,         
    output logic [1:0]                                    bresp_in ,         
    output logic [AXI_USER_RESP_WIDTH-1:0]                buser_in ,
    output logic                                          bvalid_in,     
    input                                                 bready_in
);

    // read address channel signals
    assign arid_out     = arid_in    ; 
    assign araddr_out   = araddr_in  ; 
    assign arlen_out    = arlen_in   ;         
    assign arsize_out   = arsize_in  ;     
    assign arburst_out  = arburst_in ;     
    assign arlock_out   = arlock_in  ;     
    assign arcache_out  = arcache_in ;    
    assign arprot_out   = arprot_in  ;     
    assign arqos_out    = arqos_in   ;         
    assign arregion_out = arregion_in; 
    assign aruser_out   = aruser_in  ; 
    assign arvalid_out  = arvalid_in ;            
    assign arready_in   = arready_out;

    assign rdata_in     = rdata_out ; 
    assign rid_in       = rid_out   ;    
    assign rresp_in     = rresp_out ; 
    assign rlast_in     = rlast_out ;          
    assign ruser_in     = ruser_out ;
    assign rvalid_in    = rvalid_out;     
    assign rready_out   = rready_in ;

    // write address channel signals
    assign awid_out     = awid_in    ; 
    assign awaddr_out   = awaddr_in  ; 
    assign awlen_out    = awlen_in   ;         
    assign awsize_out   = awsize_in  ;     
    assign awburst_out  = awburst_in ;     
    assign awlock_out   = awlock_in  ;     
    assign awcache_out  = awcache_in ;    
    assign awprot_out   = awprot_in  ;     
    assign awqos_out    = awqos_in   ;         
    assign awregion_out = awregion_in; 
    assign awuser_out   = awuser_in  ;
    assign awvalid_out  = awvalid_in ;    
    assign awready_in   = awready_out;

    assign wdata_out    = wdata_in  ; 
    assign wstrb_out    = wstrb_in  ;          
    assign wlast_out    = wlast_in  ;          
    assign wuser_out    = wuser_in  ;
    assign wvalid_out   = wvalid_in ;                   
    assign wready_in    = wready_out;         

    assign bid_in       = bid_out   ;
    assign bresp_in     = bresp_out ;
    assign buser_in     = buser_out ;
    assign bvalid_in    = bvalid_out;
    assign bready_out   = bready_in ;

endmodule
