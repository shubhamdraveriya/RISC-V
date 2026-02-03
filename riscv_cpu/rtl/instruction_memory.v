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
    reg [1023:0] program_file;

    initial begin
        program_file = MEM_FILE;
        $value$plusargs("PROGRAM=%s", program_file);
        if (program_file != "") begin
            $display("[IMEM] Loading program: %0s", program_file);
            $readmemh(program_file, mem);
        end else begin
            $display("[IMEM][ERROR] No program hex specified. Use +PROGRAM=<file>");
        end
    end

    always @(*) begin
        instr = mem[word_addr];
    end
endmodule
