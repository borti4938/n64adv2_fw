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
 * n64.h
 *
 *  Created on: 06.01.2018
 *      Author: Peter Bartmann
 *
 ********************************************************************************/


#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include "alt_types.h"
#include "common_types.h"
#include "altera_avalon_pio_regs.h"
#include "system.h"
#include "config.h"
#include "n64.h"
#include "vd_driver.h"
#include "si5356.h"
#include "video.h"

#define VIN_MIN_INIT_LENGTH           5
#define VIN_BOOT_DETECTION_TIMEOUT  255
#define VIN_DETECTION_TIMEOUT       127

#define WAIT_20MS   20000

#define ANALOG_TH   50

#define HOLD_CNT_LOW	3
#define HOLD_CNT_MID	7
#define HOLD_CNT_HIGH	13

#define HOLD_CNT_REP	2

#define SET_EXTINFO_SEL(x) (info_sync_val = (info_sync_val & EXT_INFO_CLR_MASK) | ((x & 0x7) << EXT_INFO_SEL_OFFSET))

#define PIN_STATE_OFFSET      16
#define GET_PIN_STATE_MASK    0xFFFF0000
#define GET_PCB_VERSION_MASK  0x00000003

#define GAMEID_BYTES    10
#define GAMEID_TXT_LEN  21

typedef enum {
  HW_INFO = 0,
  UNUSED,
  CHIP_ID_0,
  CHIP_ID_1,
  GAME_ID_0,
  GAME_ID_1,
  GAME_ID_2
} ext_info_sel_t;

alt_u8 info_sync_val;
alt_u32 ctrl_data;
bool_t active_osd;

alt_u32 n64adv_state;
bool_t video_input_detected;
cfg_pal_pattern_t pal_pattern;
vmode_t palmode;
bool_t use_pal_at_288p;
scanmode_t scanmode;
bool_t hor_hires;
bool_t hdmi_clk_ok;

bool_t game_id_valid;
alt_u8 game_id_raw[GAMEID_BYTES] = {0,0,0,0,0,0,0,0,0,0};
char game_id_txt[GAMEID_TXT_LEN];

#ifdef DEBUG
  alt_u16 vid_timeout_cnt;
#endif

void periphals_clr_ready_bit() {
  info_sync_val = info_sync_val & PERIPHALS_CFG_RDY_CLR_MASK;
  IOWR_ALTERA_AVALON_PIO_DATA(INFO_SYNC_OUT_BASE,info_sync_val);
}

void periphals_set_ready_bit() {
  info_sync_val = (info_sync_val & SYNC_INFO_OUT_ALL_MASK) | PERIPHALS_CFG_RDY_SET_MASK;
  IOWR_ALTERA_AVALON_PIO_DATA(INFO_SYNC_OUT_BASE,info_sync_val);
}

void run_pin_state(bool_t enable)
{
  if (enable) info_sync_val = (info_sync_val & SYNC_INFO_OUT_ALL_MASK) | RUN_PINCHECK_SET_MASK;
  else        info_sync_val =  info_sync_val & RUN_PINCHECK_CLR_MASK;
  IOWR_ALTERA_AVALON_PIO_DATA(INFO_SYNC_OUT_BASE,info_sync_val);
}

alt_u16 get_pin_state()
{
  SET_EXTINFO_SEL(HW_INFO);
  IOWR_ALTERA_AVALON_PIO_DATA(INFO_SYNC_OUT_BASE,info_sync_val);
  return (IORD_ALTERA_AVALON_PIO_DATA(EXT_INFO_IN_BASE) >> PIN_STATE_OFFSET);
}

