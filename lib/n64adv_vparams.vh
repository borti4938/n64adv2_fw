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
// VH-file Name:   n64adv_vparams
// Project Name:   N64 Advanced Mod
// Target Devices: several devices
// Tool versions:  Altera Quartus Prime
// Description:
//
//////////////////////////////////////////////////////////////////////////////////


parameter color_width_i = 7;
parameter color_width_o = 8;

parameter vdata_width_i = 4 + 3*color_width_i;
parameter vdata_width_o = 4 + 3*color_width_o;


`ifndef _n64adv2_vparams_vh_
`define _n64adv2_vparams_vh_

  // video vector slices and frame definitions
  // =========================================

  `define VDATA_I_FU_SLICE    vdata_width_i-1:0               // full slice
  `define VDATA_I_SY_SLICE  3*color_width_i+3:3*color_width_i // slice sync
  `define VDATA_I_CO_SLICE  3*color_width_i-1:0               // slice color
  `define VDATA_I_RE_SLICE  3*color_width_i-1:2*color_width_i // slice red
  `define VDATA_I_GR_SLICE  2*color_width_i-1:  color_width_i // slice green
  `define VDATA_I_BL_SLICE    color_width_i-1:0               // slice blue

  `define VDATA_O_FU_SLICE    vdata_width_o-1:0
  `define VDATA_O_SY_SLICE  3*color_width_o+3:3*color_width_o 
  `define VDATA_O_CO_SLICE  3*color_width_o-1:0
  `define VDATA_O_RE_SLICE  3*color_width_o-1:2*color_width_o
  `define VDATA_O_GR_SLICE  2*color_width_o-1:  color_width_o
  `define VDATA_O_BL_SLICE    color_width_o-1:0


  `define PIXEL_PER_LINE_NTSC_normal0   772
  `define PIXEL_PER_LINE_NTSC_normal1   773
  `define PIXEL_PER_LINE_NTSC_2x        1546
  `define PIXEL_PER_LINE_NTSC_4x        3093

  `define PIXEL_PER_LINE_PAL_2x_short     1586
  `define PIXEL_PER_LINE_PAL_2x_normal    1588 // slighty modified and thus different pattern
  `define PIXEL_PER_LINE_PAL_2x_long      1589 // slighty modified and thus different pattern
  `define PIXEL_PER_LINE_PAL_4x_short_v1  3173 // original: 1100 0110 0101
  `define PIXEL_PER_LINE_PAL_4x_short_v2  3175 // original: 1100 0110 0101
  `define PIXEL_PER_LINE_PAL_4x_normal    3177 // original: 1100 0110 1001
  `define PIXEL_PER_LINE_PAL_4x_long0     3181 // original: 1100 0110 1101
  `define PIXEL_PER_LINE_PAL_4x_long1_v2  3184 // original: 1100 0111 0000
  `define PIXEL_PER_LINE_PAL_4x_long2_v2  3185 // original: 1100 0111 0001
  `define PIXEL_PER_LINE_PAL_4x_long1_v1  3186 // original: 1100 0111 0010
  `define PIXEL_PER_LINE_PAL_4x_long2_v1  3187 // original: 1100 0111 0011
  
  // PAL Patterns found so far:
  // --------------------------
  // - H count pattern I    : 3177, 3181, 3177, 3177, …
  // - H count pattern II.a : 3177, 3187, 3173, 3177, 3177, …
  // - H count pattern II.b : 3177, 3185, 3175, 3177, 3177, …
  // - H count pattern III.a: 3177, 3186, 3173, 3177, …
  // - H count pattern III.b: 3177, 3184, 3175, 3177, …
  //
  // Pattern 0: (e.g. Wave Race)
  //   - Five-Frame pattern v1: 4x I, II.a, …
  //   - Five-Frame pattern v2: 4x I, II.b, …
  //
  // Pattern 1 (v1): (e.g. Super Mario 64)
  //   - Five-Frame pattern v1: 2xIII.a, II.a, III.a, II.a, …
  //   - Five-Frame pattern v2: 2xIII.b, II.a, III.b, II.a, …
  //
  // Detection:
  //   check for I (unique for pattern 0) or II.x (unique for pattern 2)

  `define PIXEL_PER_LINE_MAX            800
  `define PIXEL_PER_LINE_MAX_2x         1600
  `define PIXEL_PER_LINE_MAX_4x         3200

  `define ACTIVE_PIXEL_PER_LINE     640
  `define ACTIVE_PIXEL_PER_LINE_2x  1280

  `define TOTAL_LINES_NTSC_LX1    263
  `define TOTAL_LINES_NTSC_LX2_0  525
  `define TOTAL_LINES_NTSC_LX2_1  526
  `define TOTAL_LINES_NTSC_LX3_1  789
  `define ACTIVE_LINES_NTSC_LX1   240
  `define ACTIVE_LINES_NTSC_LX2   480
  `define ACTIVE_LINES_NTSC_LX3   720

  `define TOTAL_LINES_PAL_LX1   313
  `define TOTAL_LINES_PAL_LX2_0 625
  `define TOTAL_LINES_PAL_LX2_1 626
  `define TOTAL_LINES_PAL_LX3_1 939
  `define ACTIVE_LINES_PAL_LX1  288
  `define ACTIVE_LINES_PAL_LX2  576
  `define ACTIVE_LINES_PAL_LX3  864


  `define HSTART_NTSC     116
  `define HSTOP_NTSC      (`HSTART_NTSC + `ACTIVE_PIXEL_PER_LINE)
  `define HSTART_NTSC_2x  (2*`HSTART_NTSC+1)
  `define HSTOP_NTSC_2x   (`HSTART_NTSC_2x + `ACTIVE_PIXEL_PER_LINE_2x)

  `define VSTART_NTSC_LX1 18
  `define VSTOP_NTSC_LX1  (`VSTART_NTSC_LX1 + `ACTIVE_LINES_NTSC_LX1)
  `define VSTART_NTSC_LX2 (2*`VSTART_NTSC_LX1)
  `define VSTOP_NTSC_LX2  (`VSTART_NTSC_LX2 + `ACTIVE_LINES_NTSC_LX2)
  `define VSTART_NTSC_LX3 (3*`VSTART_NTSC_LX1)
  `define VSTOP_NTSC_LX3  (`VSTART_NTSC_LX3 + `ACTIVE_LINES_NTSC_LX3)

  `define HS_WIDTH_NTSC_LX2_2x  113
  `define HS_WIDTH_NTSC_LX3_2x  38
  `define VS_WIDTH_NTSC_LX2     2
  `define VS_WIDTH_NTSC_LX3     5

  `define H_SHIFT_NTSC_240P_LX2_2x  0
  `define H_SHIFT_NTSC_480I_LX2_2x  28
  `define H_SHIFT_NTSC_240P_LX3_2x  25
  `define V_SHIFT_NTSC_LX2          0
  `define V_SHIFT_NTSC_LX3          3


  `define HSTART_PAL      136
  `define HSTOP_PAL       (`HSTART_PAL + `ACTIVE_PIXEL_PER_LINE)
  `define HSTART_PAL_2x   (2*`HSTART_PAL+1)
  `define HSTOP_PAL_2x    (`HSTART_PAL_2x + `ACTIVE_PIXEL_PER_LINE_2x)

  `define VSTART_PAL_LX1  21
  `define VSTOP_PAL_LX1   (`VSTART_PAL_LX1 + `ACTIVE_LINES_PAL_LX1)
  `define VSTART_PAL_LX2  (2*`VSTART_PAL_LX1)
  `define VSTOP_PAL_LX2   (`VSTART_PAL_LX2 + `ACTIVE_LINES_PAL_LX2)

  `define HS_WIDTH_PAL_LX2_2x 123
  `define VS_WIDTH_PAL_LX2    5

  `define H_SHIFT_PAL_288P_LX2_2x 0
  `define H_SHIFT_PAL_576I_LX2_2x 28
  `define V_SHIFT_PAL_LX2         0


  `define BUF_NUM_OF_PAGES    4
  `define BUF_DEPTH_PER_PAGE  `ACTIVE_PIXEL_PER_LINE

`endif