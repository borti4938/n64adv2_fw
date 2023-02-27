//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the N64 RGB/YPbPr DAC project.
//
// Copyright (C) 2015-2023 by Peter Bartmann <borti4938@gmail.com>
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
// Module Name:    n64adv2_clk_n_rst_hk
// Project Name:   N64 Advanced RGB/YPbPr DAC Mod
// Target Devices: universial (PLL and 27MHz clock required)
// Tool versions:  Altera Quartus Prime
// Description:    Housekeeping for clock and reset generation
// Latest change:
//
//////////////////////////////////////////////////////////////////////////////////

module n64adv2_clk_n_rst_hk(
  N64_CLK_i,
  N64_nRST_i,
  nRST_Masking_i,
  
  SYS_CLK_i,
  
  N64_nRST_o,
  
  N64_palmode,
  N64_interlaced,
  lowlatencymode,
  use_vga_for_480p,
  target_resolution,
  
  HDMI_cfg_done_i,
  HDMI_CLKsub_i,
  HDMI_CLKmain_i,
  HDMI_CLK_o,
  HDMI_nRST_o,
  
  DRAM_CLKs_o,
  DRAM_nRST_o,
  
  
  CLKs_controller_o,
  nSRST_o,

  AMCLK_i,
  nARST_o
);


`include "../lib/videotimings.vh"

input N64_CLK_i;
input N64_nRST_i;
input [1:0] nRST_Masking_i;

input SYS_CLK_i;

output N64_nRST_o;

input N64_palmode;
input N64_interlaced;
input lowlatencymode;
input use_vga_for_480p;
input [2:0] target_resolution;

input HDMI_cfg_done_i;
input HDMI_CLKsub_i;
input HDMI_CLKmain_i;

output HDMI_CLK_o;
output HDMI_nRST_o;

output [1:0] DRAM_CLKs_o;
output DRAM_nRST_o;


output [1:0] CLKs_controller_o;
output [1:0] nSRST_o;

input AMCLK_i;
output nARST_o;



// PPU Input Reset
// ===============
wire nRST_video_masked_w = nRST_Masking_i[0] | N64_nRST_i;

reg n64_en = 1'b0;
reg [7:0] n64boot_delay = 8'hff;

always @(posedge N64_CLK_i)
  if (!n64_en) begin
    n64_en <= ~|n64boot_delay;
    n64boot_delay <= n64boot_delay - 4'h1;
  end

reset_generator #(
  .rst_length(4)
) reset_n64clk_u(
  .clk(N64_CLK_i),
//  .clk_en(1'b1),
  .clk_en(n64_en),
  .async_nrst_i(nRST_video_masked_w),
  .rst_o(N64_nRST_o)
);


// HDMI
// ====

reg HDMI_CLK_sel_cmb;
wire HDMI_clk_en_w = n64_en & HDMI_cfg_done_i;
wire HDMI_async_nRST_w = nRST_video_masked_w & HDMI_cfg_done_i;
wire HDMI_CLK_w;

always @(*) begin
  if (lowlatencymode) begin // in low latency mode, N64_interlaced determines the clock selection
    HDMI_CLK_sel_cmb <= N64_interlaced;
  end else begin
    if (target_resolution == `HDMI_TARGET_480P)
      HDMI_CLK_sel_cmb <= use_vga_for_480p;
    else
      HDMI_CLK_sel_cmb <= ((target_resolution == `HDMI_TARGET_960P) || (target_resolution == `HDMI_TARGET_1200P) || (target_resolution == `HDMI_TARGET_1440WP));// in HD modes, main is 720p, 1080p and 1440p (4:3) clock and sub is 960p, 1200p and 1440p (16:9 with pixelrep)
  end
end

altclkctrl altclkctrl_u (
  .inclk0x(HDMI_CLKsub_i),
  .inclk1x(HDMI_CLKmain_i),
  .clkselect(~HDMI_CLK_sel_cmb),
  .outclk(HDMI_CLK_w)
);

reset_generator reset_hdmiclk_u(
  .clk(HDMI_CLK_w),
  .clk_en(HDMI_clk_en_w),
  .async_nrst_i(HDMI_async_nRST_w),
  .rst_o(HDMI_nRST_o)
);

assign HDMI_CLK_o = HDMI_CLK_w;


// PLL for DRAM and system
// =======================


// Sys-PLL
// -------

wire DRAM_CLK_int_w, DRAM_CLK_w;
wire SYS_CLK_1_w, SYS_CLK_0_w;
wire SYS_PLL_LOCKED_w;

system_pll sys_pll_u(
  .inclk0(SYS_CLK_i),
  .areset(1'b0),
  .c0(DRAM_CLK_w),
  .c1(DRAM_CLK_int_w),
  .c2(SYS_CLK_1_w),
  .c3(SYS_CLK_0_w),
  .locked(SYS_PLL_LOCKED_w)
);


// DRAM
// ----

wire DRAM_async_nRST_w = n64_en;

assign DRAM_CLKs_o = {DRAM_CLK_w,DRAM_CLK_int_w};

reset_generator reset_dramclk_u(
  .clk(DRAM_CLK_w),
  .clk_en(SYS_PLL_LOCKED_w),
  .async_nrst_i(DRAM_async_nRST_w),
  .rst_o(DRAM_nRST_o)
);


// system
// ------

reg sys_en = 1'b0;
reg [3:0] sysboot_delay = 4'hf;

always @(posedge SYS_CLK_i)
  if (SYS_PLL_LOCKED_w) begin
    if (!sys_en) begin
      sys_en <= ~|sysboot_delay;
      sysboot_delay <= sysboot_delay - 4'h1;
    end
  end

reset_generator reset_sys_60M_u(
  .clk(SYS_CLK_1_w),
  .clk_en(SYS_PLL_LOCKED_w),
  .async_nrst_i(sys_en),      // special situation here; this reset is only used for soft-CPU (NIOS II), which only resets on power cycle
  .rst_o(nSRST_o[1])
);

reset_generator reset_sys_4M_u(
  .clk(SYS_CLK_0_w),
  .clk_en(n64_en),
  .async_nrst_i(N64_nRST_i),
  .rst_o(nSRST_o[0])
);


assign CLKs_controller_o = {SYS_CLK_1_w,SYS_CLK_0_w};


// Audio
// =====

wire nRST_audio_masked_w = nRST_Masking_i[1] | N64_nRST_i;

reset_generator reset_aclk_u(
  .clk(AMCLK_i),
  .clk_en(n64_en),
  .async_nrst_i(nRST_audio_masked_w),
  .rst_o(nARST_o)
);


endmodule
