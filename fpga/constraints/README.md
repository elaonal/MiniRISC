# MiniRISC V2 FPGA Constraints

This directory contains the board-level FPGA constraint information for
MiniRISC V2.

The exact FPGA board has not yet been selected, so physical pin numbers,
I/O standards and the final clock frequency are intentionally not hard-coded.

## Required physical FPGA ports

| MiniRISC port | Purpose |
|---|---|
| `clk` | FPGA board system clock |
| `reset` | External reset push-button |
| `led[7:0]` | CPU hardware debug LEDs |
| `uart_tx_pin` | UART debug transmit output |

## LED mapping

| LED | MiniRISC signal |
|---|---|
| `led[0]` | HALT |
| `led[1]` | Zero flag |
| `led[2]` | Carry flag |
| `led[5:3]` | CPU FSM state |
| `led[7:6]` | PC[1:0] |

## UART

The UART transmitter sends one debug byte when MiniRISC enters HALT.

Debug byte format:

`[7] HALT | [6] Zero | [5] Carry | [4:2] State | [1:0] PC`

The UART baud-rate divisor must be calculated from the actual FPGA board
clock frequency.

## Board-specific work still required

Once the FPGA board is selected:

1. Identify the FPGA device.
2. Identify the board oscillator frequency.
3. Assign `clk` to the oscillator pin.
4. Assign `reset` to a push-button pin.
5. Assign `led[7:0]` to eight LED pins where available.
6. Assign `uart_tx_pin` to a suitable output/UART pin.
7. Set the correct I/O voltage standard.
8. Add the board clock timing constraint.
9. Run synthesis and place-and-route with the board-specific toolchain.

Do not guess physical pin assignments. Always use the official board
schematic, reference manual or master constraint file.