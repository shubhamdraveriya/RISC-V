// instruction_memory.v
// Simple instruction memory (read-only) initialized from hex file.
`timescale 1ns/1ps

module instruction_memory #(
    parameter MEM_DEPTH = 1024,
    parameter MEM_FILE  = ""
) (
    input      [31:0] addr,
    output reg [31:0] instr
);
    reg [31:0] mem [0:MEM_DEPTH-1];
    wire [31:0] word_addr = addr[31:2];

    initial begin
        if (MEM_FILE != "") begin
            $readmemh(MEM_FILE, mem);
        end
    end

    always @(*) begin
        instr = mem[word_addr];
    end
endmodule
