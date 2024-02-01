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
#include "common_types.h"
#include "i2c.h"


#define SI5356_INIT_FAILED_0 140 // ToDo: move codes into separate header file?
#define SI5356_INIT_FAILED_1 141

#define MSx_SETUP_REG(x)          (31 + x) // max. x is 3 (for A, B, C, and D)
  #define MSx_SETUP_NORMAL_UP_VAL   0xC0
  #define MSx_SETUP_DOWN_VAL        0xE3
#define MSA_Px_REGS(x)          (53 + x) // max. x is 9
#define MSB_Px_REGS(x)          (64 + x) // max. x is 9
#define MSC_Px_REGS(x)          (75 + x) // max. x is 9
#define MSD_Px_REGS(x)          (86 + x) // max. x is 9
#define PLL_LOSSLOCK_REG        218
  #define PLL_LOSSLOCK_BIT        4
#define CLKx_PWD_REG(x)         (31 + x)
#define OEB_REG                 230
  #define OEB_REG_VAL_OFF         0x1F
  #define OEB_REG_VAL_ALL_ON      0x00 // OEB register; just use CLK0/1 and CLK2/3
  #define OEB_REG_VAL_AB_ON       0x0C // OEB register; just use CLK0/1 and CLK2/3
  #define OEB_REG_VAL_A_ON        0x0E // OEB register; just use CLK0/1 (e.g. 240p/288p and 1440p)
#define DIS_LOL_REG             241
  #define DIS_LOL_REG_VAL         0x65
#define SOFT_RST_REG            246
  #define SOFT_RST_BIT            1


#define SI5356_CLKx_POWER_UP(x)    (i2c_writereg(SI5356_I2C_BASE,MSx_SETUP_REG(x),MSx_SETUP_NORMAL_UP_VAL))
#define SI5356_CLKx_POWER_DOWN(x)  (i2c_writereg(SI5356_I2C_BASE,MSx_SETUP_REG(x),MSx_SETUP_DOWN_VAL))
#define SI5356_PLL_LOCKSTATUS()   ((i2c_readreg(SI5356_I2C_BASE,PLL_LOSSLOCK_REG) & (1<<PLL_LOSSLOCK_BIT)) == 0x00)


typedef enum {
  IN12 = 0, // free running
  IN4       // source synchronous
} si_clk_src_t;
#define NUM_CLK_SOURCES 2


int check_si5356(void);
bool_t configure_clk_si5356(clk_config_t target_cfg);
void init_si5356(void);


#endif /* SI5356_H_ */
