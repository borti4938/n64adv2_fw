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
 * adv7513.c
 *
 *  Created on: 11.09.2018
 *      Author: Peter Bartmann
 *
 ********************************************************************************/


#include "alt_types.h"
#include "common_types.h"
#include "i2c_opencores.h"
#include "system.h"
#include "altera_avalon_pio_regs.h"

#include "adv7513.h"
#include "adv7513_regs_p.h"
#include "i2c.h"
#include "n64.h"
#include "config.h"


#define adv7513_reg_bitset(regaddr,bit)   i2c_reg_bitset(ADV7513_I2C_BASE,regaddr,bit)
#define adv7513_reg_bitclear(regaddr,bit) i2c_reg_bitclear(ADV7513_I2C_BASE,regaddr,bit)
#define adv7513_readreg(regaddr)          i2c_readreg(ADV7513_I2C_BASE,regaddr)
#define adv7513_writereg(regaddr,data)    i2c_writereg(ADV7513_I2C_BASE,regaddr,data)

#define adv7513_packetmem_reg_bitset(regaddr,bit)   i2c_reg_bitset(ADV7513_PACKETMEM_I2C_BASE,regaddr,bit)
#define adv7513_packetmem_reg_bitclear(regaddr,bit) i2c_reg_bitclear(ADV7513_PACKETMEM_I2C_BASE,regaddr,bit)
#define adv7513_packetmem_readreg(regaddr)          i2c_readreg(ADV7513_PACKETMEM_I2C_BASE,regaddr)
#define adv7513_packetmem_writereg(regaddr,data)    i2c_writereg(ADV7513_PACKETMEM_I2C_BASE,regaddr,data)

#define IEEE_OUI_MIMIC_0  0x55
#define IEEE_OUI_MIMIC_1  0x55
#define IEEE_OUI_MIMIC_2  0x55


void set_vsif(bool_t enable) {
  if (!enable) {
    adv7513_reg_bitclear(ADV7513_REG_PACKET_ENABLE0,ADV7513_SPARE_PACKET1_ENABLE_BIT);
    return;
  }

  adv7513_reg_bitset(ADV7513_REG_PACKET_ENABLE0,ADV7513_SPARE_PACKET1_ENABLE_BIT);

  // format as suggested by PixelFx: https://docs.pixelfx.co/VSIF-metadata.html
  alt_u8 idx = 0;
  alt_u8 crc = 0;

  adv7513_packetmem_writereg(ADV7513_REG_SPARE_PACKET1_UPDATE,ADV7513_PACKET_UPDATE_START_VAL);

  // write header
  adv7513_packetmem_writereg(ADV7513_REG_SPARE_PACKET1(0),0x81);
  adv7513_packetmem_writereg(ADV7513_REG_SPARE_PACKET1(1),0x01);
  adv7513_packetmem_writereg(ADV7513_REG_SPARE_PACKET1(2),0x1B);
  // write IEEE OUI
  adv7513_packetmem_writereg(ADV7513_REG_SPARE_PACKET1(4),IEEE_OUI_MIMIC_2);
  adv7513_packetmem_writereg(ADV7513_REG_SPARE_PACKET1(5),IEEE_OUI_MIMIC_1);
  adv7513_packetmem_writereg(ADV7513_REG_SPARE_PACKET1(6),IEEE_OUI_MIMIC_0);
  // write Vendor Type and Game-ID type
  adv7513_packetmem_writereg(ADV7513_REG_SPARE_PACKET1(7),0x01);  // vendor
  adv7513_packetmem_writereg(ADV7513_REG_SPARE_PACKET1(8),0x03);  // N64

  crc = (alt_u8) (0x81 + 0x01 + 0x1B +
      IEEE_OUI_MIMIC_2 + IEEE_OUI_MIMIC_1 + IEEE_OUI_MIMIC_0 +
      0x01 + 0x03); // CRC up to this point
  for (idx = 0; idx < 10; idx++) {  // write 10 bytes for the game id
    adv7513_packetmem_writereg(ADV7513_REG_SPARE_PACKET1(9+idx),game_id[idx]);
    crc += game_id[idx];
  }
  // ensure that remaining bytes stay zero
//  for (idx = 19; idx < SPARE_PACKET_MAX_SIZE; idx++)
//    adv7513_packetmem_writereg(ADV7513_REG_SPARE_PACKET1(idx),0x00);
  // calculate final CRC and write CRC
  crc = ~crc + 0x01;
  adv7513_packetmem_writereg(ADV7513_REG_SPARE_PACKET1(3),crc);

  adv7513_packetmem_writereg(ADV7513_REG_SPARE_PACKET1_UPDATE,ADV7513_PACKET_UPDATE_DONE_VAL);
}

