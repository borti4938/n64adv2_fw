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
 * vd_driver.h
 *
 *  Created on: 06.01.2018
 *      Author: Peter Bartmann
 *
 ********************************************************************************/

#include "alt_types.h"
#include "altera_avalon_pio_regs.h"

#ifndef VD_DRIVER_H_
#define VD_DRIVER_H_


typedef enum {
  VD_HEADER = 0,
  VD_TEXT,
  VD_INFO
} vd_area_t;


// define virtual display (memory mapped)
#define VD_WIDTH        48
#define VD_HDR_HEIGHT    1
#define VD_TXT_HEIGHT   13
#define VD_INFO_HEIGHT   1

#define VD_HDR_AREA_VOFFSET   0
#define VD_TXT_AREA_VOFFSET   VD_HDR_HEIGHT
#define VD_INFO_AREA_VOFFSET  (VD_HDR_HEIGHT + VD_TXT_HEIGHT)


// define some masks and shifts
#define VD_WRADDR_HSHIFT_OFFSET 4

#define VD_WRADDR_V_ANDMASK 0x00F
#define VD_WRADDR_H_ANDMASK 0x3F0


#define VD_WRDATA_ADDR_OFFSET   10
#define VD_WRDATA_COLOR_OFFSET   7
#define VD_WRDATA_TEXT_OFFSET    0

#define VD_WRDATA_ALL_ANDMASK   0xFFFFF
#define VD_WRDATA_ADDR_ANDMASK  ((VD_WRADDR_H_ANDMASK | VD_WRADDR_V_ANDMASK) << VD_WRDATA_ADDR_OFFSET)
#define VD_WRDATA_COLOR_ANDMASK (0x07 << VD_WRDATA_COLOR_OFFSET)
#define VD_WRDATA_FONT_ANDMASK  (0x7F << VD_WRDATA_TEXT_OFFSET)




#define VD_WRCTRL_GETALL_MASK         0x3
#define VD_WRCTRL_WREN_GETMASK        0x3
#define VD_WRCTRL_WREN_SETMASK        0x3
#define VD_WRCTRL_WREN_CLRMASK        (VD_WRCTRL_GETALL_MASK & ~VD_WRCTRL_WREN_SETMASK)
  #define VD_WRCTRL_WREN_COLOR_GETMASK  0x2
  #define VD_WRCTRL_WREN_COLOR_SETMASK  0x2
  #define VD_WRCTRL_WREN_COLOR_CLRMASK  (VD_WRCTRL_GETALL_MASK & ~VD_WRCTRL_WREN_COLOR_SETMASK)
  #define VD_WRCTRL_WREN_FONT_GETMASK   0x1
  #define VD_WRCTRL_WREN_FONT_SETMASK   0x1
  #define VD_WRCTRL_WREN_FONT_CLRMASK   (VD_WRCTRL_GETALL_MASK & ~VD_WRCTRL_WREN_FONT_SETMASK)
#define VD_WRCTRL_WRTXTEN_GETMASK     0x1
#define VD_WRCTRL_WRTXTEN_SETMASK     0x1
#define VD_WRCTRL_WRTXTEN_CLRMASK     (VD_WRCTRL_GETALL_MASK & ~VD_WRCTRL_WRTXTEN_SETMASK)
#define VD_WRCTRL_WRCOLEN_GETMASK     0x2
#define VD_WRCTRL_WRCOLEN_SETMASK     0x2
#define VD_WRCTRL_WRCOLEN_CLRMASK     (VD_WRCTRL_GETALL_MASK & ~VD_WRCTRL_WRCOLEN_SETMASK)


// Color definitions
#define FONTCOLOR_WHITE       0x0
#define FONTCOLOR_GREY        0x1
#define FONTCOLOR_YELLOW      0x2
#define FONTCOLOR_NAVAJOWHITE 0x3
#define FONTCOLOR_GREEN       0x4
#define FONTCOLOR_MAGENTA     0x5
#define FONTCOLOR_DARKORANGE  0x6
#define FONTCOLOR_RED         0x7


// some macros
#define VD_SET_ADDR(h,v)      ((h<<VD_WRADDR_HSHIFT_OFFSET) & VD_WRADDR_H_ANDMASK) | (v & VD_WRADDR_V_ANDMASK))
#define VD_SET_DATA(a,c,f)    IOWR_ALTERA_AVALON_PIO_DATA(VD_WRDATA_BASE,(((a<<VD_WRDATA_ADDR_OFFSET)   & VD_WRDATA_ADDR_ANDMASK)  | \
                                                                         ((c<<VD_WRDATA_COLOR_OFFSET)  & VD_WRDATA_COLOR_ANDMASK) | \
                                                                          (f & VD_WRDATA_FONT_ANDMASK)                            )

// prototypes
int vd_clear_lineend(vd_area_t vd_area,alt_u8 horiz_offset_start, alt_u8 vert_offset);
int vd_print_char(vd_area_t vd_area,alt_u8 horiz_offset,alt_u8 vert_offset,alt_u8 color,const char character);
int vd_print_string(vd_area_t vd_area,alt_u8 horiz_offset,alt_u8 vert_offset,alt_u8 color,const char *string);
void vd_clear_hdr(void);
void vd_wr_hdr(alt_u8 color,const char *string);
void vd_clear_txt(void);
void vd_clear_info(void);

#endif /* VD_DRIVER_H_ */
