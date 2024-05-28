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
 * adv7513.c
 *
 *  Created on: 11.09.2018
 *      Author: Peter Bartmann
 *
 ********************************************************************************/


#include "video.h"

#include "alt_types.h"
#include "common_types.h"
#include "i2c_opencores.h"
#include "system.h"
#include "altera_avalon_pio_regs.h"

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

void set_vic_manual(alt_u8 mode) {
  adv7513_writereg(ADV7513_REG_VIC_MANUAL, mode);
}

void set_cfg_adv7513(void) {
  linex_cnt linex_val = cfg_get_value(&linex_resolution,0);
  alt_u8 color_format = cfg_get_value(&color_space,0);
  boolean_t use_limited_colorspace = cfg_get_value(&limited_colorspace,0);

  adv7513_writereg(ADV7513_REG_INFOFRAME_UPDATE, 0xE0); // [7] Auto Checksum Enable: 1 = Use automatically generated checksum
                                                        // [6] AVI Packet Update: 1 = AVI Packet I2C update active
                                                        // [5] Audio InfoFrame Packet Update: 1 = Audio InfoFrame Packet I2C update active

  set_vic_manual(0x00);

  switch (linex_val) {
    case DIRECT:
      if (cfg_get_value(&dvmode_version,0)==0) {
        set_pr_manual(PR_MANUAL,4,1);
      } else {
        set_pr_manual(PR_AUTO,1,1);
      }
      break;
    case LineX6W:
      set_pr_manual(PR_MANUAL,2,1);
      break;
    case LineX4:
    case LineX5:
    case LineX6:
      set_pr_manual(PR_MANUAL,1,1);
      break;
//    case LineX2:
//    case LineX3:
//    case LineX4p5:
    default:
      set_pr_manual(PR_AUTO,1,1);
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
//    case DIRECT:
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


void set_infoframe_packet(bool_t enable, alt_u8 enable_bit, alt_u8 packet_addr_offset, if_packet_t *buf) {
  if (!enable) {
    adv7513_reg_bitclear(ADV7513_REG_PACKET_ENABLE0,enable_bit);
    return;
  }

  adv7513_reg_bitset(ADV7513_REG_PACKET_ENABLE0,enable_bit);
  adv7513_packetmem_writereg((0x1f + packet_addr_offset),ADV7513_PACKET_UPDATE_START_VAL);

  alt_u8 idx = 0;
  alt_u8 crc = 0;

  for (idx = 0; idx < PACKET_HEADER_SIZE; idx++) {  // write header
    adv7513_packetmem_writereg((idx + packet_addr_offset),buf->header[idx]);
    crc += buf->header[idx];
  }
  for (idx = 1; idx < PACKET_BODY_SIZE; idx++) {  // write body (skipping checksum byte)
    adv7513_packetmem_writereg((idx + PACKET_HEADER_SIZE + packet_addr_offset),buf->packet_bytes[idx]);
    crc += buf->packet_bytes[idx];
  }
  crc = ~crc + 0x01;                                                          // calculate final CRC ...
  adv7513_packetmem_writereg((PACKET_HEADER_SIZE + packet_addr_offset),crc);  // ... and write CRC

  adv7513_packetmem_writereg((0x1f + packet_addr_offset),ADV7513_PACKET_UPDATE_DONE_VAL);
}

void send_game_id_if(bool_t enable)
{
  if (!enable) {
    set_infoframe_packet(enable,SPARE_PACKET1_ENABLE_BIT,SPARE_PACKET1_REG_OFFSET,NULL);
    return;
  }

  // format as suggested by PixelFx: https://docs.pixelfx.co/VSIF-metadata.html

  alt_u8 idx;
  if_packet_t buf = {
    // header
    {0x81,0x01,27},
    // packet bytes
    {0} // crc place holder
  };

  // write IEEE OUI
  buf.packet_bytes[1] = OUI_PFX_2;
  buf.packet_bytes[2] = OUI_PFX_1;
  buf.packet_bytes[3] = OUI_PFX_0;
  // write Vendor Type and Game-ID type
  buf.packet_bytes[4] = 0x01;  // game-id
  buf.packet_bytes[5] = 0x03;  // N64

  for (idx = 0; idx < 20; idx++)  // set 20 bytes for the game id
    buf.packet_bytes[6+idx] = game_id_txt[idx];

  // set infoframe
  set_infoframe_packet(enable,SPARE_PACKET1_ENABLE_BIT,SPARE_PACKET1_REG_OFFSET,&buf);
}

void send_dv1_if(bool_t enable)
{
  if (!enable) {
    set_infoframe_packet(enable,SPD_PACKET_ENABLE_BIT,SPD_PACKET_REG_OFFSET,NULL);
    return;
  }

  bool_t dv_send_pr = (scanmode == PROGRESSIVE && cfg_get_value(&deblur_mode,0) == ON);
  alt_u16 wr_val;

  // setup information for dv1
  // format according to https://github.com/MiSTer-devel/Main_MiSTer/issues/808
  if_packet_t buf = {
    // header
    {0x83,0x01,23},
    // packet bytes
    {0, // crc place holder
     'D','V','1', // version
     0,0,0,0,0,0,0,0,0,0,
     'N','6','4',' ','A','d','v','.','2'
    }
  };
  // write menu present and scanmode
  buf.packet_bytes[4] = ((active_osd << 2) | scanmode);
  // write pixel repetition
  buf.packet_bytes[5] = (dv_send_pr ? 4*2 : 4*1);
  if (palmode) {
    // offset
    buf.packet_bytes[6] = 4*56;
//    buf.packet_bytes[6] = 56;
//    buf.packet_bytes[7] = 0;
    if (use_pal_at_288p) {
      buf.packet_bytes[8] = 19;
//      buf.packet_bytes[9] = 0;
      wr_val = 288<<scanmode;
    } else {
      buf.packet_bytes[8] = 19 + 24;
//      buf.packet_bytes[9] = 0;
      wr_val = 240<<scanmode;
    }
  } else {
    // offsets
    buf.packet_bytes[6] = 4*45;
//    buf.packet_bytes[7] = 0;
    buf.packet_bytes[8] = 15;
//    buf.packet_bytes[8] = 3 + 15;
//    buf.packet_bytes[9] = 0;
    // setup height
    wr_val = 240<<scanmode;
  }
  // write height
  buf.packet_bytes[12] = (alt_u8) ( wr_val       & 0xFF);
  buf.packet_bytes[13] = (alt_u8) ((wr_val >> 8) & 0xFF);
  // write width
  wr_val = dv_send_pr ? 320 : 640;
  buf.packet_bytes[10] = (alt_u8) ( wr_val       & 0xFF);
  buf.packet_bytes[11] = (alt_u8) ((wr_val >> 8) & 0xFF);

  // set infoframe
  set_infoframe_packet(enable,SPD_PACKET_ENABLE_BIT,SPD_PACKET_REG_OFFSET,&buf);
}

void send_fxd_if(bool_t enable, bool_t use_fxd)
{
  if (!enable) {
    set_infoframe_packet(enable,SPARE_PACKET1_ENABLE_BIT,SPARE_PACKET1_REG_OFFSET,NULL);
    return;
  }

  if_packet_t buf = {
    // header
    {0x81,0x01,27},
    // packet bytes
    {0} // crc place holder
  };

  // write IEEE OUI
  buf.packet_bytes[1] = OUI_PFX_2;
  buf.packet_bytes[2] = OUI_PFX_1;
  buf.packet_bytes[3] = OUI_PFX_0;
  // write Vendor Type
  buf.packet_bytes[4] = 0x02;  // fx-direct

  if (use_fxd) {
    // write aspect ratio mode, menu present and scanmode
    buf.packet_bytes[5] = (1 << 3 | (active_osd << 2) | scanmode);  // with DAR
//    buf.packet_bytes[5] = (2 << 3 | (active_osd << 2) | scanmode);  // with PAR
    // write vertical start and stop
    if (palmode & use_pal_at_288p) { // use 576 lines
      buf.packet_bytes[6] = 0x48; // 72
//      buf.packet_bytes[7] = 0;
      buf.packet_bytes[8] = 0x88; // LSB(648)
      buf.packet_bytes[9] = 0x02; // MSB(648)
    } else {  // use 480 lines
      buf.packet_bytes[6] = 0x78; // 120
//      buf.packet_bytes[7] = 0;
      buf.packet_bytes[8] = 0x58; // LSB(600)
      buf.packet_bytes[9] = 0x02; // MSB(600)
    }
    // write horizontal start and stop
    buf.packet_bytes[10] = 0x40; // LSB(320)
    buf.packet_bytes[11] = 0x01; // MSB(320)
    buf.packet_bytes[12] = 0xC0; // LSB(960)
    buf.packet_bytes[13] = 0x03; // MSB(960)
    // write horizontal and vertical prescale
    buf.packet_bytes[14] = 1 + ((scanmode == PROGRESSIVE && cfg_get_value(&deblur_mode,0) == ON));
    buf.packet_bytes[15] = 2;
    // write aspect ratio (for DAR)
    buf.packet_bytes[16] = 4; // DAR
//    buf.packet_bytes[16] = use_pal_lines ? 10 : 4;    // PAR
//    buf.packet_bytes[17] = 0;
    buf.packet_bytes[18] = 3; // DAR
    //    buf.packet_bytes[18] = use_pal_lines ? 9 : 3; // PAR
//    buf.packet_bytes[19] = 0;
  }

  // set infoframe
  set_infoframe_packet(enable,SPARE_PACKET1_ENABLE_BIT,SPARE_PACKET1_REG_OFFSET,&buf);
}

void send_spd_if(bool_t enable)
{
  if (!enable) {
    set_infoframe_packet(enable,SPD_PACKET_ENABLE_BIT,SPD_PACKET_REG_OFFSET,NULL);
    return;
  }

  if_packet_t buf = {
    // header
    {0x83,0x01,25},
    // packet bytes
    {0, // crc place holder
     'P','r','o','j','e','c','t',0,
     'N','6','4',' ','A','d','v','.','2'
    }
  };

  // write type
  buf.packet_bytes[SPD_STD_TYPE_OFFSET] = SPD_STD_TYPE_VALUE;

  // set infoframe
  set_infoframe_packet(enable,SPD_PACKET_ENABLE_BIT,SPD_PACKET_REG_OFFSET,&buf);
}

#ifdef HDR_TESTING
  void set_hdr_if(bool_t enable, bool_t use_hdr) {
    if (!enable) {
      set_infoframe_packet(enable,ADV7513_SPARE_PACKET2_ENABLE_BIT,SPARE_PACKET2_REG_OFFSET,NULL);
      return;
    }

    alt_u8 idx;
    if_packet_t buf = {
      // header
      {0x87,0x01,26},
      // packet bytes
      {0, // crc place holder
       0x02,0x00,0xc2,0x33,0xc4,0x86,0x4c,      // data bytes  1 -  7
       0x1d,0xb8,0x0b,0xd0,0x84,0x80,0x3e,0x13, // data bytes  8 - 15
       0x3d,0x42,0x40,0xe8,0x03,0x32,0x00,0xe8, // data bytes 16 - 23
       0x03,0x90,0x01                           // data bytes 24 - 26
      }
    };
    if (!use_hdr) {
      for (idx = 0; idx < PACKET_BODY_SIZE; idx++) buf.packet_bytes[idx] = 0;
    }

    // set infoframe
    set_infoframe_packet(enable,ADV7513_SPARE_PACKET2_ENABLE_BIT,SPARE_PACKET2_REG_OFFSET,&buf);
  }
#endif
