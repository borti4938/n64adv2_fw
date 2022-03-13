/*********************************************************************************
 *
 * This file is part of the N64 RGB/YPbPr DAC project.
 *
 * Copyright (C) 2015-2022 by Peter Bartmann <borti4938@gmail.com>
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
 * si5356_regs_p.h
 *
 *  Created on: 12.03.2021
 *      Author: Peter Bartmann
 *
 * File created with the help of ClockBuilder Pro v2.30 [2021-02-29]
 *
 ********************************************************************************/

#include "app_cfg.h"
#include "si5356.h"


#ifndef SI5356_REGS_P_
#define SI5356_REGS_P_

#define NUM_INIT_REGS     121
#define NUM_INPSW_REGS     10
#define NUM_CFG_MODE_REGS  17

typedef struct init_regs_data_t {
   unsigned char reg_addr;
   unsigned char reg_val;
   unsigned char reg_mask;
} init_regs_data_t;

typedef struct inpsw_regs_data_t {
   unsigned char reg_addr;
   unsigned char reg_val[NUM_CLK_SOURCES];
   unsigned char reg_mask;
} inpsw_regs_data_t;

typedef struct mode_regs_data_t {
   unsigned char reg_addr;
   unsigned char reg_val[NUM_SUPPORTED_CONFIGS];
//   unsigned char reg_mask;  // reg_mask is always 0xFF here -> so remove it
} mode_regs_data_t;

init_regs_data_t const init_regs[NUM_INIT_REGS] __ufmdata_section__ = {
  { 27,0x70,0x80},
  { 28,0x37,0xFF},
  { 31,0xC0,0xFF},
  { 32,0xC0,0xFF},
  { 33,0xE3,0xFF},
  { 34,0xE3,0xFF},
  { 35,0x05,0xFF},
  { 36,0x13,0x1F},
  { 37,0x13,0x1F},
  { 38,0x10,0x1F},
  { 39,0x10,0x1F},
  { 40,0x73,0xFF},
  { 41,0x5E,0x7F},
  { 42,0x37,0x3F},
  { 47,0x14,0x3C},
  { 49,0x90,0x7F},
  { 50,0xDE,0xC0},
  { 52,0x10,0x0C},
  { 58,0x00,0xFF},
  { 62,0x00,0x3F},
  { 63,0x10,0x0C},
  { 73,0x00,0x3F},
  { 74,0x10,0x0C},
  { 75,0x00,0xFF},
  { 76,0x00,0xFF},
  { 77,0x00,0xFF},
  { 78,0x00,0xFF},
  { 79,0x00,0xFF},
  { 80,0x00,0xFF},
  { 81,0x00,0xFF},
  { 82,0x00,0xFF},
  { 83,0x00,0xFF},
  { 84,0x00,0x3F},
  { 85,0x10,0x0C},
  { 86,0x00,0xFF},
  { 87,0x00,0xFF},
  { 88,0x00,0xFF},
  { 89,0x00,0xFF},
  { 90,0x00,0xFF},
  { 91,0x00,0xFF},
  { 92,0x00,0xFF},
  { 93,0x00,0xFF},
  { 94,0x00,0xFF},
  { 95,0x00,0x3F},
  {100,0x00,0xFF},
  {101,0x00,0xFF},
  {102,0x00,0xFF},
  {104,0x00,0xFF},
  {105,0x00,0xFF},
  {106,0x80,0x3F},
  {107,0x00,0xFF},
  {108,0x00,0x7F},
  {111,0x00,0xFF},
  {112,0x00,0x7F},
  {115,0x00,0xFF},
  {116,0x80,0x7F},
  {118,0x40,0xC0},
  {119,0x00,0xFF},
  {120,0x00,0xFF},
  {122,0x40,0xC0},
  {129,0x00,0x0F},
  {130,0x00,0x0F},
  {144,0x00,0x80},
  {158,0x00,0x0F},
  {159,0x00,0x0F},
  {181,0x00,0x0F},
  {203,0x00,0x0F},
  {255,0x01,0xFF}, // set page bit to 1 
  { 31,0x00,0xFF},
  { 32,0x00,0xFF},
  { 33,0x01,0xFF},
  { 34,0x00,0xFF},
  { 35,0x00,0xFF},
  { 36,0x90,0xFF},
  { 37,0x31,0xFF},
  { 38,0x00,0xFF},
  { 39,0x00,0xFF},
  { 40,0x01,0xFF},
  { 41,0x00,0xFF},
  { 42,0x00,0xFF},
  { 43,0x00,0x0F},
  { 47,0x00,0xFF},
  { 48,0x00,0xFF},
  { 49,0x01,0xFF},
  { 50,0x00,0xFF},
  { 51,0x00,0xFF},
  { 52,0x90,0xFF},
  { 53,0x31,0xFF},
  { 54,0x00,0xFF},
  { 55,0x00,0xFF},
  { 56,0x01,0xFF},
  { 57,0x00,0xFF},
  { 58,0x00,0xFF},
  { 59,0x00,0x0F},
  { 63,0x00,0xFF},
  { 64,0x00,0xFF},
  { 65,0x01,0xFF},
  { 66,0x00,0xFF},
  { 67,0x00,0xFF},
  { 68,0x90,0xFF},
  { 69,0x31,0xFF},
  { 70,0x00,0xFF},
  { 71,0x00,0xFF},
  { 72,0x01,0xFF},
  { 73,0x00,0xFF},
  { 74,0x00,0xFF},
  { 75,0x00,0x0F},
  { 79,0x00,0xFF},
  { 80,0x00,0xFF},
  { 81,0x00,0xFF},
  { 82,0x00,0xFF},
  { 83,0x00,0xFF},
  { 84,0x90,0xFF},
  { 85,0x31,0xFF},
  { 86,0x00,0xFF},
  { 87,0x00,0xFF},
  { 88,0x01,0xFF},
  { 89,0x00,0xFF},
  { 90,0x00,0xFF},
  { 91,0x00,0x0F},
  {255,0x00,0xFF}  // set page bit to 0
};

