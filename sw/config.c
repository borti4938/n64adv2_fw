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
 * config.c
 *
 *  Created on: 11.01.2018
 *      Author: Peter Bartmann
 *
 ********************************************************************************/

#include "alt_types.h"
#include "altera_avalon_pio_regs.h"
#include "system.h"
#include "app_cfg.h"
#include "cfg_io_p.h"
#include "cfg_int_p.h"
#include "n64.h"
#include "config.h"
#include "menu.h"
#include "flash.h"
#include "vd_driver.h"
#include "adv7513.h"


#define CFG2FLASH_WORD_FACTOR_U32   4
#define CFG2FLASH_WORD_FACTOR_U16   2

typedef struct {
  alt_u8  vers_cfg_main;
  alt_u8  vers_cfg_sub;
  alt_u8  cfg_internals;
  alt_u8  cfg_words[CFG2FLASH_WORD_FACTOR_U32*NUM_CFG_B32WORDS];
  alt_u8  cfg_linex_trays[CFG2FLASH_WORD_FACTOR_U32*LINEX_TYPES];
  alt_u8  cfg_timing_trays[CFG2FLASH_WORD_FACTOR_U16*NUM_TIMING_MODES];
  alt_u8  cfg_scaling_trays[CFG2FLASH_WORD_FACTOR_U16*NUM_SCALING_MODES];
} cfg4flash_t;

configuration_t sysconfig = {
  .cfg_word_def[MISC]  = &cfg_data_misc,
  .cfg_word_def[VIDEO] = &cfg_data_video,
  .cfg_word_def[LINEX] = &cfg_data_linex
};

config_tray_t linex_words[2] = {
  { .config_val = 0x00000000, .config_ref_val = 0x00000000},
  { .config_val = 0x00000000, .config_ref_val = 0x00000000}
};

config_tray_u16_t timing_words[NUM_TIMING_MODES] = {
  { .config_val = CFG_TIMING_DEFAULTS,  .config_ref_val = CFG_TIMING_DEFAULTS},
  { .config_val = CFG_TIMING_DEFAULTS,  .config_ref_val = CFG_TIMING_DEFAULTS},
  { .config_val = CFG_TIMING_DEFAULTS,  .config_ref_val = CFG_TIMING_DEFAULTS},
  { .config_val = CFG_TIMING_DEFAULTS,  .config_ref_val = CFG_TIMING_DEFAULTS}
};

config_tray_u16_t scaling_words[NUM_SCALING_MODES] = {
  { .config_val = CFG_SCALING_NTSC_480_DEFAULT ,  .config_ref_val = CFG_SCALING_NTSC_480_DEFAULT},
  { .config_val = CFG_SCALING_NTSC_720_DEFAULT ,  .config_ref_val = CFG_SCALING_NTSC_720_DEFAULT},
  { .config_val = CFG_SCALING_NTSC_960_DEFAULT ,  .config_ref_val = CFG_SCALING_NTSC_960_DEFAULT},
  { .config_val = CFG_SCALING_NTSC_1080_DEFAULT,  .config_ref_val = CFG_SCALING_NTSC_1080_DEFAULT},
  { .config_val = CFG_SCALING_NTSC_1200_DEFAULT,  .config_ref_val = CFG_SCALING_NTSC_1200_DEFAULT},
  { .config_val = CFG_SCALING_PAL_576_DEFAULT  ,  .config_ref_val = CFG_SCALING_PAL_576_DEFAULT},
  { .config_val = CFG_SCALING_PAL_720_DEFAULT  ,  .config_ref_val = CFG_SCALING_PAL_720_DEFAULT},
  { .config_val = CFG_SCALING_PAL_960_DEFAULT  ,  .config_ref_val = CFG_SCALING_PAL_960_DEFAULT},
  { .config_val = CFG_SCALING_PAL_1080_DEFAULT ,  .config_ref_val = CFG_SCALING_PAL_1080_DEFAULT},
  { .config_val = CFG_SCALING_PAL_1200_DEFAULT ,  .config_ref_val = CFG_SCALING_PAL_1200_DEFAULT}
};

static const char *confirm_message = "< Really? >";
extern const char *btn_overlay_1, *btn_overlay_2;


