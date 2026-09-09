# MiniRISC V2

### Custom 8-bit Multi-Cycle Processor — RTL Design, Verification, Synthesis and FPGA Implementation Analysis

MiniRISC V2 is a custom **8-bit multi-cycle RISC-style processor** designed
and implemented in Verilog.

The project began as a processor-design exercise and was extended into a
complete RTL engineering workflow covering:

- custom instruction-set architecture design
- processor datapath and control design
- SystemVerilog verification
- self-checking testbenches
- reference-model verification
- scoreboard-based checking
- automated regression testing
- FPGA synthesis
- technology mapping
- place-and-route
- post-route timing analysis
- FPGA resource analysis
- FPGA-ready reset, LED and UART integration

The final processor completed a **20-test automated regression with zero
failures** and was successfully synthesised and placed-and-routed for a
virtual **Lattice iCE40HX8K** FPGA target.

The final implementation achieved an estimated post-route maximum frequency
of **53.39 MHz**, passing the selected **50 MHz timing target**.

> Physical FPGA deployment was not performed. FPGA results are tool-based
> implementation results for the selected target device rather than
> measurements from a physical development board.

---

# Key Results

| Metric | Final Result |
|---|---:|
| Final regression | **20 / 20 PASS** |
| Regression pass rate | **100%** |
| FPGA synthesis | **PASS** |
| Place and route | **PASS** |
| Timing target | **50 MHz** |
| Post-route estimated Fmax | **53.39 MHz** |
| Estimated critical period | **18.73 ns** |
| Estimated timing margin | **+1.27 ns** |
| Logic-cell utilisation | **4631 / 7680 (60%)** |
| Yosys LUT4 count | **2500** |
| Flip-flops | **2182** |
| Carry primitives | **51** |
| Block RAM | **1** |

---

# Project Aim

The aim of MiniRISC V2 was to move beyond simply writing a processor in
Verilog and explore a more complete **digital hardware development flow**.

The project was designed to answer several engineering questions:

- Can a custom processor architecture be designed from individual RTL blocks?
- Can the full instruction set be verified automatically?
- Can expected behaviour be generated through a reference model rather than
  manually checking every waveform?
- Can a repeatable regression detect failures automatically?
- Can the design be synthesised into real FPGA resources?
- Can the resulting design successfully complete FPGA placement and routing?
- What FPGA resources does the processor consume?
- What is its estimated post-route maximum operating frequency?
- Which part of the design becomes timing-critical?

MiniRISC V2 therefore combines **computer architecture, RTL design,
verification and FPGA implementation analysis** in one project.

---

# Processor Architecture

MiniRISC is an educational custom processor with:

- **8-bit datapath**
- **16-bit instructions**
- **8 general-purpose registers**
- **14 implemented instructions**
- **Zero and Carry flags**
- separate instruction and data memories
- multi-cycle execution
- FSM-based control
- custom Python assembler

The processor follows the sequence:

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

A dedicated HALT state stops execution until reset.

---

# Instruction Set

MiniRISC uses a custom ISA rather than implementing an existing architecture.

| Opcode | Instruction | Function |
|---|---|---|
| `0000` | NOP | No operation |
| `0001` | LDI | Load immediate |
| `0010` | MOV | Register move |
| `0011` | ADD | Addition |
| `0100` | SUB | Subtraction |
| `0101` | AND | Bitwise AND |
| `0110` | OR | Bitwise OR |
| `0111` | XOR | Bitwise XOR |
| `1000` | LOAD | Load from data memory |
| `1001` | STORE | Store to data memory |
| `1010` | JMP | Unconditional jump |
| `1011` | JZ | Jump if Zero flag is set |
| `1100` | CMP | Compare |
| `1101` | Reserved | Reserved opcode |
| `1110` | Reserved | Reserved opcode |
| `1111` | HALT | Halt processor |

The ISA therefore covers:

```text
Arithmetic
+
Logic
+
Data movement
+
Memory access
+
Comparison
+
Conditional control flow
+
Unconditional control flow
+
Processor halt
```

---

# High-Level Architecture

```text
                     ┌────────────────────┐
                     │    MiniRISC CPU    │
                     └─────────┬──────────┘
                               │
        ┌──────────────────────┼──────────────────────┐
        │                      │                      │
        ▼                      ▼                      ▼
┌───────────────┐      ┌───────────────┐      ┌───────────────┐
│ Program       │      │ Register File │      │ Control FSM   │
│ Counter       │      │ 8 × 8-bit     │      │               │
└───────────────┘      └───────┬───────┘      └───────┬───────┘
                               │                      │
                               ▼                      │
                       ┌───────────────┐              │
                       │      ALU      │◄─────────────┘
                       └───────┬───────┘
                               │
                         Zero / Carry
                               │
                               ▼
                       ┌───────────────┐
                       │ Status Reg.   │
                       └───────────────┘

        ┌──────────────────────┴──────────────────────┐
        │                                             │
        ▼                                             ▼
Instruction Memory                              Data Memory
```

