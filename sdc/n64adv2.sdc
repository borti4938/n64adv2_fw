##################################################################################
##
## This file is part of the N64 RGB/YPbPr DAC project.
##
## Copyright (C) 2015-2024 by Peter Bartmann <borti4938@gmx.de>
##
## N64 RGB/YPbPr DAC is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.
##
##################################################################################
##
## Company:  Circuit-Board.de
## Engineer: borti4938
##
##################################################################################


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

set n64_vclk_input [get_ports {N64_CLK_i}]
set sclk_input [get_ports {SYS_CLK_i}]
set hdmi_vclk0_input [get_ports {HDMI_CLKsub_i}]
set hdmi_vclk1_input [get_ports {HDMI_CLKmain_i}]
set hdmi_vclk_output [get_ports {HDMI_CLK_o}]
set aclk_input [get_ports {AMCLK_i}]

set n64_vclk_per 20.000
set n64_vclk_waveform [list 0.000 [expr $n64_vclk_per*3/5]]
set sys_clk_per 20.000
set sys_clk_waveform [list 0.000 [expr $sys_clk_per/2]]
set hdmi_clk_240p_per 73.448
set hdmi_clk_240p_waveform [list 0.000 [expr $hdmi_clk_240p_per/2]]
set hdmi_clk_vga_per 39.464
set hdmi_clk_vga_waveform [list 0.000 [expr $hdmi_clk_vga_per/2]]
set hdmi_clk_480p_per 36.724
set hdmi_clk_480p_waveform [list 0.000 [expr $hdmi_clk_480p_per/2]]
set hdmi_clk_720p_per 13.394
set hdmi_clk_720p_waveform [list 0.000 [expr $hdmi_clk_720p_per/2]]
set hdmi_clk_960p_per 11.656
set hdmi_clk_960p_waveform [list 0.000 [expr $hdmi_clk_960p_per/2]]
set hdmi_clk_1080p_per 6.698
set hdmi_clk_1080p_waveform [list 0.000 [expr $hdmi_clk_1080p_per/2]]
set hdmi_clk_1200p_per 7.628
set hdmi_clk_1200p_waveform [list 0.000 [expr $hdmi_clk_1200p_per/2]]
set hdmi_clk_1440p_per 5.510
set hdmi_clk_1440p_waveform [list 0.000 [expr $hdmi_clk_1440p_per/2]]
set hdmi_clk_1440Wp_per 8.230
set hdmi_clk_1440Wp_waveform [list 0.000 [expr $hdmi_clk_1440Wp_per/2]]
set audio_mclk_per 40.706
set audio_mclk_waveform [list 0.000 [expr $audio_mclk_per/2]]

# N64 base clock
create_clock -name {VCLK_N64_VIRT} -period $n64_vclk_per -waveform $n64_vclk_waveform
create_clock -name {VCLK_N64} -period $n64_vclk_per -waveform $n64_vclk_waveform $n64_vclk_input

