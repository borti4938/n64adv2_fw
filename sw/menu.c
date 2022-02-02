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
extern vmode_t vmode_menu, vmode_n64adv;
extern cfg_timing_model_sel_type_t timing_menu, timing_n64adv;
extern cfg_scaler_in2out_sel_type_t scaling_menu, scaling_n64adv;
extern config_tray_t scaling_words[NUM_SCALING_MODES];


static const arrowshape_t selection_arrow = {
    .left  = ARROW_RIGHT,
    .right = EMPTY
};

static const arrowshape_t optval_arrow = {
    .left  = TRIANGLE_LEFT,
    .right = TRIANGLE_RIGHT
};

static const arrow_t front_sel_arrow = {
    .shape = &selection_arrow,
    .hpos = 1
};

static const arrow_t vires_opt_arrow = {
    .shape = &optval_arrow,
    .hpos = (RESCFG_VALS_H_OFFSET - 2)
};

static const arrow_t viscaling_opt_arrow = {
    .shape = &optval_arrow,
    .hpos = (SCALERCFG_VALS_H_OFFSET - 2)
};

static const arrow_t vicfg_sel_arrow = {
    .shape = &selection_arrow,
    .hpos = (VICFG_VALS_H_OFFSET - 2)
};

static const arrow_t vicfg_opt_arrow = {
    .shape = &optval_arrow,
    .hpos = (VICFG_VALS_H_OFFSET - 2)
};

static const arrow_t slcfg_opt_arrow0 = {
    .shape = &optval_arrow,
    .hpos = (SLCFG_VALS_H_OFFSET - 11)
};

static const arrow_t slcfg_opt_arrow1 = {
    .shape = &optval_arrow,
    .hpos = (SLCFG_VALS_H_OFFSET - 2)
};

static const arrow_t misc_opt_arrow = {
    .shape = &optval_arrow,
    .hpos = (MISC_VALS_H_OFFSET - 2)
};

static const arrow_t rwdata_sel_arrow = {
    .shape = &selection_arrow,
    .hpos = (RWDATA_VALS_H_OFFSET - 2)
};

static const arrow_t rwdata_optval_arrow = {
    .shape = &optval_arrow,
    .hpos = (RWDATA_VALS_H_OFFSET - 2)
};


menu_t home_menu, vinfo_screen, vires_screen, viscaling_screen, vicfg_screen, slcfg_opt_subscreen,
       misc_screen, rwdata_screen, about_screen, thanks_screen, license_screen;


menu_t home_menu = {
    .type = HOME,
    .header  = &home_header,
    .body = {
      .hoffset = MAIN_OVERLAY_H_OFFSET,
      .text = &home_overlay
    },
    .current_selection = 1,
    .number_selections = 9,
    .leaves = {
        {.id = MAIN2VINFO_V_OFFSET  , .arrow_desc = &front_sel_arrow, .leavetype = ISUBMENU, .submenu = &vinfo_screen},
        {.id = MAIN2RES_V_OFFSET    , .arrow_desc = &front_sel_arrow, .leavetype = ISUBMENU, .submenu = &vires_screen},
        {.id = MAIN2SCALER_V_OFFSET , .arrow_desc = &front_sel_arrow, .leavetype = ISUBMENU, .submenu = &viscaling_screen},
        {.id = MAIN2VIPROC_V_OFFSET , .arrow_desc = &front_sel_arrow, .leavetype = ISUBMENU, .submenu = &vicfg_screen},
        {.id = MAIN2MISC_V_OFFSET   , .arrow_desc = &front_sel_arrow, .leavetype = ISUBMENU, .submenu = &misc_screen},
        {.id = MAIN2SAVE_V_OFFSET   , .arrow_desc = &front_sel_arrow, .leavetype = ISUBMENU, .submenu = &rwdata_screen},
        {.id = MAIN2ABOUT_V_OFFSET  , .arrow_desc = &front_sel_arrow, .leavetype = ISUBMENU, .submenu = &about_screen},
        {.id = MAIN2THANKS_V_OFFSET , .arrow_desc = &front_sel_arrow, .leavetype = ISUBMENU, .submenu = &thanks_screen},
        {.id = MAIN2LICENSE_V_OFFSET, .arrow_desc = &front_sel_arrow, .leavetype = ISUBMENU, .submenu = &license_screen}
    }
};

menu_t vinfo_screen = {
    .type = VINFO,
    .header = &vinfo_header,
    .body = {
      .hoffset = INFO_OVERLAY_H_OFFSET,
      .text = &vinfo_overlay
    },
    .parent = &home_menu
};

