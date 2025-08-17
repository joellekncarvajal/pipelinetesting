/*                                                                                                                                                 * |-----------------------------------------------------------------------|
*/
/* 
    Sequence library to support example UVM tests.

    Note:
    slave_sqr.driver.cfg_info.copy_slave_param(req.slave_param);
    Allocate and copy the slave's parameters from cfg_info.
    If you don't use Avery slave BFM, you need to directly set in this way:
    req.slave_param = new();
    req.slave_param.base_address = ???;
*/

/* Class: single_wr_seq
    Avery UVM sequence to generate basic write trans randomly */

class single_wr_seq extends aaxi_uvm_seq_base;

    `uvm_object_utils( single_wr_seq)
    `uvm_declare_p_sequencer(aaxi_uvm_sequencer)

    rand bit [`AXI_ADDR_WIDTH-1:0] s_addr;
    rand bit [`AXI_DATA_WIDTH-1:0] s_data[$];
    rand bit [`AXI_STRB_WIDTH-1:0] s_strb[$];
    rand bit [7:0]                 s_len;
    rand bit                       s_user;
    rand bit [2:0]                 s_size;

    function new(
        string name = "single_wr_seq",
        aaxi_uvm_sequencer slave_sqr= null,
        bit test_user= 0);
	super.new(name, slave_sqr);
	this.test_user= test_user;
    endfunction

    function void post_do( uvm_sequence_item this_item);
    endfunction

    virtual task body();
        bit ok;
        int byte_count;
        super.body();

	if (test_user) 
            append_callbacks();
	`uvm_info(get_type_name(), $psprintf("%s starting with (test_user %0b)...", get_sequence_path(), test_user), UVM_LOW);

	//repeat(1250) @(p_sequencer.driver.ports.mcb);
        @(p_sequencer.driver.ports.mcb);
        $display("%0t: BENI1", $time);
        @(p_sequencer.driver.ports.mcb);
        $display("%0t: BENI2", $time);


	// Generate random WRITE transfer
            `uvm_create(req);
	    req.vers = p_sequencer.driver.vers;
            p_sequencer.driver.cfg_info.copy_master_param(req.master_param);
            if (slave_sqr != null) 
                slave_sqr.driver.cfg_info.copy_slave_param(req.slave_param);
            else if (req != null)
                set_slave_param(req);

            ok= req.randomize () with {
                kind    == AAXI_WRITE;
                burst   == AAXI_BURST_INCR;
                addr    == s_addr;
                len     == s_len;
                size    == s_size;
                id      == 0;
                awuser  == s_user;
                adw_valid_delay == 10;
                ar_valid_delay == 0;
                aw_valid_delay == 10;
                write_new_interleave == 0;
                write_interleave_size == 0; // ignore interleave set; non-zero use write_interleave array
                b_valid_ready_delay == 0;
                b_ready_delay == 0;
                resp_valid_ready_delay == 0;
            };
            assert (ok) else `uvm_fatal(get_type_name(), "Randomization Failed.");
            if (s_data.size() == 0) begin
//                set_data(req.data, req.slave_param.data_bus_bytes, 'h1a, 'h01);
                set_data(req.data, (req.len+1)*(1<<req.size)-req.addr[`AXI_ALIGN_ADDR-1:0], 'h1a, 'h01);
            end else begin
                for (int i=0; i<=req.len; i++) begin
                    if(s_data.size()<=i)begin
                        s_data.push_back({`AXI_DATA_WIDTH{1'b1}});
                    end
                    for (int j=0; j<(`AXI_DATA_WIDTH/8); j++) begin
                        j = (i==0 && j==0) ? req.addr[`AXI_ALIGN_ADDR-1:0] : j;
                        req.data.push_back(s_data[i][j*8+:8]);
                        if (s_strb.size()>i) begin
                            req.strobes.push_back(s_strb[i][j]);
                        end else begin
                            req.strobes.push_back(1);
                        end
                    end
                end
            end
            // for each data byte, need 1 bit of byte enable
            
            //foreach (req.data[i])
            //    req.strobes.push_back($random);
            `uvm_send(req);

	    if (p_sequencer.driver.cfg_info.uvm_resp)
		get_response(rsp);
	    else
		req.wait_done(100us);
	    //req.print();
	`uvm_info(get_type_name(), "done sequence", UVM_LOW);
    endtask

endclass

/* Class: single_rd_seq
    Avery UVM sequence to generate basic read trans randomly */
class single_rd_seq extends aaxi_uvm_seq_base;

    `uvm_object_utils( single_rd_seq)
    `uvm_declare_p_sequencer(aaxi_uvm_sequencer)

    rand bit [`AXI_ADDR_WIDTH-1:0] s_addr;
    rand bit [7:0]                 s_len;
    rand bit                       s_user;
    rand bit [2:0]                 s_size;

    function new(
        string name = "single_rd_seq",
        aaxi_uvm_sequencer slave_sqr= null,
        bit test_user= 0);
	super.new(name, slave_sqr);
	this.test_user= test_user;
    endfunction

    function void post_do( uvm_sequence_item this_item);
    endfunction

    virtual task body();
        bit ok;

        super.body();

	if (test_user) 
            append_callbacks();
	`uvm_info(get_type_name(), $psprintf("%s starting with (test_user %0b)...", get_sequence_path(), test_user), UVM_LOW);

	//repeat(1250) @(p_sequencer.driver.ports.mcb);

	// Generate random READ transfer
            `uvm_create(req);
            p_sequencer.driver.cfg_info.copy_master_param(req.master_param);
            if (slave_sqr != null) 
                slave_sqr.driver.cfg_info.copy_slave_param(req.slave_param);
            else if (req != null)
                set_slave_param(req);

            ok= req.randomize () with {
                kind    == AAXI_READ;
                burst   == AAXI_BURST_INCR;
                addr    == s_addr;
                len     == s_len;
                size    == s_size;
                id      == 0;
                aruser  == s_user;
                adw_valid_delay == 0; //10;
                ar_valid_delay == 0;
                aw_valid_delay == 0; //10;
                write_new_interleave == 0;
                write_interleave_size == 0; // ignore interleave set; non-zero use write_interleave array
                b_valid_ready_delay == 0;
                b_ready_delay == 0;
                resp_valid_ready_delay == 0;
            };
            assert (ok) else `uvm_fatal(get_type_name(), "Randomization Failed.");
            `uvm_send(req);
	    if (p_sequencer.driver.cfg_info.uvm_resp)
		get_response(rsp);
	    else
		req.wait_done(100us);
	    req.print();
	`uvm_info(get_type_name(), "done sequence", UVM_LOW);
    endtask

endclass
