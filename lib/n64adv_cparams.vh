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
// VH-file Name:   n64adv_cparams
// Project Name:   N64 Advanced Mod
// Target Devices: several devices
// Tool versions:  Altera Quartus Prime
// Description:
//
//////////////////////////////////////////////////////////////////////////////////


`ifndef _n64adv_cparams_vh_
`define _n64adv_cparams_vh_


  // N64 controller sniffing
  // =======================

  // controller serial data bits:
  //  0: 7 - A, B, Z, St, Du, Dd, Dl, Dr
  //  8:15 - 'Joystick reset', (0), L, R, Cu, Cd, Cl, Cr
  // 16:23 - X axis
  // 24:31 - Y axis
  // 32    - Stop bit

  // define constants
  // don't edit these constants

  `define A  16'h0001 // button A
  `define B  16'h0002 // button B
  `define Z  16'h0004 // trigger Z
  `define St 16'h0008 // Start button

  `define Du 16'h0010 // D-pad up
  `define Dd 16'h0020 // D-pad down
  `define Dl 16'h0040 // D-pad left
  `define Dr 16'h0080 // D-pad right

  `define L  16'h0400 // shoulder button L
  `define R  16'h0800 // shoulder button R

  `define Cu 16'h1000 // C-button up
  `define Cd 16'h2000 // C-button down
  `define Cl 16'h4000 // C-button left
  `define Cr 16'h8000 // C-button right

  // In-game reset command
  // =====================

  `define IGR_RESET (`A + `B + `Z + `St + `R)

  // OSD menu window sizing
  // ======================

  // define font size (every value - 1)
  `define OSD_FONT_WIDTH  7
  `define OSD_FONT_HEIGHT 11

  // define text window size (every value - 1)
  `define MAX_HDR_ROWS       0
  `define MAX_TEXT_ROWS     12
  `define MAX_INFO_ROWS      0
  `define MAX_CHARS_PER_ROW 47
  
  `define VAREA_HDR2TXT  8
  `define VAREA_TXT2INFO 6

  // positioning of OSD window (not linedoubled)
  `define OSD_WINDOW_VACTIVE (8 + (`MAX_HDR_ROWS + 1)*(`OSD_FONT_HEIGHT + 1) + `VAREA_HDR2TXT + (`MAX_TEXT_ROWS + 1)*(`OSD_FONT_HEIGHT + 1) + `VAREA_TXT2INFO + (`MAX_INFO_ROWS + 1)*(`OSD_FONT_HEIGHT + 1) + 3)
                                  // 8 + 12 + 8 + 156 + 6 + 12 + 3 = 205
  `define OSD_WINDOW_HACTIVE (15 + (`MAX_CHARS_PER_ROW + 1)*(`OSD_FONT_WIDTH + 1))


  // define some areas in the OSD windows
  `define OSD_LOGO_VOFFSET  4
  `define OSD_LOGO_VACTIVE  (2*8)
  `define OSD_LOGO_HOFFSET  7
  `define OSD_LOGO_HACTIVE  (2*128)
  
  `define OSD_HDR_VOFFSET   8
  `define OSD_HDR_VACTIVE   ((`MAX_HDR_ROWS + 1)*(`OSD_FONT_HEIGHT + 1))
  `define OSD_TXT_VOFFSET   (`OSD_HDR_VOFFSET + `OSD_HDR_VACTIVE + `VAREA_HDR2TXT)
  `define OSD_TXT_VACTIVE   ((`MAX_TEXT_ROWS + 1)*(`OSD_FONT_HEIGHT + 1))
  `define OSD_INFO_VOFFSET  (`OSD_TXT_VOFFSET + `OSD_TXT_VACTIVE + `VAREA_TXT2INFO)
  `define OSD_INFO_VACTIVE  ((`MAX_INFO_ROWS + 1)*(`OSD_FONT_HEIGHT + 1))
  `define OSD_TXT_HOFFSET   7
  `define OSD_TXT_HACTIVE   ((`MAX_CHARS_PER_ROW + 1)*(`OSD_FONT_WIDTH + 1))
  
  `define OSD_SEPARATION_LINE0_VOFFSET  (`OSD_HDR_VOFFSET + `OSD_HDR_VACTIVE + 3)
  `define OSD_SEPARATION_LINE1_VOFFSET  (`OSD_HDR_VOFFSET + `OSD_HDR_VACTIVE + 5)
  `define OSD_SEPARATION_LINE2_VOFFSET  (`OSD_TXT_VOFFSET + `OSD_TXT_VACTIVE + 3)

  // define OSD background window color (three bits each color)
  `define OSD_BACKGROUND_WHITE    3
  `define OSD_BACKGROUND_GREY     2
  `define OSD_BACKGROUND_BLACK    1
  `define OSD_BACKGROUND_DARKBLUE 0

  `define OSD_WINDOW_BGCOLOR_WHITE    9'b111111111
  `define OSD_WINDOW_BGCOLOR_GREY     9'b010010010
  `define OSD_WINDOW_BGCOLOR_BLACK    9'b000000000
  `define OSD_WINDOW_BGCOLOR_DARKBLUE 9'b000000011

  // define text color
  `define FONTCOLOR_WHITE         0
  `define FONTCOLOR_GREY          1
  `define FONTCOLOR_YELLOW        2
  `define FONTCOLOR_NAVAJOWHITE   3
  `define FONTCOLOR_GREEN         4
  `define FONTCOLOR_MAGENTA       5
  `define FONTCOLOR_DARKORANGE    6
  `define FONTCOLOR_RED           7

                                    //  rrrrrrrgggggggbbbbbbb
  `define OSD_TXT_COLOR_WHITE       21'b111111111111111111111
  `define OSD_TXT_COLOR_GREY        21'b001111100111110011111
  `define OSD_TXT_COLOR_YELLOW      21'b111111111111110000000
  `define OSD_TXT_COLOR_NAVAJOWHITE 21'b111111111011111010110
  `define OSD_TXT_COLOR_GREEN       21'b000000011111110000000
  `define OSD_TXT_COLOR_MAGENTA     21'b111111100000001111111
  `define OSD_TXT_COLOR_DARKORANGE  21'b110011001100110000000
  `define OSD_TXT_COLOR_RED         21'b111111100000000000000
                                    //  rrrrrrrgggggggbbbbbbb

                                       //  rrrrrrrrggggggggbbbbbbbb
  `define OSD_TXT_COLOR_WHITE_24       24'b111111111111111111111111
  `define OSD_TXT_COLOR_GREY_24        24'b001111100011111000111110
  `define OSD_TXT_COLOR_YELLOW_24      24'b111111111111111100000000
  `define OSD_TXT_COLOR_NAVAJOWHITE_24 24'b111111111101111110101101
  `define OSD_TXT_COLOR_GREEN_24       24'b000000001111111100000000
  `define OSD_TXT_COLOR_MAGENTA_24     24'b111111110000000011111111
  `define OSD_TXT_COLOR_DARKORANGE_24  24'b110011010110011000000000
  `define OSD_TXT_COLOR_RED_24         24'b111111110000000000000000
                                       //  rrrrrrrrggggggggbbbbbbbb

  `define OSD_LOGO_COLOR    `OSD_TXT_COLOR_DARKORANGE
  `define OSD_LOGO_COLOR_24 `OSD_TXT_COLOR_DARKORANGE_24

  `define SEPARATION_LINE_COLOR    `OSD_TXT_COLOR_NAVAJOWHITE
  `define SEPARATION_LINE_COLOR_24 `OSD_TXT_COLOR_NAVAJOWHITE_24

`endif