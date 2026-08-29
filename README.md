# HP130 SG13G2 CORDIC Sine/Cosine Accelerator

A compact, single-clock, iterative CORDIC sine/cosine accelerator implemented in Verilog and taken through a complete RTL-to-GDSII physical design flow using the IHP SG13G2 (HP130) technology.

## Overview

- Architecture: Iterative sequential CORDIC
- Clocking: Single clock (`clk`)
- Iterations: 8
- Technology: IHP SG13G2 / HP130
- RTL: Verilog
- Simulation: Verilator
- Physical Design: OpenROAD
- Output: 8-bit signed sine/cosine result
- Result scale: 128 ≈ 1.0

## Interface

| Signal | Direction | Width | Description |
|---|---|---:|---|
| `clk` | Input | 1 | System clock |
| `rst_n` | Input | 1 | Active-low reset |
| `ena` | Input | 1 | Design enable |
| `ui_in` | Input | 8 | Angle input |
| `uio_in[0]` | Input | 1 | Start pulse |
| `uio_in[1]` | Input | 1 | Result select: 0 = cosine, 1 = sine |
| `uo_out` | Output | 8 | Signed result |
| `uio_out[2]` | Output | 1 | Done flag |
| `uio_oe` | Output | 8 | Output-enable indication |

## CORDIC Operation

The 8-bit angle input represents approximately 0° to 90°.

- `0` → approximately 0°
- `128` → approximately 45°
- `255` → approximately 90°

The output uses a fixed-point scale where 128 ≈ 1.0.

The design performs eight iterative CORDIC rotations using an atan lookup table.

## RTL Verification

RTL simulation was performed using Verilator.

Representative test cases:

```text
angle_code=0   sel_sin=0  result=129
angle_code=0   sel_sin=1  result=1
angle_code=128 sel_sin=0  result=90
angle_code=128 sel_sin=1  result=92
angle_code=255 sel_sin=0  result=1
angle_code=255 sel_sin=1  result=129
All test cases completed.

## Physical Design Results
Final IHP SG13G2 implementation:

Standard cells: 633
Flip-flops: 37
Chip area: 8470.2996 µm²
Sequential area: 1812.5856 µm²
Sequential area: 21.40%
Timing
Worst slack: 12.23 ns
Minimum clock period: 3.40 ns
Maximum reported frequency: 294.40 MHz
Setup violations: 0
Hold violations: 0
Max slew violations: 0
Max fanout violations: 0
Max capacitance violations: 0
RTL-to-GDSII Flow
RTL synthesis
Floorplanning
Placement
Resizing
Clock-tree synthesis
Global routing
Detailed routing
Fill insertion
Final DEF/ODB/SPEF generation
Final GDS generation
Repository Structure
src/          RTL and testbench
constraints/  SDC timing constraints
reports/      Synthesis, DRC and timing reports
netlist/      Final DEF, ODB, SPEF and gate-level Verilog
gds/          Final GDS files
layout/       Final physical-design images
Technology

IHP SG13G2 130 nm technology and its corresponding standard-cell library were used for the physical implementation.

Author

Mohammed Arbaz Ali

GitHub: https://github.com/arbaz35
