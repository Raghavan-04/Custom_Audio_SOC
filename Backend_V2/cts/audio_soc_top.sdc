###############################################################################
# Created by write_sdc
# Wed May 20 15:25:02 2026
###############################################################################
current_design audio_soc_top
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name clk -period 20.0000 [get_ports {clk}]
set_clock_transition 0.1500 [get_clocks {clk}]
set_clock_uncertainty 0.2500 clk
set_propagated_clock [get_clocks {clk}]
set_input_delay 4.0000 -clock [get_clocks {clk}] -add_delay [get_ports {rst_n}]
set_output_delay 4.0000 -clock [get_clocks {clk}] -add_delay [get_ports {audio_out}]
set_output_delay 4.0000 -clock [get_clocks {clk}] -add_delay [get_ports {gpio_pins[0]}]
set_output_delay 4.0000 -clock [get_clocks {clk}] -add_delay [get_ports {gpio_pins[1]}]
set_output_delay 4.0000 -clock [get_clocks {clk}] -add_delay [get_ports {gpio_pins[2]}]
set_output_delay 4.0000 -clock [get_clocks {clk}] -add_delay [get_ports {gpio_pins[3]}]
set_output_delay 4.0000 -clock [get_clocks {clk}] -add_delay [get_ports {gpio_pins[4]}]
set_output_delay 4.0000 -clock [get_clocks {clk}] -add_delay [get_ports {gpio_pins[5]}]
set_output_delay 4.0000 -clock [get_clocks {clk}] -add_delay [get_ports {gpio_pins[6]}]
set_output_delay 4.0000 -clock [get_clocks {clk}] -add_delay [get_ports {gpio_pins[7]}]
###############################################################################
# Environment
###############################################################################
set_load -pin_load 0.0334 [get_ports {audio_out}]
set_load -pin_load 0.0334 [get_ports {gpio_pins[7]}]
set_load -pin_load 0.0334 [get_ports {gpio_pins[6]}]
set_load -pin_load 0.0334 [get_ports {gpio_pins[5]}]
set_load -pin_load 0.0334 [get_ports {gpio_pins[4]}]
set_load -pin_load 0.0334 [get_ports {gpio_pins[3]}]
set_load -pin_load 0.0334 [get_ports {gpio_pins[2]}]
set_load -pin_load 0.0334 [get_ports {gpio_pins[1]}]
set_load -pin_load 0.0334 [get_ports {gpio_pins[0]}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {clk}]
set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 -pin {Y} -input_transition_rise 0.0000 -input_transition_fall 0.0000 [get_ports {rst_n}]
set_timing_derate -early 0.9500
set_timing_derate -late 1.0500
###############################################################################
# Design Rules
###############################################################################
set_max_transition 0.7500 [current_design]
set_max_fanout 10.0000 [current_design]
