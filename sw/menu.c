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
 * menu.c
 *
 *  Created on: 09.01.2018
 *      Author: Peter Bartmann
 *
 ********************************************************************************/


#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include "alt_types.h"
#include "common_types.h"
#include "altera_avalon_pio_regs.h"
#include "system.h"
#include "app_cfg.h"
#include "n64.h"
#include "config.h"
#include "menu.h"
#include "textdefs_p.h"
#include "vd_driver.h"
#include "led.h"

char szText[VD_WIDTH];
extern vmode_t vmode_menu;
extern cfg_scaler_in2out_sel_type_t scaling_menu, scaling_n64adv;

static const arrowshape_t select_arrow = {
    .left  = EMPTY,
    .right = TRIANGLE_RIGHT
};

static const arrowshape_t optval_arrow = {
    .left  = TRIANGLE_LEFT,
    .right = TRIANGLE_RIGHT
};

alt_u16 message_cnt;

menu_t home_menu, vires_screen, viscaling_screen, slcfg_opt_subscreen,
       vicfg_screen, audcfg_screen, misc_screen, rwdata_screen, debug_screen;
#ifndef DEBUG
  menu_t about_screen, thanks_screen, license_screen, notice_screen;
#endif


menu_t home_menu = {
    .type = HOME,
    .header  = &home_header,
    .body = {
      .hoffset = MAIN_OVERLAY_H_OFFSET,
      .text = &home_overlay
    },
    .arrow_position = 0,
    .current_selection = 0,
#ifndef DEBUG
  #ifdef USE_NOTICE_SECTION
    .number_selections = 12,
  #else
    .number_selections = 11,
  #endif
#else
    .number_selections = 8,
#endif
    .leaves = {
        {.id = MAIN2RES_V_OFFSET     , .arrowshape = &select_arrow, .leavetype = ISUBMENU, .submenu = &vires_screen},
        {.id = MAIN2SCALER_V_OFFSET  , .arrowshape = &select_arrow, .leavetype = ISUBMENU, .submenu = &viscaling_screen},
        {.id = MAIN2SCANLINE_V_OFFSET, .arrowshape = &select_arrow, .leavetype = ISUBMENU, .submenu = &slcfg_opt_subscreen},
        {.id = MAIN2VIPROC_V_OFFSET  , .arrowshape = &select_arrow, .leavetype = ISUBMENU, .submenu = &vicfg_screen},
        {.id = MAIN2AUDPROC_V_OFFSET , .arrowshape = &select_arrow, .leavetype = ISUBMENU, .submenu = &audcfg_screen},
        {.id = MAIN2MISC_V_OFFSET    , .arrowshape = &select_arrow, .leavetype = ISUBMENU, .submenu = &misc_screen},
        {.id = MAIN2SAVE_V_OFFSET    , .arrowshape = &select_arrow, .leavetype = ISUBMENU, .submenu = &rwdata_screen},
        {.id = MAIN2DEBUG_V_OFFSET   , .arrowshape = &select_arrow, .leavetype = ISUBMENU, .submenu = &debug_screen},
  #ifndef DEBUG
        {.id = MAIN2ABOUT_V_OFFSET   , .arrowshape = &select_arrow, .leavetype = ISUBMENU, .submenu = &about_screen},
        {.id = MAIN2THANKS_V_OFFSET  , .arrowshape = &select_arrow, .leavetype = ISUBMENU, .submenu = &thanks_screen},
        {.id = MAIN2LICENSE_V_OFFSET , .arrowshape = &select_arrow, .leavetype = ISUBMENU, .submenu = &license_screen},
    #ifdef USE_NOTICE_SECTION
        {.id = MAIN2NOTICE_V_OFFSET  , .arrowshape = &front_sel_arrow, .leavetype = ISUBMENU, .submenu = &notice_screen}
    #endif
  #endif
    }
};

menu_t vires_screen = {
    .type = CONFIG,
    .header = &resolution_header,
    .body = {
      .hoffset = RESCFG_OVERLAY_H_OFFSET,
      .text = &resolution_overlay
    },
    .parent = &home_menu,
    .arrow_position = (RESCFG_VALS_H_OFFSET - 2),
    .current_selection = 0,
    .number_selections = 6,
    .leaves = {
        {.id = RESCFG_RESOLUTION_V_OFFSET  , .arrowshape = &optval_arrow, .leavetype = ICONFIG  , .config_value   = &linex_resolution},
        {.id = RESCFG_USE_DV1_FXD_V_OFFSET , .arrowshape = &optval_arrow, .leavetype = ICONFIG  , .config_value   = &dvmode_version},
        {.id = RESCFG_USE_VGA_RES_V_OFFSET , .arrowshape = &optval_arrow, .leavetype = ICONFIG  , .config_value   = &vga_for_480p},
        {.id = RESCFG_USE_SRCSYNC_V_OFFSET , .arrowshape = &optval_arrow, .leavetype = ICONFIG  , .config_value   = &low_latency_mode},
        {.id = RESCFG_FORCE_5060_V_OFFSET  , .arrowshape = &optval_arrow, .leavetype = ICONFIG  , .config_value   = &linex_force_5060},
        {.id = RESCFG_TEST_N_APPLY_V_OFFSET, .arrowshape = &optval_arrow, .leavetype = CFG_FUNC0, .cfgfct_call_0  = &cfg_apply_new_linex},
    }
};

#define LINEX_SELECTION         0
#define DIRECTMODE_SELECTION    1
#define VGA480P_SELECTION       2
#define LLMODE_SELECTION        3
#define FORCE5060_SELECTION     4

menu_t viscaling_screen = {
    .type = CONFIG,
    .header = &scaler_header,
    .body = {
      .hoffset = SCALERCFG_OVERLAY_H_OFFSET,
      .text = &scaler_overlay
    },
    .parent = &home_menu,
    .arrow_position = (SCALERCFG_VALS_H_OFFSET - 2),
    .current_selection = 0,
    .number_selections = 11,
    .leaves = {
        {.id = SCALERCFG_V_INTERP_V_OFFSET   , .arrowshape = &optval_arrow, .leavetype = ICONFIG  , .config_value  = &interpolation_mode_vert},
        {.id = SCALERCFG_H_INTERP_V_OFFSET   , .arrowshape = &optval_arrow, .leavetype = ICONFIG  , .config_value  = &interpolation_mode_hori},
        {.id = SCALERCFG_VHSTEPS_V_OFFSET    , .arrowshape = &optval_arrow, .leavetype = ICONFIG  , .config_value  = &scaling_steps},
        {.id = SCALERCFG_IN2OUT_V_OFFSET     , .arrowshape = &optval_arrow, .leavetype = ICONFIG  , .config_value  = &scaling_selection},
        {.id = SCALERCFG_LINKVH_V_OFFSET     , .arrowshape = &optval_arrow, .leavetype = ICONFIG  , .config_value  = &link_hv_scale},
        {.id = SCALERCFG_VERTSCALE_V_OFFSET  , .arrowshape = &optval_arrow, .leavetype = CFG_FUNC4, .cfgfct_call_4 = &cfgfct_scale},
        {.id = SCALERCFG_HORISCALE_V_OFFSET  , .arrowshape = &optval_arrow, .leavetype = CFG_FUNC4, .cfgfct_call_4 = &cfgfct_scale},
        {.id = SCALERCFG_PALBOXED_V_OFFSET   , .arrowshape = &optval_arrow, .leavetype = ICONFIG  , .config_value  = &pal_boxed_mode},
        {.id = SCALERCFG_INSHIFTMODE_V_OFFSET, .arrowshape = &optval_arrow, .leavetype = ICONFIG  , .config_value  = &region_selection},
        {.id = SCALERCFG_VERTSHIFT_V_OFFSET  , .arrowshape = &optval_arrow, .leavetype = ICONFIG  , .config_value  = &vert_shift},
        {.id = SCALERCFG_HORISHIFT_V_OFFSET  , .arrowshape = &optval_arrow, .leavetype = ICONFIG  , .config_value  = &hor_shift}
    }
};

