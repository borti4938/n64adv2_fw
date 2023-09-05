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
#include "altera_avalon_pio_regs.h"
#include "system.h"
#include "app_cfg.h"
#include "n64.h"
#include "config.h"
#include "menu.h"
#include "textdefs_p.h"
#include "vd_driver.h"

char szText[VD_WIDTH];
//extern bool_t use_flash;
extern cfg_region_sel_type_t vmode_menu, vmode_n64adv;
extern cfg_timing_model_sel_type_t timing_menu, timing_n64adv;
extern cfg_scaler_in2out_sel_type_t scaling_menu, scaling_n64adv;
//extern config_tray_t scaling_words[NUM_SCALING_MODES];


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
       vicfg_screen, misc_screen, rwdata_screen, debug_screen;
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
    .number_selections = 11,
  #else
    .number_selections = 10,
  #endif
#else
    .number_selections = 7,
#endif
    .leaves = {
        {.id = MAIN2RES_V_OFFSET     , .arrowshape = &select_arrow, .leavetype = ISUBMENU, .submenu = &vires_screen},
        {.id = MAIN2SCALER_V_OFFSET  , .arrowshape = &select_arrow, .leavetype = ISUBMENU, .submenu = &viscaling_screen},
        {.id = MAIN2SCANLINE_V_OFFSET, .arrowshape = &select_arrow, .leavetype = ISUBMENU, .submenu = &slcfg_opt_subscreen},
        {.id = MAIN2VIPROC_V_OFFSET  , .arrowshape = &select_arrow, .leavetype = ISUBMENU, .submenu = &vicfg_screen},
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
    .number_selections = 12,
    .leaves = {
        {.id = RESCFG_INPUT_V_OFFSET      , .arrowshape = &optval_arrow, .leavetype = ICONFIG  , .config_value  = &region_selection},
        {.id = RESCFG_240P_V_OFFSET       , .arrowshape = &select_arrow, .leavetype = CFG_FUNC3, .cfgfct_call_3 = &cfgfct_linex},
        {.id = RESCFG_480P_V_OFFSET       , .arrowshape = &select_arrow, .leavetype = CFG_FUNC3, .cfgfct_call_3 = &cfgfct_linex},
        {.id = RESCFG_720P_V_OFFSET       , .arrowshape = &select_arrow, .leavetype = CFG_FUNC3, .cfgfct_call_3 = &cfgfct_linex},
        {.id = RESCFG_960P_V_OFFSET       , .arrowshape = &select_arrow, .leavetype = CFG_FUNC3, .cfgfct_call_3 = &cfgfct_linex},
        {.id = RESCFG_1080P_V_OFFSET      , .arrowshape = &select_arrow, .leavetype = CFG_FUNC3, .cfgfct_call_3 = &cfgfct_linex},
        {.id = RESCFG_1200P_V_OFFSET      , .arrowshape = &select_arrow, .leavetype = CFG_FUNC3, .cfgfct_call_3 = &cfgfct_linex},
        {.id = RESCFG_1440P_V_OFFSET      , .arrowshape = &select_arrow, .leavetype = CFG_FUNC3, .cfgfct_call_3 = &cfgfct_linex},
        {.id = RESCFG_1440WP_V_OFFSET     , .arrowshape = &select_arrow, .leavetype = CFG_FUNC3, .cfgfct_call_3 = &cfgfct_linex},
        {.id = RESCFG_USE_VGA_RES_V_OFFSET, .arrowshape = &optval_arrow, .leavetype = ICONFIG  , .config_value  = &vga_for_480p},
        {.id = RESCFG_USE_SRCSYNC_V_OFFSET, .arrowshape = &optval_arrow, .leavetype = ICONFIG  , .config_value  = &low_latency_mode},
        {.id = RESCFG_FORCE_5060_V_OFFSET , .arrowshape = &optval_arrow, .leavetype = ICONFIG  , .config_value  = &linex_force_5060}
    }
};