menu_t vires_screen = {
    .type = CONFIG,
    .header = &resolution_header,
    .body = {
      .hoffset = RESCFG_OVERLAY_H_OFFSET,
      .text = &resolution_overlay
    },
    .parent = &home_menu,
    .current_selection = 0,
    .number_selections = 11,
    .leaves = {
        {.id = RESCFG_INPUT_V_OFFSET      , .arrow_desc = &vires_opt_arrow, .leavetype = ICONFIG    , .config_value  = &res_selection},
        {.id = RESCFG_240P_V_OFFSET       , .arrow_desc = &vires_opt_arrow, .leavetype = ICFGVALFUNC, .cfgfct_call_2 = &cfgfct_linex},
        {.id = RESCFG_480P_V_OFFSET       , .arrow_desc = &vires_opt_arrow, .leavetype = ICFGVALFUNC, .cfgfct_call_2 = &cfgfct_linex},
        {.id = RESCFG_720P_V_OFFSET       , .arrow_desc = &vires_opt_arrow, .leavetype = ICFGVALFUNC, .cfgfct_call_2 = &cfgfct_linex},
        {.id = RESCFG_960P_V_OFFSET       , .arrow_desc = &vires_opt_arrow, .leavetype = ICFGVALFUNC, .cfgfct_call_2 = &cfgfct_linex},
        {.id = RESCFG_1080P_V_OFFSET      , .arrow_desc = &vires_opt_arrow, .leavetype = ICFGVALFUNC, .cfgfct_call_2 = &cfgfct_linex},
        {.id = RESCFG_1200P_V_OFFSET      , .arrow_desc = &vires_opt_arrow, .leavetype = ICFGVALFUNC, .cfgfct_call_2 = &cfgfct_linex},
        {.id = RESCFG_1440P_V_OFFSET      , .arrow_desc = &vires_opt_arrow, .leavetype = ICFGVALFUNC, .cfgfct_call_2 = &cfgfct_linex},
        {.id = RESCFG_USE_VGA_RES_V_OFFSET, .arrow_desc = &vires_opt_arrow, .leavetype = ICONFIG    , .config_value  = &vga_for_480p},
        {.id = RESCFG_USE_SRCSYNC_V_OFFSET, .arrow_desc = &vires_opt_arrow, .leavetype = ICONFIG    , .config_value  = &low_latency_mode},
        {.id = RESCFG_FORCE_5060_V_OFFSET , .arrow_desc = &vires_opt_arrow, .leavetype = ICONFIG    , .config_value  = &linex_force_5060}
    }
};

#define RES_1440P_SELECTION  7
#define FORCE5060_SELECTION 10

menu_t viscaling_screen = {
    .type = CONFIG,
    .header = &scaler_header,
    .body = {
      .hoffset = SCALERCFG_OVERLAY_H_OFFSET,
      .text = &scaler_overlay
    },
    .parent = &home_menu,
    .current_selection = 0,
    .number_selections = 10,
    .leaves = {
        {.id = SCALERCFG_INTERP_V_OFFSET     , .arrow_desc = &viscaling_opt_arrow, .leavetype = ICONFIG     , .config_value  = &interpolation_mode},
        {.id = SCALERCFG_IN2OUT_V_OFFSET     , .arrow_desc = &viscaling_opt_arrow, .leavetype = ICONFIG     , .config_value  = &scaling_selection},
        {.id = SCALERCFG_LINKVH_V_OFFSET     , .arrow_desc = &viscaling_opt_arrow, .leavetype = ICONFIG     , .config_value  = &link_hv_scale},
        {.id = SCALERCFG_VHSTEPS_V_OFFSET    , .arrow_desc = &viscaling_opt_arrow, .leavetype = ICONFIG     , .config_value  = &scaling_steps},
        {.id = SCALERCFG_VERTSCALE_V_OFFSET  , .arrow_desc = &viscaling_opt_arrow, .leavetype = ICFGCMDFUNC3, .cfgfct_call_3 = &cfgfct_scale},
        {.id = SCALERCFG_HORISCALE_V_OFFSET  , .arrow_desc = &viscaling_opt_arrow, .leavetype = ICFGCMDFUNC3, .cfgfct_call_3 = &cfgfct_scale},
        {.id = SCALERCFG_PALBOXED_V_OFFSET   , .arrow_desc = &viscaling_opt_arrow ,.leavetype = ICONFIG     , .config_value  = &pal_boxed_mode},
        {.id = SCALERCFG_INSHIFTMODE_V_OFFSET, .arrow_desc = &viscaling_opt_arrow, .leavetype = ICONFIG     , .config_value  = &timing_selection},
        {.id = SCALERCFG_VERTSHIFT_V_OFFSET  , .arrow_desc = &viscaling_opt_arrow, .leavetype = ICONFIG     , .config_value  = &vert_shift},
        {.id = SCALERCFG_HORISHIFT_V_OFFSET  , .arrow_desc = &viscaling_opt_arrow, .leavetype = ICONFIG     , .config_value  = &hor_shift}
    }
};

#define SCALING_PAGE_SELECTION  1
#define VHLINK_SELECTION        2
#define SCALING_STEPS_SELECTION 3
#define VERTSCALE_SELECTION     4
#define HORISCALE_SELECTION     5
#define PAL_BOXED_SELECTION     6
#define TIMING_PAGE_SELECTION   7
#define VERTSHIFT_SELECTION     8
#define HORSHIFT_SELECTION      9

menu_t vicfg_screen = {
    .type = CONFIG,
    .header = &vicfg_header,
    .body = {
      .hoffset = VICFG_OVERLAY_H_OFFSET,
      .text = &vicfg_overlay
    },
    .parent = &home_menu,
    .current_selection = 0,
    .number_selections = 8,
    .leaves = {
        {.id = VICFG_DEINTERL_V_OFFSET   , .arrow_desc = &vicfg_opt_arrow, .leavetype = ICONFIG , .config_value = &deinterlace_mode},
        {.id = VICFG_SCANLINE_V_OFFSET   , .arrow_desc = &vicfg_sel_arrow, .leavetype = ISUBMENU, .submenu = &slcfg_opt_subscreen},
        {.id = VICFG_GAMMA_V_OFFSET      , .arrow_desc = &vicfg_opt_arrow, .leavetype = ICONFIG , .config_value = &gamma_lut},
        {.id = VICFG_LIMITEDRGB_V_OFFSET , .arrow_desc = &vicfg_opt_arrow, .leavetype = ICONFIG , .config_value = &limited_rgb},
        {.id = VICFG_DEBLUR_V_OFFSET     , .arrow_desc = &vicfg_opt_arrow, .leavetype = ICONFIG , .config_value = &deblur_mode},
        {.id = VICFG_PCDEBLUR_V_OFFSET   , .arrow_desc = &vicfg_opt_arrow, .leavetype = ICONFIG , .config_value = &deblur_mode_powercycle},
        {.id = VICFG_16BITMODE_V_OFFSET  , .arrow_desc = &vicfg_opt_arrow, .leavetype = ICONFIG , .config_value = &mode16bit},
        {.id = VICFG_PC16BITMODE_V_OFFSET, .arrow_desc = &vicfg_opt_arrow, .leavetype = ICONFIG , .config_value = &mode16bit_powercycle}
    }
};