# HDMI video clock (for simplicity just use the standard clocks)
create_clock -name {HDMI_240P_CLK0} -period $hdmi_clk_240p_per -waveform $hdmi_clk_240p_waveform $hdmi_vclk0_input
create_clock -name {HDMI_VGA_CLK0} -period $hdmi_clk_vga_per -waveform $hdmi_clk_vga_waveform $hdmi_vclk0_input -add
create_clock -name {HDMI_480P_CLK0} -period $hdmi_clk_480p_per -waveform $hdmi_clk_480p_waveform $hdmi_vclk0_input -add
create_clock -name {HDMI_720P_CLK0} -period $hdmi_clk_720p_per -waveform $hdmi_clk_720p_waveform $hdmi_vclk0_input -add
create_clock -name {HDMI_960P_CLK0} -period $hdmi_clk_960p_per -waveform $hdmi_clk_960p_waveform $hdmi_vclk0_input -add
create_clock -name {HDMI_1080P_CLK0} -period $hdmi_clk_1080p_per -waveform $hdmi_clk_1080p_waveform $hdmi_vclk0_input -add
create_clock -name {HDMI_1200P_CLK0} -period $hdmi_clk_1200p_per -waveform $hdmi_clk_1200p_waveform $hdmi_vclk0_input -add
create_clock -name {HDMI_1440P_CLK0} -period $hdmi_clk_1440p_per -waveform $hdmi_clk_1440p_waveform $hdmi_vclk0_input -add
create_clock -name {HDMI_1440WP_CLK0} -period $hdmi_clk_1440Wp_per -waveform $hdmi_clk_1440Wp_waveform $hdmi_vclk0_input -add
create_clock -name {HDMI_240P_CLK1} -period $hdmi_clk_240p_per -waveform $hdmi_clk_240p_waveform $hdmi_vclk1_input
create_clock -name {HDMI_VGA_CLK1} -period $hdmi_clk_vga_per -waveform $hdmi_clk_vga_waveform $hdmi_vclk1_input -add
create_clock -name {HDMI_480P_CLK1} -period $hdmi_clk_480p_per -waveform $hdmi_clk_480p_waveform $hdmi_vclk1_input -add
create_clock -name {HDMI_720P_CLK1} -period $hdmi_clk_720p_per -waveform $hdmi_clk_720p_waveform $hdmi_vclk1_input -add
create_clock -name {HDMI_960P_CLK1} -period $hdmi_clk_960p_per -waveform $hdmi_clk_960p_waveform $hdmi_vclk1_input -add
create_clock -name {HDMI_1080P_CLK1} -period $hdmi_clk_1080p_per -waveform $hdmi_clk_1080p_waveform $hdmi_vclk1_input -add
create_clock -name {HDMI_1200P_CLK1} -period $hdmi_clk_1200p_per -waveform $hdmi_clk_1200p_waveform $hdmi_vclk1_input -add
create_clock -name {HDMI_1440P_CLK1} -period $hdmi_clk_1440p_per -waveform $hdmi_clk_1440p_waveform $hdmi_vclk1_input -add
create_clock -name {HDMI_1440WP_CLK1} -period $hdmi_clk_1440Wp_per -waveform $hdmi_clk_1440Wp_waveform $hdmi_vclk1_input -add

# Audio clock
create_clock -name {AMCLK} -period $audio_mclk_per -waveform $audio_mclk_waveform $aclk_input

# system clock
create_clock -name {SYS_CLK_BASE} -period $sys_clk_per -waveform $sys_clk_waveform $sclk_input
create_clock -name {UFM_OSC} -period 181.818 -waveform { 0.000 90.909 } [get_nets {n64adv2_controller_u|system_u|onchip_flash_0|altera_onchip_flash_block|osc}]


#**************************************************************
# Create Generated Clock
#**************************************************************
create_generated_clock -name {VCLK_N64_fb} -source $n64_vclk_input [get_ports {N64_CLK_o}]

set base2sdram_clk_div_factor 7
set base2sdram_clk_mult_factor 20
set sdram_clk_phase [expr -25.71]

# System PLL Clocks
set sys_pll_in [get_pins {clk_n_rst_hk_u|sys_pll_u|altpll_component|auto_generated|pll1|inclk[0]}]
set sys_pll_sdram_ext_out [get_pins {clk_n_rst_hk_u|sys_pll_u|altpll_component|auto_generated|pll1|clk[0]}]
set sys_pll_sdram_int_out [get_pins {clk_n_rst_hk_u|sys_pll_u|altpll_component|auto_generated|pll1|clk[1]}]
set sys_pll_sysclk_out [get_pins {clk_n_rst_hk_u|sys_pll_u|altpll_component|auto_generated|pll1|clk[2]}]
set sys_pll_ctrlclk_out [get_pins {clk_n_rst_hk_u|sys_pll_u|altpll_component|auto_generated|pll1|clk[3]}]

create_generated_clock -name {DRAM_CLK_o_int} -source $sys_pll_in -divide_by $base2sdram_clk_div_factor -multiply_by $base2sdram_clk_mult_factor -phase $sdram_clk_phase $sys_pll_sdram_ext_out
create_generated_clock -name {DRAM_CLK_int} -source $sys_pll_in -divide_by $base2sdram_clk_div_factor -multiply_by $base2sdram_clk_mult_factor $sys_pll_sdram_int_out
create_generated_clock -name {SYS_CLK} -source $sys_pll_in -divide_by 4 -multiply_by 5 $sys_pll_sysclk_out
create_generated_clock -name {CTRL_CLK} -source $sys_pll_in -divide_by 25 -multiply_by 2 $sys_pll_ctrlclk_out


