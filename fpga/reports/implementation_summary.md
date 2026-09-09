# MiniRISC V2 FPGA Implementation Summary

## 1. Overview

MiniRISC V2 is a custom 8-bit multi-cycle RISC-style processor designed in
Verilog and extended with structured SystemVerilog verification, automated
regression testing, synthesis, place-and-route, timing analysis and
FPGA-ready integration.

The processor was evaluated using a virtual FPGA implementation target based
on the Lattice iCE40 architecture.

No physical FPGA development board was used.

The implementation flow was used to evaluate:

- synthesis success
- FPGA technology mapping
- place-and-route feasibility
- FPGA resource utilisation
- post-route timing
- estimated maximum operating frequency
- FPGA integration logic
- repeatable verification and implementation workflows

Physical FPGA programming and hardware validation remain optional future work.

---

## 2. Processor Architecture

MiniRISC V2 is based on the MiniRISC V1 processor architecture.

Main architectural characteristics:

- 8-bit datapath
- 16-bit custom instruction format
- 8 general-purpose registers
- custom RISC-style instruction set
- separate instruction and data memories
- Zero and Carry status flags
- multi-cycle processor architecture
- FSM-controlled execution

The processor uses the following main execution sequence:

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

The HALT instruction moves the processor into a dedicated halt state.

---

## 3. FPGA Implementation Target

The selected implementation target was:

- FPGA family: **Lattice iCE40**
- FPGA device: **iCE40HX8K**
- Package: **CT256**
- Physical FPGA board: **Not used**
- Target clock frequency: **50 MHz**
- Target clock period: **20.00 ns**

The device was selected as a virtual implementation target for synthesis,
place-and-route, timing analysis and resource-utilisation evaluation.

The implementation results therefore represent FPGA tool estimates and not
measurements from physical hardware.

---

## 4. Toolchain

The MiniRISC V2 workflow used:

- Icarus Verilog
- Verilog
- SystemVerilog
- Python
- Yosys
- nextpnr-ice40
- Project IceStorm tools
- Git

The FPGA implementation flow was:

```text
MiniRISC RTL
      ↓
Yosys synthesis
      ↓
iCE40 technology mapping
      ↓
JSON netlist
      ↓
nextpnr-ice40
      ↓
Packing
      ↓
Placement
      ↓
Routing
      ↓
Post-route timing analysis
      ↓
Resource-utilisation analysis
```

---

## 5. FPGA Architecture

The FPGA implementation hierarchy is:

```text
minirisc_ice40_top
        │
        ▼
minirisc_fpga_top
        │
        ├── reset_sync
        │
        ├── minirisc_cpu
        │
        ├── LED debug mapping
        │
        └── uart_tx
```

The processor RTL is kept separate from FPGA-specific integration logic.

This allows the MiniRISC CPU architecture to remain reusable independently
from a particular FPGA development board.

---

## 6. FPGA Top-Level Interface

The implementation top-level module is:

```text
minirisc_ice40_top
```

The external FPGA-style ports are:

```text
clk
reset
led[7:0]
uart_tx_pin
```

The design therefore uses:

- 1 clock input
- 1 reset input
- 8 LED outputs
- 1 UART TX output

Total top-level FPGA I/O:

```text
11 signals
```

Internal processor debug signals remain available within the hierarchy but
are not exposed as additional physical FPGA pins.

---

## 7. Reset Architecture

A physical external reset signal can change asynchronously relative to the
FPGA clock.

MiniRISC V2 therefore includes a reset synchronisation stage:

```text
External reset
      ↓
reset_sync
      ↓
Internal reset
      ↓
MiniRISC CPU
```

The reset synchroniser provides immediate reset assertion and synchronised
reset release.

This prepares the processor for future deployment with a physical external
reset source.

---

## 8. LED Debug Interface

The FPGA integration wrapper provides an 8-bit LED debug interface.

The mapping is:

| LED | Processor Signal |
|---|---|
| LED0 | HALT |
| LED1 | Zero flag |
| LED2 | Carry flag |
| LED3 | FSM state bit 0 |
| LED4 | FSM state bit 1 |
| LED5 | FSM state bit 2 |
| LED6 | Program Counter bit 0 |
| LED7 | Program Counter bit 1 |

The LED interface provides simple processor-state observability for possible
future physical FPGA deployment.

