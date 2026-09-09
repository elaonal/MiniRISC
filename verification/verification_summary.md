# MiniRISC V2 Verification Summary

## 1. Overview

MiniRISC V2 uses a layered verification strategy covering individual RTL
modules, complete processor behaviour, instruction-set execution,
SystemVerilog self-checking verification and FPGA-wrapper integration.

The final verification suite is automated through:

```bash
./scripts/run_regression.sh
```

The final regression completed successfully.

---

## 2. Final Regression Result

The final automated regression produced:

```text
PASS = 20
FAIL = 0

OVERALL RESULT: PASS
MINIRISC V2 REGRESSION PASSED
```

Final verification metrics:

| Metric | Result |
|---|---:|
| Tests executed | **20** |
| Tests passed | **20** |
| Tests failed | **0** |
| Regression pass rate | **100%** |
| Final regression status | **PASS** |

---

## 3. Verification Layers

The MiniRISC V2 verification strategy contains four main levels:

```text
Module-Level Verification
          ↓
CPU / ISA Integration Verification
          ↓
SystemVerilog Structured Verification
          ↓
FPGA Integration Verification
```

This structure allows faults to be investigated at both individual-module
and complete-system level.

---

## 4. Module-Level Verification

Nine module-level tests are included in the final regression.

| Test | Result |
|---|---|
| ALU | PASS |
| Register File | PASS |
| Program Counter | PASS |
| Control FSM | PASS |
| Control Unit | PASS |
| Instruction Decoder | PASS |
| Data Memory | PASS |
| Instruction Memory | PASS |
| Status Register | PASS |

Module-level result:

```text
9 / 9 PASS
```

These tests verify the principal building blocks of the MiniRISC processor
independently before they are evaluated as part of the complete CPU.

---

## 5. CPU and ISA Integration Verification

Six processor-level integration tests are included.

| Test | Result |
|---|---|
| Full ISA Integration | PASS |
| Branch — JZ Not Taken | PASS |
| Branch — JZ Taken | PASS |
| Carry Edge Case | PASS |
| HALT and Reset | PASS |
| Assembler Generated Program | PASS |

CPU / ISA integration result:

```text
6 / 6 PASS
```

These tests demonstrate that individual processor blocks operate correctly
when connected together as the complete MiniRISC CPU.

---

## 6. Instruction-Set Verification

MiniRISC uses a custom 16-bit instruction format and an 8-bit datapath.

The implemented instruction set contains fourteen active instructions:

```text
NOP
LDI
MOV
ADD
SUB
AND
OR
XOR
LOAD
STORE
JMP
JZ
CMP
HALT
```

The full ISA integration test exercises processor execution across the custom
instruction set.

The verification programme also tests control-flow behaviour separately so
that branch behaviour is not validated only as part of a larger programme.

---

## 7. Branch Verification

Conditional branching is tested in both possible directions.

### JZ Not Taken

```text
Condition false
      ↓
JZ does not change execution flow
      ↓
PASS
```

### JZ Taken

```text
Condition true
      ↓
JZ redirects the program counter
      ↓
PASS
```

Final branch-outcome coverage:

| Branch Behaviour | Result |
|---|---|
| JZ taken | PASS |
| JZ not taken | PASS |
| JMP execution | PASS |

This is important because testing only one branch outcome would leave part of
the control logic unverified.

---

## 8. Arithmetic Edge-Case Verification

A dedicated processor-level carry test verifies arithmetic overflow behaviour.

One important edge case is:

```text
255 + 1
```

for an 8-bit datapath.

Expected result:

```text
Result = 0
Zero   = 1
Carry  = 1
```

This verifies that MiniRISC correctly handles unsigned overflow while
updating the Zero and Carry status flags.

---

## 9. HALT and Reset Verification

Processor control verification includes dedicated HALT and reset behaviour.

The verification checks:

```text
Normal execution
      ↓
HALT instruction
      ↓
Processor enters HALT state
      ↓
Processor remains halted
      ↓
Reset applied
      ↓
Processor state reinitialised
      ↓
Execution can restart
```

