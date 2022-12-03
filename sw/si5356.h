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
#include "i2c.h"


#define SI5356_INIT_FAILED_0 140 // ToDo: move codes into separate header file?
#define SI5356_INIT_FAILED_1 141

#define PLL_LOSSLOCK_REG      218
  #define PLL_LOSSLOCK_BIT      4
#define OEB_REG               230
  #define OEB_REG_VAL_OFF       0x1F
  #define OEB_REG_VAL_ALL_ON    0x0C // OEB register; just use CLK0/1 and CLK2/3
  #define OEB_REG_VAL_SINGLE_ON 0x0E // OEB register; just use CLK0/1 (e.g. 240p/288p and 1440p)
#define DIS_LOL_REG           241
  #define DIS_LOL_REG_VAL       0x65
#define SOFT_RST_REG          246
  #define SOFT_RST_BIT          1


typedef enum {
  IN12 = 0, // free running
  IN4       // source synchronous
} si_clk_src_t;
#define NUM_CLK_SOURCES 2

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
  PAL0_N64_288p,
  PAL0_N64_576p,
  PAL0_N64_720p,
  PAL0_N64_960p,
  PAL0_N64_1080p,
  PAL0_N64_1200p,
  PAL0_N64_1440p,
  PAL0_N64_1440Wp,
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
  FREE_576p,
  FREE_720p_960p,
  FREE_1080p_1200p,
  FREE_1440p
} clk_config_t;
#define NUM_SUPPORTED_CONFIGS (FREE_1440p+1)

#define SI5356_PLL_LOCKSTATUS() ((i2c_readreg(SI5356_I2C_BASE,PLL_LOSSLOCK_REG) & (1<<PLL_LOSSLOCK_BIT)) == 0x00)

int check_si5356(void);
bool_t init_si5356(clk_config_t target_cfg);
bool_t configure_clk_si5356(clk_config_t target_cfg);


#endif /* SI5356_H_ */
