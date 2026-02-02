// hazard_unit.v
// Detects load-use hazards and requests pipeline stalls/bubbles.
`timescale 1ns/1ps

module hazard_unit (
    input        id_ex_mem_read,
    input  [4:0] id_ex_rd,
    input  [4:0] if_id_rs1,
    input  [4:0] if_id_rs2,
    output reg   pc_write_en,
    output reg   if_id_write_en,
    output reg   id_ex_flush
);
    always @(*) begin
        if (id_ex_mem_read && (id_ex_rd != 5'd0) &&
            ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2))) begin
            // Stall PC and IF/ID; insert bubble in ID/EX.
            pc_write_en   = 1'b0;
            if_id_write_en = 1'b0;
            id_ex_flush   = 1'b1;
        end else begin
            pc_write_en   = 1'b1;
            if_id_write_en = 1'b1;
            id_ex_flush   = 1'b0;
        end
    end
endmodule