#define V_INTERP_SELECTION      0
#define H_INTERP_SELECTION      1
#define SCALING_STEPS_SELECTION 2
#define SCALING_PAGE_SELECTION  3
#define VHLINK_SELECTION        4
#define VERTSCALE_SELECTION     5
#define HORISCALE_SELECTION     6
#define PAL_BOXED_SELECTION     7
#define TIMING_PAGE_SELECTION   8
#define VERTSHIFT_SELECTION     9
#define HORSHIFT_SELECTION     10

menu_t slcfg_opt_subscreen = {
    .type = CONFIG,
    .header = &slcfg_opt_header,
    .body = {
      .hoffset = SLCFG_OVERLAY_H_OFFSET,
      .text = &slcfg_opt_overlay
    },
    .parent = &home_menu,
    .arrow_position = (SLCFG_VALS_H_OFFSET - 2),
    .current_selection = 0,
    .number_selections = 13,
    .leaves = {
        {.id = SLCFG_INPUT_OFFSET       , .arrowshape = &optval_arrow, .leavetype = ICONFIG , .config_value = &region_selection},
        {.id = SLCFG_CALC_BASE_V_OFFSET , .arrowshape = &optval_arrow, .leavetype = ICONFIG , .config_value = &sl_calc_base},
        {.id = SLCFG_HEN_V_OFFSET       , .arrowshape = &optval_arrow, .leavetype = ICONFIG , .config_value = &sl_en_hori},
        {.id = SLCFG_HTHICKNESS_V_OFFSET, .arrowshape = &optval_arrow, .leavetype = ICONFIG , .config_value = &sl_thickness_hori},
        {.id = SLCFG_HPROFILE_V_OFFSET  , .arrowshape = &optval_arrow, .leavetype = ICONFIG , .config_value = &sl_profile_hori},
        {.id = SLCFG_HSTR_V_OFFSET      , .arrowshape = &optval_arrow, .leavetype = ICONFIG , .config_value = &sl_str_hori},
        {.id = SLCFG_HHYB_STR_V_OFFSET  , .arrowshape = &optval_arrow, .leavetype = ICONFIG , .config_value = &slhyb_str_hori},
        {.id = SLCFG_VEN_V_OFFSET       , .arrowshape = &optval_arrow, .leavetype = ICONFIG , .config_value = &sl_en_vert},
        {.id = SLCFG_VLINK_OFFSET       , .arrowshape = &optval_arrow, .leavetype = ICONFIG , .config_value = &sl_link_h2v},
        {.id = SLCFG_VTHICKNESS_V_OFFSET, .arrowshape = &optval_arrow, .leavetype = ICONFIG , .config_value = &sl_thickness_vert},
        {.id = SLCFG_VPROFILE_V_OFFSET  , .arrowshape = &optval_arrow, .leavetype = ICONFIG , .config_value = &sl_profile_vert},
        {.id = SLCFG_VSTR_V_OFFSET      , .arrowshape = &optval_arrow, .leavetype = ICONFIG , .config_value = &sl_str_vert},
        {.id = SLCFG_VHYB_STR_V_OFFSET  , .arrowshape = &optval_arrow, .leavetype = ICONFIG , .config_value = &slhyb_str_vert}
    }
};

#define SL_VLINK_SELECTION           8
#define SL_HORI_TO_VERT_OFFSET       6

menu_t vicfg_screen = {
    .type = CONFIG,
    .header = &vicfg_header,
    .body = {
      .hoffset = VICFG_OVERLAY_H_OFFSET,
      .text = &vicfg_overlay
    },
    .parent = &home_menu,
    .arrow_position = (VICFG_VALS_H_OFFSET - 2),
    .current_selection = 0,
#ifdef HDR_TESTING
    .number_selections = 9,
#else
    .number_selections = 8,
#endif
    .leaves = {
        {.id = VICFG_DEINTERL_V_OFFSET    , .arrowshape = &optval_arrow, .leavetype = ICONFIG , .config_value = &deinterlace_mode},
        {.id = VICFG_GAMMA_V_OFFSET       , .arrowshape = &optval_arrow, .leavetype = ICONFIG , .config_value = &gamma_lut},
        {.id = VICFG_COLORSPACE_V_OFFSET  , .arrowshape = &optval_arrow, .leavetype = ICONFIG , .config_value = &color_space},
        {.id = VICFG_LIMITEDRANGE_V_OFFSET, .arrowshape = &optval_arrow, .leavetype = ICONFIG , .config_value = &limited_colorspace},
#ifdef HDR_TESTING
        {.id = VICFG_HDR10INJ_V_OFFSET    , .arrowshape = &optval_arrow, .leavetype = ICONFIG , .config_value = &hdr10_injection},
#endif
        {.id = VICFG_DEBLUR_V_OFFSET      , .arrowshape = &optval_arrow, .leavetype = ICONFIG , .config_value = &deblur_mode},
        {.id = VICFG_PCDEBLUR_V_OFFSET    , .arrowshape = &optval_arrow, .leavetype = ICONFIG , .config_value = &deblur_mode_powercycle},
        {.id = VICFG_16BITMODE_V_OFFSET   , .arrowshape = &optval_arrow, .leavetype = ICONFIG , .config_value = &mode16bit},
        {.id = VICFG_PC16BITMODE_V_OFFSET , .arrowshape = &optval_arrow, .leavetype = ICONFIG , .config_value = &mode16bit_powercycle}
    }
};

#define DEINTERLACE_SELECTION       0
#ifdef HDR_TESTING
  #define DEBLUR_CURRENT_SELECTION    5
  #define DEBLUR_POWERCYCLE_SELECTION 6
  #define M16BIT_CURRENT_SELECTION    7
  #define M16BIT_POWERCYCLE_SELECTION 8
#else
  #define DEBLUR_CURRENT_SELECTION    4
  #define DEBLUR_POWERCYCLE_SELECTION 5
  #define M16BIT_CURRENT_SELECTION    6
  #define M16BIT_POWERCYCLE_SELECTION 7
#endif


menu_t audcfg_screen = {
    .type = CONFIG,
    .header = &audcfg_header,
    .body = {
      .hoffset = AUD_OVERLAY_H_OFFSET,
      .text = &audcfg_overlay
    },
    .parent = &home_menu,
    .arrow_position = (AUD_VALS_H_OFFSET - 2),
    .current_selection = 0,
    .number_selections = 5,
    .leaves = {
        {.id = AUD_FILTER_BYPASS_V_OFFSET, .arrowshape = &optval_arrow, .leavetype = ICONFIG , .config_value = &audio_fliter_bypass},
        {.id = AUD_MUTE_V_OFFSET         , .arrowshape = &optval_arrow, .leavetype = ICONFIG , .config_value = &audio_mute},
        {.id = AUD_SWAP_LR_V_OFFSET      , .arrowshape = &optval_arrow, .leavetype = ICONFIG , .config_value = &audio_swap_lr},
        {.id = AUD_AMP_V_OFFSET          , .arrowshape = &optval_arrow, .leavetype = ICONFIG , .config_value = &audio_amp},
        {.id = AUD_SPDIF_EN_V_OFFSET     , .arrowshape = &optval_arrow, .leavetype = ICONFIG , .config_value = &audio_spdif_en}
    }
};

