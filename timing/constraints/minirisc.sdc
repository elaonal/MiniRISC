# MiniRISC V2 - Preliminary Timing Constraint
#
# 50 MHz preliminary analysis clock.
# Final clock constraints will depend on the selected FPGA implementation.

create_clock -name clk -period 20.000 [get_ports clk]
