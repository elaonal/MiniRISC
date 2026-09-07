# MiniRISC V2 Timing Analysis

This directory contains the preliminary timing-analysis work for
MiniRISC V2.

## Current Target

- Preliminary clock frequency: 50 MHz
- Preliminary clock period: 20 ns

The 50 MHz value is an analysis target, not a measured maximum
operating frequency.

## Analysis Performed

Yosys is used for structural longest-topological-path analysis after
synthesis and flattening.

This analysis can identify structurally deep combinational paths but
does not provide FPGA-specific propagation delay.

## Current Limitations

The design has not yet undergone device-specific FPGA placement and
routing.

Therefore the following values are not yet claimed:

- final setup slack
- final hold slack
- routing delay
- final critical-path delay in ns
- maximum operating frequency (Fmax)

These will be determined during the FPGA implementation flow.

## Timing Constraint

The preliminary SDC constraint is stored in:

    constraints/minirisc.sdc

## Optimisation Strategy

Optimisation follows a measurement-driven workflow:

    baseline
        ->
    identify bottleneck
        ->
    controlled RTL change
        ->
    regression
        ->
    synthesis
        ->
    timing comparison

CPU architectural behaviour and ISA semantics must remain unchanged
unless a genuine implementation issue requires modification.