menu_t misc_screen = {
    .type = CONFIG,
    .header = &misc_header,
    .body = {
      .hoffset = MISC_OVERLAY_H_OFFSET,
      .text = &misc_overlay,
    },
    .parent = &home_menu,
    .arrow_position = (MISC_VALS_H_OFFSET - 2),
    .current_selection = 0,
    .number_selections = 7,
    .leaves = {
        {.id = MISC_IGR_RESET_V_OFFSET     , .arrowshape = &optval_arrow, .leavetype = ICONFIG  , .config_value  = &igr_reset},
        {.id = MISC_IGR_DEBLUR_V_OFFSET    , .arrowshape = &optval_arrow, .leavetype = ICONFIG  , .config_value  = &igr_deblur},
        {.id = MISC_IGR_16BITMODE_V_OFFSET , .arrowshape = &optval_arrow, .leavetype = ICONFIG  , .config_value  = &igr_16bitmode},
        {.id = MISC_RST_MASKING_V_OFFSET   , .arrowshape = &optval_arrow, .leavetype = ICONFIG  , .config_value  = &rst_masking},
        {.id = MISC_SWAP_LED_V_OFFSET      , .arrowshape = &optval_arrow, .leavetype = ICONFIG  , .config_value  = &swap_led},
        {.id = MISC_DEBUGVITIMEOUT_V_OFFSET, .arrowshape = &optval_arrow, .leavetype = ICONFIG  , .config_value  = &debug_vtimeout},
        {.id = MISC_LUCKY_1440P_V_OFFSET   , .arrowshape = &select_arrow, .leavetype = CFG_FUNC1, .cfgfct_call_1 = &cfgfct_unlock1440p}
    }
};

menu_t rwdata_screen = {
    .type = RWDATA,
    .header = &rwdata_header,
    .body = {
      .hoffset = RWDATA_OVERLAY_H_OFFSET,
      .text = &rwdata_overlay
    },
    .parent = &home_menu,
    .arrow_position = (RWDATA_VALS_H_OFFSET - 2),
    .current_selection = 0,
#ifndef DEBUG
    .number_selections = 8,
    .leaves = {
        {.id = RWDATA_AUTOSAVE_V_OFFSET        , .arrowshape = &optval_arrow, .leavetype = ICONFIG       , .config_value = &autosave},
        {.id = RWDATA_SAVE_FL_V_OFFSET         , .arrowshape = &select_arrow, .leavetype = INFO_RET_FUNC1, .sys_fun_1    = &cfg_save_to_flash},
        {.id = RWDATA_LOAD_FL_V_OFFSET         , .arrowshape = &select_arrow, .leavetype = INFO_RET_FUNC1, .sys_fun_1    = &cfg_load_from_flash},
        {.id = RWDATA_CPYCFG_DIRECTION_V_OFFSET, .arrowshape = &optval_arrow, .leavetype = ICONFIG       , .config_value = &copy_direction},
        {.id = RWDATA_CPYCFG_FUNCTION_V_OFFSET , .arrowshape = &select_arrow, .leavetype = INFO_RET_FUNC0, .sys_fun_0    = &cfg_copy_ntsc2pal},
        {.id = RWDATA_FALLBACKRES_V_OFFSET     , .arrowshape = &optval_arrow, .leavetype = ICONFIG       , .config_value = &fallback_resolution},
        {.id = RWDATA_FALLBACKTRIG_V_OFFSET    , .arrowshape = &optval_arrow, .leavetype = ICONFIG       , .config_value = &fallback_trigger},
        {.id = RWDATA_FALLBACKMENU_V_OFFSET    , .arrowshape = &optval_arrow, .leavetype = ICONFIG       , .config_value = &fallback_menu}
    }
#else
    .number_selections = 7,
        .leaves = {
            {.id = RWDATA_SAVE_FL_V_OFFSET         , .arrowshape = &select_arrow, .leavetype = INFO_RET_FUNC1, .sys_fun_1    = &cfg_save_to_flash},
            {.id = RWDATA_LOAD_FL_V_OFFSET         , .arrowshape = &select_arrow, .leavetype = INFO_RET_FUNC1, .sys_fun_1    = &cfg_load_from_flash},
            {.id = RWDATA_CPYCFG_DIRECTION_V_OFFSET, .arrowshape = &optval_arrow, .leavetype = ICONFIG       , .config_value = &copy_direction},
            {.id = RWDATA_CPYCFG_FUNCTION_V_OFFSET , .arrowshape = &select_arrow, .leavetype = INFO_RET_FUNC0, .sys_fun_0    = &cfg_copy_ntsc2pal},
            {.id = RWDATA_FALLBACKRES_V_OFFSET     , .arrowshape = &optval_arrow, .leavetype = ICONFIG       , .config_value = &fallback_resolution},
            {.id = RWDATA_FALLBACKTRIG_V_OFFSET    , .arrowshape = &optval_arrow, .leavetype = ICONFIG       , .config_value = &fallback_trigger},
            {.id = RWDATA_FALLBACKMENU_V_OFFSET    , .arrowshape = &optval_arrow, .leavetype = ICONFIG       , .config_value = &fallback_menu}
        }
#endif
};

menu_t debug_screen = {
    .type = N64DEBUG,
    .header = &n64debug_header,
    .body = {
      .hoffset = N64DEBUG_OVERLAY_H_OFFSET,
      .text = &n64debug_overlay
    },
    .parent = &home_menu,
    .arrow_position = (N64DEBUG_FUNC_H_OFFSET - 2),
    .current_selection = 0,
    .number_selections = 2,
    .leaves = {
        {.id = N64DEBUG_RESYNC_VI_PL_V_OFFSET, .arrowshape = &select_arrow, .leavetype = INFO_RET_FUNC0, .sys_fun_0 = &resync_vi_pipeline},
        {.id = N64DEBUG_LOCK_MENU_V_OFFSET   , .arrowshape = &select_arrow, .leavetype = ICONFIG, .config_value = &lock_menu}
    }
};

#ifndef DEBUG
  menu_t about_screen = {
     .type = TEXT,
     .header = &about_header,
     .body = {
       .hoffset = 0,
       .text = &about_overlay
     },
     .parent = &home_menu
  };

  menu_t thanks_screen = {
     .type = TEXT,
     .header = &thanks_header,
     .body = {
       .hoffset = 0,
       .text = &thanks_overlay
     },
     .parent = &home_menu
  };

  menu_t license_screen = {
     .type = TEXT,
     .header = &license_header,
     .body = {
       .hoffset = 0,
       .text = &license_overlay
     },
     .parent = &home_menu
  };

  #ifdef USE_NOTICE_SECTION
    menu_t notice_screen = {
       .type = TEXT,
       .header = &notice_header,
       .body = {
         .hoffset = 0,
         .text = &notice_overlay
       },
       .parent = &home_menu
    };
  #endif
#endif

