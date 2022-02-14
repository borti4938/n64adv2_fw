//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the N64 RGB/YPbPr DAC project.
//
// Copyright (C) 2016-2022 by Peter Bartmann <borti4938@gmail.com>
//
// N64 RGB/YPbPr DAC is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
//////////////////////////////////////////////////////////////////////////////////
//
// Company:  Circuit-Board.de
// Engineer: borti4938
//
// Module Name:    n64adv2_top
// Project Name:   N64 Advanced RGB/YPbPr DAC Mod
// Target Devices: Max10: 10M16SAE144 (user) / 10M25SAE144 (dev.)
// Tool versions:  Altera Quartus Prime
// Description:
//
// Dependencies: 
// (more dependencies may appear in other files)
//
// Revision: 
// Features: see repository readme
//
//////////////////////////////////////////////////////////////////////////////////


module n64adv2_top (
  // System CLK, Controller and Reset
  SYS_CLK_i,
  CTRL_i,
  N64_nRST_io,

  // N64 Video Input
  N64_CLK_i,
  nVDSYNC_i,
  VD_i,

  // Feedback to Si5356
  N64_CLK_o,
  
  // N64 audio in
  ASCLK_i,
  ASDATA_i,
  ALRCLK_i,
  AMCLK_i,

  // Video Output to ADV7513
  HDMI_CLKsub_i,
  HDMI_CLKmain_i,
  HDMI_CLK_o,
  VSYNC_o,
  HSYNC_o,
  DE_o,
  VD_o,
  
  // I2S audio output for ADV7513
  ASCLK_o,
  ASDATA_o,
  ALRCLK_o,
  ASPDIF_o,
  
  // I2C, Int
  I2C_SCL,
  I2C_SDA,
  INT_ADV7513,
  INT_SI5356,
  
  // SDRAM
  DRAM_ADDR,
  DRAM_BA,
  DRAM_nCAS,
  DRAM_CKE,
  DRAM_CLK,
  DRAM_DQ,
  DRAM_DQM,
  DRAM_nRAS,
  DRAM_nWE,

  // LED outs and PCB ID
  LED_o,
  PCB_ID_i
);

`include "../lib/n64adv2_hw_cfg.vh"
`include "../lib/n64adv_vparams.vh"
`include "../lib/n64adv2_config.vh"

input SYS_CLK_i;
input CTRL_i;
inout N64_nRST_io;

input N64_CLK_i;
input nVDSYNC_i;
input [color_width_i-1:0] VD_i;

input ASCLK_i;
input ASDATA_i;
input ALRCLK_i;
input AMCLK_i;

output N64_CLK_o;

input  HDMI_CLKsub_i;
input  HDMI_CLKmain_i;
output HDMI_CLK_o;
output VSYNC_o;
output HSYNC_o;
output DE_o;
output [3*color_width_o-1:0] VD_o;

output ASCLK_o;
output ASDATA_o;
output ALRCLK_o;
output ASPDIF_o;

inout I2C_SCL;
inout I2C_SDA;
input INT_ADV7513;
input INT_SI5356;

output [11:0] DRAM_ADDR;
output [ 1:0] DRAM_BA;
output        DRAM_nCAS;
output        DRAM_CKE;
output        DRAM_CLK;
inout  [11:0] DRAM_DQ;
output [ 1:0] DRAM_DQM;
output        DRAM_nRAS;
output        DRAM_nWE;

output [1:0] LED_o;

input [1:0] PCB_ID_i;


// connection wires

wire N64_nRST_w;
wire HDMI_CLK_w;
wire HDMI_nRST_w;
wire [1:0] DRAM_CLKs_w;
wire DRAM_nRST_w;
wire [1:0] CLKs_controller_w, nSRST_w;
wire nARST_w;

wire Si_cfg_done_w;

wire [`APUConfig_WordWidth-1:0] APUConfigSet;

wire [`PPU_State_Width-1:0] PPUState_w;
wire [`PPUConfig_WordWidth-1:0] PPUConfigSet_w;
wire OSD_VSync_w;
wire [24:0] OSDWrVector_w;
wire [ 1:0] OSDInfo_w;

wire HSYNC_w, VSYNC_w, DE_w;

wire DRAM_nCS_dummy;
wire DRAM_ADDR12_dummy;
wire [3:0] DRAM_DQ_dummy;


// feedback

assign N64_CLK_o = N64_CLK_i;

// input registering

wire N64_CLK_w = N64_CLK_i;
wire nVDSYNC_w;
wire [6:0] VD_w;

