# RV32I Pipelined RISC-V CPU (Verilog-2001)

## Project Overview
This project implements a **fully synthesizable RV32I CPU** in Verilog-2001 with a classic **5-stage pipeline (IF, ID, EX, MEM, WB)**. The design is modular, well-commented, and intended for both academic study and portfolio-quality RTL work.

## Architecture (5-Stage Pipeline)
```
IF  ->  ID  ->  EX  ->  MEM  ->  WB
 |       |       |       |       |
PC   RegFile   ALU   DataMem   Writeback
```

### Why a 5-Stage Pipeline?
A 5-stage pipeline balances complexity and throughput, and it reflects how many real-world in-order cores are structured. It also provides a clear platform to demonstrate **hazard detection**, **data forwarding**, and **control hazard handling**.

## Supported RV32I Instructions
**Arithmetic / Logic**
- ADD, SUB, AND, OR, XOR
- SLT, SLTU
- ADDI, ANDI, ORI, XORI

**Shifts**
- SLL, SRL, SRA
- SLLI, SRLI, SRAI

**Memory**
- LW, SW

**Control Flow**
- BEQ, BNE, BLT, BGE
- JAL, JALR

**Upper Immediates**
- LUI, AUIPC

## How to Simulate
Example using Icarus Verilog (adjust to your simulator):
```
iverilog -g2001 -o simv \
  riscv_cpu/rtl/*.v \
  riscv_cpu/tb/tb_riscv_core.v
vvp simv
```

Select a program with a compile-time macro:
```
iverilog -g2001 -o simv \
  -DIMEM_FILE="\"tb/programs/loop.hex\"" \
  riscv_cpu/rtl/*.v riscv_cpu/tb/tb_riscv_core.v
vvp simv
```

## Extending the ISA
To add new instructions:
1. Update `control_unit.v` for opcode decoding.
2. Update `alu_control.v` if new ALU operations are needed.
3. Extend `alu.v` or add specialized functional units.
4. Add tests in `tb/programs/` and update the testbench checks.

## Repository Layout
```
/riscv_cpu/
  rtl/        # synthesizable RTL modules
  tb/         # testbench and programs
  docs/       # documentation
```

