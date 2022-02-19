//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the N64 RGB/YPbPr DAC project.
//
// Copyright (C) 2015-2022 by Peter Bartmann <borti4938@gmail.com>
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
  //  wire [ 7:0] SysConfigSet3; (Audio)
  //    [ 7: 0] {(1bit reserve),audio_amp (5bits),audio_swap_lr,audio_spdif_en}
  //  wire [31:0] SysConfigSet2; (Scanlines)
  //    [31:29] {(3bits reserved)}
  //    [28:16] vertical:   {Sl_thickness (2bit),Sl_profile (2bits),Sl_hybrid_depth (5bits),Sl_str (4bits)}
  //    [15: 3] horizontal: {Sl_thickness (2bit),Sl_profile (2bits),Sl_hybrid_depth (5bits),Sl_str (4bits)}
  //    [ 2: 0] control:    {Sl_V_En,Sl_H_En,Sl_link}
  //  wire [31:0] SysConfigSet1; (OSD, IGR, VI-Processing)
  //    [31:29] {show_osd_logo,show_osd,mute_osd}
  //    [28   ] {igr for reset}
  //    [27:24] {(4bits reserve)}
  //    [23:17] {limited RGB,gamma (4bits),VI-DeBlur,16bit mode}
  //    [16: 7] {LineX V-Shift (5bits),LineX H-Shift (5bits)}
  //    [ 6: 0] {(1bit reserve),De-Interlace Mode (1 bit),Vert. Interpolation Mode (2 bits),Horiz. Interpolation Mode (2 bits),PAL boxed mode (1 bit)}
  //  wire [31:0] SysConfigSet0; (Scaler)
  //    [31:21] {LineX V-Scale Target (11bits)}
  //    [20: 9] {LineX H-Scale Target (12bits)}
  //    [ 8: 0] {(2bits reserve),Force 50Hz/60Hz (2bits),LowLatencyMode (1bit),UseVGAfor480p (1bit),TargetResolution (3bits)}

  
  
  // OSD
  `define show_osd_logo_bit     31
  `define show_osd_bit          30
  `define mute_osd_bit          29
  
  
  // IGR
  `define igr_reset_enable_bit  28
  
  // Separation slices
  `define cfg3_audio_config_slice    6: 0
  `define cfg2_scanline_slice       28: 0
  `define cfg1_ppu_config_slice     21: 0
  
  // Audio config
  `define APUConfig_WordWidth        7
  `define audio_amp_slice            6: 2
  `define audio_swap_lr_bit          1
  `define audio_spdif_en_bit         0
  
  
  // PPU config
  `define PPUConfig_WordWidth       85  // 29 + 24 + 32
  
  `define SysCfg2_PPUCfg_Offset     56  // 24 + 32
  `define SysCfg1_PPUCfg_Offset     32  // 32
  `define SysCfg0_PPUCfg_Offset      0  // 0
  
  `define vSL_thickness_slice   28 + `SysCfg2_PPUCfg_Offset : 27 + `SysCfg2_PPUCfg_Offset
  `define vSL_profile_slice     26 + `SysCfg2_PPUCfg_Offset : 25 + `SysCfg2_PPUCfg_Offset
  `define vSL_hybrid_slice      24 + `SysCfg2_PPUCfg_Offset : 20 + `SysCfg2_PPUCfg_Offset
  `define vSL_str_slice         19 + `SysCfg2_PPUCfg_Offset : 16 + `SysCfg2_PPUCfg_Offset
  `define hSL_thickness_slice   15 + `SysCfg2_PPUCfg_Offset : 14 + `SysCfg2_PPUCfg_Offset
  `define hSL_profile_slice     13 + `SysCfg2_PPUCfg_Offset : 12 + `SysCfg2_PPUCfg_Offset
  `define hSL_hybrid_slice      11 + `SysCfg2_PPUCfg_Offset :  7 + `SysCfg2_PPUCfg_Offset
  `define hSL_str_slice          6 + `SysCfg2_PPUCfg_Offset :  3 + `SysCfg2_PPUCfg_Offset
  `define vSL_en_bit             2 + `SysCfg2_PPUCfg_Offset
  `define hSL_en_bit             1 + `SysCfg2_PPUCfg_Offset
  `define h2v_SL_linked_bit      0 + `SysCfg2_PPUCfg_Offset
  
  `define limitedRGB_bit              23 + `SysCfg1_PPUCfg_Offset
  `define gamma_slice                 22 + `SysCfg1_PPUCfg_Offset : 19 + `SysCfg1_PPUCfg_Offset
  `define videblur_bit                18 + `SysCfg1_PPUCfg_Offset
  `define n16bit_mode_bit             17 + `SysCfg1_PPUCfg_Offset
  `define vshift_slice                16 + `SysCfg1_PPUCfg_Offset : 12 + `SysCfg1_PPUCfg_Offset
  `define hshift_slice                11 + `SysCfg1_PPUCfg_Offset :  7 + `SysCfg1_PPUCfg_Offset
  `define deinterlacing_mode_bit       5 + `SysCfg1_PPUCfg_Offset
  `define v_interpolation_mode_slice   4 + `SysCfg1_PPUCfg_Offset :  3 + `SysCfg1_PPUCfg_Offset
  `define h_interpolation_mode_slice   2 + `SysCfg1_PPUCfg_Offset :  1 + `SysCfg1_PPUCfg_Offset
  `define pal_boxed_scale_bit          0 + `SysCfg1_PPUCfg_Offset
  
  `define target_vlines_slice       31 + `SysCfg0_PPUCfg_Offset : 21 + `SysCfg0_PPUCfg_Offset
  `define target_hpixels_slice      20 + `SysCfg0_PPUCfg_Offset :  9 + `SysCfg0_PPUCfg_Offset
  `define force_5060_slice           6 + `SysCfg0_PPUCfg_Offset :  5 + `SysCfg0_PPUCfg_Offset
  `define force50hz_bit              6 + `SysCfg0_PPUCfg_Offset
  `define force60hz_bit              5 + `SysCfg0_PPUCfg_Offset
  `define lowlatencymode_bit         4 + `SysCfg0_PPUCfg_Offset
  `define use_vga_for_480p_bit       3 + `SysCfg0_PPUCfg_Offset
  `define target_resolution_slice    2 + `SysCfg0_PPUCfg_Offset :  0 + `SysCfg0_PPUCfg_Offset
  
  // Tables
  
  `define GAMMA_TABLE_OFF   4'b0101
  `define HDMI_TARGET_240P  3'b000
  `define HDMI_TARGET_288P  3'b000
  `define HDMI_TARGET_480P  3'b001
  `define HDMI_TARGET_576P  3'b001
  `define HDMI_TARGET_720P  3'b010
  `define HDMI_TARGET_960P  3'b011
  `define HDMI_TARGET_1080P 3'b100
  `define HDMI_TARGET_1200P 3'b101
  `define HDMI_TARGET_1440P 3'b110
  
  // PPU Feedback Channel
  
  `define PPU_State_Width               24  // without pal pattern bit
  
  `define PPU_input_palpattern_bit      24  // will be extended in controller module
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