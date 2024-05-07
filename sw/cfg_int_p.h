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
 * cfg_int_p.h
 *
 *  Created on: 17.09.2020
 *      Author: Peter Bartmann
 *
 ********************************************************************************/

#include "alt_types.h"
#include "altera_avalon_pio_regs.h"
#include "system.h"

#include "config.h"
#include "menu.h"


#ifndef CFG_INT_P_H_
#define CFG_INT_P_H_

extern const char  *ColorSpace[], *ScaleVHLink[], *OffOn[], *NTSCPAL_SEL[], *HV_SEL[], *FallbackRes[], *FallbackTrig[], *VTimingSel[], *ScaleSteps[], *CopyCfg[], *DebugBoot[];


// internal configuration with references (saveable)
cfg_b32word_t intcfg0_word = {
  .cfg_word_val     = 0x00000000,
  .cfg_ref_word_val = 0x00000000
};

config_t swap_led = {
  .cfg_word        = &intcfg0_word,
  .cfg_word_offset = CFG_LEDSWAP_OFFSET,
  .num_cfg_bits    = CFG_LEDSWAP_NOFBITS,
  .max_value       = 1,
  .cfg_disp_type   = DISP_BUF_FUNC,
  .val2char_func   = &flag2set_func
};

#ifdef HDR_TESTING
  config_t hdr10_injection = {
    .cfg_word        = &intcfg0_word,
    .cfg_word_offset = CFG_HDR10INJ_OFFSET,
    .num_cfg_bits    = CFG_HDR10INJ_NOFBITS,
    .max_value       = 1,
    .cfg_disp_type   = DISP_BUF_FUNC,
    .val2char_func   = &flag2set_func
  };
#endif

config_t color_space = {
  .cfg_word        = &intcfg0_word,
  .cfg_word_offset = CFG_COLORSPACE_OFFSET,
  .num_cfg_bits    = CFG_COLORSPACE_NOFBITS,
  .max_value       = CFG_COLORSPACE_MAX_VALUE,
  .cfg_disp_type   = VAL_STRING,
  .value_string    = (const char **) &ColorSpace
};

config_t limited_colorspace = {
  .cfg_word        = &intcfg0_word,
  .cfg_word_offset = CFG_LIMITED_COLORSPACE_OFFSET,
  .num_cfg_bits    = CFG_LIMITED_COLORSPACE_NOFBITS,
  .max_value       = 1,
  .cfg_disp_type   = DISP_BUF_FUNC,
  .val2char_func   = &flag2set_func
};

config_t deblur_mode_powercycle = {
  .cfg_word        = &intcfg0_word,
  .cfg_word_offset = CFG_DEBLUR_PC_DEFAULT_OFFSET,
  .num_cfg_bits    = CFG_DEBLUR_PC_DEFAULT_NOFBITS,
  .max_value       = 1,
  .cfg_disp_type   = VAL_STRING,
  .value_string    = (const char **) &OffOn
};

config_t mode16bit_powercycle = {
  .cfg_word        = &intcfg0_word,
  .cfg_word_offset = CFG_MODE16BIT_PC_DEFAULT_OFFSET,
  .num_cfg_bits    = CFG_MODE16BIT_PC_DEFAULT_NOFBITS,
  .max_value       = 1,
  .cfg_disp_type   = VAL_STRING,
  .value_string    = (const char **) &OffOn
};

config_t igr_deblur = {
  .cfg_word        = &intcfg0_word,
  .cfg_word_offset = CFG_DEBLUR_IGR_OFFSET,
  .num_cfg_bits    = CFG_DEBLUR_IGR_NOFBITS,
  .max_value       = 1,
  .cfg_disp_type   = DISP_BUF_FUNC,
  .val2char_func   = &flag2set_func
};