#define RES_FUNCTIONS_OFFSET   1
#define RES_1440P_SELECTION    7
#define RES_1440WP_SELECTION   8
#define FORCE5060_SELECTION   11

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
        {.id = SCALERCFG_IN2OUT_V_OFFSET     , .arrowshape = &optval_arrow, .leavetype = ICONFIG  , .config_value  = &scaling_selection},
        {.id = SCALERCFG_LINKVH_V_OFFSET     , .arrowshape = &optval_arrow, .leavetype = ICONFIG  , .config_value  = &link_hv_scale},
        {.id = SCALERCFG_VHSTEPS_V_OFFSET    , .arrowshape = &optval_arrow, .leavetype = ICONFIG  , .config_value  = &scaling_steps},
        {.id = SCALERCFG_VERTSCALE_V_OFFSET  , .arrowshape = &optval_arrow, .leavetype = CFG_FUNC4, .cfgfct_call_4 = &cfgfct_scale},
        {.id = SCALERCFG_HORISCALE_V_OFFSET  , .arrowshape = &optval_arrow, .leavetype = CFG_FUNC4, .cfgfct_call_4 = &cfgfct_scale},
        {.id = SCALERCFG_PALBOXED_V_OFFSET   , .arrowshape = &optval_arrow, .leavetype = ICONFIG  , .config_value  = &pal_boxed_mode},
        {.id = SCALERCFG_INSHIFTMODE_V_OFFSET, .arrowshape = &optval_arrow, .leavetype = ICONFIG  , .config_value  = &timing_selection},
        {.id = SCALERCFG_VERTSHIFT_V_OFFSET  , .arrowshape = &optval_arrow, .leavetype = ICONFIG  , .config_value  = &vert_shift},
        {.id = SCALERCFG_HORISHIFT_V_OFFSET  , .arrowshape = &optval_arrow, .leavetype = ICONFIG  , .config_value  = &hor_shift}
    }
};

#define V_INTERP_SELECTION      0
#define H_INTERP_SELECTION      1
#define SCALING_PAGE_SELECTION  2
#define VHLINK_SELECTION        3
#define SCALING_STEPS_SELECTION 4
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
    .number_selections = 8,
    .leaves = {
        {.id = VICFG_DEINTERL_V_OFFSET    , .arrowshape = &optval_arrow, .leavetype = ICONFIG , .config_value = &deinterlace_mode},
        {.id = VICFG_GAMMA_V_OFFSET       , .arrowshape = &optval_arrow, .leavetype = ICONFIG , .config_value = &gamma_lut},
        {.id = VICFG_COLORSPACE_V_OFFSET  , .arrowshape = &optval_arrow, .leavetype = ICONFIG , .config_value = &color_space},
        {.id = VICFG_LIMITEDRANGE_V_OFFSET, .arrowshape = &optval_arrow, .leavetype = ICONFIG , .config_value = &limited_colorspace},
        {.id = VICFG_DEBLUR_V_OFFSET      , .arrowshape = &optval_arrow, .leavetype = ICONFIG , .config_value = &deblur_mode},
        {.id = VICFG_PCDEBLUR_V_OFFSET    , .arrowshape = &optval_arrow, .leavetype = ICONFIG , .config_value = &deblur_mode_powercycle},
        {.id = VICFG_16BITMODE_V_OFFSET   , .arrowshape = &optval_arrow, .leavetype = ICONFIG , .config_value = &mode16bit},
        {.id = VICFG_PC16BITMODE_V_OFFSET , .arrowshape = &optval_arrow, .leavetype = ICONFIG , .config_value = &mode16bit_powercycle}
    }
};

