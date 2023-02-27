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

//#define CONFIRM_BNT_FCT_H_OFFSET  26
#define CONFIRM_BNT_FCT_H_OFFSET  RWM_H_OFFSET
#define CONFIRM_BNT_FCT_V_OFFSET  (VD_TXT_HEIGHT - 1)

typedef struct {
  alt_u8  vers_cfg_main;
  alt_u8  vers_cfg_sub;
  alt_u8  cfg_words[CFG2FLASH_WORD_FACTOR_U32*NUM_CFG_B32WORDS];
  alt_u8  cfg_linex_trays[LINEX_TYPES];
  alt_u8  cfg_linex_scanlines_trays[CFG2FLASH_WORD_FACTOR_U32*LINEX_TYPES];
  alt_u8  cfg_timing_trays[CFG2FLASH_WORD_FACTOR_U16*NUM_TIMING_MODES];
  alt_u8  cfg_scaling_trays[CFG2FLASH_WORD_FACTOR_U32*NUM_SCALING_MODES];
} cfg4flash_t;

configuration_t sysconfig = {
  .cfg_word_def[INTCFG0] = &intcfg0_word,
  .cfg_word_def[EXTCFG0] = &extcfg0_word,
  .cfg_word_def[EXTCFG1] = &extcfg1_word,
  .cfg_word_def[EXTCFG2] = &extcfg2_word,
  .cfg_word_def[EXTCFG3] = &extcfg3_word
};

config_tray_u8_t linex_words[2] = {
  { .config_val = 0x00, .config_ref_val = 0x00},
  { .config_val = 0x00, .config_ref_val = 0x00}
};

config_tray_t linex_scanlines_words[NUM_REGION_MODES] = {
  { .config_val = 0x00000000, .config_ref_val = 0x00000000},
  { .config_val = 0x00000000, .config_ref_val = 0x00000000}
};

config_tray_u16_t timing_words[NUM_TIMING_MODES] = {
  { .config_val = CFG_TIMING_DEFAULTS,  .config_ref_val = CFG_TIMING_DEFAULTS},
  { .config_val = CFG_TIMING_DEFAULTS,  .config_ref_val = CFG_TIMING_DEFAULTS},
  { .config_val = CFG_TIMING_DEFAULTS,  .config_ref_val = CFG_TIMING_DEFAULTS},
  { .config_val = CFG_TIMING_DEFAULTS,  .config_ref_val = CFG_TIMING_DEFAULTS}
};

const alt_u32 scaling_defaults[NUM_SCALING_MODES] __ufmdata_section__ =
    {(alt_u32) CFG_SCALING_NTSC_240_DEFAULT_SHIFTED ,(alt_u32) CFG_SCALING_NTSC_480_DEFAULT_SHIFTED  ,
     (alt_u32) CFG_SCALING_NTSC_720_DEFAULT_SHIFTED ,(alt_u32) CFG_SCALING_NTSC_960_DEFAULT_SHIFTED  ,
     (alt_u32) CFG_SCALING_NTSC_1080_DEFAULT_SHIFTED,(alt_u32) CFG_SCALING_NTSC_1200_DEFAULT_SHIFTED ,
     (alt_u32) CFG_SCALING_NTSC_1440_DEFAULT_SHIFTED,(alt_u32) CFG_SCALING_NTSC_1440_DEFAULT_SHIFTED,
     (alt_u32) CFG_SCALING_PAL_288_DEFAULT_SHIFTED  ,(alt_u32) CFG_SCALING_PAL_576_DEFAULT_SHIFTED   ,
     (alt_u32) CFG_SCALING_PAL_720_DEFAULT_SHIFTED  ,(alt_u32) CFG_SCALING_PAL_960_DEFAULT_SHIFTED   ,
     (alt_u32) CFG_SCALING_PAL_1080_DEFAULT_SHIFTED ,(alt_u32) CFG_SCALING_PAL_1200_DEFAULT_SHIFTED  ,
     (alt_u32) CFG_SCALING_PAL_1440_DEFAULT_SHIFTED ,(alt_u32) CFG_SCALING_PAL_1440_DEFAULT_SHIFTED };

