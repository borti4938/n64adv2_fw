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
 * main.c
 *
 *  Created on: 08.01.2018
 *      Author: Peter Bartmann
 *
 ********************************************************************************/

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include "alt_types.h"
#include <sys/alt_sys_init.h>
#include "i2c_opencores.h"
#include "system.h"
#include "app_cfg.h"
#include "adv7513.h"
#include "si5356.h"
#include "n64.h"
#include "config.h"
#include "menu.h"
#include "vd_driver.h"
#include "flash.h"


#define CTRL_IGNORE_FRAMES 10;


const alt_u8 RW_Message_FontColor[] = {FONTCOLOR_GREEN,FONTCOLOR_RED,FONTCOLOR_MAGENTA};
const char *RW_Message[] __ufmdata_section__ = {"< Success >","< Failed >","< Aborted >"};
const char *Unlock_1440p_Message __ufmdata_section__ = "< Good Luck! > :)";

//bool_t use_flash;
vmode_t vmode_menu, vmode_n64adv, vmode_scaling_menu;
cfg_timing_model_sel_type_t timing_menu, timing_n64adv;
cfg_scaler_in2out_sel_type_t scaling_menu, scaling_n64adv;

extern config_tray_t linex_words[2];


/* ToDo's:
 * - Display warning messages
 * - Additional windows (Ctrl. input, Video Output as OSD without menu)
 */

void open_osd_main(menu_t **menu)
{
  print_overlay(*menu);
  cfg_set_flag(&show_logo);
  print_selection_arrow(*menu);
  cfg_set_flag(&show_osd);
  cfg_clear_flag(&mute_osd_tmp);
}


clk_config_t get_target_resolution(cfg_pal_pattern_t pal_pattern_tmp, vmode_t palmode_tmp)
{
  alt_u8 linex_setting = (alt_u8) cfg_get_value(&linex_resolution,0);
  if ((alt_u8) cfg_get_value(&low_latency_mode,0) == ON) {
    alt_u8 case_val = (pal_pattern_tmp << 1 | palmode_tmp);
    switch (case_val) {
      case 3:
        return PAL1_N64_288p + linex_setting;
      case 1:
        return PAL0_N64_288p + linex_setting;
      default:
        if ((alt_u8) cfg_get_value(&vga_for_480p,0) && linex_setting == LineX2)  return NTSC_N64_VGA;
        else return NTSC_N64_240p + linex_setting;
    }
  } else {
    switch (linex_setting) {
      case PASSTHROUGH:
        return FREE_240p_288p;
      case LineX2:
        if ((alt_u8) cfg_get_value(&linex_force_5060,0) == 0) {
          if (palmode_tmp == NTSC) return FREE_480p_VGA;
          else                     return FREE_576p;
        } else {
          if ((alt_u8) cfg_get_value(&linex_force_5060,0) == 1) return FREE_480p_VGA;
          else return FREE_576p;
        }
      case LineX3:
      case LineX4:
        return FREE_720p_960p;
      case LineX4p5:
      case LineX5:
        return FREE_1080p_1200p;
      case LineX6:
        return FREE_1440p;
    }
  }
  return FREE_480p_VGA; // should never happen
}

cfg_scaler_in2out_sel_type_t get_target_scaler(vmode_t palmode_tmp)
{
  alt_u8 linex_setting = (alt_u8) cfg_get_value(&linex_resolution,0);

  if (palmode_tmp) return (PAL_TO_288 + linex_setting);
  else return (NTSC_TO_240 + linex_setting);
}