#define DEINTERLACE_SELECTION       0
#define DEBLUR_CURRENT_SELECTION    4
#define DEBLUR_POWERCYCLE_SELECTION 5
#define M16BIT_CURRENT_SELECTION    6
#define M16BIT_POWERCYCLE_SELECTION 7

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
    .number_selections = 9,
    .leaves = {
        {.id = MISC_AUDIO_SWAP_LR_V_OFFSET       , .arrowshape = &optval_arrow, .leavetype = ICONFIG  , .config_value = &audio_swap_lr},
        {.id = MISC_AUDIO_FILTER_BYPASS_V_OFFSET , .arrowshape = &optval_arrow, .leavetype = ICONFIG  , .config_value = &audio_fliter_bypass},
        {.id = MISC_AUDIO_AMP_V_OFFSET           , .arrowshape = &optval_arrow, .leavetype = ICONFIG  , .config_value = &audio_amp},
        {.id = MISC_AUDIO_SPDIF_EN_V_OFFSET      , .arrowshape = &optval_arrow, .leavetype = ICONFIG  , .config_value = &audio_spdif_en},
        {.id = MISC_IGR_RESET_V_OFFSET           , .arrowshape = &optval_arrow, .leavetype = ICONFIG  , .config_value = &igr_reset},
        {.id = MISC_IGR_DEBLUR_V_OFFSET          , .arrowshape = &optval_arrow, .leavetype = ICONFIG  , .config_value = &igr_deblur},
        {.id = MISC_IGR_16BITMODE_V_OFFSET       , .arrowshape = &optval_arrow, .leavetype = ICONFIG  , .config_value = &igr_16bitmode},
        {.id = MISC_RST_MASKING_V_OFFSET         , .arrowshape = &optval_arrow, .leavetype = ICONFIG  , .config_value = &rst_masking},
        {.id = MISC_LUCKY_1440P_V_OFFSET         , .arrowshape = &select_arrow, .leavetype = CFG_FUNC1, .cfgfct_call_1 = &cfgfct_unlock1440p}
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
    .number_selections = 7,
    .leaves = {
        {.id = RWDATA_AUTOSAVE_V_OFFSET        , .arrowshape = &optval_arrow, .leavetype = ICONFIG       , .config_value = &autosave},
        {.id = RWDATA_SAVE_FL_V_OFFSET         , .arrowshape = &select_arrow, .leavetype = INFO_RET_FUNC1, .sys_fun_1 = &cfg_save_to_flash},
        {.id = RWDATA_LOAD_FL_V_OFFSET         , .arrowshape = &select_arrow, .leavetype = INFO_RET_FUNC1, .sys_fun_1 = &cfg_load_from_flash},
        {.id = RWDATA_LOAD_FBDEFAULTS_V_OFFSET , .arrowshape = &select_arrow, .leavetype = INFO_RET_FUNC2, .sys_fun_2 = &cfg_load_defaults},
        {.id = RWDATA_CPYCFG_DIRECTION_V_OFFSET, .arrowshape = &optval_arrow, .leavetype = ICONFIG       , .config_value = &copy_direction},
        {.id = RWDATA_CPYCFG_FUNCTION_V_OFFSET , .arrowshape = &select_arrow, .leavetype = INFO_RET_FUNC0, .sys_fun_0 = &cfg_copy_ntsc2pal},
        {.id = RWDATA_FALLBACK_V_OFFSET        , .arrowshape = &optval_arrow, .leavetype = ICONFIG       , .config_value = &fallbackmode},
//        {.id = RWDATA_UPDATE_V_OFFSET          , .arrowshape = &optval_arrow, .leavetype = INFO_RET_FUNC0, .sys_fun_0 = &fw_update}
    }
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
#ifndef DEBUG
  static inline bool_t is_about_screen (menu_t *menu)
    {  return (menu == &about_screen); }
//  static inline bool_t is_license_screen (menu_t *menu)
//    {  return (menu == &license_screen); }
#endif


void val2txt_func(alt_u16 v) { sprintf(szText,"%u", v); };
void val2txt_4u_func(alt_u16 v) { sprintf(szText,"%4u", v); };
void val2txt_5b_binaryoffset_func(alt_u16 v) { if (v & 0x10) sprintf(szText," %2u", (v&0xF)); else sprintf(szText,"-%2u", (v^0xF)+1); };
void val2txt_scale_sel_func(alt_u16 v) {
  if (v == PPU_SCALING_CURRENT) {
    sprintf(szText,NTSCPAL_SEL[PPU_REGION_CURRENT]);
  } else {
    if (v > NTSC_LAST_SCALING_MODE) {
      sprintf(szText,"PAL to ");
      sprintf(&szText[7],Resolutions[v - PAL_TO_288]);
    } else {
      sprintf(szText,"NTSC to ");
      sprintf(&szText[8],Resolutions[v - NTSC_TO_240]);
    }
  }
};
void val2txt_scale_func(alt_u16 v, bool_t use_vertical) {
  alt_u8 idx = cfg_scale_is_predefined(v,use_vertical);
  if (!use_vertical && hor_hires) {
    if (idx & 0x01) idx = PREDEFINED_SCALE_STEPS;
    else idx = idx/2;
  }
  if (idx < PREDEFINED_SCALE_STEPS && (scaling_menu != NTSC_TO_240) && (scaling_menu != PAL_TO_288)) {
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


void print_current_timing_mode()
{
  vd_clear_info_area(0,COPYRIGHT_H_OFFSET-1,0,0);
  val2txt_scale_sel_func(scaling_n64adv);
  vd_print_string(VD_INFO,0,0,FONTCOLOR_NAVAJOWHITE,&szText[0]);

  alt_u8 hoffset = strlen(&szText[0]);
  alt_u16 hscale = cfg_get_value(&hor_scale,0);
  alt_u16 vscale = cfg_get_value(&vert_scale,0);

  sprintf(szText,"(%d x %d)",hscale,vscale);
  szText[6-(hscale<1000)] = (char) CHECKBOX_TICK;
  vd_print_string(VD_INFO,hoffset + 1,0,FONTCOLOR_NAVAJOWHITE,&szText[0]);
}

void print_ctrl_data() {
  sprintf(szText,"Ctrl. data: 0x%08x",(uint) ctrl_data);
  vd_clear_info_area(0,COPYRIGHT_H_OFFSET-1,0,0);
  vd_print_string(VD_INFO,0,0,FONTCOLOR_NAVAJOWHITE,&szText[0]);
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

void print_1440p_unlock_info() {
  vd_clear_info();
  vd_print_string(VD_INFO,VD_WIDTH - UNLOCK1140P_H_LENGTH,0,confirm_messages_color[0],Unlock_1440p_Message);;
}

void print_cr_info() {
  vd_clear_info_area(COPYRIGHT_H_OFFSET,VD_WIDTH-1,0,0);
  vd_print_string(VD_INFO,COPYRIGHT_H_OFFSET,COPYRIGHT_V_OFFSET,FONTCOLOR_DARKORANGE,copyright_note);
}

void print_fw_version()
{
  alt_u16 ext_fw = (alt_u16) get_pcb_version();
  vd_print_string(VD_TEXT,VERSION_H_OFFSET,VERSION_V_OFFSET,FONTCOLOR_WHITE,pcb_rev[ext_fw]);

  sprintf(szText,"0x%08x%08x",(uint) get_chip_id(1),(uint) get_chip_id(0));
  vd_print_string(VD_TEXT,VERSION_H_OFFSET,VERSION_V_OFFSET+1,FONTCOLOR_WHITE,&szText[0]);

  ext_fw = get_hdl_version();
  sprintf(szText,"%1d.%02d",((ext_fw & HDL_FW_GETMAIN_MASK) >> HDL_FW_MAIN_OFFSET),
                            ((ext_fw & HDL_FW_GETSUB_MASK) >> HDL_FW_SUB_OFFSET));
  vd_print_string(VD_TEXT,VERSION_H_OFFSET,VERSION_V_OFFSET+2,FONTCOLOR_WHITE,&szText[0]);

  sprintf(szText,"%1d.%02d",SW_FW_MAIN,SW_FW_SUB);
  vd_print_string(VD_TEXT,VERSION_H_OFFSET,VERSION_V_OFFSET+3,FONTCOLOR_WHITE,&szText[0]);
}

void update_vmode_menu()
{
  vmode_menu = cfg_get_value(&region_selection,0);
  if (vmode_menu == PPU_REGION_CURRENT) vmode_menu = vmode_n64adv;
}

void update_scaling_menu()
{
  scaling_menu = cfg_get_value(&scaling_selection,0);
  if (scaling_menu == PPU_SCALING_CURRENT) scaling_menu = scaling_n64adv;
}

void update_timing_menu()
{
  timing_menu = cfg_get_value(&timing_selection,0);
  if (timing_menu == PPU_TIMING_CURRENT) timing_menu = timing_n64adv;
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
      cfg_reset_selections();
      while ((*current_menu)->parent) {
        (*current_menu)->current_selection = 0;
        *current_menu = (*current_menu)->parent;
      }
      (*current_menu)->current_selection = 0;
      return MENU_CLOSE;
    case CMD_MENU_BACK:
      cfg_reset_selections();
      (*current_menu)->current_selection = 0;
      if ((*current_menu)->parent) {
        *current_menu = (*current_menu)->parent;
        todo = NEW_OVERLAY;
      } else {
        return MENU_CLOSE;
      }
      break;
    case CMD_MENU_PAGE_RIGHT:
      if (is_vires_screen(*current_menu)) {
        cfg_inc_value(&region_selection);
        update_vmode_menu();
        cfg_load_linex_word(vmode_menu);
        todo = NEW_OVERLAY;
      }
      if (is_viscaling_screen(*current_menu)){
        if ((*current_menu)->current_selection >= SCALING_PAGE_SELECTION && (*current_menu)->current_selection < PAL_BOXED_SELECTION) {
          cfg_inc_value(&scaling_selection);
          update_scaling_menu();
          cfg_load_scaling_word(scaling_menu);
          todo = NEW_OVERLAY;
        }
//        if ((*current_menu)->current_selection >= TIMING_PAGE_SELECTION && (*current_menu)->current_selection <= HORSHIFT_SELECTION) {
        if ((*current_menu)->current_selection >= TIMING_PAGE_SELECTION) {
          cfg_inc_value(&timing_selection);
          update_timing_menu();
          cfg_load_timing_word(timing_menu);
          todo = NEW_OVERLAY;
        }
      }
      if (is_slcfg_screen(*current_menu)) {
        cfg_inc_value(&region_selection);
        update_vmode_menu();
        cfg_load_linex_word(vmode_menu);
        todo = NEW_OVERLAY;
      }
      break;
    case CMD_MENU_PAGE_LEFT:
      if (is_vires_screen(*current_menu)) {
        cfg_dec_value(&region_selection);
        update_vmode_menu();
        cfg_load_linex_word(vmode_menu);
        todo = NEW_OVERLAY;
      }
      if (is_viscaling_screen(*current_menu)){
        if ((*current_menu)->current_selection >= SCALING_PAGE_SELECTION && (*current_menu)->current_selection < PAL_BOXED_SELECTION) {
          cfg_dec_value(&scaling_selection);
          update_scaling_menu();
          cfg_load_scaling_word(scaling_menu);
          todo = NEW_OVERLAY;
        }
//        if ((*current_menu)->current_selection >= TIMING_PAGE_SELECTION && (*current_menu)->current_selection <= HORSHIFT_SELECTION) {
        if ((*current_menu)->current_selection >= TIMING_PAGE_SELECTION) {
          cfg_dec_value(&timing_selection);
          update_timing_menu();
          cfg_load_timing_word(timing_menu);
          todo = NEW_OVERLAY;
        }
      }
      if (is_slcfg_screen(*current_menu)) {
        cfg_dec_value(&region_selection);
        update_vmode_menu();
        cfg_load_linex_word(vmode_menu);
        todo = NEW_OVERLAY;
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
  if (todo == NEW_OVERLAY || todo == NEW_SELECTION) {
    if (is_vires_screen(*current_menu)) {
      if ((unlock_1440p == FALSE) && ((current_sel == RES_1440P_SELECTION) || (current_sel == RES_1440WP_SELECTION)))
        (*current_menu)->current_selection = (command == CMD_MENU_DOWN) ? RES_1440WP_SELECTION + 1 : RES_1440P_SELECTION - 1;
      if ((cfg_get_value(&low_latency_mode,0) == ON || cfg_get_value(&linex_resolution,0) == PASSTHROUGH) && (current_sel == FORCE5060_SELECTION))
        (*current_menu)->current_selection = (command == CMD_MENU_DOWN) ? 0 : FORCE5060_SELECTION - 1;
    }

    if (is_viscaling_screen(*current_menu)) {
      if ((scaling_menu == NTSC_TO_240) || (scaling_menu == PAL_TO_288)) {
        if (current_sel < SCALING_PAGE_SELECTION)
          (*current_menu)->current_selection = ((todo == NEW_OVERLAY) ||(command == CMD_MENU_DOWN)) ? H_INTERP_SELECTION + 1 : (*current_menu)->number_selections - 1;
        if (current_sel == VHLINK_SELECTION || current_sel == SCALING_STEPS_SELECTION)
          (*current_menu)->current_selection = (command == CMD_MENU_DOWN) ? SCALING_STEPS_SELECTION + 1 : VHLINK_SELECTION - 1;
      } else {
        if((current_sel == HORISCALE_SELECTION) && (cfg_get_value(&link_hv_scale,0) != CFG_LINK_HV_SCALE_MAX_VALUE))
          (*current_menu)->current_selection = (command == CMD_MENU_DOWN) ? HORISCALE_SELECTION + 1 : HORISCALE_SELECTION - 1;
      }
    }

    return todo;
  }

  if (apply_sl_vert_negoffset(*current_menu) && current_sel > SL_VLINK_SELECTION) current_sel -= SL_HORI_TO_VERT_OFFSET;

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
    if (todo == NEW_CONF_VALUE) {
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
  if ((*current_menu)->leaves[current_sel].leavetype == CFG_FUNC1) {
    if (command == CMD_MENU_RIGHT) {
      (*current_menu)->leaves[current_sel].cfgfct_call_1(1);  // at the moment only used for unlock 1440p, so this is correct
      return NEW_CONF_VALUE;
    }
  }
  if ((*current_menu)->leaves[current_sel].leavetype == CFG_FUNC3) {
    if (command == CMD_MENU_RIGHT) {
      (*current_menu)->leaves[current_sel].cfgfct_call_3(current_sel-RES_FUNCTIONS_OFFSET,1,0);  // at the moment only used in resolution menu, so this is correct
      return NEW_CONF_VALUE;
    }
  }
  if ((*current_menu)->leaves[current_sel].leavetype == CFG_FUNC4) { // at the moment only used in scaling menu for horizontal and vertical scale
    if ((command == CMD_MENU_RIGHT) || (command == CMD_MENU_LEFT)) {
      (*current_menu)->leaves[current_sel].cfgfct_call_4(command,current_sel==VERTSCALE_SELECTION,1,0);
      return NEW_CONF_VALUE;
    }
  }

  if (((command == CMD_MENU_RIGHT) || (command == CMD_MENU_ENTER)) && ((*current_menu)->leaves[current_sel].leavetype >= INFO_RET_FUNC0)) {
    int retval = 0;
    if ((*current_menu)->leaves[current_sel].leavetype == INFO_RET_FUNC0) retval = (*current_menu)->leaves[current_sel].sys_fun_0();
    if ((*current_menu)->leaves[current_sel].leavetype == INFO_RET_FUNC1) retval = (*current_menu)->leaves[current_sel].sys_fun_1(1);
    if ((*current_menu)->leaves[current_sel].leavetype == INFO_RET_FUNC2) retval = (*current_menu)->leaves[current_sel].sys_fun_2(cfg_get_value(&fallbackmode,0),1);
    return (retval == 0                     ? CONFIRM_OK  :
            retval == -CFG_FLASH_SAVE_ABORT ? CONFIRM_ABORTED :
                                              CONFIRM_FAILED);
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

  for (v_run = 0; v_run < current_menu->number_selections; v_run++)
    if (current_menu->leaves[v_run].arrowshape != NULL) {
      v_offset   = current_menu->leaves[v_run].id;
      if (v_run == current_menu->current_selection) {
        vd_print_char(VD_TEXT,h_l_offset  ,v_offset,FONTCOLOR_WHITE,(char) current_menu->leaves[v_run].arrowshape->left);
        vd_print_char(VD_TEXT,h_l_offset+1,v_offset,FONTCOLOR_WHITE,(char) current_menu->leaves[v_run].arrowshape->right);
      } else {
        vd_clear_txt_area(h_l_offset,h_l_offset+1,v_offset,v_offset);
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

  bool_t use_240p_288p = (scaling_menu == NTSC_TO_240) || (scaling_menu == PAL_TO_288);

  bool_t use_sl_vert_negoffset = apply_sl_vert_negoffset(current_menu);
  alt_u8 v_run_negoffset = 0;

  for (v_run = 0; v_run < current_menu->number_selections - v_run_negoffset; v_run++) {
    v_offset   = current_menu->leaves[v_run + v_run_negoffset].id;

    if (use_sl_vert_negoffset && v_run > SL_VLINK_SELECTION) {
        use_sl_vert_negoffset = FALSE;
      v_run -= SL_HORI_TO_VERT_OFFSET;
      v_run_negoffset = SL_HORI_TO_VERT_OFFSET;
    }

    vd_clear_txt_area(h_l_offset,h_l_offset + OPT_WINDOW_WIDTH,v_offset,v_offset);
    bool_t print_szText = FALSE;
    switch (current_menu->leaves[v_run].leavetype) {
      case ICONFIG:
        val_select = cfg_get_value(current_menu->leaves[v_run].config_value,0);
//        ref_val_select = cfg_get_value(current_menu->leaves[v_run].config_value,use_flash);
        ref_val_select = cfg_get_value(current_menu->leaves[v_run].config_value,1);
        if (is_vicfg_screen(current_menu)){
          if (v_run == DEBLUR_CURRENT_SELECTION    || v_run == M16BIT_CURRENT_SELECTION   ) ref_val_select = val_select;
//          if (v_run == DEBLUR_POWERCYCLE_SELECTION || v_run == M16BIT_POWERCYCLE_SELECTION) ref_val_select = cfg_get_value(current_menu->leaves[v_run-1].config_value,use_flash);
          if (v_run == DEBLUR_POWERCYCLE_SELECTION || v_run == M16BIT_POWERCYCLE_SELECTION) ref_val_select = cfg_get_value(current_menu->leaves[v_run-1].config_value,1);
        }
//        if (current_menu->current_selection == v_run) {
//          background_color = OPT_WINDOWCOLOR_BG;
//          font_color = OPT_WINDOWCOLOR_FONT;
//        } else {
//          background_color = BACKGROUNDCOLOR_STANDARD;
//          font_color = (val_select == ref_val_select) ? FONTCOLOR_WHITE : FONTCOLOR_YELLOW;
//        }


        val_is_ref = (val_select == ref_val_select);
        font_color = val_is_ref ? FONTCOLOR_WHITE : FONTCOLOR_YELLOW;

        // check res screen
        if (is_vires_screen(current_menu)) {
          if ((cfg_get_value(&low_latency_mode,0) == ON || cfg_get_value(&linex_resolution,0) == PASSTHROUGH) && v_run == FORCE5060_SELECTION) {
            val_select = 0;
            font_color = FONTCOLOR_GREY;
          }
        }
//
//        // check scanline screen
//        if (is_slcfg_screen(current_menu)) {
//          if (((cfg_get_value(&sl_en,0) == OFF) && v_run > SL_EN_SELECTION && v_run < SL_INPUT_480I_SELECTION)        ||
//              ((cfg_get_value(&sl_en_480i,0) == OFF) && v_run > SL_EN_480I_SELECTION )                                ||
//              (use_sl_linked_vals && v_run_offset == 0 && (cfg_get_value(&sl_en,0) == OFF) && v_run > SL_EN_SELECTION) )
//            font_color = val_is_ref ? FONTCOLOR_GREY : FONTCOLOR_NAVAJOWHITE;
//        }

        // check scaling menu
        if (is_viscaling_screen(current_menu) && use_240p_288p) {
//          if (v_run == V_INTERP_SELECTION || v_run == H_INTERP_SELECTION) {
          if (v_run < SCALING_PAGE_SELECTION) {
            val_select = 0;
            font_color = FONTCOLOR_GREY;
          }
          if (v_run == VHLINK_SELECTION) {
            val_select = CFG_LINK_HV_SCALE_MAX_VALUE;
            font_color = FONTCOLOR_GREY;
          }
          if (v_run == SCALING_STEPS_SELECTION) {
            val_select = 1;
            font_color = FONTCOLOR_GREY;
          }
        }
        if (is_vicfg_screen(current_menu) && v_run == DEINTERLACE_SELECTION && use_240p_288p) {
          val_select = val_select & 1;
        }

//        if (v_run == current_menu->current_selection)

        if (current_menu->leaves[v_run].config_value->cfg_type == FLAGTXT ||
            current_menu->leaves[v_run].config_value->cfg_type == NUMVALUE ) {
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
      case CFG_FUNC3:  // at the moment just in resolution screen
        val_select = current_menu->leaves[v_run].cfgfct_call_3(v_run-RES_FUNCTIONS_OFFSET,0,0) + 1;
        ref_val_select = current_menu->leaves[v_run].cfgfct_call_3(v_run-RES_FUNCTIONS_OFFSET,0,1) + 1;
        val_is_ref = ((val_select != v_run && ref_val_select != v_run) || val_select == ref_val_select);
        flag2set_func(val_select == v_run);
        if ((unlock_1440p == FALSE) && ((v_run == RES_1440P_SELECTION) || (v_run == RES_1440WP_SELECTION)))
          font_color = FONTCOLOR_GREY;
        else
          font_color = val_is_ref ? FONTCOLOR_WHITE : FONTCOLOR_YELLOW;
        print_szText = TRUE;
        break;
      case CFG_FUNC4:  // at the moment just for horizontal and vertical scale
        if (!use_240p_288p && v_run == HORISCALE_SELECTION && cfg_get_value(&link_hv_scale,0) != CFG_LINK_HV_SCALE_MAX_VALUE) {
          cfg_scale_v2h_update();
          val_select = current_menu->leaves[v_run].cfgfct_call_4(0,0,0,0);
          ref_val_select = current_menu->leaves[v_run].cfgfct_call_4(0,0,0,1);
          val2txt_4u_func(val_select);
          font_color = (val_select == ref_val_select) ? FONTCOLOR_GREY : FONTCOLOR_NAVAJOWHITE;
        } else {
          val_select = current_menu->leaves[v_run].cfgfct_call_4(0,v_run==VERTSCALE_SELECTION,0,0);
          ref_val_select = current_menu->leaves[v_run].cfgfct_call_4(0,v_run==VERTSCALE_SELECTION,0,1);
          val_is_ref = (val_select == ref_val_select);
          val2txt_scale_func(val_select,v_run==VERTSCALE_SELECTION);
          font_color = val_is_ref ? FONTCOLOR_WHITE : FONTCOLOR_YELLOW;
        }
        print_szText = TRUE;
        break;
      case ISUBMENU:
        font_color = FONTCOLOR_WHITE;
        vd_print_string(VD_TEXT,h_l_offset,v_offset,font_color,EnterSubMenu);
        break;
      case INFO_RET_FUNC0:
      case INFO_RET_FUNC1:
      case INFO_RET_FUNC2:
        font_color = FONTCOLOR_WHITE;
        vd_print_string(VD_TEXT,h_l_offset,v_offset,font_color,RunFunction);
        break;
      default:
        break;
    }
    if (print_szText) vd_print_string(VD_TEXT,h_l_offset,v_offset,font_color,&szText[0]);
  }

  return 0;
}

int update_debug_screen(menu_t* current_menu)
{
  if (current_menu->type != N64DEBUG) return -1;

  alt_u8 idx;

  // PPU state
  vd_clear_lineend(VD_TEXT,N64DEBUG_VALS_H_OFFSET,N64DEBUG_PPU_STATE_V_OFFSET);
  sprintf(szText,"0x%07x",(uint) ppu_state);
  vd_print_string(VD_TEXT,N64DEBUG_VALS_H_OFFSET,N64DEBUG_PPU_STATE_V_OFFSET,FONTCOLOR_WHITE,&szText[0]);

  // PPU state: VI mode
  vd_clear_lineend(VD_TEXT,N64DEBUG_PPU_VI_H_OFFSET,N64DEBUG_PPU_VI_V_OFFSET);
  if (palmode) {
    sprintf(szText,VTimingSel[2+scanmode]);
    sprintf(&szText[10]," (Pat. %d)",pal_pattern);
  } else {
    sprintf(szText,VTimingSel[scanmode]);
  }
  vd_print_string(VD_TEXT,N64DEBUG_PPU_VI_H_OFFSET,N64DEBUG_PPU_VI_V_OFFSET,FONTCOLOR_WHITE,&szText[0]);

  // PPU state: Source-Sync. Mode
  bool_t is_lowlatency_mode = ((ppu_state & PPU_LOWLATENCYMODE_GETMASK) >> PPU_LOWLATENCYMODE_OFFSET);
  vd_clear_lineend(VD_TEXT,N64DEBUG_SSM_H_OFFSET,N64DEBUG_SSM_V_OFFSET);
  vd_print_string(VD_TEXT,N64DEBUG_SSM_H_OFFSET,N64DEBUG_SSM_V_OFFSET,FONTCOLOR_WHITE,OffOn[is_lowlatency_mode]);
  if (is_lowlatency_mode) {
    sprintf(szText,"(%d sl. buffered)",(uint) ((ppu_state & PPU_LLM_SLBUF_FB_GETMASK) >> PPU_LLM_SLBUF_FB_OFFSET));
    vd_print_string(VD_TEXT,N64DEBUG_SSM_H_OFFSET+3,N64DEBUG_SSM_V_OFFSET,FONTCOLOR_WHITE,&szText[0]);
  }

  // Pin state
  run_pin_state(TRUE);
  alt_u16 pin_state = get_pin_state();
  if (pin_state == PIN_STATE_GETALL_MASK) idx = 1;
  else if ((pin_state & PIN_STATE_NOAUDIO_PINS_GETMASK) == PIN_STATE_NOAUDIO_PINS_GETMASK) idx = 2;
  else idx = 0;
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

//  // for testing, if positions are right
//  alt_u8 position_to_test = PIN_STATE_SYSCLK_OFFSET;
//  sprintf(szText,"-");
//  vd_print_string(VD_TEXT,hoffsets[position_to_test],voffsets[position_to_test],FONTCOLOR_WHITE,&szText[0]);

  return 0;
}