This validates both terminal processor behaviour and recovery through reset.

---

## 10. Assembler-to-CPU Verification

MiniRISC includes a Python assembler.

The verification flow includes a test in which:

```text
Assembly program
      ↓
Python assembler
      ↓
Machine-code memory file
      ↓
MiniRISC instruction memory
      ↓
CPU execution
      ↓
Final architectural state checked
```

Final result:

```text
Assembler Generated Program: PASS
```

This provides end-to-end verification extending beyond the RTL alone.

---

## 11. SystemVerilog Verification

Four SystemVerilog-oriented verification tests are included in the final
regression.

| Test | Result |
|---|---|
| SystemVerilog ALU Self-Checker | PASS |
| Structured ALU Verification | PASS |
| ALU Reference Scoreboard | PASS |
| ALU Regression | PASS |

SystemVerilog verification result:

```text
4 / 4 PASS
```

---

## 12. Self-Checking Verification

The SystemVerilog environment does not rely only on manual waveform
inspection.

The testbench automatically compares actual and expected behaviour.

Conceptually:

```text
Stimulus
   ↓
 DUT
   ↓
Actual Result
   ↓
Automatic Comparison
   ↓
PASS / FAIL
```

This makes failures easier to identify and allows tests to be executed as
part of an automated regression.

---

## 13. Structured Verification Environment

The verification structure evolved into:

```text
Test
  ↓
Driver
  ↓
DUT
  ↓
Monitor
  ↓
Reference Model
  ↓
Scoreboard
  ↓
PASS / FAIL
```

Each component has a different responsibility.

### Driver

Applies input stimulus to the DUT.

### Monitor

Observes DUT inputs and outputs.

### Reference Model

Calculates expected behaviour independently from the RTL implementation.

### Scoreboard

Compares DUT behaviour against the reference-model result.

This separation makes the verification environment more reusable and easier
to extend.

---

## 14. Reference Model

The ALU verification environment contains a behavioural reference model.

Instead of manually providing every expected output:

```text
Input operands
      +
Operation
      ↓
Reference Model
      ↓
Expected result
```

The expected value is calculated automatically.

This reduces manual expected-value errors and supports larger regressions.

---

## 15. Scoreboard Verification

The scoreboard performs automatic comparison between:

```text
RTL result
```

and:

```text
Reference-model result
```

Conceptually:

```text
            DUT
             ↓
        Actual Result
             │
             ▼
          Scoreboard
             ▲
             │
       Expected Result
             ↑
       Reference Model
```

A mismatch produces a verification failure.

The final scoreboard regression result was:

```text
PASS
```

---

## 16. Regression Verification

MiniRISC V2 includes a larger ALU regression in addition to directed tests.

The purpose of regression testing is to repeatedly exercise the design using
multiple input combinations and operation types.

This helps reveal problems that may not appear in a small number of manually
selected examples.

Final result:

```text
ALU Regression: PASS
```

---

## 17. FPGA Integration Verification

The final regression includes the FPGA wrapper:

```text
minirisc_fpga_top
```

The integration test verifies the CPU together with FPGA-facing support logic.

This includes:

```text
MiniRISC CPU
      +
Reset synchronisation
      +
LED debug interface
      +
UART transmitter
```

Final result:

```text
FPGA Wrapper Integration: PASS
```

This verifies the FPGA integration logic in simulation before any future
physical-board deployment.

---

## 18. Automated Regression Architecture

The complete regression is executed using:

```bash
./scripts/run_regression.sh
```

The script automatically performs:

```text
Select test
     ↓
Compile RTL + testbench
     ↓
Check compilation
     ↓
Run simulation
     ↓
Check simulation status
     ↓
Detect reported failure
     ↓
Record PASS / FAIL
     ↓
Run next test
```

After all tests complete:

```text
Total PASS count
      +
Total FAIL count
      ↓
Final regression result
```

---

## 19. Shell Exit Status

The regression script uses its exit status to represent the final result.

```text
exit 0
```

means:

```text
Regression PASS
```

