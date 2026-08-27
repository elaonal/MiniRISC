# MiniRISC V1

A custom 8-bit multi-cycle RISC-style processor designed and implemented in Verilog.

MiniRISC was built as an educational computer architecture project to understand how a processor works internally — from fetching a binary instruction to decoding it, performing arithmetic or memory operations, updating flags, controlling program flow, and writing results back to registers.

The project also includes a Python assembler that converts human-readable MiniRISC assembly into machine code that can be executed directly by the processor.

---

## Project Overview

MiniRISC V1 is a custom processor with:

| Feature | Specification |
|---|---|
| Data width | 8-bit |
| Instruction width | 16-bit |
| Registers | 8 × 8-bit general-purpose registers |
| Program Counter | 8-bit |
| Instruction Memory | 256 × 16-bit |
| Data Memory | 256 × 8-bit |
| Architecture | Multi-cycle |
| Execution stages | FETCH → DECODE → EXECUTE → WRITEBACK |
| Status flags | Zero (Z), Carry (C) |
| HDL | Verilog |
| Assembler | Python |
| Simulation | Icarus Verilog |
| Waveform analysis | Surfer |

MiniRISC uses a custom instruction set and is not binary-compatible with RISC-V, ARM, or another commercial ISA.

---

## Architecture

MiniRISC uses a multi-cycle architecture.

Each normal instruction progresses through:

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

A separate HALT state stops processor execution until reset.

At a high level:

```text
                   +--------------------+
                   |  Program Counter   |
                   +---------+----------+
                             |
                             v
                   +--------------------+
                   | Instruction Memory |
                   +---------+----------+
                             |
                             v
                   +--------------------+
                   | Instruction Reg.   |
                   +---------+----------+
                             |
                             v
                   +--------------------+
                   | Instruction Decoder|
                   +----+-----------+---+
                        |           |
                        |           v
                        |     +-----------+
                        |     | Control   |
                        |     | Unit / FSM|
                        |     +-----------+
                        |
                        v
               +------------------+
               |  Register File   |
               |     R0 - R7      |
               +-----+--------+---+
                     |        |
                     v        v
                   +------------+
                   |    ALU     |
                   +-----+------+
                         |
               +---------+---------+
               |                   |
               v                   v
        +-------------+      +-------------+
        | Status Reg. |      | Writeback   |
        |    Z / C    |      | Multiplexer |
        +-------------+      +------+------+
                                   |
                 +-----------------+----------------+
                 |                                  |
                 v                                  v
          +-------------+                    +--------------+
          | Data Memory |                    | Register File|
          +-------------+                    +--------------+
```

More detailed architecture information is available in:

```text
docs/architecture.md
```

---

## Instruction Set

MiniRISC V1 implements 14 instructions.

| Opcode | Instruction | Description |
|---|---|---|
| `0000` | `NOP` | No operation |
| `0001` | `LDI` | Load immediate |
| `0010` | `MOV` | Copy register |
| `0011` | `ADD` | Addition |
| `0100` | `SUB` | Subtraction |
| `0101` | `AND` | Bitwise AND |
| `0110` | `OR` | Bitwise OR |
| `0111` | `XOR` | Bitwise XOR |
| `1000` | `LOAD` | Load from data memory |
| `1001` | `STORE` | Store to data memory |
| `1010` | `JMP` | Unconditional jump |
| `1011` | `JZ` | Jump if Zero flag is set |
| `1100` | `CMP` | Compare two registers |
| `1111` | `HALT` | Stop execution |

Opcodes `1101` and `1110` are reserved for possible future extensions.

Full ISA documentation is available in:

```text
docs/isa.md
```

---

## Example Program

Instead of manually writing binary instructions, MiniRISC programs can be written in assembly.

```asm
LDI R1, 5
LDI R2, 3
ADD R1, R2
STORE R1, 10
HALT
```

The Python assembler converts this into:

```text
0001001000000101
0001010000000011
0011001010000000
1001001000001010
1111000000000000
```

The processor executes the generated machine code and produces:

```text
R1         = 8
R2         = 3
Memory[10] = 8
CPU        = HALTED
```

---

## Python Assembler

The project contains a custom Python assembler:

```text
assembler/assembler.py
```

It converts MiniRISC assembly source into a `.mem` file that can be loaded directly by the Verilog instruction memory.

Example:

```bash
python3 assembler/assembler.py \
    programs/test_program.asm \
    programs/assembled_program.mem
```

The assembler supports:

