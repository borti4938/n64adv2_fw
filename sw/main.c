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
#include "common_types.h"
#include "i2c_opencores.h"
#include "system.h"
#include "app_cfg.h"
#include "si5356.h"
#include "n64.h"
#include "config.h"
#include "menu.h"
#include "vd_driver.h"
#include "flash.h"
#include "led.h"
#include "video.h"


#define VSIF_CYCLE_CNT_TH 7

typedef struct {
  bool_t si5356_i2c_up;
  bool_t si5356_locked;
  bool_t adv7513_i2c_up;
  bool_t adv7513_hdmi_up;
} periphal_state_t;

//bool_t use_flash;
vmode_t vmode_n64adv, vmode_menu, vmode_menu_pre, vmode_scaling_menu;
cfg_timing_model_sel_type_t timing_n64adv, timing_menu;
cfg_scaler_in2out_sel_type_t scaling_n64adv, scaling_menu;

extern alt_u8 info_sync_val;

/* ToDo's:
 * - Display warning messages
 * - Additional windows (Ctrl. input, Video Output as OSD without menu)
 */

void open_osd_main(menu_t **menu)
{
  print_overlay(*menu);
  cfg_set_value(&show_logo,ON);
  print_selection_arrow(*menu);
  cfg_set_value(&show_osd,ON);
  active_osd = TRUE;
  cfg_set_value(&mute_osd_tmp,OFF);
}


clk_config_t get_target_resolution(cfg_pal_pattern_t pal_pattern_tmp, vmode_t palmode_tmp)
{
  clk_config_t retval = FREE_VGA60_480p;
  if (video_input_detected) {
    alt_u8 linex_setting = (alt_u8) cfg_get_value(&linex_resolution,0);
    bool_t is_fx_direct = (alt_u8) cfg_get_value(&dvmode_version,0);
    alt_u8 not_vga = 1 - ((alt_u8) cfg_get_value(&vga_for_480p,0) && linex_setting == LineX2);
    alt_u8 case_val = (pal_pattern_tmp << 1 | palmode_tmp);
    if (linex_setting == DIRECT) {
        switch (case_val) {
          case 3:
            retval = is_fx_direct ? PAL1_N64_720p : PAL1_N64_DIRECT;
            break;
          case 1:
            retval = is_fx_direct ? PAL0_N64_720p : PAL0_N64_DIRECT;
            break;
          default:
            retval = is_fx_direct ? NTSC_N64_720p : NTSC_N64_DIRECT;
        }
    } else if ((alt_u8) cfg_get_value(&low_latency_mode,0) == ON) {
      alt_u8 linex_offset = not_vga*linex_setting;
      switch (case_val) {
        case 0b11:
          retval = PAL1_N64_VGA + linex_offset;
          break;
        case 0b01:
          retval = PAL0_N64_VGA + linex_offset;
          break;
        default:
          retval = NTSC_N64_VGA + linex_offset;
      }
    } else {
      switch (linex_setting) {
        case LineX2:
          if ((alt_u8) cfg_get_value(&linex_force_5060,0) == AUTO_HZ) {
            if (palmode_tmp == NTSC) retval = FREE_VGA60_480p;
            else                     retval = FREE_VGA50_576p;
          } else {
            if ((alt_u8) cfg_get_value(&linex_force_5060,0) == FORCE_60HZ) retval = FREE_VGA60_480p;
            else                                                           retval = FREE_VGA50_576p;
          }
          break;
        case LineX3:
        case LineX4:
          retval = FREE_720p_960p;
          break;
        case LineX4p5:
        case LineX5:
          retval = FREE_1080p_1200p;
          break;
        case LineX6:
        case LineX6W:
        default:
          retval = FREE_1440p;
      }
    }
  }
  return retval;
}

cfg_scaler_in2out_sel_type_t get_target_scaler(vmode_t palmode_tmp)
{
  alt_u8 linex_setting = (alt_u8) cfg_get_value(&linex_resolution,0);

  if (palmode_tmp) return (PAL_DIRECT + linex_setting);
  else return (NTSC_DIRECT + linex_setting);
}

