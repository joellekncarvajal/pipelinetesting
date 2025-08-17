xrun \
	-64bit \
	+nowarn+LIBNOU \
	-svseed 1234 \
	+access+rwc \
	+ncstatus \
	+nowarn+AAMNSD \
	+nowarn+BIGWBS \
	+nowarn+CRCCON \
	+nowarn+BIGWIX \
	+nowarn+NOMEMP \
	+nowarn+INTWID \
	-f files.f \
	-DINCA \
	-y /tools/uvm/uvm-1.1d/src \
	/tools/uvm/uvm-1.1d/src/dpi/uvm_dpi.cc \
	-licq \
	+sv \
	-l xrun.log \
	-access rw \
	-uvm \
	-uvmhome /tools/uvm/uvm-1.1d \
	-uvmnocdnsextra \
	+UVM_VERBOSITY=UVM_FULL \
	+UVM_TESTNAME=sig_simple_axi_test

