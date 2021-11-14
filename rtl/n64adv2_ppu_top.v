//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the N64 RGB/YPbPr DAC project.
//
// Copyright (C) 2016-2019 by Peter Bartmann <borti4938@gmx.de>
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
  // Note: SYSCLK is System clock (Nios II)
  PPUState,
  ConfigSet,

  SYSCLK,
  
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


`include "../vh/n64adv_cparams.vh"
`include "../vh/n64adv_vparams.vh"
`include "../vh/n64adv2_config.vh"
`include "../vh/videotimings.vh"

input N64_CLK_i;
input N64_nVRST_i;
input nVDSYNC_i;
input [color_width_i-1:0] VD_i;

output [`PPU_State_Width-1:0] PPUState;
input  [`PPUConfig_WordWidth-1:0] ConfigSet;

input        SYSCLK;

output       OSD_VSync;
input [24:0] OSDWrVector;
input [ 1:0] OSDInfo;

input scaler_nresync_i;

input VCLK_Tx;
input nVRST_Tx;

//output reg VSYNC_o = 1'b0                                       /* synthesis ALTERA_ATTRIBUTE = "FAST_OUTPUT_REGISTER=ON" */;
//output reg HSYNC_o = 1'b0                                       /* synthesis ALTERA_ATTRIBUTE = "FAST_OUTPUT_REGISTER=ON" */;
//output reg DE_o = 1'b0                                          /* synthesis ALTERA_ATTRIBUTE = "FAST_OUTPUT_REGISTER=ON" */;
//output reg [3*color_width_o-1:0] VD_o = {3*color_width_o{1'b0}} /* synthesis ALTERA_ATTRIBUTE = "FAST_OUTPUT_REGISTER=ON" */;

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
wire cfg_lowlatencymode;
wire [11:0] cfg_hvshift;

wire palmode_resynced, n64_480i_resynced;

wire [`PPUConfig_WordWidth-1:0] ConfigSet_resynced;

wire vdata_valid_bwd_w, vdata_valid_fwd_w;
wire [`VDATA_I_SY_SLICE] vdata_bwd_sy_w;
wire [`VDATA_I_FU_SLICE] vdata_fwd_w;

wire vdata_valid_pp_w[0:1], vdata_valid_pp_dummy_w_4;
wire [`VDATA_I_FU_SLICE] vdata21_pp_w;
wire [`VDATA_O_FU_SLICE] vdata24_pp_w[1:4];

wire async_nRST_scaler_w;
wire [2:0] drawSL_w;

wire [1:0] OSDInfo_resynced;

wire [15:0] limited_Re_pre, limited_Gr_pre, limited_Bl_pre;

//regs
reg cfg_nvideblur;

reg [`VID_CFG_W-1:0] cfg_videomode;
reg [1:0] cfg_interpolation_mode;
reg [4:0] cfg_vscale_factor;
reg [4:0] cfg_hscale_factor;
reg cfg_pal_boxed;
reg cfg_SL_method, cfg_SL_id, cfg_SL_en;
reg [1:0] cfg_SL_thickness;
reg [ 4:0] cfg_SLHyb_str;
reg [ 7:0] cfg_SL_str;

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