---

## 9. UART Debug Interface

MiniRISC V2 includes a UART transmitter for processor-state debugging.

A debug byte is transmitted when the CPU enters the HALT state.

The UART debug byte format is:

```text
Bit 7     = HALT
Bit 6     = Zero flag
Bit 5     = Carry flag
Bits 4:2  = FSM state
Bits 1:0  = PC[1:0]
```

Equivalent layout:

```text
7 6 5 4 3 2 1 0
H Z C S S S P P
```

The UART clock divisor is parameterised, allowing the design to be adapted
later to a selected physical FPGA board clock frequency.

---

## 10. Functional Verification

MiniRISC V2 includes module-level, processor-level, SystemVerilog and
FPGA-integration verification.

The final automated regression contained:

```text
20 tests
```

Final result:

```text
PASS = 20
FAIL = 0

OVERALL RESULT: PASS
MINIRISC V2 REGRESSION PASSED
```

The final regression therefore achieved:

```text
20 / 20 tests passed
100% regression pass rate
```

---

## 11. Final Regression Tests

The final regression included:

1. ALU
2. Register File
3. Program Counter
4. Control FSM
5. Control Unit
6. Instruction Decoder
7. Data Memory
8. Instruction Memory
9. Status Register
10. Full ISA Integration
11. Branch — JZ Not Taken
12. Branch — JZ Taken
13. Carry Edge Case
14. HALT and Reset
15. Assembler Generated Program
16. SystemVerilog ALU Self-Checker
17. Structured ALU Verification
18. ALU Reference Scoreboard
19. ALU Regression
20. FPGA Wrapper Integration

All twenty tests passed during the final regression.

---

## 12. Verification Architecture

The MiniRISC V2 verification environment evolved beyond simple waveform
inspection.

The structured verification architecture includes:

```text
Test stimulus
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

The reference model automatically calculates expected ALU behaviour.

The scoreboard compares the real RTL outputs against the independently
calculated expected outputs.

This reduces dependence on manually entered expected values.

---

## 13. Verification Features

Verification performed during MiniRISC V2 included:

- directed verification
- module-level testbenches
- processor-level integration testing
- self-checking SystemVerilog testbenches
- reusable verification tasks
- driver and monitor separation
- automatic PASS/FAIL checking
- reference modelling
- scoreboard-based verification
- edge-case testing
- branch taken testing
- branch not-taken testing
- Carry flag testing
- Zero flag testing
- HALT behaviour testing
- reset testing
- processor restart testing
- assembler-to-CPU integration
- larger ALU regression
- FPGA-wrapper integration verification
- automated final regression execution

---

## 14. Regression Automation

The complete functional regression can be executed with:

```bash
./scripts/run_regression.sh
```

The script:

1. compiles each selected testbench
2. executes the simulation
3. detects compilation failures
4. detects simulation failures
5. checks textual PASS/FAIL results
6. records the final regression result
7. returns a non-zero shell exit code if the regression fails

This creates a repeatable verification workflow suitable for future CI
integration.

---

## 15. Yosys Synthesis

The complete FPGA-ready MiniRISC design was synthesised using Yosys.

The synthesis top-level module was:

```text
minirisc_ice40_top
```

The synthesis process successfully:

- elaborated the complete hierarchy
- mapped RTL logic
- mapped arithmetic operations
- inferred FPGA registers
- mapped memory
- mapped carry-chain resources
- generated an iCE40 technology-specific implementation netlist

Final synthesis status:

```text
YOSYS SYNTHESIS: PASS
```

Generated synthesis netlist:

```text
fpga/build/minirisc_ice40.json
```

Synthesis report:

```text
fpga/reports/yosys_synthesis.log
```

---

## 16. Final Yosys Resource Results

The final Yosys technology-mapped design contained:

| Resource | Used |
|---|---:|
| SB_LUT4 | **2500** |
| Flip-flops | **2182** |
| SB_CARRY | **51** |
| SB_RAM40_4K | **1** |

The mapped flip-flops were:

| Flip-Flop Primitive | Count |
|---|---:|
| SB_DFF | 10 |
| SB_DFFE | 2048 |
| SB_DFFESR | 83 |
| SB_DFFESS | 1 |
| SB_DFFS | 2 |
| SB_DFFSR | 38 |
| **Total** | **2182** |

The synthesis results show that MiniRISC uses dedicated FPGA resources for
both sequential logic and arithmetic carry propagation.

---

## 17. Memory Mapping

The final Yosys result included:

```text
SB_RAM40_4K = 1
```

This demonstrates that part of the MiniRISC memory architecture was
successfully mapped into an iCE40 block-RAM primitive.

The remaining memory/resource implementation depends on synthesis inference,
memory style and FPGA architecture.

---

## 18. Carry-Chain Mapping

The final technology-mapped design contained:

```text
51 SB_CARRY primitives
```

The dedicated iCE40 carry-chain resources support arithmetic implementation
and allow the FPGA architecture to perform carry propagation more efficiently
than implementing all arithmetic purely through general LUT logic.

---

## 19. Place and Route

The Yosys JSON netlist was passed into:

```text
nextpnr-ice40
```

using the target:

```text
Device:  iCE40HX8K
Package: CT256
```

The implementation successfully completed:

```text
Packing      PASS
Placement    PASS
Routing      PASS
Timing       PASS
```

Generated routed design:

```text
fpga/build/minirisc_ice40.asc
```

Place-and-route report:

```text
fpga/reports/nextpnr_place_route.log
```

---

## 20. Final Place-and-Route Result

The automated implementation script reported:

```text
Synthesis:       PASS
Technology map:  PASS
Place & Route:   PASS
Output netlist:  PASS