config_tray_t scaling_words[NUM_SCALING_MODES] = {
    { .config_val = CFG_SCALING_NTSC_240_DEFAULT_SHIFTED ,  .config_ref_val = CFG_SCALING_NTSC_240_DEFAULT_SHIFTED},
    { .config_val = CFG_SCALING_NTSC_480_DEFAULT_SHIFTED ,  .config_ref_val = CFG_SCALING_NTSC_480_DEFAULT_SHIFTED},
    { .config_val = CFG_SCALING_NTSC_720_DEFAULT_SHIFTED ,  .config_ref_val = CFG_SCALING_NTSC_720_DEFAULT_SHIFTED},
    { .config_val = CFG_SCALING_NTSC_960_DEFAULT_SHIFTED ,  .config_ref_val = CFG_SCALING_NTSC_960_DEFAULT_SHIFTED},
    { .config_val = CFG_SCALING_NTSC_1080_DEFAULT_SHIFTED,  .config_ref_val = CFG_SCALING_NTSC_1080_DEFAULT_SHIFTED},
    { .config_val = CFG_SCALING_NTSC_1200_DEFAULT_SHIFTED,  .config_ref_val = CFG_SCALING_NTSC_1200_DEFAULT_SHIFTED},
    { .config_val = CFG_SCALING_NTSC_1440_DEFAULT_SHIFTED,  .config_ref_val = CFG_SCALING_NTSC_1440_DEFAULT_SHIFTED},
    { .config_val = CFG_SCALING_NTSC_1440_DEFAULT_SHIFTED,  .config_ref_val = CFG_SCALING_NTSC_1440_DEFAULT_SHIFTED},
    { .config_val = CFG_SCALING_PAL_288_DEFAULT_SHIFTED  ,  .config_ref_val = CFG_SCALING_PAL_288_DEFAULT_SHIFTED},
    { .config_val = CFG_SCALING_PAL_576_DEFAULT_SHIFTED  ,  .config_ref_val = CFG_SCALING_PAL_576_DEFAULT_SHIFTED},
    { .config_val = CFG_SCALING_PAL_720_DEFAULT_SHIFTED  ,  .config_ref_val = CFG_SCALING_PAL_720_DEFAULT_SHIFTED},
    { .config_val = CFG_SCALING_PAL_960_DEFAULT_SHIFTED  ,  .config_ref_val = CFG_SCALING_PAL_960_DEFAULT_SHIFTED},
    { .config_val = CFG_SCALING_PAL_1080_DEFAULT_SHIFTED ,  .config_ref_val = CFG_SCALING_PAL_1080_DEFAULT_SHIFTED},
    { .config_val = CFG_SCALING_PAL_1200_DEFAULT_SHIFTED ,  .config_ref_val = CFG_SCALING_PAL_1200_DEFAULT_SHIFTED},
    { .config_val = CFG_SCALING_PAL_1440_DEFAULT_SHIFTED ,  .config_ref_val = CFG_SCALING_PAL_1440_DEFAULT_SHIFTED},
    { .config_val = CFG_SCALING_PAL_1440_DEFAULT_SHIFTED ,  .config_ref_val = CFG_SCALING_PAL_1440_DEFAULT_SHIFTED}
};

const alt_u16 predef_scaling_vals[LINEX_TYPES+1][PREDEFINED_SCALE_STEPS] __ufmdata_section__ = {
  { 480, 540, 600, 660, 720, 780, 840, 900, 960,1020,1080,1140,1200,1260,1320,1380,1440,1500,1560,1620,1680}, // vertical NTSC
  { 576, 648, 720, 792, 864, 936,1008,1080,1152,1224,1296,1368,1440,1512,1584,1656,1728,1800,1872,1944,2016}, // vertical PAL
  { 640, 720, 800, 880, 960,1040,1120,1200,1280,1360,1440,1520,1600,1680,1760,1840,1920,2000,2080,2160,2240}  // horizontal
};

//extern bool_t use_flash;
extern cfg_scaler_in2out_sel_type_t scaling_menu, scaling_n64adv;
extern vmode_t vmode_scaling_menu;

static const char *confirm_message = "< Really? >";
extern const char *btn_fct_confirm_overlay;

bool_t unlock_1440p;


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
  alt_u16 cur_val = (*cfg_word & cfg_data->value_details.getvalue_mask) >> cfg_data->cfg_word_offset;

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
  alt_u16 cur_val = (*cfg_word & cfg_data->value_details.getvalue_mask) >> cfg_data->cfg_word_offset;

  cur_val = cur_val == 0 ? cfg_data->value_details.max_value : cur_val - 1;
  *cfg_word = (*cfg_word & ~cfg_data->value_details.getvalue_mask) | (cur_val << cfg_data->cfg_word_offset);
}

