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
 * adv7513_regs_p.h
 *
 *  Created on: 11.09.2018
 *      Author: Peter Bartmann
 *
 ********************************************************************************/

#include "alt_types.h"
#include "app_cfg.h"

#ifndef ADV7513_REGS_P_H_
#define ADV7513_REGS_P_H_

#define BIT(n)  (1 << (n))


#define ADV7513_REG_CHIP_REVISION 0x00
#define ADV7513_REG_N0                        0x01
#define ADV7513_REG_N1                        0x02
#define ADV7513_REG_N2                        0x03
#define ADV7513_REG_SPDIF_FREQ                0x04
#define ADV7513_REG_CTS_AUTOMATIC1            0x05
#define ADV7513_REG_CTS_AUTOMATIC2            0x06
#define ADV7513_REG_CTS_MANUAL0               0x07
#define ADV7513_REG_CTS_MANUAL1               0x08
#define ADV7513_REG_CTS_MANUAL2               0x09
#define ADV7513_REG_AUDIO_SOURCE              0x0a
#define ADV7513_REG_AUDIO_CONFIG              0x0b
#define ADV7513_REG_I2S_CONFIG                0x0c
#define ADV7513_REG_I2S_WIDTH                 0x0d
#define ADV7513_REG_AUDIO_SUB_SRC0            0x0e
#define ADV7513_REG_AUDIO_SUB_SRC1            0x0f
#define ADV7513_REG_AUDIO_SUB_SRC2            0x10
#define ADV7513_REG_AUDIO_SUB_SRC3            0x11
#define ADV7513_REG_AUDIO_CFG1                0x12
#define ADV7513_REG_AUDIO_CFG2                0x13
#define ADV7513_REG_AUDIO_CFG3                0x14
#define ADV7513_REG_I2C_FREQ_ID_CFG           0x15
#define ADV7513_REG_VIDEO_INPUT_CFG1          0x16
#define ADV7513_REG_VIDEO_INPUT_CFG2          0x17
#define ADV7513_REG_CSC_UPPER(x)              0x18 + (x) * 2)
#define ADV7513_REG_CSC_LOWER(x)              (0x19 + (x) * 2)
#define ADV7513_REG_SYNC_DECODER(x)           (0x30 + (x))
#define ADV7513_REG_DE_GENERATOR(x)           (0x35 + (x))
#define ADV7513_REG_PIXEL_REPETITION          0x3b
#define ADV7513_REG_VIC_MANUAL                0x3c
#define ADV7513_REG_VIC_SEND                  0x3d
#define ADV7513_REG_VIC_DETECTED              0x3e
#define ADV7513_REG_AUX_VIC_DETECTED          0x3f
#define ADV7513_REG_PACKET_ENABLE0            0x40
#define ADV7513_REG_POWER                     0x41
#define ADV7513_REG_EDID_I2C_ADDR             0x43
#define ADV7513_REG_PACKET_ENABLE1            0x44
#define ADV7513_REG_PACKET_I2C_ADDR           0x45
#define ADV7513_REG_DSD_ENABLE                0x46
//#define ADV7513_REG_VIDEO_INPUT_CFG2          0x48
#define ADV7513_REG_INFOFRAME_UPDATE          0x4a
#define ADV7513_REG_GC(x)                     (0x4b + (x)) /* 0x4b - 0x51 */
#define ADV7513_REG_AVI_INFOFRAME_VERSION     0x52
#define ADV7513_REG_AVI_INFOFRAME_LENGTH      0x53
#define ADV7513_REG_AVI_INFOFRAME_CHECKSUM    0x54
#define ADV7513_REG_AVI_INFOFRAME(x)          (0x55 + (x)) /* 0x55 - 0x6f */
#define ADV7513_REG_AUDIO_INFOFRAME_VERSION   0x70
#define ADV7513_REG_AUDIO_INFOFRAME_LENGTH    0x71
#define ADV7513_REG_AUDIO_INFOFRAME_CHECKSUM  0x72
#define ADV7513_REG_AUDIO_INFOFRAME(x)        (0x73 + (x)) /* 0x73 - 0x7c */
#define ADV7513_REG_INT_ENABLE(x)             (0x94 + (x))
#define ADV7513_REG_INT0(x)                   (0x96 + (x))
#define ADV7513_REG_INPUT_CLK_DIV             0x9d
#define ADV7513_REG_PLL_STATUS                0x9e
#define ADV7513_REG_HDMI_POWER                0xa1
#define ADV7513_REG_INT1(x)                   (0xa2 + (x))
#define ADV7513_REG_HDCP_HDMI_CFG             0xaf
#define ADV7513_REG_AN(x)                     (0xb0 + (x)) /* 0xb0 - 0xb7 */
#define ADV7513_REG_HDCP_STATUS               0xb8
#define ADV7513_REG_BCAPS                     0xbe
#define ADV7513_REG_BKSV(x)                   (0xc0 + (x)) /* 0xc0 - 0xc3 */
#define ADV7513_REG_EDID_SEGMENT              0xc4
#define ADV7513_REG_DDC_STATUS                0xc8
#define ADV7513_REG_EDID_READ_CTRL            0xc9
#define ADV7513_REG_BSTATUS(x)                (0xca + (x)) /* 0xca - 0xcb */
#define ADV7513_REG_TIMING_GEN_SEQ            0xd0
#define ADV7513_REG_POWER2                    0xd6
#define ADV7513_REG_HSYNC_PLACEMENT_MSB       0xfa
#define ADV7513_REG_DE_GENERATOR_MSBS         0xfb

#define ADV7513_REG_SYNC_ADJUSTMENT(x)        (0xd7 + (x)) /* 0xd7 - 0xdc */
#define ADV7513_REG_TMDS_CLOCK_INV            0xde
#define ADV7513_REG_ARC_CTRL                  0xdf
#define ADV7513_REG_INT2                      0xe0
#define ADV7513_REG_CEC_I2C_ADDR              0xe1
#define ADV7513_REG_CEC_CTRL                  0xe2
#define ADV7513_REG_CHIP_ID_HIGH              0xf5
#define ADV7513_REG_CHIP_ID_LOW               0xf6
#define ADV7513_REG_INT3                      0xf9

#define ADV7513_STATUS_HPD                    BIT(6)
#define ADV7513_STATUS_MONITOR_SENSE          BIT(5)


#endif /* ADV7513_REGS_P_H_ */
