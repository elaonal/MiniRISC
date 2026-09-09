> **Historical V1 documentation.** Synthesis and FPGA timing described as future work below refer to V1. V2 has completed verification, synthesis, place-and-route and post-route timing analysis: see the [current overview](../README.md) and [implementation evidence](../fpga/reports/implementation_summary.md). Physical FPGA-board validation remains future work.

# MiniRISC V1 Verification

## 1. Overview

MiniRISC V1 was verified using a combination of:

- module-level testbenches
- full-CPU integration tests
- edge-case testing
- branch testing
- waveform inspection
- assembler-to-CPU testing

The objective of verification was not only to prove that individual Verilog modules worked independently, but also to confirm that the complete processor executed MiniRISC programs correctly.

Simulation was performed using:

```text
Icarus Verilog
```

Waveforms were inspected using:

```text
Surfer
```

---

## 2. Verification Strategy

Verification was divided into two levels.

### Module-Level Verification

Individual processor components were tested independently before CPU integration.

Modules tested included:

```text
ALU
Register File
Program Counter
Instruction Decoder
Control Unit
Instruction Memory
Data Memory
Status Register
Control FSM
Instruction Register
```

### Full-CPU Verification

After the modules were integrated into `minirisc_cpu.v`, complete programs were executed.

These tests verified interactions between:

```text
Program Counter
Instruction Memory
Instruction Register
Decoder
Control Unit
FSM
Register File
ALU
Status Register
Data Memory
Writeback logic
```

---

# 3. ALU Verification

The ALU was tested independently using:

```text
tb/alu_tb.v
```

The following operations were verified:

```text
ADD
SUB
AND
OR
XOR
```

Example arithmetic tests included:

```text
5 + 3 = 8
10 - 3 = 7
```

Logical operations were also checked against expected binary results.

---

## Zero Flag Test

The operation:

```text
5 - 5
```

produced:

```text
result = 0
Z = 1
```

This verified that the Zero flag is asserted when the ALU output is zero.

---

## Carry Flag Test

The edge case:

```text
255 + 1
```

was tested.

For an 8-bit processor:

```text
255 = 11111111
1   = 00000001
```

The mathematical result is:

```text
256
```

but only the lower eight bits fit in the result:

```text
00000000
```

Therefore the expected result was:

```text
result = 0
Z = 1
C = 1
```

The ALU test passed.

---

# 4. Register File Verification

The register file was tested using:

```text
tb/register_file_tb.v
```

The following behaviour was verified:

```text
Eight 8-bit registers
Two independent read ports
One write port
Clocked register writes
Synchronous reset
```

Register values changed only on the rising clock edge when:

```text
write_enable = 1
```

The test also confirmed that reset clears the register file.

---

# 5. Program Counter Verification

The Program Counter was tested independently.

The final V1 PC supports:

```text
enable
load
next_pc
```

Normal execution uses:

```text
PC ← PC + 1
```

while jump instructions use:

```text
PC ← next_pc
```

The PC was later modified so that it only updates when:

```text
enable = 1
```

This was required for the multi-cycle architecture because the same instruction must remain active throughout:

```text
FETCH
DECODE
EXECUTE
WRITEBACK
```

---

# 6. Instruction Decoder Verification

The Instruction Decoder was tested with multiple instruction formats.

Examples included:

```text
LDI
ADD
STORE
JMP
```

The test confirmed correct extraction of:

```text
opcode
Rd
Rs
immediate/address
```

For example:

```text
0011001010000000
```

was decoded as:

```text
opcode = 0011
Rd     = 001
Rs     = 010
```

corresponding to:

```asm
ADD R1, R2
```

---

# 7. Control Unit Verification

The Control Unit was tested independently using different opcodes.

The test confirmed generation of control signals including:

```text
alu_op
wb_sel
reg_write_req
flag_write_req
mem_read_req
mem_write_req
jump
jump_zero
halt
```

For example:

```asm
ADD R1, R2
```

produces a control request equivalent to:

```text
ALU operation    = ADD
Register write   = enabled
Flag update      = enabled
Writeback source = ALU
```

---

# 8. Instruction Memory Verification

Instruction memory was tested using program files loaded with:

```verilog
$readmemb
```

The memory organization is:

```text
256 × 16-bit
```

The program file was later parameterised so that different testbenches could execute different programs without modifying the CPU RTL.

For example:

```verilog
.PROGRAM_FILE("programs/carry_test.mem")
```

allows a specific test program to be loaded during simulation.

