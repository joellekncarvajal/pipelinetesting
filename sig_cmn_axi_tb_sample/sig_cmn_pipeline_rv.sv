module sig_cmn_pipeline_rv #(
    parameter DWIDTH     = 32,
    parameter NUM_STAGES =  1)
(
    input  logic              clk,
    input  logic              reset_n,
    input  logic              valid_in,
    output logic              ready_out,
    input  logic [DWIDTH-1:0] data_in,
    output logic              valid_out,
    input  logic              ready_in,
    output logic [DWIDTH-1:0] data_out);

    generate if (NUM_STAGES == 0) begin : gen_bypass
        assign valid_out = valid_in;
        assign ready_out = ready_in;
        assign data_out  = data_in;
    end else begin : gen_pipeline
        logic   [NUM_STAGES:0] stage_valid;
        logic   [NUM_STAGES:0] stage_ready;
        logic     [DWIDTH-1:0] stage_data [NUM_STAGES:0];
        logic [NUM_STAGES-1:0] stage_reg_valid;
        logic     [DWIDTH-1:0] stage_reg_data [NUM_STAGES-1:0];

        assign stage_valid[0]          = valid_in;
        assign ready_out               = stage_ready[0];
        assign stage_data[0]           = data_in;
        assign valid_out               = stage_valid[NUM_STAGES];
        assign stage_ready[NUM_STAGES] = ready_in;
        assign data_out                = stage_data[NUM_STAGES];

        genvar i;
        for (i = 0; i < NUM_STAGES; i++) begin : gen_stage
            assign stage_ready[i] = stage_ready[i+1] || !stage_valid[i+1];
            always_ff @(posedge clk or negedge reset_n) begin
                if (reset_n == '0) begin
                    stage_valid[i+1]   <= '0;
                    stage_reg_valid[i] <= '0;
                end else begin
                    if (stage_ready[i+1] == 1'd1) begin
                        stage_valid[i+1]   <= stage_valid[i] || stage_reg_valid[i];
                        stage_reg_valid[i] <= 1'b0;
                    end else if (stage_valid[i] && stage_ready[i]) begin
                        stage_reg_valid[i] <= 1'b1;
                    end // if()
                end // if()
            end

            always_ff @(posedge clk or negedge reset_n) begin
                if (reset_n == '0) begin
                    stage_data[i+1]   <= '0;
                    stage_reg_data[i] <= '0;
                end else begin
                    if (stage_ready[i+1] == 1'd1) begin
                        if (stage_reg_valid[i]) begin
                            stage_data[i+1] <= stage_reg_data[i];
                        end else begin
                            stage_data[i+1] <= stage_data[i];
                        end // if()
                    end else if (stage_valid[i] && stage_ready[i]) begin
                        stage_reg_data[i] <= stage_data[i];
                    end // if()
                end // if()
            end
        end // for()
    end endgenerate
endmodule // sig_cmn_pipeline_rv