static inline bool_t is_vires_screen (menu_t *menu)
  {  return (menu == &vires_screen); }
static inline bool_t is_viscaling_screen (menu_t *menu)
  {  return (menu == &viscaling_screen); }
static inline bool_t is_slcfg_screen (menu_t *menu)
  {  return (menu == &slcfg_opt_subscreen); }
static inline bool_t is_vicfg_h2v_sl_are_linked ()
  {  return (bool_t) cfg_get_value(&sl_link_h2v,0); }
static inline bool_t is_vicfg_screen (menu_t *menu)
  {  return (menu == &vicfg_screen); }
static inline bool_t is_rwdata_screen (menu_t *menu)
  {  return (menu == &rwdata_screen); }
#ifndef DEBUG
  static inline bool_t is_about_screen (menu_t *menu)
    {  return (menu == &about_screen); }
#endif


void val2txt_func(alt_u16 v) { sprintf(szText,"%u", v); };
void val2txt_4u_func(alt_u16 v) { sprintf(szText,"%4u", v); };
void val2txt_5b_binaryoffset_func(alt_u16 v) { if (v & 0x10) sprintf(szText," %2u", (v&0xF)); else sprintf(szText,"-%2u", (v^0xF)+1); };
void val2txt_scale_sel_func(alt_u16 v) {
  alt_u8 h_offset = 6;
  if (v >= NUM_SCALING_MODES) {
    h_offset = h_offset + 2;
    v = v - NUM_SCALING_MODES;
    if (v > NTSC_LAST_SCALING_MODE) {
      sprintf(szText,"PAL.%s  ",scanmode == INTERLACED ? "i" : "p");
      v = v - PAL_DIRECT;
    } else {
      sprintf(szText,"NTSC.%s  ",scanmode == INTERLACED ? "i" : "p");
      h_offset++;
    }
  } else {
    if (v > NTSC_LAST_SCALING_MODE) {
      sprintf(szText,"PAL  ");
      v = v - PAL_DIRECT;
    } else {
      sprintf(szText,"NTSC  ");
      h_offset++;
    }
  }
  alt_u8 force5060_mode = cfg_get_value(&linex_force_5060,0);
  if ((v == LineX2) && ((palmode && (force5060_mode != FORCE_60HZ)) || (force5060_mode == FORCE_50HZ)))
    sprintf(&szText[h_offset],Resolution576pReplacement);
  else
    if ((v == DIRECT) & (h_offset > 7)) sprintf(&szText[h_offset],DV_Versions[cfg_get_value(&dvmode_version,0)]);
    else sprintf(&szText[h_offset],Resolutions[v]);
};

void val2txt_scale_func(alt_u16 v, bool_t use_vertical) {
  alt_u8 idx = cfg_scale_is_predefined(v,use_vertical);
  if (!use_vertical && hor_hires) {
    if (idx & 0x01) idx = PREDEFINED_SCALE_STEPS;
    else idx = idx/2;
  }
  if (idx < PREDEFINED_SCALE_STEPS && (scaling_menu != NTSC_DIRECT) && (scaling_menu != PAL_DIRECT)) {
    if (!use_vertical && hor_hires) sprintf(szText,"%4u %s", v, PredefScaleStepsHalf[idx]);
    else sprintf(szText,"%4u %s", v, PredefScaleSteps[idx]);
  } else {
    sprintf(szText,"%4u", v);
  }
};
void audioamp2txt_func(alt_u16 v) { if (v < 19) sprintf(szText,"-%02udB",19-v); else sprintf(szText," %02udB",v-19); };
void flag2set_func(alt_u16 v) { sprintf(szText,"[ ]"); if (v) szText[1] = (char) CHECKBOX_TICK; };
void scanline_str2txt_func(alt_u16 v) { v++; sprintf(szText,"%3u.%02u%%", (v*625)/100, 25*(v&3)); };
void scanline_hybrstr2txt_func(alt_u16 v) { sprintf(szText,"%3u.%02u%%", (v*625)/100, 25*(v&3)); };
void gamma2txt_func(alt_u16 v) { sprintf(szText,"%u.%02u", v > 4, 5* v + 75 - (100 * (v > 4))); };

bool_t apply_sl_vert_negoffset(menu_t* current_menu) {
  return (is_slcfg_screen(current_menu) && is_vicfg_h2v_sl_are_linked());
}

void print_cr_info() {
  vd_clear_info();
  vd_print_string(VD_INFO,COPYRIGHT_H_OFFSET,COPYRIGHT_V_OFFSET,FONTCOLOR_DARKORANGE,copyright_note);
}

void print_current_timing_mode()
{
  print_cr_info();
  val2txt_scale_sel_func(scaling_n64adv+NUM_SCALING_MODES); // addition is a hack to trigger .p and .i print
  vd_print_string(VD_INFO,0,0,FONTCOLOR_NAVAJOWHITE,&szText[0]);

  alt_u8 hoffset = strlen(&szText[0]);
  alt_u16 hscale = cfg_get_value(&hor_scale,0);
  alt_u16 vscale = cfg_get_value(&vert_scale,0);

  if (scaling_n64adv != NTSC_DIRECT && scaling_n64adv != PAL_DIRECT) {
    sprintf(szText,"(%d x %d)",hscale,vscale);
    szText[6-(hscale<1000)] = (char) CHECKBOX_TICK;
    vd_print_string(VD_INFO,hoffset + 1,0,FONTCOLOR_NAVAJOWHITE,&szText[0]);
  }
}

void print_ctrl_data() {
  print_cr_info();
  if ((n64adv_state & N64ADV_INPUT_CTRL_DETECTED_GETMASK) >> N64ADV_INPUT_CTRL_DETECTED_OFFSET) {
    sprintf(szText,"Ctrl. data: 0x%08x",(uint) ctrl_data);
    vd_print_string(VD_INFO,0,0,FONTCOLOR_NAVAJOWHITE,&szText[0]);
  } else {
    vd_print_string(VD_INFO,0,0,FONTCOLOR_RED,NoCtrlDetected);
  }
}

void print_confirm_info(alt_u8 type) {
  if (type > 4) return;
  if (type > 2) {
    vd_print_string(VD_INFO,VD_WIDTH - CONFIRM_H_LENGTH - CONFIRM_BTN_H_LENGTH - 1,0,confirm_messages_color[3],confirm_messages[type]);
    vd_print_string(VD_INFO,VD_WIDTH - CONFIRM_BTN_H_LENGTH,0,confirm_messages_color[3],btn_fct_confirm_overlay);
  } else {
    vd_print_string(VD_INFO,VD_WIDTH - strlen(confirm_messages[type]),0,confirm_messages_color[type],confirm_messages[type]);
  }
}