void set_dv_spd_packet(bool_t dv_send_pr) {
  if (cfg_get_value(&linex_resolution,0)!=DIRECT) {
    adv7513_reg_bitclear(ADV7513_REG_PACKET_ENABLE0,ADV7513_SPD_PACKET_ENABLE_BIT);
    return;
  }

  adv7513_reg_bitset(ADV7513_REG_PACKET_ENABLE0,ADV7513_SPD_PACKET_ENABLE_BIT);

  // start writing information
  // format according to https://github.com/MiSTer-devel/Main_MiSTer/issues/808
  alt_u8 idx = 0;
  alt_u16 wr_val = 0;

  adv7513_packetmem_writereg(ADV7513_REG_SPD_PACKET_UPDATE,ADV7513_PACKET_UPDATE_START_VAL);

  // write header
  for (idx = 0; idx < SPD_DV_HEADER_LEN; idx++)
    adv7513_packetmem_writereg(ADV7513_REG_SPD_PACKET(idx),spd_header[idx]);

  // write vi config
  adv7513_packetmem_writereg(ADV7513_REG_SPD_PACKET(0+SPD_DV_VI_CFG_OFFSET),scanmode);
  adv7513_packetmem_writereg(ADV7513_REG_SPD_PACKET(1+SPD_DV_VI_CFG_OFFSET),dv_send_pr ? 2 : 1);
  for (idx = 0; idx < (SPD_DV_VI_CFG_LEN-2)/2; idx++) {
    if (idx % 2 == 0) wr_val = vi_cfg_dv[2*scanmode + palmode][idx]/(1+dv_send_pr);
    else              wr_val =  vi_cfg_dv[2*scanmode + palmode][idx];
    adv7513_packetmem_writereg(ADV7513_REG_SPD_PACKET(2*idx  +2+SPD_DV_VI_CFG_OFFSET),(alt_u8) ( wr_val       & 0xFF));
    adv7513_packetmem_writereg(ADV7513_REG_SPD_PACKET(2*idx+1+2+SPD_DV_VI_CFG_OFFSET),(alt_u8) ((wr_val >> 8) & 0xFF));
  }

  // write core name
  for (idx = 0; idx < SPD_DV_CORE_NAME_LEN; idx++)
    adv7513_packetmem_writereg(ADV7513_REG_SPD_PACKET(idx+SPD_DV_CORE_NAME_OFFSET),core_name_data[idx]);

  adv7513_packetmem_writereg(ADV7513_REG_SPD_PACKET_UPDATE,ADV7513_PACKET_UPDATE_DONE_VAL);
}

#ifdef HDR_TESTING
  void set_hdr(bool_t enable) {
    if (!enable) {
      adv7513_reg_bitclear(ADV7513_REG_PACKET_ENABLE0,ADV7513_SPARE_PACKET2_ENABLE_BIT);
      return;
    }

    adv7513_reg_bitset(ADV7513_REG_PACKET_ENABLE0,ADV7513_SPARE_PACKET2_ENABLE_BIT);

    alt_u8 idx = 0;

    adv7513_packetmem_writereg(ADV7513_REG_SPARE_PACKET2_UPDATE,ADV7513_SPARE_PACKET_UPDATE_START_VAL);

    for (idx = 0; idx < HDR_SPARE_PACKET_SIZE; idx++)
      if (!enable) adv7513_packetmem_writereg(ADV7513_REG_SPARE_PACKET2(idx),0x00);
      else         adv7513_packetmem_writereg(ADV7513_REG_SPARE_PACKET2(idx),hdr_data[idx]);

    adv7513_packetmem_writereg(ADV7513_REG_SPARE_PACKET2_UPDATE,ADV7513_SPARE_PACKET_UPDATE_DONE_VAL);
  }
#endif

void set_color_format(color_format_t color_format) {
  adv7513_reg_bitset(ADV7513_REG_CSC_UPDATE,ADV7513_CSC_UPDATE_BIT);

//  if (color_format > RGB_limited) {
//    adv7513_writereg(ADV7513_REG_VIDEO_INPUT_CFG1,0x01);
//  } else {
//    adv7513_writereg(ADV7513_REG_VIDEO_INPUT_CFG1,0x00);
//  }
  adv7513_writereg(ADV7513_REG_VIDEO_INPUT_CFG1,color_format > RGB_limited);

  for (int idx = 0; idx < CSC_COEFFICIENTS; idx++) {
    adv7513_writereg(ADV7513_REG_CSC_UPPER(idx),csc_reg_vals[color_format][2*idx    ]);
    adv7513_writereg(ADV7513_REG_CSC_LOWER(idx),csc_reg_vals[color_format][2*idx + 1]);
  }
  adv7513_reg_bitclear(ADV7513_REG_CSC_UPDATE,ADV7513_CSC_UPDATE_BIT);
}

void set_pr_manual(pr_mode_t pr_mode, alt_u8 pr_set, alt_u8 pr_send2tx) {

  alt_u8 regval = 0x80;
  if (pr_mode == PR_MANUAL) regval |= (0b11 << 5);

  if (pr_set == 4) regval |= 0b10 << 3;
  if (pr_set == 2) regval |= 0b01 << 3;

  if (pr_send2tx == 4) regval |= 0b10 << 1;
  if (pr_send2tx == 2) regval |= 0b01 << 1;

  adv7513_writereg(ADV7513_REG_PIXEL_REPETITION,regval);
}

