
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

extern const char  *OffOn[], *NTSCPAL_SEL[], *VTimingSel[];

cfg_b32word_t cfg_data_internal =
  { .cfg_word_mask    = 0x0000000F,
    .cfg_word_val     = 0x00000000,
    .cfg_ref_word_val = 0x00000000
  };

config_t deblur_mode_powercycle = {
    .cfg_word        = &cfg_data_internal,
    .cfg_word_offset = 3,
    .cfg_type     = FLAG,
    .flag_masks      = {
        .setflag_mask = (1<<3),
        .clrflag_mask = (0x0000000F & ~(1<<3))
    },
    .value_string = &OffOn
};

config_t mode16bit_powercycle = {
    .cfg_word        = &cfg_data_internal,
    .cfg_word_offset = 2,
    .cfg_type     = FLAG,
    .flag_masks      = {
        .setflag_mask = (1<<2),
        .clrflag_mask = (0x0000000F & ~(1<<2))
    },
    .value_string = &OffOn
};

config_t igr_deblur = {
    .cfg_word        = &cfg_data_internal,
    .cfg_word_offset = 1,
    .cfg_type     = FLAGTXT,
    .flag_masks      = {
        .setflag_mask = (1<<1),
        .clrflag_mask = (0x0000000F & ~(1<<1))
    },
    .val2char_func = &flag2set_func
};

config_t igr_16bitmode = {
    .cfg_word        = &cfg_data_internal,
    .cfg_word_offset = 0,
    .cfg_type     = FLAGTXT,
    .flag_masks      = {
        .setflag_mask = (1<<0),
        .clrflag_mask = (0x0000000F & ~(1<<0))
    },
    .val2char_func = &flag2set_func
};

config_t res_selection = {
    // .cfg_b32word_t* must be NULL to show that this is a local value without reference
    .cfg_type     = TXTVALUE, // treat as txtvalue for modifying function
    .cfg_value    = PPU_RES_CURRENT,
    .value_details = {
      .max_value = PPU_RES_CURRENT,
    },
    .value_string = &NTSCPAL_SEL
};

config_t scanline_selection = {
    // .cfg_b32word_t* must be NULL to show that this is a local value without reference
    .cfg_type     = TXTVALUE, // treat as txtvalue for modifying function
    .cfg_value    = 0,
    .value_details = {
      .max_value = NUM_TIMING_MODES,
    },
    .value_string = &VTimingSel
};

config_t timing_selection = {
    // .cfg_b32word_t* must be NULL to show that this is a local value without reference
    .cfg_type     = TXTVALUE, // treat as txtvalue for modifying function
    .cfg_value    = 0,
    .value_details = {
      .max_value = NUM_TIMING_MODES,
    },
    .value_string = &VTimingSel
};

config_t scaling_selection = {
    // .cfg_b32word_t* must be NULL to show that this is a local value without reference
    .cfg_type     = NUMVALUE, // treat as numvalue for modifying function
    .cfg_value    = 0,
    .value_details = {
      .max_value = NUM_SCALING_MODES,
    },
    .val2char_func = &val2txt_scale_sel_func
};

#endif /* CFG_INT_P_H_ */
