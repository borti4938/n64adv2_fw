//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the N64 RGB/YPbPr DAC project.
//
// Copyright (C) 2015-2021 by Peter Bartmann <borti4938@gmail.com>
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
// VH-file Name:   n64adv_config
// Project Name:   N64 Advanced Mod
// Target Devices: several devices
// Tool versions:  Altera Quartus Prime
// Description:
//
//////////////////////////////////////////////////////////////////////////////////


`ifndef _n64adv2_config_vh_
`define _n64adv2_config_vh_

  // configuration as defined in n64adv_controller.v (must match software)
  //  wire [31:0] SysConfigSet2;
  //    [31:24] {(8bits reserve)}
  //    [23:16] {(1bit reserve),audio_amp (5bits),audio_swap_lr,audio_spdif_en}
  //    [15: 8] {(4bits reserve),show_osd_logo,show_osd,mute_osd,igr for reset}
  //    [ 7: 0] {(1bit reserve),gamma (4bits),limited RGB,VI-DeBlur,16bit mode}
  //  wire [31:0] SysConfigSet1;
  //    [31:22] {LineX H-Shift (5bits), LineX V-Shift (5bits)}
  //    [21:11] {Link HV scale (1bit), LineX H-Scale (5bits), LineX V-Scale (5bits)}
  //    [10: 0] {(6bits reserve),De-Interlace Mode (2 bits),Interpolation Mode (2 bits), PAL boxed mode (1 bit)}
  //  wire [31:0] SysConfigSet0;
  //    [31:25] Resolution: {Force 50Hz/60Hz (2bits), UseVGAfor480p (1bit), LowLatencyMode (1bit),TargetResolution (3bits)}
  //    [24:13] SL 240p:    {Sl_hybrid_depth (5bits),Sl_str (4bits),Sl_Method,Sl_ID,Sl_En}
  //    [12: 0] SL 480i:    {Sl_hybrid_depth (5bits),Sl_str (4bits),Sl_Method,Sl_ID,Sl_link,Sl_En}

  // Audio, OSD and IGR stuff handelded differently compared to ppu config
  `define audio_amp_slice         6:2
  `define audio_swap_lr_bit       1
  `define audio_spdif_en_bit      0

  `define audio_config_slice      22:16
  `define show_osd_logo_bit       11
  `define show_osd_bit            10
  `define mute_osd_bit             9
  `define igr_reset_enable_bit     8
  `define gamma_sysslice           6 : 3
  `define limitedRGB_sysbit        2
  `define videblur_sysbit          1
  `define n16bit_mode_sysbit       0

  `define PPUConfig_WordWidth 71

  `define SysConfigSet2_PPUConfig_slice  6 : 0
  `define SysConfigSet2_Offset          64
  `define gamma_slice                    6 + `SysConfigSet2_Offset : 3 + `SysConfigSet2_Offset
  `define limitedRGB_bit                 2 + `SysConfigSet2_Offset
  `define videblur_bit                   1 + `SysConfigSet2_Offset
  `define n16bit_mode_bit                0 + `SysConfigSet2_Offset

  `define SysConfigSet1_Offset      32
  `define hshift_slice              31 + `SysConfigSet1_Offset : 27 + `SysConfigSet1_Offset
  `define vshift_slice              26 + `SysConfigSet1_Offset : 22 + `SysConfigSet1_Offset
  `define link_hv_scale_bit         21 + `SysConfigSet1_Offset
  `define hscale_slice              20 + `SysConfigSet1_Offset : 16 + `SysConfigSet1_Offset
  `define vscale_slice              15 + `SysConfigSet1_Offset : 11 + `SysConfigSet1_Offset
  `define deinterlacing_mode_slice   4 + `SysConfigSet1_Offset :  3 + `SysConfigSet1_Offset
  `define interpolation_mode_slice   2 + `SysConfigSet1_Offset :  1 + `SysConfigSet1_Offset
  `define pal_boxed_scale_bit        0 + `SysConfigSet1_Offset

  `define force_5060_slice        31:30
  `define force50hz_bit           31
  `define force60hz_bit           30
  `define use_vga_for_480p_bit    29
  `define lowlatencymode_bit      28
  `define target_resolution_slice 27:25

  `define v240p_SL_hybrid_slice   24:20
  `define v240p_SL_str_slice      19:16
  `define v240p_SL_method_bit     15
  `define v240p_SL_ID_bit         14
  `define v240p_SL_En_bit         13

  `define v480i_SL_hybrid_slice   12: 8
  `define v480i_SL_str_slice       7: 4
  `define v480i_SL_method_bit      3
  `define v480i_SL_ID_bit          2
  `define v480i_SL_linked_bit      1
  `define v480i_SL_En_bit          0
  
  `define GAMMA_TABLE_OFF   4'b0101
  `define HDMI_TARGET_480P  3'b000
  `define HDMI_TARGET_720P  3'b001
  `define HDMI_TARGET_960P  3'b010
  `define HDMI_TARGET_1080P 3'b011
  `define HDMI_TARGET_1200P 3'b100
  
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