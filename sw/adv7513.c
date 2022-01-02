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
 * adv7513.c
 *
 *  Created on: 11.09.2018
 *      Author: Peter Bartmann
 *
 ********************************************************************************/


#include "alt_types.h"
#include "i2c_opencores.h"
#include "system.h"
#include "altera_avalon_pio_regs.h"

#include "adv7513.h"
#include "adv7513_regs_p.h"
#include "n64.h"
#include "config.h"
#include "led.h"


void adv7513_reg_bitset(alt_u8 regaddr, alt_u8 bit) {
  if (bit > 7) return;
  adv7513_writereg(regaddr,(adv7513_readreg(regaddr) | (1 << bit)));
}

void adv7513_reg_bitclear(alt_u8 regaddr, alt_u8 bit) {
  if (bit > 7) return;
  adv7513_writereg(regaddr,(adv7513_readreg(regaddr) & ~(1 << bit)));
}

void set_pr_manual(alt_u8 pr_send) {
  switch (pr_send) {
    case 2:
      adv7513_writereg(ADV7513_REG_PIXEL_REPETITION,0x12);
      break;
    case 4:
      adv7513_writereg(ADV7513_REG_PIXEL_REPETITION,0x14);
      break;
    default:
      adv7513_writereg(ADV7513_REG_PIXEL_REPETITION,0x10);
  }
}

void set_vclk_div(alt_u8 divider) {
  switch (divider) {
    case 2:
      adv7513_writereg(ADV7513_REG_INPUT_CLK_DIV, 0x65);
      adv7513_reg_bitset(ADV7513_REG_INT1(2), 6);
      break;
    case 4:
      adv7513_writereg(ADV7513_REG_INPUT_CLK_DIV, 0x67);
      adv7513_reg_bitset(ADV7513_REG_INT1(2), 6);
      break;
    default:
      adv7513_writereg(ADV7513_REG_INPUT_CLK_DIV, 0x61);
      adv7513_reg_bitclear(ADV7513_REG_INT1(2), 6);
  }
}

void set_avi_info(void) {
  linex_cnt linex_val = cfg_get_value(&linex_resolution,0);

  adv7513_writereg(ADV7513_REG_INFOFRAME_UPDATE, 0x80); // [7] Auto Checksum Enable: 1 = Use automatically generated checksum
                                                        // [6] AVI Packet Update: 0 = AVI Packet I2C update inactive
                                                        // [5] Audio InfoFrame Packet Update: 0 = Audio InfoFrame Packet I2C update inactive

  if (linex_val > PASSTHROUGH) {
    adv7513_writereg(ADV7513_REG_PIXEL_REPETITION, 0x80);
    adv7513_writereg(ADV7513_REG_VIC_MANUAL, 0b000000);
  } else {
    adv7513_writereg(ADV7513_REG_PIXEL_REPETITION, 0x82);
    if (palmode) adv7513_writereg(ADV7513_REG_VIC_MANUAL, 0b010111);
    else adv7513_writereg(ADV7513_REG_VIC_MANUAL, 0b001000);
  }

  adv7513_writereg(ADV7513_REG_AVI_INFOFRAME(0), 0x01); // [6:5] Output format: 00 = RGB
                                                        // [1:0] Scan Information: 01 = TV, 10 = PC
  switch (linex_val) {
    case LineX3:
    case LineX4p5:
      adv7513_reg_bitset(ADV7513_REG_VIDEO_INPUT_CFG2,1); // set 16:9 aspect ratio of input video
      adv7513_writereg(ADV7513_REG_AVI_INFOFRAME(1), 0x2A); // [5:4] Picture Aspect Ratio: 10 = 16:9
                                                            // [3:0] Active Format Aspect Ratio: 1010 = 16:9 (center)
      break;
//    case PASSTHROUGH:
//    case LineX2:
//    case LineX4:
//    case LineX5:
//    case LineX6:
    default:
      adv7513_reg_bitclear(ADV7513_REG_VIDEO_INPUT_CFG2,1); // set 4:3 aspect ratio of input video
      adv7513_writereg(ADV7513_REG_AVI_INFOFRAME(1), 0x19); // [5:4] Picture Aspect Ratio: 01 = 4:3
                                                            // [3:0] Active Format Aspect Ratio: 1001 = 4:3 (center)
      break;
  }

  if (cfg_get_value(&limited_rgb,0)) adv7513_writereg(ADV7513_REG_AVI_INFOFRAME(2), 0x04); // [3:2] RGB Quantization range: 01 = full range
  else adv7513_writereg(ADV7513_REG_AVI_INFOFRAME(2), 0x08); // [3:2] RGB Quantization range: 10 = full range

  adv7513_writereg(ADV7513_REG_INFOFRAME_UPDATE, 0xE0); // [7] Auto Checksum Enable: 1 = Use automatically generated checksum
                                                        // [6] AVI Packet Update: 1 = AVI Packet I2C update active
                                                        // [5] Audio InfoFrame Packet Update: 1 = Audio InfoFrame Packet I2C update active
}

int check_adv7513()
{
  if (adv7513_readreg(ADV7513_REG_CHIP_REVISION) != ADV7513_CHIP_ID)
    return -ADV_INIT_FAILED;
  return 0;
}