- Decimal values
- Hexadecimal values
- Binary values
- Inline comments
- Register validation
- Immediate/address range checking
- Operand validation
- Invalid-instruction detection
- `.mem` file generation

For example:

```asm
LDI R1, 0xFF       # Load 255
LDI R2, 0b00000001
ADD R1, R2
HALT
```

---

## Project Structure

```text
MiniRISC/
│
├── assembler/
│   └── assembler.py
│
├── docs/
│   ├── architecture.md
│   ├── isa.md
│   └── verification.md
│
├── programs/
│   ├── test_program.asm
│   ├── assembled_program.mem
│   ├── test_program.mem
│   ├── carry_test.mem
│   ├── halt_reset_test.mem
│   └── waveform_test.mem
│
├── rtl/
│   ├── alu.v
│   ├── control_fsm.v
│   ├── control_unit.v
│   ├── data_memory.v
│   ├── instruction_decoder.v
│   ├── instruction_memory.v
│   ├── instruction_register.v
│   ├── minirisc_cpu.v
│   ├── program_counter.v
│   ├── register_file.v
│   └── status_register.v
│
├── tb/
│   ├── alu_tb.v
│   ├── control_fsm_tb.v
│   ├── control_unit_tb.v
│   ├── data_memory_tb.v
│   ├── instruction_decoder_tb.v
│   ├── instruction_memory_tb.v
│   ├── minirisc_cpu_tb.v
│   ├── minirisc_branch_tb.v
│   ├── minirisc_isa_tb.v
│   ├── minirisc_carry_tb.v
│   ├── minirisc_halt_reset_tb.v
│   ├── minirisc_assembler_tb.v
│   ├── minirisc_waveform_tb.v
│   ├── register_file_tb.v
│   └── status_register_tb.v
│
├── sim/
│
└── README.md
```

---

## RTL Modules

### `minirisc_cpu.v`

Top-level processor module connecting the datapath and control-path components.

### `alu.v`

Performs:

```text
ADD
SUB
AND
OR
XOR
```

and generates Zero and Carry outputs.

### `register_file.v`

Contains eight 8-bit general-purpose registers with:

```text
2 read ports
1 write port
```

### `program_counter.v`

Maintains the current instruction address.

Supports:

```text
increment
enable
direct jump loading
reset
```

### `instruction_memory.v`

Stores 16-bit processor instructions.

Different program files can be supplied using the `MEM_FILE` parameter.

### `instruction_register.v`

Captures the fetched instruction and keeps it stable while it progresses through the remaining processor states.

### `instruction_decoder.v`

Extracts:

```text
opcode
Rd
Rs
immediate/address
```

from the current 16-bit instruction.

### `control_unit.v`

Converts the instruction opcode into processor control requests.

### `control_fsm.v`

Implements the multi-cycle execution sequence:

```text
FETCH
DECODE
EXECUTE
WRITEBACK
HALT
```

### `status_register.v`

Stores:

```text
Z — Zero flag
C — Carry flag
```

### `data_memory.v`

Implements a separate:

```text
256 × 8-bit
```

data memory used by LOAD and STORE.

---

## Verification

MiniRISC was verified at both module and full-processor level.

Major tests include:

| Test | Result |
|---|---|
| ADD | ✅ Passed |
| SUB | ✅ Passed |
| AND | ✅ Passed |
| OR | ✅ Passed |
| XOR | ✅ Passed |
| Register reads/writes | ✅ Passed |
| Program Counter | ✅ Passed |
| Decoder | ✅ Passed |
| Control Unit | ✅ Passed |
| Instruction Memory | ✅ Passed |
| Data Memory | ✅ Passed |
| Status Register | ✅ Passed |
| FSM | ✅ Passed |
| MOV | ✅ Passed |
| LOAD | ✅ Passed |
| STORE | ✅ Passed |
| CMP | ✅ Passed |
| JMP | ✅ Passed |
| JZ taken | ✅ Passed |
| JZ not taken | ✅ Passed |
| NOP | ✅ Passed |
| HALT | ✅ Passed |
| Zero flag | ✅ Passed |
| Carry flag | ✅ Passed |
| `255 + 1` edge case | ✅ Passed |
| HALT stability | ✅ Passed |
| Reset from HALT | ✅ Passed |
| CPU restart after reset | ✅ Passed |
| Python assembler | ✅ Passed |
| Assembler → CPU execution | ✅ Passed |

Detailed verification information is available in:

```text
docs/verification.md
```

