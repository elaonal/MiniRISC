# MiniRISC V1 Instruction Set Architecture

## 1. Overview

MiniRISC V1 uses a custom 16-bit instruction set.

Each instruction contains a 4-bit opcode together with register fields, immediate values, or memory/jump addresses depending on the instruction type.

The processor operates on 8-bit data and contains eight general-purpose registers.

```text
Instruction width = 16 bits
Data width        = 8 bits
Registers         = R0-R7
Address width     = 8 bits
```

---

## 2. Register Encoding

| Register | Encoding |
|---|---|
| R0 | `000` |
| R1 | `001` |
| R2 | `010` |
| R3 | `011` |
| R4 | `100` |
| R5 | `101` |
| R6 | `110` |
| R7 | `111` |

All eight registers are general-purpose 8-bit registers.

---

## 3. Instruction Formats

MiniRISC V1 uses three main instruction formats.

### Register-Register Format

Used by:

```text
MOV
ADD
SUB
AND
OR
XOR
CMP
```

Format:

```text
15          12 11      9 8       6 5             0
+-------------+----------+----------+---------------+
|   OPCODE    |    Rd    |    Rs    |    UNUSED     |
+-------------+----------+----------+---------------+
     4 bits      3 bits     3 bits       6 bits
```

Unused bits are encoded as zero.

Example:

```asm
ADD R1, R2
```

Encoding:

```text
0011 001 010 000000
```

Final machine code:

```text
0011001010000000
```

---

### Immediate / Memory Format

Used by:

```text
LDI
LOAD
STORE
```

Format:

```text
15          12 11      9 8 7                       0
+-------------+----------+-+-------------------------+
|   OPCODE    |    Rd    |0|     IMM / ADDRESS       |
+-------------+----------+-+-------------------------+
     4 bits      3 bits  1          8 bits
```

Example:

```asm
LDI R1, 5
```

Encoding:

```text
0001 001 0 00000101
```

Final machine code:

```text
0001001000000101
```

---

### Jump Format

Used by:

```text
JMP
JZ
```

Format:

```text
15          12 11             8 7                 0
+-------------+----------------+--------------------+
|   OPCODE    |     UNUSED     |      ADDRESS       |
+-------------+----------------+--------------------+
     4 bits         4 bits             8 bits
```

Unused bits are encoded as zero.

Example:

```asm
JMP 20
```

Address 20 in binary:

```text
00010100
```

Encoding:

```text
1010 0000 00010100
```

Final machine code:

```text
1010000000010100
```

---

## 4. Opcode Table

| Opcode | Mnemonic | Operation |
|---|---|---|
| `0000` | NOP | No operation |
| `0001` | LDI | Load immediate |
| `0010` | MOV | Copy register |
| `0011` | ADD | Addition |
| `0100` | SUB | Subtraction |
| `0101` | AND | Bitwise AND |
| `0110` | OR | Bitwise OR |
| `0111` | XOR | Bitwise XOR |
| `1000` | LOAD | Read data memory |
| `1001` | STORE | Write data memory |
| `1010` | JMP | Unconditional jump |
| `1011` | JZ | Jump if Zero flag is set |
| `1100` | CMP | Compare two registers |
| `1101` | Reserved | Future use |
| `1110` | Reserved | Future use |
| `1111` | HALT | Stop processor execution |

---

## 5. Instruction Definitions

### NOP

```asm
NOP
```

Performs no processor operation.

```text
Opcode: 0000
```

Encoding:

```text
0000000000000000
```

---

### LDI — Load Immediate

```asm
LDI Rd, immediate
```

Loads an 8-bit immediate value into a register.

Operation:

```text
Rd ← immediate
```

Example:

```asm
LDI R1, 5
```

Result:

```text
R1 = 5
```

Encoding:

```text
0001001000000101
```

Immediate range:

```text
0 – 255
```

---

### MOV — Move Register

```asm
MOV Rd, Rs
```

Copies the contents of Rs into Rd.

Operation:

```text
Rd ← Rs
```

Example:

```asm
MOV R3, R1
```

If:

```text
R1 = 12
```

then:

```text
R3 = 12
```

---

### ADD — Addition

```asm
ADD Rd, Rs
```

Adds Rs to Rd.

Operation:

```text
Rd ← Rd + Rs
```

The Zero and Carry flags are updated.

Example:

```asm
LDI R1, 5
LDI R2, 3
ADD R1, R2
```

Result:

```text
R1 = 8
```

For:

```text
255 + 1
```

the 8-bit result wraps to:

```text
0
```

and:

