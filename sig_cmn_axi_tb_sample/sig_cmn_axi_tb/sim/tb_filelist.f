# --- start axi vip files ---
+incdir+${SIG_VIP_AXI_HOME}/env 
+incdir+${SIG_VIP_AXI_HOME}/seqs
+incdir+${SIG_VIP_AXI_HOME}/tests
${SIG_VIP_AXI_HOME}/env/axi_pkg.sv
${SIG_VIP_AXI_HOME}/env/axi_interface.sv
# --- end axi vip files ---

${SIG_CMN_AXI_TB}/top/sig_sys_pkg.sv
${SIG_CMN_AXI_TB}/env/sig_env.sv

${SIG_CMN_AXI_TB}/tests/sig_base_test.sv
${SIG_CMN_AXI_TB}/tests/sig_multi_test.sv
${SIG_CMN_AXI_TB}/tests/sig_perf_test.sv
${SIG_CMN_AXI_TB}/tests/sig_rand_timing_test.sv

${SIG_CMN_AXI_TB}/top/top.sv