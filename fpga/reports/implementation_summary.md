# MiniRISC V2 FPGA Implementation Summary

## 1. Implementation Target

- FPGA family: Lattice iCE40
- Device: iCE40HX8K
- Package: CT256
- Physical FPGA board: Not used
- Implementation clock target: 50 MHz
- Target clock period: 20 ns

The device is used as a virtual implementation target for synthesis,
place-and-route, timing analysis and FPGA resource evaluation.

No physical FPGA deployment is claimed.

---

## 2. Tool Flow

MiniRISC V2 was processed using:

1. Verilog/SystemVerilog simulation
2. Yosys synthesis
3. iCE40 technology mapping
4. nextpnr-ice40 packing
5. nextpnr placement
6. nextpnr routing
7. Post-route timing analysis
8. FPGA resource-utilisation analysis

Implementation flow:

Verilog RTL  
→ Yosys  
→ iCE40 JSON netlist  
→ nextpnr-ice40  
→ placed-and-routed ASC design  
→ timing and utilisation reports

---

## 3. FPGA Top-Level Architecture

Implementation top:

`minirisc_ice40_top`

External-style ports:

- `clk`
- `reset`
- `led[7:0]`
- `uart_tx_pin`

The implementation includes:

- MiniRISC CPU
- synchronised external reset
- LED processor-state debugging
- UART debug transmitter

---

## 4. Synthesis Results

Source:

`yosys_synthesis.log`

Record the final synthesis statistics here:

- LUT / logic cells: TBD
- Flip-flops: TBD
- Carry cells: TBD
- Block RAM: TBD
- Other mapped resources: TBD

---

## 5. Place-and-Route

Source:

`nextpnr_place_route.log`

- Packing: PASS
- Placement: PASS
- Routing: PASS
- Target device: iCE40HX8K
- Package: CT256
- Physical pin constraints: Not used

I/O was left unconstrained because no physical FPGA board is used.

---

## 6. Timing Analysis

Timing target:

- Frequency: 50 MHz
- Period: 20 ns

Measured from the post-route tool report:

- nextpnr estimated Fmax: TBD MHz
- 50 MHz timing target met: TBD

The reported frequency is a tool-estimated post-route result for the
selected FPGA architecture and is not a physical measurement.

---

## 7. Resource Utilisation

Record the actual post-synthesis/place-and-route values:

| FPGA Resource | Used |
|---|---:|
| LUTs / logic cells | TBD |
| Flip-flops | TBD |
| Carry cells | TBD |
| Block RAM | TBD |
| I/O | TBD |

---

## 8. Hardware Interface

LED debug mapping:

| Output | Processor information |
|---|---|
| LED0 | HALT |
| LED1 | Zero flag |
| LED2 | Carry flag |
| LED3–5 | FSM state |
| LED6–7 | PC[1:0] |

UART debug packet:

`HALT | ZERO | CARRY | FSM STATE | PC[1:0]`

UART transmission is generated when MiniRISC enters the HALT state.

---

## 9. Project Scope

MiniRISC V2 was verified and evaluated through simulation, synthesis,
place-and-route and timing/resource analysis.

The FPGA integration RTL is prepared for future hardware deployment,
but no physical FPGA board was used.

Physical FPGA programming and real-hardware validation therefore remain
optional future work.