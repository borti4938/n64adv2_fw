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

extern const char  *ColorSpace[], *ScaleVHLink[], *OffOn[], *NTSCPAL_SEL[], *HV_SEL[], *FallbackRes[], *VTimingSel[], *ScaleSteps[], *CopyCfg[], *DebugBoot[];

cfg_b32word_t intcfg0_word =
  { .cfg_word_mask    = INTCFG0_GETALL_MASK,
    .cfg_word_val     = 0x00000000,
    .cfg_ref_word_val = 0x00000000
  };

config_t swap_led = {
    .cfg_word        = &intcfg0_word,
    .cfg_word_offset = CFG_LEDSWAP_OFFSET,
    .cfg_type        = FLAGTXT,
    .flag_masks      = {
        .setflag_mask = CFG_LEDSWAP_SETMASK,
        .clrflag_mask = CFG_LEDSWAP_CLRMASK
    },
    .val2char_func = &flag2set_func
};

#ifdef HDR_TESTING
  config_t hdr10_injection = {
      .cfg_word        = &intcfg0_word,
      .cfg_word_offset = CFG_HDR10INJ_OFFSET,
      .cfg_type        = FLAGTXT,
      .flag_masks      = {
          .setflag_mask = CFG_HDR10INJ_SETMASK,
          .clrflag_mask = CFG_HDR10INJ_CLRMASK
      },
      .val2char_func = &flag2set_func
  };
#endif

config_t color_space = {
    .cfg_word        = &intcfg0_word,
    .cfg_word_offset = CFG_COLORSPACE_OFFSET,
    .cfg_type        = TXTVALUE,
    .value_details   = {
        .max_value     = CFG_COLORSPACE_MAX_VALUE,
        .getvalue_mask = CFG_COLORSPACE_GETMASK
    },
    .value_string = (const char **) &ColorSpace
};

config_t limited_colorspace = {
    .cfg_word        = &intcfg0_word,
    .cfg_word_offset = CFG_LIMITED_COLORSPACE_OFFSET,
    .cfg_type        = FLAGTXT,
    .flag_masks      = {
        .setflag_mask = CFG_LIMITED_COLORSPACE_SETMASK,
        .clrflag_mask = CFG_LIMITED_COLORSPACE_CLRMASK
    },
    .val2char_func = &flag2set_func
};

config_t deblur_mode_powercycle = {
    .cfg_word        = &intcfg0_word,
    .cfg_word_offset = CFG_DEBLUR_PC_DEFAULT_OFFSET,
    .cfg_type     = FLAG,
    .flag_masks      = {
        .setflag_mask = CFG_DEBLUR_PC_DEFAULT_SETMASK,
        .clrflag_mask = CFG_DEBLUR_PC_DEFAULT_CLRMASK
    },
    .value_string = (const char **) &OffOn
};

config_t mode16bit_powercycle = {
    .cfg_word        = &intcfg0_word,
    .cfg_word_offset = CFG_MODE16BIT_PC_DEFAULT_OFFSET,
    .cfg_type     = FLAG,
    .flag_masks      = {
        .setflag_mask = CFG_MODE16BIT_PC_DEFAULT_SETMASK,
        .clrflag_mask = CFG_MODE16BIT_PC_DEFAULT_CLRMASK
    },
    .value_string = (const char **) &OffOn
};

config_t igr_deblur = {
    .cfg_word        = &intcfg0_word,
    .cfg_word_offset = CFG_DEBLUR_IGR_OFFSET,
    .cfg_type     = FLAGTXT,
    .flag_masks      = {
        .setflag_mask = CFG_DEBLUR_IGR_SETMASK,
        .clrflag_mask = CFG_DEBLUR_IGR_CLRMASK
    },
    .val2char_func = &flag2set_func
};

config_t igr_16bitmode = {
    .cfg_word        = &intcfg0_word,
    .cfg_word_offset = CFG_MODE16BIT_IGR_OFFSET,
    .cfg_type     = FLAGTXT,
    .flag_masks      = {
        .setflag_mask = CFG_MODE16BIT_IGR_SETMASK,
        .clrflag_mask = CFG_MODE16BIT_IGR_CLRMASK
    },
    .val2char_func = &flag2set_func
};