set vclk_mux_out [get_pins {clk_n_rst_hk_u|altclkctrl_u|altclkctrl_0|altclkctrl_altclkctrl_0_sub_component|clkctrl1|outclk}]
set vclk_out [get_ports {HDMI_CLK_o}]

create_generated_clock -name {HDMI_240P_CLK0_o_int} -source $hdmi_vclk0_input -master_clock {HDMI_240P_CLK0} $vclk_mux_out
create_generated_clock -name {HDMI_VGA_CLK0_o_int} -source $hdmi_vclk0_input -master_clock {HDMI_VGA_CLK0} $vclk_mux_out -add
create_generated_clock -name {HDMI_480P_CLK0_o_int} -source $hdmi_vclk0_input -master_clock {HDMI_480P_CLK0} $vclk_mux_out -add
create_generated_clock -name {HDMI_720P_CLK0_o_int} -source $hdmi_vclk0_input -master_clock {HDMI_720P_CLK0} $vclk_mux_out -add
create_generated_clock -name {HDMI_960P_CLK0_o_int} -source $hdmi_vclk0_input -master_clock {HDMI_960P_CLK0} $vclk_mux_out -add
create_generated_clock -name {HDMI_1080P_CLK0_o_int} -source $hdmi_vclk0_input -master_clock {HDMI_1080P_CLK0} $vclk_mux_out -add
create_generated_clock -name {HDMI_1200P_CLK0_o_int} -source $hdmi_vclk0_input -master_clock {HDMI_1200P_CLK0} $vclk_mux_out -add
create_generated_clock -name {HDMI_1440P_CLK0_o_int} -source $hdmi_vclk0_input -master_clock {HDMI_1440P_CLK0} $vclk_mux_out -add
create_generated_clock -name {HDMI_1440WP_CLK0_o_int} -source $hdmi_vclk0_input -master_clock {HDMI_1440WP_CLK0} $vclk_mux_out -add
create_generated_clock -name {HDMI_240P_CLK1_o_int} -source $hdmi_vclk1_input -master_clock {HDMI_240P_CLK1} $vclk_mux_out -add
create_generated_clock -name {HDMI_VGA_CLK1_o_int} -source $hdmi_vclk1_input -master_clock {HDMI_VGA_CLK1} $vclk_mux_out -add
create_generated_clock -name {HDMI_480P_CLK1_o_int} -source $hdmi_vclk1_input -master_clock {HDMI_480P_CLK1} $vclk_mux_out -add
create_generated_clock -name {HDMI_720P_CLK1_o_int} -source $hdmi_vclk1_input -master_clock {HDMI_720P_CLK1} $vclk_mux_out -add
create_generated_clock -name {HDMI_960P_CLK1_o_int} -source $hdmi_vclk1_input -master_clock {HDMI_960P_CLK1} $vclk_mux_out -add
create_generated_clock -name {HDMI_1080P_CLK1_o_int} -source $hdmi_vclk1_input -master_clock {HDMI_1080P_CLK1} $vclk_mux_out -add
create_generated_clock -name {HDMI_1200P_CLK1_o_int} -source $hdmi_vclk1_input -master_clock {HDMI_1200P_CLK1} $vclk_mux_out -add
create_generated_clock -name {HDMI_1440P_CLK1_o_int} -source $hdmi_vclk1_input -master_clock {HDMI_1440P_CLK1} $vclk_mux_out -add
create_generated_clock -name {HDMI_1440WP_CLK1_o_int} -source $hdmi_vclk1_input -master_clock {HDMI_1440WP_CLK1} $vclk_mux_out -add

