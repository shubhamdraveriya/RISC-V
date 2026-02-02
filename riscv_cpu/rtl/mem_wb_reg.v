// mem_wb_reg.v
// Pipeline register between MEM and WB stages.
`timescale 1ns/1ps

module mem_wb_reg (
    input             clk,
    input             rst_n,
    // Control signals
    input             reg_write_in,
    input             mem_to_reg_in,
    input             jump_in,
    // Data signals
    input      [31:0] alu_result_in,
    input      [31:0] mem_data_in,
    input      [31:0] pc_plus4_in,
    input      [4:0]  rd_in,
    // Outputs
    output reg        reg_write_out,
    output reg        mem_to_reg_out,
    output reg        jump_out,
    output reg [31:0] alu_result_out,
    output reg [31:0] mem_data_out,
    output reg [31:0] pc_plus4_out,
    output reg [4:0]  rd_out
);
    always @(posedge clk) begin
        if (!rst_n) begin
            reg_write_out  <= 1'b0;
            mem_to_reg_out <= 1'b0;
            jump_out       <= 1'b0;
            alu_result_out <= 32'h0000_0000;
            mem_data_out   <= 32'h0000_0000;
            pc_plus4_out   <= 32'h0000_0000;
            rd_out         <= 5'd0;
        end else begin
            reg_write_out  <= reg_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            jump_out       <= jump_in;
            alu_result_out <= alu_result_in;
            mem_data_out   <= mem_data_in;
            pc_plus4_out   <= pc_plus4_in;
            rd_out         <= rd_in;
        end
    end
endmodule