void load_value_trays(bool_t for_n64adv)
{
  if (vmode_menu_pre != vmode_menu)
    linex_words[LINEX_TMP_TRAY] = linex_words[vmode_menu];
  vmode_menu_pre = vmode_menu;
  if (for_n64adv) {
    cfg_load_linex_word(vmode_n64adv,for_n64adv);
    cfg_load_timing_word(timing_n64adv);
    cfg_load_scaling_word(scaling_n64adv);
  } else {
    cfg_load_linex_word(vmode_menu,for_n64adv);
    cfg_load_timing_word(timing_menu);
    cfg_load_scaling_word(scaling_menu);
  }
}

void store_value_trays()
{
  cfg_store_linex_word(vmode_menu,1);
  cfg_store_timing_word(timing_menu);
  cfg_store_scaling_word(scaling_menu);
}

int main()
{
  // initialize menu
  #ifdef DEBUG
    home_menu.current_selection = DEBUG_IN_MAIN_MENU_SELECTION;
    menu_t *menu = &debug_screen;
    bool_t load_n64_defaults = TRUE;
  #else
    menu_t *menu = &home_menu;

    // initialize flash and configuration
    cfg_clear_words();
    init_flash();
    bool_t load_n64_defaults = (cfg_load_from_flash(0) != 0);
  #endif

  bool_t fallback_triggered = FALSE;
  alt_u8 use_fallback;
  do {
    use_fallback = (get_fallback_mode() & FALLBACKRST_GETMASK);
  } while (use_fallback == 0);

  active_osd = FALSE;
  cfg_set_value(&show_osd,OFF);

  if (load_n64_defaults) {
    cfg_clear_words();  // just in case anything went wrong while loading from flash
    cfg_load_defaults((use_fallback & FALLBACKRST_PRESSED_GETMASK) ? FB_480P : FB_1080P,0);  // loads 1080p on default and 480p if reset button is pressed (do not use fallback configuration from flash as load was invalid)
    fallback_triggered = TRUE;
    cfg_set_value(&igr_reset,ON);     // handle a bit different from other defaults
    cfg_set_value(&fallback_menu,ON); // handle a bit different from other defaults
    cfg_update_reference();
    open_osd_main(&menu);
  } else {
    if (cfg_get_value(&fallback_trigger,0) == 1) { // fallback only on button L
      use_fallback = 0; // clear fallback on reset button
    }
    if (use_fallback > 1) { // fallback on reset button triggered
      if (cfg_get_value(&fallback_menu,0) == TRUE) open_osd_main(&menu);
      cfg_load_defaults(cfg_get_value(&fallback_resolution,0),0);  // load the desired default settings
      fallback_triggered = TRUE;  // fallback triggered on reset button
    }
    cfg_set_value(&deblur_mode,cfg_get_value(&deblur_mode_powercycle,0));
    cfg_set_value(&mode16bit,cfg_get_value(&mode16bit_powercycle,0));
  }


  // setup initial target resolution and apply config to FPGA
  vmode_n64adv = NTSC;
  timing_n64adv = NTSC_PROGRESSIVE;
  scaling_n64adv = get_target_scaler(NTSC);
  load_value_trays(1);

  clk_config_t target_resolution, target_resolution_pre;
  target_resolution = get_target_resolution(PAL_PAT0,NTSC);
  target_resolution_pre = target_resolution;

  // N64Adv2 state variable
  bool_t video_input_detected_pre;
  vmode_t palmode_pre = palmode;
  scanmode_t scanmode_pre = scanmode;
  bool_t unlock_1440p_pre = unlock_1440p;

  // set LEDs
  led_drive(LED_OK, LED_OFF);
  led_drive(LED_NOK, LED_ON);

  // initialize I2C and periphal states
  // periphal devices will be initialized during event loop
  I2C_init(I2C_MASTER_BASE,ALT_CPU_FREQ,400000);

  periphal_state_t periphal_state = {FALSE,FALSE,FALSE,FALSE};
  periphals_clr_ready_bit();

  // check for I2C devices
  do {
    periphal_state.si5356_i2c_up = check_si5356() == 0;
  } while(!periphal_state.si5356_i2c_up);
  init_si5356();

  do {
    periphal_state.adv7513_i2c_up = check_adv7513() == 0;
  } while(!periphal_state.adv7513_i2c_up);


  // define some variables for housekeeping
  cmd_t command;
  updateaction_t todo = NON;

  info_sync_val = 0;
  bool_t ctrl_ignore = 0;

  bool_t igr_reset_tmp = (bool_t) cfg_get_value(&igr_reset,0);
  bool_t active_osd_pre;
  bool_t lock_menu_pre = FALSE;

  alt_u8 linex_word_pre;
  bool_t changed_linex_setting = FALSE;
  bool_t undo_changed_linex_setting = FALSE;

  bool_t led_set_ok = FALSE;
  bool_t use_fxd_mode;
  bool_t use_fxd_mode_pre = FALSE;
  alt_u8 vsif_cycle_cnt = 0;

  // set some basic variables for operation
  message_cnt = 0;
#ifdef DEBUG
  vid_timeout_cnt = 0;
#endif

  /* Event loop never exits. */
  while (1) {

    active_osd_pre = active_osd;
    video_input_detected_pre = video_input_detected;
    palmode_pre = palmode;
    scanmode_pre = scanmode;
    target_resolution_pre = target_resolution;
    unlock_1440p_pre = unlock_1440p;
    update_n64adv_state(); // also update commonly used ppu states (video_input_detected, palmode, scanmode, linemult_mode)

    loop_sync(hdmi_clk_ok); // as soon as we have an hdmi clock (i2c devices are ready then),
                            // the FPGA will produces sync signal, no matter we have an input signal detected or not

    if (new_ctrl_available() && !ctrl_ignore) {
      update_ctrl_data();
      command = ctrl_data_to_cmd(0);
    } else {
      ctrl_ignore = ctrl_ignore == 0 ? 0 : ctrl_ignore - 1;
      command = CMD_NON;
    }

    if (fallback_triggered == FALSE) {
      use_fallback = (get_fallback_mode() & FALLBACKCTRL_GETMASK);  // check for fallback on controller L
      if ((use_fallback > 0)) {
        fallback_triggered = TRUE;
        if (((use_fallback & FALLBACKCTRL_PRESSED_GETMASK) == FALLBACKCTRL_PRESSED_GETMASK) &&  // controller L pressed
            (cfg_get_value(&fallback_trigger,0) > 0)) { // fallback on controller L also enabled
          if (cfg_get_value(&fallback_menu,0) == TRUE) open_osd_main(&menu);
          cfg_load_defaults(cfg_get_value(&fallback_resolution,0),0);  // load the desired default settings
        }
      }
    }

    // update correct config set for FPGA
    if (!changed_linex_setting) { // important to check this flag as program cycles 1x through menu after change to set also the scaling correctly
      linex_word_pre = linex_words[palmode].config_val;
      vmode_n64adv = palmode; // update only if there is no change in linex config
    }
    if (vmode_n64adv)
      timing_n64adv = scanmode ? PAL_INTERLACED : PAL_PROGRESSIVE;
    else
      timing_n64adv = scanmode ? NTSC_INTERLACED : NTSC_PROGRESSIVE;
    scaling_n64adv = get_target_scaler(vmode_n64adv);

    // update correct config set for menu
    vmode_menu = cfg_get_value(&region_selection,0);
    timing_menu = cfg_get_value(&timing_selection,0);
    scaling_menu = cfg_get_value(&scaling_selection,0);
    if (cfg_get_value(&pal_boxed_mode,0)) vmode_scaling_menu = NTSC;
    else vmode_scaling_menu = scaling_menu > NTSC_LAST_SCALING_MODE;

    if(active_osd && hdmi_clk_ok) {
      if (message_cnt > 0) {
        if (command != CMD_NON) {
          command = CMD_NON;
          message_cnt = 1;
        }
        message_cnt--;
      }

      // load settings to display correct values for menu
      load_value_trays(0);

      if (video_input_detected_pre && !video_input_detected) {  // go directly to debug screen if no video input is being detected and if not already there
        home_menu.current_selection = DEBUG_IN_MAIN_MENU_SELECTION;
        menu = &debug_screen;
        todo = NEW_OVERLAY;
      } else {  // else operate normally
        todo = modify_menu(command,&menu);
      }

      switch (todo) {
        case MENU_CLOSE:
          cfg_set_value(&show_osd,OFF);
          active_osd = FALSE;
          if (cfg_get_value(&autosave,0)) cfg_save_to_flash(0);
          break;
        case MENU_MUTE:
          cfg_set_value(&mute_osd_tmp,ON);
          break;
        case MENU_UNMUTE:
          cfg_set_value(&mute_osd_tmp,OFF);
          break;
        case NEW_OVERLAY:
          cfg_set_value(&region_selection,palmode);
          cfg_set_value(&copy_direction,palmode);
          cfg_set_value(&scaling_selection,scaling_n64adv);
          cfg_set_value(&timing_selection,timing_n64adv);
          vmode_menu_pre = (palmode == NTSC); // make sure that we load setting next loop correctly
          load_value_trays(0);  // reload needed
          print_overlay(menu);
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

      if (menu->type == CONFIG) store_value_trays(); // and store everything in case there was a change

      if (menu->type == N64DEBUG) update_debug_screen(menu);
      else run_pin_state(0);

      linex_words[PAL+1].config_val = (sysconfig.cfg_word_def[EXTCFG0]->cfg_word_val & CFG_EXTCFG0_GETLINEX_MASK);  // save current menu settings

    } else { /* ELSE OF if(active_osd && hdmi_clk_ok) */
      todo = NON;

      if (video_input_detected_pre && !video_input_detected) {  // open menu in debug screen if no video input is being detected
        command = CMD_OPEN_MENU;
        home_menu.current_selection = DEBUG_IN_MAIN_MENU_SELECTION;
        menu = &debug_screen;
      }
      if (command == CMD_OPEN_MENU) {
        open_osd_main(&menu);
      }

      if ((scanmode == PROGRESSIVE) && cfg_get_value(&igr_deblur,0))
        switch (command) {
          case CMD_DEBLUR_QUICK_ON:
            cfg_set_value(&deblur_mode,ON);
            todo = NEW_CONF_VALUE;
            break;
          case CMD_DEBLUR_QUICK_OFF:
            cfg_set_value(&deblur_mode,OFF);
            todo = NEW_CONF_VALUE;
            break;
          default:
            break;
        }

      if (cfg_get_value(&igr_16bitmode,0))
        switch (command) {
          case CMD_16BIT_QUICK_ON:
            cfg_set_value(&mode16bit,ON);
            todo = NEW_CONF_VALUE;
            break;
          case CMD_16BIT_QUICK_OFF:
            cfg_set_value(&mode16bit,OFF);
            todo = NEW_CONF_VALUE;
            break;
          default:
            break;
        }

      message_cnt = 0;
    } /* END OF if(active_osd && hdmi_clk_ok) */

    if (cfg_get_value(&lock_menu,0)) {
      if (!lock_menu_pre) igr_reset_tmp = (bool_t) cfg_get_value(&igr_reset,0);
      cfg_set_value(&igr_reset,OFF);
      lock_menu_pre = TRUE;
    } else if (lock_menu_pre) {
      cfg_set_value(&igr_reset,(alt_u16) igr_reset_tmp);
      lock_menu_pre = FALSE;
    }

    load_value_trays(1); // load settings for FPGA before leaving loop
    cfg_apply_to_logic();

    if (message_cnt == 0) {
      if (menu->type == N64DEBUG) print_ctrl_data();
      else print_current_timing_mode();
    }

    target_resolution = get_target_resolution(pal_pattern,palmode);
    if (periphal_state.si5356_locked) periphal_state.si5356_locked = SI5356_PLL_LOCKSTATUS();

    // check up routines for si5356
    if (!periphal_state.si5356_locked || (target_resolution_pre != target_resolution)) {
      led_drive(LED_NOK, LED_ON);
      periphals_clr_ready_bit();
      led_set_ok = FALSE;
      periphal_state.si5356_locked = configure_clk_si5356(target_resolution);
    }

    // check up routines for adv7513
    if (periphal_state.adv7513_hdmi_up) {
      periphal_state.adv7513_hdmi_up = (ADV_HPD_STATE() && ADV_MONITOR_SENSE_STATE());
    }
    if (!periphal_state.adv7513_hdmi_up) {
      led_drive(LED_NOK, LED_ON);
      periphals_clr_ready_bit();
      led_set_ok = FALSE;
      periphal_state.adv7513_hdmi_up = init_adv7513();
      todo = NEW_CONF_VALUE;
    }

    use_fxd_mode = (cfg_get_value(&linex_resolution,0)==DIRECT) && (cfg_get_value(&dvmode_version,0)==1);

    if (periphal_state.si5356_locked && periphal_state.adv7513_hdmi_up) { // all ok let's setup register settings in adv and  game-idperiphals_set_ready_bit();
      if ((active_osd_pre != active_osd) || undo_changed_linex_setting) {
        undo_changed_linex_setting = FALSE;
        todo = NEW_CONF_VALUE;
      }

      if (!led_set_ok || (palmode_pre != palmode) || (scanmode_pre != scanmode) || (todo == NEW_CONF_VALUE)) {
        set_cfg_adv7513();
        if ((cfg_get_value(&linex_resolution,0)==DIRECT) && (cfg_get_value(&dvmode_version,0)==0)) send_dv1_if(ON);
        else send_spd_if(ON);
        led_set_ok = FALSE;  // this forces that green led will show up on a change of settings
      }

      if (vsif_cycle_cnt > VSIF_CYCLE_CNT_TH) {
        if (use_fxd_mode) {
          send_fxd_if(ON,ON);
        }
        else if (use_fxd_mode_pre) {
          send_fxd_if(ON,OFF);
          vsif_cycle_cnt = VSIF_CYCLE_CNT_TH; // make sure that info on fx-direct is off is being send
        }
        else {
          send_fxd_if(OFF,OFF);
        }
      } else {
        get_game_id();
        send_game_id_if(ON);
      }
      use_fxd_mode_pre = use_fxd_mode;
      vsif_cycle_cnt++;

      periphals_set_ready_bit();
      if (!led_set_ok) led_drive(LED_OK,LED_ON);
      if (get_led_timout(LED_OK) == 0) led_drive(LED_OK,LED_OFF);
      else dec_led_timeout(LED_OK);
      led_set_ok = TRUE;
    }

    if ((unlock_1440p_pre != unlock_1440p) && (unlock_1440p == TRUE)) {
      print_1440p_unlock_info();
      message_cnt = CONFIRM_SHOW_CNT_MID;
    }

    if (hdmi_clk_ok) {
      if (menu->type != N64DEBUG) { // LEDs are not under control by Debug-Screen
        if (video_input_detected & led_set_ok) {
          clear_led_timeout(LED_NOK);
          led_drive(LED_NOK,LED_OFF);
        } else {
          led_drive(LED_NOK,LED_ON);
        }
      }
    }


    if (changed_linex_setting) {  // important to check this flag in that order
                                  // as program cycles 1x through menu after change to set also the scaling correctly
      if (use_fxd_mode) send_fxd_if(ON,ON);
      if (!confirmation_routine(1)) {  // change was not ok
        print_confirm_info(CONFIRM_ABORTED-CONFIRM_OK);
        linex_words[vmode_n64adv].config_val = linex_word_pre;
        undo_changed_linex_setting = TRUE;
        message_cnt = CONFIRM_SHOW_CNT_LONG;
        if (use_fxd_mode) send_fxd_if(ON,OFF);
      } else {
        print_confirm_info(CONFIRM_OK-CONFIRM_OK);
        message_cnt = CONFIRM_SHOW_CNT_MID;
      }
      changed_linex_setting = FALSE;
    } else if (menu == &vires_screen) {
      changed_linex_setting = (linex_word_pre != linex_words[vmode_n64adv].config_val);
    }
  }

  return 0;
}
