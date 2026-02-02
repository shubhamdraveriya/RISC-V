// program_counter.v
// Program counter with synchronous update and active-low reset.
`timescale 1ns/1ps

module program_counter (
    input              clk,
    input              rst_n,
    input              pc_write_en,
    input      [31:0]  pc_next,
    output reg [31:0]  pc_current
);
    always @(posedge clk) begin
        if (!rst_n) begin
            pc_current <= 32'h0000_0000;
        end else if (pc_write_en) begin
            pc_current <= pc_next;
        end
    end
endmodule
