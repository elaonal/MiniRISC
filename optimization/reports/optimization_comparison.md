# MiniRISC V2 Optimisation Comparison

## Objective

The purpose of Day 12 was to evaluate whether an additional synthesis
optimisation flow could reduce structural logic complexity without
changing MiniRISC architectural behaviour.

## Baseline

The baseline design used the standard generic Yosys synthesis flow.

Evidence:

- `optimization/baseline/before_optimization.log`
- `optimization/reports/before_compare.txt`

## Optimised Flow

The optimised flow added:

- `opt`
- `fsm`
- `techmap`
- `abc -fast`
- `clean`

Evidence:

- `optimization/reports/after_optimization.log`
- `optimization/reports/after_compare.txt`

## Correctness

The complete MiniRISC RTL regression was rerun after optimisation.

Expected acceptance criterion:

- 16 tests executed
- 16 tests passed
- 0 tests failed

The optimisation is only considered acceptable if architectural
behaviour remains unchanged.

## Structural Comparison

| Metric | Before | After |
|---|---:|---:|
| Generic cell count | See report | See report |
| Longest topological path | See report | See report |
| RTL regression | PASS | PASS |
| ISA behaviour | Unchanged | Unchanged |
| CPU architecture | Unchanged | Unchanged |

## Interpretation

Yosys `ltp` measures structural topological depth. It does not represent
propagation delay in nanoseconds.

Therefore any reduction in the longest topological path should be
reported as a structural improvement rather than a measured increase in
clock frequency.

A final Fmax requires FPGA-specific technology mapping, placement,
routing and timing analysis.

## Conclusion

Day 12 establishes a repeatable before-versus-after optimisation
methodology.

Further timing optimisation should be based on FPGA-specific timing
results rather than arbitrary RTL modifications.
