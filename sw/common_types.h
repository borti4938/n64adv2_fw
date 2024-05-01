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
  OFF = 0,
  ON
} cfg_offon_t;

typedef enum {
  NTSC = 0,
  PAL
} vmode_t;
#define LINEX_MODES (PAL+1)

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
  NTSC_N64_DIRECT = 0,
  NTSC_N64_VGA,
  NTSC_N64_480p,
  NTSC_N64_720p,
  NTSC_N64_960p,
  NTSC_N64_1080p,
  NTSC_N64_1200p,
  NTSC_N64_1440p,
  NTSC_N64_1440Wp,
  PAL0_N64_DIRECT,
  PAL0_N64_VGA,
  PAL0_N64_576p,
  PAL0_N64_720p,
  PAL0_N64_960p,
  PAL0_N64_1080p,
  PAL0_N64_1200p,
  PAL0_N64_1440p,
  PAL0_N64_1440Wp,
  PAL1_N64_DIRECT,
  PAL1_N64_VGA,
  PAL1_N64_576p,
  PAL1_N64_720p,
  PAL1_N64_960p,
  PAL1_N64_1080p,
  PAL1_N64_1200p,
  PAL1_N64_1440p,
  PAL1_N64_1440Wp,
  FREE_VGA60_480p, // use only CLK0/1 from here on
  FREE_VGA50_576p,
  FREE_720p_960p,
  FREE_1080p_1200p,
  FREE_1440p
} clk_config_t;
#define NUM_SUPPORTED_CONFIGS (FREE_1440p+1)
#define LAST_LLM_CLOCK_CONFIG (PAL1_N64_1440Wp)


#endif /* COMMON_TYPES_H_ */