void print_linex_settings() {
  alt_u8 ref_val, font_color;

  alt_u8 cfg_val = sysconfig.cfg_word_def[EXTCFG0]->cfg_word_val;
  alt_u8 cfg_ref_val = sysconfig.cfg_word_def[EXTCFG0]->cfg_ref_word_val;

  alt_u8 val_linex = (cfg_val & CFG_RESOLUTION_GETMASK);
  alt_u8 val_dv = (cfg_val & CFG_DVMODE_VERSION_GETMASK) >> CFG_DVMODE_VERSION_OFFSET;
  alt_u8 val_vga = (cfg_val & CFG_VGAFOR480P_GETMASK) >> CFG_VGAFOR480P_OFFSET;
  alt_u8 val_llm;
  if (val_linex == DIRECT) val_llm = 1;
  else                     val_llm = (cfg_val & CFG_LOWLATENCYMODE_GETMASK) >> CFG_LOWLATENCYMODE_OFFSET;
  alt_u8 val_5060;
  if (val_llm) val_5060 = AUTO_HZ;
  else         val_5060 = (cfg_val & CFG_FORCE_5060_GETMASK) >> CFG_FORCE_5060_OFFSET;

  // LineX output
  ref_val = (cfg_ref_val & CFG_RESOLUTION_GETMASK);
  font_color = val_linex == ref_val ? FONTCOLOR_WHITE : FONTCOLOR_YELLOW;
  vd_clear_lineend(VD_TEXT,vires_screen.arrow_position,RESCFG_CURRENT_RESOLUTION_V_OFFSET);
  if (val_linex == DIRECT) {
    if (val_linex == ref_val) {
      ref_val = (cfg_ref_val & CFG_DVMODE_VERSION_GETMASK) >> CFG_DVMODE_VERSION_OFFSET;
      font_color = val_dv == ref_val ? FONTCOLOR_WHITE : FONTCOLOR_YELLOW;
    }
    vd_print_string(VD_TEXT,vires_screen.arrow_position,RESCFG_CURRENT_RESOLUTION_V_OFFSET,font_color,dvmode_version.value_string[val_dv]);
  } else {
    vd_print_string(VD_TEXT,vires_screen.arrow_position,RESCFG_CURRENT_RESOLUTION_V_OFFSET,font_color,linex_resolution.value_string[val_linex]);
  }

  if (val_linex == LineX2) {
    if ((palmode && (val_5060 != FORCE_60HZ))  || (!palmode && (val_5060 == FORCE_50HZ)))
      vd_print_string(VD_TEXT,vires_screen.arrow_position,RESCFG_CURRENT_RESOLUTION_V_OFFSET,font_color,Resolution576pReplacement);
    ref_val = (cfg_ref_val & CFG_VGAFOR480P_GETMASK) >> CFG_VGAFOR480P_OFFSET;
    font_color = val_vga == ref_val ? FONTCOLOR_WHITE : FONTCOLOR_YELLOW;
    vd_print_string(VD_TEXT,vires_screen.arrow_position + 5,RESCFG_CURRENT_RESOLUTION_V_OFFSET,font_color,VGAFLAG[val_vga]);
  }

  // LLM
  if (val_linex == DIRECT) ref_val = 1;
  else                     ref_val = (cfg_ref_val & CFG_LOWLATENCYMODE_GETMASK) >> CFG_LOWLATENCYMODE_OFFSET;
  font_color = val_llm == ref_val ? FONTCOLOR_WHITE : FONTCOLOR_YELLOW;
  vd_clear_lineend(VD_TEXT,vires_screen.arrow_position,RESCFG_CURRENT_SRCSYNC_V_OFFSET);
  vd_print_string(VD_TEXT,vires_screen.arrow_position,RESCFG_CURRENT_SRCSYNC_V_OFFSET,font_color,OffOn[val_llm]);

  // Hz mode
  if (val_llm) ref_val = AUTO_HZ;
  else         ref_val = (cfg_ref_val & CFG_FORCE_5060_GETMASK) >> CFG_FORCE_5060_OFFSET;
  font_color = val_5060 == ref_val ? FONTCOLOR_WHITE : FONTCOLOR_YELLOW;
  vd_clear_lineend(VD_TEXT,vires_screen.arrow_position,RESCFG_CURRENT_5060_V_OFFSET);
  vd_print_string(VD_TEXT,vires_screen.arrow_position,RESCFG_CURRENT_5060_V_OFFSET,font_color,linex_force_5060.value_string[val_5060]);
}

void print_1440p_unlock_info() {
  vd_clear_info();
  vd_print_string(VD_INFO,VD_WIDTH - UNLOCK1140P_H_LENGTH,0,confirm_messages_color[0],Unlock_1440p_Message);;
}

//void print_fw_info() {
//  vd_clear_info_area(COPYRIGHT_H_OFFSET,VD_WIDTH-1,0,0);
//  vd_print_string(VD_INFO,COPYRIGHT_H_OFFSET,COPYRIGHT_V_OFFSET,FONTCOLOR_DARKORANGE,copyright_note);
//}

void print_fw_version()
{
  sprintf(szText,"%1d.%02d.%d",FW_MOD,FW_MAIN,FW_SUB);
  vd_print_string(VD_TEXT,VERSION_H_OFFSET,VERSION_V_OFFSET,FONTCOLOR_WHITE,&szText[0]);

  vd_print_string(VD_TEXT,VERSION_H_OFFSET,VERSION_V_OFFSET+1,FONTCOLOR_WHITE,pcb_rev[get_pcb_version()]);

  sprintf(szText,"0x%08x%08x",(uint) get_chip_id(1),(uint) get_chip_id(0));
  vd_print_string(VD_TEXT,VERSION_H_OFFSET,VERSION_V_OFFSET+2,FONTCOLOR_WHITE,&szText[0]);
}

void print_game_id()
{
  if (game_id_valid) {
    sprintf(szText,"Game-ID: %s",game_id_txt);
    vd_print_string(VD_TEXT,19,VD_TXT_HEIGHT-1,FONTCOLOR_WHITE,&szText[0]);
  } else {
    vd_clear_lineend(VD_TEXT,19,VD_TXT_HEIGHT-1);
    vd_print_string(VD_TEXT,27,VD_TXT_HEIGHT-1,FONTCOLOR_GREY,NoGameIDDetected);
  }
}