---

## Carry Edge Case

One full-CPU test specifically verifies 8-bit overflow behaviour:

```asm
LDI R1, 255
LDI R2, 1
ADD R1, R2
HALT
```

Expected:

```text
255 + 1 = 256

8-bit result = 0

R1 = 0
Z  = 1
C  = 1
```

The test passed at full processor level.

---

## Branch Verification

Conditional branching was tested in both directions.

For equal registers:

```asm
CMP R1, R2
JZ target
```

produces:

```text
Z = 1
```

and the branch is taken.

For unequal registers:

```text
Z = 0
```

and execution continues sequentially.

An unconditional `JMP` was also verified.

---

## Waveform Analysis

VCD waveform files are generated during simulation.

Example:

```text
sim/minirisc_waveform.vcd
```

Waveform analysis confirmed the multi-cycle execution sequence:

```text
FETCH → DECODE → EXECUTE → WRITEBACK
```

For example:

```asm
ADD R1, R2
```

with:

```text
R1 = 5
R2 = 3
```

shows:

```text
Rd value          = 5
Rs value          = 3
ALU operation     = ADD
ALU result        = 8
writeback data    = 8
register write    = enabled
R1                = 8
```

The Program Counter remains unchanged while the instruction passes through the execution states and advances when the instruction completes.

---

## Running MiniRISC

### Requirements

The project was developed using:

```text
Python 3
Icarus Verilog
Surfer
```

Surfer is optional and is only required for waveform inspection.

### Assemble a Program

From the project root:

```bash
python3 assembler/assembler.py
```

Or specify the input and output files:

```bash
python3 assembler/assembler.py \
    programs/test_program.asm \
    programs/assembled_program.mem
```

### Compile the Assembler-to-CPU Test

```bash
iverilog \
    -s minirisc_assembler_tb \
    -o sim/minirisc_assembler_sim \
    rtl/*.v \
    tb/minirisc_assembler_tb.v
```

### Run the Simulation

```bash
vvp sim/minirisc_assembler_sim
```

Expected result:

```text
PASS: R1 = 8
PASS: R2 = 3
PASS: Memory[10] = 8
PASS: CPU halted
```

### View a Waveform

Compile and run the waveform test, then open:

```bash
surfer sim/minirisc_waveform.vcd
```

---

## Design Decisions

MiniRISC deliberately uses a multi-cycle architecture rather than a pipelined implementation.

This keeps the control flow explicit and makes it possible to observe how individual instructions move through the processor.

The project focuses on understanding:

```text
Instruction encoding
Datapath design
Control-path design
Finite State Machines
Register-transfer behaviour
Memory interfaces
ALU design
Processor status flags
Conditional branching
Hardware verification
Assembly-to-machine-code translation
```

The objective of V1 is therefore architectural clarity and correctness rather than maximum performance.

---

## Current Limitations

MiniRISC V1 does not currently include:

```text
Pipelining
Interrupts
Stack operations
CALL / RET
Signed overflow flag
Negative flag
Multiplication
Division
Indirect addressing
Caches
FPGA deployment
```

These features are intentionally outside the scope of the first version.

---

## Possible Future Work

Potential MiniRISC V2 extensions include:

```text
FPGA implementation
Additional status flags
CALL and RET instructions
Stack Pointer
Interrupt support
Additional addressing modes
Expanded instruction set
UART output
Memory-mapped peripherals
Automated regression testing
Synthesis and timing analysis
```

A future version could also investigate pipelining after the multi-cycle architecture has been fully characterized.

---

## What I Learned

This project was developed to move beyond programming an existing microcontroller and instead understand how the processor itself is constructed.

Building MiniRISC involved designing and integrating:

```text
An instruction set architecture
Binary instruction formats
An ALU
A register file
A Program Counter
Instruction and data memories
An instruction decoder
A control unit
A finite-state machine
Status flags
Writeback logic
Conditional program flow
A Python assembler
A structured verification environment
```

The project provided practical experience connecting software-level assembly instructions with the RTL hardware that executes them.

---

## Documentation

Detailed project documentation:

- [`Architecture`](docs/architecture.md)
- [`Instruction Set Architecture`](docs/isa.md)
- [`Verification`](docs/verification.md)

---

## Status

**MiniRISC V1: Functional simulation complete ✅**

The processor executes the complete V1 instruction set, passes directed integration tests, supports assembly-generated programs, and has been inspected using simulation waveforms.

FPGA implementation is considered an optional future extension.