inline void set_vclk_div(alt_u8 divider) {
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

void set_cfg_adv7513(void) {
  linex_cnt linex_val = cfg_get_value(&linex_resolution,0);
  alt_u8 color_format = cfg_get_value(&color_space,0);
  boolean_t use_limited_colorspace = cfg_get_value(&limited_colorspace,0);

  adv7513_writereg(ADV7513_REG_INFOFRAME_UPDATE, 0xE0); // [7] Auto Checksum Enable: 1 = Use automatically generated checksum
                                                        // [6] AVI Packet Update: 1 = AVI Packet I2C update active
                                                        // [5] Audio InfoFrame Packet Update: 1 = Audio InfoFrame Packet I2C update active

  switch (linex_val) {
    case DIRECT:
//      set_pr_manual(PR_MANUAL,2,2*(2-hor_hires));
      set_pr_manual(PR_MANUAL,2,2);
      if (palmode) adv7513_writereg(ADV7513_REG_VIC_MANUAL, 0b010111);
      else adv7513_writereg(ADV7513_REG_VIC_MANUAL, 0b001000);
      break;
    case LineX6W:
      set_pr_manual(PR_MANUAL,2,1);
      adv7513_writereg(ADV7513_REG_VIC_MANUAL, 0b000000);
      break;
//    case LineX2:
//    case LineX3:
//    case LineX4:
//    case LineX4p5:
//    case LineX5:
//    case LineX6:
    default:
//      set_pr_manual(PR_AUTO,1,1);
      set_pr_manual(PR_MANUAL,1,1);
      adv7513_writereg(ADV7513_REG_VIC_MANUAL, 0b000000);
  }

  set_color_format((color_format << 1) | use_limited_colorspace);

  adv7513_writereg(ADV7513_REG_AVI_INFOFRAME(0), ((color_format > 0) << 6 ) | 0x01);  // [6:5] Output format: 00 = RGB, 01 = YCbCr 4:2:2, 10 = YCbCr 4:4:4
                                                                                      // [1:0] Scan Information: 01 = TV, 10 = PC

  switch (linex_val) {
    case LineX3:
    case LineX4p5:
    case LineX6W:
      adv7513_reg_bitset(ADV7513_REG_VIDEO_INPUT_CFG2,1); // set 16:9 aspect ratio of input video
      adv7513_writereg(ADV7513_REG_AVI_INFOFRAME(1), (color_format << 6) | 0x2A); // [7:6] Colorimetry: 00 = no data, 01 = ITU601, 10 = ITU709
                                                                                  // [5:4] Picture Aspect Ratio: 10 = 16:9
                                                                                  // [3:0] Active Format Aspect Ratio: 1010 = 16:9 (center)
      break;
//    case PASSTHROUGH:
//    case LineX2:
//    case LineX4:
//    case LineX5:
//    case LineX6:
    default:
      adv7513_reg_bitclear(ADV7513_REG_VIDEO_INPUT_CFG2,1); // set 4:3 aspect ratio of input video
      adv7513_writereg(ADV7513_REG_AVI_INFOFRAME(1), (color_format << 6) | 0x19); // [7:6] Colorimetry: 00 = no data, 01 = ITU601, 10 = ITU709
                                                                                  // [5:4] Picture Aspect Ratio: 01 = 4:3
                                                                                  // [3:0] Active Format Aspect Ratio: 1001 = 4:3 (center)
      break;
  }

//  if (use_limited_colorspace) adv7513_writereg(ADV7513_REG_AVI_INFOFRAME(2), 0x04); // [3:2] Quantization range: 01 = limited range
//  else adv7513_writereg(ADV7513_REG_AVI_INFOFRAME(2), 0x08); // [3:2] Quantization range: 10 = full range
  adv7513_writereg(ADV7513_REG_AVI_INFOFRAME(2), 0x08 >> use_limited_colorspace); // [3:2] Quantization range: 10 = full range, 01 = limited range
#ifdef HDR_TESTING
  set_hdr(cfg_get_value(&hdr10_injection,0));
#endif

  adv7513_writereg(ADV7513_REG_INFOFRAME_UPDATE, 0x80); // [7] Auto Checksum Enable: 1 = Use automatically generated checksum
                                                        // [6] AVI Packet Update: 0 = AVI Packet I2C update inactive
                                                        // [5] Audio InfoFrame Packet Update: 0 = Audio InfoFrame Packet I2C update inactive
}

int check_adv7513()
{
  if (adv7513_readreg(ADV7513_REG_CHIP_REVISION) != ADV7513_CHIP_ID)
    return -ADV_INIT_FAILED;
  return 0;
}

bool_t init_adv7513() {
  if (!ADV_POWER_RDY()) return FALSE;

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

  set_cfg_adv7513();
  return TRUE;
}