// to N64_CLK_i first
register_sync #(
  .reg_width(19), // 4 + 1 + 1 + 12 + 1
  .reg_preset(19'd0)
) cfg_sync4n64clk_u0 (
  .clk(N64_CLK_i),
  .clk_en(1'b1),
  .nrst(1'b1),
  .reg_i({ConfigSet[`gamma_slice],~ConfigSet[`n16bit_mode_bit],ConfigSet[`lowlatencymode_bit],ConfigSet[`hshift_slice],ConfigSet[`vshift_slice],~ConfigSet[`videblur_bit]}),
  .reg_o({cfg_gamma,cfg_n16bit_mode,cfg_lowlatencymode,cfg_hvshift,cfg_nvideblur_pre})
);

always @(*)
  if (!n64_480i)
    cfg_nvideblur      <= cfg_nvideblur_pre;
  else
    cfg_nvideblur        <= 1'b1;


// to VCLK_Tx clock domain 
register_sync_2 #(
  .reg_width(2),
  .reg_preset(2'd0),
  .resync_stages(3)
) sync4txlogic_u0 (
  .nrst(1'b1),
  .clk_i(N64_CLK_i),
  .clk_i_en(1'b1),
  .reg_i(vinfo_pass),
  .clk_o(VCLK_Tx),
  .clk_o_en(1'b1),
  .reg_o({palmode_resynced,n64_480i_resynced})
);

register_sync #(
  .reg_width(`PPUConfig_WordWidth),
  .reg_preset({`PPUConfig_WordWidth{1'b0}})
) sync4txlogic_u1 (
  .clk(VCLK_Tx),
  .clk_en(1'b1),
  .nrst(1'b1),
  .reg_i(ConfigSet),
  .reg_o(ConfigSet_resynced)
);

wire [`VID_CFG_W-1:0] videomode_ntsc_w = ConfigSet_resynced[`target_resolution_slice] == `HDMI_TARGET_1200P ? `USE_1200p60 :
                                         ConfigSet_resynced[`target_resolution_slice] == `HDMI_TARGET_1080P ? `USE_1080p60 :
                                         ConfigSet_resynced[`target_resolution_slice] == `HDMI_TARGET_960P  ? `USE_960p60  :
                                         ConfigSet_resynced[`target_resolution_slice] == `HDMI_TARGET_720P  ? `USE_720p60  :
                                         ConfigSet_resynced[`use_vga_for_480p_bit]                          ? `USE_VGAp60  :
                                                                                                              `USE_480p60  ;

wire [`VID_CFG_W-1:0] videomode_pal_w = ConfigSet_resynced[`target_resolution_slice] == `HDMI_TARGET_1200P ? `USE_1200p50 :
                                        ConfigSet_resynced[`target_resolution_slice] == `HDMI_TARGET_1080P ? `USE_1080p50 :
                                        ConfigSet_resynced[`target_resolution_slice] == `HDMI_TARGET_960P  ? `USE_960p50  :
                                        ConfigSet_resynced[`target_resolution_slice] == `HDMI_TARGET_720P  ? `USE_720p50  :
                                                                                                             `USE_576p50  ;

always @(posedge VCLK_Tx) begin
  if (ConfigSet_resynced[`force60hz_bit] & !ConfigSet_resynced[`lowlatencymode_bit]) // do not allow forcing 60Hz mode in llm
    cfg_videomode <= videomode_ntsc_w;
  else if (ConfigSet_resynced[`force50hz_bit] & !ConfigSet_resynced[`lowlatencymode_bit]) // do not allow forcing 50Hz mode in llm
    cfg_videomode <= videomode_pal_w;
  else begin
    if (palmode_resynced)
      cfg_videomode <= videomode_pal_w;
    else
      cfg_videomode <= videomode_ntsc_w;
  end
  cfg_interpolation_mode <= ConfigSet_resynced[`interpolation_mode_slice];
  cfg_vscale_factor <= ConfigSet_resynced[`vscale_slice];
  if (ConfigSet_resynced[`link_hv_scale_bit])
    cfg_hscale_factor <= ConfigSet_resynced[`vscale_slice];
  else
    cfg_hscale_factor <= ConfigSet_resynced[`hscale_slice];
  cfg_pal_boxed <= ConfigSet_resynced[`pal_boxed_scale_bit];
  if (cfg_vscale_factor < 5'h06) // less than 3.5x
    cfg_SL_thickness <= 2'b00;
  else if (cfg_vscale_factor < 5'h0E) // less than 5.5x
    cfg_SL_thickness <= 2'b01;
  else
    cfg_SL_thickness <= 2'b10;  
  if (!n64_480i_resynced) begin
    cfg_SLHyb_str    <= ConfigSet[`v240p_SL_hybrid_slice];
    cfg_SL_str       <= ((ConfigSet_resynced[`v240p_SL_str_slice]+8'h01)<<4)-1'b1;
    cfg_SL_method    <= ConfigSet[`v240p_SL_method_bit];
    cfg_SL_id        <= ConfigSet[`v240p_SL_ID_bit];
    cfg_SL_en        <= ConfigSet[`v240p_SL_En_bit];
  end else begin
    if (ConfigSet[`v480i_SL_linked_bit]) begin // check if SL mode is linked to 240p
      cfg_SLHyb_str    <= ConfigSet[`v240p_SL_hybrid_slice];
      cfg_SL_str        <= ((ConfigSet_resynced[`v240p_SL_str_slice]+8'h01)<<4)-1'b1;
      cfg_SL_id        <= ConfigSet[`v240p_SL_ID_bit];
    end else begin
      cfg_SLHyb_str    <= ConfigSet[`v480i_SL_hybrid_slice];
      cfg_SL_str        <= ((ConfigSet_resynced[`v480i_SL_str_slice]+8'h01)<<4)-1'b1;
      cfg_SL_id        <= ConfigSet[`v480i_SL_ID_bit];
    end
    cfg_SL_method    <= 1'b0;
    cfg_SL_en        <= ConfigSet[`v480i_SL_En_bit];
  end
  case (cfg_videomode)
    `USE_VGAp60: begin
      cfg_osd_vscale <= 3'b001;
      cfg_osd_hscale <= 2'b00;
      cfg_osd_voffset <=  59;   // (`VSYNCLEN_VGA + `VBACKPORCH_VGA + (`VACTIVE_VGA - 2*`OSD_WINDOW_VACTIVE)/2)/2
                                // = (2 + 33 +(480 - 2*156)/2)/2 = 119/2 = 59,5
      cfg_osd_hoffset <=  248;  // `HSYNCLEN_VGA + `HBACKPORCH_VGA + (`HACTIVE_VGA - `OSD_WINDOW_HACTIVE)/2
                                // = 96 + 48 + (640-431)/2 = 248,5
      cfg_active_vsync <= `VSYNC_active_VGA;
      cfg_active_hsync <= `HSYNC_active_VGA;
     end
    `USE_720p60: begin
      cfg_osd_vscale <= 3'b010;
      cfg_osd_hscale <= 2'b01;
      cfg_osd_voffset <= 50;  // (`VSYNCLEN_720p60 + `VBACKPORCH_720p60 + (`VACTIVE_720P60 - 3*`OSD_WINDOW_VACTIVE)/2)/3;
                              // = (5 + 20 + (720 - 3*156)/2)/3 = 151/3 = 50,3
      cfg_osd_hoffset <= 234; // (`HSYNCLEN_720p60 + `HBACKPORCH_720p60 + (`HACTIVE_720P60 - 2*`OSD_WINDOW_HACTIVE)/2)/2
                              // = (40 + 220 + (1280 - 2*431)/2)/2 = 469/2 = 234,5
      cfg_active_vsync <= `VSYNC_active_720p60;
      cfg_active_hsync <= `HSYNC_active_720p60;
     end
    `USE_960p60: begin
      cfg_osd_vscale <= 3'b011;
      cfg_osd_hscale <= 2'b01;
      cfg_osd_voffset <= 48;  // (`VSYNCLEN_960p60 + `VBACKPORCH_960p60 + (`VACTIVE_960P60 - 5*`OSD_WINDOW_VACTIVE)/2)/4;
                              // = (4 + 21 + (960 - 4*156)/2)/4 = 193/4 = 48,25
      cfg_osd_hoffset <= 160; // (`HSYNCLEN_960p60 + `HBACKPORCH_960p60 + (`HACTIVE_960P60 - 2*`OSD_WINDOW_HACTIVE)/2)/2
                              // = (32 + 80 + (1280 - 2*431)/2)/2 = 321/2 = 160,5
      cfg_active_vsync <= `VSYNC_active_720p60;
      cfg_active_hsync <= `HSYNC_active_720p60;
     end
    `USE_1080p60: begin
      cfg_osd_vscale <= 3'b100;
      cfg_osd_hscale <= 2'b10;
      cfg_osd_voffset <= 38;  // (`VSYNCLEN_1080p60 + `VBACKPORCH_1080p60 + (`VACTIVE_1080P60 - 5*`OSD_WINDOW_VACTIVE)/2)/5
                              // = (5 + 36 + (1080 - 5*156)/2)/5 = 191/5 = 38,2
      cfg_osd_hoffset <= 168; // (`HSYNCLEN_1080p60 + `HBACKPORCH_1080p60 + (`HACTIVE_1080P60 - 3*`OSD_WINDOW_HACTIVE)/2)/3
                              // = (44 + 148 + (1920 - 3*431)/2)/3 = 505,5/3 = 168,5
      cfg_active_vsync <= `VSYNC_active_1080p60;
      cfg_active_hsync <= `HSYNC_active_1080p60;
     end
    `USE_1200p60: begin
      cfg_osd_vscale <= 3'b100;
      cfg_osd_hscale <= 2'b10;
      cfg_osd_voffset <= 48;  // (`VSYNCLEN_1200p60 + `VBACKPORCH_1200p60 + (`VACTIVE_1200P60 - 5*`OSD_WINDOW_VACTIVE)/2)/5
                              // = (4 + 28 + (1200 - 5*156)/2)/5 = 242/5 = 48,4
      cfg_osd_hoffset <= 88;  // (`HSYNCLEN_1200p60 + `HBACKPORCH_1200p60 + (`HACTIVE_1200P60 - 3*`OSD_WINDOW_HACTIVE)/2)/3
                              // = (32 + 80 + (1600 - 3*431)/2)/3 = 265,5/3 = 88,5
      cfg_active_vsync <= `VSYNC_active_1080p60;
      cfg_active_hsync <= `HSYNC_active_1080p60;
     end
    `USE_720p50: begin
      cfg_osd_vscale <= 3'b010;
      cfg_osd_hscale <= 2'b01;
      cfg_osd_voffset <= 50;  // (`VSYNCLEN_720p50 + `VBACKPORCH_720p50 + (`VACTIVE_720P50 - 3*`OSD_WINDOW_VACTIVE)/2)/3;
                              // = (5 + 20 + (720 - 3*156)/2)/3 = 151/3 = 50,3
      cfg_osd_hoffset <= 234; // (`HSYNCLEN_720p50 + `HBACKPORCH_720p50 + (`HACTIVE_720P50 - 2*`OSD_WINDOW_HACTIVE)/2)/2
                              // = (40 + 220 + (1280 - 2*431)/2)/2 = 469/2 = 234,5
      cfg_active_vsync <= `VSYNC_active_720p50;
      cfg_active_hsync <= `HSYNC_active_720p50;
     end
    `USE_960p50: begin
      cfg_osd_vscale <= 3'b011;
      cfg_osd_hscale <= 2'b01;
      cfg_osd_voffset <= 48;  // (`VSYNCLEN_960p50 + `VBACKPORCH_960p50 + (`VACTIVE_960P50 - 2*`OSD_WINDOW_VACTIVE)/2)/2;
                              // = (4 + 21 + (960 - 4*156)/2)/4 = 193/4 = 48,25
      cfg_osd_hoffset <= 160; // (`HSYNCLEN_960p50 + `HBACKPORCH_960p50 + (`HACTIVE_960P50 - 2*`OSD_WINDOW_HACTIVE)/2)/2
                              // = (32 + 80 + (1280 - 2*431)/2)/2 = 321/2 = 160,5
      cfg_active_vsync <= `VSYNC_active_720p50;
      cfg_active_hsync <= `HSYNC_active_720p50;
     end
    `USE_1080p50: begin
      cfg_osd_vscale <= 3'b011;
      cfg_osd_hscale <= 2'b10;
      cfg_osd_voffset <= 67;  // (`VSYNCLEN_1080p50 + `VBACKPORCH_1080p50 + (`VACTIVE_1080P50 - 4*`OSD_WINDOW_VACTIVE)/2)/4
                              // = (5 + 36 + (1080 - 4*156)/2)/4 = 269/4 = 67,25
      cfg_osd_hoffset <= 168; // (`HSYNCLEN_1080p50 + `HBACKPORCH_1080p50 + (`HACTIVE_1080P50 - 3*`OSD_WINDOW_HACTIVE)/2)/3
                              // = (44 + 148 + (1920 - 3*431)/2)/3 = 505,5/3 = 168,5
      cfg_active_vsync <= `VSYNC_active_1080p50;
      cfg_active_hsync <= `HSYNC_active_1080p50;
     end
    `USE_1200p50: begin
      cfg_osd_vscale <= 3'b100;
      cfg_osd_hscale <= 2'b10;
      cfg_osd_voffset <= 48;  // (`VSYNCLEN_1200p50 + `VBACKPORCH_1200p50 + (`VACTIVE_1200P50 - 5*`OSD_WINDOW_VACTIVE)/2)/5
                              // = (4 + 28 + (1200 - 5*156)/2)/5 = 242/5 = 48,4
      cfg_osd_hoffset <= 88;  // (`HSYNCLEN_1200p50 + `HBACKPORCH_1200p50 + (`HACTIVE_1200P50 - 3*`OSD_WINDOW_HACTIVE)/2)/3
                              // = (32 + 80 + (1600 - 3*431)/2)/3 = 265,5/3 = 88,5
      cfg_active_vsync <= `VSYNC_active_1080p50;
      cfg_active_hsync <= `HSYNC_active_1080p50;
     end
    default: begin
      cfg_osd_vscale <= 3'b001;
      cfg_osd_hscale <= 2'b00;
      if (cfg_videomode[`VID_CFG_50HZ_BIT]) begin
        cfg_osd_voffset <= 88;  // (`VSYNCLEN_576p50 + `VBACKPORCH_576p50 + (`VACTIVE_576p50 - 2*`OSD_WINDOW_VACTIVE)/2)/2
                                // = (5 + 39 + (576 - 2*156)/2)/2 = 176/2 = 88
        cfg_osd_hoffset <= 276; // `HSYNCLEN_576p50 + `HBACKPORCH_576p50 + (`HACTIVE_576p50 - `OSD_WINDOW_HACTIVE)/2
                                // = 64 + 68 + (720 - 431)/2 = 276,5
        cfg_active_vsync <= `VSYNC_active_576p50;
        cfg_active_hsync <= `HSYNC_active_576p50;
      end else begin
        cfg_osd_voffset <= 60;  // (`VSYNCLEN_480p60 + `VBACKPORCH_480p60 + (`VACTIVE_480p60 - 2*`OSD_WINDOW_VACTIVE)/2)/2
                                // = (6 + 30 + (480 - 2*156)/2)/2 = 120/2 = 60
        cfg_osd_hoffset <= 266; // `HSYNCLEN_480p60 + `HBACKPORCH_480p60 + (`HACTIVE_480p60 - `OSD_WINDOW_HACTIVE)/2
                                // = 62 + 60 + (720 - 431)/2 = 266,5
        cfg_active_vsync <= `VSYNC_active_480p60;
        cfg_active_hsync <= `HSYNC_active_480p60;
      end
    end
  endcase
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
  .vdata_hvshift(cfg_hvshift),
  .VCLK_o(VCLK_Tx),
  .video_config_i(cfg_videomode),
  .video_llm_i(cfg_lowlatencymode),
  .video_interpolation_mode_i(cfg_interpolation_mode),
  .video_vscale_factor_i(cfg_vscale_factor),
  .video_hscale_factor_i(cfg_hscale_factor),
  .video_pal_boxed_i(cfg_pal_boxed),
  .vinfo_txsynced_i({palmode_resynced,n64_480i_resynced}),
  .vinfo_llm_slbuf_fb_o(PPUState[`PPU_output_llm_slbuf_slice]),
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
  .drawSL(drawSL_w),
  .HSYNC_o(vdata24_pp_w[2][3*color_width_o+1]),
  .VSYNC_o(vdata24_pp_w[2][3*color_width_o+3]),
  .DE_o(vdata24_pp_w[2][3*color_width_o+2]),
  .vdata_o(vdata24_pp_w[2][`VDATA_O_CO_SLICE])
);


// Scanline emulation
// ==================

scanline_emu scanline_emu_u (
  .VCLK_i(VCLK_Tx),
  .nVRST_i(nVRST_Tx),
  .HSYNC_i(vdata24_pp_w[2][3*color_width_o+1]),
  .VSYNC_i(vdata24_pp_w[2][3*color_width_o+3]),
  .DE_i(vdata24_pp_w[2][3*color_width_o+2]),
  .vdata_i(vdata24_pp_w[2][`VDATA_O_CO_SLICE]),
  .drawSL_i(drawSL_w),
  .sl_settings_i({cfg_SLHyb_str,cfg_SL_str,cfg_SL_thickness,cfg_SL_id,cfg_SL_en}),
  .HSYNC_o(vdata24_pp_w[3][3*color_width_o+1]),
  .VSYNC_o(vdata24_pp_w[3][3*color_width_o+3]),
  .DE_o(vdata24_pp_w[3][3*color_width_o+2]),
  .vdata_o(vdata24_pp_w[3][`VDATA_O_CO_SLICE])
);


// OSD Menu Injection
// ==================

osd_injection #(
  .flavor("N64Adv2"),
  .bits_per_color(color_width_o),
  .vcnt_width(11),
  .hcnt_width(12)
) osd_injection_u (
  .OSDCLK(SYSCLK),
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
  .vdata_i(vdata24_pp_w[3]),
  .active_vsync_i(cfg_active_vsync),
  .active_hsync_i(cfg_active_hsync),
  .vdata_valid_o(vdata_valid_pp_dummy_w_4),
  .vdata_o(vdata24_pp_w[4])
);


// limit RGB range and
// register final outputs
// ======================

assign limited_Re_pre = vdata24_pp_w[4][`VDATA_O_RE_SLICE] * (* multstyle = "dsp" *) limitRGB_coeff;
assign limited_Gr_pre = vdata24_pp_w[4][`VDATA_O_GR_SLICE] * (* multstyle = "dsp" *) limitRGB_coeff;
assign limited_Bl_pre = vdata24_pp_w[4][`VDATA_O_BL_SLICE] * (* multstyle = "dsp" *) limitRGB_coeff;

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
    full_RGB_pre_L <= vdata24_pp_w[4][`VDATA_O_CO_SLICE];
    
    VSYNC_pre_LL <= VSYNC_pre_L;
    HSYNC_pre_LL <= HSYNC_pre_L;
       DE_pre_LL <= DE_pre_L;
    VSYNC_pre_L <= vdata24_pp_w[4][3*color_width_o+3];
    HSYNC_pre_L <= vdata24_pp_w[4][3*color_width_o+1];
       DE_pre_L <= vdata24_pp_w[4][3*color_width_o+2];
    
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
