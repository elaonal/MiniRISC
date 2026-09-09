# MiniRISC V1 / V2

Custom 8-bit multi-cycle processor exploring the path from digital architecture and RTL design to functional verification and FPGA implementation analysis. Designed by Ela Onal using Verilog, SystemVerilog and a Python assembler.

## Start with the V2 evidence

**V2 verification, synthesis and place-and-route are complete. No physical FPGA board was used.** The implementation and reports are on [v2-development](https://github.com/elaonal/MiniRISC/tree/v2-development); main retains the V1 source.

| Result | Evidence |
| --- | --- |
| 20/20 selected regression tests passed; 0 failed | [Verification summary](https://github.com/elaonal/MiniRISC/blob/v2-development/verification/verification_summary.md) |
| Yosys synthesis and nextpnr placement/routing completed for iCE40HX8K CT256 | [Implementation summary](https://github.com/elaonal/MiniRISC/blob/v2-development/fpga/reports/implementation_summary.md) |
| 4,631/7,680 logic cells; 1/32 block RAMs | [nextpnr report](https://github.com/elaonal/MiniRISC/blob/v2-development/fpga/reports/nextpnr_place_route.log) |
| Final nextpnr estimated maximum clock frequency 53.39 MHz; PASS at 50 MHz | [Timing and routing evidence](https://github.com/elaonal/MiniRISC/blob/v2-development/fpga/reports/nextpnr_place_route.log) |
| Technology-mapped resource breakdown | [Yosys synthesis log](https://github.com/elaonal/MiniRISC/blob/v2-development/fpga/reports/yosys_synthesis.log) |

Timing and utilisation are tool results for this implementation, not hardware measurements. The run used automatic I/O placement without a board-specific PCF. Physical pin constraints, programming and board-level validation remain future work. Functional regression and implementation timing are separate checks; neither constitutes exhaustive verification.

## Architecture and engineering work

- 8-bit datapath, 16-bit instruction format and eight general-purpose registers.
- ALU, separate instruction/data memories, Zero/Carry flags and FSM-controlled execution.
- Python assembler and directed CPU tests covering ISA execution, branching, carry edge cases, HALT/reset and assembler integration.
- V2 adds structured SystemVerilog ALU checking, reference-model/scoreboard comparison, automated regression, and a simulated FPGA wrapper with reset, LED and UART debug interfaces.

The 20-test suite comprises nine module tests, six CPU/ISA integration tests, four SystemVerilog tests and one FPGA-wrapper integration test. See the linked summary for scope and limitations.

## Reproduce the V2 flow

Use the v2-development branch and install the tools required by the scripts: Icarus Verilog, Python, Yosys, nextpnr-ice40 and Project IceStorm. From the repository root:

```bash
git switch v2-development
bash scripts/run_regression.sh
bash scripts/run_implementation.sh
```

Inspect the [regression script](https://github.com/elaonal/MiniRISC/blob/v2-development/scripts/run_regression.sh) and [implementation script](https://github.com/elaonal/MiniRISC/blob/v2-development/scripts/run_implementation.sh) for commands and generated outputs. Results above describe the committed reports; they are not a new run on your machine.

## V1 documentation and version scope

[Architecture](docs/architecture.md), [V1 project notes](docs/read.md) and [V1 verification](docs/verification.md) document the original simulation-focused release. Their statements about synthesis/timing being future work apply to V1 only; the linked V2 reports supersede that project-wide status. V1 source and testbenches remain available on main for comparison.
