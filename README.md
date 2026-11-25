# RISC-V AI Accelerator

This project develops RTL components for a RISC-V-based system with dedicated
hardware acceleration for AI workloads. Current work focuses on CPU building
blocks and their verification, laying the groundwork for an integrated
accelerator system.

## Progress

Based on the project history and current files:

- Implemented a 32-bit register file and a register-file testbench.
- Implemented an ALU with arithmetic, logical, shift, and comparison
  operations, with a UVM verification environment.
- Added an immediate generator and a testbench for it.
- Added a decoder for common RV32I instruction families, including arithmetic,
  loads and stores, branches, and jumps.

Together, these components form a foundation for the processor and accelerator
system described by this project.

## Repository layout

- `rtl/cpu/` - CPU building blocks: ALU, decoder, immediate generator, and
  register file.
- `rtl/accelerator/` - planned accelerator RTL.
- `rtl/soc/` and `rtl/peripherals/` - planned system and peripheral RTL.
- `tb/` - directed testbenches.
- `verification/uvm/` - UVM verification environments.
- `model/` - planned reference model and test vectors.
- `sw/` - planned firmware and drivers.
- `docs/` - project documentation and design decisions.

## Verification

Verification includes directed testbenches for the immediate generator and
register file, plus UVM environments for the ALU and register file.
