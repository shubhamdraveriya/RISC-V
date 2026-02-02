// data_memory.v
// Simple byte-addressed data memory with word-aligned accesses.
`timescale 1ns/1ps

module data_memory #(
    parameter MEM_DEPTH = 1024
) (
    input             clk,
    input             rst_n,
    input             mem_read,
    input             mem_write,
    input      [31:0] addr,
    input      [31:0] write_data,
    output reg [31:0] read_data
);
    reg [31:0] mem [0:MEM_DEPTH-1];
    wire [31:0] word_addr = addr[31:2];
    integer i;

    always @(posedge clk) begin
        if (!rst_n) begin
            for (i = 0; i < MEM_DEPTH; i = i + 1) begin
                mem[i] <= 32'h0000_0000;
            end
        end else if (mem_write) begin
            mem[word_addr] <= write_data;
        end
    end

    always @(*) begin
        if (mem_read)
            read_data = mem[word_addr];
        else
            read_data = 32'h0000_0000;
    end
endmodule
