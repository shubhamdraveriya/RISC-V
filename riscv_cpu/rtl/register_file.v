// register_file.v
// 32 x 32-bit register file with two read ports and one write port.
`timescale 1ns/1ps

module register_file (
    input             clk,
    input             rst_n,
    input             reg_write_en,
    input      [4:0]  rs1_addr,
    input      [4:0]  rs2_addr,
    input      [4:0]  rd_addr,
    input      [31:0] rd_data,
    output     [31:0] rs1_data,
    output     [31:0] rs2_data
);
    reg [31:0] regs [0:31];
    integer i;

    // Synchronous reset for register file contents.
    always @(posedge clk) begin
        if (!rst_n) begin
            for (i = 0; i < 32; i = i + 1) begin
                regs[i] <= 32'h0000_0000;
            end
        end else if (reg_write_en && (rd_addr != 5'd0)) begin
            regs[rd_addr] <= rd_data;
        end
    end

    assign rs1_data = (rs1_addr == 5'd0) ? 32'h0000_0000 : regs[rs1_addr];
    assign rs2_data = (rs2_addr == 5'd0) ? 32'h0000_0000 : regs[rs2_addr];
endmodule