void cfg_toggle_flag(config_t* cfg_data) {
  if (cfg_data->cfg_type == FLAG || cfg_data->cfg_type == FLAGTXT) {
      if (is_local_cfg(cfg_data)) cfg_data->cfg_value ^= 1;
    else                        cfg_data->cfg_word->cfg_word_val ^= cfg_data->flag_masks.setflag_mask;
  }
}

void cfg_set_flag(config_t* cfg_data) {
  if (cfg_data->cfg_type == FLAG || cfg_data->cfg_type == FLAGTXT) {
    if (is_local_cfg(cfg_data)) cfg_data->cfg_value = 1;
    else                        cfg_data->cfg_word->cfg_word_val |= cfg_data->flag_masks.setflag_mask;
  }
}

void cfg_clear_flag(config_t* cfg_data) {
  if (cfg_data->cfg_type == FLAG || cfg_data->cfg_type == FLAGTXT) {
    if (is_local_cfg(cfg_data)) cfg_data->cfg_value = 0;
    else                        cfg_data->cfg_word->cfg_word_val &= cfg_data->flag_masks.clrflag_mask;
  }
}

void cfg_inc_value(config_t* cfg_data)
{
  if (cfg_data->cfg_type == FLAG || cfg_data->cfg_type == FLAGTXT) {
    cfg_toggle_flag(cfg_data);
    return;
  }
  if (is_local_cfg(cfg_data)) {
    cfg_data->cfg_value = cfg_data->cfg_value == cfg_data->value_details.max_value ? 0 : cfg_data->cfg_value + 1;
    return;
  }

  alt_u32 *cfg_word = &(cfg_data->cfg_word->cfg_word_val);
  alt_u8 cur_val = (*cfg_word & cfg_data->value_details.getvalue_mask) >> cfg_data->cfg_word_offset;

  cur_val = cur_val == cfg_data->value_details.max_value ? 0 : cur_val + 1;
  *cfg_word = (*cfg_word & ~cfg_data->value_details.getvalue_mask) | (cur_val << cfg_data->cfg_word_offset);
}

void cfg_dec_value(config_t* cfg_data)
{
  if (cfg_data->cfg_type == FLAG || cfg_data->cfg_type == FLAGTXT) {
    cfg_toggle_flag(cfg_data);
    return;
  }
  if (is_local_cfg(cfg_data)) {
    cfg_data->cfg_value = cfg_data->cfg_value == 0 ? cfg_data->value_details.max_value : cfg_data->cfg_value - 1;
    return;
  }

  alt_u32 *cfg_word = &(cfg_data->cfg_word->cfg_word_val);
  alt_u8 cur_val = (*cfg_word & cfg_data->value_details.getvalue_mask) >> cfg_data->cfg_word_offset;

  cur_val = cur_val == 0 ? cfg_data->value_details.max_value : cur_val - 1;
  *cfg_word = (*cfg_word & ~cfg_data->value_details.getvalue_mask) | (cur_val << cfg_data->cfg_word_offset);
}

alt_u8 cfg_get_value(config_t* cfg_data, alt_u8 get_reference)
{
  if (is_local_cfg(cfg_data)) return cfg_data->cfg_value;

  alt_u32 *cfg_word;
  if (!get_reference) cfg_word = &(cfg_data->cfg_word->cfg_word_val);
  else                cfg_word = &(cfg_data->cfg_word->cfg_ref_word_val);

  if (cfg_data->cfg_type == FLAG ||
      cfg_data->cfg_type == FLAGTXT) return ((*cfg_word & cfg_data->flag_masks.setflag_mask)     >> cfg_data->cfg_word_offset);
  else                               return ((*cfg_word & cfg_data->value_details.getvalue_mask) >> cfg_data->cfg_word_offset);
}

void cfg_set_value(config_t* cfg_data, alt_u8 value)
{
  if (cfg_data->cfg_type == FLAG || cfg_data->cfg_type == FLAGTXT) {
    if (value) cfg_set_flag(cfg_data);
    else       cfg_clear_flag(cfg_data);
    return;
  }
  if (is_local_cfg(cfg_data)) {
    cfg_data->cfg_value = value;
    return;
  }

  alt_u32 *cfg_word = &(cfg_data->cfg_word->cfg_word_val);
  alt_u32 cur_val = value > cfg_data->value_details.max_value ? 0 : value;

  *cfg_word = (*cfg_word & ~cfg_data->value_details.getvalue_mask) | (cur_val << cfg_data->cfg_word_offset);
}