int main()
{
  cmd_t command;
  updateaction_t todo = NON;
  menu_t *menu = &home_menu;
  print_cr_info();

  bool_t ctrl_update = 1;
  bool_t ctrl_ignore = 0;

  int message_cnt = 0;

//  use_flash = FALSE;
//  if (check_flash() == 0) use_flash = TRUE;
//
//  bool_t load_n64_defaults = FALSE;
//  cfg_clear_words();
//  if (use_flash) {
//    load_n64_defaults = (cfg_load_from_flash(0) != 0);
//  }

  cfg_clear_words();
  init_flash();
  bool_t load_n64_defaults = (cfg_load_from_flash(0) != 0);

  bool_t use_fallback = get_fallback_mode();
  while (is_fallback_mode_valid() == FALSE) use_fallback = get_fallback_mode();

  if (load_n64_defaults) {
    cfg_clear_words();  // just in case anything went wrong while loading from flash
    cfg_load_defaults(1,0);
    cfg_update_reference();
    open_osd_main(&menu);
  } else {
    if (use_fallback) {
      cfg_load_defaults(cfg_get_value(&fallbackmode,0),0);
      open_osd_main(&menu);
    } else {
      cfg_clear_flag(&show_osd);
    }
    cfg_set_value(&deblur_mode,cfg_get_value(&deblur_mode_powercycle,0));
    cfg_set_value(&mode16bit,cfg_get_value(&mode16bit_powercycle,0));
  }

  cfg_load_linex_word(NTSC);
  cfg_load_timing_word(NTSC_PROGRESSIVE);
  cfg_load_scaling_word(get_target_scaler(NTSC));

  if (((linex_words[NTSC].config_val & CFG_RESOLUTION_GETMASK) == CFG_RESOLUTION_1440_SETMASK) ||
      ((linex_words[PAL].config_val & CFG_RESOLUTION_GETMASK) == CFG_RESOLUTION_1440_SETMASK))
    unlock_1440p = TRUE;
  else
    unlock_1440p = FALSE;
  bool_t unlock_1440p_pre = unlock_1440p;


  clk_config_t target_resolution = get_target_resolution(PAL_PAT0,NTSC);

  cfg_apply_to_logic();

  I2C_init(I2C_MASTER_BASE,ALT_CPU_FREQ,200000);
  while (check_si5356() != 0) {};
  init_si5356(target_resolution);
  while (check_adv7513() != 0) {};
  while (!ADV_HPD_STATE() || !ADV_MONITOR_SENSE_STATE()) {};
  init_adv7513(); // assume that hpd and monitor sense are up

  update_ppu_state(); // also update commonly used ppu states (palmode, scanmode, linemult_mode)

  set_avi_info();

  cfg_pal_pattern_t pal_pattern_pre = PAL_PAT0;
  vmode_t palmode_pre = NTSC;
  clk_config_t target_resolution_pre = target_resolution;
  bool_t hor_hires_pre = hor_hires;

  /* Event loop never exits. */
  while (1) {
    ctrl_update = new_ctrl_available();
    update_ppu_state();

    if (ctrl_update && !ctrl_ignore) {
      update_ctrl_data();
      command = ctrl_data_to_cmd(0);
    } else {
      ctrl_ignore = ctrl_ignore == 0 ? 0 : ctrl_ignore - 1;
      command = CMD_NON;
    }

    vmode_n64adv = palmode;
    update_vmode_menu(menu);
    if (palmode)
      timing_n64adv = scanmode ? PAL_INTERLACED : PAL_PROGRESSIVE;
    else
      timing_n64adv = scanmode ? NTSC_INTERLACED : NTSC_PROGRESSIVE;
    timing_menu = (cfg_timing_model_sel_type_t) cfg_get_value(&timing_selection,0);
    if (timing_menu == PPU_TIMING_CURRENT) timing_menu = timing_n64adv;
    scaling_n64adv = get_target_scaler(palmode);
    scaling_menu = (cfg_scaler_in2out_sel_type_t) cfg_get_value(&scaling_selection,0);
    if (scaling_menu == PPU_SCALING_CURRENT) scaling_menu = scaling_n64adv;
    if (cfg_get_value(&pal_boxed_mode,0)) vmode_scaling_menu = NTSC;
    else vmode_scaling_menu = scaling_menu > NUM_SCALING_MODES/2; // NUM_SCALING_MODES/2 should be exactly the border between NTSC and PAL

    if(cfg_get_value(&show_osd,0)) {
      cfg_load_linex_word(vmode_menu);
      cfg_load_timing_word(timing_menu);
      cfg_load_scaling_word(scaling_menu);

      if (message_cnt > 0) {
        if (command != CMD_NON) {
          command = CMD_NON;
          message_cnt = 1;
        }
        if (message_cnt == 1) vd_clear_txt_area(RWM_H_OFFSET,VD_WIDTH-1,RWM_V_OFFSET,RWM_V_OFFSET+1);
        message_cnt--;
      }

      todo = modify_menu(command,&menu);

      switch (todo) {
        case MENU_CLOSE:
          cfg_clear_flag(&show_osd);
          break;
        case MENU_MUTE:
          cfg_set_flag(&mute_osd_tmp);
          break;
        case MENU_UNMUTE:
          cfg_clear_flag(&mute_osd_tmp);
          break;
        case NEW_OVERLAY:
          print_overlay(menu);
          print_selection_arrow(menu);
          message_cnt = 0;
          /* no break */
        case NEW_SELECTION:
          print_selection_arrow(menu);
          break;
        case RW_DONE:
        case RW_FAILED:
        case RW_ABORT:
          vd_print_string(VD_TEXT,RWM_H_OFFSET,RWM_V_OFFSET,BACKGROUNDCOLOR_STANDARD,RW_Message_FontColor[todo-RW_DONE],RW_Message[todo-RW_DONE]);
          message_cnt = RWM_SHOW_CNT;
          break;
        default:
          break;
      }

      if (menu->type == VINFO) update_vinfo_screen(menu);
      if (menu->type == CONFIG) {
        update_cfg_screen(menu);
        cfg_store_linex_word(vmode_menu);
        cfg_store_timing_word(timing_menu);
        cfg_store_scaling_word(scaling_menu);
        print_current_timing_mode();
      } else {
        if (menu->type == RWDATA) update_cfg_screen(menu);
        print_ctrl_data();
      }
      
    } else { /* END OF if(cfg_get_value(&show_osd)) */
      todo = NON;

      if (command == CMD_OPEN_MENU) {
        open_osd_main(&menu);
        ctrl_ignore = CTRL_IGNORE_FRAMES;
      }

      if (cfg_get_value(&igr_deblur,0))
        switch (command) {
          case CMD_DEBLUR_QUICK_ON:
            if (scanmode == PROGRESSIVE) {
              cfg_set_flag(&deblur_mode);
            };
            break;
          case CMD_DEBLUR_QUICK_OFF:
            if (scanmode == PROGRESSIVE) {
              cfg_clear_flag(&deblur_mode);
            };
            break;
          default:
            break;
        }

      if (cfg_get_value(&igr_16bitmode,0))
          switch (command) {
            case CMD_16BIT_QUICK_ON:
              cfg_set_flag(&mode16bit);
              break;
            case CMD_16BIT_QUICK_OFF:
              cfg_clear_flag(&mode16bit);
              break;
            default:
              break;
          }

    } /* END OF if(!cfg_get_value(&show_osd)) */

    cfg_load_linex_word(vmode_n64adv);
    cfg_load_timing_word(timing_n64adv);
    cfg_load_scaling_word(scaling_n64adv);
    cfg_apply_to_logic();

    target_resolution = get_target_resolution(pal_pattern,palmode);
    if (((pal_pattern_pre != pal_pattern) & (palmode == NTSC)) ||
        (palmode_pre != palmode)                               ||
        (target_resolution_pre != target_resolution)            )
      configure_clk_si5356(target_resolution);
    if (!SI5356_PLL_LOCKSTATUS())
      init_si5356(target_resolution);

    if (!ADV_HPD_STATE() || !ADV_MONITOR_SENSE_STATE()) {
      init_adv7513();
    }

    if ((palmode_pre != palmode)                     ||
        (target_resolution_pre != target_resolution) ||
        (hor_hires_pre != hor_hires)                 ||
        (todo == NEW_CONF_VALUE))
      set_avi_info();

    if (unlock_1440p_pre != unlock_1440p) {
      vd_print_string(VD_TEXT,VD_WIDTH - 17,RWM_V_OFFSET+1,BACKGROUNDCOLOR_STANDARD,RW_Message_FontColor[0],Unlock_1440p_Message);
      message_cnt = RWM_SHOW_CNT;
      unlock_1440p_pre = unlock_1440p;
    }

    while(!get_osdvsync()){};  /* wait for OSD_VSYNC goes high (OSD vert. active area) */
    while( get_osdvsync()){};  /* wait for OSD_VSYNC goes low  */

    pal_pattern_pre = pal_pattern;
    palmode_pre = palmode;
    target_resolution_pre = target_resolution;
  }

  return 0;
}
