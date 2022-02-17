//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the N64 RGB/YPbPr DAC project.
//
// Copyright (C) 2016-2022 by Peter Bartmann <borti4938@gmx.de>
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
// Module Name:    n64adv2_ppu_top
// Project Name:   N64 Advanced HMDI Mod
// Target Devices: 10M16SAE144
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


module n64adv2_ppu_top (
  // N64 Video Input
  N64_CLK_i,
  N64_nVRST_i,
  nVDSYNC_i,
  VD_i,

  // Misc Information Exchange
  // Note: SYS_CLK is System clock (Nios II)
  PPUState,
  ConfigSet,

  SYS_CLK,
  
  OSD_VSync,
  OSDWrVector,
  OSDInfo,
  
  scaler_nresync_i,

  // VCLK for video output
  VCLK_Tx,
  nVRST_Tx,

  // Video Output to ADV7513
  VSYNC_o,
  HSYNC_o,
  DE_o,
  VD_o,
  
  // SDRAM
  DRAM_CLK_i,
  DRAM_nRST_i,
  DRAM_ADDR,
  DRAM_BA,
  DRAM_nCAS,
  DRAM_CKE,
  DRAM_nCS,
  DRAM_DQ,
  DRAM_DQM,
  DRAM_nRAS,
  DRAM_nWE
);


`include "../lib/n64adv_cparams.vh"
`include "../lib/n64adv_vparams.vh"
`include "../lib/n64adv2_config.vh"
`include "../lib/videotimings.vh"

`include "../lib/setVideoTimings.tasks.v"
`include "../lib/setOSDConfig.tasks.v"

input N64_CLK_i;
input N64_nVRST_i;
input nVDSYNC_i;
input [color_width_i-1:0] VD_i;

output [`PPU_State_Width-1:0] PPUState;
input  [`PPUConfig_WordWidth-1:0] ConfigSet;

input        SYS_CLK;

output       OSD_VSync;
input [24:0] OSDWrVector;
input [ 1:0] OSDInfo;

input scaler_nresync_i;

input VCLK_Tx;
input nVRST_Tx;

