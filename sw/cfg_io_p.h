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
 * cfg_header/cfg_io_p.h
 *
 *  Created on: 17.01.2018
 *      Author: Peter Bartmann
 *
 ********************************************************************************/

#include "alt_types.h"
#include "altera_avalon_pio_regs.h"
#include "system.h"

#include "config.h"
#include "menu.h"
#include "vd_driver.h"


#ifndef CFG_HEADER_CFG_IO_P_H_
#define CFG_HEADER_CFG_IO_P_H_

extern char szText[VD_WIDTH];

extern const char *OffOn[], *Force5060[], *Resolutions[], *InterpModes[], *AdvSL[],
                  *LinkSL[], *EvenOdd[], *QuickChange[];


// misc
cfg_b32word_t cfg_data_misc =
  { .cfg_word_mask    = CFG_MISC_GETALL_MASK,
    .cfg_word_val     = 0x00000000,
    .cfg_ref_word_val = 0x00000000
  };

config_t audio_amp = {
    .cfg_word        = &cfg_data_misc,
    .cfg_word_offset = CFG_AUDIO_AMP_OFFSET,
    .cfg_type        = NUMVALUE,
    .value_details   = {
        .max_value     = CFG_AUDIO_AMP_MAX_VALUE,
        .getvalue_mask = CFG_AUDIO_AMP_GETMASK
    },
    .val2char_func = &audioamp2txt_func
};

config_t audio_swap_lr = {
    .cfg_word        = &cfg_data_misc,
    .cfg_word_offset = CFG_AUDIO_SWAP_LR_OFFSET,
    .cfg_type        = FLAGTXT,
    .flag_masks      = {
        .setflag_mask = CFG_AUDIO_SWAP_LR_SETMASK,
        .clrflag_mask = CFG_AUDIO_SWAP_LR_CLRMASK
    },
    .val2char_func = &flag2set_func
};

config_t audio_spdif_en = {
    .cfg_word        = &cfg_data_misc,
    .cfg_word_offset = CFG_AUDIO_SPDIF_EN_OFFSET,
    .cfg_type        = FLAGTXT,
    .flag_masks      = {
        .setflag_mask = CFG_AUDIO_SPDIF_EN_SETMASK,
        .clrflag_mask = CFG_AUDIO_SPDIF_EN_CLRMASK
    },
    .val2char_func = &flag2set_func
};

config_t show_logo = {
    .cfg_word        = &cfg_data_misc,
    .cfg_word_offset = CFG_SHOWLOGO_OFFSET,
    .cfg_type        = FLAG,
    .flag_masks      = {
        .setflag_mask = CFG_SHOWLOGO_SETMASK,
        .clrflag_mask = CFG_SHOWLOGO_CLRMASK
    }
};

config_t show_osd = {
    .cfg_word        = &cfg_data_misc,
    .cfg_word_offset = CFG_SHOWOSD_OFFSET,
    .cfg_type        = FLAG,
    .flag_masks      = {
        .setflag_mask = CFG_SHOWOSD_SETMASK,
        .clrflag_mask = CFG_SHOWOSD_CLRMASK
    }
};

config_t mute_osd_tmp = {
    .cfg_word        = &cfg_data_misc,
    .cfg_word_offset = CFG_MUTEOSDTMP_OFFSET,
    .cfg_type        = FLAG,
    .flag_masks      = {
        .setflag_mask = CFG_MUTEOSDTMP_SETMASK,
        .clrflag_mask = CFG_MUTEOSDTMP_CLRMASK
    }
};

config_t limited_rgb = {
    .cfg_word = &cfg_data_misc,
    .cfg_word_offset = CFG_LIMITED_RGB_OFFSET,
    .cfg_type        = FLAGTXT,
    .flag_masks      = {
        .setflag_mask = CFG_LIMITED_RGB_SETMASK,
        .clrflag_mask = CFG_LIMITED_RGB_CLRMASK
    },
    .val2char_func = &flag2set_func
};

config_t deblur_mode = {
    .cfg_word        = &cfg_data_misc,
    .cfg_word_offset = CFG_DEBLUR_MODE_OFFSET,
    .cfg_type        = FLAGTXT,
    .flag_masks      = {
        .setflag_mask = CFG_DEBLUR_MODE_SETMASK,
        .clrflag_mask = CFG_DEBLUR_MODE_CLRMASK
    },
    .val2char_func = &flag2set_func
};

config_t mode16bit = {
    .cfg_word        = &cfg_data_misc,
    .cfg_word_offset = CFG_16BITMODE_OFFSET,
    .cfg_type        = FLAGTXT,
    .flag_masks      = {
        .setflag_mask = CFG_16BITMODE_SETMASK,
        .clrflag_mask = CFG_16BITMODE_CLRMASK
    },
    .val2char_func = &flag2set_func
};

config_t igr_reset = {
    .cfg_word = &cfg_data_misc,
    .cfg_word_offset = CFG_IGRRST_OFFSET,
    .cfg_type        = FLAGTXT,
    .flag_masks      = {
        .setflag_mask = CFG_IGRRST_SETMASK,
        .clrflag_mask = CFG_IGRRST_CLRMASK
    },
    .val2char_func = &flag2set_func
};


