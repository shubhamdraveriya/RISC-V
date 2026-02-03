# RV32I RISC-V CPU (Verilog-2001)

## Overview
This repository contains a clean, modular, and synthesizable **RV32I** CPU written in
**Verilog-2001**. The core implements a classic **5-stage in-order pipeline** and is
intended for learning, experimentation, and portfolio-quality RTL work. The design ships
with a simple testbench and a set of sample programs to help you get up and running.

If you are new to CPU design, this README starts from first principles: what the core is,
how the pipeline is organized, how to simulate it, and where to look when you want to
extend the ISA.

## What Is RV32I?
**RV32I** is the 32-bit base integer instruction set of the RISC-V specification. It
includes arithmetic/logic operations, loads/stores, branches, and jumps. This project
implements that base ISA (no multiply/divide, atomics, or floating point), which keeps
the pipeline understandable while still supporting meaningful programs.

## Architecture at a Glance
The CPU uses a classic 5-stage pipeline:

```
IF  ->  ID  ->  EX  ->  MEM  ->  WB
 |       |       |       |       |
PC   RegFile   ALU   DataMem   Writeback
```

**Stage responsibilities:**
- **IF (Instruction Fetch):** Fetches the instruction from instruction memory and
  increments the program counter (PC).
- **ID (Instruction Decode):** Decodes the instruction, reads the register file, and
  generates immediate values and control signals.
- **EX (Execute):** Performs ALU operations and computes branch/jump targets.
- **MEM (Memory):** Accesses data memory for loads/stores.
- **WB (Writeback):** Writes results back to the register file.

This structure strikes a balance between throughput and complexity and showcases
pipeline hazards and forwarding logic in a way that is easy to study.

## Supported Instructions (RV32I Subset)
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

## Repository Layout
```
/riscv_cpu/
  rtl/        # synthesizable RTL modules
  tb/         # testbench and programs
  docs/       # documentation and design notes
```

## Getting Started (Simulation)
The testbench is designed to run with Icarus Verilog, but any Verilog-2001 compatible
simulator should work with minimal changes.

**Build and run the default program:**
```bash
iverilog -g2001 -o simv \
  riscv_cpu/rtl/*.v \
  riscv_cpu/tb/tb_riscv_core.v
vvp simv
```

**Run a different sample program:**
```bash
iverilog -g2001 -o simv \
  -DIMEM_FILE="\"tb/programs/loop.hex\"" \
  riscv_cpu/rtl/*.v riscv_cpu/tb/tb_riscv_core.v
vvp simv
```

Available sample programs live in `riscv_cpu/tb/programs/` (e.g., `fib.hex`,
`branch_test.hex`, `mem_test.hex`).

## How to Extend the Core
When adding an instruction or feature, the typical flow is:
1. **Decode**: Update opcode/func decoding in the control logic.
2. **ALU control**: Add or modify ALU operation selection if needed.
3. **Execute**: Implement the operation in the ALU (or a new functional unit).
4. **Verification**: Add a test program in `tb/programs/` and update the testbench as
   needed.

## Documentation
Deeper design notes and module-level explanations are in:
- `riscv_cpu/docs/README.md`
- `riscv_cpu/docs/design_notes.md`

## License
See the repository for license details or contact the maintainer if licensing
information is required.