#define DEBLUR_CURRENT_SELECTION    4
#define DEBLUR_POWERCYCLE_SELECTION 5
#define M16BIT_CURRENT_SELECTION    6
#define M16BIT_POWERCYCLE_SELECTION 7

menu_t slcfg_opt_subscreen = {
    .type = CONFIG,
    .header = &slcfg_opt_header,
    .body = {
      .hoffset = SLCFG_OVERLAY_H_OFFSET,
      .text = &slcfg_opt_overlay
    },
    .parent = &vicfg_screen,
    .current_selection = 0,
    .number_selections = 8,
    .leaves = {
        {.id = SLCFG_INPUT_OFFSET      , .arrow_desc = &slcfg_opt_arrow0, .leavetype = ICONFIG , .config_value = &timing_selection},
        {.id = SLCFG_LINK_OFFSET       , .arrow_desc = &slcfg_opt_arrow1, .leavetype = ICONFIG , .config_value = &sl_link_480i},
        {.id = SLCFG_HEN_V_OFFSET      , .arrow_desc = &slcfg_opt_arrow1, .leavetype = ICONFIG , .config_value = &hsl_en},
        {.id = SLCFG_VEN_V_OFFSET      , .arrow_desc = &slcfg_opt_arrow1, .leavetype = ICONFIG , .config_value = &vsl_en},
        {.id = SLCFG_THICKNESS_V_OFFSET, .arrow_desc = &slcfg_opt_arrow1, .leavetype = ICONFIG , .config_value = &sl_thickness},
        {.id = SLCFG_SCALESOFT_V_OFFSET, .arrow_desc = &slcfg_opt_arrow1, .leavetype = ICONFIG , .config_value = &sl_scalesoftening},
        {.id = SLCFG_STR_V_OFFSET      , .arrow_desc = &slcfg_opt_arrow1, .leavetype = ICONFIG , .config_value = &sl_str},
        {.id = SLCFG_HYB_STR_V_OFFSET  , .arrow_desc = &slcfg_opt_arrow1, .leavetype = ICONFIG , .config_value = &slhyb_str},
        {.id = SLCFG_HEN_V_OFFSET      , .arrow_desc = &slcfg_opt_arrow1, .leavetype = ICONFIG , .config_value = &hsl_en_480i},
        {.id = SLCFG_VEN_V_OFFSET      , .arrow_desc = &slcfg_opt_arrow1, .leavetype = ICONFIG , .config_value = &vsl_en_480i},
        {.id = SLCFG_THICKNESS_V_OFFSET, .arrow_desc = &slcfg_opt_arrow1, .leavetype = ICONFIG , .config_value = &sl_thickness_480i},
        {.id = SLCFG_SCALESOFT_V_OFFSET, .arrow_desc = &slcfg_opt_arrow1, .leavetype = ICONFIG , .config_value = &sl_scalesoftening_480i},
        {.id = SLCFG_STR_V_OFFSET      , .arrow_desc = &slcfg_opt_arrow1, .leavetype = ICONFIG , .config_value = &sl_str_480i},
        {.id = SLCFG_HYB_STR_V_OFFSET  , .arrow_desc = &slcfg_opt_arrow1, .leavetype = ICONFIG , .config_value = &slhyb_str_480i}
    }
};

#define SL_INPUT_SELECTION           0
#define SL_LINK_SELECTION            1
#define SL_HEN_SELECTION             2
#define SL_VEN_SELECTION             3
#define SL_THICKNESS_SELECTION       4
#define SL_240P_TO_480I_OFFSET       6
#define SL_HEN_480I_SELECTION        8
#define SL_VEN_480I_SELECTION        9
#define SL_THICKNESS_480I_SELECTION 10

