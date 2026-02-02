// id_ex_reg.v
// Pipeline register between ID and EX stages.
`timescale 1ns/1ps

module id_ex_reg (
    input             clk,
    input             rst_n,
    input             flush,
    // Control signals
    input             reg_write_in,
    input             mem_read_in,
    input             mem_write_in,
    input             mem_to_reg_in,
    input             alu_src_in,
    input             branch_in,
    input             jump_in,
    input             jump_reg_in,
    input             lui_in,
    input             auipc_in,
    input      [1:0]  alu_op_in,
    // Data signals
    input      [31:0] pc_in,
    input      [31:0] rs1_data_in,
    input      [31:0] rs2_data_in,
    input      [31:0] imm_i_in,
    input      [31:0] imm_s_in,
    input      [31:0] imm_b_in,
    input      [31:0] imm_u_in,
    input      [31:0] imm_j_in,
    input      [4:0]  rs1_in,
    input      [4:0]  rs2_in,
    input      [4:0]  rd_in,
    input      [2:0]  funct3_in,
    input      [6:0]  funct7_in,
    // Outputs
    output reg        reg_write_out,
    output reg        mem_read_out,
    output reg        mem_write_out,
    output reg        mem_to_reg_out,
    output reg        alu_src_out,
    output reg        branch_out,
    output reg        jump_out,
    output reg        jump_reg_out,
    output reg        lui_out,
    output reg        auipc_out,
    output reg [1:0]  alu_op_out,
    output reg [31:0] pc_out,
    output reg [31:0] rs1_data_out,
    output reg [31:0] rs2_data_out,
    output reg [31:0] imm_i_out,
    output reg [31:0] imm_s_out,
    output reg [31:0] imm_b_out,
    output reg [31:0] imm_u_out,
    output reg [31:0] imm_j_out,
    output reg [4:0]  rs1_out,
    output reg [4:0]  rs2_out,
    output reg [4:0]  rd_out,
    output reg [2:0]  funct3_out,
    output reg [6:0]  funct7_out
);
    always @(posedge clk) begin
        if (!rst_n || flush) begin
            reg_write_out <= 1'b0;
            mem_read_out  <= 1'b0;
            mem_write_out <= 1'b0;
            mem_to_reg_out <= 1'b0;
            alu_src_out   <= 1'b0;
            branch_out    <= 1'b0;
            jump_out      <= 1'b0;
            jump_reg_out  <= 1'b0;
            lui_out       <= 1'b0;
            auipc_out     <= 1'b0;
            alu_op_out    <= 2'b00;
            pc_out        <= 32'h0000_0000;
            rs1_data_out  <= 32'h0000_0000;
            rs2_data_out  <= 32'h0000_0000;
            imm_i_out     <= 32'h0000_0000;
            imm_s_out     <= 32'h0000_0000;
            imm_b_out     <= 32'h0000_0000;
            imm_u_out     <= 32'h0000_0000;
            imm_j_out     <= 32'h0000_0000;
            rs1_out       <= 5'd0;
            rs2_out       <= 5'd0;
            rd_out        <= 5'd0;
            funct3_out    <= 3'd0;
            funct7_out    <= 7'd0;
        end else begin
            reg_write_out <= reg_write_in;
            mem_read_out  <= mem_read_in;
            mem_write_out <= mem_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            alu_src_out   <= alu_src_in;
            branch_out    <= branch_in;
            jump_out      <= jump_in;
            jump_reg_out  <= jump_reg_in;
            lui_out       <= lui_in;
            auipc_out     <= auipc_in;
            alu_op_out    <= alu_op_in;
            pc_out        <= pc_in;
            rs1_data_out  <= rs1_data_in;
            rs2_data_out  <= rs2_data_in;
            imm_i_out     <= imm_i_in;
            imm_s_out     <= imm_s_in;
            imm_b_out     <= imm_b_in;
            imm_u_out     <= imm_u_in;
            imm_j_out     <= imm_j_in;
            rs1_out       <= rs1_in;
            rs2_out       <= rs2_in;
            rd_out        <= rd_in;
            funct3_out    <= funct3_in;
            funct7_out    <= funct7_in;
        end
    end
endmodule