---

# Multi-Cycle Execution

Unlike a single-cycle processor, MiniRISC distributes instruction execution
across multiple clock cycles.

This allows the processor to reuse hardware resources and provides a clear
educational separation between instruction-processing stages.

Conceptually:

```text
        ┌─────────┐
        │  FETCH  │
        └────┬────┘
             ↓
        ┌─────────┐
        │ DECODE  │
        └────┬────┘
             ↓
        ┌─────────┐
        │ EXECUTE │
        └────┬────┘
             ↓
       ┌───────────┐
       │ WRITEBACK │
       └─────┬─────┘
             │
             └──────────► FETCH
```

Control is generated by a finite-state machine.

---

# ALU and Status Flags

The ALU supports:

```text
ADD
SUB
AND
OR
XOR
```

MiniRISC also maintains:

```text
Zero Flag
Carry Flag
```

An important verified arithmetic edge case is:

```text
255 + 1
```

For an 8-bit processor:

```text
Result = 0
Zero   = 1
Carry  = 1
```

This behaviour is explicitly checked by the regression suite.

---

# Memory Architecture

MiniRISC uses separate instruction and data memories.

```text
               MiniRISC
               /      \
              /        \
             ▼          ▼
     Instruction      Data
       Memory        Memory
```

This is similar to a simplified Harvard-style architecture.

Instruction memory contains program machine code while data memory supports
LOAD and STORE operations.

---

# Python Assembler

MiniRISC includes a Python assembler that converts custom assembly code into
machine-code memory files.

The tool flow is:

```text
Assembly Program
       ↓
Python Assembler
       ↓
16-bit Machine Code
       ↓
Instruction Memory File
       ↓
MiniRISC CPU
```

The assembler is included in processor-level verification so the project
tests the complete path from assembly source to CPU execution.

---

# Verification Strategy

Verification was an important focus of MiniRISC V2.

The project progressed from conventional directed testbenches toward a more
structured verification environment.

```text
Directed Tests
      ↓
Self-Checking Tests
      ↓
Reusable Tasks
      ↓
Driver
      ↓
Monitor
      ↓
Reference Model
      ↓
Scoreboard
      ↓
Regression
```

---

# Reference Model and Scoreboard

The SystemVerilog environment includes an independently implemented reference
model.

Instead of manually entering every expected result:

```text
A + B + operation
        ↓
 Reference Model
        ↓
 Expected Result
```

The expected result is compared automatically against the RTL output.

```text
             DUT
              │
              ▼
        Actual Result
              │
              ▼
          Scoreboard
              ▲
              │
       Expected Result
              ▲
              │
       Reference Model
```

A mismatch causes the verification test to fail.

---

# Final Regression

All primary verification tests can be executed with:

```bash
./scripts/run_regression.sh
```

The final regression contained **20 automated tests**.

| Category | Tests | Passed |
|---|---:|---:|
| Module-level RTL | 9 | 9 |
| CPU / ISA integration | 6 | 6 |
| SystemVerilog verification | 4 | 4 |
| FPGA integration | 1 | 1 |
| **Total** | **20** | **20** |

Final result:

```text
PASS = 20
FAIL = 0

OVERALL RESULT: PASS
MINIRISC V2 REGRESSION PASSED
```

---

# Regression Coverage

The final regression includes:

- ALU
- Register File
- Program Counter
- Control FSM
- Control Unit
- Instruction Decoder
- Data Memory
- Instruction Memory
- Status Register
- Full ISA Integration
- JZ Not Taken
- JZ Taken
- Carry Edge Case
- HALT and Reset
- Assembler Generated Program
- SystemVerilog ALU Self-Checker
- Structured ALU Verification
- ALU Reference Scoreboard
- ALU Regression
- FPGA Wrapper Integration

---

# FPGA Integration

MiniRISC V2 contains a generic FPGA integration layer.

```text
minirisc_ice40_top
        │
        ▼
minirisc_fpga_top
        │
        ├── MiniRISC CPU
        │
        ├── Reset Synchroniser
        │
        ├── LED Debug
        │
        └── UART Debug
```

This separates the processor RTL from FPGA-facing logic.

---

# Reset Synchronisation

The FPGA wrapper contains a two-stage reset synchroniser.

```text
External Reset
      ↓
Reset Synchroniser
      ↓
Internal Reset
      ↓
MiniRISC CPU
```

This prepares asynchronous external reset behaviour for use with synchronous
processor logic.