alt_u16 cfg_get_value(config_t* cfg_data, cfg_offon_t get_reference)
{
  if (is_local_cfg(cfg_data)) return (alt_u16) cfg_data->cfg_value;

  alt_u32 *cfg_word;
  if (!get_reference) cfg_word = &(cfg_data->cfg_word->cfg_word_val);
  else                cfg_word = &(cfg_data->cfg_word->cfg_ref_word_val);

  if (cfg_data->cfg_type == FLAG ||
      cfg_data->cfg_type == FLAGTXT) return ((*cfg_word & cfg_data->flag_masks.setflag_mask)     >> cfg_data->cfg_word_offset);
  else                               return ((*cfg_word & cfg_data->value_details.getvalue_mask) >> cfg_data->cfg_word_offset);
}

void cfg_set_value(config_t* cfg_data, alt_u16 value)
{
  if (cfg_data->cfg_type == FLAG || cfg_data->cfg_type == FLAGTXT) {
    if (value) cfg_set_flag(cfg_data);
    else       cfg_clear_flag(cfg_data);
    return;
  }
  if (is_local_cfg(cfg_data)) {
    cfg_data->cfg_value = (alt_u8) (value & 0x00FF);
    return;
  }

  alt_u32 *cfg_word = &(cfg_data->cfg_word->cfg_word_val);
  alt_u32 cur_val = value > cfg_data->value_details.max_value ? 0 : value;

  *cfg_word = (*cfg_word & ~cfg_data->value_details.getvalue_mask) | (cur_val << cfg_data->cfg_word_offset);
}

alt_u16 cfgfct_linex(alt_u16 value, bool_t set_value, bool_t ret_reference)
{
  if (set_value) cfg_set_value(&linex_resolution,value);
  return cfg_get_value(&linex_resolution,ret_reference);
}

alt_u16 cfgfct_unlock1440p(alt_u16 value, bool_t set_value, bool_t get_reference)
{
  if (set_value) unlock_1440p = TRUE;
  return (alt_u16) unlock_1440p;
};

alt_u8 cfg_scale_is_predefined(alt_u16 value, bool_t use_vertical) {
  alt_u8 jdx = use_vertical ? vmode_scaling_menu : 2;
  alt_u8 idx;
  for (idx = 0; idx < PREDEFINED_SCALE_STEPS; idx++) {
    if (predef_scaling_vals[jdx][idx] == value) return idx;
  }
  return PREDEFINED_SCALE_STEPS;
}

void cfg_scale_v2h_update() {
  if (cfg_get_value(&linex_resolution,0) == PASSTHROUGH) return;
  alt_u8 hv_scale_link = cfg_get_value(&link_hv_scale,0);
  alt_u32 hscale = cfg_get_value(&vert_scale,0);
  switch (hv_scale_link) {
    case 0: // 4:3
      hscale = 4*hscale/3;
      break;
    case 1: // CRT (160:119)
      hscale = 160*hscale/119;
      break;
    case 2: // 16:9
      hscale = 16*hscale/9;
      break;
    default:
      return;
  }
  cfg_set_value(&hor_scale,hscale);
}