menu_t misc_screen = {
    .type = CONFIG,
    .header = &misc_header,
    .body = {
      .hoffset = MISC_OVERLAY_H_OFFSET,
      .text = &misc_overlay,
    },
    .parent = &home_menu,
    .current_selection = 0,
    .number_selections = 7,
    .leaves = {
        {.id = MISC_AUDIO_SWAP_LR_V_OFFSET , .arrow_desc = &misc_opt_arrow, .leavetype = ICONFIG    , .config_value = &audio_swap_lr},
//        {.id = MISC_AUDIO_FILTER_V_OFFSET  , .arrow_desc = &misc_opt_arrow, .leavetype = ICONFIG    , .config_value = &audio_filter},
        {.id = MISC_AUDIO_AMP_V_OFFSET     , .arrow_desc = &misc_opt_arrow, .leavetype = ICONFIG    , .config_value = &audio_amp},
        {.id = MISC_AUDIO_SPDIF_EN_V_OFFSET, .arrow_desc = &misc_opt_arrow, .leavetype = ICONFIG    , .config_value = &audio_spdif_en},
        {.id = MISC_IGR_RESET_V_OFFSET     , .arrow_desc = &misc_opt_arrow, .leavetype = ICONFIG    , .config_value = &igr_reset},
        {.id = MISC_IGR_DEBLUR_V_OFFSET    , .arrow_desc = &misc_opt_arrow, .leavetype = ICONFIG    , .config_value = &igr_deblur},
        {.id = MISC_IGR_16BITMODE_V_OFFSET , .arrow_desc = &misc_opt_arrow, .leavetype = ICONFIG    , .config_value = &igr_16bitmode},
        {.id = MISC_LUCKY_1440P_V_OFFSET   , .arrow_desc = &misc_opt_arrow, .leavetype = ICFGVALFUNC, .cfgfct_call_2 = &cfgfct_unlock1440p}
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
    .current_selection = 0,
    .number_selections = 5,
    .leaves = {
        {.id = RWDATA_SAVE_FL_V_OFFSET          , .arrow_desc = &rwdata_sel_arrow   , .leavetype = IFUNC1,  .sys_fun_bool_1 = &cfg_save_to_flash},
        {.id = RWDATA_LOAD_FL_V_OFFSET          , .arrow_desc = &rwdata_sel_arrow   , .leavetype = IFUNC1,  .sys_fun_bool_1 = &cfg_load_from_flash},
        {.id = RWDATA_LOAD_DEFAULT480P_V_OFFSET , .arrow_desc = &rwdata_sel_arrow   , .leavetype = IFUNC2,  .sys_fun_bool_2 = &cfg_load_defaults},
        {.id = RWDATA_LOAD_DEFAULT1080P_V_OFFSET, .arrow_desc = &rwdata_sel_arrow   , .leavetype = IFUNC2,  .sys_fun_bool_2 = &cfg_load_defaults},
        {.id = RWDATA_FALLBACK_V_OFFSET         , .arrow_desc = &rwdata_optval_arrow, .leavetype = ICONFIG, .config_value = &fallbackmode},
//        {.id = RWDATA_UPDATE_V_OFFSET           , .arrow_desc = &rwdata_optsel_arrow, .leavetype = IFUNC0, .sys_fun_0 = &fw_update}
    }
};

#define RW_LOAD_DEFAULT480P_SELECTION   2
#define RW_LOAD_DEFAULT1080P_SELECTION  3

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


static inline bool_t is_vires_screen (menu_t *menu)
  {  return (menu == &vires_screen); }
static inline bool_t is_viscaling_screen (menu_t *menu)
  {  return (menu == &viscaling_screen); }
static inline bool_t is_vicfg_screen (menu_t *menu)
  {  return (menu == &vicfg_screen); }
static inline bool_t is_slcfg_screen (menu_t *menu)
  {  return (menu == &slcfg_opt_subscreen); }
static inline bool_t is_vicfg_480i_sl_are_linked ()
  {  return (bool_t) cfg_get_value(&sl_link_480i,0); }
static inline bool_t is_about_screen (menu_t *menu)
  {  return (menu == &about_screen); }
static inline bool_t is_license_screen (menu_t *menu)
  {  return (menu == &license_screen); }


void val2txt_func(alt_u16 v) { sprintf(szText,"%u", v); };
void val2txt_4u_func(alt_u16 v) { sprintf(szText,"%4u", v); };
void val2txt_5b_binaryoffset_func(alt_u16 v) { if (v & 0x10) sprintf(szText," %2u", (v&0xF)); else sprintf(szText,"-%2u", (v^0xF)+1); };
void val2txt_scale_sel_func(alt_u16 v) {
  if (v == 0) {
    sprintf(szText,NTSCPAL_SEL[2]);
  } else {
    if (v < PAL_TO_288) {
      sprintf(szText,"NTSC to ");
      sprintf(&szText[8],Resolutions[v - NTSC_TO_240]);
    } else {
      sprintf(szText,"PAL to ");
      sprintf(&szText[7],Resolutions[v - PAL_TO_288]);
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

bool_t apply_sl_480i_offset(menu_t* current_menu) {
  return (is_slcfg_screen(current_menu) &&
          ((cfg_get_value(&timing_selection,0) == PPU_TIMING_CURRENT && scanmode == INTERLACED) ||
            cfg_get_value(&timing_selection,0) == NTSC_INTERLACED || cfg_get_value(&timing_selection,0) == PAL_INTERLACED) &&
          !is_vicfg_480i_sl_are_linked());
}


void print_current_timing_mode()
{
  vd_clear_info_area(0,COPYRIGHT_SIGN_H_OFFSET-1,0,0);
  sprintf(szText,"Current:");
  vd_print_string(VD_INFO,0, 0,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_NAVAJOWHITE,&szText[0]);
  val2txt_scale_sel_func(scaling_n64adv);
  vd_print_string(VD_INFO,9,0,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_NAVAJOWHITE,&szText[0]);
}

void print_ctrl_data() {
  sprintf(szText,"Ctrl.Data: 0x%08x",(uint) ctrl_data);
  vd_clear_info_area(0,COPYRIGHT_SIGN_H_OFFSET-1,0,0);
  vd_print_string(VD_INFO,0,0,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_NAVAJOWHITE,&szText[0]);
}

void print_cr_info() {
  vd_clear_info_area(COPYRIGHT_SIGN_H_OFFSET,VD_WIDTH-1,0,0);
  vd_print_string(VD_INFO,COPYRIGHT_H_OFFSET,COPYRIGHT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_DARKORANGE,copyright_note);
  vd_print_char(VD_INFO,COPYRIGHT_SIGN_H_OFFSET,COPYRIGHT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_DARKORANGE,(char) COPYRIGHT_SIGN);
}

void print_fw_version()
{
  alt_u16 ext_fw = (alt_u16) get_pcb_version();
  vd_print_string(VD_TEXT,VERSION_H_OFFSET,VERSION_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,pcb_rev[ext_fw]);

  sprintf(szText,"0x%08x%08x",(uint) get_chip_id(1),(uint) get_chip_id(0));
  vd_print_string(VD_TEXT,VERSION_H_OFFSET,VERSION_V_OFFSET+1,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,&szText[0]);

  ext_fw = get_hdl_version();
  sprintf(szText,"%1d.%02d",((ext_fw & HDL_FW_GETMAIN_MASK) >> HDL_FW_MAIN_OFFSET),
                            ((ext_fw & HDL_FW_GETSUB_MASK) >> HDL_FW_SUB_OFFSET));
  vd_print_string(VD_TEXT,VERSION_H_OFFSET,VERSION_V_OFFSET+2,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,&szText[0]);

  sprintf(szText,"%1d.%02d",SW_FW_MAIN,SW_FW_SUB);
  vd_print_string(VD_TEXT,VERSION_H_OFFSET,VERSION_V_OFFSET+3,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,&szText[0]);
}

void update_vmode_menu(menu_t *menu)
{
  if (is_vires_screen(menu)) {
    vmode_menu = cfg_get_value(&res_selection,0) == PPU_RES_CURRENT ? vmode_n64adv : (vmode_t) cfg_get_value(&res_selection,0);
  } else {
    switch (cfg_get_value(&timing_selection,0)) {
      case NTSC_PROGRESSIVE:
      case NTSC_INTERLACED:
        vmode_menu = NTSC;
        break;
      case PAL_PROGRESSIVE:
      case PAL_INTERLACED:
        vmode_menu = PAL;
        break;
      case PPU_TIMING_CURRENT:
      default:
        vmode_menu = vmode_n64adv;
        break;
    }
  }
}

updateaction_t modify_menu(cmd_t command, menu_t* *current_menu)
{

  updateaction_t todo = NON;

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
      (*current_menu)->current_selection = 1;
      return MENU_CLOSE;
    case CMD_MENU_BACK:
      cfg_reset_selections();
      if ((*current_menu)->parent) {
        (*current_menu)->current_selection = 0;
        *current_menu = (*current_menu)->parent;
        return NEW_OVERLAY;
      } else {
        (*current_menu)->current_selection = 1;
        return MENU_CLOSE;
      }
    case CMD_MENU_PAGE_RIGHT:
      if (is_vires_screen(*current_menu)) {
        cfg_inc_value(&res_selection);
        update_vmode_menu(*current_menu);
        cfg_load_linex_word(vmode_menu);
        todo = NEW_OVERLAY;
        break;
      }
      if (is_viscaling_screen(*current_menu)){
        if ((*current_menu)->current_selection >= SCALING_PAGE_SELECTION && (*current_menu)->current_selection < PAL_BOXED_SELECTION) {
          cfg_inc_value(&scaling_selection);
          scaling_menu = cfg_get_value(&scaling_selection,0);
          if (scaling_menu == PPU_SCALING_CURRENT) scaling_menu = scaling_n64adv;
          cfg_load_scaling_word(scaling_menu);
          todo = NEW_OVERLAY;
          break;
        }
//        if ((*current_menu)->current_selection >= TIMING_PAGE_SELECTION && (*current_menu)->current_selection <= HORSHIFT_SELECTION) {
        if ((*current_menu)->current_selection >= TIMING_PAGE_SELECTION) {
          cfg_inc_value(&timing_selection);
          timing_menu = cfg_get_value(&timing_selection,0);
          if (timing_menu == PPU_TIMING_CURRENT) timing_menu = timing_n64adv;
          cfg_load_timing_word(timing_menu);
          todo = NEW_OVERLAY;
          break;
        }
      }
      if (is_slcfg_screen(*current_menu)) {
        cfg_inc_value(&timing_selection);
        update_vmode_menu(*current_menu);
        cfg_load_linex_word(vmode_menu);
        todo = NEW_OVERLAY;
        break;
      }
      break;
    case CMD_MENU_PAGE_LEFT:
      if (is_vires_screen(*current_menu)) {
        cfg_dec_value(&res_selection);
        update_vmode_menu(*current_menu);
        cfg_load_linex_word(vmode_menu);
        todo = NEW_OVERLAY;
        break;
      }
      if (is_viscaling_screen(*current_menu)){
        if ((*current_menu)->current_selection >= SCALING_PAGE_SELECTION && (*current_menu)->current_selection < PAL_BOXED_SELECTION) {
          cfg_dec_value(&scaling_selection);
          scaling_menu = cfg_get_value(&scaling_selection,0);
          if (scaling_menu == PPU_SCALING_CURRENT) scaling_menu = scaling_n64adv;
          cfg_load_scaling_word(scaling_menu);
          todo = NEW_OVERLAY;
          break;
        }
//        if ((*current_menu)->current_selection >= TIMING_PAGE_SELECTION && (*current_menu)->current_selection <= HORSHIFT_SELECTION) {
        if ((*current_menu)->current_selection >= TIMING_PAGE_SELECTION) {
          cfg_dec_value(&timing_selection);
          timing_menu = cfg_get_value(&timing_selection,0);
          if (timing_menu == PPU_TIMING_CURRENT) timing_menu = timing_n64adv;
          cfg_load_timing_word(timing_menu);
          todo = NEW_OVERLAY;
          break;
        }
      }
      if (is_slcfg_screen(*current_menu)) {
        cfg_dec_value(&timing_selection);
        update_vmode_menu(*current_menu);
        cfg_load_linex_word(vmode_menu);
        todo = NEW_OVERLAY;
        break;
      }
      break;
    default:
      break;
  }

  if (((*current_menu)->type == TEXT) ||
      ((*current_menu)->type == VINFO)  )
    return NON;

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

  // menu specific modifications

  if (is_vires_screen(*current_menu)) {
    if ((unlock_1440p == FALSE) && (current_sel == RES_1440P_SELECTION))
      (*current_menu)->current_selection = (command == CMD_MENU_DOWN) ? RES_1440P_SELECTION + 1 : RES_1440P_SELECTION - 1;
    if (cfg_get_value(&low_latency_mode,0) == ON && (current_sel == FORCE5060_SELECTION))
      (*current_menu)->current_selection = (command == CMD_MENU_DOWN) ? 0 : FORCE5060_SELECTION - 1;
  }

  if (is_viscaling_screen(*current_menu)) {
    if ((scaling_menu == NTSC_TO_240) || (scaling_menu == PAL_TO_288)) {
      if (current_sel == VHLINK_SELECTION)
        (*current_menu)->current_selection = (command == CMD_MENU_DOWN) ? VHLINK_SELECTION + 1 : VHLINK_SELECTION - 1;
    } else {
      if((current_sel == HORISCALE_SELECTION) && (cfg_get_value(&link_hv_scale,0) == 0))
        (*current_menu)->current_selection = (command == CMD_MENU_DOWN) ? HORISCALE_SELECTION + 1 : HORISCALE_SELECTION - 1;
    }
  }

  if (apply_sl_480i_offset(*current_menu) && current_sel > SL_LINK_SELECTION) current_sel += SL_240P_TO_480I_OFFSET;
//
//  if (is_slcfg_screen(*current_menu)) {
//    if ((cfg_get_value(&timing_selection,0) == PPU_TIMING_CURRENT && scanmode == INTERLACED) ||
//         cfg_get_value(&timing_selection,0) == NTSC_INTERLACED || cfg_get_value(&timing_selection,0) == PAL_INTERLACED) {
//      current_sel = current_sel + (*current_menu)->number_selections; // apply offset
//      if (cfg_get_value(&sl_en_480i,0) == OFF) {
//        current_sel = (current_sel < SL_METHOD_480I_SELECTION) ? current_sel :
//                                    (command == CMD_MENU_DOWN) ? SL_INPUT_480I_SELECTION :
//                                                                 SL_EN_480I_SELECTION;
//        (*current_menu)->current_selection = current_sel - (*current_menu)->number_selections;
//      } else if (is_vicfg_480i_sl_are_linked() && current_sel > SL_EN_480I_SELECTION) { // options are linked; so use 240p/288p values instead for modifications
//        current_sel = current_sel - (*current_menu)->number_selections;
//        if (cfg_get_value(&sl_en,0) == OFF) {
//          current_sel = (command == CMD_MENU_DOWN) ? SL_INPUT_480I_SELECTION : SL_EN_480I_SELECTION;
//          (*current_menu)->current_selection = current_sel - (*current_menu)->number_selections;
//        }
//      }
//    } else {
//      if (cfg_get_value(&sl_en,0) == OFF)
//        (*current_menu)->current_selection = (current_sel < SL_METHOD_SELECTION) ? current_sel :
//                                                      (command == CMD_MENU_DOWN) ? SL_INPUT_SELECTION :
//                                                                                   SL_EN_SELECTION;
//    }
//  }


  if (todo == NEW_OVERLAY || todo == NEW_SELECTION) return todo;

  if ((*current_menu)->leaves[current_sel].leavetype == ISUBMENU) {
    switch (command) {
      case CMD_MENU_RIGHT:
      case CMD_MENU_ENTER:
        if ((*current_menu)->leaves[current_sel].submenu) { // check for existing submenu
          *current_menu = (*current_menu)->leaves[current_sel].submenu;
          return NEW_OVERLAY;
        }
        break;
      default:
        break;
    }
  }

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

  if ((*current_menu)->leaves[current_sel].leavetype == ICFGVALFUNC) {
    if (command == CMD_MENU_RIGHT) {
      (*current_menu)->leaves[current_sel].cfgfct_call_2(current_sel-1,1,0);  // at the moment only used in resolution menu, so this is correct
      return NEW_CONF_VALUE;
    }
  }
  if ((*current_menu)->leaves[current_sel].leavetype == ICFGCMDFUNC3) { // at the moment only used in scaling menu for horizontal and vertical scale
    if ((command == CMD_MENU_RIGHT) || (command == CMD_MENU_LEFT)) {
      (*current_menu)->leaves[current_sel].cfgfct_call_3(command,current_sel==VERTSCALE_SELECTION,1,0);
      return NEW_CONF_VALUE;
    }
  }

  if (((command == CMD_MENU_RIGHT) || (command == CMD_MENU_ENTER)) && ((*current_menu)->leaves[current_sel].leavetype >= IFUNC0)) {
    int retval = 0;
    if ((*current_menu)->leaves[current_sel].leavetype == IFUNC0) retval = (*current_menu)->leaves[current_sel].sys_fun_0();
    if ((*current_menu)->leaves[current_sel].leavetype == IFUNC1) retval = (*current_menu)->leaves[current_sel].sys_fun_1(1);
    if ((*current_menu)->leaves[current_sel].leavetype == IFUNC2) retval = (*current_menu)->leaves[current_sel].sys_fun_2(RW_LOAD_DEFAULT480P_SELECTION==(*current_menu)->current_selection,1);
    return (retval == 0                     ? RW_DONE  :
            retval == -CFG_FLASH_SAVE_ABORT ? RW_ABORT :
                                              RW_FAILED);
  }
  return NON;
}

void print_overlay(menu_t* current_menu)
{
  vd_clear_hdr();
  vd_clear_txt();

  if (current_menu->header) vd_wr_hdr(BACKGROUNDCOLOR_STANDARD,FONTCOLOR_DARKORANGE,*current_menu->header);
  vd_print_string(VD_TEXT,current_menu->body.hoffset,0,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,*current_menu->body.text);

  if (is_about_screen(current_menu)) print_fw_version();
  if (is_license_screen(current_menu)) vd_print_char(VD_TEXT,CR_SIGN_LICENSE_H_OFFSET,CR_SIGN_LICENSE_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,(char) COPYRIGHT_SIGN);
}

void print_selection_arrow(menu_t* current_menu)
{
  alt_u8 h_l_offset, h_r_offset;
  alt_u8 v_run, v_offset;

  for (v_run = 0; v_run < current_menu->number_selections; v_run++)
    if (current_menu->leaves[v_run].arrow_desc != NULL) {
      h_l_offset = current_menu->leaves[v_run].arrow_desc->hpos;
      h_r_offset = current_menu->leaves[v_run].arrow_desc->hpos + (current_menu->leaves[v_run].arrow_desc->shape->right != EMPTY);
      v_offset   = current_menu->leaves[v_run].id;
      if (v_run == current_menu->current_selection) {
        vd_print_char(VD_TEXT,h_r_offset,v_offset,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,(char) current_menu->leaves[v_run].arrow_desc->shape->right);
        vd_print_char(VD_TEXT,h_l_offset,v_offset,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,(char) current_menu->leaves[v_run].arrow_desc->shape->left);
      } else {
        vd_clear_txt_area(h_l_offset,h_l_offset,v_offset,v_offset);
        vd_clear_txt_area(h_r_offset,h_r_offset,v_offset,v_offset);
      }
    }
}

int update_vinfo_screen(menu_t* current_menu)
{
  if (current_menu->type != VINFO) return -1;

  // PPU state
  vd_clear_lineend(VD_TEXT,INFO_VALS_H_OFFSET,INFO_PPU_STATE_V_OFFSET);
  sprintf(szText,"0x%08x",(uint) ppu_state);
  vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET,INFO_PPU_STATE_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,&szText[0]);

  // Video Input
  vd_clear_lineend(VD_TEXT,INFO_VALS_H_OFFSET,INFO_VIN_V_OFFSET);
  vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET,INFO_VIN_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VideoMode[(palmode << 1) | scanmode]);
  vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET + 5,INFO_VIN_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VRefresh[palmode]);

  // Video Output
  linex_cnt linex_mode = (ppu_state & PPU_RESOLUTION_GETMASK) >> PPU_RESOLUTION_OFFSET;
  bool_t is_lowlatency_mode = ((ppu_state & PPU_LOWLATENCYMODE_GETMASK) >> PPU_LOWLATENCYMODE_OFFSET);
  alt_u8 force5060val = (ppu_state & PPU_FORCE5060_GETMASK) >> PPU_FORCE5060_OFFSET;
  bool_t is_50Hz_mode = (is_lowlatency_mode || (linex_mode == PASSTHROUGH) || (force5060val == 0x00)) ? palmode : (force5060val == 0x02);
  bool_t printhz4vga = FALSE;

  vd_clear_lineend(VD_TEXT,INFO_VALS_H_OFFSET,INFO_VOUT_V_OFFSET);
  switch (linex_mode) {
    case PASSTHROUGH:
      if (palmode) vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,Resolution288p576p[0]);
      else vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,Resolution240p480p[0]);
      break;
    case LineX2:
      if (is_50Hz_mode) {
        vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET    ,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,Resolution288p576p[1]);
      } else {
        if ((ppu_state & PPU_USE_VGA_FOR_480P_GETMASK) >> PPU_USE_VGA_FOR_480P_OFFSET) {
          vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET     ,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,ResolutionVGA);
          printhz4vga = TRUE;
        } else {
          vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET    ,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,Resolution240p480p[1]);
        }
      }
      break;
    default:
      vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET    ,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,Resolutions[linex_mode]);
  }
  if (printhz4vga) vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET + 14,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VRefresh[0]);
  else vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET + 5 + (linex_mode > LineX4),INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VRefresh[is_50Hz_mode]);

  // Image size
  sprintf(szText,"%ux%u", (alt_u16) ((scaling_words[scaling_n64adv-1].config_val & CFG_HORSCALE_GETMASK) >> CFG_HORSCALE_OFFSET),
                          (alt_u16) ((scaling_words[scaling_n64adv-1].config_val & CFG_VERTSCALE_GETMASK) >> CFG_VERTSCALE_OFFSET));
  vd_clear_lineend(VD_TEXT,INFO_VALS_H_OFFSET,INFO_VRES_V_OFFSET);
  vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET,INFO_VRES_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,&szText[0]);

  // Source-Sync. Mode
  vd_clear_lineend(VD_TEXT,INFO_VALS_H_OFFSET,INFO_LLM_V_OFFSET);
  vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET,INFO_LLM_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,OffOn[is_lowlatency_mode]);
  if (is_lowlatency_mode) {
    sprintf(szText,"(%d sl. buffered)",(uint) ((ppu_state & PPU_LLM_SLBUF_FB_GETMASK) >> PPU_LLM_SLBUF_FB_OFFSET));
    vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET+3,INFO_LLM_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,&szText[0]);
  }

  // 240p DeBlur
  vd_clear_lineend(VD_TEXT,INFO_VALS_H_OFFSET, INFO_DEBLUR_V_OFFSET);
  if (scanmode == INTERLACED) vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET,INFO_DEBLUR_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_GREY,text_480i_576i_br);
  else vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET, INFO_DEBLUR_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,OffOn[!hor_hires]);

  // Gamma Table
  gamma2txt_func((ppu_state & PPU_GAMMA_TABLE_GETMASK) >> PPU_GAMMA_TABLE_OFFSET);
  vd_clear_lineend(VD_TEXT,INFO_VALS_H_OFFSET,INFO_GAMMA_V_OFFSET);
  vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET,INFO_GAMMA_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,&szText[0]);

  return 0;
}