---

# 9. Data Memory Verification

Data memory was verified using:

```text
tb/data_memory_tb.v
```

The test confirmed:

```text
8-bit memory values
8-bit memory addresses
Combinational reads
Clocked writes
mem_read control
mem_write control
```

The memory organization is:

```text
256 × 8-bit
```

---

# 10. Status Register Verification

The Status Register was tested independently.

It stores:

```text
Zero flag
Carry flag
```

The test confirmed that flags update only when:

```text
write_enable = 1
```

and that reset clears both stored flags.

---

# 11. Control FSM Verification

The MiniRISC control FSM was verified independently.

The states are:

| State | Encoding |
|---|---|
| FETCH | `000` |
| DECODE | `001` |
| EXECUTE | `010` |
| WRITEBACK | `011` |
| HALT | `100` |

Normal execution was confirmed to follow:

```text
FETCH
  ↓
DECODE
  ↓
EXECUTE
  ↓
WRITEBACK
  ↓
FETCH
```

When a HALT request is detected during DECODE:

```text
DECODE → HALT
```

The HALT state remains active until reset.

---

# 12. First Full-CPU Program

The first integrated CPU test executed:

```asm
LDI R1, 5
LDI R2, 3
ADD R1, R2
STORE R1, 10
HALT
```

Expected final state:

```text
R1 = 8
R2 = 3
Memory[10] = 8
CPU halted
```

All checks passed.

This test proved that the basic processor path worked across:

```text
instruction fetch
decode
register read
ALU execution
writeback
memory write
HALT
```

---

# 13. Conditional Branch — Taken

A branch test was created to verify `CMP` together with `JZ`.

Program:

```asm
LDI R1, 5
LDI R2, 5
CMP R1, R2
JZ 6
LDI R3, 99
JMP 7
LDI R3, 42
HALT
```

Since:

```text
R1 = R2
```

the comparison computes:

```text
5 - 5 = 0
```

therefore:

```text
Z = 1
```

The `JZ` instruction was expected to jump to address 6.

Expected result:

```text
R1 = 5
R2 = 5
R3 = 42
Z = 1
CPU halted
```

The test passed.

---

# 14. Conditional Branch — Not Taken

A second branch test used:

```asm
LDI R1, 5
LDI R2, 4
CMP R1, R2
JZ 6
LDI R3, 99
JMP 7
LDI R3, 42
HALT
```

Since:

```text
5 - 4 != 0
```

the Zero flag becomes:

```text
Z = 0
```

Therefore `JZ` must not branch.

Execution continues to:

```asm
LDI R3, 99
```

and then:

```asm
JMP 7
```

skips the instruction that would have loaded 42.

Expected result:

```text
R1 = 5
R2 = 4
R3 = 99
Z = 0
CPU halted
```

The test passed.

This verified both:

```text
JZ not taken
JMP taken
```

---

# 15. Integrated ISA Verification

A larger program was used to verify instructions that were not all exercised by the first CPU tests.

The program included:

```asm
LDI R1, 12
LDI R2, 5
MOV R3, R1
SUB R3, R2
AND R1, R2
OR R1, R2
XOR R1, R2
LDI R4, 42
STORE R4, 20
LOAD R5, 20
NOP
HALT
```

Expected final values were:

```text
R1 = 0
R2 = 5
R3 = 7
R4 = 42
R5 = 42
Memory[20] = 42
Z = 1
CPU halted
```

All checks passed.

Together with the earlier tests, this provided execution evidence for the complete V1 ISA:

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

---

# 16. Integrated Carry Edge Case

Carry behaviour was also tested through the complete CPU rather than only inside the ALU.

Program:

```asm
LDI R1, 255
LDI R2, 1
ADD R1, R2
HALT
```

Expected behaviour:

```text
R1 = 0
R2 = 1
Z = 1
C = 1
CPU halted
```

The following checks passed:

```text
PASS: 255 + 1 wrapped to 0
PASS: R2 remains 1
PASS: Zero flag is set
PASS: Carry flag is set
PASS: CPU halted
```

This verified the complete path:

```text
Register File
     ↓
ALU
     ↓
Flag generation
     ↓
Status Register
     ↓
Register Writeback
```

---

# 17. HALT Stability Verification

HALT behaviour was tested using:

```asm
LDI R1, 7
HALT
```

After the CPU entered HALT, several additional clock cycles were allowed to pass.

The test verified that:

```text
halted remains 1
PC remains unchanged
R1 remains unchanged
```