updateaction_t modify_menu(cmd_t command, menu_t* *current_menu)
{

  updateaction_t todo = NON;

  // check for some overlay modifying commands first
  switch (command) {
    case CMD_MUTE_MENU:
      return MENU_MUTE;
    case CMD_UNMUTE_MENU:
      return MENU_UNMUTE;
    case CMD_CLOSE_MENU:
      while ((*current_menu)->parent) {
        (*current_menu)->current_selection = 0;
        *current_menu = (*current_menu)->parent;
      }
      (*current_menu)->current_selection = 0;
      return MENU_CLOSE;
    case CMD_MENU_BACK:
      (*current_menu)->current_selection = 0;
      if ((*current_menu)->parent) {
        *current_menu = (*current_menu)->parent;
        todo = NEW_OVERLAY;
      } else {
        return MENU_CLOSE;
      }
      break;
    case CMD_MENU_PAGE_RIGHT:
      if (is_viscaling_screen(*current_menu)){
        if ((*current_menu)->current_selection >= SCALING_PAGE_SELECTION && (*current_menu)->current_selection < TIMING_PAGE_SELECTION) {
          cfg_inc_value(&scaling_selection);
          todo = NEW_SELECTION;
        }
//        if ((*current_menu)->current_selection >= TIMING_PAGE_SELECTION && (*current_menu)->current_selection <= HORSHIFT_SELECTION) {
        if ((*current_menu)->current_selection >= TIMING_PAGE_SELECTION) {
          cfg_inc_value(&region_selection);
          todo = NEW_SELECTION;
        }
      }
      if (is_slcfg_screen(*current_menu)) {
        cfg_inc_value(&region_selection);
        todo = NEW_SELECTION;
      }
      break;
    case CMD_MENU_PAGE_LEFT:
      if (is_viscaling_screen(*current_menu)){
        if ((*current_menu)->current_selection >= SCALING_PAGE_SELECTION && (*current_menu)->current_selection < TIMING_PAGE_SELECTION) {
          cfg_dec_value(&scaling_selection);
          todo = NEW_SELECTION;
        }
        if ((*current_menu)->current_selection >= TIMING_PAGE_SELECTION) {
          cfg_dec_value(&region_selection);
          todo = NEW_SELECTION;
        }
      }
      if (is_slcfg_screen(*current_menu)) {
        cfg_dec_value(&region_selection);
        todo = NEW_SELECTION;
      }
      break;
    default:
      break;
  }

  // if current menu is text, nothing else but modifying commands are relevant
  if ((*current_menu)->type == TEXT)
    return NON;

  // check for up and down
  switch (command) {
    case CMD_MENU_DOWN:
      (*current_menu)->current_selection++;
      if ((*current_menu)->current_selection == (*current_menu)->number_selections)
        (*current_menu)->current_selection = 0;
      todo = NEW_SELECTION;
      break;
    case CMD_MENU_UP:
      if ((*current_menu)->current_selection == 0)
        (*current_menu)->current_selection =  (*current_menu)->number_selections - 1;
      else
        (*current_menu)->current_selection--;
      todo = NEW_SELECTION;
      break;
    default:
      break;
  }

  alt_u8 current_sel = (*current_menu)->current_selection;

  // check for entering a new submenu if possible
  if (((*current_menu)->leaves[current_sel].leavetype == ISUBMENU) &&
      ((command == CMD_MENU_RIGHT) || (command == CMD_MENU_ENTER))) {
    if ((*current_menu)->leaves[current_sel].submenu) { // check for existing submenu
      *current_menu = (*current_menu)->leaves[current_sel].submenu;
      todo = NEW_OVERLAY;
    }
  }

  current_sel = (*current_menu)->current_selection;

  // menu specific modifications
  if (apply_sl_vert_negoffset(*current_menu) && current_sel > SL_VLINK_SELECTION){
    current_sel -= SL_HORI_TO_VERT_OFFSET;
  }

  if (command == CMD_NON || todo == NEW_OVERLAY || todo == NEW_SELECTION) { // end by end of this if clause if we have either no command, new overlay or a new selection
    if (is_vires_screen(*current_menu)) {
      if (cfg_get_value(&linex_resolution,0) == DIRECT) {
        if ((current_sel == VGA480P_SELECTION) || (current_sel == FORCE5060_SELECTION))
          (*current_menu)->current_selection = (command == CMD_MENU_UP) ? VGA480P_SELECTION - 1 : FORCE5060_SELECTION + 1;
      } else {
        if (current_sel == DIRECTMODE_SELECTION) current_sel = (command == CMD_MENU_UP) ? DIRECTMODE_SELECTION - 1 : DIRECTMODE_SELECTION + 1;
        if ((cfg_get_value(&linex_resolution,0) != LineX2) && (current_sel == VGA480P_SELECTION)) current_sel = (command == CMD_MENU_UP) ? DIRECTMODE_SELECTION - 1 : VGA480P_SELECTION + 1;
        if ((cfg_get_value(&low_latency_mode,0) == ON) && (current_sel == FORCE5060_SELECTION)) current_sel = (command == CMD_MENU_UP) ? FORCE5060_SELECTION - 1 : FORCE5060_SELECTION + 1;
        (*current_menu)->current_selection = current_sel;
      }
    }

    if (is_viscaling_screen(*current_menu)) {
      if (((scaling_menu == NTSC_DIRECT) || (scaling_menu == PAL_DIRECT)) &&
          (current_sel > SCALING_PAGE_SELECTION) && (current_sel < PAL_BOXED_SELECTION)) {
        (*current_menu)->current_selection = ((todo == NEW_OVERLAY) || (command == CMD_MENU_UP)) ? SCALING_PAGE_SELECTION : PAL_BOXED_SELECTION;
      }
    }

    if (command == CMD_NON) return NEW_SELECTION;
    return todo;
  }

  // check for configuration change
  if ((*current_menu)->leaves[current_sel].leavetype == ICONFIG) {
    switch (command) {
      case CMD_MENU_RIGHT:
        cfg_inc_value((*current_menu)->leaves[current_sel].config_value);
        todo = NEW_CONF_VALUE;
        break;
      case CMD_MENU_LEFT:
        cfg_dec_value((*current_menu)->leaves[current_sel].config_value);
        todo = NEW_CONF_VALUE;
        break;
      default:
        break;
    }

    // again some menu specific adaptations
    if (todo == NEW_CONF_VALUE) {
      if (is_vires_screen(*current_menu) && (unlock_1440p == FALSE) && (cfg_get_value(&linex_resolution,0) > LineX5))
              cfg_set_value(&linex_resolution,(command == CMD_MENU_RIGHT) ? DIRECT : LineX5);
      if (is_viscaling_screen((*current_menu)) &&
          ((current_sel == VERTSHIFT_SELECTION) || (current_sel == HORSHIFT_SELECTION)) &&
          (cfg_get_value((*current_menu)->leaves[current_sel].config_value,0) == 0)) { // all-zero not allowed for vert./hor. shift
        if (command == CMD_MENU_RIGHT) cfg_inc_value((*current_menu)->leaves[current_sel].config_value);
        else                           cfg_dec_value((*current_menu)->leaves[current_sel].config_value);
      }
    }
    return todo;
  }

  // check for functions embedded in menu
  if (((command == CMD_MENU_RIGHT) || (command == CMD_MENU_LEFT)) &&
      ((*current_menu)->leaves[current_sel].leavetype == CFG_FUNC4)) { // at the moment only used in scaling menu for horizontal and vertical scale
    (*current_menu)->leaves[current_sel].cfgfct_call_4(command,current_sel==VERTSCALE_SELECTION,1,0);
    cfg_scale_v2h_update(current_sel==VERTSCALE_SELECTION);
    return NEW_CONF_VALUE;
  }

  if ((command == CMD_MENU_RIGHT) || (command == CMD_MENU_ENTER)) {
    if ((*current_menu)->leaves[current_sel].leavetype == CFG_FUNC0) {
      (*current_menu)->leaves[current_sel].cfgfct_call_0();  // at the moment only used in resolution menu, so this is correct
      return NEW_CONF_VALUE;
    }
    if ((*current_menu)->leaves[current_sel].leavetype == CFG_FUNC1) {
      (*current_menu)->leaves[current_sel].cfgfct_call_1(1);  // at the moment only used for unlock 1440p, so this is correct
      return NEW_CONF_VALUE;
    }
    if ((*current_menu)->leaves[current_sel].leavetype >= INFO_RET_FUNC0) {
      int retval = 0;
      if ((*current_menu)->leaves[current_sel].leavetype == INFO_RET_FUNC0) retval = (*current_menu)->leaves[current_sel].sys_fun_0();
      if ((*current_menu)->leaves[current_sel].leavetype == INFO_RET_FUNC1) retval = (*current_menu)->leaves[current_sel].sys_fun_1(1);
      return (retval == 0                     ? CONFIRM_OK  :
              retval == -CFG_FLASH_SAVE_ABORT ? CONFIRM_ABORTED :
                                                CONFIRM_FAILED);
    }
  }

  return NON;
}