config_t link_hv_scale = {
    .cfg_word        = &intcfg0_word,
    .cfg_word_offset = CFG_LINK_HV_SCALE_OFFSET,
    .cfg_type        = TXTVALUE,
    .value_details   = {
        .max_value     = CFG_LINK_HV_SCALE_MAX_VALUE,
        .getvalue_mask = CFG_LINK_HV_SCALE_GETMASK
    },
    .value_string = (const char **) &ScaleVHLink
};

config_t fallbackmode = {
    .cfg_word        = &intcfg0_word,
    .cfg_word_offset = CFG_FALLBACK_OFFSET,
    .cfg_type        = TXTVALUE,
    .value_details   = {
        .max_value     = CFG_FALLBACK_MAX_VALUE,
        .getvalue_mask = CFG_FALLBACK_GETMASK
    },
    .value_string = (const char **) &FallbackRes
};

config_t autosave = {
    .cfg_word        = &intcfg0_word,
    .cfg_word_offset = CFG_AUTOSAVE_OFFSET,
    .cfg_type     = FLAGTXT,
    .flag_masks      = {
        .setflag_mask = CFG_AUTOSAVE_SETMASK,
        .clrflag_mask = CFG_AUTOSAVE_CLRMASK
    },
    .val2char_func = &flag2set_func
};

config_t debug_boot = {
    .cfg_word        = &intcfg0_word,
    .cfg_word_offset = CFG_DEBUGBOOT_OFFSET,
    .cfg_type        = FLAG,
    .flag_masks      = {
        .setflag_mask = CFG_DEBUGBOOT_SETMASK,
        .clrflag_mask = CFG_DEBUGBOOT_CLRMASK
    },
    .value_string = (const char **) &DebugBoot
};

// values without reference values
config_t scaling_steps = {
    // .cfg_b32word_t* must be NULL to show that this is a local value without reference
    .cfg_type     = TXTVALUE, // treat as txtvalue for modifying function
    .cfg_value    = 0,
    .value_details = {
      .max_value = 1,
    },
    .value_string = (const char **) &ScaleSteps
};

config_t region_selection = {
    // .cfg_b32word_t* must be NULL to show that this is a local value without reference
    .cfg_type     = TXTVALUE, // treat as txtvalue for modifying function
    .cfg_value    = NTSC,
    .value_details = {
      .max_value = PAL,
    },
    .value_string = (const char **) &NTSCPAL_SEL
};

config_t timing_selection = {
    // .cfg_b32word_t* must be NULL to show that this is a local value without reference
    .cfg_type     = TXTVALUE, // treat as txtvalue for modifying function
    .cfg_value    = NTSC_PROGRESSIVE,
    .value_details = {
      .max_value = PAL_INTERLACED,
    },
    .value_string = (const char **) &VTimingSel
};

config_t scaling_selection = {
    // .cfg_b32word_t* must be NULL to show that this is a local value without reference
    .cfg_type     = NUMVALUE, // treat as numvalue for modifying function
    .cfg_value    = NTSC_TO_1080,
    .value_details = {
      .max_value = PAL_TO_1440W,
    },
    .val2char_func = &val2txt_scale_sel_func
};

config_t copy_direction = {
    // .cfg_b32word_t* must be NULL to show that this is a local value without reference
    .cfg_type     = TXTVALUE, // treat as txtvalue for modifying function
    .cfg_value    = 0,
    .value_details = {
      .max_value = 1,
    },
    .value_string = (const char **) &CopyCfg
};

config_t lock_menu = {
    // .cfg_b32word_t* must be NULL to show that this is a local value without reference
    .cfg_type     = FLAGTXT,
    .cfg_value    = 0,
    .value_details = {
      .max_value = 1,
    },
    .val2char_func = &flag2set_func
};

#endif /* CFG_INT_P_H_ */