OVERALL RESULT: PASS
MINIRISC V2 FPGA IMPLEMENTATION PASSED
```

This demonstrates that the complete MiniRISC FPGA-ready design was
successfully synthesised and physically placed and routed within the selected
virtual iCE40HX8K FPGA architecture.

---

## 21. Post-Route Resource Utilisation

Final nextpnr device utilisation:

| FPGA Resource | Used | Available | Utilisation |
|---|---:|---:|---:|
| Logic cells | **4631** | **7680** | **60%** |
| Block RAM | **1** | **32** | **3%** |
| I/O | **11** | **206** | **5%** |
| Global buffers | **2** | **8** | **25%** |
| PLLs | **0** | **2** | **0%** |

The design therefore occupies approximately:

```text
60% of the available iCE40HX8K logic cells
```

for the selected implementation.

---

## 22. Logic-Cell Packing

nextpnr reported the following logic-cell packing:

| Logic Cell Use | Count |
|---|---:|
| LUT4 only | **2442** |
| LUT4 + DFF | **58** |
| DFF only | **2124** |
| Carry only | **3** |

Additionally:

```text
2 logic cells
```

were used to legalise carry chains during implementation.

This resulted in a final device utilisation of:

```text
4631 / 7680 logic cells
```

or:

```text
60%
```

---

## 23. Timing Target

The selected virtual implementation timing target was:

```text
Frequency = 50 MHz
```

The corresponding target period was:

```text
T = 1 / f
```

Therefore:

```text
T = 1 / 50 MHz
  = 20.00 ns
