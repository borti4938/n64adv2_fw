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
 * i2c.h
 *
 *  Created on: 02.12.2022
 *      Author: Peter Bartmann
 *
 ********************************************************************************/

#ifndef I2C_H_
#define I2C_H_


#include "system.h"
#include "alt_types.h"

#define ADV7513_I2C_BASE    (0x72>>1)
#define SI5356_I2C_BASE     (0xE0>>1)

void i2c_reg_bitset(alt_u8 i2c_dev, alt_u8 regaddr, alt_u8 bit);
void i2c_reg_bitclear(alt_u8 i2c_dev, alt_u8 regaddr, alt_u8 bit);
alt_u8 i2c_readreg(alt_u8 i2c_dev, alt_u8 regaddr);
void i2c_writereg(alt_u8 i2c_dev, alt_u8 regaddr, alt_u8 data);


#endif /* I2C_H_ */
