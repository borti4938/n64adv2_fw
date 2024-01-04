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
  if (video_input_detected) {
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
  }
  return FREE_480p_VGA; // should only happen if no video input is being detected
}

cfg_scaler_in2out_sel_type_t get_target_scaler(vmode_t palmode_tmp)
{
  alt_u8 linex_setting = (alt_u8) cfg_get_value(&linex_resolution,0);

  if (palmode_tmp) return (PAL_TO_288 + linex_setting);
  else return (NTSC_TO_240 + linex_setting);
}

int main()
{
  // initialize menu
  #ifdef DEBUG
    home_menu.current_selection = DEBUG_IN_MAIN_MENU_SELECTION;
    menu_t *menu = &debug_screen;
  #else
    menu_t *menu = &home_menu;
  #endif

  // initialize flash and configuration
  cfg_clear_words();
  init_flash();
  bool_t load_n64_defaults = (cfg_load_from_flash(0) != 0);

  while (is_fallback_mode_valid() == FALSE) {};
  fallback_vmodes_t use_fallback = (fallback_vmodes_t) get_fallback_mode(); // returns either 0 or 1 (not associated to 1080p, 240p and 480p Fallback mode)

  if (load_n64_defaults) {
    cfg_clear_words();  // just in case anything went wrong while loading from flash
    cfg_load_defaults(2*use_fallback,0);  // loads 1080p on default and 480p if reset button is pressed (do not use fallback configuration from flash as load was invalid)
    cfg_set_flag(&igr_reset); // handle a bit different from other defaults
    cfg_update_reference();
    open_osd_main(&menu);
  } else {
    if (use_fallback > 0) {
      cfg_load_defaults(cfg_get_value(&fallbackmode,0),0);  // load the desired default settings
      open_osd_main(&menu);
    } else {
      #ifdef DEBUG
        open_osd_main(&menu);
      #else
        cfg_clear_flag(&show_osd);
      #endif
    }
    cfg_set_value(&deblur_mode,cfg_get_value(&deblur_mode_powercycle,0));
    cfg_set_value(&mode16bit,cfg_get_value(&mode16bit_powercycle,0));
  }


  // setup target resolution and apply config to FPGA
  cfg_load_linex_word(NTSC);
  cfg_load_timing_word(NTSC_PROGRESSIVE);
  cfg_load_scaling_word(get_target_scaler(NTSC));

  clk_config_t target_resolution, target_resolution_pre;
  target_resolution = get_target_resolution(PAL_PAT0,NTSC);
  target_resolution_pre = target_resolution;

  cfg_apply_to_logic();


  // update N64Adv2 state
  bool_t video_input_detected_pre = TRUE;
  update_n64adv_state(); // also update commonly used ppu states (video_input_detected, palmode, scanmode, linemult_mode)
  vmode_t palmode_pre = palmode;
  bool_t unlock_1440p_pre = unlock_1440p;


  // initialize I2C and periphal states
  // periphal devices will be initialized during event loop
  I2C_init(I2C_MASTER_BASE,ALT_CPU_FREQ,400000);

  periphal_state_t periphal_state = {FALSE,FALSE,FALSE,FALSE};
  periphals_clr_ready_bit();


  // set LEDs
  led_drive(LED_OK, LED_OFF);
  led_drive(LED_NOK, LED_ON);


  // define some variables for housekeeping
  cmd_t command;
  updateaction_t todo = NON;

  bool_t i2c_devs_ok = FALSE;
  bool_t keep_vout_rst = TRUE;
  bool_t ctrl_ignore = 0;

  bool_t igr_reset_tmp = (bool_t) cfg_get_value(&igr_reset,0);
  bool_t lock_menu_pre = FALSE;

  alt_u8 linex_word_pre;
  bool_t changed_linex_setting = FALSE;
  bool_t undo_changed_linex_setting = FALSE;

  message_cnt = 0;

  /* Event loop never exits. */
  while (1) {
    if (new_ctrl_available() && !ctrl_ignore) {
      update_ctrl_data();
      command = ctrl_data_to_cmd(0);
    } else {
      ctrl_ignore = ctrl_ignore == 0 ? 0 : ctrl_ignore - 1;
      command = CMD_NON;
    }

    vmode_n64adv = palmode;
    update_vmode_menu();
    scaling_n64adv = get_target_scaler(vmode_n64adv);
    update_scaling_menu();
    if (vmode_n64adv)
      timing_n64adv = scanmode ? PAL_INTERLACED : PAL_PROGRESSIVE;
    else
      timing_n64adv = scanmode ? NTSC_INTERLACED : NTSC_PROGRESSIVE;
    update_timing_menu();
    if (cfg_get_value(&pal_boxed_mode,0)) vmode_scaling_menu = NTSC;
    else vmode_scaling_menu = scaling_menu > NTSC_LAST_SCALING_MODE;

    if (!changed_linex_setting) // important to check this flag as program cycles 1x through menu after change to set also the scaling correctly
      linex_word_pre = linex_words[vmode_n64adv].config_val;

    if(cfg_get_value(&show_osd,0) && !keep_vout_rst) {
      cfg_load_linex_word(vmode_menu);
      cfg_load_timing_word(timing_menu);
      cfg_load_scaling_word(scaling_menu);

      if (message_cnt > 0) {
        if (command != CMD_NON) {
          command = CMD_NON;
          message_cnt = 1;
        }
        message_cnt--;
      }

      if (video_input_detected_pre && !video_input_detected) {  // go directly to debug screen if no video input is being detected and if not already there
        home_menu.current_selection = DEBUG_IN_MAIN_MENU_SELECTION;
        menu = &debug_screen;
        todo = NEW_OVERLAY;
      } else {  // else operate normally
        todo = modify_menu(command,&menu);
      }

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
        case CONFIRM_OK:
        case CONFIRM_FAILED:
        case CONFIRM_ABORTED:
          print_confirm_info(todo-CONFIRM_OK);
          message_cnt = CONFIRM_SHOW_CNT_MID;
          break;
        default:
          break;
      }

      update_cfg_screen(menu);

      if (menu->type == CONFIG) {
        cfg_store_linex_word(vmode_menu);
        cfg_store_timing_word(timing_menu);
        cfg_store_scaling_word(scaling_menu);
      }

      if (menu->type == N64DEBUG) update_debug_screen(menu);
      else run_pin_state(0);

      if (message_cnt == 0) {
        print_cr_info();
        if (menu->type == N64DEBUG) print_ctrl_data();
        else print_current_timing_mode();
      }

    } else { /* ELSE OF if(cfg_get_value(&show_osd,0) && !keep_vout_rst) */
      todo = NON;

      if (!keep_vout_rst) {
        if (video_input_detected_pre && !video_input_detected) {  // open menu in debug screen if no video input is being detected
          command = CMD_OPEN_MENU;
          home_menu.current_selection = DEBUG_IN_MAIN_MENU_SELECTION;
          menu = &debug_screen;
        }
        if (command == CMD_OPEN_MENU) {
          open_osd_main(&menu);
          ctrl_ignore = CTRL_IGNORE_FRAMES;
        }
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

    if (cfg_get_value(&lock_menu,0)) {
      if (!lock_menu_pre) igr_reset_tmp = (bool_t) cfg_get_value(&igr_reset,0);
      cfg_clear_flag(&igr_reset);
      lock_menu_pre = TRUE;
    } else {
      cfg_set_value(&igr_reset,(alt_u16) igr_reset_tmp);
      lock_menu_pre = FALSE;
    }

    cfg_apply_to_logic();

    if ((todo == MENU_CLOSE) && cfg_get_value(&autosave,0))
      cfg_save_to_flash(0);

    if (!periphal_state.si5356_i2c_up)
      periphal_state.si5356_i2c_up = check_si5356() == 0;
    else
      periphal_state.si5356_locked = SI5356_PLL_LOCKSTATUS();

    target_resolution = get_target_resolution(pal_pattern,palmode);

    if (!periphal_state.si5356_locked) {
      i2c_devs_ok = FALSE;
      periphal_state.si5356_locked = init_si5356(target_resolution);
    } else if (target_resolution_pre != target_resolution) {
      i2c_devs_ok = FALSE;
      configure_clk_si5356(target_resolution);
    }


    if (!periphal_state.adv7513_i2c_up)
      periphal_state.adv7513_i2c_up = check_adv7513() == 0;

    if (periphal_state.adv7513_i2c_up) {
      if (!periphal_state.adv7513_hdmi_up) {
          i2c_devs_ok = FALSE;
          periphal_state.adv7513_hdmi_up = init_adv7513();
      } else if (!ADV_HPD_STATE() || !ADV_MONITOR_SENSE_STATE()) {
        i2c_devs_ok = FALSE;
        periphal_state.adv7513_hdmi_up = FALSE;
      } else if ((palmode_pre != palmode) || (undo_changed_linex_setting) || (todo == NEW_CONF_VALUE)) {
        i2c_devs_ok = FALSE;
        set_cfg_adv7513();
      }
    }

    if ((unlock_1440p_pre != unlock_1440p) && (unlock_1440p == TRUE)) {
      print_1440p_unlock_info();
      message_cnt = CONFIRM_SHOW_CNT_MID;
    }

    if (periphal_state.si5356_locked && periphal_state.adv7513_hdmi_up) {
      if (!i2c_devs_ok) led_drive(LED_OK,LED_ON);
      if (get_led_timout(LED_OK) == 0) led_drive(LED_OK,LED_OFF);
      else dec_led_timeout(LED_OK);
      i2c_devs_ok = TRUE;
    }

    keep_vout_rst = !periphal_state.si5356_locked ||
                    !periphal_state.adv7513_hdmi_up ||
                    init_phase; // do not output during initial phase
    if (!keep_vout_rst) {
      periphals_set_ready_bit();
      if (menu->type != N64DEBUG) { // LEDs are not under control by Debug-Screen
        if (video_input_detected) {
          clear_led_timeout(LED_NOK);
          led_drive(LED_NOK,LED_OFF);
        } else {
          led_drive(LED_NOK,LED_ON);
        }
      }
    }

    if (undo_changed_linex_setting) undo_changed_linex_setting = FALSE;

    if (changed_linex_setting) {  // important to check this flag in that order
                                  // as program cycles 1x through menu after change to set also the scaling correctly
      if (!confirmation_routine(1)) {  // change was not ok
        print_confirm_info(CONFIRM_ABORTED-CONFIRM_OK);
        linex_words[vmode_n64adv].config_val = linex_word_pre;
        undo_changed_linex_setting = TRUE;
        message_cnt = CONFIRM_SHOW_CNT_LONG;
      } else {
        print_confirm_info(CONFIRM_OK-CONFIRM_OK);
        message_cnt = CONFIRM_SHOW_CNT_MID;
      }
      changed_linex_setting = FALSE;
    } else if (menu == &vires_screen) {
      changed_linex_setting = (linex_word_pre != linex_words[vmode_n64adv].config_val);
    }

    loop_sync(keep_vout_rst);

    video_input_detected_pre = video_input_detected;
    palmode_pre = palmode;
    target_resolution_pre = target_resolution;
    unlock_1440p_pre = unlock_1440p;
    update_n64adv_state();
  }

  return 0;
}
