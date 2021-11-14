/*********************************************************************************
 *
 * This file is part of the N64 RGB/YPbPr DAC project.
 *
 * Copyright (C) 2015-2021 by Peter Bartmann <borti4938@gmail.com>
 *
 * N64 RGB/YPbPr DAC is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *********************************************************************************
 *
 * vd_driver.c
 *
 *  Created on: 06.01.2018
 *      Author: Peter Bartmann
 *
 ********************************************************************************/
 
#include <string.h>
#include <stddef.h>
#include <unistd.h>
#include "vd_driver.h"
#include "alt_types.h"
#include "altera_avalon_pio_regs.h"
#include "system.h"

alt_u8 _width = VD_WIDTH;
alt_u8 _height = VD_HEIGHT;

int vd_clear_area(alt_u8 horiz_offset_start, alt_u8 horiz_offset_stop, alt_u8 vert_offset_start, alt_u8 vert_offset_stop)
{
  alt_u8 horiz_offset, vert_offset;
  for (horiz_offset = horiz_offset_start; horiz_offset<=horiz_offset_stop; horiz_offset++)
    for (vert_offset = vert_offset_start; vert_offset<=vert_offset_stop; vert_offset++)
      vd_print_char(horiz_offset,vert_offset, BACKGROUNDCOLOR_STANDARD, FONTCOLOR_NON, 0x00);
  return(0);
};

int vd_print_string(alt_u8 horiz_offset, alt_u8 vert_offset, alt_u8 background, alt_u8 color, const char *string)
{
  int i = 0;
  alt_u8 original_horiz_offset;

  original_horiz_offset = horiz_offset;

  // Print until we hit the '\0' char.
  while (string[i]) {
    //Handle newline char here.
    if (string[i] == '\n') {
      horiz_offset = original_horiz_offset;
      vert_offset++;
      i++;
      continue;
    }
    // Lay down that character and increment our offsets.
    vd_print_char(horiz_offset, vert_offset, background, color, string[i]);
    i++;
    horiz_offset++;
  }
  return (0);
}

int vd_print_char (alt_u8 horiz_offset, alt_u8 vert_offset, alt_u8 background, alt_u8 color, const char character)
{
  if((horiz_offset >= 0) && (horiz_offset < _width) && (vert_offset >= 0) && (vert_offset < _height)){
    VD_SET_DATA(VD_SET_ADDR(horiz_offset,vert_offset),background,color,character);
    vd_write_data(1,1);
  }
  return(0);
}

//int vd_change_color_area(alt_u8 horiz_offset_start, alt_u8 horiz_offset_stop, alt_u8 vert_offset_start, alt_u8 vert_offset_stop, alt_u8 background, alt_u8 fontcolor)
//{
//  alt_u8 horiz_offset, vert_offset;
//  for (horiz_offset = horiz_offset_start; horiz_offset<=horiz_offset_stop; horiz_offset++)
//    for (vert_offset = vert_offset_start; vert_offset<=vert_offset_stop; vert_offset++)
//      vd_change_color(horiz_offset,vert_offset, background, fontcolor);
//  return(0);
//};
//
//int vd_change_color_px (alt_u8 horiz_offset, alt_u8 vert_offset, alt_u8 background, alt_u8 color)
//{
//  if((horiz_offset >= 0) && (horiz_offset < _width) && (vert_offset >= 0) && (vert_offset < _height)){
//    VD_SET_ADDR(horiz_offset,vert_offset);
//    VD_SET_DATA(background,color,EMPTY);
//    vd_write_data(1,0);
//  }
//  return(0);
//}

void vd_write_data(alt_u8 wr_color, alt_u8 wr_font)
{
  alt_u8 wrctrl = ((wr_color != 0) << 1) | (wr_font != 0);

  wrctrl = IORD_ALTERA_AVALON_PIO_DATA(VD_WRCTRL_BASE) | (wrctrl & VD_WRCTRL_WREN_GETMASK);
  IOWR_ALTERA_AVALON_PIO_DATA(VD_WRCTRL_BASE,wrctrl);
  wrctrl = wrctrl & VD_WRCTRL_WREN_CLRMASK;
  IOWR_ALTERA_AVALON_PIO_DATA(VD_WRCTRL_BASE,wrctrl);
}

//void vd_mute()
//{
//  // ToDo
//}
//
//void vd_unmute()
//{
//  // ToDo
//}
