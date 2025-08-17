TEST=sig_multi_test
VERBOSE=UVM_MEDIUM
PROBEFILE=waves.tcl
SVSEED=1
LOGFILE=
AVERY_PLI=/tools/avery/avery_pli-2020_1124
RGXNDIR=
VERIFDIR=${SIG_CMN_AXI_TB}

RTL_FILELIST=${VERIFDIR}/sim/rtl_filelist.f
TB_FILELIST=${VERIFDIR}/sim/tb_filelist.f
DEFINES_LIST=${VERIFDIR}/sim/sig_cmn_axi_params.svh

CMPOPT=
SIMOPT=

VCS_COMPLOG=compile.log
VCS_SIMLOG=simv.log
VCS_LOGFILE=vcs.log

VCS_COV_INCL=line+cond+fsm+tgl+assert+branch
CMP_VCS_COV=
SIM_VCS_COV=

# --- start parse arguments
ifeq ($(LOGFILE),)
#  VCS_LOGFILE=$(VCS_LOGFILE)
else
  VCS_LOGFILE=$(LOGFILE)
endif

ifeq ($(PROBEFILE),top.fsdb)
   VCS_DUMP=+define+DUMP_FSDB
else ifeq ($(PROBEFILE),top.vpd)
   VCS_DUMP=+define+DUMP_VPD
else ifeq ($(PROBEFILE),top.vcd)
   VCS_DUMP=+define+DUMP_VCD
else ifeq ($(PROBEFILE),empty.tcl)
   VCS_DUMP=
else
   VCS_DUMP=+define+DUMP_VPD
endif

ifeq ($(SVSEED),random)
  VCS_SEED=+ntb_random_seed_automatic
else
  VCS_SEED=+ntb_random_seed=$(SVSEED)
endif
# --- end parse arguments

# --- start make targets

vcs: base_clean vcs_compile vcs_sim

vcs_compile:
#	parse start time
#	@echo "[$(TOPOLOGY)][$(TEST)][compile]: $(SEC_TIME)(start)" >> time_parse.out
#	start compile
	vcs \
	-full64 \
	+libext+.v+.sv+.svh \
	-ntb_opts uvm \
	-debug_access+all+dmptf \
	-debug_region+cell+encrypt \
	+vpi +memcbk +vcsd \
	-kdb \
	-V \
	+vcs+lic+wait \
	-notice \
	-sverilog \
	+nocelldefinepli+0 \
    $(CMP_VCS_COV) \
	-xlrm ext_soft_cnst \
	-v2k_generate \
	-timescale=1ps/1ps \
	$(AVERY_PLI)/lib.linux/libtb_vcs64.so \
	-P $(AVERY_PLI)/tb_vcs64.tab \
	-lpthread  \
	+incdir+$(UVM_HOME)/src \
	$(UVM_HOME)/src/uvm_pkg.sv \
	-y $(UVM_HOME)/src \
    $(TOOL_GEN_FILES) \
	$(DEFINES_LIST) \
	-f $(RTL_FILELIST) \
    -l $(VCS_COMPLOG) \
	-top top \
	+define+MAKE_OPT=vcs \
    $(CMPOPT) \
	$(VCS_DUMP)	\
	-f $(TB_FILELIST)
#	parse end time
#	@sed -i '$$s/\([^[:space:]]*\) \(.*\).start./\1 \2(start),'$(SEC_TIME)'(end)/' time_parse.out
#	@awk -F'[ ,()]' '{sec=$$5-$$2;} {printf "%s,%d:%d:%d(duration)\n",$$0,sec/3600,sec/60%60,sec%60}' time_parse.out >> duration_time_parse.out
#	@rm time_parse.out

vcs_sim:
#	parse start time
#	@echo "[$(TOPOLOGY)][$(TEST)][sim]: $(SEC_TIME)(start)" >> time_parse.out
#	start sim and parse compile and simv logs
	./simv $(SIM_VCS_COV) -l $(VCS_SIMLOG) +UVM_TESTNAME=$(TEST) +UVM_VERBOSITY=$(VERBOSE) $(VCS_SEED) $(SIMOPT);
#	parse end time
#	@sed -i '$$s/\([^[:space:]]*\) \(.*\).start./\1 \2(start),'$(SEC_TIME)'(end)/' time_parse.out
#	@awk -F'[ ,()]' '{sec=$$5-$$2;} {printf "%s,%d:%d:%d(duration)\n",$$0,sec/3600,sec/60%60,sec%60}' time_parse.out >> duration_time_parse.out
#	@rm time_parse.out

base_clean:
	@rm -rf xcelium.d *.txt *.log *.rlog *.history waves.shm log_parse.out csrc simv.daidir simv *.trk time_parse.out

clean: base_clean
	@rm -rf duration_time_parse.out

cov_clean: base_clean
	@rm -rf cov_* urgReport novas* *.vdb *.vpd ucli.key vc_hdrs.h vdCovLog verdiLog verdi_config_file

all_clean: cov_clean clean
	@rm -rf regression/result/sanity_* regression/result/regression* regression/result/short_* regression/result/simple_* regression/result/nightly_* regression/result/medium_* regression/result/configurable_*