---

# LED Debug Interface

Eight FPGA-style LED outputs expose processor state:

| LED | Function |
|---|---|
| LED0 | HALT |
| LED1 | Zero flag |
| LED2 | Carry flag |
| LED3–5 | FSM state |
| LED6–7 | `PC[1:0]` |

This provides simple processor observability for possible future hardware
deployment.

---

# UART Debug Interface

MiniRISC V2 also contains a UART transmitter.

When the processor enters HALT, a debug byte can be transmitted.

```text
Bit 7     HALT
Bit 6     Zero
Bit 5     Carry
Bits 4:2  FSM state
Bits 1:0  PC[1:0]
```

Debug-byte layout:

```text
H Z C S S S P P
```

The UART clock frequency and baud rate are parameterised.

---

# FPGA Implementation

A **Lattice iCE40HX8K** was selected as a virtual FPGA implementation target.

```text
Family:  Lattice iCE40
Device:  iCE40HX8K
Package: CT256
Target:  50 MHz
```

The FPGA implementation flow is:

```text
Verilog RTL
     ↓
Yosys
     ↓
iCE40 Technology Mapping
     ↓
JSON Netlist
     ↓
nextpnr-ice40
     ↓
Packing
     ↓
Placement
     ↓
Routing
     ↓
Post-Route Timing
     ↓
Resource Analysis
```

---

# Automated Implementation

The complete FPGA implementation can be rerun with:

```bash
./scripts/run_implementation.sh
```

The final implementation completed:

```text
YOSYS SYNTHESIS: PASS
JSON NETLIST: PASS
PLACE AND ROUTE: PASS
ASC IMPLEMENTATION: PASS

OVERALL RESULT: PASS
MINIRISC V2 FPGA IMPLEMENTATION PASSED
```

---

# Synthesis Results

Final Yosys technology mapping:

| Resource | Count |
|---|---:|
| `SB_LUT4` | **2500** |
| Flip-flops | **2182** |
| `SB_CARRY` | **51** |
| `SB_RAM40_4K` | **1** |

The mapped flip-flop total includes the different iCE40 DFF primitive
variants generated by synthesis.

---

# FPGA Resource Utilisation

Final post-route utilisation for the iCE40HX8K target:

| Resource | Used | Available | Utilisation |
|---|---:|---:|---:|
| Logic cells | **4631** | **7680** | **60%** |
| Block RAM | **1** | **32** | **3%** |
| I/O | **11** | **206** | **5%** |
| Global buffers | **2** | **8** | **25%** |
| PLLs | **0** | **2** | **0%** |

The implementation therefore occupies approximately:

```text
60% of the available HX8K logic cells
```

---

# Post-Route Timing

The implementation target was:

```text
50 MHz
```

Corresponding clock period:

```text
20.00 ns
```

The final nextpnr result was:

```text
Estimated Fmax = 53.39 MHz
PASS at 50.00 MHz
```

This corresponds to an estimated critical period of:

```text
1000 / 53.39
≈ 18.73 ns
```

and an estimated timing margin of:

```text
20.00 - 18.73
≈ +1.27 ns
```

Final timing result:

```text
50 MHz TARGET: PASS
```

---

# Critical Path Analysis

The post-route timing report identified a critical synchronous path involving
instruction-memory read logic followed by multiple LUT and routing stages
toward processor status/carry-related logic.

This provides a useful optimisation target for future versions.

Potential future timing work could investigate:

- memory architecture
- combinational logic depth
- decoding structure
- datapath multiplexing
- signal fan-out
- additional pipeline boundaries

---

# Repository Structure

```text
MiniRISC/
│
├── rtl/
│   └── Processor RTL modules
│
├── tb/
│   └── Module and CPU testbenches
│
├── verification/
│   ├── tests/
│   └── verification_summary.md
│
├── assembler/
│   └── Python assembler
│
├── programs/
│   └── MiniRISC machine-code programs
│
├── fpga/
│   ├── rtl/
│   │   ├── minirisc_fpga_top.v
│   │   ├── minirisc_ice40_top.v
│   │   ├── reset_sync.v
│   │   └── uart_tx.v
│   │
│   ├── tb/
│   │   └── FPGA integration verification
│   │
│   ├── constraints/
│   │   └── Generic constraint templates
│   │
│   ├── build/
│   │   └── Generated implementation files
│   │
│   └── reports/
│       └── Implementation and timing reports
│
├── scripts/
│   ├── run_regression.sh
│   └── run_implementation.sh
│
├── docs/
│   └── Technical documentation
│
└── README.md
```

---

# Running the Verification

Requirements include:

```text
Icarus Verilog
Python 3
```

Run the complete regression:

```bash
./scripts/run_regression.sh
```

Expected final result:

```text
PASS = 20
FAIL = 0
OVERALL RESULT: PASS
```

---

# Running the FPGA Implementation

The current FPGA implementation flow uses:

```text
Yosys
nextpnr-ice40
```

Run:

```bash
./scripts/run_implementation.sh
```

The script performs:

```text
Synthesis
    ↓
Netlist generation
    ↓
Place and route
    ↓
Timing extraction
    ↓
Resource extraction
```

---

# V1 → V2 Development

MiniRISC V1 established the processor architecture:

```text
Custom ISA
+
Datapath
+
FSM
+
Assembler
+
Directed simulation
```

MiniRISC V2 extended this into:

```text
MiniRISC V1
      ↓
SystemVerilog Verification
      ↓
Self-Checking Tests
      ↓
Driver / Monitor
      ↓
Reference Model
      ↓
Scoreboard
      ↓
Regression
      ↓
Synthesis
      ↓
Timing Analysis
      ↓
Optimisation / Implementation Analysis
      ↓
FPGA Integration
      ↓
Place and Route
```

The main objective of V2 was therefore not simply to add processor
instructions, but to develop the architecture using a more complete
professional RTL engineering workflow.

---

# Engineering Skills Demonstrated

This project demonstrates experience with:

### Digital Design

- processor architecture
- RTL design
- finite-state machines
- datapath design
- control logic
- register files
- ALUs
- memory interfaces
- branch control

### Hardware Description Languages

- Verilog
- SystemVerilog
- synchronous RTL
- combinational RTL
- parameterised modules

### Verification

- directed testing
- self-checking testbenches
- reusable tasks
- driver/monitor architecture
- behavioural reference models
- scoreboards
- regression testing
- edge-case verification
- CPU integration verification

### FPGA Engineering

- Yosys synthesis
- technology mapping
- nextpnr
- packing
- placement
- routing
- LUT utilisation
- flip-flop utilisation
- block-RAM inference
- carry chains

### Timing Analysis

- clock-frequency targets
- clock periods
- critical paths
- post-route Fmax
- timing margins
- timing closure concepts

### Engineering Workflow

- Python tooling
- Bash automation
- Git
- repeatable regression
- reproducible implementation
- technical documentation
- quantitative validation

---

# Project Scope and Limitations

MiniRISC V2 was not deployed onto a physical FPGA development board.

Therefore the project does **not** claim:

- physical FPGA programming
- measured hardware Fmax
- physical LED validation
- physical UART validation
- oscilloscope measurements from an FPGA
- board-level electrical validation
- production-grade verification
- ASIC implementation

The FPGA implementation results are generated by synthesis and
place-and-route tools for the selected iCE40HX8K target.

---

# Future Work

Possible future extensions include:

- physical FPGA deployment
- interrupts
- stack support
- memory-mapped peripherals
- additional ISA instructions
- larger memory
- pipelining
- improved branch handling
- full CPU architectural reference model
- constrained-random instruction generation
- functional coverage
- formal verification
- continuous integration
- timing optimisation
- power analysis

---

# Final Results

```text
MINIRISC V2

Architecture
------------
8-bit datapath
16-bit custom ISA
8 general-purpose registers
14 implemented instructions
Multi-cycle FSM architecture
Separate instruction/data memory

Verification
------------
20 tests
20 PASS
0 FAIL
100% final regression pass rate

Synthesis
---------
2500 LUT4
2182 flip-flops
51 carry primitives
1 block RAM

FPGA Implementation
-------------------
Target: iCE40HX8K
Logic cells: 4631 / 7680
Utilisation: 60%

Timing
------
Target: 50.00 MHz
Post-route Fmax: 53.39 MHz
Estimated critical period: 18.73 ns
Estimated margin: +1.27 ns
Result: PASS
```

---

# Conclusion

MiniRISC V2 demonstrates the development of a custom processor through a
complete educational RTL engineering flow:

```text
Architecture
     ↓
Custom ISA
     ↓
Verilog RTL
     ↓
Functional Verification
     ↓
SystemVerilog Verification
     ↓
Reference Model
     ↓
Scoreboard
     ↓
Automated Regression
     ↓
Synthesis
     ↓
FPGA Technology Mapping
     ↓
Place and Route
     ↓
Post-Route Timing
     ↓
Resource Analysis
     ↓
FPGA-Ready Integration
```

The final design passed all **20 automated regression tests**, successfully
completed FPGA synthesis and place-and-route, and met the selected **50 MHz**
timing target with a final estimated post-route Fmax of **53.39 MHz**.

MiniRISC V2 therefore represents a progression from basic processor RTL
design toward a broader digital-design, verification and FPGA implementation
workflow.