// video
cfg_b32word_t cfg_data_video =
  { .cfg_word_mask    = CFG_VIDEO_GETALL_MASK,
    .cfg_word_val     = 0x00000000,
    .cfg_ref_word_val = 0x00000000
  };

config_t gamma_lut = {
    .cfg_word        = &cfg_data_video,
    .cfg_word_offset = CFG_GAMMA_OFFSET,
    .cfg_type        = NUMVALUE,
    .value_details   = {
        .max_value     = CFG_GAMMA_MAX_VALUE,
        .getvalue_mask = CFG_GAMMA_GETMASK
    },
    .val2char_func = &gamma2txt_func
};

config_t hor_shift = {
    .cfg_word        = &cfg_data_video,
    .cfg_word_offset = CFG_HORSHIFT_OFFSET,
    .cfg_type        = NUMVALUE,
    .value_details   = {
        .max_value     = CFG_HORSHIFT_MAX_VALUE,
        .getvalue_mask = CFG_HORSHIFT_GETMASK
    },
    .val2char_func = &val2txt_6b_binaryoffset_func
};

config_t vert_shift = {
    .cfg_word        = &cfg_data_video,
    .cfg_word_offset = CFG_VERTSHIFT_OFFSET,
    .cfg_type        = NUMVALUE,
    .value_details   = {
        .max_value     = CFG_VERTSHIFT_MAX_VALUE,
        .getvalue_mask = CFG_VERTSHIFT_GETMASK
    },
    .val2char_func = &val2txt_6b_binaryoffset_func
};

config_t link_hv_scale = {
    .cfg_word        = &cfg_data_video,
    .cfg_word_offset = CFG_LINK_HVSCALE_OFFSET,
    .cfg_type        = FLAGTXT,
    .flag_masks      = {
        .setflag_mask = CFG_LINK_HVSCALE_SETMASK,
        .clrflag_mask = CFG_LINK_HVSCALE_CLRMASK
    },
    .val2char_func = &flag2set_func
};

config_t hor_scale = {
    .cfg_word        = &cfg_data_video,
    .cfg_word_offset = CFG_HORSCALE_OFFSET,
    .cfg_type        = NUMVALUE,
    .value_details   = {
        .max_value     = CFG_HORSCALE_MAX_VALUE,
        .getvalue_mask = CFG_HORSCALE_GETMASK
    },
    .val2char_func = &val2txt_hscale_func
};

config_t vert_scale = {
    .cfg_word        = &cfg_data_video,
    .cfg_word_offset = CFG_VERTSCALE_OFFSET,
    .cfg_type        = NUMVALUE,
    .value_details   = {
        .max_value     = CFG_VERTSCALE_MAX_VALUE,
        .getvalue_mask = CFG_VERTSCALE_GETMASK
    },
    .val2char_func = &val2txt_vscale_func
};

config_t interpolation_mode = {
    .cfg_word        = &cfg_data_video,
    .cfg_word_offset = CFG_INTERP_MODE_OFFSET,
    .cfg_type        = TXTVALUE,
    .value_details   = {
        .max_value     = 1,
        .getvalue_mask = CFG_INTERP_MODE_GETMASK
    },
    .value_string = &InterpModes
};

config_t pal_boxed_mode = {
    .cfg_word        = &cfg_data_video,
    .cfg_word_offset = CFG_PAL_BOXED_MODE_OFFSET,
    .cfg_type        = FLAGTXT,
    .flag_masks      = {
        .setflag_mask = CFG_PAL_BOXED_MODE_SETMASK,
        .clrflag_mask = CFG_PAL_BOXED_MODE_CLRMASK
    },
    .val2char_func = &flag2set_func
};


// image 240p and 480i
cfg_b32word_t cfg_data_linex =
  { .cfg_word_mask    = CFG_LINEX_GETALL_MASK,
    .cfg_word_val     = 0x000000000,
    .cfg_ref_word_val = 0x000000000
  };

config_t linex_force_5060 = {
    .cfg_word        = &cfg_data_linex,
    .cfg_word_offset = CFG_FORCE_5060_OFFSET,
    .cfg_type        = TXTVALUE,
    .value_details   = {
        .max_value     = CFG_FORCE5060_MAX_VALUE,
        .getvalue_mask = CFG_FORCE_5060_GETMASK
    },
    .value_string = &Force5060
};

config_t vga_for_480p = {
    .cfg_word        = &cfg_data_linex,
    .cfg_word_offset = CFG_VGAFOR480P_OFFSET,
    .cfg_type        = FLAGTXT,
    .flag_masks      = {
        .setflag_mask = CFG_VGAFOR480P_SETMASK,
        .clrflag_mask = CFG_VGAFOR480P_CLRMASK
    },
    .val2char_func = &flag2set_func
};

