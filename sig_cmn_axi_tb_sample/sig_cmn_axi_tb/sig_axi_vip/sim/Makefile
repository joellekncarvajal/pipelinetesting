TEST=sig_simple_axi_test
VERBOSE=UVM_FULL
xrun:
	xrun -64bit +access+rwc \
	-input waves.tcl \
	+libext+.v+.sv+.svh  \
	-timescale 1ns/1ps \
	${UVM_HOME}/src/uvm_pkg.sv \
	+incdir+${UVM_HOME}/src \
	-y ${UVM_HOME}/src \
	${UVM_HOME}/src/dpi/uvm_dpi.cc \
	-uvmhome ${UVM_HOME} \
	-f files.f \
	+UVM_TESTNAME=$(TEST) \
	+UVM_VERBOSITY=$(VERBOSE)

clean:
	@rm -rf xcelium.d *.txt *.log *.history waves.shm