alt_u8 confirmation_routine(alt_u8 with_btn_overlay)
{
  cmd_t command;
  alt_u8 abort = 0;

  vd_print_string(VD_TEXT,RWM_H_OFFSET,RWM_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_NAVAJOWHITE,confirm_message);
  if (with_btn_overlay > 0) vd_print_string(VD_TEXT,BTN_OVERLAY_H_OFFSET,BTN_OVERLAY_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_GREEN,btn_overlay_2);

  while(1) {
    while(!get_osdvsync()){};                         // wait for OSD_VSYNC goes high
    while( get_osdvsync() && new_ctrl_available()){}; // wait for OSD_VSYNC goes low and
                                                      // wait for new controller available
    update_ctrl_data();
    command = ctrl_data_to_cmd(1);

    if ((command == CMD_MENU_ENTER) || (command == CMD_MENU_RIGHT)) break;
    if ((command == CMD_MENU_BACK)  || (command == CMD_MENU_LEFT))  {abort = 1; break;};
  }
  if (with_btn_overlay > 0) {
    vd_clear_lineend(VD_TEXT,BTN_OVERLAY_H_OFFSET,BTN_OVERLAY_V_OFFSET);
    vd_clear_lineend(VD_TEXT,BTN_OVERLAY_H_OFFSET,BTN_OVERLAY_V_OFFSET+1);
    vd_print_string(VD_TEXT,BTN_OVERLAY_H_OFFSET,BTN_OVERLAY_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_GREEN,btn_overlay_1);
  }
  return abort;
}

int cfg_save_to_flash(alt_u8 need_confirm)
{
  if (!use_flash) return -CFG_FLASH_NOT_USED;

  if (need_confirm) {
    alt_u8 abort = confirmation_routine(1);
    if (abort) return -CFG_FLASH_SAVE_ABORT;
  }

  alt_u8 databuf[PAGESIZE];
  int idx, jdx;

  ((cfg4flash_t*) databuf)->vers_cfg_main = CFG_FW_MAIN;
  ((cfg4flash_t*) databuf)->vers_cfg_sub = CFG_FW_SUB;

  ((cfg4flash_t*) databuf)->cfg_internals = (alt_u8) (cfg_data_internal.cfg_word_val & 0x0F);

  for (idx = 0; idx < NUM_CFG_B32WORDS; idx++)
    for (jdx = 0; jdx < CFG2FLASH_WORD_FACTOR_U32; jdx++)
      ((cfg4flash_t*) databuf)->cfg_words[CFG2FLASH_WORD_FACTOR_U32*idx+jdx] = (alt_u8) ((sysconfig.cfg_word_def[idx]->cfg_word_val >> (8*jdx)) & 0xFF);

  for (jdx = 0; jdx < CFG2FLASH_WORD_FACTOR_U32; jdx++) {
    ((cfg4flash_t*) databuf)->cfg_linex_trays[                          jdx] = (alt_u8) ((linex_words[NTSC].config_val >> (8*jdx)) & 0xFF); // global/ntsc
    ((cfg4flash_t*) databuf)->cfg_linex_trays[CFG2FLASH_WORD_FACTOR_U32+jdx] = (alt_u8) ((linex_words[PAL].config_val  >> (8*jdx)) & 0xFF); // pal
  }

  for (idx = 0; idx < NUM_TIMING_MODES; idx++)
    for (jdx = 0; jdx < CFG2FLASH_WORD_FACTOR_U16; jdx++)
      ((cfg4flash_t*) databuf)->cfg_timing_trays[CFG2FLASH_WORD_FACTOR_U16*idx+jdx] = (alt_u8) ((timing_words[idx].config_val >> (8*jdx)) & 0xFF);

  for (idx = 0; idx < NUM_SCALING_MODES; idx++)
    for (jdx = 0; jdx < CFG2FLASH_WORD_FACTOR_U16; jdx++)
      ((cfg4flash_t*) databuf)->cfg_scaling_trays[CFG2FLASH_WORD_FACTOR_U16*idx+jdx] = (alt_u8) ((scaling_words[idx].config_val >> (8*jdx)) & 0xFF);

  int retval = write_flash_page((alt_u8*) databuf, sizeof(cfg4flash_t), USERDATA_OFFSET/PAGESIZE);

  if (retval == 0)
    cfg_update_reference(); // leave power cycle values for deblur and 16bit mode in reference

  return retval;
}