create_generated_clock -name {HDMI_240P_CLK0_out} -source $vclk_mux_out -master_clock {HDMI_240P_CLK0_o_int} $vclk_out
create_generated_clock -name {HDMI_VGA_CLK0_out} -source $vclk_mux_out -master_clock {HDMI_VGA_CLK0_o_int} $vclk_out -add
create_generated_clock -name {HDMI_480P_CLK0_out} -source $vclk_mux_out -master_clock {HDMI_480P_CLK0_o_int} $vclk_out -add
create_generated_clock -name {HDMI_720P_CLK0_out} -source $vclk_mux_out -master_clock {HDMI_720P_CLK0_o_int} $vclk_out -add
create_generated_clock -name {HDMI_960P_CLK0_out} -source $vclk_mux_out -master_clock {HDMI_960P_CLK0_o_int} $vclk_out -add
create_generated_clock -name {HDMI_1080P_CLK0_out} -source $vclk_mux_out -master_clock {HDMI_1080P_CLK0_o_int} $vclk_out -add
create_generated_clock -name {HDMI_1200P_CLK0_out} -source $vclk_mux_out -master_clock {HDMI_1200P_CLK0_o_int} $vclk_out -add
create_generated_clock -name {HDMI_1440P_CLK0_out} -source $vclk_mux_out -master_clock {HDMI_1440P_CLK0_o_int} $vclk_out -add
create_generated_clock -name {HDMI_1440WP_CLK0_out} -source $vclk_mux_out -master_clock {HDMI_1440WP_CLK0_o_int} $vclk_out -add
create_generated_clock -name {HDMI_240P_CLK1_out} -source $vclk_mux_out -master_clock {HDMI_240P_CLK1_o_int} $vclk_out -add
create_generated_clock -name {HDMI_VGA_CLK1_out} -source $vclk_mux_out -master_clock {HDMI_VGA_CLK1_o_int} $vclk_out -add
create_generated_clock -name {HDMI_480P_CLK1_out} -source $vclk_mux_out -master_clock {HDMI_480P_CLK1_o_int} $vclk_out -add
create_generated_clock -name {HDMI_720P_CLK1_out} -source $vclk_mux_out -master_clock {HDMI_720P_CLK1_o_int} $vclk_out -add
create_generated_clock -name {HDMI_960P_CLK1_out} -source $vclk_mux_out -master_clock {HDMI_960P_CLK1_o_int} $vclk_out -add
create_generated_clock -name {HDMI_1080P_CLK1_out} -source $vclk_mux_out -master_clock {HDMI_1080P_CLK1_o_int} $vclk_out -add
create_generated_clock -name {HDMI_1200P_CLK1_out} -source $vclk_mux_out -master_clock {HDMI_1200P_CLK1_o_int} $vclk_out -add
create_generated_clock -name {HDMI_1440P_CLK1_out} -source $vclk_mux_out -master_clock {HDMI_1440P_CLK1_o_int} $vclk_out -add
create_generated_clock -name {HDMI_1440WP_CLK1_out} -source $vclk_mux_out -master_clock {HDMI_1440WP_CLK1_o_int} $vclk_out -add

set sdram_clk_out [get_ports {DRAM_CLK}]
create_generated_clock -name {DRAM_CLK_out} -source $sys_pll_sdram_ext_out -master_clock {DRAM_CLK_o_int} $sdram_clk_out
set_multicycle_path -from [get_clocks {DRAM_CLK_o_int}] -to [get_clocks {DRAM_CLK_out}] -hold 1

# System Clocks
create_generated_clock -name {flash_int_clk} -source [get_pins {n64adv2_controller_u|system_u|onchip_flash_0|avmm_data_controller|flash_se_neg_reg|clk }] -master_clock {SYS_CLK} -divide_by 2 [get_pins {n64adv2_controller_u|system_u|onchip_flash_0|avmm_data_controller|flash_se_neg_reg|q}]


#**************************************************************
# Set Clock Uncertainty
#**************************************************************

derive_clock_uncertainty


#**************************************************************
# Set Input Delay for N64 data
#**************************************************************
# delays were carried out at the modding board and includes some potential skew (quite large for slow corner)
set n64_data_delay_min 2.0
set n64_data_delay_max 8.0
# allow a trace/wire margin of +/-3cm difference in installation between clock and any data
set n64_margin 0.15
set n64_in_dly_min [expr $n64_data_delay_min - $n64_margin]
set n64_in_dly_max [expr $n64_data_delay_max + $n64_margin]

set_input_delay -clock {VCLK_N64_VIRT} -min $n64_in_dly_min [get_ports {nVDSYNC_i VD_i[*]}]
set_input_delay -clock {VCLK_N64_VIRT} -max $n64_in_dly_max [get_ports {nVDSYNC_i VD_i[*]}]

set_input_delay -clock altera_reserved_tck 20 [get_ports altera_reserved_tdi]
set_input_delay -clock altera_reserved_tck 20 [get_ports altera_reserved_tms]



