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
 * adv7513.h
 *
 *  Created on: 11.09.2018
 *      Author: Peter Bartmann
 *
 ********************************************************************************/

#include "system.h"
#include "alt_types.h"
#include "config.h"


#ifndef ADV7513_H_
#define ADV7513_H_

#define ADV7513_CHIP_ID     0x13
#define ADV7513_I2C_BASE    (0x72>>1)
#define ADV7513_REG_STATUS  0x42

#define ADV_INIT_FAILED 150 // ToDo: move codes into separate header file?

#define ADV_POWER_RDY()           ((adv7513_readreg(ADV7513_REG_STATUS) & 0x70) == 0x70)
#define ADV_HPD_STATE()           ((adv7513_readreg(ADV7513_REG_STATUS) & 0x40) == 0x40)
#define ADV_MONITOR_SENSE_STATE() ((adv7513_readreg(ADV7513_REG_STATUS) & 0x20) == 0x20)

typedef enum {
  RGB_full = 0,
  RGB_limited,
  YCbCr_601_full,
  YCbCr_601_limited,
  YCbCr_709_full,
  YCbCr_709_limited
} color_format_t;

#define MAX_COLOR_FORMATS  YCbCr_709_limited

typedef enum {
  PR_AUTO = 0,
  PR_MANUAL
} pr_mode_t;


alt_u8 adv7513_readreg(alt_u8 regaddr);
void adv7513_writereg(alt_u8 regaddr,alt_u8 data);
void set_cfg_adv7513(void);
int check_adv7513(void);
void init_adv7513(void);


#endif /* ADV7513_H_ */