int cfg_load_from_flash(alt_u8 need_confirm)
{
  if (!use_flash) return -CFG_FLASH_NOT_USED;

  if (need_confirm) {
    alt_u8 abort = confirmation_routine(1);
    if (abort) return -CFG_FLASH_LOAD_ABORT;
  }

  alt_u8 databuf[PAGESIZE];
  int idx, jdx, retval;

  retval = read_flash(USERDATA_OFFSET, PAGESIZE, databuf);

  if (retval != 0) return retval;

  // backup logic values for deblur and 16bit mode
  // they will be overwritten which is not intended
  cfg_offon_t deblur_bak = (cfg_offon_t) cfg_get_value(&deblur_mode,0);
  cfg_offon_t mode16bit_bak = (cfg_offon_t) cfg_get_value(&mode16bit,0);

  if ((((cfg4flash_t*) databuf)->vers_cfg_main != CFG_FW_MAIN) ||
      (((cfg4flash_t*) databuf)->vers_cfg_sub  != CFG_FW_SUB)   ) return -CFG_VERSION_INVALID;

  cfg_data_internal.cfg_word_val = 0;
  cfg_data_internal.cfg_word_val |= ((cfg4flash_t*) databuf)->cfg_internals;

  for (idx = 0; idx < NUM_CFG_B32WORDS; idx++) {
    sysconfig.cfg_word_def[idx]->cfg_word_val = 0;
    for (jdx = 0; jdx < CFG2FLASH_WORD_FACTOR_U32; jdx++)
      sysconfig.cfg_word_def[idx]->cfg_word_val |= (((cfg4flash_t*) databuf)->cfg_words[CFG2FLASH_WORD_FACTOR_U32*idx + jdx] << (8*jdx));
  }

  linex_words[NTSC].config_val = 0;
  linex_words[PAL].config_val = 0;
  for (jdx = 0; jdx < CFG2FLASH_WORD_FACTOR_U32; jdx++) {
    linex_words[NTSC].config_val |= (((cfg4flash_t*) databuf)->cfg_linex_trays[                          jdx]  << (8*jdx)); // global/ntsc
    linex_words[PAL].config_val  |= (((cfg4flash_t*) databuf)->cfg_linex_trays[CFG2FLASH_WORD_FACTOR_U32+jdx]  << (8*jdx)); // pal
  }

  for (idx = 0; idx < NUM_TIMING_MODES; idx++) {
    timing_words[idx].config_val = 0;
    for (jdx = 0; jdx < CFG2FLASH_WORD_FACTOR_U16; jdx++)
      timing_words[idx].config_val |= (((cfg4flash_t*) databuf)->cfg_timing_trays[CFG2FLASH_WORD_FACTOR_U16*idx+jdx]  << (8*jdx));
  }

  for (idx = 0; idx < NUM_SCALING_MODES; idx++) {
      scaling_words[idx].config_val = 0;
    for (jdx = 0; jdx < CFG2FLASH_WORD_FACTOR_U16; jdx++)
      scaling_words[idx].config_val |= (((cfg4flash_t*) databuf)->cfg_scaling_trays[CFG2FLASH_WORD_FACTOR_U16*idx+jdx]  << (8*jdx));
  }

  cfg_update_reference(); // leave power cycle values for deblur and 16bit mode in reference

  // store powercycle values for deblur and 16bit mode
  // reset logic values
  cfg_set_value(&deblur_mode_powercycle,cfg_get_value(&deblur_mode,0));
  cfg_set_value(&deblur_mode,(alt_u8) deblur_bak);
  cfg_set_value(&mode16bit_powercycle,cfg_get_value(&mode16bit,0));
  cfg_set_value(&mode16bit,(alt_u8) mode16bit_bak);

  return retval;
}