while:

```text
exit 1
```

means:

```text
Regression FAIL
```

This allows the regression script to be integrated into future automated
testing or continuous-integration workflows.

---

## 20. Final Verification Breakdown

The 20-test final regression can be grouped as:

| Verification Category | Tests | Passed | Failed |
|---|---:|---:|---:|
| Module-level RTL | **9** | **9** | **0** |
| CPU / ISA integration | **6** | **6** | **0** |
| SystemVerilog verification | **4** | **4** | **0** |
| FPGA integration | **1** | **1** | **0** |
| **Total** | **20** | **20** | **0** |

Overall:

```text
20 / 20 tests passed
```

Regression pass rate:

```text
100%
```

---

## 21. Key Verified Behaviours

The final verification environment provides evidence for:

- arithmetic operations
- logical operations
- register reads and writes
- program-counter operation
- FSM sequencing
- instruction decoding
- data-memory behaviour
- instruction-memory behaviour
- Zero flag behaviour
- Carry flag behaviour
- complete CPU integration
- instruction-set execution
- unconditional branching
- conditional branch taken
- conditional branch not taken
- arithmetic carry edge cases
- HALT behaviour
- reset behaviour
- post-reset processor recovery
- assembler-generated machine-code execution
- self-checking verification
- reference-model comparison
- scoreboard comparison
- larger regression execution
- FPGA-wrapper integration

---

## 22. Verification Strengths

MiniRISC V2 improves on simple waveform-only testing by combining:

```text
Directed Tests
      +
Edge Cases
      +
CPU Integration Tests
      +
Self-Checking Testbenches
      +
Reference Model
      +
Scoreboard
      +
Regression Testing
      +
Automated Execution
```

This provides substantially stronger evidence of functional correctness than
a single processor simulation.

---

## 23. Verification Limitations

The verification environment is intentionally educational rather than a
commercial-scale verification framework.

The project does not claim:

- formal verification of the complete CPU
- exhaustive mathematical proof of all possible processor states
- UVM implementation
- gate-level simulation of every routed timing path
- physical FPGA validation
- production-grade silicon verification

These would be possible areas for future development.

The current verification scope is appropriate for demonstrating structured
RTL verification concepts within the MiniRISC V2 project.

---

## 24. Future Verification Extensions

Possible future improvements include:

- constrained-random instruction generation
- larger randomly generated processor programs
- full processor architectural reference model
- instruction-by-instruction CPU scoreboard
- functional coverage collection
- code-coverage measurement
- formal properties
- formal equivalence checking
- continuous integration using GitHub Actions
- FPGA hardware-in-the-loop tests

These are potential extensions rather than requirements for MiniRISC V2.

---

## 25. Final Verification Result

Final MiniRISC V2 verification status:

```text
Module verification             PASS
CPU integration                 PASS
ISA integration                 PASS
Branch taken                    PASS
Branch not taken                PASS
Carry edge case                 PASS
HALT/reset                      PASS
Assembler integration           PASS
SystemVerilog self-checking     PASS
Structured verification         PASS
Reference model                 PASS
Scoreboard                      PASS
Regression                      PASS
FPGA wrapper simulation         PASS
```

Quantitative final result:

```text
Tests executed: 20
Tests passed:   20
Tests failed:   0
Pass rate:      100%

OVERALL RESULT: PASS
```

---

## 26. Conclusion

MiniRISC V2 demonstrates a verification workflow that progresses from
individual RTL testbenches to structured SystemVerilog verification and
complete automated regression.

The verification progression is:

```text
Module Tests
      ↓
CPU Integration
      ↓
ISA Tests
      ↓
Edge Cases
      ↓
SystemVerilog Self-Checking
      ↓
Driver / Monitor
      ↓
Reference Model
      ↓
Scoreboard
      ↓
Regression
      ↓
FPGA Integration Verification
```

The final automated regression completed all twenty selected tests with zero
failures.

This provides the functional-verification foundation for the subsequent
successful synthesis, place-and-route and timing-analysis stages of
MiniRISC V2.