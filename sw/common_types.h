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


#endif /* COMMON_TYPES_H_ */