#**************************************************************
# Set Output Delay for HDMI output
#**************************************************************

set adv_vtsu 1.0
set adv_vth  0.7
set adv_pcb_data2clk_skew_min 0.0
set adv_pcb_data2clk_skew_max 0.1
set adv_out_dly_max [expr $adv_vtsu + $adv_pcb_data2clk_skew_min]
set adv_out_dly_min [expr -$adv_vth - $adv_pcb_data2clk_skew_max]

set adv_vid_ports [get_ports {VD_o* VSYNC_o HSYNC_o DE_o}]

foreach_in_collection clk_o [get_clocks HDMI_*_CLK*_out] {
  set_output_delay -clock $clk_o -max $adv_out_dly_max $adv_vid_ports -add_delay
  set_output_delay -clock $clk_o -min $adv_out_dly_min $adv_vid_ports -add_delay
}


set_output_delay -clock {AMCLK} -max 1 [get_ports {ASCLK_o ASDATA_o ALRCLK_o}]
set_output_delay -clock {AMCLK} -min -1 [get_ports {ASCLK_o ASDATA_o ALRCLK_o}]



#**************************************************************
# Set Input and Output Delay for SDRAM
#**************************************************************

## input delay
# tac: CL=2: 6.0ns | CL=3: 5.4ns
#set sdram_tac   6.0
set sdram_tac   5.4
set sdram_toh   2.5
set sdram_pcb_delay 0.15
set sdram_pcb_in_skew  0.015

set sdram_in_dly_min [expr {$sdram_toh + 2*($sdram_pcb_delay - $sdram_pcb_in_skew)}]
set sdram_in_dly_max [expr {$sdram_tac + 2*($sdram_pcb_delay + $sdram_pcb_in_skew)}]

set_input_delay -clock { DRAM_CLK_out } -max $sdram_in_dly_max [get_ports {DRAM_DQ[*]}]
set_input_delay -clock { DRAM_CLK_out } -min $sdram_in_dly_min [get_ports {DRAM_DQ[*]}]


# output delay
set sdram_tsu 1.5
set sdram_th 0.8
set sdram_pcb_out_skew  0.05

set sdram_out_dly_max [expr $sdram_tsu + $sdram_pcb_out_skew]
set sdram_out_dly_min [expr -$sdram_th - $sdram_pcb_out_skew]

set_output_delay -clock {DRAM_CLK_out} -max $sdram_out_dly_max [get_ports {DRAM_*}]
set_output_delay -clock {DRAM_CLK_out} -min $sdram_out_dly_min [get_ports {DRAM_*}]

set_multicycle_path -from [get_clocks {DRAM_CLK_out}] -to [get_clocks {DRAM_CLK_int}] -setup 3
set_multicycle_path -from [get_clocks {DRAM_CLK_out}] -to [get_clocks {DRAM_CLK_int}] -hold 2
set_multicycle_path -from [get_clocks {DRAM_CLK_int}] -to [get_clocks {DRAM_CLK_out}] -setup 2
set_multicycle_path -from [get_clocks {DRAM_CLK_int}] -to [get_clocks {DRAM_CLK_out}] -hold 1


#**************************************************************
# Set Output Delay for JTAG
#**************************************************************

set_output_delay -clock altera_reserved_tck 20 [get_ports altera_reserved_tdo]


#**************************************************************
# Set Clock Groups
#**************************************************************

