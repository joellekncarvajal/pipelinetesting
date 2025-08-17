#!/bin/csh -f

setenv SIG_CMN_AXI_TB  $PWD

#if local vip will be used:
setenv SIG_VIP_AXI_HOME $SIG_CMN_AXI_TB/sig_axi_vip
#if remote/tools axi vip will be used:
#setenv SIG_VIP_AXI_VERSION latest
#setenv SIG_VIP_AXI_HOME ${SIG_VIP_HOME}/sig_axi_vip_${SIG_VIP_AXI_VERSION}
