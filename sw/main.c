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
#include "led.h"


#define CTRL_IGNORE_FRAMES 10


const alt_u8 RW_Message_FontColor[] = {FONTCOLOR_GREEN,FONTCOLOR_RED,FONTCOLOR_MAGENTA};
const char *RW_Message[] __ufmdata_section__ = {"< Success >","< Failed >","< Aborted >"};
const char *Unlock_1440p_Message __ufmdata_section__ = "On your own risk, so\n"
                                                       "Good Luck I guess :)";

typedef struct {
  bool_t si5356_i2c_up;
  bool_t si5356_locked;
  bool_t adv7513_i2c_up;
  bool_t adv7513_hdmi_up;
} periphal_state_t;

//bool_t use_flash;
cfg_region_sel_type_t vmode_menu, vmode_n64adv, vmode_scaling_menu;
cfg_timing_model_sel_type_t timing_menu, timing_n64adv;
cfg_scaler_in2out_sel_type_t scaling_menu, scaling_n64adv;


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
      case LineX6W:
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
  bool_t keep_vout_rst = TRUE;

  bool_t load_n64_defaults, use_fallback;
  print_cr_info();

  periphal_state_t periphal_state = {FALSE,FALSE,FALSE,FALSE};

  bool_t ctrl_update = 1;
  bool_t ctrl_ignore = 0;

  vmode_t palmode_pre;
  clk_config_t target_resolution, target_resolution_pre;
//  bool_t hor_hires_pre;
  bool_t unlock_1440p_pre;

  alt_u8 message_cnt = 0;

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
  load_n64_defaults = (cfg_load_from_flash(0) != 0);

  while (is_fallback_mode_valid() == FALSE) {};
  use_fallback = get_fallback_mode();

  if (load_n64_defaults) {
    cfg_clear_words();  // just in case anything went wrong while loading from flash
    cfg_load_defaults(use_fallback,0);
    cfg_set_flag(&igr_reset); // handle a bit different from other defaults
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

#ifdef DEBUG
  open_osd_main(&menu);
#endif

  cfg_load_linex_word(NTSC);
  cfg_load_timing_word(NTSC_PROGRESSIVE);
  cfg_load_scaling_word(get_target_scaler(NTSC));

  target_resolution = get_target_resolution(PAL_PAT0,NTSC);

  cfg_apply_to_logic();

  I2C_init(I2C_MASTER_BASE,ALT_CPU_FREQ,400000);

  led_drive(LED_1, LED_ON);
  led_drive(LED_2, LED_ON);
  periphals_clr_ready_bit();

  update_ppu_state(); // also update commonly used ppu states (palmode, scanmode, linemult_mode)
  palmode_pre = palmode;
  target_resolution_pre = target_resolution;
//  hor_hires_pre = hor_hires;
  unlock_1440p_pre = unlock_1440p;

  /* Event loop never exits. */
  while (1) {
    ctrl_update = new_ctrl_available();

    if (ctrl_update && !ctrl_ignore) {
      update_ctrl_data();
      command = ctrl_data_to_cmd(0);
    } else {
      ctrl_ignore = ctrl_ignore == 0 ? 0 : ctrl_ignore - 1;
      command = CMD_NON;
    }

    vmode_n64adv = palmode;
    update_vmode_menu();
    scaling_n64adv = get_target_scaler(palmode);
    update_scaling_menu();
    if (palmode)
      timing_n64adv = scanmode ? PAL_INTERLACED : PAL_PROGRESSIVE;
    else
      timing_n64adv = scanmode ? NTSC_INTERLACED : NTSC_PROGRESSIVE;
    update_timing_menu();
    if (cfg_get_value(&pal_boxed_mode,0)) vmode_scaling_menu = NTSC;
    else vmode_scaling_menu = scaling_menu > NTSC_LAST_SCALING_MODE;

    if(cfg_get_value(&show_osd,0) && !keep_vout_rst) {
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
          vd_print_string(VD_TEXT,RWM_H_OFFSET,RWM_V_OFFSET,RW_Message_FontColor[todo-RW_DONE],RW_Message[todo-RW_DONE]);
          message_cnt = RWM_SHOW_CNT;
          break;
        default:
          break;
      }

      update_cfg_screen(menu);

      if (menu->type == VINFO)
        update_vinfo_screen(menu);

      if (menu->type == CONFIG) {
        cfg_store_linex_word(vmode_menu);
        cfg_store_timing_word(timing_menu);
        cfg_store_scaling_word(scaling_menu);
        print_current_timing_mode();
      } else {
        print_ctrl_data();
      }
      
    } else { /* ELSE OF if(cfg_get_value(&show_osd,0) && !keep_vout_rst) */
      todo = NON;

      if (command == CMD_OPEN_MENU && !keep_vout_rst) {
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

    } /* END OF if(cfg_get_value(&show_osd,0) && !keep_vout_rst) */

    cfg_load_linex_word(vmode_n64adv);
    cfg_load_timing_word(timing_n64adv);
    cfg_load_scaling_word(scaling_n64adv);
    cfg_apply_to_logic();

    if ((todo == MENU_CLOSE) && cfg_get_value(&autosave,0))
      cfg_save_to_flash(0);

    if (!periphal_state.si5356_i2c_up)
      periphal_state.si5356_i2c_up = check_si5356() == 0;
    else
      periphal_state.si5356_locked = SI5356_PLL_LOCKSTATUS();

    target_resolution = get_target_resolution(pal_pattern,palmode);

    if (!periphal_state.si5356_locked)
      periphal_state.si5356_locked = init_si5356(target_resolution);
    else if (target_resolution_pre != target_resolution)
      configure_clk_si5356(target_resolution);


    if (!periphal_state.adv7513_i2c_up)
      periphal_state.adv7513_i2c_up = check_adv7513() == 0;

    if (periphal_state.adv7513_i2c_up) {
      if (!periphal_state.adv7513_hdmi_up)
          periphal_state.adv7513_hdmi_up = init_adv7513();
      else if (!ADV_HPD_STATE() || !ADV_MONITOR_SENSE_STATE())
        periphal_state.adv7513_hdmi_up = FALSE;
      else if ((palmode_pre != palmode)                     ||
               (target_resolution_pre != target_resolution) ||
//               (hor_hires_pre != hor_hires)                 ||
               (todo == NEW_CONF_VALUE))
        set_cfg_adv7513();
    }

    if ((unlock_1440p_pre != unlock_1440p) && (unlock_1440p == TRUE)) {
      vd_print_string(VD_TEXT,RWM_H_OFFSET,RWM_V_OFFSET,RW_Message_FontColor[0],Unlock_1440p_Message);
      message_cnt = RWM_SHOW_CNT;
    }

    keep_vout_rst = !periphal_state.si5356_locked || !periphal_state.adv7513_hdmi_up;
    if (!keep_vout_rst)
      periphals_set_ready_bit();

    while(!get_vsync_cpu()){};  /* wait for nVSYNC_CPU goes high */
    while( get_vsync_cpu()){};  /* wait for nVSYNC_CPU goes low  */

    palmode_pre = palmode;
    target_resolution_pre = target_resolution;
 //   hor_hires_pre = hor_hires;
    unlock_1440p_pre = unlock_1440p;
    update_ppu_state();
  }

  return 0;
}
