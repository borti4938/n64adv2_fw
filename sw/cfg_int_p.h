
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

extern const char  *ScaleVHLink[], *OffOn[], *NTSCPAL_SEL[], *HV_SEL[], *FallbackRes[], *VTimingSel[], *ScaleSteps[];

cfg_b32word_t intcfg0_word =
  { .cfg_word_mask    = INTCFG0_GETALL_MASK,
    .cfg_word_val     = 0x00000000,
    .cfg_ref_word_val = 0x00000000
  };

config_t link_hv_scale = {
    .cfg_word        = &intcfg0_word,
    .cfg_word_offset = CFG_LINK_HV_SCALE_OFFSET,
    .cfg_type        = TXTVALUE,
    .value_details   = {
        .max_value     = CFG_LINK_HV_SCALE_MAX_VALUE,
        .getvalue_mask = CFG_LINK_HV_SCALE_GETMASK
    },
    .value_string = &ScaleVHLink
};

config_t deblur_mode_powercycle = {
    .cfg_word        = &intcfg0_word,
    .cfg_word_offset = CFG_DEBLUR_PC_DEFAULT_OFFSET,
    .cfg_type     = FLAG,
    .flag_masks      = {
        .setflag_mask = CFG_DEBLUR_PC_DEFAULT_SETMASK,
        .clrflag_mask = CFG_DEBLUR_PC_DEFAULT_CLRMASK
    },
    .value_string = &OffOn
};

config_t mode16bit_powercycle = {
    .cfg_word        = &intcfg0_word,
    .cfg_word_offset = CFG_MODE16BIT_PC_DEFAULT_OFFSET,
    .cfg_type     = FLAG,
    .flag_masks      = {
        .setflag_mask = CFG_MODE16BIT_PC_DEFAULT_SETMASK,
        .clrflag_mask = CFG_MODE16BIT_PC_DEFAULT_CLRMASK
    },
    .value_string = &OffOn
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

config_t fallbackmode = {
    .cfg_word        = &intcfg0_word,
    .cfg_word_offset = CFG_FALLBACK_OFFSET,
    .cfg_type     = FLAG,
    .flag_masks      = {
        .setflag_mask = CFG_FALBACK_SETMASK,
        .clrflag_mask = CFG_FALLBACK_CLRMASK
    },
    .value_string = &FallbackRes
};

config_t scaling_steps = {
    // .cfg_b32word_t* must be NULL to show that this is a local value without reference
    .cfg_type     = TXTVALUE, // treat as txtvalue for modifying function
    .cfg_value    = 0,
    .value_details = {
      .max_value = 1,
    },
    .value_string = &ScaleSteps
};

config_t region_selection = {
    // .cfg_b32word_t* must be NULL to show that this is a local value without reference
    .cfg_type     = TXTVALUE, // treat as txtvalue for modifying function
    .cfg_value    = PPU_REGION_CURRENT,
    .value_details = {
      .max_value = NUM_REGION_MODES,
    },
    .value_string = &NTSCPAL_SEL
};

config_t timing_selection = {
    // .cfg_b32word_t* must be NULL to show that this is a local value without reference
    .cfg_type     = TXTVALUE, // treat as txtvalue for modifying function
    .cfg_value    = PPU_TIMING_CURRENT,
    .value_details = {
      .max_value = NUM_TIMING_MODES,
    },
    .value_string = &VTimingSel
};

config_t scaling_selection = {
    // .cfg_b32word_t* must be NULL to show that this is a local value without reference
    .cfg_type     = NUMVALUE, // treat as numvalue for modifying function
    .cfg_value    = PPU_SCALING_CURRENT,
    .value_details = {
      .max_value = NUM_SCALING_MODES,
    },
    .val2char_func = &val2txt_scale_sel_func
};

#endif /* CFG_INT_P_H_ */