output reg VSYNC_o = 1'b0;
output reg HSYNC_o = 1'b0;
output reg DE_o = 1'b0;
output reg [3*color_width_o-1:0] VD_o = {3*color_width_o{1'b0}};

input         DRAM_CLK_i;
input         DRAM_nRST_i;
output [12:0] DRAM_ADDR;
output [ 1:0] DRAM_BA;
output        DRAM_nCAS;
output        DRAM_CKE;
output        DRAM_nCS;
inout  [15:0] DRAM_DQ;
output [ 1:0] DRAM_DQM;
output        DRAM_nRAS;
output        DRAM_nWE;


// start of rtl

// params
localparam limitRGB_coeff = 8'd220;
localparam limitRGB_offset = 8'd16;

// wires
wire [1:0] vinfo_pass;  // [1:0] {vmode,n64_480i}
wire palmode, n64_480i;

wire [ 3:0] cfg_gamma;
wire cfg_nvideblur_pre, cfg_n16bit_mode;
wire [9:0] cfg_hvshift;
wire cfg_bob_deinterlacing_mode;

wire [`VID_CFG_W-1:0] sys_vmode_ntsc_w, sys_vmode_pal_w;
wire [10:0] vlines_set_w;
wire [11:0] hpixels_set_w;

wire palmode_sysclk_resynced, n64_480i_sysclk_resynced;
wire use_interlaced_full_w;
wire cfg_nvideblur_sysclk_resynced;

wire cfg_deinterlacing_mode_dramclk_resynced;
wire palmode_dramclk_resynced, n64_480i_dramclk_resynced;

wire cfg_lowlatencymode_resynced;
wire [9:0] cfg_vpos_1st_rdline_w, cfg_vpos_1st_rdline_resynced;
wire [10:0] cfg_vlines_out_w, cfg_vlines_out_resynced;
wire [17:0] cfg_v_interp_factor_w, cfg_v_interp_factor_resynced;
wire [9:0] cfg_vlines_in_needed_w, cfg_vlines_in_needed_resynced;
wire [9:0] cfg_vlines_in_full_w, cfg_vlines_in_full_resynced;

wire [9:0] cfg_hpos_1st_rdpixel_w, cfg_hpos_1st_rdpixel_resynced;
wire [11:0] cfg_hpixels_out_w, cfg_hpixels_out_resynced;
wire [17:0] cfg_h_interp_factor_w, cfg_h_interp_factor_resynced;
wire [9:0] cfg_hpixel_in_needed_w, cfg_hpixel_in_needed_resynced;
wire [9:0] cfg_hpixel_in_full_w, cfg_hpixel_in_full_resynced;

wire palmode_vclk_o_resynced, n64_480i_vclk_o_resynced;
wire [`VID_CFG_W-1:0] videomode_ntsc_w, videomode_pal_w;

wire [`PPUConfig_WordWidth-1:0] ConfigSet_resynced;

wire vdata_valid_bwd_w, vdata_valid_fwd_w;
wire [`VDATA_I_SY_SLICE] vdata_bwd_sy_w;
wire [`VDATA_I_FU_SLICE] vdata_fwd_w;

wire vdata_valid_pp_w[0:1], vdata_valid_pp_dummy_w_4;
wire [`VDATA_I_FU_SLICE] vdata21_pp_w;
wire [`VDATA_O_FU_SLICE] vdata24_pp_w[1:5];

wire async_nRST_scaler_w;
wire [7:0] sl_vpos_rel_w, sl_hpos_rel_w;

wire [1:0] OSDInfo_resynced;

wire [15:0] limited_Re_pre, limited_Gr_pre, limited_Bl_pre;

//regs
reg cfg_nvideblur;

reg [`VID_CFG_W-1:0] sys_videomode;

reg [`VID_CFG_W-1:0] cfg_videomode;
reg [1:0] cfg_interpolation_mode;
reg cfg_pal_boxed;

reg cfg_SL_v_en, cfg_SL_h_en;
reg cfg_SL_thickness;
reg [1:0] cfg_SL_profile;
reg [4:0] cfg_SLHyb_str;
reg [7:0] cfg_SL_str;

reg [2:0] cfg_osd_vscale;
reg [1:0] cfg_osd_hscale;
reg [10:0] cfg_osd_voffset;
reg [11:0] cfg_osd_hoffset;

reg cfg_active_vsync;
reg cfg_active_hsync;

reg cfg_limitedRGB;

reg [3:0] palmode_buf;
reg palmode_change;

reg [color_width_o-1:0] limited_Re_pre_LL, limited_Gr_pre_LL, limited_Bl_pre_LL;
reg [color_width_o  :0] limited_Re_pre_L, limited_Gr_pre_L, limited_Bl_pre_L;
reg [`VDATA_O_CO_SLICE] full_RGB_pre_LL, full_RGB_pre_L;
reg VSYNC_pre_LL, VSYNC_pre_L, HSYNC_pre_LL, HSYNC_pre_L, DE_pre_LL, DE_pre_L;

reg VSYNC_o_L = 1'b0;
reg HSYNC_o_L = 1'b0;
reg DE_o_L = 1'b0;
reg [3*color_width_o-1:0] VD_o_L = {3*color_width_o{1'b0}};


// apply some assignments
// ----------------------

assign palmode = vinfo_pass[1];
assign n64_480i = vinfo_pass[0];

assign PPUState[`PPU_input_pal_bit]             = palmode;
assign PPUState[`PPU_input_interlaced_bit]      = n64_480i;
assign PPUState[`PPU_output_f5060_slice]        = {ConfigSet_resynced[`force50hz_bit],ConfigSet_resynced[`force60hz_bit]};
assign PPUState[`PPU_output_vga_for_480p_bit]   = ConfigSet_resynced[`use_vga_for_480p_bit];
assign PPUState[`PPU_output_resolution_slice]   = ConfigSet_resynced[`target_resolution_slice];
assign PPUState[`PPU_output_lowlatencymode_bit] = ConfigSet_resynced[`lowlatencymode_bit];
assign PPUState[`PPU_240p_deblur_bit]           = ~cfg_nvideblur;
assign PPUState[`PPU_color_16bit_mode_bit]      = ~cfg_n16bit_mode;
assign PPUState[`PPU_gamma_table_slice]         = cfg_gamma;


// write configuration register
// ----------------------------

// generate aprroximated multiplication factor for scaler config in sysclk domain first

register_sync #(
  .reg_width(3),
  .reg_preset(3'd0)
) sync4cpu_u0(
  .clk(SYS_CLK),
  .clk_en(1'b1),
  .nrst(1'b1),
  .reg_i({palmode                ,n64_480i                ,cfg_nvideblur}),
  .reg_o({palmode_sysclk_resynced,n64_480i_sysclk_resynced,cfg_nvideblur_sysclk_resynced})
);


assign sys_vmode_ntsc_w = ConfigSet[`target_resolution_slice] == `HDMI_TARGET_1440P ? `USE_1440p60 :
                          ConfigSet[`target_resolution_slice] == `HDMI_TARGET_1200P ? `USE_1200p60 :
                          ConfigSet[`target_resolution_slice] == `HDMI_TARGET_1080P ? `USE_1080p60 :
                          ConfigSet[`target_resolution_slice] == `HDMI_TARGET_960P  ? `USE_960p60  :
                          ConfigSet[`target_resolution_slice] == `HDMI_TARGET_720P  ? `USE_720p60  :
                          ConfigSet[`target_resolution_slice] == `HDMI_TARGET_240P  ? `USE_240p60  :
                          ConfigSet[`use_vga_for_480p_bit]                          ? `USE_VGAp60  :
                                                                                      `USE_480p60  ;

assign sys_vmode_pal_w =  ConfigSet[`target_resolution_slice] == `HDMI_TARGET_1440P ? `USE_1440p50 :
                          ConfigSet[`target_resolution_slice] == `HDMI_TARGET_1200P ? `USE_1200p50 :
                          ConfigSet[`target_resolution_slice] == `HDMI_TARGET_1080P ? `USE_1080p50 :
                          ConfigSet[`target_resolution_slice] == `HDMI_TARGET_960P  ? `USE_960p50  :
                          ConfigSet[`target_resolution_slice] == `HDMI_TARGET_720P  ? `USE_720p50  :
                          ConfigSet[`target_resolution_slice] == `HDMI_TARGET_576P  ? `USE_576p50  :
                                                                                      `USE_288p50  ;

always @(posedge SYS_CLK) begin
  if (ConfigSet[`force60hz_bit] & !ConfigSet[`lowlatencymode_bit] & (ConfigSet[`target_resolution_slice] != `HDMI_TARGET_288P)) // do not allow forcing 60Hz mode in llm and in 288p mode
    sys_videomode <= sys_vmode_ntsc_w;
  else if (ConfigSet[`force50hz_bit] & !ConfigSet[`lowlatencymode_bit] & (ConfigSet[`target_resolution_slice] != `HDMI_TARGET_240P)) // do not allow forcing 50Hz mode in llm and in 240p mode
    sys_videomode <= sys_vmode_pal_w;
  else begin
    if (palmode)
      sys_videomode <= sys_vmode_pal_w;
    else
      sys_videomode <= sys_vmode_ntsc_w;
  end
end

assign vlines_set_w = ConfigSet[`target_vlines_slice];
assign hpixels_set_w = ConfigSet[`target_resolution_slice] == `HDMI_TARGET_240P ? ConfigSet[`target_hpixels_slice] << 1 : ConfigSet[`target_hpixels_slice];
assign use_interlaced_full_w = n64_480i_sysclk_resynced & ConfigSet[`deinterlacing_mode_bit];

scaler_cfggen scaler_cfggen_u(
  .SYS_CLK(SYS_CLK),
  .palmode_i(palmode_sysclk_resynced),
  .palmode_boxed_i(ConfigSet[`pal_boxed_scale_bit]),
  .use_interlaced_full_i(use_interlaced_full_w),
  .nvideblur_i(cfg_nvideblur_sysclk_resynced),
  .video_config_i(sys_videomode),
  .vlines_out_i(vlines_set_w),
  .hpixels_out_i(hpixels_set_w),
  .vpos_1st_rdline_o(cfg_vpos_1st_rdline_w),
  .vlines_in_needed_o(cfg_vlines_in_needed_w),
  .vlines_in_full_o(cfg_vlines_in_full_w),
  .vlines_out_o(cfg_vlines_out_w),
  .v_interp_factor_o(cfg_v_interp_factor_w),
  .hpos_1st_rdpixel_o(cfg_hpos_1st_rdpixel_w),
  .hpixels_in_needed_o(cfg_hpixel_in_needed_w),
  .hpixels_in_full_o(cfg_hpixel_in_full_w),
  .hpixels_out_o(cfg_hpixels_out_w),
  .h_interp_factor_o(cfg_h_interp_factor_w)
);

// setup config in different clock domains ...

// ... in N64_CLK_i
register_sync #(
  .reg_width(17), // 4 + 1 + 10 + 1 + 1
  .reg_preset(17'd0)
) cfg_sync4n64clk_u0 (
  .clk(N64_CLK_i),
  .clk_en(1'b1),
  .nrst(1'b1),
  .reg_i({ConfigSet[`gamma_slice],~ConfigSet[`n16bit_mode_bit],ConfigSet[`hshift_slice],ConfigSet[`vshift_slice],~ConfigSet[`deinterlacing_mode_bit],~ConfigSet[`videblur_bit]}),
  .reg_o({cfg_gamma              ,cfg_n16bit_mode             ,cfg_hvshift                                      ,cfg_bob_deinterlacing_mode            ,cfg_nvideblur_pre})
); // Note: add output reg as false path in sdc (cfg_sync4n64clk_u0|reg_synced_1[*])

always @(*)
  if (!n64_480i)
    cfg_nvideblur <= cfg_nvideblur_pre;
  else
    cfg_nvideblur <= 1'b1;


// ... in DRAM clock domain
register_sync #(
  .reg_width(11),  // 10 + 1
  .reg_preset(11'd0)
) cfg_sync4dramlogic_u0 (
  .clk(DRAM_CLK_i),
  .clk_en(1'b1),
  .nrst(1'b1),
  .reg_i({cfg_vpos_1st_rdline_w       ,ConfigSet[`deinterlacing_mode_bit]}),
  .reg_o({cfg_vpos_1st_rdline_resynced,cfg_deinterlacing_mode_dramclk_resynced})
); // Note: add output reg as false path in sdc (cfg_sync4dramlogic_u0|reg_synced_1[*])

register_sync_2 #(
  .reg_width(2),
  .reg_preset(2'd0),
  .resync_stages(3)
) cfg_sync4dramlogic_u1 (
  .nrst(1'b1),
  .clk_i(N64_CLK_i),
  .clk_i_en(1'b1),
  .reg_i(vinfo_pass),
  .clk_o(DRAM_CLK_i),
  .clk_o_en(1'b1),
  .reg_o({palmode_dramclk_resynced,n64_480i_dramclk_resynced})
);


// ... in VCLK_Tx clock domain
register_sync #(
  .reg_width(50), // 1 + 10 + 10 + 11 + 18
  .reg_preset(50'd0)
) cfg_sync4txlogic_u0 (
  .clk(VCLK_Tx),
  .clk_en(1'b1),
  .nrst(1'b1),
  .reg_i({ConfigSet[`lowlatencymode_bit],cfg_vlines_in_needed_w       ,cfg_vlines_in_full_w       ,cfg_vlines_out_w       ,cfg_v_interp_factor_w       }),
  .reg_o({cfg_lowlatencymode_resynced   ,cfg_vlines_in_needed_resynced,cfg_vlines_in_full_resynced,cfg_vlines_out_resynced,cfg_v_interp_factor_resynced})
); // Note: add output reg as false path in sdc (cfg_sync4txlogic_u0|reg_synced_1[*])

register_sync #(
  .reg_width(60), // 10 + 10 + 10 + 12 + 18
  .reg_preset({(60){1'b0}})
) cfg_sync4txlogic_u1 (
  .clk(VCLK_Tx),
  .clk_en(1'b1),
  .nrst(1'b1),
  .reg_i({cfg_hpos_1st_rdpixel_w       ,cfg_hpixel_in_needed_w       ,cfg_hpixel_in_full_w       ,cfg_hpixels_out_w       ,cfg_h_interp_factor_w       }),
  .reg_o({cfg_hpos_1st_rdpixel_resynced,cfg_hpixel_in_needed_resynced,cfg_hpixel_in_full_resynced,cfg_hpixels_out_resynced,cfg_h_interp_factor_resynced})
); // Note: add output reg as false path in sdc (cfg_sync4txlogic_u1|reg_synced_1[*])

register_sync_2 #(
  .reg_width(2),
  .reg_preset(2'd0),
  .resync_stages(3)
) cfg_sync4txlogic_u2 (
  .nrst(1'b1),
  .clk_i(N64_CLK_i),
  .clk_i_en(1'b1),
  .reg_i(vinfo_pass),
  .clk_o(VCLK_Tx),
  .clk_o_en(1'b1),
  .reg_o({palmode_vclk_o_resynced,n64_480i_vclk_o_resynced})
);

register_sync #(
  .reg_width(`PPUConfig_WordWidth),
  .reg_preset({`PPUConfig_WordWidth{1'b0}})
) cfg_sync4txlogic_u3 (
  .clk(VCLK_Tx),
  .clk_en(1'b1),
  .nrst(1'b1),
  .reg_i(ConfigSet),
  .reg_o(ConfigSet_resynced)
);


assign videomode_ntsc_w = ConfigSet_resynced[`target_resolution_slice] == `HDMI_TARGET_1440P ? `USE_1440p60 :
                          ConfigSet_resynced[`target_resolution_slice] == `HDMI_TARGET_1200P ? `USE_1200p60 :
                          ConfigSet_resynced[`target_resolution_slice] == `HDMI_TARGET_1080P ? `USE_1080p60 :
                          ConfigSet_resynced[`target_resolution_slice] == `HDMI_TARGET_960P  ? `USE_960p60  :
                          ConfigSet_resynced[`target_resolution_slice] == `HDMI_TARGET_720P  ? `USE_720p60  :
                          ConfigSet_resynced[`target_resolution_slice] == `HDMI_TARGET_240P  ? `USE_240p60  :
                          ConfigSet_resynced[`use_vga_for_480p_bit]                          ? `USE_VGAp60  :
                                                                                               `USE_480p60  ;

assign videomode_pal_w =  ConfigSet_resynced[`target_resolution_slice] == `HDMI_TARGET_1440P ? `USE_1440p50 :
                          ConfigSet_resynced[`target_resolution_slice] == `HDMI_TARGET_1200P ? `USE_1200p50 :
                          ConfigSet_resynced[`target_resolution_slice] == `HDMI_TARGET_1080P ? `USE_1080p50 :
                          ConfigSet_resynced[`target_resolution_slice] == `HDMI_TARGET_960P  ? `USE_960p50  :
                          ConfigSet_resynced[`target_resolution_slice] == `HDMI_TARGET_720P  ? `USE_720p50  :
                          ConfigSet_resynced[`target_resolution_slice] == `HDMI_TARGET_576P  ? `USE_576p50  :
                                                                                               `USE_288p50  ;

always @(posedge VCLK_Tx) begin
  if (ConfigSet_resynced[`force60hz_bit] & !ConfigSet_resynced[`lowlatencymode_bit] & (ConfigSet_resynced[`target_resolution_slice] != `HDMI_TARGET_288P)) // do not allow forcing 60Hz mode in llm and in 288p mode
    cfg_videomode <= videomode_ntsc_w;
  else if (ConfigSet_resynced[`force50hz_bit] & !ConfigSet_resynced[`lowlatencymode_bit] & (ConfigSet_resynced[`target_resolution_slice] != `HDMI_TARGET_240P)) // do not allow forcing 50Hz mode in llm and in 240p mode
    cfg_videomode <= videomode_pal_w;
  else begin
    if (palmode_vclk_o_resynced)
      cfg_videomode <= videomode_pal_w;
    else
      cfg_videomode <= videomode_ntsc_w;
  end
  cfg_interpolation_mode <= ConfigSet_resynced[`target_resolution_slice] == `HDMI_TARGET_240P ? 2'b00 : ConfigSet_resynced[`interpolation_mode_slice];
  cfg_pal_boxed <= ConfigSet_resynced[`pal_boxed_scale_bit];
  if (!n64_480i_vclk_o_resynced | ConfigSet_resynced[`v480i_SL_linked_bit]) begin
    cfg_SL_thickness <= ConfigSet_resynced[`v240p_SL_thickness_bit];
    cfg_SL_profile   <= ConfigSet_resynced[`v240p_SL_profile_slice];
    cfg_SLHyb_str    <= ConfigSet_resynced[`v240p_SL_hybrid_slice];
    cfg_SL_str       <= ((ConfigSet_resynced[`v240p_SL_str_slice]+8'h01)<<4)-1'b1;
    cfg_SL_v_en      <= ConfigSet_resynced[`v240p_SL_V_En_bit];
    cfg_SL_h_en      <= ConfigSet_resynced[`v240p_SL_H_En_bit];
  end else begin
    cfg_SL_thickness <= ConfigSet_resynced[`v480i_SL_thickness_bit];
    cfg_SL_profile   <= ConfigSet_resynced[`v480i_SL_profile_slice];
    cfg_SLHyb_str    <= ConfigSet_resynced[`v480i_SL_hybrid_slice];
    cfg_SL_str       <= ((ConfigSet_resynced[`v480i_SL_str_slice]+8'h01)<<4)-1'b1;
    cfg_SL_v_en      <= ConfigSet_resynced[`v480i_SL_V_En_bit];
    cfg_SL_h_en      <= ConfigSet_resynced[`v480i_SL_H_En_bit];
  end
  
  setVideoSYNCactive(cfg_videomode,cfg_active_vsync,cfg_active_hsync);
  setOSDConfig(cfg_videomode,cfg_osd_vscale,cfg_osd_hscale,cfg_osd_voffset,cfg_osd_hoffset);
  
  cfg_limitedRGB <= ConfigSet_resynced[`limitedRGB_bit];
end

register_sync #(
  .reg_width(2),
  .reg_preset(2'b00)
) sync4cpu_u(
  .clk(VCLK_Tx),
  .clk_en(1'b1),
  .nrst(nVRST_Tx),
  .reg_i(OSDInfo),
  .reg_o(OSDInfo_resynced)
);


// get vinfo
// =========

n64_vinfo_ext get_vinfo_u(
  .VCLK(N64_CLK_i),
  .nRST(N64_nVRST_i),
  .nVDSYNC(nVDSYNC_i),
  .Sync_pre(vdata_bwd_sy_w),
  .Sync_cur(VD_i[3:0]),
  .vinfo_o(vinfo_pass)
);


// video data demux
// ================

n64a_vdemux video_demux_u(
  .VCLK(N64_CLK_i),
  .nRST(N64_nVRST_i),
  .nVDSYNC(nVDSYNC_i),
  .VD_i(VD_i),
  .demuxparams_i({palmode,cfg_nvideblur,cfg_n16bit_mode}),
  .vdata_valid_0(vdata_valid_bwd_w),
  .vdata_r_sy_0(vdata_bwd_sy_w),
  .vdata_valid_1(vdata_valid_fwd_w),
  .vdata_r_1(vdata_fwd_w)
);



assign vdata_valid_pp_w[0] = vdata_valid_fwd_w;
assign vdata21_pp_w = vdata_fwd_w;


// Post-Processing
// ===============

// Gamma Correction
// ----------------

gamma_module_v2 gamma_module_u(
  .VCLK(N64_CLK_i),
  .nRST(N64_nVRST_i),
  .gammaparams_i(cfg_gamma),
  .vdata_valid_i(vdata_valid_pp_w[0]),
  .vdata_i(vdata21_pp_w),
  .vdata_valid_o(vdata_valid_pp_w[1]),
  .vdata_o(vdata24_pp_w[1])
);


// Scaler
// ------

always @(posedge N64_CLK_i) begin
  palmode_change <= palmode_buf[3] ^ palmode;
  palmode_buf <= {palmode_buf[2:0],palmode};
end

assign async_nRST_scaler_w = N64_nVRST_i & DRAM_nRST_i & nVRST_Tx & scaler_nresync_i & ~palmode_change;

scaler scaler_u(
  .async_nRST_i(async_nRST_scaler_w),
  .VCLK_i(N64_CLK_i),
  .vinfo_i(vinfo_pass),
  .vdata_i(vdata24_pp_w[1]),
  .vdata_valid_i(vdata_valid_pp_w[1]),
  .vdata_hvshift_i(cfg_hvshift),
  .vdata_bob_deinterlacing_mode_i(cfg_bob_deinterlacing_mode),
  .DRAM_CLK_i(DRAM_CLK_i),
  .DRAM_nRST_i(DRAM_nRST_i),
  .DRAM_ADDR(DRAM_ADDR),
  .DRAM_BA(DRAM_BA),
  .DRAM_nCAS(DRAM_nCAS),
  .DRAM_CKE(DRAM_CKE),
  .DRAM_nCS(DRAM_nCS),
  .DRAM_DQ(DRAM_DQ),
  .DRAM_DQM(DRAM_DQM),
  .DRAM_nRAS(DRAM_nRAS),
  .DRAM_nWE(DRAM_nWE),
  .vinfo_dramsynced_i({palmode_dramclk_resynced,n64_480i_dramclk_resynced}),
  .video_deinterlacing_mode_i(cfg_deinterlacing_mode_dramclk_resynced),
  .video_vpos_1st_rdline_i(cfg_vpos_1st_rdline_resynced),
  .VCLK_o(VCLK_Tx),
  .vinfo_txsynced_i({palmode_vclk_o_resynced,n64_480i_vclk_o_resynced}),
  .video_config_i(cfg_videomode),
  .video_llm_i(cfg_lowlatencymode_resynced),
  .video_interpolation_mode_i(cfg_interpolation_mode),
  .video_pal_boxed_i(cfg_pal_boxed),
  .vinfo_llm_slbuf_fb_o(PPUState[`PPU_output_llm_slbuf_slice]),
  .video_vlines_in_needed_i(cfg_vlines_in_needed_resynced),
  .video_vlines_in_full_i(cfg_vlines_in_full_resynced),
  .video_vlines_out_i(cfg_vlines_out_resynced),
  .video_v_interpfactor_i(cfg_v_interp_factor_resynced),
  .video_hpos_1st_rdpixel_i(cfg_hpos_1st_rdpixel_resynced),
  .video_hpixel_in_needed_i(cfg_hpixel_in_needed_resynced),
  .video_hpixel_in_full_i(cfg_hpixel_in_full_resynced),
  .video_hpixel_out_i(cfg_hpixels_out_resynced),
  .video_h_interpfactor_i(cfg_h_interp_factor_resynced),
  .scale_vpos_rel_o(sl_vpos_rel_w),
  .scale_hpos_rel_o(sl_hpos_rel_w),
  .HSYNC_o(vdata24_pp_w[2][3*color_width_o+1]),
  .VSYNC_o(vdata24_pp_w[2][3*color_width_o+3]),
  .DE_o(vdata24_pp_w[2][3*color_width_o+2]),
  .vdata_o(vdata24_pp_w[2][`VDATA_O_CO_SLICE])
);


// Scanline emulation
// ==================

scanline_emu #(
  .FALSE_PATH_STR_CORRECTION("OFF")
) vertical_scanline_emu_u (
  .VCLK_i(VCLK_Tx),
  .nVRST_i(nVRST_Tx),
  .HSYNC_i(vdata24_pp_w[2][3*color_width_o+1]),
  .VSYNC_i(vdata24_pp_w[2][3*color_width_o+3]),
  .DE_i(vdata24_pp_w[2][3*color_width_o+2]),
  .vdata_i(vdata24_pp_w[2][`VDATA_O_CO_SLICE]),
  .sl_en_i(cfg_SL_v_en),
  .sl_thickness_i(cfg_SL_thickness),
  .sl_profile_i(cfg_SL_profile),
  .sl_rel_pos_i(sl_hpos_rel_w),
  .sl_strength_i(cfg_SL_str),
  .sl_bloom_i(cfg_SLHyb_str),
  .HSYNC_o(vdata24_pp_w[3][3*color_width_o+1]),
  .VSYNC_o(vdata24_pp_w[3][3*color_width_o+3]),
  .DE_o(vdata24_pp_w[3][3*color_width_o+2]),
  .vdata_o(vdata24_pp_w[3][`VDATA_O_CO_SLICE])
);

scanline_emu #(
  .FALSE_PATH_STR_CORRECTION("ON")
) horizontal_scanline_emu_u (
  .VCLK_i(VCLK_Tx),
  .nVRST_i(nVRST_Tx),
  .HSYNC_i(vdata24_pp_w[3][3*color_width_o+1]),
  .VSYNC_i(vdata24_pp_w[3][3*color_width_o+3]),
  .DE_i(vdata24_pp_w[3][3*color_width_o+2]),
  .vdata_i(vdata24_pp_w[3][`VDATA_O_CO_SLICE]),
  .sl_en_i(cfg_SL_h_en),
  .sl_thickness_i(cfg_SL_thickness),
  .sl_profile_i(cfg_SL_profile),
  .sl_rel_pos_i(sl_vpos_rel_w),
  .sl_strength_i(cfg_SL_str),
  .sl_bloom_i(cfg_SLHyb_str),
  .HSYNC_o(vdata24_pp_w[4][3*color_width_o+1]),
  .VSYNC_o(vdata24_pp_w[4][3*color_width_o+3]),
  .DE_o(vdata24_pp_w[4][3*color_width_o+2]),
  .vdata_o(vdata24_pp_w[4][`VDATA_O_CO_SLICE])
);


// OSD Menu Injection
// ==================

osd_injection #(
  .flavor("N64Adv2"),
  .bits_per_color(color_width_o),
  .vcnt_width(11),
  .hcnt_width(12)
) osd_injection_u (
  .OSDCLK(SYS_CLK),
  .OSD_VSync(OSD_VSync),
  .OSDWrVector(OSDWrVector),
  .OSDInfo(OSDInfo_resynced),
  .VCLK(VCLK_Tx),
  .nVRST(nVRST_Tx),
  .osd_vscale(cfg_osd_vscale),
  .osd_hscale(cfg_osd_hscale),
  .osd_voffset(cfg_osd_voffset),
  .osd_hoffset(cfg_osd_hoffset),
  .vdata_valid_i(1'b1),
  .vdata_i(vdata24_pp_w[4]),
  .active_vsync_i(cfg_active_vsync),
  .active_hsync_i(cfg_active_hsync),
  .vdata_valid_o(vdata_valid_pp_dummy_w_4),
  .vdata_o(vdata24_pp_w[5])
);


// limit RGB range and
// register final outputs
// ======================

assign limited_Re_pre = vdata24_pp_w[5][`VDATA_O_RE_SLICE] * (* multstyle = "dsp" *) limitRGB_coeff;
assign limited_Gr_pre = vdata24_pp_w[5][`VDATA_O_GR_SLICE] * (* multstyle = "dsp" *) limitRGB_coeff;
assign limited_Bl_pre = vdata24_pp_w[5][`VDATA_O_BL_SLICE] * (* multstyle = "dsp" *) limitRGB_coeff;

always @(posedge VCLK_Tx or negedge nVRST_Tx)
  if (!nVRST_Tx) begin
    limited_Re_pre_LL <= {color_width_o{1'b0}};
    limited_Gr_pre_LL <= {color_width_o{1'b0}};
    limited_Bl_pre_LL <= {color_width_o{1'b0}};
    limited_Re_pre_L <= {(color_width_o+1){1'b0}};
    limited_Gr_pre_L <= {(color_width_o+1){1'b0}};
    limited_Bl_pre_L <= {(color_width_o+1){1'b0}};
    
    full_RGB_pre_LL <= {3*color_width_o{1'b0}};
    full_RGB_pre_L <= {3*color_width_o{1'b0}};
    
    VSYNC_pre_LL <= 1'b0;
    HSYNC_pre_LL <= 1'b0;
       DE_pre_LL <= 1'b0;
    VSYNC_pre_L <= 1'b0;
    HSYNC_pre_L <= 1'b0;
       DE_pre_L <= 1'b0;
    
    VSYNC_o <= 1'b0;
    HSYNC_o <= 1'b0;
       DE_o <= 1'b0;
       VD_o <= {3*color_width_o{1'b0}};
  end else begin
    limited_Re_pre_LL <= limited_Re_pre_L[color_width_o:1] + limited_Re_pre_L[0];
    limited_Gr_pre_LL <= limited_Gr_pre_L[color_width_o:1] + limited_Gr_pre_L[0];
    limited_Bl_pre_LL <= limited_Bl_pre_L[color_width_o:1] + limited_Bl_pre_L[0];
    limited_Re_pre_L <= limited_Re_pre[2*color_width_o-1:2*color_width_o-9];
    limited_Gr_pre_L <= limited_Gr_pre[2*color_width_o-1:2*color_width_o-9];
    limited_Bl_pre_L <= limited_Bl_pre[2*color_width_o-1:2*color_width_o-9];
    
    full_RGB_pre_LL <= full_RGB_pre_L;
    full_RGB_pre_L <= vdata24_pp_w[5][`VDATA_O_CO_SLICE];
    
    VSYNC_pre_LL <= VSYNC_pre_L;
    HSYNC_pre_LL <= HSYNC_pre_L;
       DE_pre_LL <= DE_pre_L;
    VSYNC_pre_L <= vdata24_pp_w[5][3*color_width_o+3];
    HSYNC_pre_L <= vdata24_pp_w[5][3*color_width_o+1];
       DE_pre_L <= vdata24_pp_w[5][3*color_width_o+2];
    
    VSYNC_o <= VSYNC_pre_LL;
    HSYNC_o <= HSYNC_pre_LL;
       DE_o <= DE_pre_LL;
    if (cfg_limitedRGB) begin
      VD_o[`VDATA_O_RE_SLICE] <= {limited_Re_pre_LL[color_width_o-1:4] + 1'b1,limited_Re_pre_LL[3:0]};
      VD_o[`VDATA_O_GR_SLICE] <= {limited_Gr_pre_LL[color_width_o-1:4] + 1'b1,limited_Gr_pre_LL[3:0]};
      VD_o[`VDATA_O_BL_SLICE] <= {limited_Bl_pre_LL[color_width_o-1:4] + 1'b1,limited_Bl_pre_LL[3:0]};
    end else begin
      VD_o <= full_RGB_pre_LL;
    end
  end

endmodule