config_t igr_16bitmode = {
  .cfg_word        = &intcfg0_word,
  .cfg_word_offset = CFG_MODE16BIT_IGR_OFFSET,
  .num_cfg_bits    = CFG_MODE16BIT_IGR_NOFBITS,
  .max_value       = 1,
  .cfg_disp_type   = DISP_BUF_FUNC,
  .val2char_func   = &flag2set_func
};

config_t link_hv_scale = {
  .cfg_word        = &intcfg0_word,
  .cfg_word_offset = CFG_LINK_HV_SCALE_OFFSET,
  .num_cfg_bits    = CFG_LINK_HV_SCALE_NOFBITS,
  .max_value       = CFG_LINK_HV_SCALE_MAX_VALUE,
  .cfg_disp_type   = VAL_STRING,
  .value_string    = (const char **) &ScaleVHLink
};

config_t fallback_resolution = {
  .cfg_word        = &intcfg0_word,
  .cfg_word_offset = CFG_FALLBACK_RES_OFFSET,
  .num_cfg_bits    = CFG_FALLBACK_RES_NOFBITS,
  .max_value       = CFG_FALLBACK_MAX_VALUE,
  .cfg_disp_type   = VAL_STRING,
  .value_string    = (const char **) &FallbackRes
};

config_t fallback_trigger = {
  .cfg_word        = &intcfg0_word,
  .cfg_word_offset = CFG_FALLBACK_TRIGGER_OFFSET,
  .num_cfg_bits    = CFG_FALLBACK_TRIGGER_NOFBITS,
  .max_value       = CFG_FALLBACK_MAX_VALUE,
  .cfg_disp_type   = VAL_STRING,
  .value_string    = (const char **) &FallbackTrig
};

config_t fallback_menu = {
  .cfg_word        = &intcfg0_word,
  .cfg_word_offset = CFG_FALLBACK_MENU_OFFSET,
  .num_cfg_bits    = CFG_FALLBACK_MENU_NOFBITS,
  .max_value       = 1,
  .cfg_disp_type   = VAL_STRING,
  .value_string    = (const char **) &OffOn
};

config_t autosave = {
  .cfg_word        = &intcfg0_word,
  .cfg_word_offset = CFG_AUTOSAVE_OFFSET,
  .num_cfg_bits    = CFG_AUTOSAVE_NOFBITS,
  .cfg_disp_type   = DISP_BUF_FUNC,
  .val2char_func   = &flag2set_func
};

config_t debug_vtimeout = {
  .cfg_word        = &intcfg0_word,
  .cfg_word_offset = CFG_DEBUGVTIMEOUT_OFFSET,
  .num_cfg_bits    = CFG_DEBUGVTIMEOUT_NOFBITS,
  .max_value       = 1,
  .cfg_disp_type   = VAL_STRING,
  .value_string    = (const char **) &DebugBoot
};


// values without reference values (not saveable)
// .cfg_b32word_t* must be NULL to show that this is a local value without reference
config_t scaling_steps = {
  .cfg_value     = 0,
  .max_value     = 1,
  .cfg_disp_type = VAL_STRING,
  .value_string  = (const char **) &ScaleSteps
};

config_t region_selection = {
  .cfg_value     = NTSC,
  .max_value     = PAL,
  .cfg_disp_type = VAL_STRING,
  .value_string  = (const char **) &NTSCPAL_SEL
};

config_t scaling_selection = {
  .cfg_value     = NTSC_TO_1080,
  .max_value     = PAL_TO_1440W,
  .cfg_disp_type = DISP_BUF_FUNC,
  .val2char_func = &val2txt_scale_sel_func
};

config_t copy_direction = {
  .cfg_value     = 0,
  .max_value     = 1,
  .cfg_disp_type = VAL_STRING,
  .value_string  = (const char **) &CopyCfg
};

config_t lock_menu = {
  .cfg_value     = FALSE,
  .max_value     = TRUE,
  .cfg_disp_type = DISP_BUF_FUNC,
  .val2char_func = &flag2set_func
};


#endif /* CFG_INT_P_H_ */
