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
 * adv7513.h
 *
 *  Created on: 11.09.2018
 *      Author: Peter Bartmann
 *
 ********************************************************************************/


#ifndef ADV7513_H_
#define ADV7513_H_

#include "system.h"
#include "alt_types.h"
#include "app_cfg.h"
#include "common_types.h"
#include "i2c.h"

#define ADV7513_CHIP_ID     0x13
#define ADV7513_REG_STATUS  0x42

#define ADV_INIT_FAILED 150 // ToDo: move codes into separate header file?

#define ADV_POWER_RDY()           ((i2c_readreg(ADV7513_I2C_BASE,ADV7513_REG_STATUS) & 0x70) == 0x70)
#define ADV_HPD_STATE()           ((i2c_readreg(ADV7513_I2C_BASE,ADV7513_REG_STATUS) & 0x40) == 0x40)
#define ADV_MONITOR_SENSE_STATE() ((i2c_readreg(ADV7513_I2C_BASE,ADV7513_REG_STATUS) & 0x20) == 0x20)


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


#define OUI_PFX_2   0x49
#define OUI_PFX_1   0x31
#define OUI_PFX_0   0xF4

#define PACKET_HEADER_SIZE  3
#define PACKET_BODY_SIZE    28
#define PACKET_MAX_SIZE     (PACKET_HEADER_SIZE + PACKET_BODY_SIZE)

#define SPD_STD_VENDOR_NAME_LEN   7
#define SPD_STD_PRODUCT_NAME_LEN  9
#define SPD_DV1_CORE_NAME_LEN     SPD_STD_PRODUCT_NAME_LEN

#define SPD_STD_VENDOR_NAME_LEN   7
  #define SPD_STD_VENDOR_OFFSET     1
#define SPD_STD_PRODUCT_NAME_LEN  9
  #define SPD_STD_PRODUCT_OFFSET    9  // SPD_STD_HEADER_LEN+SPD_STD_VENDOR_NAME_LEN must not exceed this number
#define SPD_STD_TYPE_LEN          1
  #define SPD_STD_TYPE_OFFSET     25    // SPD_STD_HEADER_LEN+SPD_STD_VENDOR_NAME_LEN+SPD_STD_PRODUCT_NAME_LEN must not exceed this number
  #define SPD_STD_TYPE_VALUE      8

#define SPD_PACKET_REG_OFFSET     0x00
#define SPARE_PACKET1_REG_OFFSET  0xc0
#define SPARE_PACKET2_REG_OFFSET  0xe0

#define SPD_PACKET_ENABLE_BIT     6
#define SPARE_PACKET2_ENABLE_BIT  1
#define SPARE_PACKET1_ENABLE_BIT  0



typedef struct {
  char header[PACKET_HEADER_SIZE];
  char packet_bytes[PACKET_BODY_SIZE];
} if_packet_t;


void set_infoframe_packet(bool_t enable,alt_u8 enable_bit,alt_u8 packet_addr_offset,if_packet_t *buf);
void set_cfg_adv7513(void);
int check_adv7513(void);
bool_t init_adv7513(void);


#endif /* ADV7513_H_ */