alt_u16 cfgfct_scale(alt_u16 command, bool_t use_vertical, bool_t set_value, bool_t ret_reference)
{
  alt_u16 current_scale = use_vertical ? cfg_get_value(&vert_scale,0) :  cfg_get_value(&hor_scale,0);
  if (set_value) {  // ensure from outside that command is valid (left or right)
    alt_u8 jdx = use_vertical ? vmode_scaling_menu : 2;
    alt_u8 idx, idx_min;
    bool_t use_240p_288p = ((scaling_menu == NTSC_TO_240) || (scaling_menu == PAL_TO_288));
    bool_t use_1440Wp = ((scaling_menu == NTSC_TO_1440W) || (scaling_menu == PAL_TO_1440W));
    alt_u16 scale_max, scale_min;
    alt_u8 scale_inc = 1;
    if (use_240p_288p) {
      if (use_vertical) {
        scale_max = 2*CFG_VERTSCALE_PAL_MIN;
        scale_min = ((vmode_scaling_menu == PAL) && !((bool_t) cfg_get_value(&pal_boxed_mode,0))) ? (CFG_VERTSCALE_PAL_MIN & 0xFFFE) : (CFG_VERTSCALE_NTSC_MIN & 0xFFFE);
      } else {
        scale_max = 2*predef_scaling_vals[2][0];
        scale_min = predef_scaling_vals[2][0];
      }
    } else {
      scale_max = use_vertical ? CFG_VERTSCALE_MAX_VALUE : CFG_HORSCALE_MAX_VALUE;
      scale_min = use_1440Wp ? 2*predef_scaling_vals[jdx][0] : predef_scaling_vals[jdx][0];
      scale_inc = use_1440Wp ? 2 : 1;
    }
    bool_t scale_pixelwise = cfg_get_value(&scaling_steps,0) > 0 || (use_240p_288p && use_vertical);
    idx_min = 0;
    for (idx = 0; idx < PREDEFINED_SCALE_STEPS; idx++) {
      if (predef_scaling_vals[jdx][idx] < scale_min) idx_min = idx+1;
      if (predef_scaling_vals[jdx][idx] >= current_scale) break;
    }
    if (((cmd_t) command) == CMD_MENU_RIGHT) {  // increment
      if (scale_pixelwise) {  // pixelwise
        current_scale = current_scale <= scale_max - scale_inc ? current_scale + scale_inc : scale_min;
      } else {  // by 0.25x steps
        if (predef_scaling_vals[jdx][idx] > current_scale) idx--;
        if (idx >= PREDEFINED_SCALE_STEPS-1) current_scale = scale_min;
        else current_scale = predef_scaling_vals[jdx][idx+1];
        if (current_scale > scale_max) current_scale = scale_min;
      }
    } else {  // decrement
      if (scale_pixelwise) {  // pixelwise
        current_scale = current_scale >= scale_min + scale_inc ? current_scale - scale_inc : scale_max;
      } else {  // by 0.25x steps
        if (idx == idx_min) current_scale = predef_scaling_vals[jdx][PREDEFINED_SCALE_STEPS-1];
        else current_scale = predef_scaling_vals[jdx][idx-1];
        if (current_scale > scale_max) current_scale = scale_max;
      }
    }
    if (use_vertical) cfg_set_value(&vert_scale,current_scale);
    else cfg_set_value(&hor_scale,current_scale);
  }
  current_scale = use_vertical ? cfg_get_value(&vert_scale,ret_reference) :  cfg_get_value(&hor_scale,ret_reference);
  return current_scale;
}

bool_t confirmation_routine()
{
  cmd_t command;
  alt_u8 abort = 0;

  vd_print_string(VD_TEXT,RWM_H_OFFSET,RWM_V_OFFSET,FONTCOLOR_NAVAJOWHITE,confirm_message);
  vd_print_string(VD_TEXT,CONFIRM_BNT_FCT_H_OFFSET,CONFIRM_BNT_FCT_V_OFFSET,FONTCOLOR_GREEN,btn_fct_confirm_overlay);

  while(1) {
    while(!get_vsync_cpu()){};                         // wait for OSD_VSYNC goes high
    while( get_vsync_cpu() && new_ctrl_available()){}; // wait for OSD_VSYNC goes low and
                                                      // wait for new controller available
    update_ctrl_data();
    command = ctrl_data_to_cmd(1);

    if ((command == CMD_MENU_ENTER) || (command == CMD_MENU_RIGHT)) break;
    if ((command == CMD_MENU_BACK)  || (command == CMD_MENU_LEFT))  {abort = 1; break;};
  }
  vd_clear_lineend(VD_TEXT,RWM_H_OFFSET,RWM_V_OFFSET);
  vd_clear_lineend(VD_TEXT,CONFIRM_BNT_FCT_H_OFFSET,CONFIRM_BNT_FCT_V_OFFSET);
  return abort;
}

