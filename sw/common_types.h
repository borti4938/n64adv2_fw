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
 * common_types.h
 *
 *  Created on: 05.01.2024
 *      Author: Peter Bartmann
 *
 ********************************************************************************/

#ifndef COMMON_TYPES_H_
#define COMMON_TYPES_H_


typedef enum {
  FALSE = 0,
  TRUE
} bool_t;
typedef bool_t boolean_t;

typedef enum {
  PPU_NTSC = 0,
  PPU_PAL,
  PPU_REGION_CURRENT
} cfg_region_sel_type_t;
#define NUM_REGION_MODES  PPU_REGION_CURRENT

typedef enum {
  NTSC = 0,
  PAL
} vmode_t;
#define LINEX_TYPES 2

typedef enum {
  PROGRESSIVE = 0,
  INTERLACED
} scanmode_t;

typedef enum {
  AUTO_HZ = 0,
  FORCE_60HZ,
  FORCE_50HZ
} vsync_mode_t;

typedef enum {
  NTSC_N64_VGA = 0,
  NTSC_N64_240p,
  NTSC_N64_480p,
  NTSC_N64_720p,
  NTSC_N64_960p,
  NTSC_N64_1080p,
  NTSC_N64_1200p,
  NTSC_N64_1440p,
  NTSC_N64_1440Wp,
  PAL0_N64_VGA,
  PAL0_N64_288p,
  PAL0_N64_576p,
  PAL0_N64_720p,
  PAL0_N64_960p,
  PAL0_N64_1080p,
  PAL0_N64_1200p,
  PAL0_N64_1440p,
  PAL0_N64_1440Wp,
  PAL1_N64_VGA,
  PAL1_N64_288p,
  PAL1_N64_576p,
  PAL1_N64_720p,
  PAL1_N64_960p,
  PAL1_N64_1080p,
  PAL1_N64_1200p,
  PAL1_N64_1440p,
  PAL1_N64_1440Wp,
  FREE_240p_288p, // use only CLK0/1
  FREE_480p_VGA,
  FREE_576p_VGA,
  FREE_720p_960p,
  FREE_1080p_1200p,
  FREE_1440p
} clk_config_t;
#define NUM_SUPPORTED_CONFIGS (FREE_1440p+1)


#endif /* COMMON_TYPES_H_ */
