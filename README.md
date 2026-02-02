# RV32I RISC-V CPU (Verilog-2001)

This repository contains a clean, modular, and synthesizable RV32I implementation built around a classic 5‑stage pipeline. The design targets academic and industry portfolio use and includes a verification testbench with sample programs.

## Quick Start

From the repository root:

```bash
iverilog -g2001 -o simv \
  riscv_cpu/rtl/*.v \
  riscv_cpu/tb/tb_riscv_core.v
vvp simv
```

To run a different sample program:

```bash
iverilog -g2001 -o simv \
  -DIMEM_FILE="\"tb/programs/loop.hex\"" \
  riscv_cpu/rtl/*.v riscv_cpu/tb/tb_riscv_core.v
vvp simv
```

## Documentation

Full documentation lives in:
- `riscv_cpu/docs/README.md`
- `riscv_cpu/docs/design_notes.md`

## Repository Layout

```
/riscv_cpu/
  rtl/        # synthesizable RTL modules
  tb/         # testbench and programs
  docs/       # documentation
```

