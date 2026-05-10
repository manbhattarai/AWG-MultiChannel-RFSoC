#set_false_path -from [get_clocks clk_pl_0] -to [get_clocks RFDAC0_CLK]
#set_false_path -from [get_clocks clk_pl_0] -to [get_clocks RFDAC2_CLK]
#set_false_path -from [get_clocks RFDAC0_CLK] -to [get_clocks RFDAC2_CLK]
#set_false_path -from [get_clocks RFDAC2_CLK] -to [get_clocks RFDAC0_CLK]
set_property IOSTANDARD LVCMOS18 [get_ports control_trigger_0]
set_property PACKAGE_PIN AG17 [get_ports control_trigger_0]

#set_input_delay -clock [get_clocks RFDAC0_CLK] 1.0 [get_ports control_trigger_0]

create_clock -name m_axis_clk -period 50 [get_ports m_axis_clk]   # 20 MHz for example
create_clock -name m00_axis_aclk -period 1.628 [get_ports m00_axis_aclk] # 50 MHz
create_clock -name m22_axis_aclk -period 1.628 [get_ports m22_axis_aclk]
set_clock_groups -asynchronous -group [get_clocks clk_pl_0] -group [get_clocks RFDAC0_CLK]
set_clock_groups -asynchronous -group [get_clocks clk_pl_0] -group [get_clocks RFDAC2_CLK]


