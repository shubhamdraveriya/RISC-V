// control_unit.v
// Decodes opcode/funct3/funct7 into control signals for the pipeline.
`timescale 1ns/1ps

module control_unit (
    input      [6:0] opcode,
    output reg        reg_write,
    output reg        mem_read,
    output reg        mem_write,
    output reg        mem_to_reg,
    output reg        alu_src,
    output reg        branch,
    output reg        jump,
    output reg        jump_reg,
    output reg        lui,
    output reg        auipc,
    output reg [1:0]  alu_op
);
    // Opcode definitions
    localparam OPCODE_RTYPE  = 7'b0110011;
    localparam OPCODE_ITYPE  = 7'b0010011;
    localparam OPCODE_LOAD   = 7'b0000011;
    localparam OPCODE_STORE  = 7'b0100011;
    localparam OPCODE_BRANCH = 7'b1100011;
    localparam OPCODE_JAL    = 7'b1101111;
    localparam OPCODE_JALR   = 7'b1100111;
    localparam OPCODE_LUI    = 7'b0110111;
    localparam OPCODE_AUIPC  = 7'b0010111;

    always @(*) begin
        // Default safe values
        reg_write = 1'b0;
        mem_read  = 1'b0;
        mem_write = 1'b0;
        mem_to_reg = 1'b0;
        alu_src   = 1'b0;
        branch    = 1'b0;
        jump      = 1'b0;
        jump_reg  = 1'b0;
        lui       = 1'b0;
        auipc     = 1'b0;
        alu_op    = 2'b00;

        case (opcode)
            OPCODE_RTYPE: begin
                reg_write = 1'b1;
                alu_src   = 1'b0;
                alu_op    = 2'b10;
            end
            OPCODE_ITYPE: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                alu_op    = 2'b11;
            end
            OPCODE_LOAD: begin
                reg_write = 1'b1;
                mem_read  = 1'b1;
                mem_to_reg = 1'b1;
                alu_src   = 1'b1;
                alu_op    = 2'b00;
            end
            OPCODE_STORE: begin
                mem_write = 1'b1;
                alu_src   = 1'b1;
                alu_op    = 2'b00;
            end
            OPCODE_BRANCH: begin
                branch    = 1'b1;
                alu_op    = 2'b01;
            end
            OPCODE_JAL: begin
                reg_write = 1'b1;
                jump      = 1'b1;
                alu_op    = 2'b00;
            end
            OPCODE_JALR: begin
                reg_write = 1'b1;
                jump_reg  = 1'b1;
                alu_src   = 1'b1;
                alu_op    = 2'b00;
            end
            OPCODE_LUI: begin
                reg_write = 1'b1;
                lui       = 1'b1;
                alu_src   = 1'b1;
                alu_op    = 2'b00;
            end
            OPCODE_AUIPC: begin
                reg_write = 1'b1;
                auipc     = 1'b1;
                alu_src   = 1'b1;
                alu_op    = 2'b00;
            end
            default: begin
                // NOP / illegal opcode -> all controls deasserted
            end
        endcase
    end
endmodule
