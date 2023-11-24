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
// Company: Circuit-Board.de
// Engineer: borti4938
//
// VH-file Name:   n64adv2_config
// Project Name:   N64 Advanced Mod
// Target Devices: several devices
// Tool versions:  Altera Quartus Prime
// Description:
//
//////////////////////////////////////////////////////////////////////////////////


`ifndef _n64adv2_config_vh_
`define _n64adv2_config_vh_

  // configuration as defined in n64adv_controller.v (must match software)
  //  wire [15:0] SysConfigSet3; (Audio)
  //    sw: [15: 0] {(6bit reserve),audio_filter_bypass,audio_mute,audio_amp (5bits),audio_swap_lr,audio_spdif_en,hw_reserved}
  //    hw: [15: 0] {(6bit reserve),audio_filter_bypass,audio_mute,audio_amp (5bits),audio_swap_lr,audio_spdif_en,hdmi_en}
  //  wire [31:0] SysConfigSet2; (Scanlines)
  //    [31:30] {(2bits reserved)}
  //    [29:17] vertical:   {Sl_thickness (2bit),Sl_profile (2bits),Sl_hybrid_depth (5bits),Sl_str (4bits)}
  //    [16: 4] horizontal: {Sl_thickness (2bit),Sl_profile (2bits),Sl_hybrid_depth (5bits),Sl_str (4bits)}
  //    [ 3: 0] control:    {Sl_V_En,Sl_H_En,Sl_link,SL_per_Channel}
  //  wire [31:0] SysConfigSet1; (OSD, IGR, VI-Processing)
  //    [31:29] {show_osd_logo,show_osd,mute_osd}
  //    [28   ] {igr for reset}
  //    [27:26] {reset masks (2bit)}
  //    [25]    {(1bit reserved)}
  //    [24:19] {gamma (4bits),VI-DeBlur,16bit mode}
  //    [18: 9] {LineX V-Shift (5bits),LineX H-Shift (5bits)}
  //    [ 8: 0] {De-Interlace Mode (2 bit),(1bit reserve),Vert. Interpolation Mode (2 bits),(1bit reserve),Horiz. Interpolation Mode (2 bits),PAL boxed mode (1 bit)}
  //  wire [31:0] SysConfigSet0; (Scaler)
  //    [31:20] {LineX V-Scale Target (12bits)}
  //    [19: 8] {LineX H-Scale Target (12bits)}
  //    [ 7: 0] {(1bit reserve),Force 50Hz/60Hz (2bits),LowLatencyMode (1bit),UseVGAfor480p (1bit),TargetResolution (3bits)}

  
  
  // OSD
  `define show_osd_logo_bit     31
  `define show_osd_bit          30
  `define mute_osd_bit          29
  
  
  // IGR
  `define igr_reset_enable_bit  28
  
  // Reset Masks
  `define rst_masks_slice           27:26
  `define rst_audio_mask_bit        27
  `define rst_vi_pipeline_mask_bit  26
  
  // Separation slices
  `define cfg3_audio_config_slice    9: 1
  `define cfg2_scanline_slice       29: 0
  `define cfg1_ppu_config_slice     24: 0
  `define cfg0_ppu_config_slice     31: 0
  
  // Audio config
  `define APUConfig_WordWidth       10
  `define audio_filter_bypass_bit    9
  `define audio_mute_bit             8
  `define audio_amp_slice            7: 3
  `define audio_swap_lr_bit          2
  `define audio_spdif_en_bit         1
  `define audio_hdmi_en_bit          0
  
  
  // PPU config
  `define PPUConfig_WordWidth       87  // 30 + 25 + 32
  
  `define SysCfg2_PPUCfg_Offset     57  // 25 + 32
  `define SysCfg1_PPUCfg_Offset     32  // 32
  `define SysCfg0_PPUCfg_Offset      0  // 0
  
  `define vSL_thickness_slice   29 + `SysCfg2_PPUCfg_Offset : 28 + `SysCfg2_PPUCfg_Offset
  `define vSL_profile_slice     27 + `SysCfg2_PPUCfg_Offset : 26 + `SysCfg2_PPUCfg_Offset
  `define vSL_hybrid_slice      25 + `SysCfg2_PPUCfg_Offset : 21 + `SysCfg2_PPUCfg_Offset
  `define vSL_str_slice         20 + `SysCfg2_PPUCfg_Offset : 17 + `SysCfg2_PPUCfg_Offset
  `define hSL_thickness_slice   16 + `SysCfg2_PPUCfg_Offset : 15 + `SysCfg2_PPUCfg_Offset
  `define hSL_profile_slice     14 + `SysCfg2_PPUCfg_Offset : 13 + `SysCfg2_PPUCfg_Offset
  `define hSL_hybrid_slice      12 + `SysCfg2_PPUCfg_Offset :  8 + `SysCfg2_PPUCfg_Offset
  `define hSL_str_slice          7 + `SysCfg2_PPUCfg_Offset :  4 + `SysCfg2_PPUCfg_Offset
  `define vSL_en_bit             3 + `SysCfg2_PPUCfg_Offset
  `define hSL_en_bit             2 + `SysCfg2_PPUCfg_Offset
  `define h2v_SL_linked_bit      1 + `SysCfg2_PPUCfg_Offset
  `define SL_per_Channel_bit     0 + `SysCfg2_PPUCfg_Offset
  
  `define gamma_slice                 24 + `SysCfg1_PPUCfg_Offset : 21 + `SysCfg1_PPUCfg_Offset
  `define videblur_bit                20 + `SysCfg1_PPUCfg_Offset
  `define n16bit_mode_bit             19 + `SysCfg1_PPUCfg_Offset
  `define vshift_slice                18 + `SysCfg1_PPUCfg_Offset : 14 + `SysCfg1_PPUCfg_Offset
  `define hshift_slice                13 + `SysCfg1_PPUCfg_Offset :  9 + `SysCfg1_PPUCfg_Offset
  `define deinterlacing_mode_slice     8 + `SysCfg1_PPUCfg_Offset :  7 + `SysCfg1_PPUCfg_Offset
  `define deinterlacing_mode_bit1      8 + `SysCfg1_PPUCfg_Offset
  `define deinterlacing_mode_bit0      7 + `SysCfg1_PPUCfg_Offset
  `define v_interpolation_mode_slice   5 + `SysCfg1_PPUCfg_Offset :  4 + `SysCfg1_PPUCfg_Offset
  `define h_interpolation_mode_slice   2 + `SysCfg1_PPUCfg_Offset :  1 + `SysCfg1_PPUCfg_Offset
  `define pal_boxed_scale_bit          0 + `SysCfg1_PPUCfg_Offset
  
  `define target_vlines_slice       31 + `SysCfg0_PPUCfg_Offset : 20 + `SysCfg0_PPUCfg_Offset
  `define target_hpixels_slice      19 + `SysCfg0_PPUCfg_Offset :  8 + `SysCfg0_PPUCfg_Offset
  `define force_5060_slice           6 + `SysCfg0_PPUCfg_Offset :  5 + `SysCfg0_PPUCfg_Offset
  `define force50hz_bit              6 + `SysCfg0_PPUCfg_Offset
  `define force60hz_bit              5 + `SysCfg0_PPUCfg_Offset
  `define lowlatencymode_bit         4 + `SysCfg0_PPUCfg_Offset
  `define use_vga_for_480p_bit       3 + `SysCfg0_PPUCfg_Offset
  `define target_resolution_slice    2 + `SysCfg0_PPUCfg_Offset :  0 + `SysCfg0_PPUCfg_Offset
  
  // Tables
  
  `define GAMMA_TABLE_OFF     4'b0101
  `define HDMI_TARGET_240P    3'b000
  `define HDMI_TARGET_288P    3'b000
  `define HDMI_TARGET_480P    3'b001
  `define HDMI_TARGET_576P    3'b001
  `define HDMI_TARGET_720P    3'b010
  `define HDMI_TARGET_960P    3'b011
  `define HDMI_TARGET_1080P   3'b100
  `define HDMI_TARGET_1200P   3'b101
  `define HDMI_TARGET_1440P   3'b110
  `define HDMI_TARGET_1440WP  3'b111
  
  // PPU Feedback Channel
  
  `define PPU_State_Width               26  // without pal pattern bit
  
  `define PPU_input_vdata_detected_bit  25
  `define PPU_input_palpattern_bit      24
  `define PPU_input_pal_bit             23
  `define PPU_input_interlaced_bit      22
  
  `define PPU_output_f5060_slice        21:20
  `define PPU_output_vga_for_480p_bit   19
  `define PPU_output_resolution_slice   18:16
  `define PPU_output_llm_slbuf_slice    15: 7
  `define PPU_output_lowlatencymode_bit  6
  
  `define PPU_240p_deblur_bit            5
  `define PPU_color_16bit_mode_bit       4
  `define PPU_gamma_table_slice          3: 0

`endif
