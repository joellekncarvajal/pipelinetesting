seed = random
test = my_axi_base_test
elab = 
#either SHM or VCD or blank
wave =
tb_list  = files.list
sigvip_list = sigvip.f
compile_opt = 
run_opt = 
timescale = -timescale 1ps/1ps

all:
	make comp; \
	make simul;

comp:
	rm -rf xcelium.d/; \
	xrun -64bit +nowarn+LIBNOU -svseed $(seed) +access+rwc \
        -input waves.tcl \
	+nowarn_AAMNSD \
	-disable_sem2009 \
	-incdir ../tb \
	$(timescale) \
	../tb/my_axi_defines.sv \
	-f avy_list.f \
        -f $(sigvip_list) \
	-f $(tb_list) \
	+define+AVERY_ASSERT_ON+AVERY_MONITOR_ON+AVERY_COVERAGE_ON \
	+loadpli1=$(AVERY_PLI)/lib.linux/libwizard64.so:wizard_bootstrap \
	+ncstatus +nowarn+AAMNSD +nowarn+BIGWBS +nowarn+CRCCON  +nowarn+BIGWIX +nowarn+NOMEMP +nowarn+INTWID  \
	+define+AVERY_AXI_USER \
	-y /tools/avery/axixactor-2.0d.190719/src.axi \
	-y /tools/avery/axixactor-2.0d.190719/checker/BP062-BU-01000-r0p1-00rel0/sva \
	-y /tools/avery/axixactor-2.0d.190719/checker/BP062-BU-01000-r0p1-00rel0/verilog \
	+incdir+/tools/avery/axixactor-2.0d.190719/testbench \
	/tools/avery/axixactor-2.0d.190719/src.NC/aaxi_busmonitor.v \
	+define+AVERY_NAMED_CONSTRUCTOR \
	-DINCA \
	+define+AAXI_TOP_PATH=my_aaxi_uvm_test_top \
	+define+AVERY_AXI_UVM+AVERY_UVM \
	-y /tools/uvm/uvm-1.1d/src \
	-y /tools/avery/axixactor-2.0d.190719/src.uvm \
	-y /tools/avery/axixactor-2.0d.190719/testsuite/examples.uvm \
	/tools/uvm/uvm-1.1d/src/dpi/uvm_dpi.cc \
	-licq \
	+sv -l comp.log +define+AVERY_NC \
	-access rw -uvm -uvmhome /tools/uvm/uvm-1.1d -uvmnocdnsextra \
	$(compile_opt) \
	+$(wave) \
	-elaborate \
	+UVM_TESTNAME=$(test); \

simul:
	xrun -R \
	-64bit +nowarn+LIBNOU -svseed $(seed) +access+rwc \
        -input waves.tcl \
        +define+AVERY_ASSERT_ON+AVERY_MONITOR_ON+AVERY_COVERAGE_ON \
        +loadpli1=$(AVERY_PLI)/lib.linux/libwizard64.so:wizard_bootstrap \
        +ncstatus +nowarn+AAMNSD +nowarn+BIGWBS +nowarn+CRCCON  +nowarn+BIGWIX +nowarn+NOMEMP +nowarn+INTWID  \
        +define+AVERY_AXI_USER \
	+define+AVERY_NAMED_CONSTRUCTOR \
	-DINCA \
	+define+AAXI_TOP_PATH=my_aaxi_uvm_test_top \
	+define+AVERY_AXI_UVM+AVERY_UVM \
	-licq \
	+sv +define+AVERY_NC \
	-access rw -uvm -uvmhome /tools/uvm/uvm-1.1d -uvmnocdnsextra \
        $(run_opt) \
        -l run.log \
        +UVM_TESTNAME=$(test); \

simul_old: 
	xrun -R \
	-svseed $(seed) \
	+$(wave_flag) \
	-licqueue \
	+xm64bit\
	+xmnowarn+BIGWIX \
	+xmnowarn+NOMEMP+LIBNOU +nowarn+EXFARG +xmaccess+rwc \
	+xmstatus +nowarn+AAMNSD +nowarn+BIGWBS \
	+nowarn+CRCCON  +nowarn+BIGWIX +nowarn+NOMEMP \
	+nowarn+INTWID  \
	$(run_opt) \
	-l xrun.log \
	+UVM_TESTNAME=$(test); \