```

MiniRISC therefore needed a post-route critical timing period below
20.00 ns to meet the selected target.

---

## 24. Post-Route Timing Results

The final nextpnr post-route result was:

```text
Max frequency = 53.39 MHz
PASS at 50.00 MHz
```

Final timing metrics:

| Timing Metric | Result |
|---|---:|
| Target frequency | **50.00 MHz** |
| Target clock period | **20.00 ns** |
| Final estimated Fmax | **53.39 MHz** |
| Estimated critical period | **18.73 ns** |
| Estimated timing margin | **+1.27 ns** |
| Timing target | **PASS** |

The selected 50 MHz timing target was therefore successfully achieved.

---

## 25. Critical-Period Calculation

The critical period was estimated from the final post-route Fmax:

```text
Critical period (ns)
=
1000 / Fmax(MHz)
```

Therefore:

```text
Critical period
=
1000 / 53.39
≈
18.73 ns
```

---

## 26. Timing Margin

The timing margin relative to the 50 MHz target was estimated as:

```text
Timing margin
=
Target period - Critical period
```

Therefore:

```text
Timing margin
=
20.00 ns - 18.73 ns
=
+1.27 ns
```

Since the margin is positive:

```text
+1.27 ns > 0
```

the selected timing target passes.

---

## 27. Timing Interpretation

The final post-route Fmax of:

```text
53.39 MHz
```

is only moderately above the selected:

```text
50 MHz
```

target.

This means the design meets timing, but the implementation does not have a
very large timing margin.

That makes the critical path and future timing optimisation meaningful areas
for further investigation.

---

## 28. Critical Path

The nextpnr timing report identified a synchronous critical path beginning
from instruction-memory read logic and propagating through multiple LUT and
routing stages toward processor status/carry-related logic.

The path therefore involves logic associated with the processor's instruction
and control/datapath behaviour rather than the UART output interface alone.

This provides a useful optimisation target for a future MiniRISC version.

Possible future timing-improvement approaches could include:

- reducing combinational logic depth
- restructuring instruction-memory access
- simplifying decode logic
- improving datapath multiplexing
- introducing additional pipeline boundaries
- changing memory implementation style
- reducing fan-out on critical control signals

These are future optimisation possibilities and were not required for the
current MiniRISC V2 completion target.

---

## 29. Physical I/O Constraints

No physical FPGA board was used.

Therefore physical FPGA pin assignments were intentionally not defined.

The project does not assign:

- physical clock pin
- reset-button pin
- LED package pins
- UART package pin
- board-specific voltage standards

nextpnr was therefore used with unconstrained top-level I/O for implementation
analysis.

The implementation is intended to evaluate FPGA feasibility and timing rather
than claim physical board deployment.

---

## 30. FPGA Implementation Automation

The complete FPGA implementation can be executed using:

```bash
./scripts/run_implementation.sh
```

The script performs:

```text
Yosys synthesis
      ↓
JSON netlist check
      ↓
nextpnr place-and-route
      ↓
ASC output check
      ↓
timing result extraction
      ↓
resource result extraction
      ↓
final PASS / FAIL
```

The final implementation run completed successfully.

---

## 31. Complete MiniRISC V2 Workflow

The project now provides two high-level validation commands.

Functional regression:

```bash
./scripts/run_regression.sh
```

FPGA implementation:

```bash
./scripts/run_implementation.sh
```

Overall project workflow:

```text
MiniRISC RTL
      ↓
Functional verification
      ↓
20/20 regression tests PASS
      ↓
Yosys synthesis
      ↓
Technology mapping
      ↓
nextpnr place-and-route
      ↓
Post-route timing
      ↓
Resource analysis
      ↓
FPGA-ready implementation PASS
```

---

## 32. Final Quantitative Results

### Verification

```text
Regression tests: 20
Passed:           20
Failed:           0
Pass rate:        100%
```

### Timing

```text
Target frequency:          50.00 MHz
Final estimated Fmax:      53.39 MHz
Target period:             20.00 ns
Estimated critical period: 18.73 ns
Estimated timing margin:   +1.27 ns
Timing result:             PASS
```

### Yosys Resources

```text
SB_LUT4:       2500
Flip-flops:    2182
SB_CARRY:      51
SB_RAM40_4K:   1
```

### Post-Route Device Utilisation

```text
Logic cells:     4631 / 7680  = 60%
Block RAM:          1 / 32    = 3%
I/O:               11 / 206   = 5%
Global buffers:     2 / 8     = 25%
PLLs:               0 / 2     = 0%
```

---

## 33. Generated Implementation Evidence

Important generated implementation files:

```text
fpga/build/minirisc_ice40.json
fpga/build/minirisc_ice40.asc
```

Primary reports:

```text
fpga/reports/yosys_synthesis.log
fpga/reports/nextpnr_place_route.log
fpga/reports/implementation_summary.md
```

Automation scripts:

```text
scripts/run_regression.sh
scripts/run_implementation.sh
```

Together these provide repeatable evidence for:

- functional verification
- synthesis
- FPGA technology mapping
- place-and-route
- resource utilisation
- post-route timing analysis

---

## 34. Physical Hardware Validation

No physical FPGA board was used.

Therefore MiniRISC V2 does not claim:

- FPGA board programming
- real LED validation
- physical UART validation
- oscilloscope measurements of FPGA signals
- measured hardware Fmax
- electrical signal validation
- board-specific power analysis

These remain optional future extensions.

---

## 35. FPGA Readiness

Although no physical FPGA board was used, the MiniRISC V2 architecture
contains the primary integration components required for future FPGA
deployment:

```text
Board clock
     ↓
