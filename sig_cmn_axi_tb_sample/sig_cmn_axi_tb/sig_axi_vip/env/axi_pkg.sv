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
//`timescale 1ns/1ps
package axi_pkg;
   
   import uvm_pkg::*;
`include "uvm_macros.svh"

`include "axi_seq_item.sv"
`include "axi_params.sv"   
`include "axi_cfg.sv"   
`include "axi_system_memory.sv"
`include "axi_model.sv"
`include "axi_driver.sv"
`include "axi_monitor.sv"
`include "axi_coverage.sv"
`include "axi_master_agent.sv"
`include "axi_slave_agent.sv"
`include "axi_virtual_sequencer.sv"
//`include "axi_env.sv"   
   
endpackage // axi_pkg
