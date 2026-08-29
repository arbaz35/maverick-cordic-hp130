# ============================================================
# CORDIC Single-Clock SDC
# HP130 / IHP SG13G2
# Target clock: 64 MHz
# Clock period: 15.625 ns
# ============================================================

create_clock -name clk -period 15.625 [get_ports clk]

# Clock uncertainty
set_clock_uncertainty 0.20 [get_clocks clk]

# Input delays
set_input_delay 2.0 -clock clk [get_ports rst_n]
set_input_delay 2.0 -clock clk [get_ports ena]
set_input_delay 2.0 -clock clk [get_ports ui_in]
set_input_delay 2.0 -clock clk [get_ports uio_in]

# Output delays
set_output_delay 2.0 -clock clk [get_ports uo_out]
set_output_delay 2.0 -clock clk [get_ports uio_out]
set_output_delay 2.0 -clock clk [get_ports uio_oe]

# Asynchronous reset
set_false_path -from [get_ports rst_n]