FPGA top
     ↓
Reset synchroniser
     ↓
MiniRISC CPU
     ↓
┌──────────────┬──────────────┐
│              │              │
LED debug     UART          Internal debug
```

A future physical-board implementation would primarily require:

1. selecting an FPGA development board
2. entering the real board clock frequency
3. adding board-specific physical pin constraints
4. adding the correct I/O voltage standards
5. generating a board-specific bitstream
6. programming the FPGA
7. validating LED behaviour
8. validating UART transmission
9. comparing physical behaviour against simulation

The fundamental MiniRISC processor architecture would not need to be
redesigned.

---

## 36. What MiniRISC V2 Demonstrates

MiniRISC V2 demonstrates practical experience with:

### Processor Architecture

- custom instruction-set architecture
- datapath design
- multi-cycle execution
- register files
- program counter control
- arithmetic and logic operations
- status flags
- memory interfaces
- branch control
- FSM-based control

### RTL Design

- Verilog
- combinational logic
- sequential logic
- non-blocking assignments
- FSM design
- RTL hierarchy
- parameterised modules

### Verification

- SystemVerilog
- self-checking testbenches
- reusable tasks
- functions
- driver/monitor separation
- reference models
- scoreboards
- edge-case testing
- processor-level regression
- automated verification scripts

### FPGA Implementation

- Yosys synthesis
- iCE40 technology mapping
- nextpnr
- FPGA packing
- placement
- routing
- LUT mapping
- flip-flop mapping
- block-RAM inference
- dedicated carry chains
- resource-utilisation analysis

### Timing

- target clock frequency
- clock period
- critical paths
- estimated Fmax
- timing margin
- post-route timing analysis
- timing closure concepts

### FPGA Integration

- reset synchronisation
- LED debug outputs
- UART debug output
- implementation wrappers
- board-independent FPGA architecture

### Engineering Workflow

- Git
- automated regression
- reproducible implementation scripts
- implementation reports
- quantitative engineering validation

---

## 37. Final Implementation Status

| Stage | Result |
|---|---|
| CPU RTL design | **PASS** |
| Module simulation | **PASS** |
| Processor integration | **PASS** |
| ISA verification | **PASS** |
| Branch verification | **PASS** |
| Carry edge-case verification | **PASS** |
| HALT/reset verification | **PASS** |
| Assembler integration | **PASS** |
| SystemVerilog verification | **PASS** |
| Reference model | **PASS** |
| Scoreboard | **PASS** |
| Automated regression | **20/20 PASS** |
| FPGA wrapper simulation | **PASS** |
| Yosys synthesis | **PASS** |
| iCE40 technology mapping | **PASS** |
| nextpnr packing | **PASS** |
| nextpnr placement | **PASS** |
| nextpnr routing | **PASS** |
| 50 MHz timing target | **PASS** |
| Resource analysis | **PASS** |
| FPGA implementation automation | **PASS** |
| Physical FPGA deployment | **Not performed** |

---

## 38. Final Project Scope

MiniRISC V2 is a:

**verified, synthesised, timing-analysed and FPGA-ready custom processor.**

The complete engineering flow demonstrated by the project is:

```text
CPU Architecture
      ↓
Custom ISA
      ↓
Verilog RTL
      ↓
Module Verification
      ↓
Processor Verification
      ↓
SystemVerilog Verification
      ↓
Driver / Monitor
      ↓
Reference Model
      ↓
Scoreboard
      ↓
Automated Regression
      ↓
Yosys Synthesis
      ↓
FPGA Technology Mapping
      ↓
Place and Route
      ↓
Resource Analysis
      ↓
Post-Route Timing Analysis
      ↓
FPGA Integration
```

Final quantitative implementation results:

```text
Verification:
20 / 20 tests passed

FPGA implementation:
PASS

Target frequency:
50 MHz

Final estimated post-route Fmax:
53.39 MHz

Timing margin:
+1.27 ns

Logic-cell utilisation:
4631 / 7680 = 60%

Yosys LUT4 count:
2500

Flip-flops:
2182

Carry primitives:
51

Block RAM:
1
```

Physical FPGA deployment remains optional future work and is intentionally
outside the completed MiniRISC V2 project scope.