config_t low_latency_mode = {
    .cfg_word        = &cfg_data_linex,
    .cfg_word_offset = CFG_LOWLATENCYMODE_OFFSET,
    .cfg_type        = FLAGTXT,
    .flag_masks      = {
        .setflag_mask = CFG_LOWLATENCYMODE_SETMASK,
        .clrflag_mask = CFG_LOWLATENCYMODE_CLRMASK
    },
    .val2char_func = &flag2set_func
};

config_t linex_resolution = {
    .cfg_word        = &cfg_data_linex,
    .cfg_word_offset = CFG_RESOLUTION_OFFSET,
    .cfg_type        = TXTVALUE,
    .value_details   = {
        .max_value     = CFG_RESOLUTION_MAX_VALUE,
        .getvalue_mask = CFG_RESOLUTION_GETMASK
    },
    .value_string = &Resolutions
};

config_t slhyb_str = {
    .cfg_word        = &cfg_data_linex,
    .cfg_word_offset = CFG_240P_SLHYBDEP_OFFSET,
    .cfg_type        = NUMVALUE,
    .value_details   = {
        .max_value     = CFG_SLHYBDEP_MAX_VALUE,
        .getvalue_mask = CFG_240P_SLHYBDEP_GETMASK
    },
    .val2char_func = &scanline_hybrstr2txt_func
};

config_t sl_str = {
    .cfg_word        = &cfg_data_linex,
    .cfg_word_offset = CFG_240P_SLSTR_OFFSET,
    .cfg_type        = NUMVALUE,
    .value_details   = {
        .max_value     = CFG_SLSTR_MAX_VALUE,
        .getvalue_mask = CFG_240P_SLSTR_GETMASK
    },
    .val2char_func = &scanline_str2txt_func
};

config_t sl_method = {
    .cfg_word        = &cfg_data_linex,
    .cfg_word_offset = CFG_240P_SL_METHOD_OFFSET,
    .cfg_type        = FLAG,
    .flag_masks   = {
        .setflag_mask = CFG_240P_SL_METHOD_SETMASK,
        .clrflag_mask = CFG_240P_SL_METHOD_CLRMASK
    },
    .value_string = &AdvSL
};

config_t sl_id = {
    .cfg_word        = &cfg_data_linex,
    .cfg_word_offset = CFG_240P_SL_ID_OFFSET,
    .cfg_type        = FLAG,
    .flag_masks   = {
        .setflag_mask = CFG_240P_SL_ID_SETMASK,
        .clrflag_mask = CFG_240P_SL_ID_CLRMASK
    },
    .value_string = &EvenOdd
};

config_t sl_en = {
    .cfg_word = &cfg_data_linex,
    .cfg_word_offset = CFG_240P_SL_EN_OFFSET,
    .cfg_type        = FLAG,
    .flag_masks      = {
        .setflag_mask = CFG_240P_SL_EN_SETMASK,
        .clrflag_mask = CFG_240P_SL_EN_CLRMASK
    },
    .value_string = &OffOn
};

config_t slhyb_str_480i = {
    .cfg_word        = &cfg_data_linex,
    .cfg_word_offset = CFG_480I_SLHYBDEP_OFFSET,
    .cfg_type        = NUMVALUE,
    .value_details   = {
        .max_value     = CFG_SLHYBDEP_MAX_VALUE,
        .getvalue_mask = CFG_480I_SLHYBDEP_GETMASK
    },
    .val2char_func = &scanline_hybrstr2txt_func
};

config_t sl_str_480i = {
    .cfg_word        = &cfg_data_linex,
    .cfg_word_offset = CFG_480I_SLSTR_OFFSET,
    .cfg_type        = NUMVALUE,
    .value_details   = {
        .max_value     = CFG_SLSTR_MAX_VALUE,
        .getvalue_mask = CFG_480I_SLSTR_GETMASK
    },
    .val2char_func = &scanline_str2txt_func
};

config_t sl_id_480i = {
    .cfg_word        = &cfg_data_linex,
    .cfg_word_offset = CFG_480I_SL_ID_OFFSET,
    .cfg_type        = FLAG,
    .flag_masks   = {
        .setflag_mask = CFG_480I_SL_ID_SETMASK,
        .clrflag_mask = CFG_480I_SL_ID_CLRMASK
    },
    .value_string = &EvenOdd
};

config_t sl_method_480i = {
    .cfg_word = &cfg_data_linex,
    .cfg_word_offset = CFG_480I_SL_METHOD_OFFSET,
    .cfg_type        = FLAG,
    .flag_masks      = {
        .setflag_mask = CFG_480I_SL_METHOD_SETMASK,
        .clrflag_mask = CFG_480I_SL_METHOD_CLRMASK
    },
    .value_string = &AdvSL
};

config_t sl_en_480i = {
    .cfg_word = &cfg_data_linex,
    .cfg_word_offset = CFG_480I_SL_EN_OFFSET,
    .cfg_type        = TXTVALUE,
    .value_details   = {
        .max_value     = CFG_480I_SL_EN_MAX_VALUE,
        .getvalue_mask = CFG_480I_SL_EN_GETMASK
    },
    .value_string = &LinkSL
};


#endif /* CFG_HEADER_CFG_IO_P_H_ */
