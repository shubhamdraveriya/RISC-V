// branch_unit.v
// Evaluates branch conditions for RV32I branch instructions.
`timescale 1ns/1ps

module branch_unit (
    input             branch_en,
    input      [2:0]  funct3,
    input      [31:0] op_a,
    input      [31:0] op_b,
    output reg        branch_taken
);
    localparam F3_BEQ = 3'b000;
    localparam F3_BNE = 3'b001;
    localparam F3_BLT = 3'b100;
    localparam F3_BGE = 3'b101;

    always @(*) begin
        if (!branch_en) begin
            branch_taken = 1'b0;
        end else begin
            case (funct3)
                F3_BEQ: branch_taken = (op_a == op_b);
                F3_BNE: branch_taken = (op_a != op_b);
                F3_BLT: branch_taken = ($signed(op_a) < $signed(op_b));
                F3_BGE: branch_taken = ($signed(op_a) >= $signed(op_b));
                default: branch_taken = 1'b0;
            endcase
        end
    end
endmodule
