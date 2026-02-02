# Design Notes

## Microarchitecture Choice
A **5-stage in-order pipeline (IF/ID/EX/MEM/WB)** was chosen to demonstrate industry-standard control and data hazard handling while remaining approachable for verification and extension. This pipeline structure also enables higher throughput compared to single-cycle and multi-cycle designs, with clear separation of concerns.

## Timing Considerations
- **IF stage**: instruction fetch from instruction memory (combinational ROM in this project).
- **ID stage**: register read and immediate generation; main decode occurs here.
- **EX stage**: ALU operations, branch resolution, and jump target calculation.
- **MEM stage**: data memory access for loads/stores.
- **WB stage**: register writeback.

The pipeline registers (IF/ID, ID/EX, EX/MEM, MEM/WB) ensure clean stage boundaries and improve timing by minimizing combinational depth per stage.

## Hazard Handling
- **Data hazards**: Resolved with a forwarding unit (EX/MEM and MEM/WB forwarding).
- **Load-use hazards**: Detected by the hazard unit; pipeline is stalled and a bubble is inserted.
- **Control hazards**: Branch and jump decisions are resolved in EX; IF/ID and ID/EX are flushed on taken control flow.

## Reset and Clocking
- Single synchronous clock domain.
- Active-low reset (`rst_n`).
- All architectural state (PC, pipeline registers, register file, data memory) resets to a known value.

## Limitations
- No support for CSR, interrupts, or exceptions.
- Instruction and data memory are modeled as simple arrays (no caches).
- Branch decision in EX stage incurs a control hazard penalty.

## Future Extensions
- **M-extension**: integer multiply/divide unit.
- **CSR/interrupts**: trap handling and privilege levels.
- **Caches**: I-cache and D-cache for performance.
- **Branch prediction**: reduce control hazard penalty.
- **More robust memory model**: byte enables and misaligned access handling.

