# MiniRISC V2 Timing Analysis and Optimisation Targets

## 1. Timing Objective

MiniRISC V2 currently uses a preliminary target clock of:

- Frequency: 50 MHz
- Period: 20 ns

This target is preliminary and is not a measured maximum operating
frequency.

Final timing will require FPGA-specific synthesis, placement and routing.

---

## 2. Current Analysis Method

The current timing investigation uses Yosys longest-topological-path
analysis.

This identifies structurally deep combinational paths but does not
provide physical propagation delay in nanoseconds.

Therefore:

- structural path depth can be reported
- likely timing-critical regions can be identified
- final setup slack cannot yet be reported
- final hold slack cannot yet be reported
- final Fmax cannot yet be reported

---

## 3. Architectural Timing Boundaries

MiniRISC is a multi-cycle processor using:

FETCH -> DECODE -> EXECUTE -> WRITEBACK

Major sequential state elements include:

- Program Counter
- Instruction Register
- Register File
- Control FSM state
- Zero and Carry status registers
- Data Memory

The multi-cycle architecture prevents instruction fetch, decode,
execution and writeback from forming one single-cycle combinational path.

---

## 4. Candidate Timing Paths

Important candidate register-to-register paths include:

### Datapath

Register File
-> ALU
-> Writeback selection
-> Register File

### Flag Path

Register File
-> ALU
-> Zero/Carry logic
-> Status Register

### Program Counter Path

Program Counter
-> Increment / branch selection
-> Program Counter

### Decode / Control Path

Instruction Register
-> Instruction Decoder
-> Control Unit
-> control signals

### Memory Paths

Register File / address logic
-> Data Memory

and

Data Memory
-> Writeback selection
-> Register File

---

## 5. Structural Critical Path

Yosys `ltp` is used after synthesis and flattening to identify the
longest topological path.

The exact critical-path region should be taken from:

timing/reports/critical_path_structural.log

The structural path must not be interpreted directly as a delay in
nanoseconds.

---

## 6. Memory Considerations

Generic synthesis maps the 256 x 8 data memory into large numbers of
generic storage and logic cells.

Earlier synthesis stages correctly infer:

- Instruction memory as `$mem_v2`
- Data memory as `$mem_v2`

The generic memory implementation is therefore not considered a
reliable representation of final FPGA memory resources or timing.

Memory optimisation should be based on FPGA-specific mapping rather
than generic gate counts.

---

## 7. Optimisation Priorities

### Priority 1 - Preserve Correctness

Any optimisation must continue to pass the complete RTL regression.

No architectural behaviour, ISA behaviour or flag behaviour should be
changed solely for timing improvement.

### Priority 2 - Critical Combinational Logic

Investigate the region reported by Yosys longest-topological-path
analysis.

Potential targets include:

- ALU logic depth
- writeback selection logic
- branch / next-PC logic
- register-file read selection

Only optimise a block when synthesis/timing evidence supports doing so.

### Priority 3 - Memory Mapping

Avoid interpreting generic data-memory flip-flop implementation as the
final FPGA architecture.

Investigate distributed RAM / block RAM mapping during FPGA-specific
synthesis.

### Priority 4 - Control Logic

The Control Unit and FSM are relatively small compared with the
datapath and generic memory implementation.

They should not be rewritten unless timing analysis identifies them as
a genuine bottleneck.

---

## 8. Blocks That Should Not Be Randomly Optimised

The following should remain unchanged unless evidence shows a problem:

- ISA
- 8 general-purpose registers
- Zero and Carry semantics
- 16-bit instruction width
- 8-bit datapath
- FETCH -> DECODE -> EXECUTE -> WRITEBACK architecture
- HALT behaviour

---

## 9. Day 12 Methodology

Day 12 optimisation should follow:

Baseline
-> identify measured bottleneck
-> make one controlled RTL change
-> run full regression
-> re-synthesize
-> re-run structural timing analysis
-> compare before and after

Changes should be evaluated using both correctness and implementation
results.

---

## 10. Current Timing Status

| Metric | Current Status |
|---|---|
| Preliminary target | 50 MHz |
| Preliminary period | 20 ns |
| Structural path analysis | Completed / recorded |
| Device-specific setup slack | Pending |
| Device-specific hold slack | Pending |
| Routing delay | Pending |
| Final Fmax | Pending |
| FPGA resource timing | Pending |