```text
Z = 1
C = 1
```

---

### SUB — Subtraction

```asm
SUB Rd, Rs
```

Subtracts Rs from Rd.

Operation:

```text
Rd ← Rd - Rs
```

The Zero flag is updated.

Example:

```asm
LDI R1, 10
LDI R2, 3
SUB R1, R2
```

Result:

```text
R1 = 7
```

---

### AND — Bitwise AND

```asm
AND Rd, Rs
```

Operation:

```text
Rd ← Rd AND Rs
```

The Zero flag is updated.

---

### OR — Bitwise OR

```asm
OR Rd, Rs
```

Operation:

```text
Rd ← Rd OR Rs
```

The Zero flag is updated.

---

### XOR — Bitwise XOR

```asm
XOR Rd, Rs
```

Operation:

```text
Rd ← Rd XOR Rs
```

The Zero flag is updated.

---

### LOAD — Load Data Memory

```asm
LOAD Rd, address
```

Loads one byte from data memory.

Operation:

```text
Rd ← Memory[address]
```

Example:

```asm
LOAD R2, 20
```

causes:

```text
R2 ← Memory[20]
```

Valid addresses:

```text
0 – 255
```

---

### STORE — Store Data Memory

```asm
STORE Rd, address
```

Writes the contents of Rd into data memory.

Operation:

```text
Memory[address] ← Rd
```

Example:

```asm
STORE R1, 20
```

stores the current value of R1 into data-memory address 20.

---

### JMP — Unconditional Jump

```asm
JMP address
```

Loads the target address into the Program Counter.

Operation:

```text
PC ← address
```

Example:

```asm
JMP 10
```

causes execution to continue from instruction address 10.

---

### JZ — Jump if Zero

```asm
JZ address
```

Tests the stored Zero flag.

If:

```text
Z = 1
```

then:

```text
PC ← address
```

Otherwise execution continues with the next sequential instruction.

Example:

```asm
CMP R1, R2
JZ 10
```

If R1 and R2 are equal, CMP produces a zero subtraction result and sets:

```text
Z = 1
```

Therefore the JZ instruction jumps to address 10.

---

### CMP — Compare

```asm
CMP Rd, Rs
```

Compares two registers by internally performing:

```text
Rd - Rs
```

The result is **not written back** to a register.

Only the processor flags are updated.

Conceptually:

```text
temporary_result = Rd - Rs

Z ← (temporary_result == 0)
```

Therefore:

```asm
CMP R1, R2
```

followed by:

```asm
JZ address
```

can implement an equality branch.

---

### HALT

```asm
HALT
```

Stops normal processor execution.

Encoding:

```text
1111000000000000
```

When HALT is decoded, the control FSM enters the HALT state.

The processor remains halted until reset.

---

## 6. Status Flags

MiniRISC V1 contains two status flags.

| Flag | Name | Meaning |
|---|---|---|
| Z | Zero | ALU result equals zero |
| C | Carry | Unsigned ADD produced a carry-out |

The following instructions request flag updates:

```text
ADD
SUB
AND
OR
XOR
CMP
```

The Carry flag is specifically generated by ADD in the current V1 ALU implementation.

---

## 7. Example Program

Assembly:

```asm
LDI R1, 5
LDI R2, 3
ADD R1, R2
STORE R1, 10
HALT
```

Generated machine code:

```text
0001001000000101
0001010000000011
0011001010000000
1001001000001010
1111000000000000
```

Execution result:

```text
R1 = 8
R2 = 3
Memory[10] = 8
CPU = HALTED
```

---

## 8. Python Assembler

MiniRISC includes a Python assembler that converts human-readable assembly code into the 16-bit binary format expected by the instruction memory.

For example:

```asm
LDI R1, 5
ADD R1, R2
HALT
```

is translated into binary machine instructions automatically.

The assembler supports:

```text
Decimal values
Hexadecimal values
Binary values
Inline comments
Register validation
Immediate/address range checking
Operand validation
Instruction validation
.mem file generation
```

Example command:

```bash
python3 assembler/assembler.py programs/test_program.asm programs/assembled_program.mem
```

The resulting `.mem` file can then be loaded directly by the MiniRISC instruction memory.

---

## 9. V1 Limitations

MiniRISC V1 intentionally keeps the ISA small and understandable.

Current limitations include:

```text
No signed-overflow flag
No negative flag
No stack
No CALL/RET instructions
No interrupts
No indirect memory addressing
No hardware multiplication/division
No pipelining
```

Opcodes `1101` and `1110` are reserved for possible future extensions.