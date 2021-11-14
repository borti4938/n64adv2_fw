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
 * si5356.h
 *
 *  Created on: 12.03.2021
 *      Author: Peter Bartmann
 *
 ********************************************************************************/

#ifndef SI5356_H_
#define SI5356_H_


#include "system.h"
#include "alt_types.h"
#include "config.h"

#define SI5356_I2C_BASE 0x70

#define SI5356_INIT_FAILED_0 140 // ToDo: move codes into separate header file?
#define SI5356_INIT_FAILED_1 141


typedef enum {
  vVGA = 0,
  v480p,
  v576p,
  v720p,
  v1080p
} output_res_t;

typedef enum {
  IN12 = 0, // free running
  IN4       // source synchronous
} si_clk_src_t;
#define NUM_CLK_SOURCES 2

typedef enum {
  NTSC_N64_VGA = 0,
  NTSC_N64_480p,
  NTSC_N64_720p,
  NTSC_N64_960p,
  NTSC_N64_1080p,
  NTSC_N64_1200p,
  PAL0_N64_576p,
  PAL0_N64_720p,
  PAL0_N64_960p,
  PAL0_N64_1080p,
  PAL0_N64_1200p,
  PAL1_N64_576p,
  PAL1_N64_720p,
  PAL1_N64_960p,
  PAL1_N64_1080p,
  PAL1_N64_1200p,
  FREE_480p_VGA,
  FREE_576p,
  FREE_720p_960p,
  FREE_1080p_1200p
} clk_config_t;
#define NUM_SUPPORTED_CONFIGS 20

int check_si5356(void);
void init_si5356(clk_config_t target_cfg);
void configure_clk_si5356(clk_config_t target_cfg);
alt_u8 si5356_readreg(alt_u8 regaddr);
void si5356_writereg(alt_u8 regaddr, alt_u8 data, alt_u8 regmask);


#endif /* SI5356_H_ */
