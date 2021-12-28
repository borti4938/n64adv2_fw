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
 * si5356.c
 *
 *  Created on: 12.03.2021
 *      Author: Peter Bartmann
 *
 * File created with the help of ClockBuilder Pro v2.29 [2018-11-04]
 *
 ********************************************************************************/

#include "unistd.h"
#include "alt_types.h"
#include "i2c_opencores.h"
#include "system.h"
#include "altera_avalon_pio_regs.h"

#include "si5356.h"
#include "si5356_regs_p.h"
#include "config.h"
#include "n64.h"
#include "led.h"

#define PLL_LOCK_2_FPGA_TIMEOUT_US  150


void si5356_clr_ready_bit() {
  info_sync_val = info_sync_val & SI_CFG_RDY_CLR_MASK;
  IOWR_ALTERA_AVALON_PIO_DATA(INFO_SYNC_OUT_BASE,info_sync_val);
}

void si5356_set_ready_bit() {
  info_sync_val = (info_sync_val & SYNC_INFO_OUT_ALL_MASK) | SI_CFG_RDY_SET_MASK;
  IOWR_ALTERA_AVALON_PIO_DATA(INFO_SYNC_OUT_BASE,info_sync_val);
}

void si5356_reg_bitset(alt_u8 regaddr, alt_u8 bit, alt_u8 regmask) {
  if (bit > 7) return;
  if ((1 << bit) & regmask) si5356_writereg(regaddr,(si5356_readreg(regaddr) | (1 << bit)),regmask);
}

void si5351a_reg_bitclear(alt_u8 regaddr, alt_u8 bit, alt_u8 regmask) {
  if (bit > 7) return;
  if ((1 << bit) & regmask) si5356_writereg(regaddr,(si5356_readreg(regaddr) & ~(1 << bit)),regmask);
}

int check_si5356()
{
  alt_u8 retval = si5356_readreg(0x00);
  if ( retval == 0xff) return -SI5356_INIT_FAILED_0;
  retval &= 0x07;
  if (retval > 1) return -SI5356_INIT_FAILED_1;
  return 0;
}

void init_si5356(clk_config_t target_cfg) {

  led_drive(LED_1, LED_ON);
  si5356_clr_ready_bit();
  int i;
  
  si5356_writereg(OEB_REG,OEB_REG_VAL_OFF,0xFF);      // disable outputs
  si5356_writereg(DIS_LOL_REG,DIS_LOL_REG_VAL,0xFF);  // write needed for proper operation

  for (i=0; i<NUM_INIT_REGS; i++)
    si5356_writereg(init_regs[i].reg_addr,init_regs[i].reg_val,init_regs[i].reg_mask);

  configure_clk_si5356(target_cfg);
}

void configure_clk_si5356(clk_config_t target_cfg) {
  led_drive(LED_1, LED_ON);
	si5356_clr_ready_bit();
  
  int i;
  si5356_writereg(OEB_REG,OEB_REG_VAL_OFF,0xFF);      // disable outputs
  
  si_clk_src_t clk_src = target_cfg < FREE_480p_VGA;
  for (i=0; i<NUM_INPSW_REGS; i++)
    si5356_writereg(inpsw_regs[i].reg_addr,inpsw_regs[i].reg_val[clk_src],inpsw_regs[i].reg_mask);
  
  for (i=0; i<NUM_CFG_MODE_REGS; i++)
    si5356_writereg(si_mode_regs[i].reg_addr,si_mode_regs[i].reg_val[target_cfg],0xFF);

//  si5356_reg_bitset(SOFT_RST_REG,SOFT_RST_BIT,0xFF);    // soft reset
  si5356_writereg(SOFT_RST_REG,(1<<SOFT_RST_BIT),0xFF); // soft reset
  si5356_writereg(OEB_REG,OEB_REG_VAL_ON,0xFF);         // enable outputs
  
  while (!SI5356_PLL_LOCKSTATUS()) {};  // wait for PLL lock
  usleep(PLL_LOCK_2_FPGA_TIMEOUT_US);
  si5356_set_ready_bit();
  led_drive(LED_1, LED_OFF);
}


alt_u8 si5356_readreg(alt_u8 regaddr)
{
  //Phase 1
  I2C_start(I2C_MASTER_BASE, SI5356_I2C_BASE, 0);
  I2C_write(I2C_MASTER_BASE, regaddr, 0);

  //Phase 2
  I2C_start(I2C_MASTER_BASE, SI5356_I2C_BASE, 1);
  return (alt_u8) I2C_read(I2C_MASTER_BASE,1);
}

void si5356_writereg(alt_u8 regaddr, alt_u8 data, alt_u8 regmask)
{
  alt_u8 wr_data;
  if (regmask == 0xFF) wr_data = data;
  else wr_data = (data & regmask) | (si5356_readreg(regaddr) & ~regmask);  // do not touch bits outside of regmask
  I2C_start(I2C_MASTER_BASE, SI5356_I2C_BASE, 0);
  I2C_write(I2C_MASTER_BASE, regaddr, 0);
  I2C_write(I2C_MASTER_BASE, wr_data, 1);
}