register_sync #(
  .reg_width(8),
  .reg_preset(8'h00)
) inp_vregs_u(
  .clk(N64_CLK_w),
  .clk_en(1'b1),
  .nrst(1'b1),
  .reg_i({nVDSYNC_i,VD_i}),
  .reg_o({nVDSYNC_w,VD_w})
);


// housekeeping of clocks and resets

n64adv2_clk_n_rst_hk clk_n_rst_hk_u(
  .N64_CLK_i(N64_CLK_w),
  .N64_nRST_i(N64_nRST_io),
  .SYS_CLK_i(SYS_CLK_i),
  .N64_nRST_o(N64_nRST_w),
  .N64_palmode(PPUState_w[`PPU_input_pal_bit]),
  .N64_interlaced(PPUState_w[`PPU_input_interlaced_bit]),
  .lowlatencymode(PPUConfigSet_w[`lowlatencymode_bit]),
  .use_vga_for_480p(PPUConfigSet_w[`use_vga_for_480p_bit]),
  .target_resolution(PPUConfigSet_w[`target_resolution_slice]),
  .HDMI_CLKsub_i(HDMI_CLKsub_i),
  .HDMI_CLKmain_i(HDMI_CLKmain_i),
  .Si_cfg_done_i(Si_cfg_done_w),
  .HDMI_CLK_o(HDMI_CLK_w),
  .HDMI_nRST_o(HDMI_nRST_w),
  .DRAM_CLKs_o(DRAM_CLKs_w),
  .DRAM_nRST_o(DRAM_nRST_w),
  .CLKs_controller_o(CLKs_controller_w),
  .nSRST_o(nSRST_w),
  .AMCLK_i(AMCLK_i),
  .nARST_o(nARST_w)
);

// controller module

n64adv2_controller #({hdl_fw_main,hdl_fw_sub}) n64adv2_controller_u(
  .N64_nRST_io(N64_nRST_io),
  .SCLKs(CLKs_controller_w),
  .nSRSTs(nSRST_w),
  .CTRL_i(CTRL_i),
  .I2C_SCL(I2C_SCL),
  .I2C_SDA(I2C_SDA),
  .Interrupt_i({INT_ADV7513,INT_SI5356}),
  .Si_cfg_done_o(Si_cfg_done_w),
  .APUConfigSet(APUConfigSet),
  .PPUState(PPUState_w),
  .PPUConfigSet(PPUConfigSet_w),
  .OSD_VSync(OSD_VSync_w),
  .OSDWrVector(OSDWrVector_w),
  .OSDInfo(OSDInfo_w),
  .N64_CLK_i(N64_CLK_w),
  .N64_nVRST_i(N64_nRST_w),
  .nVDSYNC_i(nVDSYNC_w),
  .VD_VS_i(VD_w[3]),
  .VD_HS_i(VD_w[1]),
  .LED_o(LED_o),
  .PCB_ID_i(PCB_ID_i)
);


// picture processing unit

n64adv2_ppu_top n64adv2_ppu_u(
  .N64_CLK_i(N64_CLK_w),
  .N64_nVRST_i(N64_nRST_w),
  .nVDSYNC_i(nVDSYNC_w),
  .VD_i(VD_w),
  .PPUState(PPUState_w),
  .ConfigSet(PPUConfigSet_w),
  .SYS_CLK(CLKs_controller_w[0]),
  .OSD_VSync(OSD_VSync_w),
  .OSDWrVector(OSDWrVector_w),
  .OSDInfo(OSDInfo_w),
  .scaler_nresync_i(Si_cfg_done_w),
  .VCLK_Tx(HDMI_CLK_w),
  .nVRST_Tx(HDMI_nRST_w),
  .VSYNC_o(VSYNC_w),
  .HSYNC_o(HSYNC_w),
  .DE_o(DE_w),
  .VD_o(VD_o),
  .DRAM_CLK_i(DRAM_CLKs_w[0]),
  .DRAM_nRST_i(DRAM_nRST_w),
  .DRAM_ADDR({DRAM_ADDR12_dummy,DRAM_ADDR}),
  .DRAM_BA(DRAM_BA),
  .DRAM_nCAS(DRAM_nCAS),
  .DRAM_CKE(DRAM_CKE),
  .DRAM_nCS(DRAM_nCS_dummy),
  .DRAM_DQ({DRAM_DQ_dummy,DRAM_DQ}),
  .DRAM_DQM(DRAM_DQM),
  .DRAM_nRAS(DRAM_nRAS),
  .DRAM_nWE(DRAM_nWE)
);

assign DRAM_CLK = DRAM_CLKs_w[1];
assign HDMI_CLK_o = HDMI_CLK_w;
assign HSYNC_o = HSYNC_w;
assign VSYNC_o = VSYNC_w;
assign DE_o = DE_w;


// audio processing module

n64adv2_apu_top n64adv2_apu_u(
  .MCLK_i(AMCLK_i),
  .nRST_i(nARST_w),
  .APUConfigSet(APUConfigSet),
  .SCLK_i(ASCLK_i),
  .SDATA_i(ASDATA_i),
  .LRCLK_i(ALRCLK_i),
  .SCLK_o(ASCLK_o),
  .SDATA_o(ASDATA_o),
  .LRCLK_o(ALRCLK_o),
  .SPDIF_o(ASPDIF_o)
);


endmodule
