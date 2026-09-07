# MiniRISC V2 Optimisation

Day 12 evaluates MiniRISC using a controlled before-versus-after
synthesis optimisation workflow.

## Method

1. Capture baseline synthesis results
2. Record structural longest-path information
3. Apply additional Yosys optimisation passes
4. Run the complete RTL regression
5. Re-synthesise
6. Compare structural path depth and generic cell count

## Optimised Flow

The experimental optimisation flow uses:

- proc
- opt
- fsm
- memory mapping
- flatten
- techmap
- abc -fast
- clean

## Correctness Requirement

An optimisation is accepted only if MiniRISC continues to pass its
functional regression.

The ISA, CPU state-machine architecture, register semantics and flag
behaviour are not intentionally changed.

## Timing Interpretation

Yosys longest-topological-path analysis measures structural logic depth.

It does not provide FPGA propagation delay in nanoseconds and must not
be used directly to calculate a final Fmax.

Device-specific timing will be evaluated after FPGA synthesis,
placement and routing.

## Evidence

See:

- baseline/before_optimization.log
- reports/after_optimization.log
- reports/optimization_comparison.md