int cfg_reset_timing()
{
  alt_u8 abort = confirmation_routine(0);
  if (abort) return -CFG_DEF_LOAD_ABORT;

  alt_u8 timing_word_select = timing_selection.cfg_value;
  if (timing_word_select == PPU_TIMING_CURRENT || timing_word_select > NUM_TIMING_MODES) return -1;
  timing_words[timing_word_select-1].config_val = CFG_TIMING_DEFAULTS;
  cfg_load_timing_word(timing_word_select);
  return 0;
}

int cfg_load_defaults(alt_u8 video480p, alt_u8 need_confirm)
{
  if (need_confirm) {
    alt_u8 abort = confirmation_routine(1);
    if (abort) return -CFG_DEF_LOAD_ABORT;
  }

  sysconfig.cfg_word_def[MISC]->cfg_word_val &= CFG_MISC_GET_NODEFAULTS;
  sysconfig.cfg_word_def[VIDEO]->cfg_word_val &= CFG_VIDEO_GET_NODEFAULTS;
  sysconfig.cfg_word_def[LINEX]->cfg_word_val &= CFG_LINEX_GET_NODEFAULTS;

  sysconfig.cfg_word_def[MISC]->cfg_word_val |= CFG_MISC_DEFAULT;
  sysconfig.cfg_word_def[VIDEO]->cfg_word_val |= CFG_VIDEO_DEFAULT;
  sysconfig.cfg_word_def[LINEX]->cfg_word_val |= CFG_LINEX_DEFAULT;

  cfg_store_linex_word(NTSC);
  cfg_store_linex_word(PAL);

  return 0;
}

void cfg_store_linex_word(vmode_t palmode_select) {
  linex_words[palmode_select].config_val = sysconfig.cfg_word_def[LINEX]->cfg_word_val;
  linex_words[palmode_select].config_ref_val = sysconfig.cfg_word_def[LINEX]->cfg_ref_word_val;
}

void cfg_load_linex_word(vmode_t palmode_select) {
  sysconfig.cfg_word_def[LINEX]->cfg_word_val = linex_words[palmode_select].config_val;
  sysconfig.cfg_word_def[LINEX]->cfg_ref_word_val = linex_words[palmode_select].config_ref_val;
}

void cfg_store_timing_word(cfg_timing_model_sel_type_t timing_word_select) {
  if (timing_word_select == PPU_TIMING_CURRENT || timing_word_select > NUM_TIMING_MODES) return;
  timing_word_select--;
  timing_words[timing_word_select].config_val = ((sysconfig.cfg_word_def[VIDEO]->cfg_word_val & CFG_VIDEO_GETTIMINGS_MASK) >> CFG_VERTSHIFT_OFFSET);
  timing_words[timing_word_select].config_ref_val = ((sysconfig.cfg_word_def[VIDEO]->cfg_ref_word_val & CFG_VIDEO_GETTIMINGS_MASK) >> CFG_VERTSHIFT_OFFSET);
}

void cfg_load_timing_word(cfg_timing_model_sel_type_t timing_word_select) {
  if (timing_word_select == PPU_TIMING_CURRENT || timing_word_select > NUM_TIMING_MODES) return;
  timing_word_select--;

  alt_u32 loading_tray;
  loading_tray = timing_words[timing_word_select].config_val;
  sysconfig.cfg_word_def[VIDEO]->cfg_word_val &= CFG_VIDEO_GETNONTIMINGS_MASK;
  sysconfig.cfg_word_def[VIDEO]->cfg_word_val |= ((loading_tray << CFG_VERTSHIFT_OFFSET) & CFG_VIDEO_GETTIMINGS_MASK);

  loading_tray = timing_words[timing_word_select].config_ref_val;
  sysconfig.cfg_word_def[VIDEO]->cfg_ref_word_val &= CFG_VIDEO_GETNONTIMINGS_MASK;
  sysconfig.cfg_word_def[VIDEO]->cfg_ref_word_val |= ((loading_tray << CFG_VERTSHIFT_OFFSET) & CFG_VIDEO_GETTIMINGS_MASK);
}

