// riscv_core_top.v
// RV32I 5-stage pipelined core (IF/ID/EX/MEM/WB).
// Rationale: A 5-stage pipeline balances throughput and complexity, and
// highlights hazard handling and forwarding typical in industry designs.
`timescale 1ns/1ps

`ifndef PIPELINED
`define PIPELINED
`endif

module riscv_core_top #(
    parameter IMEM_FILE = "",
    parameter IMEM_DEPTH = 1024,
    parameter DMEM_DEPTH = 1024
) (
    input clk,
    input rst_n
);
`ifdef PIPELINED
    // IF stage
    wire [31:0] pc_current;
    wire [31:0] pc_next;
    wire [31:0] pc_plus4 = pc_current + 32'd4;
    wire [31:0] instr;

    // ID stage
    wire [31:0] if_id_pc;
    wire [31:0] if_id_instr;
    wire [6:0] opcode = if_id_instr[6:0];
    wire [4:0] rs1 = if_id_instr[19:15];
    wire [4:0] rs2 = if_id_instr[24:20];
    wire [4:0] rd  = if_id_instr[11:7];
    wire [2:0] funct3 = if_id_instr[14:12];
    wire [6:0] funct7 = if_id_instr[31:25];

    wire [31:0] rs1_data;
    wire [31:0] rs2_data;

    wire [31:0] imm_i;
    wire [31:0] imm_s;
    wire [31:0] imm_b;
    wire [31:0] imm_u;
    wire [31:0] imm_j;

    wire        reg_write;
    wire        mem_read;
    wire        mem_write;
    wire        mem_to_reg;
    wire        alu_src;
    wire        branch;
    wire        jump;
    wire        jump_reg;
    wire        lui;
    wire        auipc;
    wire [1:0]  alu_op;

    // Hazard control
    wire pc_write_en;
    wire if_id_write_en;
    wire id_ex_flush;

    // ID/EX stage
    wire        id_ex_reg_write;
    wire        id_ex_mem_read;
    wire        id_ex_mem_write;
    wire        id_ex_mem_to_reg;
    wire        id_ex_alu_src;
    wire        id_ex_branch;
    wire        id_ex_jump;
    wire        id_ex_jump_reg;
    wire        id_ex_lui;
    wire        id_ex_auipc;
    wire [1:0]  id_ex_alu_op;
    wire [31:0] id_ex_pc;
    wire [31:0] id_ex_rs1_data;
    wire [31:0] id_ex_rs2_data;
    wire [31:0] id_ex_imm_i;
    wire [31:0] id_ex_imm_s;
    wire [31:0] id_ex_imm_b;
    wire [31:0] id_ex_imm_u;
    wire [31:0] id_ex_imm_j;
    wire [4:0]  id_ex_rs1;
    wire [4:0]  id_ex_rs2;
    wire [4:0]  id_ex_rd;
    wire [2:0]  id_ex_funct3;
    wire [6:0]  id_ex_funct7;

    // EX stage forwarding
    wire [1:0] forward_a;
    wire [1:0] forward_b;

    // EX stage
    wire [3:0] alu_ctrl;
    wire [31:0] alu_result;
    wire alu_zero;

    wire [31:0] wb_write_data;

    // Forwarded operands
    wire [31:0] ex_rs1_forward = (forward_a == 2'b10) ? ex_mem_alu_result :
                                 (forward_a == 2'b01) ? wb_write_data :
                                 id_ex_rs1_data;
    wire [31:0] ex_rs2_forward = (forward_b == 2'b10) ? ex_mem_alu_result :
                                 (forward_b == 2'b01) ? wb_write_data :
                                 id_ex_rs2_data;

    wire [31:0] imm_alu = (id_ex_lui || id_ex_auipc) ? id_ex_imm_u :
                          (id_ex_mem_write) ? id_ex_imm_s :
                          id_ex_imm_i;

    wire [31:0] alu_in1 = (id_ex_auipc) ? id_ex_pc :
                          (id_ex_lui)   ? 32'h0000_0000 :
                          ex_rs1_forward;

    wire [31:0] alu_in2 = (id_ex_alu_src) ? imm_alu : ex_rs2_forward;

    wire [31:0] ex_pc_plus4 = id_ex_pc + 32'd4;

    // Branch/jump
    wire branch_taken;
    wire [31:0] branch_target = id_ex_pc + id_ex_imm_b;
    wire [31:0] jal_target    = id_ex_pc + id_ex_imm_j;
    wire [31:0] jalr_target   = (ex_rs1_forward + id_ex_imm_i) & 32'hFFFF_FFFE;

    wire take_branch = (id_ex_branch && branch_taken) || id_ex_jump || id_ex_jump_reg;
    wire [31:0] pc_target = id_ex_jump_reg ? jalr_target :
                            id_ex_jump     ? jal_target  :
                            branch_target;

    // EX/MEM stage
    wire        ex_mem_reg_write;
    wire        ex_mem_mem_read;
    wire        ex_mem_mem_write;
    wire        ex_mem_mem_to_reg;
    wire        ex_mem_jump;
    wire [31:0] ex_mem_alu_result;
    wire [31:0] ex_mem_rs2_data;
    wire [31:0] ex_mem_pc_plus4;
    wire [4:0]  ex_mem_rd;

    // MEM stage
    wire [31:0] mem_read_data;

    // MEM/WB stage
    wire        mem_wb_reg_write;
    wire        mem_wb_mem_to_reg;
    wire        mem_wb_jump;
    wire [31:0] mem_wb_alu_result;
    wire [31:0] mem_wb_mem_data;
    wire [31:0] mem_wb_pc_plus4;
    wire [4:0]  mem_wb_rd;

    // Control hazard flush (branch/jump resolved in EX)
    wire if_id_flush = take_branch;
    wire id_ex_flush_ctl = take_branch;

    // Program counter
    program_counter pc_u (
        .clk(clk),
        .rst_n(rst_n),
        .pc_write_en(pc_write_en),
        .pc_next(pc_next),
        .pc_current(pc_current)
    );

    // Instruction memory
    instruction_memory #(
        .MEM_DEPTH(IMEM_DEPTH),
        .MEM_FILE(IMEM_FILE)
    ) imem_u (
        .addr(pc_current),
        .instr(instr)
    );

    // IF/ID pipeline register
    if_id_reg if_id_u (
        .clk(clk),
        .rst_n(rst_n),
        .write_en(if_id_write_en),
        .flush(if_id_flush),
        .pc_in(pc_current),
        .instr_in(instr),
        .pc_out(if_id_pc),
        .instr_out(if_id_instr)
    );

    // Register file
    register_file rf_u (
        .clk(clk),
        .rst_n(rst_n),
        .reg_write_en(mem_wb_reg_write),
        .rs1_addr(rs1),
        .rs2_addr(rs2),
        .rd_addr(mem_wb_rd),
        .rd_data(wb_write_data),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    // Immediate generator
    immediate_generator imm_gen_u (
        .instr(if_id_instr),
        .imm_i(imm_i),
        .imm_s(imm_s),
        .imm_b(imm_b),
        .imm_u(imm_u),
        .imm_j(imm_j)
    );

    // Main control unit
    control_unit ctrl_u (
        .opcode(opcode),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .alu_src(alu_src),
        .branch(branch),
        .jump(jump),
        .jump_reg(jump_reg),
        .lui(lui),
        .auipc(auipc),
        .alu_op(alu_op)
    );

    // Hazard detection (load-use)
    hazard_unit hazard_u (
        .id_ex_mem_read(id_ex_mem_read),
        .id_ex_rd(id_ex_rd),
        .if_id_rs1(rs1),
        .if_id_rs2(rs2),
        .pc_write_en(pc_write_en),
        .if_id_write_en(if_id_write_en),
        .id_ex_flush(id_ex_flush)
    );

    // ID/EX pipeline register
    id_ex_reg id_ex_u (
        .clk(clk),
        .rst_n(rst_n),
        .flush(id_ex_flush || id_ex_flush_ctl),
        .reg_write_in(reg_write),
        .mem_read_in(mem_read),
        .mem_write_in(mem_write),
        .mem_to_reg_in(mem_to_reg),
        .alu_src_in(alu_src),
        .branch_in(branch),
        .jump_in(jump),
        .jump_reg_in(jump_reg),
        .lui_in(lui),
        .auipc_in(auipc),
        .alu_op_in(alu_op),
        .pc_in(if_id_pc),
        .rs1_data_in(rs1_data),
        .rs2_data_in(rs2_data),
        .imm_i_in(imm_i),
        .imm_s_in(imm_s),
        .imm_b_in(imm_b),
        .imm_u_in(imm_u),
        .imm_j_in(imm_j),
        .rs1_in(rs1),
        .rs2_in(rs2),
        .rd_in(rd),
        .funct3_in(funct3),
        .funct7_in(funct7),
        .reg_write_out(id_ex_reg_write),
        .mem_read_out(id_ex_mem_read),
        .mem_write_out(id_ex_mem_write),
        .mem_to_reg_out(id_ex_mem_to_reg),
        .alu_src_out(id_ex_alu_src),
        .branch_out(id_ex_branch),
        .jump_out(id_ex_jump),
        .jump_reg_out(id_ex_jump_reg),
        .lui_out(id_ex_lui),
        .auipc_out(id_ex_auipc),
        .alu_op_out(id_ex_alu_op),
        .pc_out(id_ex_pc),
        .rs1_data_out(id_ex_rs1_data),
        .rs2_data_out(id_ex_rs2_data),
        .imm_i_out(id_ex_imm_i),
        .imm_s_out(id_ex_imm_s),
        .imm_b_out(id_ex_imm_b),
        .imm_u_out(id_ex_imm_u),
        .imm_j_out(id_ex_imm_j),
        .rs1_out(id_ex_rs1),
        .rs2_out(id_ex_rs2),
        .rd_out(id_ex_rd),
        .funct3_out(id_ex_funct3),
        .funct7_out(id_ex_funct7)
    );

    // Forwarding unit
    forwarding_unit fwd_u (
        .ex_mem_reg_write(ex_mem_reg_write),
        .ex_mem_rd(ex_mem_rd),
        .mem_wb_reg_write(mem_wb_reg_write),
        .mem_wb_rd(mem_wb_rd),
        .id_ex_rs1(id_ex_rs1),
        .id_ex_rs2(id_ex_rs2),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );

    // ALU control
    alu_control alu_ctrl_u (
        .alu_op(id_ex_alu_op),
        .funct3(id_ex_funct3),
        .funct7(id_ex_funct7),
        .alu_ctrl(alu_ctrl)
    );

    // ALU
    alu alu_u (
        .op_a(alu_in1),
        .op_b(alu_in2),
        .alu_ctrl(alu_ctrl),
        .result(alu_result),
        .zero(alu_zero)
    );

    // Branch decision
    branch_unit br_u (
        .branch_en(id_ex_branch),
        .funct3(id_ex_funct3),
        .op_a(ex_rs1_forward),
        .op_b(ex_rs2_forward),
        .branch_taken(branch_taken)
    );

    // Next PC logic
    assign pc_next = take_branch ? pc_target : pc_plus4;

    // EX/MEM pipeline register
    ex_mem_reg ex_mem_u (
        .clk(clk),
        .rst_n(rst_n),
        .reg_write_in(id_ex_reg_write),
        .mem_read_in(id_ex_mem_read),
        .mem_write_in(id_ex_mem_write),
        .mem_to_reg_in(id_ex_mem_to_reg),
        .jump_in(id_ex_jump || id_ex_jump_reg),
        .alu_result_in(alu_result),
        .rs2_data_in(ex_rs2_forward),
        .pc_plus4_in(ex_pc_plus4),
        .rd_in(id_ex_rd),
        .reg_write_out(ex_mem_reg_write),
        .mem_read_out(ex_mem_mem_read),
        .mem_write_out(ex_mem_mem_write),
        .mem_to_reg_out(ex_mem_mem_to_reg),
        .jump_out(ex_mem_jump),
        .alu_result_out(ex_mem_alu_result),
        .rs2_data_out(ex_mem_rs2_data),
        .pc_plus4_out(ex_mem_pc_plus4),
        .rd_out(ex_mem_rd)
    );

    // Data memory
    data_memory #(
        .MEM_DEPTH(DMEM_DEPTH)
    ) dmem_u (
        .clk(clk),
        .rst_n(rst_n),
        .mem_read(ex_mem_mem_read),
        .mem_write(ex_mem_mem_write),
        .addr(ex_mem_alu_result),
        .write_data(ex_mem_rs2_data),
        .read_data(mem_read_data)
    );

    // MEM/WB pipeline register
    mem_wb_reg mem_wb_u (
        .clk(clk),
        .rst_n(rst_n),
        .reg_write_in(ex_mem_reg_write),
        .mem_to_reg_in(ex_mem_mem_to_reg),
        .jump_in(ex_mem_jump),
        .alu_result_in(ex_mem_alu_result),
        .mem_data_in(mem_read_data),
        .pc_plus4_in(ex_mem_pc_plus4),
        .rd_in(ex_mem_rd),
        .reg_write_out(mem_wb_reg_write),
        .mem_to_reg_out(mem_wb_mem_to_reg),
        .jump_out(mem_wb_jump),
        .alu_result_out(mem_wb_alu_result),
        .mem_data_out(mem_wb_mem_data),
        .pc_plus4_out(mem_wb_pc_plus4),
        .rd_out(mem_wb_rd)
    );

    // Writeback mux
    assign wb_write_data = mem_wb_jump ? mem_wb_pc_plus4 :
                           mem_wb_mem_to_reg ? mem_wb_mem_data :
                           mem_wb_alu_result;

`else
    // Placeholder for non-pipelined option.
`endif
endmodule