inpsw_regs_data_t const inpsw_regs[NUM_INPSW_REGS] __ufmdata_section__  = {
  {  6,{0x08,0x04},0x1D},
  { 29,{0x80,0x60},0xFF},
  { 30,{0xA0,0xA9},0xFF},
  { 48,{0x34,0x39},0x7F},
  { 97,{0xBD,0xE5},0xFF},
  { 98,{0x26,0x2A},0xFF},
  { 99,{0x44,0xAC},0xFF},
  {103,{0x1B,0x31},0xFF},
  {110,{0xC0,0x40},0xC0},
  {114,{0xC0,0x40},0xC0}
};

mode_regs_data_t const si_mode_regs[NUM_CFG_MODE_REGS] __ufmdata_section__  = {
//      NTSC_N64_VGA,NTSC_N64_240p,NTSC_N64_480p,NTSC_N64_720p,NTSC_N64_960p,NTSC_N64_1080p,NTSC_N64_1200p,NTSC_N64_1440p,NTSC_N64_1440Wp,PAL0_N64_288p,PAL0_N64_576p,PAL0_N64_720p,PAL0_N64_960p,PAL0_N64_1080p,PAL0_N64_1200p,PAL0_N64_1440p,PAL0_N64_1440Wp,PAL1_N64_288p,PAL1_N64_576p,PAL1_N64_720p,PAL1_N64_960p,PAL1_N64_1080p,PAL1_N64_1200p,PAL1_N64_1440p,PAL1_N64_1440Wp,FREE_240p_288p,FREE_480p_VGA,FREE_576p,FREE_720p_960p,FREE_1080p_1200p,FREE_1440p
  { 53,{0x7E        ,0x79         ,0x8D         ,0xC2         ,0xD6         ,0x61          ,0x67          ,0x12          ,0x11           ,0x49         ,0x5A         ,0x09         ,0x14         ,0x84          ,0x8F          ,0x2F          ,0x3D           ,0x49         ,0x5A         ,0x09         ,0x14         ,0x84          ,0x8F          ,0x2F          ,0x3D           ,0xBD          ,0xB3         ,0xBD     ,0xD0          ,0x68            ,0x17      }}, // 53
  { 54,{0x29        ,0x26         ,0x26         ,0x0C         ,0x0A         ,0x05          ,0x06          ,0x04          ,0x07           ,0x27         ,0x27         ,0x0D         ,0x0B         ,0x05          ,0x06          ,0x04          ,0x07           ,0x27         ,0x27         ,0x0D         ,0x0B         ,0x05          ,0x06          ,0x04          ,0x07           ,0x26          ,0x26         ,0x26     ,0x0C          ,0x05            ,0x04      }}, // 54
  { 55,{0xB0        ,0x4C         ,0x6C         ,0xE8         ,0x40         ,0x74          ,0xE8          ,0xA8          ,0x44           ,0x1C         ,0x78         ,0x0C         ,0xC0         ,0xB0          ,0x84          ,0x14          ,0x6C           ,0xA0         ,0xA0         ,0x24         ,0x00         ,0x20          ,0xA0          ,0x78          ,0x10           ,0x44          ,0x14         ,0x44     ,0x40          ,0x20            ,0xEC      }}, // 55
  { 56,{0x23        ,0x00         ,0x04         ,0x70         ,0x8E         ,0x38          ,0x01          ,0x0D          ,0x7C           ,0x06         ,0xE8         ,0xDC         ,0x0A         ,0x9C          ,0x00          ,0x97          ,0x73           ,0xB8         ,0x53         ,0x9E         ,0x14         ,0xB6          ,0xFA          ,0xF8          ,0x8F           ,0x00          ,0x08         ,0x00     ,0x00          ,0x00            ,0x6B      }}, // 56
  { 57,{0x00        ,0x00         ,0x00         ,0x00         ,0x00         ,0x00          ,0x00          ,0x00          ,0x00           ,0x03         ,0x00         ,0x01         ,0x00         ,0x02          ,0x00          ,0x08          ,0x0C           ,0x4A         ,0x0B         ,0x05         ,0xFB         ,0x0F          ,0x0B          ,0x33          ,0x97           ,0x00          ,0x00         ,0x00     ,0x00          ,0x00            ,0x00      }}, // 57
  { 59,{0xB6        ,0x15         ,0xB9         ,0xC3         ,0x68         ,0xC3          ,0x0A          ,0x33          ,0x7F           ,0x31         ,0x55         ,0x55         ,0xE4         ,0x55          ,0x31          ,0xB5          ,0x09           ,0x98         ,0xFC         ,0xFF         ,0xA0         ,0xFE          ,0xA8          ,0x3E          ,0x6C           ,0x1B          ,0x99         ,0x1B     ,0x1B          ,0x1B            ,0x43      }}, // 59
  { 60,{0x1C        ,0x00         ,0x01         ,0x1E         ,0x25         ,0x1E          ,0x01          ,0x18          ,0x28           ,0x1B         ,0xD7         ,0xD7         ,0x06         ,0xD7          ,0x00          ,0x3F          ,0xD3           ,0x8C         ,0x17         ,0x85         ,0x8F         ,0x0B          ,0x6E          ,0x7E          ,0xE4           ,0x00          ,0x09         ,0x00     ,0x00          ,0x00            ,0x23      }}, // 60
  { 61,{0x00        ,0x00         ,0x00         ,0x00         ,0x00         ,0x00          ,0x00          ,0x00          ,0x00           ,0x02         ,0x00         ,0x00         ,0x00         ,0x00          ,0x00          ,0x0B          ,0x12           ,0x32         ,0x0A         ,0x02         ,0x9F         ,0x05          ,0x04          ,0x43          ,0xE1           ,0x00          ,0x00         ,0x00     ,0x00          ,0x00            ,0x00      }}, // 61
  { 64,{0x69        ,0x66         ,0x79         ,0xBB         ,0xD0         ,0x5D          ,0x63          ,0x0F          ,0x0D           ,0x38         ,0x49         ,0x03         ,0x0F         ,0x81          ,0x8C          ,0x2C          ,0x39           ,0x38         ,0x49         ,0x03         ,0x0F         ,0x81          ,0x8C          ,0x2C          ,0x39           ,0xBD          ,0x00         ,0xBD     ,0xE2          ,0x6F            ,0x1A      }}, // 64
  { 65,{0x29        ,0x26         ,0x26         ,0x0C         ,0x0A         ,0x05          ,0x06          ,0x04          ,0x07           ,0x27         ,0x27         ,0x0D         ,0x0B         ,0x05          ,0x06          ,0x04          ,0x07           ,0x27         ,0x27         ,0x0D         ,0x0B         ,0x05          ,0x06          ,0x04          ,0x07           ,0x26          ,0x2A         ,0x26     ,0x0A          ,0x06            ,0x07      }}, // 65
  { 66,{0x10        ,0xD8         ,0x4C         ,0x2C         ,0x00         ,0x34          ,0x70          ,0x2C          ,0x58           ,0x00         ,0x90         ,0x0C         ,0x80         ,0x08          ,0x80          ,0x60          ,0xD0           ,0xC0         ,0x24         ,0x0C         ,0xA0         ,0x04          ,0x20          ,0xB0          ,0xF4           ,0x44          ,0x00         ,0x44     ,0x18          ,0xD4            ,0x88      }}, // 66
  { 67,{0x00        ,0x00         ,0x00         ,0x00         ,0x0A         ,0x00          ,0x00          ,0x00          ,0x10           ,0x0D         ,0x7E         ,0x12         ,0x48         ,0x2A          ,0x0E          ,0xAF          ,0xD1           ,0x8C         ,0xBB         ,0x1C         ,0x1B         ,0x1A          ,0xC6          ,0x8E          ,0xFD           ,0x00          ,0x00         ,0x00     ,0x58          ,0x02            ,0xC7      }}, // 67
  { 68,{0x00        ,0x00         ,0x00         ,0x00         ,0x00         ,0x00          ,0x00          ,0x00          ,0x00           ,0x60         ,0x0E         ,0x04         ,0x1A         ,0x0E          ,0x03          ,0xB2          ,0x5D           ,0x18         ,0x03         ,0x04         ,0x07         ,0x07          ,0x00          ,0x59          ,0x57           ,0x00          ,0x00         ,0x00     ,0x00          ,0x00            ,0x00      }}, // 68
  { 69,{0x00        ,0x00         ,0x00         ,0x00         ,0x00         ,0x00          ,0x00          ,0x00          ,0x00           ,0x00         ,0x00         ,0x00         ,0x00         ,0x00          ,0x00          ,0x00          ,0x01           ,0x00         ,0x00         ,0x00         ,0x00         ,0x00          ,0x00          ,0x00          ,0x01           ,0x00          ,0x00         ,0x00     ,0x00          ,0x00            ,0x00      }}, // 69
  { 70,{0x1C        ,0x07         ,0x15         ,0x0F         ,0x90         ,0x0F          ,0x4C          ,0x3B          ,0x92           ,0x98         ,0xFC         ,0xFF         ,0xA0         ,0xFE          ,0xA8          ,0x3E          ,0x6C           ,0x26         ,0xFF         ,0xFF         ,0xE8         ,0xFF          ,0xAA          ,0x1F          ,0x1B           ,0x1B          ,0x01         ,0x1B     ,0x0D          ,0xE5            ,0x0B      }}, // 70
  { 71,{0x00        ,0x01         ,0x00         ,0x00         ,0x03         ,0x00          ,0x00          ,0x00          ,0x0B           ,0x8C         ,0x17         ,0x85         ,0x8F         ,0x0B          ,0x6E          ,0x7E          ,0xE4           ,0xA3         ,0x85         ,0x85         ,0xE3         ,0x85          ,0x1B          ,0xBF          ,0x79           ,0x00          ,0x00         ,0x00     ,0x1A          ,0x02            ,0x27      }}, // 71
  { 72,{0x00        ,0x00         ,0x00         ,0x00         ,0x00         ,0x00          ,0x00          ,0x00          ,0x00           ,0x32         ,0x0A         ,0x02         ,0x9F         ,0x05          ,0x04          ,0x43          ,0xE1           ,0x0C         ,0x02         ,0x02         ,0x27         ,0x02          ,0x01          ,0x21          ,0x38           ,0x00          ,0x00         ,0x00     ,0x00          ,0x00            ,0x01      }}  // 72
};
//      NTSC_N64_VGA,NTSC_N64_240p,NTSC_N64_480p,NTSC_N64_720p,NTSC_N64_960p,NTSC_N64_1080p,NTSC_N64_1200p,NTSC_N64_1440p,NTSC_N64_1440Wp,PAL0_N64_288p,PAL0_N64_576p,PAL0_N64_720p,PAL0_N64_960p,PAL0_N64_1080p,PAL0_N64_1200p,PAL0_N64_1440p,PAL0_N64_1440Wp,PAL1_N64_288p,PAL1_N64_576p,PAL1_N64_720p,PAL1_N64_960p,PAL1_N64_1080p,PAL1_N64_1200p,PAL1_N64_1440p,PAL1_N64_1440Wp,FREE_240p_288p,FREE_480p_VGA,FREE_576p,FREE_720p_960p,FREE_1080p_1200p,FREE_1440p


#endif /* SI5356_REGS_P_ */