void update_n64adv_state()
{
  static alt_u8 vin_detection_timeout = VIN_BOOT_DETECTION_TIMEOUT;

  n64adv_state = IORD_ALTERA_AVALON_PIO_DATA(N64ADV_STATE_IN_BASE);
  video_input_detected = TRUE;
  if ((n64adv_state & N64ADV_INPUT_VDATA_DETECTED_GETMASK) >> N64ADV_INPUT_VDATA_DETECTED_OFFSET) {
    if (vin_detection_timeout < VIN_DETECTION_TIMEOUT) vin_detection_timeout = VIN_DETECTION_TIMEOUT;
    else vin_detection_timeout--;
  } else {
    if (vin_detection_timeout == 0) video_input_detected = (bool_t) cfg_get_value(&debug_vtimeout,0);
    else vin_detection_timeout--;
    #ifdef DEBUG
      vid_timeout_cnt++;
    #endif
  }
  pal_pattern = ((n64adv_state & N64ADV_INPUT_PALPATTERN_GETMASK) >> N64ADV_INPUT_PALPATTERN_OFFSET);
  palmode = ((n64adv_state & N64ADV_INPUT_PALMODE_GETMASK) >> N64ADV_INPUT_PALMODE_OFFSET);
  use_pal_at_288p = !(
                      (cfg_get_value(&pal_boxed_mode,0)==FORCE_60HZ) ||
                      ((cfg_get_value(&pal_boxed_mode,0)==AUTO_HZ) && (n64adv_state & N64ADV_INPUT_PAL_IS_240P_GETMASK) >> N64ADV_INPUT_PAL_IS_240P_OFFSET)
                     );
  scanmode = ((n64adv_state & N64ADV_INPUT_INTERLACED_GETMASK) >> N64ADV_INPUT_INTERLACED_OFFSET);
  hor_hires = (scanmode == INTERLACED) || ((n64adv_state & N64ADV_240P_DEBLUR_GETMASK) == 0);

  hdmi_clk_ok = ((n64adv_state & N64ADV_HDMI_CLK_OK_GETMASK) >> N64ADV_HDMI_CLK_OK_OFFSET);
}

void update_ctrl_data()
{
  static bool_t tack = 0;
  ctrl_data = IORD_ALTERA_AVALON_PIO_DATA(CTRL_DATA_IN_BASE);
  tack = !tack;
  info_sync_val = (info_sync_val & CTRL_TACK_BIT_CLR_MASK) | tack;
  IOWR_ALTERA_AVALON_PIO_DATA(INFO_SYNC_OUT_BASE,info_sync_val);
}

