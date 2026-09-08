# ============================================================
# MiniRISC V2 Clock Constraint Template
# ============================================================
#
# Replace <CLOCK_PERIOD_NS> only after the FPGA board clock
# frequency is known.
#
# Example:
#
# 50 MHz:
# period = 20 ns
#
# 100 MHz:
# period = 10 ns
#
# DO NOT use either value unless it matches the real board.
# ============================================================

# create_clock \
#     -name sys_clk \
#     -period <CLOCK_PERIOD_NS> \
#     [get_ports {clk}]