All checks passed.

This confirmed that MiniRISC does not continue executing instructions after HALT.

---

# 18. Reset Recovery Verification

Reset was asserted while the CPU was already halted.

The test confirmed:

```text
PC → 0
R1 → 0
FSM → FETCH
halted → 0
```

After reset was released, the same program executed again.

Expected result:

```text
R1 = 7
CPU halted again
```

The test passed.

This demonstrated that the processor can recover cleanly from HALT using reset.

---

# 19. Waveform Verification

A dedicated waveform program was used:

```asm
LDI R1, 5
LDI R2, 3
ADD R1, R2
HALT
```

Simulation generated:

```text
sim/minirisc_waveform.vcd
```

The waveform was inspected using Surfer.

The top-level waveform showed the expected processor state sequence:

```text
FETCH
DECODE
EXECUTE
WRITEBACK
```

The Program Counter remained constant while each instruction passed through the four processor states.

For the instruction:

```asm
ADD R1, R2
```

the expected behaviour was:

```text
PC = 2

opcode = ADD
Rd = R1
Rs = R2

Rd value = 5
Rs value = 3

ALU operation = ADD
ALU result = 8

writeback_data = 8
register_write_enable = 1

R1 ← 8
PC ← 3
```

Waveform inspection provided visual confirmation of the multi-cycle execution model.

---

# 20. Python Assembler Verification

MiniRISC includes a Python assembler.

Example assembly input:

```asm
LDI R1, 5
LDI R2, 3
ADD R1, R2
STORE R1, 10
HALT
```

The assembler generates:

```text
0001001000000101
0001010000000011
0011001010000000
1001001000001010
1111000000000000
```

The generated machine code was written to:

```text
programs/assembled_program.mem
```

---

# 21. Assembler-to-CPU Integration Test

The most complete software-to-hardware test was:

```text
Assembly source
      ↓
Python assembler
      ↓
.mem machine-code file
      ↓
Instruction memory
      ↓
MiniRISC CPU
```

The CPU directly loaded:

```text
programs/assembled_program.mem
```

generated by the Python assembler.

Expected final state:

```text
R1 = 8
R2 = 3
Memory[10] = 8
CPU halted
```

The following checks passed:

```text
PASS: R1 = 8
PASS: R2 = 3
PASS: Memory[10] = 8
PASS: CPU halted
```

This verifies that the assembler encoding matches the instruction format expected by the hardware.

---

# 22. Verification Coverage Summary

| Area | Verification |
|---|---|
| ALU arithmetic | Passed |
| ALU logical operations | Passed |
| Zero flag | Passed |
| Carry flag | Passed |
| Register reads/writes | Passed |
| Register reset | Passed |
| Program Counter | Passed |
| Instruction decoding | Passed |
| Control Unit | Passed |
| Instruction memory | Passed |
| Data memory | Passed |
| Status Register | Passed |
| FSM transitions | Passed |
| Full CPU execution | Passed |
| LOAD/STORE | Passed |
| JMP | Passed |
| JZ taken | Passed |
| JZ not taken | Passed |
| CMP | Passed |
| NOP | Passed |
| HALT | Passed |
| HALT stability | Passed |
| Reset after HALT | Passed |
| CPU restart after reset | Passed |
| 8-bit overflow/carry case | Passed |
| Waveform behaviour | Passed |
| Python assembler | Passed |
| Assembler → CPU execution | Passed |

---

# 23. Known V1 Verification Limitations

MiniRISC V1 has strong functional simulation coverage, but it is not intended to represent an industrial verification environment.

Current limitations include:

```text
No formal verification
No constrained-random verification
No functional coverage framework
No SystemVerilog/UVM environment
No FPGA timing verification
No synthesis timing analysis
```

The current verification approach is based primarily on directed Verilog testbenches and waveform inspection.

This approach is appropriate for the educational scope of MiniRISC V1 while still demonstrating structured hardware verification principles.

---

# 24. Conclusion

MiniRISC V1 successfully passed module-level and processor-level verification.

The verification process demonstrated correct operation of:

```text
instruction execution
register operations
arithmetic and logic
memory access
conditional control flow
status flags
HALT behaviour
reset recovery
assembly-code execution
```

The final assembler-to-CPU test demonstrates a complete programming flow from human-readable assembly source to machine-code execution on the custom processor.

MiniRISC V1 therefore meets its primary objective of implementing and verifying a complete small multi-cycle processor in Verilog.