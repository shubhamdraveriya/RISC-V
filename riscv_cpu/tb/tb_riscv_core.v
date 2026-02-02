// tb_riscv_core.v
// Testbench for RV32I core. Loads .hex programs and checks results.
`timescale 1ns/1ps

module tb_riscv_core;
    reg clk;
    reg rst_n;

`ifdef IMEM_FILE
    localparam IMEM_FILE_PARAM = `IMEM_FILE;
`else
    localparam IMEM_FILE_PARAM = "tb/programs/fib.hex";
`endif

    // Instantiate DUT
    riscv_core_top #(
        .IMEM_FILE(IMEM_FILE_PARAM),
        .IMEM_DEPTH(1024),
        .DMEM_DEPTH(1024)
    ) dut (
        .clk(clk),
        .rst_n(rst_n)
    );

    // Clock generation
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // Reset sequence
    initial begin
        rst_n = 1'b0;
        #20;
        rst_n = 1'b1;
    end

    // Waveform dump
    initial begin
        $dumpfile("riscv_core.vcd");
        $dumpvars(0, tb_riscv_core);
    end

    // Instruction trace and memory/register monitoring
    always @(posedge clk) begin
        if (rst_n) begin
            if (dut.mem_wb_reg_write) begin
                $display("[WB] PC=0x%08h rd=x%0d data=0x%08h", dut.mem_wb_pc_plus4 - 32'd4, dut.mem_wb_rd, dut.wb_write_data);
            end
            if (dut.ex_mem_mem_write) begin
                $display("[MEM] STORE addr=0x%08h data=0x%08h", dut.ex_mem_alu_result, dut.ex_mem_rs2_data);
            end
            if (dut.ex_mem_mem_read) begin
                $display("[MEM] LOAD  addr=0x%08h data=0x%08h", dut.ex_mem_alu_result, dut.mem_read_data);
            end
        end
    end

    task run_cycles;
        input integer count;
        integer i;
        begin
            for (i = 0; i < count; i = i + 1) begin
                @(posedge clk);
            end
        end
    endtask

    task check_result;
        input [31:0] expected;
        begin
            if (dut.rf_u.regs[10] === expected) begin
                $display("[PASS] x10 = 0x%08h", dut.rf_u.regs[10]);
            end else begin
                $display("[FAIL] x10 = 0x%08h expected 0x%08h", dut.rf_u.regs[10], expected);
            end
        end
    endtask

    initial begin
        run_cycles(200);

        if (IMEM_FILE_PARAM == "tb/programs/fib.hex") begin
            $display("Checking Fibonacci program...");
            check_result(32'd89);
        end else if (IMEM_FILE_PARAM == "tb/programs/loop.hex") begin
            $display("Checking loop program...");
            check_result(32'd15);
        end else if (IMEM_FILE_PARAM == "tb/programs/branch_test.hex") begin
            $display("Checking branch test program...");
            check_result(32'd10);
        end else if (IMEM_FILE_PARAM == "tb/programs/mem_test.hex") begin
            $display("Checking memory test program...");
            check_result(32'h0000_00FF);
            if (dut.dmem_u.mem[0] === 32'h0000_0055 && dut.dmem_u.mem[1] === 32'h0000_00AA) begin
                $display("[PASS] Memory contents correct.");
            end else begin
                $display("[FAIL] Memory contents incorrect: mem0=0x%08h mem1=0x%08h", dut.dmem_u.mem[0], dut.dmem_u.mem[1]);
            end
        end else begin
            $display("Unknown program file: %s", IMEM_FILE_PARAM);
        end

        $finish;
    end
endmodule