set_clock_groups -logically_exclusive \
                    -group {VCLK_N64_VIRT VCLK_N64 VCLK_N64_fb} \
                    -group {HDMI_240P_CLK0 HDMI_240P_CLK0_o_int HDMI_240P_CLK0_out} \
                    -group {HDMI_VGA_CLK0 HDMI_VGA_CLK0_o_int HDMI_VGA_CLK0_out} \
                    -group {HDMI_480P_CLK0 HDMI_480P_CLK0_o_int HDMI_480P_CLK0_out} \
                    -group {HDMI_720P_CLK0 HDMI_720P_CLK0_o_int HDMI_720P_CLK0_out} \
                    -group {HDMI_960P_CLK0 HDMI_960P_CLK0_o_int HDMI_960P_CLK0_out} \
                    -group {HDMI_1080P_CLK0 HDMI_1080P_CLK0_o_int HDMI_1080P_CLK0_out} \
                    -group {HDMI_1200P_CLK0 HDMI_1200P_CLK0_o_int HDMI_1200P_CLK0_out} \
                    -group {HDMI_1440P_CLK0 HDMI_1440P_CLK0_o_int HDMI_1440P_CLK0_out} \
                    -group {HDMI_1440WP_CLK0 HDMI_1440WP_CLK0_o_int HDMI_1440WP_CLK0_out} \
                    -group {HDMI_240P_CLK1 HDMI_240P_CLK1_o_int HDMI_240P_CLK1_out} \
                    -group {HDMI_VGA_CLK1 HDMI_VGA_CLK1_o_int HDMI_VGA_CLK1_out} \
                    -group {HDMI_480P_CLK1 HDMI_480P_CLK1_o_int HDMI_480P_CLK1_out} \
                    -group {HDMI_720P_CLK1 HDMI_720P_CLK1_o_int HDMI_720P_CLK1_out} \
                    -group {HDMI_960P_CLK1 HDMI_960P_CLK1_o_int HDMI_960P_CLK1_out} \
                    -group {HDMI_1080P_CLK1 HDMI_1080P_CLK1_o_int HDMI_1080P_CLK1_out} \
                    -group {HDMI_1200P_CLK1 HDMI_1200P_CLK1_o_int HDMI_1200P_CLK1_out} \
                    -group {HDMI_1440P_CLK1 HDMI_1440P_CLK1_o_int HDMI_1440P_CLK1_out} \
                    -group {HDMI_1440WP_CLK1 HDMI_1440WP_CLK1_o_int HDMI_1440WP_CLK1_out} \
                    -group {DRAM_CLK_int DRAM_CLK_o_int DRAM_CLK_out} \
                    -group {SYS_CLK_BASE} \
                    -group {CTRL_CLK} \
                    -group {SYS_CLK flash_int_clk} \
                    -group {UFM_OSC} \
                    -group {AMCLK}


#**************************************************************
# Set False Path by Module
#**************************************************************
# (might be not exhaustive)

# general
#*************************************


# some misc intput ports as false path
#*************************************
set_false_path -from [get_ports {N64_nRST_io CTRL_i ASCLK_i ASDATA_i ALRCLK_i INT_* I2C_SCL I2C_SDA PCB_ID_i*}]


# Clock and Reset Housekeeping
#*************************************
set_false_path -from [get_registers {*rst_o}]


# PPU top
#*************************************
set_false_path -from [get_registers {n64adv2_ppu_u|cfg_sync4n64clk_u0|reg_synced_1[*] \
                                     n64adv2_ppu_u|cfg_sync4dramlogic_u0|reg_synced_1[*] \
                                     n64adv2_ppu_u|cfg_sync4dramlogic_u1|reg_synced_1[*] \
                                     n64adv2_ppu_u|cfg_sync4txlogic_u0|reg_synced_1[*] \
                                     n64adv2_ppu_u|cfg_sync4txlogic_u1|reg_synced_1[*] \
                                     n64adv2_ppu_u|cfg_* n64adv2_ppu_u|*|X_* \
                                     n64adv2_ppu_u|cfg_* n64adv2_ppu_u|*|Y_* \
                                     n64adv2_ppu_u|cfg_* n64adv2_ppu_u|*|Z_*}]


# Video Info
#*************************************
set_false_path -from [get_registers {n64adv2_ppu_u|get_vinfo_u|field_id \
                                     n64adv2_ppu_u|get_vinfo_u|n64_480i \
                                     n64adv2_ppu_u|get_vinfo_u|palmode \
                                     n64adv2_ppu_u|get_vinfo_u|pal_in_240p_box \
                                     n64adv2_ppu_u|get_vinfo_u|vdata_detected} \
                     ]

# APU top
#*************************************
set_false_path -from [get_registers {n64adv2_apu_u|cfg_sync4mclk_u|reg_synced_1[*] n64adv2_apu_u|cfg_*}]


# some misc output ports as false path
#*************************************
set_false_path -to [get_ports {ASPDIF_o}]
set_false_path -to [get_ports {N64_nRST_io nViDeblur_o I2C_SCL I2C_SDA LED_o[*]}]