int cfg_save_to_flash(bool_t need_confirm)
{
//  if (!use_flash) return -CFG_FLASH_NOT_USED;

  if (need_confirm) {
    bool_t abort = confirmation_routine();
    if (abort) return -CFG_FLASH_SAVE_ABORT;
  }

  alt_u8 databuf[PAGESIZE];
  int idx, jdx;

  ((cfg4flash_t*) databuf)->vers_cfg_main = CFG_FW_MAIN;
  ((cfg4flash_t*) databuf)->vers_cfg_sub = CFG_FW_SUB;

  for (idx = 0; idx < NUM_CFG_B32WORDS; idx++)
    for (jdx = 0; jdx < CFG2FLASH_WORD_FACTOR_U32; jdx++)
      ((cfg4flash_t*) databuf)->cfg_words[CFG2FLASH_WORD_FACTOR_U32*idx+jdx] = (alt_u8) ((sysconfig.cfg_word_def[idx]->cfg_word_val >> (8*jdx)) & 0xFF);

  ((cfg4flash_t*) databuf)->cfg_linex_trays[NTSC] = linex_words[NTSC].config_val; // global/ntsc
  ((cfg4flash_t*) databuf)->cfg_linex_trays[PAL] = linex_words[PAL].config_val; // pal

  for (jdx = 0; jdx < CFG2FLASH_WORD_FACTOR_U32; jdx++) {
    ((cfg4flash_t*) databuf)->cfg_linex_scanlines_trays[                          jdx] = (alt_u8) ((linex_scanlines_words[NTSC].config_val >> (8*jdx)) & 0xFF); // global/ntsc
    ((cfg4flash_t*) databuf)->cfg_linex_scanlines_trays[CFG2FLASH_WORD_FACTOR_U32+jdx] = (alt_u8) ((linex_scanlines_words[PAL].config_val  >> (8*jdx)) & 0xFF); // pal
  }

  for (idx = 0; idx < NUM_TIMING_MODES; idx++)
    for (jdx = 0; jdx < CFG2FLASH_WORD_FACTOR_U16; jdx++)
      ((cfg4flash_t*) databuf)->cfg_timing_trays[CFG2FLASH_WORD_FACTOR_U16*idx+jdx] = (alt_u8) ((timing_words[idx].config_val >> (8*jdx)) & 0xFF);

  for (idx = 0; idx < NUM_SCALING_MODES; idx++)
    for (jdx = 0; jdx < CFG2FLASH_WORD_FACTOR_U32; jdx++)
      ((cfg4flash_t*) databuf)->cfg_scaling_trays[CFG2FLASH_WORD_FACTOR_U32*idx+jdx] = (alt_u8) ((scaling_words[idx].config_val >> (8*jdx)) & 0xFF);

  int retval = write_flash_page((alt_u8*) databuf, sizeof(cfg4flash_t), USERDATA_OFFSET/PAGESIZE);

  if (retval == 0)
    cfg_update_reference(); // leave power cycle values for deblur and 16bit mode in reference

  return retval;
}