void print_overlay(menu_t* current_menu)
{
  vd_clear_hdr();
  vd_clear_txt();

  if (current_menu->header) vd_wr_hdr(FONTCOLOR_DARKORANGE,*current_menu->header);
  vd_print_string(VD_TEXT,current_menu->body.hoffset,0,FONTCOLOR_WHITE,*current_menu->body.text);

  #ifndef DEBUG
    if (is_about_screen(current_menu)) print_fw_version();
  #endif
}

void print_selection_arrow(menu_t* current_menu)
{
  alt_u8 h_l_offset = current_menu->arrow_position;
  alt_u8 v_run, v_offset;
  const char *clear = "  ";

  for (v_run = 0; v_run < current_menu->number_selections; v_run++)
    if (current_menu->leaves[v_run].arrowshape != NULL) {
      v_offset   = current_menu->leaves[v_run].id;
      if (v_run == current_menu->current_selection) {
        vd_print_char(VD_TEXT,h_l_offset  ,v_offset,FONTCOLOR_WHITE,(char) current_menu->leaves[v_run].arrowshape->left);
        vd_print_char(VD_TEXT,h_l_offset+1,v_offset,FONTCOLOR_WHITE,(char) current_menu->leaves[v_run].arrowshape->right);
      } else {
        vd_print_string(VD_TEXT,h_l_offset  ,v_offset,FONTCOLOR_WHITE,clear);
      }
    }
}

int update_cfg_screen(menu_t* current_menu)
{
  if (current_menu->type == HOME || current_menu->type == TEXT) return -1;

  alt_u8 h_l_offset = current_menu->arrow_position + 3;
  alt_u8 v_run, v_offset;
  alt_u8 font_color;
  alt_u16 val_select, ref_val_select;
  bool_t val_is_ref;

  bool_t use_direct_mode = (scaling_menu == NTSC_DIRECT) || (scaling_menu == PAL_DIRECT);

  bool_t use_sl_vert_negoffset = apply_sl_vert_negoffset(current_menu);
  alt_u8 v_run_negoffset = 0;

  for (v_run = 0; v_run < current_menu->number_selections - v_run_negoffset; v_run++) {
    v_offset   = current_menu->leaves[v_run + v_run_negoffset].id;

    if (use_sl_vert_negoffset && v_run > SL_VLINK_SELECTION) {
        use_sl_vert_negoffset = FALSE;
      v_run -= SL_HORI_TO_VERT_OFFSET;
      v_run_negoffset = SL_HORI_TO_VERT_OFFSET;
    }

    vd_clear_lineend(VD_TEXT,h_l_offset,v_offset);
    bool_t print_szText = FALSE;
    switch (current_menu->leaves[v_run].leavetype) {
      case ICONFIG:
        val_select = cfg_get_value(current_menu->leaves[v_run].config_value,0);
        ref_val_select = cfg_get_value(current_menu->leaves[v_run].config_value,1);
        if (is_vicfg_screen(current_menu)){
          if (v_run == DEBLUR_CURRENT_SELECTION    || v_run == M16BIT_CURRENT_SELECTION   ) ref_val_select = val_select;
          if (v_run == DEBLUR_POWERCYCLE_SELECTION || v_run == M16BIT_POWERCYCLE_SELECTION) ref_val_select = cfg_get_value(current_menu->leaves[v_run-1].config_value,1);
        }


        val_is_ref = (val_select == ref_val_select);
        font_color = val_is_ref ? FONTCOLOR_WHITE : FONTCOLOR_YELLOW;

        // check res screen
        if (is_vires_screen(current_menu)) {
          font_color = FONTCOLOR_WHITE;
          if (cfg_get_value(&linex_resolution,0) == DIRECT) {
            if ((v_run == FORCE5060_SELECTION) || (v_run == LLMODE_SELECTION)) {
              val_select = (v_run == LLMODE_SELECTION);
              font_color = FONTCOLOR_GREY;
            }
          } else {
            if (v_run == DIRECTMODE_SELECTION)  font_color = FONTCOLOR_GREY;
            if ((cfg_get_value(&low_latency_mode,0) == ON) && (v_run == FORCE5060_SELECTION)) {
              val_select = 0;
              font_color = FONTCOLOR_GREY;
            }
          }
          if ((cfg_get_value(&linex_resolution,0) != LineX2) && (v_run == VGA480P_SELECTION)) font_color = FONTCOLOR_GREY;
        }

        // check scaling menu
        if (is_viscaling_screen(current_menu) && use_direct_mode) {
          if (v_run == VHLINK_SELECTION) {
            val_select = CFG_LINK_HV_SCALE_DEFAULTVAL_FIXED;
            font_color = FONTCOLOR_GREY;
          }
          if ((v_run == VERTSCALE_SELECTION) || (v_run == HORISCALE_SELECTION)) {
            font_color = FONTCOLOR_GREY;
          }
        }

        if (current_menu->leaves[v_run].config_value->cfg_disp_type == DISP_BUF_FUNC) {
          current_menu->leaves[v_run].config_value->val2char_func(val_select);
          print_szText = TRUE;
        } else {
          vd_print_string(VD_TEXT,h_l_offset,v_offset,font_color,current_menu->leaves[v_run].config_value->value_string[val_select]);
        }
        break;
      case CFG_FUNC1:  // at the moment just for unlock 1440p
        flag2set_func(unlock_1440p);
        font_color = FONTCOLOR_WHITE;
        print_szText = TRUE;
        break;
      case CFG_FUNC4:  // at the moment just for horizontal and vertical scale
        val_select = current_menu->leaves[v_run].cfgfct_call_4(0,v_run==VERTSCALE_SELECTION,0,0);
        val2txt_scale_func(val_select,v_run==VERTSCALE_SELECTION);
        if (use_direct_mode) {
          font_color = FONTCOLOR_GREY;
        } else {
          ref_val_select = current_menu->leaves[v_run].cfgfct_call_4(0,v_run==VERTSCALE_SELECTION,0,1);
          val_is_ref = (val_select == ref_val_select);
          font_color = val_is_ref ? FONTCOLOR_WHITE : FONTCOLOR_YELLOW;
        }
        print_szText = TRUE;
        break;
      case ISUBMENU:
        font_color = FONTCOLOR_WHITE;
        vd_print_string(VD_TEXT,h_l_offset,v_offset,font_color,EnterSubMenu);
        break;
      case CFG_FUNC0: // at the moment only in resolution screen
      case INFO_RET_FUNC0:
      case INFO_RET_FUNC1:
        font_color = FONTCOLOR_WHITE;
        vd_print_string(VD_TEXT,h_l_offset,v_offset,font_color,RunFunction);
        break;
      default:
        break;
    }
    if (print_szText) vd_print_string(VD_TEXT,h_l_offset,v_offset,font_color,&szText[0]);
  }

  if (is_rwdata_screen(current_menu)) print_game_id();

  return 0;
}

