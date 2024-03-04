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
 * i2c.c
 *
 *  Created on: 02.12.2022
 *      Author: Peter Bartmann
 *
 ********************************************************************************/

#include "app_cfg.h"
#include "i2c.h"

#include "unistd.h"
#include "stdio.h"
#include "alt_types.h"
#include "common_types.h"
#include "i2c_opencores.h"
#include "system.h"
#include "altera_avalon_pio_regs.h"


void i2c_reg_bitset(alt_u8 i2c_dev, alt_u8 regaddr, alt_u8 bit) {
  if (bit > 7) return;
  i2c_writereg(i2c_dev, regaddr,(i2c_readreg(i2c_dev, regaddr) | (1 << bit)));
}

void i2c_reg_bitclear(alt_u8 i2c_dev, alt_u8 regaddr, alt_u8 bit) {
  if (bit > 7) return;
  i2c_writereg(i2c_dev, regaddr,(i2c_readreg(i2c_dev, regaddr) & ~(1 << bit)));
}

alt_u8 i2c_readreg(alt_u8 i2c_dev, alt_u8 regaddr)
{
  //Phase 1
  I2C_start(I2C_MASTER_BASE, i2c_dev, 0);
  I2C_write(I2C_MASTER_BASE, regaddr, 0);

  //Phase 2
  I2C_start(I2C_MASTER_BASE, i2c_dev, 1);
  return (alt_u8) I2C_read(I2C_MASTER_BASE,1);
}

void i2c_writereg(alt_u8 i2c_dev, alt_u8 regaddr, alt_u8 data)
{
  I2C_start(I2C_MASTER_BASE, i2c_dev, 0);
  I2C_write(I2C_MASTER_BASE, regaddr, 0);
  I2C_write(I2C_MASTER_BASE, data, 1);
}