int update_cfg_screen(menu_t* current_menu)
{
  if (current_menu->type != CONFIG && current_menu->type != RWDATA) return -1;

  alt_u8 h_l_offset;
  alt_u8 v_run, v_offset;
  alt_u8 background_color, font_color;
  alt_u16 val_select, ref_val_select;
  bool_t val_is_ref;

  bool_t use_240p_288p = (scaling_menu == NTSC_TO_240) || (scaling_menu == PAL_TO_288);

  bool_t use_sl_480i_offset = apply_sl_480i_offset(current_menu);
  alt_u8 v_run_offset = 0;

  background_color = BACKGROUNDCOLOR_STANDARD;

  for (v_run = 0; v_run < current_menu->number_selections + v_run_offset; v_run++) {
    h_l_offset = current_menu->leaves[v_run].arrow_desc->hpos + 3;
    v_offset   = current_menu->leaves[v_run].id;

    if (use_sl_480i_offset && v_run > SL_LINK_SELECTION) {
      use_sl_480i_offset = FALSE;
      v_run += SL_240P_TO_480I_OFFSET;
      v_run_offset = SL_240P_TO_480I_OFFSET;
    }

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
          if (cfg_get_value(&low_latency_mode,0) == ON && v_run == FORCE5060_SELECTION) {
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
//            font_color = val_is_ref ? FONTCOLOR_GREY : FONTCOLOR_DARKGOLD;
//        }

        // check scaling menu
        if (is_viscaling_screen(current_menu) && use_240p_288p) {
          if (v_run == VHLINK_SELECTION) {
            val_select = 1;
            font_color = FONTCOLOR_GREY;
          }
        }

//        if (v_run == current_menu->current_selection)
        vd_clear_txt_area(h_l_offset,h_l_offset + OPT_WINDOW_WIDTH,v_offset,v_offset);

        if (current_menu->leaves[v_run].config_value->cfg_type == FLAGTXT ||
            current_menu->leaves[v_run].config_value->cfg_type == NUMVALUE ) {
          current_menu->leaves[v_run].config_value->val2char_func(val_select);
          vd_print_string(VD_TEXT,h_l_offset,v_offset,background_color,font_color,&szText[0]);
        } else {
          vd_print_string(VD_TEXT,h_l_offset,v_offset,background_color,font_color,current_menu->leaves[v_run].config_value->value_string[val_select]);
        }
        break;
      case ICFGVALFUNC:
      case ICFGCMDFUNC2:  // at the moment just in resolution screen
        val_select = current_menu->leaves[v_run].cfgfct_call_2(v_run-1,0,0) + 1;
        ref_val_select = current_menu->leaves[v_run].cfgfct_call_2(v_run-1,0,1) + 1;
        val_is_ref = ((val_select != v_run && ref_val_select != v_run) || val_select == ref_val_select);
        if (is_vires_screen(current_menu)) {
          flag2set_func(val_select == v_run);
          if ((unlock_1440p == FALSE) && (v_run == RES_1440P_SELECTION))
            font_color = FONTCOLOR_GREY;
          else
            font_color = val_is_ref ? FONTCOLOR_WHITE : FONTCOLOR_YELLOW;
        } else {
          flag2set_func(unlock_1440p);
          font_color = FONTCOLOR_WHITE;
        }
        vd_clear_txt_area(h_l_offset,h_l_offset + OPT_WINDOW_WIDTH,v_offset,v_offset);
        vd_print_string(VD_TEXT,h_l_offset,v_offset,background_color,font_color,&szText[0]);
        break;
      case ICFGCMDFUNC3:  // at the moment just for horizontal and vertical scale
        if (!use_240p_288p && v_run == HORISCALE_SELECTION && cfg_get_value(&link_hv_scale,0) == 0) {
          cfg_scale_v2h_update();
          val_select = current_menu->leaves[v_run].cfgfct_call_3(0,0,0,0);
          ref_val_select = current_menu->leaves[v_run].cfgfct_call_3(0,0,0,1);
          val2txt_4u_func(val_select);
          font_color = (val_select == ref_val_select) ? FONTCOLOR_GREY : FONTCOLOR_DARKGOLD;
        } else {
          val_select = current_menu->leaves[v_run].cfgfct_call_3(0,v_run==VERTSCALE_SELECTION,0,0);
          ref_val_select = current_menu->leaves[v_run].cfgfct_call_3(0,v_run==VERTSCALE_SELECTION,0,1);
          val_is_ref = (val_select == ref_val_select);
          val2txt_scale_func(val_select,v_run==VERTSCALE_SELECTION);
          font_color = val_is_ref ? FONTCOLOR_WHITE : FONTCOLOR_YELLOW;
        }
        vd_clear_txt_area(h_l_offset,h_l_offset + OPT_WINDOW_WIDTH,v_offset,v_offset);
        vd_print_string(VD_TEXT,h_l_offset,v_offset,background_color,font_color,&szText[0]);
        break;
      case ISUBMENU:
        font_color = FONTCOLOR_WHITE;
        vd_print_string(VD_TEXT,h_l_offset,v_offset,background_color,font_color,EnterSubMenu);
        break;
      case IFUNC0:
      case IFUNC1:
      case IFUNC2:
        font_color = FONTCOLOR_WHITE;
        vd_print_string(VD_TEXT,h_l_offset,v_offset,background_color,font_color,RunFunction);
        break;
      default:
        break;
    }
  }

  return 0;
}
