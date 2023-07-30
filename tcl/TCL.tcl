# Copyright (C) 1991-2013 Altera Corporation
# Your use of Altera Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License 
# Subscription Agreement, Altera MegaCore Function License 
# Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the 
# applicable agreement for further details.

# Quartus II 64-Bit Version 13.1.0 Build 162 10/23/2013 SJ Full Version
# File: D:\KAITUOZHE\1_Verilog\4_touch_led\doc\touch_led.tcl
# Generated on: Mon May 24 14:43:12 2021

package require ::quartus::project

#set_location_assignment PIN_M2      -to sys_clk
#set_location_assignment PIN_M1      -to sys_rst_n
#set_location_assignment PIN_D11     -to LED[0]
#set_location_assignment PIN_C11     -to LED[1]
#set_location_assignment PIN_E10     -to LED[2]
#set_location_assignment PIN_F9      -to LED[3]

set_location_assignment PIN_M2 -to sys_clk
set_location_assignment PIN_M1 -to sys_rst_n
set_location_assignment PIN_B12 -to tmds_clk_p
set_location_assignment PIN_A12 -to tmds_clk_n
set_location_assignment PIN_B9 -to tmds_data_p[2]
set_location_assignment PIN_A9 -to tmds_data_n[2]
set_location_assignment PIN_B10 -to tmds_data_p[1]
set_location_assignment PIN_A10 -to tmds_data_n[1]
set_location_assignment PIN_B11 -to tmds_data_p[0]
set_location_assignment PIN_A11 -to tmds_data_n[0]
