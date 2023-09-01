/*********************************************************************************
 *
 * This file is part of the N64 RGB/YPbPr DAC project.
 *
 * Copyright (C) 2015-2023 by Peter Bartmann <borti4938@gmail.com>
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
#include "config.h"


#define EMPTY               0x20

const alt_u8 vd_overall_width = VD_WIDTH;
const alt_u8 vd_overall_height = (VD_HDR_HEIGHT + VD_TXT_HEIGHT + VD_INFO_HEIGHT);


void vd_print_char_local (alt_u8 horiz_offset, alt_u8 vert_offset, alt_u8 color, const char character)
{
  if((horiz_offset >= 0) && (horiz_offset < vd_overall_width) && (vert_offset >= 0) && (vert_offset < vd_overall_height)){
    VD_SET_DATA(VD_SET_ADDR(horiz_offset,vert_offset),color,character);
    IOWR_ALTERA_AVALON_PIO_DATA(VD_WRCTRL_BASE,1);
    asm ("nop");
    IOWR_ALTERA_AVALON_PIO_DATA(VD_WRCTRL_BASE,0);
//    asm ("nop");
  }
};

void vd_clear_area_local(alt_u8 horiz_offset_start, alt_u8 horiz_offset_stop, alt_u8 vert_offset_start, alt_u8 vert_offset_stop)
{
  alt_u8 horiz_offset, vert_offset;
  for (horiz_offset = horiz_offset_start; horiz_offset<=horiz_offset_stop; horiz_offset++)
    for (vert_offset = vert_offset_start; vert_offset<=vert_offset_stop; vert_offset++)
      vd_print_char_local(horiz_offset,vert_offset, FONTCOLOR_WHITE, EMPTY);
};

int vd_print_string_local(alt_u8 horiz_offset, alt_u8 vert_offset, alt_u8 color, const char *string, alt_u8 max_linebreaks)
{
  alt_u16 i = 0;
  alt_u8 linebreak_cnt = 0;
  alt_u8 original_horiz_offset;

  original_horiz_offset = horiz_offset;

  // Print until we hit the '\0' char.
  while (string[i]) {
    //Handle newline char here.
    if (string[i] == '\n') {
      if (linebreak_cnt == max_linebreaks) return -11;
      else                                 linebreak_cnt++;
      horiz_offset = original_horiz_offset;
      vert_offset++;
      i++;
      continue;
    }
    // Lay down that character and increment our offsets.
    vd_print_char_local(horiz_offset, vert_offset, color, string[i]);
    i++;
    horiz_offset++;
  }
  return 0;
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

int vd_clear_lineend(vd_area_t vd_area,alt_u8 horiz_offset_start, alt_u8 vert_offset)
{
  alt_u8 tmp_vert_offset = vert_offset;
  switch (vd_area) {
    case VD_HEADER:
      vd_clear_hdr();
      return 0;
    case VD_TEXT:
      if (tmp_vert_offset > VD_TXT_HEIGHT-1) return -1;
      tmp_vert_offset = tmp_vert_offset + VD_TXT_AREA_VOFFSET;
      break;
    case VD_INFO:
      if (tmp_vert_offset > VD_INFO_HEIGHT-1) return -2;
      tmp_vert_offset = tmp_vert_offset + VD_INFO_AREA_VOFFSET;
      break;
    default: break;
  }
  vd_clear_area_local(horiz_offset_start, VD_WIDTH-1, tmp_vert_offset, tmp_vert_offset);
  return 0;
};

int vd_print_char(vd_area_t vd_area, alt_u8 horiz_offset, alt_u8 vert_offset, alt_u8 color, const char character)
{
  alt_u8 tmp_vert_offset = vert_offset;

//  if ((vd_area == VD_HEADER) && (tmp_vert_offset > VD_HDR_HEIGHT-1)) return -1;
//
//  if ((vd_area == VD_TEXT) && (tmp_vert_offset > VD_TXT_HEIGHT-1)) return -2;
//  else tmp_vert_offset = tmp_vert_offset + VD_TXT_AREA_VOFFSET;
//
//  if ((vd_area == VD_INFO) && (tmp_vert_offset > VD_INFO_HEIGHT-1)) return -3;
//  else tmp_vert_offset = tmp_vert_offset + VD_INFO_AREA_VOFFSET;

  switch (vd_area) {
    case VD_HEADER:
      if (tmp_vert_offset > VD_HDR_HEIGHT-1) return -1;
      break;
    case VD_TEXT:
      if (tmp_vert_offset > VD_TXT_HEIGHT-1) return -2;
      tmp_vert_offset = tmp_vert_offset + VD_TXT_AREA_VOFFSET;
      break;
    case VD_INFO:
      if (tmp_vert_offset > VD_INFO_HEIGHT-1) return -3;
      tmp_vert_offset = tmp_vert_offset + VD_INFO_AREA_VOFFSET;
      break;
    default: return -4;
  }

  vd_print_char_local(horiz_offset,tmp_vert_offset,color,character);
  return 0;
};

int vd_print_string(vd_area_t vd_area, alt_u8 horiz_offset, alt_u8 vert_offset, alt_u8 color, const char *string)
{
  alt_u8 max_linebreaks = 0;
  alt_u8 tmp_vert_offset = vert_offset;
  switch (vd_area) {
    case VD_HEADER:
      if (tmp_vert_offset > VD_HDR_HEIGHT-1) return -1;
      max_linebreaks = VD_HDR_HEIGHT - 1 - tmp_vert_offset;
      break;
    case VD_TEXT:
      if (tmp_vert_offset > VD_TXT_HEIGHT-1) return -2;
      max_linebreaks = VD_TXT_HEIGHT - 1 - tmp_vert_offset;
      tmp_vert_offset = tmp_vert_offset + VD_TXT_AREA_VOFFSET;
      break;
    case VD_INFO:
      if (tmp_vert_offset > VD_INFO_HEIGHT-1) return -3;
      max_linebreaks = VD_INFO_HEIGHT - 1 - tmp_vert_offset;
      tmp_vert_offset = tmp_vert_offset + VD_INFO_AREA_VOFFSET;
      break;
    default: return -4;
  }

  return vd_print_string_local(horiz_offset,tmp_vert_offset,color,string,max_linebreaks);
};

void vd_clear_hdr()
{
  vd_clear_area_local(0,vd_overall_width-1,VD_HDR_AREA_VOFFSET,VD_HDR_AREA_VOFFSET+VD_HDR_HEIGHT-1);
  cfg_set_flag(&show_logo);
};

void vd_wr_hdr(alt_u8 color, const char *string)
{
  vd_clear_hdr();
  alt_u8 h_offset = VD_WIDTH - strlen(string);
  if (h_offset < 32) cfg_clear_flag(&show_logo);
  vd_print_string_local(h_offset,VD_HDR_AREA_VOFFSET,color,string,VD_HDR_HEIGHT-1);
};

void vd_clear_txt()
{
  vd_clear_area_local(0,vd_overall_width-1,VD_TXT_AREA_VOFFSET,VD_TXT_AREA_VOFFSET+VD_TXT_HEIGHT-1);
};

void vd_clear_txt_area(alt_u8 horiz_offset_start, alt_u8 horiz_offset_stop, alt_u8 vert_offset_start, alt_u8 vert_offset_stop)
{
  // make sure that area to be cleaned is not part of the info area
  if (vert_offset_start > VD_TXT_HEIGHT-1) return;
  alt_u8 tmp_vert_offset_stop = vert_offset_stop;
  if (vert_offset_stop > VD_TXT_HEIGHT-1) tmp_vert_offset_stop = VD_TXT_HEIGHT-1;
  // now - go on
  vd_clear_area_local(horiz_offset_start,horiz_offset_stop,vert_offset_start+VD_TXT_AREA_VOFFSET,tmp_vert_offset_stop+VD_TXT_AREA_VOFFSET);
};

void vd_clear_info()
{
  vd_clear_area_local(0,vd_overall_width-1,VD_INFO_AREA_VOFFSET,VD_INFO_AREA_VOFFSET+VD_INFO_HEIGHT-1);
};

void vd_clear_info_area(alt_u8 horiz_offset_start, alt_u8 horiz_offset_stop, alt_u8 vert_offset_start, alt_u8 vert_offset_stop)
{
  vd_clear_area_local(horiz_offset_start,horiz_offset_stop,vert_offset_start+VD_INFO_AREA_VOFFSET,vert_offset_stop+VD_INFO_AREA_VOFFSET);
};

