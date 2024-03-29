/*********************************************************************************
 *
 * This file is part of the N64 RGB/YPbPr DAC project.
 *
 * Copyright (C) 2015-2024 by Peter Bartmann <borti4938@gmail.com>
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
#include "common_types.h"
#include "si5356.h"


#ifndef SI5356_REGS_P_
#define SI5356_REGS_P_

#define NUM_INIT_REGS           101
#define NUM_INPSW_REGS            9
#define NUM_VARIABLE_MSx_REGS   (9+9)

typedef struct init_regs_data_t {
   unsigned char reg_addr;
   unsigned char reg_val;
#ifndef DEBUG
   unsigned char reg_mask;
#endif
} init_regs_data_t;

typedef struct inpsw_regs_data_t {
   unsigned char reg_addr;
   unsigned char reg_val[NUM_CLK_SOURCES];
#ifndef DEBUG
   unsigned char reg_mask;
#endif
} inpsw_regs_data_t;


#ifndef DEBUG
  init_regs_data_t const init_regs[NUM_INIT_REGS] __ufmdata_section__ = {
    { 27,0x70,0x80},
    { 28,0x37,0xFF},
    { 30,0xA9,0xFF},
    { 31,0xC0,0xFF},
    { 32,0xC0,0xFF},
    { 33,0xE3,0xFF},
    { 34,0xE3,0xFF},
    { 35,0x05,0xFF},
    { 36,0x11,0x1F},
    { 37,0x11,0x1F},
    { 38,0x10,0x1F},
    { 39,0x10,0x1F},
    { 40,0x73,0xFF},
    { 41,0x5E,0x7F},
    { 42,0x37,0x3F},
    { 47,0x14,0x3C},
    { 49,0x90,0x7F},
    { 50,0xDE,0xC0},
    { 52,0x10,0x0C},
    { 62,0x00,0x3F},
    { 63,0x10,0x0C},
    { 73,0x00,0x3F},
    { 74,0x10,0x0C},
    { 85,0x10,0x0C},
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
    { 48,{0x33,0x39},0x7F},
    { 97,{0xBD,0xE5},0xFF},
    { 98,{0x26,0x2A},0xFF},
    { 99,{0x44,0xAC},0xFF},
    {103,{0x1B,0x31},0xFF},
    {110,{0xC0,0x40},0xC0},
    {114,{0xC0,0x40},0xC0}
  };
#else
  init_regs_data_t const init_regs[NUM_INIT_REGS] __ufmdata_section__ = {
    { 27,0x70},
    { 28,0x37},
    { 30,0xA9},
    { 31,0xC0},
    { 32,0xC0},
    { 33,0xE3},
    { 34,0xE3},
    { 35,0x05},
    { 36,0x11},
    { 37,0x11},
    { 38,0x10},
    { 39,0x10},
    { 40,0x73},
    { 41,0x5E},
    { 42,0x37},
    { 47,0x14},
    { 49,0x90},
    { 50,0xDE},
    { 52,0x10},
    { 62,0x00},
    { 63,0x10},
    { 73,0x00},
    { 74,0x10},
    { 85,0x10},
    {100,0x00},
    {101,0x00},
    {102,0x00},
    {104,0x00},
    {105,0x00},
    {106,0x80},
    {107,0x00},
    {108,0x00},
    {111,0x00},
    {112,0x00},
    {115,0x00},
    {116,0x80},
    {118,0x40},
    {119,0x00},
    {120,0x00},
    {122,0x40},
    {129,0x00},
    {130,0x00},
    {144,0x00},
    {158,0x00},
    {159,0x00},
    {181,0x00},
    {203,0x00},
    {255,0x01}, // set page bit to 1
    { 31,0x00},
    { 32,0x00},
    { 33,0x01},
    { 34,0x00},
    { 35,0x00},
    { 36,0x90},
    { 37,0x31},
    { 38,0x00},
    { 39,0x00},
    { 40,0x01},
    { 41,0x00},
    { 42,0x00},
    { 43,0x00},
    { 47,0x00},
    { 48,0x00},
    { 49,0x01},
    { 50,0x00},
    { 51,0x00},
    { 52,0x90},
    { 53,0x31},
    { 54,0x00},
    { 55,0x00},
    { 56,0x01},
    { 57,0x00},
    { 58,0x00},
    { 59,0x00},
    { 63,0x00},
    { 64,0x00},
    { 65,0x01},
    { 66,0x00},
    { 67,0x00},
    { 68,0x90},
    { 69,0x31},
    { 70,0x00},
    { 71,0x00},
    { 72,0x01},
    { 73,0x00},
    { 74,0x00},
    { 75,0x00},
    { 79,0x00},
    { 80,0x00},
    { 81,0x00},
    { 82,0x00},
    { 83,0x00},
    { 84,0x90},
    { 85,0x31},
    { 86,0x00},
    { 87,0x00},
    { 88,0x01},
    { 89,0x00},
    { 90,0x00},
    { 91,0x00},
    {255,0x00}  // set page bit to 0
  };

  inpsw_regs_data_t const inpsw_regs[NUM_INPSW_REGS] __ufmdata_section__  = {
    {  6,{0x08,0x04}},
    { 29,{0x80,0x60}},
    { 48,{0x34,0x39}},
    { 97,{0xBD,0xE5}},
    { 98,{0x26,0x2A}},
    { 99,{0x44,0xAC}},
    {103,{0x1B,0x31}},
    {110,{0xC0,0x40}},
    {114,{0xC0,0x40}}
  };
#endif

#define MS_REGVALS_USED 9

// msa registers: #define MSA_Px_REGS(x)        (53 + x)
const unsigned char msx_reg_addr[NUM_VARIABLE_MSx_REGS] __ufmdata_section__  = {
  53, 54, 55, 56, 57, 58, 59, 60, 61, // MSA register addresses (register 62 is constant and set during init)
  64, 65, 66, 67, 68, 69, 70, 71, 72  // MSB register addresses (register 73 is constant and set during init)
};
const unsigned char msx_reg_vals[NUM_SUPPORTED_CONFIGS][NUM_VARIABLE_MSx_REGS] __ufmdata_section__  = {
  {0xD2,0x54,0x10,0x00,0x00,0x00,0x0E,0x00,0x00,
   0xD2,0x54,0x10,0x00,0x00,0x00,0x0E,0x00,0x00 },  // NTSC_N64_DIRECT
  {0x7E,0x29,0xB0,0x23,0x00,0x00,0xB6,0x1C,0x00,
   0x69,0x29,0x10,0x00,0x00,0x00,0x1C,0x00,0x00 },  // NTSC_N64_VGA
  {0x8D,0x26,0x6C,0x04,0x00,0x00,0xB9,0x01,0x00,
   0x79,0x26,0x4C,0x00,0x00,0x00,0x15,0x00,0x00 },  // NTSC_N64_480p
  {0xC2,0x0C,0xE8,0x70,0x00,0x00,0xC3,0x1E,0x00,
   0xBB,0x0C,0x2C,0x00,0x00,0x00,0x0F,0x00,0x00 },  // NTSC_N64_720p
  {0xD6,0x0A,0x40,0x8E,0x00,0x00,0x68,0x25,0x00,
   0xD0,0x0A,0x00,0x0A,0x00,0x00,0x90,0x03,0x00 },  // NTSC_N64_960p
  {0x61,0x05,0x74,0x38,0x00,0x00,0xC3,0x1E,0x00,
   0x5D,0x05,0x34,0x00,0x00,0x00,0x0F,0x00,0x00 },  // NTSC_N64_1080p
  {0x67,0x06,0xE8,0x01,0x00,0x00,0x0A,0x01,0x00,
   0x63,0x06,0x70,0x00,0x00,0x00,0x4C,0x00,0x00 },  // NTSC_N64_1200p
  {0x12,0x04,0xA8,0x0D,0x00,0x00,0x33,0x18,0x00,
   0x0F,0x04,0x2C,0x00,0x00,0x00,0x3B,0x00,0x00 },  // NTSC_N64_1440p
  {0x11,0x07,0x44,0x7C,0x00,0x00,0x7F,0x28,0x00,
   0x0D,0x07,0x58,0x10,0x00,0x00,0x92,0x0B,0x00 },  // NTSC_N64_1440Wp
  {0x83,0x56,0x6C,0x23,0x19,0x00,0x37,0x41,0x07,
   0x83,0x56,0xEC,0x88,0x82,0x00,0x17,0xAA,0x25 },  // PAL0_N64_DIRECT
  {0x54,0x2A,0x10,0xB5,0x00,0x00,0xB3,0xE5,0x02,
   0x41,0x2A,0xA4,0x98,0x8C,0x00,0x17,0xAA,0x25 },  // PAL0_N64_VGA
  {0x5A,0x27,0x78,0xE8,0x00,0x00,0x55,0xD7,0x00,
   0x49,0x27,0x90,0x7E,0x0E,0x00,0xFC,0x17,0x0A },  // PAL0_N64_576p
  {0x09,0x0D,0x0C,0xDC,0x01,0x00,0x55,0xD7,0x00,
   0x03,0x0D,0x0C,0x12,0x04,0x00,0xFF,0x85,0x02 },  // PAL0_N64_720p
  {0x14,0x0B,0xC0,0x0A,0x00,0x00,0xE4,0x06,0x00,
   0x0F,0x0B,0x80,0x48,0x1A,0x00,0xA0,0x8F,0x9F },  // PAL0_N64_960p
  {0x84,0x05,0xB0,0x9C,0x02,0x00,0x55,0xD7,0x00,
   0x81,0x05,0x08,0x2A,0x0E,0x00,0xFE,0x0B,0x05 },  // PAL0_N64_1080p
  {0x8F,0x06,0x84,0x00,0x00,0x00,0x31,0x00,0x00,
   0x8C,0x06,0x80,0x0E,0x03,0x00,0xA8,0x6E,0x04 },  // PAL0_N64_1200p
  {0x2F,0x04,0x14,0x97,0x08,0x00,0xB5,0x3F,0x0B,
   0x2C,0x04,0x60,0xAF,0xB2,0x00,0x3E,0x7E,0x43 },  // PAL0_N64_1440p
  {0x3D,0x07,0x6C,0x73,0x0C,0x00,0x09,0xD3,0x12,
   0x39,0x07,0xD0,0xD1,0x5D,0x01,0x6C,0xE4,0xE1 },  // PAL0_N64_1440Wp
  {0x83,0x56,0x7C,0x64,0x4F,0x01,0xCB,0x4F,0x5E,
   0x83,0x56,0xEC,0xF8,0x85,0x00,0x17,0xAA,0x25 },  // PAL1_N64_DIRECT
  {0x54,0x2A,0xD0,0xE9,0x0A,0x00,0x17,0xAA,0x25,
   0x41,0x2A,0xA4,0x50,0x8E,0x00,0x17,0xAA,0x25 },  // PAL1_N64_VGA
  {0x5A,0x27,0xA0,0x53,0x0B,0x00,0xFC,0x17,0x0A,
   0x49,0x27,0x24,0xBB,0x03,0x00,0xFF,0x85,0x02 },  // PAL1_N64_576p
  {0x09,0x0D,0x24,0x9E,0x05,0x00,0xFF,0x85,0x02,
   0x03,0x0D,0x0C,0x1C,0x04,0x00,0xFF,0x85,0x02 },  // PAL1_N64_720p
  {0x14,0x0B,0x00,0x14,0xFB,0x00,0xA0,0x8F,0x9F,
   0x0F,0x0B,0xA0,0x1B,0x07,0x00,0xE8,0xE3,0x27 },  // PAL1_N64_960p
  {0x84,0x05,0x20,0xB6,0x0F,0x00,0xFE,0x0B,0x05,
   0x81,0x05,0x04,0x1A,0x07,0x00,0xFF,0x85,0x02 },  // PAL1_N64_1080p
  {0x8F,0x06,0xA0,0xFA,0x0B,0x00,0xA8,0x6E,0x04,
   0x8C,0x06,0x20,0xC6,0x00,0x00,0xAA,0x1B,0x01 },  // PAL1_N64_1200p
  {0x2F,0x04,0x78,0xF8,0x33,0x00,0x3E,0x7E,0x43,
   0x2C,0x04,0xB0,0x8E,0x59,0x00,0x1F,0xBF,0x21 },  // PAL1_N64_1440p
  {0x3D,0x07,0x10,0x8F,0x97,0x00,0x6C,0xE4,0xE1,
   0x39,0x07,0xF4,0xFD,0x57,0x00,0x1B,0x79,0x38 },  // PAL1_N64_1440Wp
  {0x00,0x2A,0x00,0x00,0x00,0x00,0x01,0x00,0x00,
   0xB3,0x26,0x14,0x08,0x00,0x00,0x99,0x09,0x00 },  // FREE_VGA60_480p
  {0xAC,0x29,0xF0,0x00,0x00,0x00,0x93,0x01,0x00,
   0xBD,0x26,0x44,0x00,0x00,0x00,0x1B,0x00,0x00 },  // FREE_VGA50_576p
  {0xD0,0x0C,0x40,0x00,0x00,0x00,0x1B,0x00,0x00,
   0xE2,0x0A,0x18,0x58,0x00,0x00,0x0D,0x1A,0x00 },  // FREE_720p_960p
  {0x68,0x05,0x20,0x00,0x00,0x00,0x1B,0x00,0x00,
   0x6F,0x06,0xD4,0x02,0x00,0x00,0xE5,0x02,0x00 },  // FREE_1080p_1200p
  {0x17,0x04,0xEC,0x6B,0x00,0x00,0x43,0x23,0x00,
   0x1A,0x07,0x88,0xC7,0x00,0x00,0x0B,0x27,0x01 }   // FREE_1440p
};


#endif /* SI5356_REGS_P_ */