int cfg_load_from_flash(bool_t need_confirm)
{
//  if (!use_flash) return -CFG_FLASH_NOT_USED;

  if (need_confirm) {
    bool_t abort = confirmation_routine();
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

  for (idx = 0; idx < NUM_CFG_B32WORDS; idx++) {
    sysconfig.cfg_word_def[idx]->cfg_word_val = 0;
    for (jdx = 0; jdx < CFG2FLASH_WORD_FACTOR_U32; jdx++)
      sysconfig.cfg_word_def[idx]->cfg_word_val |= (((cfg4flash_t*) databuf)->cfg_words[CFG2FLASH_WORD_FACTOR_U32*idx + jdx] << (8*jdx));
  }

  linex_words[NTSC].config_val = 0;
  linex_words[PAL].config_val = 0;
  linex_words[NTSC].config_val |= ((cfg4flash_t*) databuf)->cfg_linex_trays[NTSC];
  linex_words[PAL].config_val  |= ((cfg4flash_t*) databuf)->cfg_linex_trays[PAL];

  linex_scanlines_words[NTSC].config_val = 0;
  linex_scanlines_words[PAL].config_val = 0;
  for (jdx = 0; jdx < CFG2FLASH_WORD_FACTOR_U32; jdx++) {
    linex_scanlines_words[NTSC].config_val |= (((cfg4flash_t*) databuf)->cfg_linex_scanlines_trays[                          jdx]  << (8*jdx)); // global/ntsc
    linex_scanlines_words[PAL].config_val  |= (((cfg4flash_t*) databuf)->cfg_linex_scanlines_trays[CFG2FLASH_WORD_FACTOR_U32+jdx]  << (8*jdx)); // pal
  }

  for (idx = 0; idx < NUM_TIMING_MODES; idx++) {
    timing_words[idx].config_val = 0;
    for (jdx = 0; jdx < CFG2FLASH_WORD_FACTOR_U16; jdx++)
      timing_words[idx].config_val |= (((cfg4flash_t*) databuf)->cfg_timing_trays[CFG2FLASH_WORD_FACTOR_U16*idx+jdx]  << (8*jdx));
  }

  for (idx = 0; idx < NUM_SCALING_MODES; idx++) {
      scaling_words[idx].config_val = 0;
    for (jdx = 0; jdx < CFG2FLASH_WORD_FACTOR_U32; jdx++)
      scaling_words[idx].config_val |= (((cfg4flash_t*) databuf)->cfg_scaling_trays[CFG2FLASH_WORD_FACTOR_U32*idx+jdx]  << (8*jdx));
  }

  cfg_update_reference(); // leave power cycle values for deblur and 16bit mode in reference

  // store powercycle values for deblur and 16bit mode
  // reset logic values
  cfg_set_value(&deblur_mode_powercycle,cfg_get_value(&deblur_mode,0));
  cfg_set_value(&deblur_mode,(alt_u8) deblur_bak);
  cfg_set_value(&mode16bit_powercycle,cfg_get_value(&mode16bit,0));
  cfg_set_value(&mode16bit,(alt_u8) mode16bit_bak);

  if (((linex_words[NTSC].config_val & CFG_RESOLUTION_GETMASK) == CFG_RESOLUTION_1440_SETMASK)  ||
      ((linex_words[NTSC].config_val & CFG_RESOLUTION_GETMASK) == CFG_RESOLUTION_1440W_SETMASK) ||
      ((linex_words[PAL].config_val  & CFG_RESOLUTION_GETMASK) == CFG_RESOLUTION_1440_SETMASK)  ||
      ((linex_words[PAL].config_val  & CFG_RESOLUTION_GETMASK) == CFG_RESOLUTION_1440W_SETMASK)  )
    unlock_1440p = TRUE;
  else
    unlock_1440p = FALSE;

  return retval;
}

void cfg_reset_selections() {
  cfg_set_value(&region_selection,PPU_REGION_CURRENT);
  cfg_set_value(&scaling_selection,PPU_SCALING_CURRENT);
  cfg_set_value(&timing_selection,PPU_TIMING_CURRENT);
}

void cfg_store_linex_word(cfg_region_sel_type_t palmode_select) {
  if (palmode_select == PPU_REGION_CURRENT || palmode_select > NUM_REGION_MODES) return;

  linex_words[palmode_select].config_val = (sysconfig.cfg_word_def[EXTCFG0]->cfg_word_val & CFG_EXTCFG0_GETLINEX_MASK);
  linex_words[palmode_select].config_ref_val = (sysconfig.cfg_word_def[EXTCFG0]->cfg_ref_word_val & CFG_EXTCFG0_GETLINEX_MASK);
  linex_scanlines_words[palmode_select].config_val = sysconfig.cfg_word_def[EXTCFG2]->cfg_word_val;
  linex_scanlines_words[palmode_select].config_ref_val = sysconfig.cfg_word_def[EXTCFG2]->cfg_ref_word_val;
}

void cfg_load_linex_word(cfg_region_sel_type_t palmode_select) {
  if (palmode_select == PPU_REGION_CURRENT || palmode_select > NUM_REGION_MODES) return;

  sysconfig.cfg_word_def[EXTCFG0]->cfg_word_val &= CFG_EXTCFG0_GETNOLINEX_MASK;
  sysconfig.cfg_word_def[EXTCFG0]->cfg_word_val |= linex_words[palmode_select].config_val;
  sysconfig.cfg_word_def[EXTCFG0]->cfg_ref_word_val &= CFG_EXTCFG0_GETNOLINEX_MASK;
  sysconfig.cfg_word_def[EXTCFG0]->cfg_ref_word_val |= linex_words[palmode_select].config_ref_val;
  sysconfig.cfg_word_def[EXTCFG2]->cfg_word_val = linex_scanlines_words[palmode_select].config_val;
  sysconfig.cfg_word_def[EXTCFG2]->cfg_ref_word_val = linex_scanlines_words[palmode_select].config_ref_val;
}

void cfg_reset_timing_word(cfg_timing_model_sel_type_t timing_word_select) {
  if (timing_word_select == PPU_TIMING_CURRENT || timing_word_select > NUM_TIMING_MODES) return;

  timing_words[timing_word_select].config_val = CFG_TIMING_DEFAULTS;
}

void cfg_store_timing_word(cfg_timing_model_sel_type_t timing_word_select) {
  if (timing_word_select == PPU_TIMING_CURRENT || timing_word_select > NUM_TIMING_MODES) return;

  timing_words[timing_word_select].config_val = ((sysconfig.cfg_word_def[EXTCFG1]->cfg_word_val & CFG_EXTCFG1_GETTIMINGS_MASK) >> CFG_HORSHIFT_OFFSET);
  timing_words[timing_word_select].config_ref_val = ((sysconfig.cfg_word_def[EXTCFG1]->cfg_ref_word_val & CFG_EXTCFG1_GETTIMINGS_MASK) >> CFG_HORSHIFT_OFFSET);
}

void cfg_load_timing_word(cfg_timing_model_sel_type_t timing_word_select) {
  if (timing_word_select == PPU_TIMING_CURRENT || timing_word_select > NUM_TIMING_MODES) return;

  sysconfig.cfg_word_def[EXTCFG1]->cfg_word_val &= CFG_EXTCFG1_GETNONTIMINGS_MASK;
  sysconfig.cfg_word_def[EXTCFG1]->cfg_word_val |= ((timing_words[timing_word_select].config_val << CFG_HORSHIFT_OFFSET) & CFG_EXTCFG1_GETTIMINGS_MASK);

  sysconfig.cfg_word_def[EXTCFG1]->cfg_ref_word_val &= CFG_EXTCFG1_GETNONTIMINGS_MASK;
  sysconfig.cfg_word_def[EXTCFG1]->cfg_ref_word_val |= ((timing_words[timing_word_select].config_ref_val << CFG_HORSHIFT_OFFSET) & CFG_EXTCFG1_GETTIMINGS_MASK);
}

void cfg_reset_scaling_word(cfg_scaler_in2out_sel_type_t scaling_word_select) {
  if (scaling_word_select == PPU_SCALING_CURRENT || scaling_word_select > NUM_SCALING_MODES) return;

  scaling_words[scaling_word_select].config_val = scaling_defaults[scaling_word_select];
}

void cfg_store_scaling_word(cfg_scaler_in2out_sel_type_t scaling_word_select) {
  if (scaling_word_select == PPU_SCALING_CURRENT || scaling_word_select > NUM_SCALING_MODES) return;

  scaling_words[scaling_word_select].config_val = (sysconfig.cfg_word_def[EXTCFG0]->cfg_word_val & CFG_EXTCFG0_GETSCALING_MASK);
  scaling_words[scaling_word_select].config_ref_val = (sysconfig.cfg_word_def[EXTCFG0]->cfg_ref_word_val & CFG_EXTCFG0_GETSCALING_MASK);
}

void cfg_load_scaling_word(cfg_scaler_in2out_sel_type_t scaling_word_select) {
  if (scaling_word_select == PPU_SCALING_CURRENT || scaling_word_select > NUM_SCALING_MODES) return;

  sysconfig.cfg_word_def[EXTCFG0]->cfg_word_val &= CFG_EXTCFG0_GETNONSCALING_MASK;
  sysconfig.cfg_word_def[EXTCFG0]->cfg_word_val |= (scaling_words[scaling_word_select].config_val & CFG_EXTCFG0_GETSCALING_MASK);

  sysconfig.cfg_word_def[EXTCFG0]->cfg_ref_word_val &= CFG_EXTCFG0_GETNONSCALING_MASK;
  sysconfig.cfg_word_def[EXTCFG0]->cfg_ref_word_val |= (scaling_words[scaling_word_select].config_ref_val & CFG_EXTCFG0_GETSCALING_MASK);
}

int cfg_load_defaults(bool_t load_video_480p, bool_t need_confirm)
{
  if (need_confirm) {
    alt_u8 abort = confirmation_routine();
    if (abort) return -CFG_DEF_LOAD_ABORT;
  }

  sysconfig.cfg_word_def[INTCFG0]->cfg_word_val &= INTCFG0_NODEFAULTS_GETMASK;
  sysconfig.cfg_word_def[INTCFG0]->cfg_word_val |= INTCFG0_DEFAULTS;

  sysconfig.cfg_word_def[EXTCFG1]->cfg_word_val &= EXTCFG1_NODEFAULTS_GETMASK;
  sysconfig.cfg_word_def[EXTCFG1]->cfg_word_val |= EXTCFG1_DEFAULTS;

  sysconfig.cfg_word_def[EXTCFG2]->cfg_word_val &= EXTCFG2_NODEFAULTS_GETMASK;
  sysconfig.cfg_word_def[EXTCFG2]->cfg_word_val |= EXTCFG2_DEFAULTS;

  sysconfig.cfg_word_def[EXTCFG3]->cfg_word_val &= EXTCFG3_NODEFAULTS_GETMASK;
  sysconfig.cfg_word_def[EXTCFG3]->cfg_word_val |= EXTCFG3_DEFAULTS;

  if (load_video_480p) {
    sysconfig.cfg_word_def[EXTCFG0]->cfg_word_val &= EXTCFG0_NODEFAULTS_GETMASK;
    sysconfig.cfg_word_def[EXTCFG0]->cfg_word_val |= EXTCFG0_DEFAULTS_PAL576P;
    cfg_store_linex_word(PAL);
    sysconfig.cfg_word_def[EXTCFG0]->cfg_word_val &= EXTCFG0_NODEFAULTS_GETMASK;
    sysconfig.cfg_word_def[EXTCFG0]->cfg_word_val |= EXTCFG0_DEFAULTS_NTSC480P;
    cfg_store_linex_word(NTSC);
  } else {
    sysconfig.cfg_word_def[EXTCFG0]->cfg_word_val &= EXTCFG0_NODEFAULTS_GETMASK;
    sysconfig.cfg_word_def[EXTCFG0]->cfg_word_val |= EXTCFG0_DEFAULTS_PAL1080P;
    cfg_store_linex_word(PAL);
    sysconfig.cfg_word_def[EXTCFG0]->cfg_word_val &= EXTCFG0_NODEFAULTS_GETMASK;
    sysconfig.cfg_word_def[EXTCFG0]->cfg_word_val |= EXTCFG0_DEFAULTS_NTSC1080P;
    cfg_store_linex_word(NTSC);
  }

  int idx;
  for (idx = 0; idx < NUM_TIMING_MODES; idx++) cfg_reset_timing_word(idx);
  for (idx = 0; idx < NUM_SCALING_MODES; idx++) cfg_reset_scaling_word(idx);

  cfg_load_linex_word(palmode);
  cfg_load_timing_word(palmode);
  cfg_load_scaling_word(palmode);

  unlock_1440p = FALSE;

  return 0;
}

void cfg_apply_to_logic()
{
  if ((scaling_n64adv == PAL_TO_288) && ((bool_t) cfg_get_value(&pal_boxed_mode,0) == FALSE) && (cfg_get_value(&vert_scale,0) < CFG_VERTSCALE_PAL_MIN))
    cfg_set_value(&vert_scale,288);
  cfg_scale_v2h_update();
  IOWR_ALTERA_AVALON_PIO_DATA(EXTCFG0_OUT_BASE,sysconfig.cfg_word_def[EXTCFG0]->cfg_word_val);
  IOWR_ALTERA_AVALON_PIO_DATA(EXTCFG1_OUT_BASE,sysconfig.cfg_word_def[EXTCFG1]->cfg_word_val);
  IOWR_ALTERA_AVALON_PIO_DATA(EXTCFG2_OUT_BASE,sysconfig.cfg_word_def[EXTCFG2]->cfg_word_val);
  IOWR_ALTERA_AVALON_PIO_DATA(EXTCFG3_OUT_BASE,sysconfig.cfg_word_def[EXTCFG3]->cfg_word_val);
}

void cfg_clear_words()
{
  int idx;
  for (idx = 0; idx < NUM_CFG_B32WORDS; idx++)
    sysconfig.cfg_word_def[idx]->cfg_word_val = 0;
}

void cfg_update_reference()
{
  int idx;
  for (idx = 0; idx < NUM_CFG_B32WORDS; idx++)
    sysconfig.cfg_word_def[idx]->cfg_ref_word_val = sysconfig.cfg_word_def[idx]->cfg_word_val;

  linex_words[NTSC].config_ref_val = linex_words[NTSC].config_val;
  linex_words[PAL].config_ref_val  = linex_words[PAL].config_val;
  linex_scanlines_words[NTSC].config_ref_val = linex_scanlines_words[NTSC].config_val;
  linex_scanlines_words[PAL].config_ref_val  = linex_scanlines_words[PAL].config_val;
  for (idx = 0; idx < NUM_TIMING_MODES; idx++) timing_words[idx].config_ref_val = timing_words[idx].config_val;
  for (idx = 0; idx < NUM_SCALING_MODES; idx++) scaling_words[idx].config_ref_val = scaling_words[idx].config_val;
}

int cfg_copy_ntsc2pal()
{
  alt_u8 abort = confirmation_routine();
  if (abort) return -CFG_CFG_COPY_ABORT;

  alt_u8 idx;
  if (cfg_get_value(&copy_direction,0)) { // PAL to NTSC
    linex_words[NTSC].config_val = linex_words[PAL].config_val;
    linex_scanlines_words[NTSC].config_val = linex_scanlines_words[PAL].config_val;
    for (idx = 1; idx <= NTSC_LAST_SCALING_MODE; idx++)
      scaling_words[idx] = scaling_words[idx + NTSC_LAST_SCALING_MODE + 1];
  } else {  // NTSC to PAL
    linex_words[PAL].config_val = linex_words[NTSC].config_val;
    linex_scanlines_words[PAL].config_val = linex_scanlines_words[NTSC].config_val;
    for (idx = 1; idx <= NTSC_LAST_SCALING_MODE; idx++)
      scaling_words[idx + NTSC_LAST_SCALING_MODE + 1] = scaling_words[idx];
    cfg_set_flag(&pal_boxed_mode);
  }
  return 0;
}