cmd_t ctrl_data_to_cmd(bool_t no_fast_skip)
{
  cmd_t cmd_new = CMD_NON;
  static cmd_t cmd_pre_int = CMD_NON, cmd_pre = CMD_NON;

  static alt_u8 simple_btn_cmb_timeout = HOLD_CNT_LOW;
  static alt_u8 rep_cnt = 0, hold_cnt = HOLD_CNT_HIGH;

  if (cfg_get_value(&lock_menu,0)) {
    if (((ctrl_data & CTRL_GETALL_DIGITAL_MASK) == CTRL_DR_SETMASK) ||
        ((ctrl_data & CTRL_GETALL_DIGITAL_MASK) == CTRL_CR_SETMASK)   )
      cmd_new = CMD_MENU_RIGHT;
  } else {
    switch (ctrl_data & CTRL_GETALL_DIGITAL_MASK) {
      case BTN_OPEN_OSDMENU:
        cmd_new = CMD_OPEN_MENU;
        break;
      case BTN_CLOSE_OSDMENU:
        cmd_new = CMD_CLOSE_MENU;
        break;
      case BTN_MUTE_OSDMENU:
        cmd_new = CMD_MUTE_MENU;
        break;
      case BTN_DEBLUR_QUICK_ON:
        cmd_new = CMD_DEBLUR_QUICK_ON;
        break;
      case BTN_DEBLUR_QUICK_OFF:
        cmd_new = CMD_DEBLUR_QUICK_OFF;
        break;
      case BTN_16BIT_QUICK_ON:
        cmd_new = CMD_16BIT_QUICK_ON;
        break;
      case BTN_16BIT_QUICK_OFF:
        cmd_new = CMD_16BIT_QUICK_OFF;
        break;
      case BTN_MENU_ENTER:
        if (simple_btn_cmb_timeout == 0) cmd_new = CMD_MENU_ENTER;
        else simple_btn_cmb_timeout--;
        break;
      case BTN_MENU_BACK:
        if (simple_btn_cmb_timeout == 0) cmd_new = CMD_MENU_BACK;
        else simple_btn_cmb_timeout--;
        break;
      case CTRL_R_SETMASK:
        if (simple_btn_cmb_timeout == 0) cmd_new = CMD_MENU_PAGE_RIGHT;
        else simple_btn_cmb_timeout--;
        break;
      case CTRL_L_SETMASK:
      case CTRL_Z_SETMASK:
        if (simple_btn_cmb_timeout == 0) cmd_new = CMD_MENU_PAGE_LEFT;
        else simple_btn_cmb_timeout--;
        break;
      case CTRL_DU_SETMASK:
      case CTRL_CU_SETMASK:
        cmd_new = CMD_MENU_UP;
        break;
      case CTRL_DD_SETMASK:
      case CTRL_CD_SETMASK:
        cmd_new = CMD_MENU_DOWN;
        break;
      case CTRL_DL_SETMASK:
      case CTRL_CL_SETMASK:
        cmd_new = CMD_MENU_LEFT;
        break;
      case CTRL_DR_SETMASK:
      case CTRL_CR_SETMASK:
        cmd_new = CMD_MENU_RIGHT;
        break;
      default:
        simple_btn_cmb_timeout = HOLD_CNT_LOW;
    };

    if (cmd_new == CMD_NON) {
      alt_u16 xy_axis = ALT_CI_NIOS_CUSTOM_INSTR_BITSWAP_0(ctrl_data);
      alt_8 x_axis_val = xy_axis >> 8;
      alt_8 y_axis_val = xy_axis;

      if (x_axis_val  >  ANALOG_TH) cmd_new = CMD_MENU_RIGHT;
      if (x_axis_val  < -ANALOG_TH) cmd_new = CMD_MENU_LEFT;
      if (y_axis_val  >  ANALOG_TH) cmd_new = CMD_MENU_UP;
      if (y_axis_val  < -ANALOG_TH) cmd_new = CMD_MENU_DOWN;
    }
  }

  if (cmd_new == CMD_MUTE_MENU) {
    cmd_pre = cmd_new;
    cmd_pre_int = CMD_NON;
    return cmd_new;
  } else if (cmd_pre == CMD_MUTE_MENU) {
    cmd_pre = CMD_NON;
    return CMD_UNMUTE_MENU;
  }

  if (cmd_pre_int != cmd_new) {
    cmd_pre_int = cmd_new;
    rep_cnt = 0;
    hold_cnt = HOLD_CNT_HIGH;
  } else {
    if (hold_cnt == 0) {
      if (rep_cnt < 255) rep_cnt++;
      if      (rep_cnt <   HOLD_CNT_REP) hold_cnt = HOLD_CNT_HIGH;
      else if (rep_cnt < 2*HOLD_CNT_REP) hold_cnt = HOLD_CNT_MID;
      else                               hold_cnt = HOLD_CNT_LOW;
      if (!no_fast_skip) cmd_pre = CMD_NON;
    } else {
      hold_cnt--;
    }
  }

  if (cmd_pre != cmd_new) {
    cmd_pre = cmd_new;
    return cmd_new;
  }

  return CMD_NON;
}

inline bool_t get_vsync_cpu()
{
  return (IORD_ALTERA_AVALON_PIO_DATA(SYNC_IN_BASE) & NVSYNC_IN_MASK);
};

