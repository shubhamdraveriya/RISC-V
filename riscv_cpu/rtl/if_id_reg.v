// if_id_reg.v
// Pipeline register between IF and ID stages.
`timescale 1ns/1ps

module if_id_reg (
    input             clk,
    input             rst_n,
    input             write_en,
    input             flush,
    input      [31:0] pc_in,
    input      [31:0] instr_in,
    output reg [31:0] pc_out,
    output reg [31:0] instr_out
);
    localparam NOP = 32'h0000_0013; // addi x0, x0, 0

    always @(posedge clk) begin
        if (!rst_n) begin
            pc_out    <= 32'h0000_0000;
            instr_out <= NOP;
        end else if (flush) begin
            pc_out    <= 32'h0000_0000;
            instr_out <= NOP;
        end else if (write_en) begin
            pc_out    <= pc_in;
            instr_out <= instr_in;
        end
    end
endmodule