void init_adv7513() {
  led_drive(LED_2, LED_ON);
  while (!ADV_POWER_RDY()) {}

  adv7513_writereg(ADV7513_REG_POWER, 0x10);
  //adv7513_writereg(ADV7513_REG_POWER2, 0xc0);

  adv7513_writereg(ADV7513_REG_INT0(2), 0x03);          // Must be set to 0x03 for proper operation
  adv7513_writereg(ADV7513_REG_INT0(4), 0xE0);          // Must be set to 0b1110000
  adv7513_writereg(ADV7513_REG_INT0(6), 0x30);          // Must be set to 0x30 for proper operation
  adv7513_writereg(ADV7513_REG_INPUT_CLK_DIV, 0x61);    // [7:4] Must be set to Default Value (0110)
                                                        // [3:2] Input Video CLK Divide: 01 = Input Clock Divided by 2
                                                        // [1:0] Must be set to 1 for proper operation
  adv7513_writereg(ADV7513_REG_INT1(0), 0xA4);          // Must be set to 0xA4 for proper operation
  adv7513_writereg(ADV7513_REG_INT1(1), 0xA4);          // Must be set to 0xA4 for proper operation
  adv7513_reg_bitclear(ADV7513_REG_INT1(2), 6);         // disable Video CLK Divide output if bit 6 is cleared
//  adv7513_reg_bitset(ADV7513_REG_INT1(2), 6);         // enable Video CLK Divide output if bit 6 is set
  adv7513_writereg(ADV7513_REG_INT2, 0xD0);             // Must be set to 0xD0 for proper operation
  adv7513_writereg(ADV7513_REG_INT3, 0x00);             // Must be set to 0x00 for proper operation

  adv7513_writereg(ADV7513_REG_I2C_FREQ_ID_CFG, 0x20);  // [7:4] Sampling frequency for I2S audio: 0010 = 48.0 kHz
                                                        // [3:0] Input Video Format: 0000 = 24 bit RGB 4:4:4 or YCbCr 4:4:4 (separate syncs)
  adv7513_writereg(ADV7513_REG_VIDEO_INPUT_CFG1, 0x32); // [5:4] Color Depth for Input Video Data: 11 = 8 bit
                                                        // [3:2] Input Style: 00 = Normal RGB or YCbCr 4:4:4 (24 bits) with Separate Syncs
                                                        // [1] Video data input edge selection: 1 = rising edge
                                                        // [0] Input Color Space Selection: 0 = RGB
//  adv7513_reg_bitset(ADV7513_REG_TIMING_GEN_SEQ,1);     // first generate DE (and then adjust HV sync if needed)
//  adv7513_reg_bitset(ADV7513_REG_VIDEO_INPUT_CFG2,0);   // enable internal DE generator
  adv7513_writereg(ADV7513_REG_PIXEL_REPETITION,0x80);  // [7] must be set to 1

  adv7513_writereg(ADV7513_REG_HDCP_HDMI_CFG, 0x06);    // [6:5] and [3:2] Must be set to Default Value (00 and 01 respectively)
                                                        // [1] HDMI Mode: 1 = HDMI Mode

  adv7513_writereg(ADV7513_REG_AN(10), 0x60);           // [7:5] Programmable delay for input video clock: 011 = no delay
                                                        // [3] Must be set to Default Value (0)

  adv7513_writereg(ADV7513_REG_N0, 0x00);               // N value for 48kHz
  adv7513_writereg(ADV7513_REG_N1, 0x18);               // 6144 decimal equals binary
  adv7513_writereg(ADV7513_REG_N2, 0x00);               // 0000 0000 0001 1000 0000 0000
  adv7513_writereg(ADV7513_REG_AUDIO_SOURCE, 0x03);     // [7] CTS Source Select: 0 = CTS Automatic
                                                        // [6:4] Audio Select: 000 = I2S
                                                        // [3:2] Mode Selection for Audio Select
                                                        // [1:0] MCLK Ratio: 11 = 512xfs
//  adv7513_reg_bitset(ADV7513_REG_AUDIO_CONFIG,5);       // [5] MCLK Enable: 1 = MCLK is available, 0 = MCLK not available
                                                        // [4:1] Must be set to Default Value (0111)
  adv7513_writereg(ADV7513_REG_I2S_CONFIG, 0x86);       // [7] Select source of audio sampling frequency: 1 = use sampling frequency from I2C register
                                                        // [2] I2S0 enable for the 4 I2S pins: 1 = Enabled
                                                        // [1:0] I2S Format: 10 = left justified mode, 00 = standard
  adv7513_writereg(ADV7513_REG_AUDIO_CFG3, 0x0B);       // [3:0] I2S Word length per channel: 1011 = 24bit
  led_drive(LED_2, LED_OFF);
}


alt_u8 adv7513_readreg(alt_u8 regaddr)
{
    //Phase 1
    I2C_start(I2C_MASTER_BASE, ADV7513_I2C_BASE, 0);
    I2C_write(I2C_MASTER_BASE, regaddr, 0);

    //Phase 2
    I2C_start(I2C_MASTER_BASE, ADV7513_I2C_BASE, 1);
    return (alt_u8) I2C_read(I2C_MASTER_BASE,1);
}

void adv7513_writereg(alt_u8 regaddr, alt_u8 data)
{
    I2C_start(I2C_MASTER_BASE, ADV7513_I2C_BASE, 0);
    I2C_write(I2C_MASTER_BASE, regaddr, 0);
    I2C_write(I2C_MASTER_BASE, data, 1);
}