void loop_sync(bool_t use_vsync) {
  if (use_vsync) {
    while(!get_vsync_cpu()){}  /* wait for nVSYNC_CPU goes high (active OSD) */
    while( get_vsync_cpu()){}  /* wait for nVSYNC_CPU goes low  (inactive OSD) */
  } else {
    usleep(WAIT_20MS);
  }
}

int resync_vi_pipeline()
{
  if (!confirmation_routine(0)) return -CFG_RESYNC_ABORT; // does not return ok
  periphals_clr_ready_bit();
  run_pin_state(FALSE);
  usleep(100);
  periphals_set_ready_bit();
  run_pin_state(TRUE);
  return 0;
}

bool_t new_ctrl_available()
{
  return ((IORD_ALTERA_AVALON_PIO_DATA(SYNC_IN_BASE) & NEW_CTRL_DATA_IN_MASK) == NEW_CTRL_DATA_IN_MASK);
};

alt_u8 get_fallback_mode()
{
  return (IORD_ALTERA_AVALON_PIO_DATA(FALLBACK_IN_BASE) & FALLBACK_GETALL_MASK);
};

alt_u32 get_chip_id(cfg_offon_t msb_select)
{
  if (msb_select) {
      SET_EXTINFO_SEL(CHIP_ID_1);
      IOWR_ALTERA_AVALON_PIO_DATA(INFO_SYNC_OUT_BASE,info_sync_val);
      return IORD_ALTERA_AVALON_PIO_DATA(EXT_INFO_IN_BASE);
  } else {
      SET_EXTINFO_SEL(CHIP_ID_0);
      IOWR_ALTERA_AVALON_PIO_DATA(INFO_SYNC_OUT_BASE,info_sync_val);
      return IORD_ALTERA_AVALON_PIO_DATA(EXT_INFO_IN_BASE);
  }
};

alt_u8 get_pcb_version()
{
  SET_EXTINFO_SEL(HW_INFO);
  IOWR_ALTERA_AVALON_PIO_DATA(INFO_SYNC_OUT_BASE,info_sync_val);
  return (IORD_ALTERA_AVALON_PIO_DATA(EXT_INFO_IN_BASE) & GET_PCB_VERSION_MASK);
};

void get_game_id()
{
  alt_u8 idx;
  alt_u32 buf;

  game_id_valid = FALSE;

  SET_EXTINFO_SEL(GAME_ID_2);
  IOWR_ALTERA_AVALON_PIO_DATA(INFO_SYNC_OUT_BASE,info_sync_val);
  buf = IORD_ALTERA_AVALON_PIO_DATA(EXT_INFO_IN_BASE);
  game_id_valid |= buf > 0;
  for (idx = 0; idx < 2; idx++)
    game_id_raw[idx] = buf >> 8*(1-idx);

  SET_EXTINFO_SEL(GAME_ID_1);
  IOWR_ALTERA_AVALON_PIO_DATA(INFO_SYNC_OUT_BASE,info_sync_val);
  buf = IORD_ALTERA_AVALON_PIO_DATA(EXT_INFO_IN_BASE);
  game_id_valid |= buf > 0;
  for (idx = 0; idx < 4; idx++)
    game_id_raw[2+idx] = buf >> 8*(3-idx);

  SET_EXTINFO_SEL(GAME_ID_0);
  IOWR_ALTERA_AVALON_PIO_DATA(INFO_SYNC_OUT_BASE,info_sync_val);
  buf = IORD_ALTERA_AVALON_PIO_DATA(EXT_INFO_IN_BASE);
  game_id_valid |= buf > 0;
  for (idx = 0; idx < 4; idx++)
    game_id_raw[6+idx] = buf >> 8*(3-idx);

  sprintf(game_id_txt,"%02X%02X%02X%02X-%02X%02X%02X%02X-%02X",
          game_id_raw[0],game_id_raw[1],game_id_raw[2],game_id_raw[3],
          game_id_raw[4],game_id_raw[5],game_id_raw[6],game_id_raw[7],
          game_id_raw[9]);
}
