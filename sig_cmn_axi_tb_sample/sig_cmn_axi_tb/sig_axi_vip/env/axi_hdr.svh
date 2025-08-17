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
`ifndef axi_hdr__svh
`define axi_hdr__svh
`define MAX_ADDR_WIDTH 64
`define MAX_DATA_WIDTH 64
`define MAX_ID_WIDTH 7

//These defines are not intended to be modified by the end-user.
//These are created to avoid using fixed numbers in the VIP code.
//To modify actual widths:
// - For interface, overwrite parameters during instantiation
// - For uvm components/objects, modify value inside the class parameter
 
`define AXI_ID_WIDTH     7
`define AXI_ADDR_WIDTH   64
`define AXI_LEN_WIDTH    8
`define AXI_SIZE_WIDTH   3
`define AXI_BURST_WIDTH  2
`define AXI_LOCK_WIDTH   2
`define AXI_CACHE_WIDTH  4
`define AXI_PROT_WIDTH   3
`define AXI_QOS_WIDTH    4
`define AXI_REGION_WIDTH 4
`define AXI_USER_WIDTH   4
`define AXI_DATA_WIDTH   64
`define AXI_STRB_WIDTH   `AXI_DATA_WIDTH/8
`define AXI_RESP_WIDTH   2
`define AXI_GPIO_WIDTH   32

typedef enum bit[2:0] {WRITE=3'b000, READ=3'b001, BRESP=3'b010, RRESP=3'b011, AXI_RST=3'b100} OpType;
typedef enum bit[`AXI_RESP_WIDTH-1:0] {OKAY=2'b00, EXOKAY=2'b01, SLVERR=2'b10, DECERR=2'b11} RespCode;
typedef enum bit[`AXI_BURST_WIDTH-1:0] {FIXED=2'b00, INCR=2'b01, WRAP=2'b10, RESERVED_burst=2'b11} BurstType;
typedef enum bit[`AXI_LOCK_WIDTH-1:0] {NORMAL=2'b00, EXCLUSIVE=2'b01, LOCKED=2'b10, RESERVED_lock=2'b11} LockType;
typedef enum bit[1:0] {AXI_ADDR=2'b00, AXI_DATA=2'b01, AXI_RESP=2'b10, RESERVED_ch=2'b11} ChType;
typedef enum bit[1:0] {AXI3 = 2'b00, AXI4 = 2'b01, AXI4_LITE=2'b10} AxiVer;
//typedef enum bit[2:0] {FULL_REQ=3'b000, FULL_COMP=3'b001, ADDR_ONLY=3'b010, DATA_START=3'b011, DATA_CONT=3'b100, DATA_END=3'b101, DATA_SINGLE=3'b110, FULL_TRANS=3'b111} SampleType;
typedef enum bit[3:0] {FULL_REQ=4'b0000, FULL_COMP=4'b0001, ADDR_ONLY=4'b0010, DATA_START=4'b0011, DATA_CONT=4'b0100, DATA_END=4'b0101, DATA_SINGLE=4'b0110, FULL_TRANS=4'b0111, AXI_RST_ASSERTED=4'b1000, RESP_ONLY=4'b1001} SampleType;
typedef struct packed {
          bit       hurry;    //gpio[4]
          bit [3:0] pressure; //gpio[3:0]
   } AxGPIO;


`endif