int update_debug_screen(menu_t* current_menu)
{
  if (current_menu->type != N64DEBUG) return -1;

  alt_u8 idx;
  bool_t show_led_ok = TRUE;
  bool_t show_led_nok = FALSE;

  // PPU state
  vd_clear_lineend(VD_TEXT,N64DEBUG_VALS_H_OFFSET,N64DEBUG_N64ADV_STATE_V_OFFSET);
  sprintf(szText,"0x%07x",(uint) n64adv_state);
  vd_print_string(VD_TEXT,N64DEBUG_VALS_H_OFFSET,N64DEBUG_N64ADV_STATE_V_OFFSET,FONTCOLOR_WHITE,&szText[0]);

  // PPU state: VI mode and Source-Sync. Mode
  bool_t is_lowlatency_mode = ((n64adv_state & N64ADV_LOWLATENCYMODE_GETMASK) >> N64ADV_LOWLATENCYMODE_OFFSET);
  vd_clear_lineend(VD_TEXT,N64DEBUG_N64ADV_VI_H_OFFSET,N64DEBUG_N64ADV_VI_V_OFFSET);
  vd_clear_lineend(VD_TEXT,N64DEBUG_SSM_H_OFFSET,N64DEBUG_SSM_V_OFFSET);
  if (video_input_detected) {
    if (palmode) {
      sprintf(szText,VTimingSel[2+scanmode]);
      sprintf(&szText[10]," (Pat. %d)",pal_pattern);
    } else {
      sprintf(szText,VTimingSel[scanmode]);
    }
    vd_print_string(VD_TEXT,N64DEBUG_N64ADV_VI_H_OFFSET,N64DEBUG_N64ADV_VI_V_OFFSET,FONTCOLOR_WHITE,&szText[0]);
    vd_print_string(VD_TEXT,N64DEBUG_SSM_H_OFFSET,N64DEBUG_SSM_V_OFFSET,FONTCOLOR_WHITE,OffOn[is_lowlatency_mode]);
    if (is_lowlatency_mode) {
      sprintf(szText,"(appr. %d sl. delay)",(uint) ((n64adv_state & N64ADV_LLM_SLBUF_FB_GETMASK) >> N64ADV_LLM_SLBUF_FB_OFFSET));
      vd_print_string(VD_TEXT,N64DEBUG_SSM_H_OFFSET+3,N64DEBUG_SSM_V_OFFSET,FONTCOLOR_WHITE,&szText[0]);
    }
  } else {
    sprintf(szText,"No video input detected");
    vd_print_string(VD_TEXT,N64DEBUG_N64ADV_VI_H_OFFSET,N64DEBUG_N64ADV_VI_V_OFFSET,FONTCOLOR_RED,NoVideoDetected);
    show_led_ok = FALSE;
    show_led_nok = TRUE;
  }

  // Pin state
  run_pin_state(TRUE);
  alt_u16 pin_state = get_pin_state();
  if (pin_state == PIN_STATE_GETALL_MASK) {
    idx = 1;
  } else if ((pin_state & PIN_STATE_NOAUDIO_PINS_GETMASK) == (PIN_STATE_GETALL_MASK & PIN_STATE_NOAUDIO_PINS_GETMASK)) {
    idx = 2;
    show_led_nok = TRUE;
  } else {
    idx = 0;
    show_led_ok = FALSE;
    show_led_nok = TRUE;
  }
  vd_clear_lineend(VD_TEXT,N64DEBUG_VALS_H_OFFSET,N64DEBUG_PIN_STATE_V_OFFSET);
  sprintf(szText,"0x%04x",(uint) pin_state);
  vd_print_string(VD_TEXT,N64DEBUG_VALS_H_OFFSET,N64DEBUG_PIN_STATE_V_OFFSET,Nok_Ok_color[idx],&szText[0]);

  // Pin state: show hearts
  sprintf(szText,"-");
  const alt_u8 hoffsets[16] = {
    N64DEBUG_PIN_AUDIO_SC_H_OFFSET, N64DEBUG_PIN_AUDIO_SD_H_OFFSET, N64DEBUG_PIN_AUDIO_LRC_H_OFFSET,
    N64DEBUG_PIN_VD_SYNC_H_OFFSET, N64DEBUG_PIN_VD_DATA_H_OFFSET + 0, N64DEBUG_PIN_VD_DATA_H_OFFSET + 2, N64DEBUG_PIN_VD_DATA_H_OFFSET + 4,
    N64DEBUG_PIN_VD_DATA_H_OFFSET + 6, N64DEBUG_PIN_VD_DATA_H_OFFSET + 8, N64DEBUG_PIN_VD_DATA_H_OFFSET + 10, N64DEBUG_PIN_VD_DATA_H_OFFSET + 12,
    N64DEBUG_PIN_CLK_N64_H_OFFSET, N64DEBUG_PIN_CLK_PLL0_H_OFFSET, N64DEBUG_PIN_CLK_PLL1_H_OFFSET,
    N64DEBUG_PIN_CLK_AUD_H_OFFSET, N64DEBUG_PIN_CLK_SYS_H_OFFSET
  };  // define offsets according to bit position in in pin_state variable
  const alt_u8 voffsets[16] = {
    N64DEBUG_PIN_AUDIO_V_OFFSET, N64DEBUG_PIN_AUDIO_V_OFFSET, N64DEBUG_PIN_AUDIO_V_OFFSET,
    N64DEBUG_PIN_VDATA_V_OFFSET, N64DEBUG_PIN_VDATA_V_OFFSET, N64DEBUG_PIN_VDATA_V_OFFSET, N64DEBUG_PIN_VDATA_V_OFFSET,
    N64DEBUG_PIN_VDATA_V_OFFSET, N64DEBUG_PIN_VDATA_V_OFFSET, N64DEBUG_PIN_VDATA_V_OFFSET, N64DEBUG_PIN_VDATA_V_OFFSET,
    N64DEBUG_PIN_CLK_LINE1_V_OFFSET, N64DEBUG_PIN_CLK_LINE0_V_OFFSET, N64DEBUG_PIN_CLK_LINE0_V_OFFSET,
    N64DEBUG_PIN_CLK_LINE1_V_OFFSET, N64DEBUG_PIN_CLK_LINE1_V_OFFSET
  };  // define offsets according to bit position in in pin_state variable
  alt_u8 nok_ok_val;
  for (idx = 0; idx < 16; idx++) {
    nok_ok_val = ((pin_state & (1<<idx)) >> idx);
    szText[0] = (char) Nok_Ok[nok_ok_val];
    vd_print_string(VD_TEXT,hoffsets[idx],voffsets[idx],Nok_Ok_color[nok_ok_val],&szText[0]);
  }

  vd_clear_lineend(VD_TEXT,N64DEBUG_PIN_PLL_SRC_H_OFFSET,N64DEBUG_PIN_CLK_LINE0_V_OFFSET);
  sprintf(szText,"(Source: %s)",ClkSrc[cfg_get_value(&low_latency_mode,0)]);
  vd_print_string(VD_TEXT,N64DEBUG_PIN_PLL_SRC_H_OFFSET,N64DEBUG_PIN_CLK_LINE0_V_OFFSET,FONTCOLOR_WHITE,&szText[0]);

  #ifdef DEBUG
    sprintf(szText,"(Vid. timeout cnt.: %u)",vid_timeout_cnt);
    vd_print_string(VD_TEXT,VD_WIDTH - strlen(&szText[0]),N64DEBUG_FUNC_V_OFFSET+2,FONTCOLOR_WHITE,&szText[0]);
  #endif

//  // for testing, if positions are right
//  alt_u8 position_to_test = PIN_STATE_SYSCLK_OFFSET;
//  sprintf(szText,"-");
//  vd_print_string(VD_TEXT,hoffsets[position_to_test],voffsets[position_to_test],FONTCOLOR_WHITE,&szText[0]);

  led_drive(LED_OK, (led_state_t) show_led_ok);
  led_drive(LED_NOK, (led_state_t) show_led_nok);

  return 0;
}
