# MiniRISC V2 Preliminary Timing Baseline

## Clock Target

A preliminary 50 MHz clock target is used.

- Target frequency: 50 MHz
- Target clock period: 20 ns

This is an analysis target and is not yet a measured maximum
operating frequency.

## Current Timing Analysis

Yosys longest-topological-path analysis is used to identify structurally
deep combinational paths in the generic synthesized MiniRISC design.

This analysis identifies logic depth and likely timing-critical regions,
but does not provide FPGA-specific propagation delays.

## Fmax

A reliable Fmax cannot yet be reported because the design has not been
mapped to a specific FPGA architecture and has not undergone
device-specific place-and-route.

The final Fmax will be determined from the minimum achievable clock
period after FPGA timing analysis.

Fmax = 1 / Tmin

## Timing Closure Criterion

For the preliminary 50 MHz target:

Clock period = 20 ns

Timing is considered met when the FPGA implementation reports
non-negative setup slack for the required paths.

## Current Status

- RTL verification: complete
- Generic synthesis: complete
- Structural path analysis: complete
- Preliminary clock constraint: 50 MHz
- Device-specific setup analysis: pending
- Device-specific hold analysis: pending
- Routing-delay analysis: pending
- Final Fmax: pending