void cfg_store_scaling_word(cfg_scaler_in2out_sel_type_t scaling_word_select) {
  if (scaling_word_select == PPU_SCALING_CURRENT || scaling_word_select > NUM_SCALING_MODES) return;
  scaling_word_select--;
  scaling_words[scaling_word_select].config_val = ((sysconfig.cfg_word_def[VIDEO]->cfg_word_val & CFG_VIDEO_GETSCALING_MASK) >> CFG_VERTSCALE_OFFSET);
  scaling_words[scaling_word_select].config_ref_val = ((sysconfig.cfg_word_def[VIDEO]->cfg_ref_word_val & CFG_VIDEO_GETSCALING_MASK) >> CFG_VERTSCALE_OFFSET);
}

void cfg_load_scaling_word(cfg_scaler_in2out_sel_type_t scaling_word_select) {
  if (scaling_word_select == PPU_SCALING_CURRENT || scaling_word_select > NUM_SCALING_MODES) return;
  scaling_word_select--;

  alt_u32 loading_tray;
  loading_tray = scaling_words[scaling_word_select].config_val;
  sysconfig.cfg_word_def[VIDEO]->cfg_word_val &= CFG_VIDEO_GETNONSCALING_MASK;
  sysconfig.cfg_word_def[VIDEO]->cfg_word_val |= ((loading_tray << CFG_VERTSCALE_OFFSET) & CFG_VIDEO_GETSCALING_MASK);

  loading_tray = scaling_words[scaling_word_select].config_ref_val;
  sysconfig.cfg_word_def[VIDEO]->cfg_ref_word_val &= CFG_VIDEO_GETNONSCALING_MASK;
  sysconfig.cfg_word_def[VIDEO]->cfg_ref_word_val |= ((loading_tray << CFG_VERTSCALE_OFFSET) & CFG_VIDEO_GETSCALING_MASK);
}

void cfg_apply_to_logic()
{
  IOWR_ALTERA_AVALON_PIO_DATA(CFG_MISC_OUT_BASE,sysconfig.cfg_word_def[MISC]->cfg_word_val);
  IOWR_ALTERA_AVALON_PIO_DATA(CFG_VIDEO_OUT_BASE,sysconfig.cfg_word_def[VIDEO]->cfg_word_val);
  IOWR_ALTERA_AVALON_PIO_DATA(CFG_LINEX_OUT_BASE,sysconfig.cfg_word_def[LINEX]->cfg_word_val);
}

void cfg_read_from_logic()
{
  sysconfig.cfg_word_def[MISC]->cfg_word_val  = (IORD_ALTERA_AVALON_PIO_DATA(CFG_MISC_OUT_BASE)  & sysconfig.cfg_word_def[MISC]->cfg_word_mask);
  sysconfig.cfg_word_def[VIDEO]->cfg_word_val = (IORD_ALTERA_AVALON_PIO_DATA(CFG_VIDEO_OUT_BASE) & sysconfig.cfg_word_def[VIDEO]->cfg_word_mask);
  sysconfig.cfg_word_def[LINEX]->cfg_word_val = (IORD_ALTERA_AVALON_PIO_DATA(CFG_LINEX_OUT_BASE) & sysconfig.cfg_word_def[LINEX]->cfg_word_mask);
}

void cfg_clear_words()
{
  int idx;
  for (idx = 0; idx < NUM_CFG_B32WORDS; idx++)
    sysconfig.cfg_word_def[idx]->cfg_word_val = 0;
}

void cfg_update_reference()
{
  cfg_data_internal.cfg_ref_word_val = cfg_data_internal.cfg_word_val;

  int idx;
  for (idx = 0; idx < NUM_CFG_B32WORDS; idx++)
    sysconfig.cfg_word_def[idx]->cfg_ref_word_val = sysconfig.cfg_word_def[idx]->cfg_word_val;

  linex_words[NTSC].config_ref_val = linex_words[NTSC].config_val;
  linex_words[PAL].config_ref_val  = linex_words[PAL].config_val;
  for (idx = 0; idx < NUM_TIMING_MODES; idx++) timing_words[idx].config_ref_val = timing_words[idx].config_val;
  for (idx = 0; idx < NUM_SCALING_MODES; idx++) scaling_words[idx].config_ref_val = scaling_words[idx].config_val;
}
