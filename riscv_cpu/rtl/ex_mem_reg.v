// ex_mem_reg.v
// Pipeline register between EX and MEM stages.
`timescale 1ns/1ps

module ex_mem_reg (
    input             clk,
    input             rst_n,
    // Control signals
    input             reg_write_in,
    input             mem_read_in,
    input             mem_write_in,
    input             mem_to_reg_in,
    input             jump_in,
    // Data signals
    input      [31:0] alu_result_in,
    input      [31:0] rs2_data_in,
    input      [31:0] pc_plus4_in,
    input      [4:0]  rd_in,
    // Outputs
    output reg        reg_write_out,
    output reg        mem_read_out,
    output reg        mem_write_out,
    output reg        mem_to_reg_out,
    output reg        jump_out,
    output reg [31:0] alu_result_out,
    output reg [31:0] rs2_data_out,
    output reg [31:0] pc_plus4_out,
    output reg [4:0]  rd_out
);
    always @(posedge clk) begin
        if (!rst_n) begin
            reg_write_out  <= 1'b0;
            mem_read_out   <= 1'b0;
            mem_write_out  <= 1'b0;
            mem_to_reg_out <= 1'b0;
            jump_out       <= 1'b0;
            alu_result_out <= 32'h0000_0000;
            rs2_data_out   <= 32'h0000_0000;
            pc_plus4_out   <= 32'h0000_0000;
            rd_out         <= 5'd0;
        end else begin
            reg_write_out  <= reg_write_in;
            mem_read_out   <= mem_read_in;
            mem_write_out  <= mem_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            jump_out       <= jump_in;
            alu_result_out <= alu_result_in;
            rs2_data_out   <= rs2_data_in;
            pc_plus4_out   <= pc_plus4_in;
            rd_out         <= rd_in;
        end
    end
endmodule
