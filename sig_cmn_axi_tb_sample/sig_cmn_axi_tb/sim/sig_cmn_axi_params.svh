//axi params
`define AXI_IN_ID_WIDTH      8
`define AXI_IN_RD_ID_WIDTH   8
`define AXI_IN_WR_ID_WIDTH   8

`define AXI_IN_DATA_WIDTH    512
`define AXI_IN_STRB_WIDTH    `AXI_IN_DATA_WIDTH/8

`define AXI_OUT_DATA_WIDTH   512
`define AXI_OUT_STRB_WIDTH   `AXI_OUT_DATA_WIDTH/8

`define AXI_OUT_ID_WIDTH     8
`define AXI_OUT_RD_ID_WIDTH  8
`define AXI_OUT_WR_ID_WIDTH  8

`define AXI_ADDR_WIDTH       64
`define AXI_LEN_WIDTH        8
`define AXI_SIZE_WIDTH       3
`define AXI_BURST_WIDTH      2
`define AXI_LOCK_WIDTH       1
`define AXI_CACHE_WIDTH      4
`define AXI_PROT_WIDTH       3
`define AXI_QOS_WIDTH        4
`define AXI_REGION_WIDTH     4
`define AXI_RESP_WIDTH       2

`define AXI_USER_REQ_WIDTH   1
`define AXI_USER_DATA_WIDTH  1
`define AXI_USER_RESP_WIDTH  1
`define AXI_USER_WIDTH       1 //maximum value between the three user parameters used above (only used by unit level tb)