# MiniRISC V2 Verification

MiniRISC V2 extends the original MiniRISC verification environment with
SystemVerilog-based self-checking verification, reference models,
scoreboards, functional coverage, assertions, constrained-random testing,
edge-case testing and automated regression.

## Verification Strategy

The verification environment uses several complementary techniques:

- Directed unit tests
- Self-checking SystemVerilog testbenches
- Driver / monitor separation
- Independent reference models
- Architectural scoreboards
- Functional coverage
- Coverage closure
- Immediate SystemVerilog assertions
- Deliberate fault-injection tests
- Instruction-retirement monitoring
- Whole-CPU architectural checking
- Branch and PC checking
- Constrained-random verification
- Directed boundary and edge-case regression
- Automated regression scripting

## ALU Verification

The ALU verification environment checks:

- ADD
- SUB
- AND
- OR
- XOR
- Zero flag
- Carry flag
- Overflow/wraparound cases such as 255 + 1
- Boundary operand values
- Random operand combinations

A defined 27-bin ALU functional coverage plan was closed completely.

This represents 100% coverage of the defined ALU coverage plan, not
100% verification of the entire processor.

## Assertions

Assertions and invariant checks cover:

- ALU result/flag relationships
- Control Unit output combinations
- FSM legal states and transitions
- HALT behaviour
- CPU reset behaviour
- Program Counter behaviour
- PC wraparound
- Reset priority

A deliberate verification-side fault injection demonstrates that the
checking environment detects an intentionally corrupted observation.

## Whole-CPU Verification

MiniRISC instructions are monitored at architectural retirement.

Normal instructions retire at WRITEBACK.

HALT is treated separately because it transitions from DECODE directly
to the HALT state.

The whole-CPU reference model independently predicts architectural
state including:

- R0-R7
- Zero flag
- Carry flag
- Data memory effects
- Instruction behaviour

The architectural scoreboard compares the MiniRISC DUT against this
reference state after instruction retirement.

## Control Flow Verification

Dedicated tests verify:

- Sequential PC progression
- JMP
- JZ taken
- JZ not taken
- Skipped instructions
- HALT PC stability

## Constrained-Random Verification

Python generates reproducible MiniRISC programs using a fixed seed.

Random programs exercise:

- LDI
- MOV
- ADD
- SUB
- AND
- OR
- XOR
- CMP
- NOP
- HALT

Branches and memory operations are handled separately so that the
initial constrained-random programs remain deterministic and
guaranteed to terminate.

The random whole-CPU scoreboard checks architectural state after every
retired instruction.

## Directed Edge Cases

Dedicated CPU-level edge testing includes:

- 0
- 1
- 254
- 255
- 255 + 1
- 255 + 255
- 254 + 1
- subtraction producing zero
- subtraction underflow/wraparound
- logic producing zero
- logic producing 255
- XOR with the same register
- writes to R0
- CMP equal
- CMP not equal

R0 is intentionally treated as a normal writable MiniRISC
general-purpose register.

## Automated Regression

Run the complete verification regression with:

```bash
./verification/run_regression.sh