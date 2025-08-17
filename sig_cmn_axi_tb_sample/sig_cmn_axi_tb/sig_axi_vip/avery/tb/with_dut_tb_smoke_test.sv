
class no_dut_tb_smoke_test extends axi2sram_base_test;
    int num_trans;

    `uvm_component_utils( no_dut_tb_smoke_test )

    single_wr_seq wseq;
    single_rd_seq rseq;

    function new( string name = "no_dut_tb_smoke_test", uvm_component parent = null);
	super.new(name, parent);
    endfunction

    virtual function void build();
	super.build();
    endfunction

    task run_phase(uvm_phase phase);
        bit ok;
        sram_wr_seq wr_seq;
        sram_rd_seq rd_seq;
        phase.raise_objection(this);

        super.run_phase(phase);
        fork
            begin
                for (int i=0; i<4; i++) begin
                  wr_seq = sram_wr_seq::type_id::create("wr_seq", this);
                  wr_seq.randomize() with {
                    addr_s == 256*i;
                    data_s == {i[7:0],i[7:0],i[7:0],i[7:0]};
                  };
                  wr_seq.start(sram_env0.agt.sqr);
                end
                for (int i=0; i<4; i++) begin
                  rd_seq = sram_rd_seq::type_id::create("rd_seq", this);
                  rd_seq.randomize() with {
                    addr_s == 256*i;
                  };
                  rd_seq.start(sram_env0.agt.sqr);
                  $display("%0t: READ - ADDR=%0x, DATA=%0x", $time, rd_seq.addr_s, rd_seq.data_s);
                end
            end
            begin
            `ifdef USER_UVM_SLAVE
                wseq = new();
                rseq = new();
            `else 
        	wseq = new(, tb0.env0.slave[0].sequencer);
                rseq = new(, tb0.env0.slave[0].sequencer);
            `endif
        
             // WRITE CASES
            
             // CASE 1.0: Let sequence generate wdata and wstrb
             //           - wdata follows incrementing byte pattern
             //           - wstrb is set to 1 for all valid byte lanes
                ok = wseq.randomize() with {
                    s_addr == 10'h135;
                    s_user == 0;
                    s_len  == 3;
                    s_size == 2;
                };
                assert (ok) else `uvm_fatal(get_type_name(), "Randomization Failed.");
        	wseq.start(tb0.env0.master[0].sequencer, null);
        
             // CASE 1.1: User provides wdata; wdata is `AXI_DATA_WIDTH bits wide
             //           - number of wdata is equal to AWLEN+1
                ok = wseq.randomize() with {
                    s_addr == 10'h004;
                    s_user == 1;
                    s_len  == 0;
                    s_size == 2;
                };
                wseq.s_data.delete();
                wseq.s_data.push_back(32'hB001_A001);
                assert (ok) else `uvm_fatal(get_type_name(), "Randomization Failed.");
                wseq.start(tb0.env0.master[0].sequencer, null);
        
             // CASE 1.2: User provides wdata; wdata is `AXI_DATA_WIDTH bits wide
             //           - number of wdata provided is less than AWLEN+1 
             //           - sequence will provide additional data
                ok = wseq.randomize() with {
                    s_addr == 10'h246;
                    s_user == 0;
                    s_len  == 5;
                    s_size == 2;
                };
                wseq.s_data.delete();
                wseq.s_data.push_back(32'h03020100);
                wseq.s_data.push_back(32'h07060504);
                assert (ok) else `uvm_fatal(get_type_name(), "Randomization Failed.");
                wseq.start(tb0.env0.master[0].sequencer, null);
        
             // READ CASES
        
             // CASE 1.0: Read Transaction
                ok = rseq.randomize() with {
                    s_addr == 10'h246;
                    s_user == 0;
                    s_len  == 5;
                    s_size == 2;
                };
                assert (ok) else `uvm_fatal(get_type_name(), "Randomization Failed.");
                rseq.start(tb0.env0.master[0].sequencer, null);
        
                ok = rseq.randomize() with {
                    s_addr == 10'h004;
                    s_user == 1;
                    s_len  == 0;
                    s_size == 2;
                };
                assert (ok) else `uvm_fatal(get_type_name(), "Randomization Failed.");
                rseq.start(tb0.env0.master[0].sequencer, null);
        
                ok = rseq.randomize() with {
                    s_addr == 10'h135;
                    s_user == 0;
                    s_len  == 3;
                    s_size == 2;
                };
                assert (ok) else `uvm_fatal(get_type_name(), "Randomization Failed.");
                rseq.start(tb0.env0.master[0].sequencer, null);
            end
        join
        #50;

        phase.drop_objection(this);
    endtask
endclass

