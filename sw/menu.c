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
extern alt_u8 use_flash;
extern vmode_t vmode_menu, vmode_n64adv;
extern cfg_timing_model_sel_type_t timing_menu, timing_n64adv;
extern cfg_scaler_in2out_sel_type_t scaling_menu, scaling_n64adv;


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
//    .number_selections = 11,
    .number_selections = 9,
    .leaves = {
        {.id = RESCFG_INPUT_V_OFFSET      , .arrow_desc = &vires_opt_arrow, .leavetype = ICONFIG, .config_value = &res_selection},
//        {.id = RESCFG_240P_V_OFFSET       , .arrow_desc = &vires_opt_arrow, .leavetype = ICFGFUNC, .cfgfct_call = &cfgfct_linex},
        {.id = RESCFG_480P_V_OFFSET       , .arrow_desc = &vires_opt_arrow, .leavetype = ICFGFUNC, .cfgfct_call = &cfgfct_linex},
        {.id = RESCFG_720P_V_OFFSET       , .arrow_desc = &vires_opt_arrow, .leavetype = ICFGFUNC, .cfgfct_call = &cfgfct_linex},
        {.id = RESCFG_960P_V_OFFSET       , .arrow_desc = &vires_opt_arrow, .leavetype = ICFGFUNC, .cfgfct_call = &cfgfct_linex},
        {.id = RESCFG_1080P_V_OFFSET      , .arrow_desc = &vires_opt_arrow, .leavetype = ICFGFUNC, .cfgfct_call = &cfgfct_linex},
        {.id = RESCFG_1200P_V_OFFSET      , .arrow_desc = &vires_opt_arrow, .leavetype = ICFGFUNC, .cfgfct_call = &cfgfct_linex},
//        {.id = RESCFG_1440P_V_OFFSET      , .arrow_desc = &vires_opt_arrow, .leavetype = ICFGFUNC, .cfgfct_call = &cfgfct_linex},
        {.id = RESCFG_USE_VGA_RES_V_OFFSET, .arrow_desc = &vires_opt_arrow, .leavetype = ICONFIG, .config_value = &vga_for_480p},
        {.id = RESCFG_USE_SRCSYNC_V_OFFSET, .arrow_desc = &vires_opt_arrow, .leavetype = ICONFIG, .config_value = &low_latency_mode},
        {.id = RESCFG_FORCE_5060_V_OFFSET , .arrow_desc = &vires_opt_arrow, .leavetype = ICONFIG, .config_value = &linex_force_5060}
    }
};

#define FORCE5060_SELECTION 8

menu_t viscaling_screen = {
    .type = CONFIG,
    .header = &scaler_header,
    .body = {
      .hoffset = SCALERCFG_OVERLAY_H_OFFSET,
      .text = &scaler_overlay
    },
    .parent = &home_menu,
    .current_selection = 0,
    .number_selections = 9,
    .leaves = {
        {.id = SCALERCFG_IN2OUT_V_OFFSET     , .arrow_desc = &viscaling_opt_arrow, .leavetype = ICONFIG, .config_value = &scaling_selection},
        {.id = SCALERCFG_INTERP_V_OFFSET     , .arrow_desc = &viscaling_opt_arrow, .leavetype = ICONFIG, .config_value = &interpolation_mode},
        {.id = SCALERCFG_LINKVH_V_OFFSET     , .arrow_desc = &viscaling_opt_arrow, .leavetype = ICONFIG, .config_value = &link_hv_scale},
//        {.id = SCALERCFG_VHSTEPS_V_OFFSET    , .arrow_desc = &viscaling_opt_arrow, .leavetype = ICONFIG, .config_value = &scaling_steps},
        {.id = SCALERCFG_VERTSCALE_V_OFFSET  , .arrow_desc = &viscaling_opt_arrow, .leavetype = ICONFIG, .config_value = &vert_scale},
        {.id = SCALERCFG_HORISCALE_V_OFFSET  , .arrow_desc = &viscaling_opt_arrow, .leavetype = ICONFIG, .config_value = &hor_scale},
        {.id = SCALERCFG_PALBOXED_V_OFFSET   , .arrow_desc = &viscaling_opt_arrow ,.leavetype = ICONFIG, .config_value = &pal_boxed_mode},
        {.id = SCALERCFG_INSHIFTMODE_V_OFFSET, .arrow_desc = &viscaling_opt_arrow, .leavetype = ICONFIG, .config_value = &timing_selection},
        {.id = SCALERCFG_VERTSHIFT_V_OFFSET  , .arrow_desc = &viscaling_opt_arrow, .leavetype = ICONFIG, .config_value = &vert_shift},
        {.id = SCALERCFG_HORISHIFT_V_OFFSET  , .arrow_desc = &viscaling_opt_arrow, .leavetype = ICONFIG, .config_value = &hor_shift}
    }
};

#define SCALING_PAGE_SELECTION  0
#define VERTSCALE_SELECTION     3
#define HORISCALE_SELECTION     4
#define PAL_BOX_SELECTION       5
#define TIMING_PAGE_SELECTION   6
#define VERTSHIFT_SELECTION     7
#define HORSHIFT_SELECTION      8

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
    .number_selections = 6,
    .leaves = {
        {.id = SLCFG_INPUT_OFFSET    , .arrow_desc = &slcfg_opt_arrow0, .leavetype = ICONFIG , .config_value = &scanline_selection},
        {.id = SLCFG_EN_V_OFFSET     , .arrow_desc = &slcfg_opt_arrow1, .leavetype = ICONFIG , .config_value = &sl_en},
        {.id = SLCFG_METHOD_V_OFFSET , .arrow_desc = &slcfg_opt_arrow1, .leavetype = ICONFIG , .config_value = &sl_method},
        {.id = SLCFG_ID_V_OFFSET     , .arrow_desc = &slcfg_opt_arrow1, .leavetype = ICONFIG , .config_value = &sl_id},
        {.id = SLCFG_STR_V_OFFSET    , .arrow_desc = &slcfg_opt_arrow1, .leavetype = ICONFIG , .config_value = &sl_str},
        {.id = SLCFG_HYB_STR_V_OFFSET, .arrow_desc = &slcfg_opt_arrow1, .leavetype = ICONFIG , .config_value = &slhyb_str},
        {.id = SLCFG_INPUT_OFFSET    , .arrow_desc = &slcfg_opt_arrow0, .leavetype = ICONFIG , .config_value = &scanline_selection},
        {.id = SLCFG_EN_V_OFFSET     , .arrow_desc = &slcfg_opt_arrow1, .leavetype = ICONFIG , .config_value = &sl_en_480i},
        {.id = SLCFG_METHOD_V_OFFSET , .arrow_desc = &slcfg_opt_arrow1, .leavetype = ICONFIG , .config_value = &sl_method_480i},
        {.id = SLCFG_ID_V_OFFSET     , .arrow_desc = &slcfg_opt_arrow1, .leavetype = ICONFIG , .config_value = &sl_id_480i},
        {.id = SLCFG_STR_V_OFFSET    , .arrow_desc = &slcfg_opt_arrow1, .leavetype = ICONFIG , .config_value = &sl_str_480i},
        {.id = SLCFG_HYB_STR_V_OFFSET, .arrow_desc = &slcfg_opt_arrow1, .leavetype = ICONFIG , .config_value = &slhyb_str_480i}
    }
};

#define SL_INPUT_SELECTION        0
#define SL_EN_SELECTION           1
#define SL_METHOD_SELECTION       2
#define SL_INPUT_480I_SELECTION   6
#define SL_EN_480I_SELECTION      7
#define SL_LINKED_480I_SELECTION  7
#define SL_METHOD_480I_SELECTION  8

menu_t misc_screen = {
    .type = CONFIG,
    .header = &misc_header,
    .body = {
      .hoffset = MISC_OVERLAY_H_OFFSET,
      .text = &misc_overlay,
    },
    .parent = &home_menu,
    .current_selection = 0,
    .number_selections = 6,
    .leaves = {
        {.id = MISC_AUDIO_SWAP_LR_V_OFFSET , .arrow_desc = &misc_opt_arrow, .leavetype = ICONFIG, .config_value = &audio_swap_lr},
//        {.id = MISC_AUDIO_FILTER_V_OFFSET  , .arrow_desc = &misc_opt_arrow, .leavetype = ICONFIG, .config_value = &audio_filter},
        {.id = MISC_AUDIO_AMP_V_OFFSET     , .arrow_desc = &misc_opt_arrow, .leavetype = ICONFIG, .config_value = &audio_amp},
        {.id = MISC_AUDIO_SPDIF_EN_V_OFFSET, .arrow_desc = &misc_opt_arrow, .leavetype = ICONFIG, .config_value = &audio_spdif_en},
        {.id = MISC_IGR_RESET_V_OFFSET     , .arrow_desc = &misc_opt_arrow, .leavetype = ICONFIG, .config_value = &igr_reset},
        {.id = MISC_IGR_DEBLUR_V_OFFSET    , .arrow_desc = &misc_opt_arrow, .leavetype = ICONFIG, .config_value = &igr_deblur},
        {.id = MISC_IGR_16BITMODE_V_OFFSET , .arrow_desc = &misc_opt_arrow, .leavetype = ICONFIG, .config_value = &igr_16bitmode}
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


static inline alt_u8 is_vires_screen (menu_t *menu)
  {  return (menu == &vires_screen); }
static inline alt_u8 is_viscaling_screen (menu_t *menu)
  {  return (menu == &viscaling_screen); }
static inline alt_u8 is_vicfg_screen (menu_t *menu)
  {  return (menu == &vicfg_screen); }
static inline alt_u8 is_slcfg_screen (menu_t *menu)
  {  return (menu == &slcfg_opt_subscreen); }
static inline alt_u8 is_vicfg_480i_sl_are_linked ()
  {  return ( cfg_get_value(&sl_en_480i,0) == CFG_480I_SL_EN_MAX_VALUE); }
static inline alt_u8 is_about_screen (menu_t *menu)
  {  return (menu == &about_screen); }
static inline alt_u8 is_license_screen (menu_t *menu)
  {  return (menu == &license_screen); }


void val2txt_func(alt_u16 v) { sprintf(szText,"%u", v); };
void val2txt_5b_binaryoffset_func(alt_u16 v) { if (v & 0x10) sprintf(szText," %2u", (v&0xF)); else sprintf(szText,"-%2u", (v^0xF)+1); };
void val2txt_scale_sel_func(alt_u16 v) {
  if (v == 0) {
    sprintf(szText,NTSCPAL_SEL[2]);
  } else {
    if (v < PAL_TO_576) {
      sprintf(szText,"NTSC to ");
      sprintf(&szText[8],Resolutions[v - NTSC_TO_480]);
    } else {
      sprintf(szText,"PAL to ");
      sprintf(&szText[7],Resolutions[v - PAL_TO_576]);
    }
  }
};

void val2txt_hscale_func(alt_u16 v) { sprintf(szText,"%1u.%03ux", v/8+1, 125*(v&7)); };
void val2txt_vscale_func(alt_u16 v) { sprintf(szText,"%1u.%02ux", v/4+2, 25*(v&3)); };
void audioamp2txt_func(alt_u16 v) { if (v < 19) sprintf(szText,"-%02udB",19-v); else sprintf(szText," %02udB",v-19); };
void flag2set_func(alt_u16 v) { sprintf(szText,"[ ]"); if (v) szText[1] = (char) CHECKBOX_TICK; };
void scanline_str2txt_func(alt_u16 v) { v++; sprintf(szText,"%3u.%02u%%", (v*625)/100, 25*(v&3)); };
void scanline_hybrstr2txt_func(alt_u16 v) { sprintf(szText,"%3u.%02u%%", (v*625)/100, 25*(v&3)); };
void gamma2txt_func(alt_u16 v) { sprintf(szText,"%u.%02u", v > 4, 5* v + 75 - (100 * (v > 4))); };


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
    switch (cfg_get_value(&scanline_selection,0)) {
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
      while ((*current_menu)->parent) {
        (*current_menu)->current_selection = 0;
        *current_menu = (*current_menu)->parent;
      }
      (*current_menu)->current_selection = 1;
      return MENU_CLOSE;
    case CMD_MENU_BACK:
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
        if ((*current_menu)->current_selection < TIMING_PAGE_SELECTION) {
          cfg_inc_value(&scaling_selection);
          scaling_menu = cfg_get_value(&scaling_selection,0);
          if (scaling_menu == PPU_SCALING_CURRENT) scaling_menu = scaling_n64adv;
          cfg_load_scaling_word(scaling_menu);
        } else {
          cfg_inc_value(&timing_selection);
          timing_menu = cfg_get_value(&timing_selection,0);
          if (timing_menu == PPU_TIMING_CURRENT) timing_menu = timing_n64adv;
          cfg_load_timing_word(timing_menu);
        }
        todo = NEW_OVERLAY;
        break;
      }
      if (is_slcfg_screen(*current_menu)) {
        cfg_inc_value(&scanline_selection);
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
        if ((*current_menu)->current_selection < TIMING_PAGE_SELECTION) {
          cfg_dec_value(&scaling_selection);
          scaling_menu = cfg_get_value(&scaling_selection,0);
          if (scaling_menu == PPU_SCALING_CURRENT) scaling_menu = scaling_n64adv;
          cfg_load_scaling_word(scaling_menu);
        } else {
          cfg_dec_value(&timing_selection);
          timing_menu = cfg_get_value(&timing_selection,0);
          if (timing_menu == PPU_TIMING_CURRENT) timing_menu = timing_n64adv;
          cfg_load_timing_word(timing_menu);
        }
        todo = NEW_OVERLAY;
        break;
      }
      if (is_slcfg_screen(*current_menu)) {
        cfg_dec_value(&scanline_selection);
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
    if (cfg_get_value(&low_latency_mode,0) == ON && current_sel == FORCE5060_SELECTION)
      (*current_menu)->current_selection = (command == CMD_MENU_DOWN) ? 0 : FORCE5060_SELECTION - 1;
  }

  if (is_slcfg_screen(*current_menu)) {
    if ((cfg_get_value(&scanline_selection,0) == PPU_TIMING_CURRENT && scanmode == INTERLACED) ||
         cfg_get_value(&scanline_selection,0) == NTSC_INTERLACED || cfg_get_value(&scanline_selection,0) == PAL_INTERLACED) {
      current_sel = current_sel + (*current_menu)->number_selections; // apply offset
      if (cfg_get_value(&sl_en_480i,0) == OFF) {
        current_sel = (current_sel < SL_METHOD_480I_SELECTION) ? current_sel :
                                    (command == CMD_MENU_DOWN) ? SL_INPUT_480I_SELECTION :
                                                                 SL_EN_480I_SELECTION;
        (*current_menu)->current_selection = current_sel - (*current_menu)->number_selections;
      } else if (is_vicfg_480i_sl_are_linked() && current_sel > SL_EN_480I_SELECTION) { // options are linked; so use 240p/288p values instead for modifications
        current_sel = current_sel - (*current_menu)->number_selections;
        if (cfg_get_value(&sl_en,0) == OFF) {
          current_sel = (command == CMD_MENU_DOWN) ? SL_INPUT_480I_SELECTION : SL_EN_480I_SELECTION;
          (*current_menu)->current_selection = current_sel - (*current_menu)->number_selections;
        }
      }
    } else {
      if (cfg_get_value(&sl_en,0) == OFF)
        (*current_menu)->current_selection = (current_sel < SL_METHOD_SELECTION) ? current_sel :
                                                      (command == CMD_MENU_DOWN) ? SL_INPUT_SELECTION :
                                                                                   SL_EN_SELECTION;
    }
  }



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

  if ((*current_menu)->leaves[current_sel].leavetype == ICFGFUNC) { // at the moment only used in resolution menu
    switch (command) {
      case CMD_MENU_RIGHT:
        (*current_menu)->leaves[current_sel].cfgfct_call(current_sel-1,1,0);
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


  if (((command == CMD_MENU_RIGHT) || (command == CMD_MENU_ENTER)) && ((*current_menu)->leaves[current_sel].leavetype >= IFUNC0)) {
    int retval = 0;
    if ((*current_menu)->leaves[current_sel].leavetype == IFUNC0) retval = (*current_menu)->leaves[current_sel].sys_fun_0();
    if ((*current_menu)->leaves[current_sel].leavetype == IFUNC1) retval = (*current_menu)->leaves[current_sel].sys_fun_1(1);
    if ((*current_menu)->leaves[current_sel].leavetype == IFUNC2) retval = (*current_menu)->leaves[current_sel].sys_fun_2(RW_LOAD_DEFAULT1080P_SELECTION==(*current_menu)->current_selection,1);
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

  switch (current_menu->type) {
    case HOME:
    case CONFIG:
    case VINFO:
    case RWDATA:
      vd_print_string(VD_INFO,COPYRIGHT_H_OFFSET,COPYRIGHT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_DARKORANGE,copyright_note);
      vd_print_char(VD_INFO,COPYRIGHT_SIGN_H_OFFSET,COPYRIGHT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_DARKORANGE,(char) COPYRIGHT_SIGN);
      break;
    case TEXT:
      if (is_about_screen(current_menu)) print_fw_version();
      if (is_license_screen(current_menu)) vd_print_char(VD_TEXT,CR_SIGN_LICENSE_H_OFFSET,CR_SIGN_LICENSE_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,(char) COPYRIGHT_SIGN);
      break;
    default:
      break;
  }
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

  alt_u8 str_select;

  // PPU state
  vd_clear_lineend(VD_TEXT,INFO_VALS_H_OFFSET,INFO_PPU_STATE_V_OFFSET);
  sprintf(szText,"0x%08x",(uint) ppu_state);
  vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET,INFO_PPU_STATE_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,&szText[0]);

  // Video Input
  str_select = (palmode << 1) | scanmode;
  vd_clear_lineend(VD_TEXT,INFO_VALS_H_OFFSET,INFO_VIN_V_OFFSET);
  vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET,INFO_VIN_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VideoMode[str_select]);
  vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET + 5,INFO_VIN_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VRefresh[palmode]);

  // Video Output
  alt_u8 ppu_output_res_val = ((ppu_state & (PPU_FORCE5060_GETMASK | PPU_USE_VGA_FOR_480P_GETMASK | PPU_RESOLUTION_GETMASK)) >> PPU_RESOLUTION_OFFSET);
  vd_clear_lineend(VD_TEXT,INFO_VALS_H_OFFSET,INFO_VOUT_V_OFFSET);
  switch (ppu_output_res_val) { // 2bit 50/60, 1 bit VGA, 3 bit resolution
    case 0b000000:
      if (palmode) vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,Resolution576p);
      else vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,Resolution480p);
      vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET + 5,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VRefresh[palmode]);
      break;
    case 0b001000:
      if (palmode) {
        vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET    ,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,Resolution576p);
        vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET + 5,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VRefresh[1]);
      }
      else {
        vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET     ,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,ResolutionVGA);
        vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET + 14,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VRefresh[0]);
      }
      break;
    case 0b010000:
      vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET    ,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,Resolution480p);
      vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET + 5,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VRefresh[0]);
      break;
    case 0b011000:
      vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET     ,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,ResolutionVGA);
      vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET + 14,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VRefresh[0]);
      break;
    case 0b100000:
    case 0b101000:
      vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET    ,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,Resolution576p);
      vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET + 5,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VRefresh[1]);
      break;
    case 0b000001:
    case 0b001001:
      vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET    ,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,Resolutions[1]);
      vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET + 5,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VRefresh[palmode]);
      break;
    case 0b010001:
    case 0b011001:
      vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET    ,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,Resolutions[1]);
      vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET + 5,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VRefresh[0]);
      break;
    case 0b100001:
    case 0b101001:
      vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET    ,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,Resolutions[1]);
      vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET + 5,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VRefresh[1]);
      break;
    case 0b000010:
    case 0b001010:
      vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET    ,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,Resolutions[2]);
      vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET + 6,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VRefresh[palmode]);
      break;
    case 0b010010:
    case 0b011010:
      vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET    ,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,Resolutions[2]);
      vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET + 6,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VRefresh[0]);
      break;
    case 0b100010:
    case 0b101010:
      vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET    ,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,Resolutions[2]);
      vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET + 6,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VRefresh[1]);
      break;
    case 0b000011:
    case 0b001011:
      vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET    ,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,Resolutions[3]);
      vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET + 6,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VRefresh[palmode]);
      break;
    case 0b010011:
    case 0b011011:
      vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET    ,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,Resolutions[3]);
      vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET + 6,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VRefresh[0]);
      break;
    case 0b100011:
    case 0b101011:
      vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET    ,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,Resolutions[3]);
      vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET + 6,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VRefresh[1]);
      break;
    case 0b000100:
    case 0b001100:
      vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET    ,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,Resolutions[4]);
      vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET + 6,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VRefresh[palmode]);
      break;
    case 0b010100:
    case 0b011100:
      vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET    ,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,Resolutions[4]);
      vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET + 6,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VRefresh[0]);
      break;
    case 0b100100:
    case 0b101100:
      vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET    ,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,Resolutions[4]);
      vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET + 6,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VRefresh[1]);
      break;
    default:
      vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_GREY,not_available);
  }

  // Source-Sync. Mode
  str_select = ((ppu_state & PPU_LOWLATENCYMODE_GETMASK) >> PPU_LOWLATENCYMODE_OFFSET);
  vd_clear_lineend(VD_TEXT,INFO_VALS_H_OFFSET,INFO_LLM_V_OFFSET);
  vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET,INFO_LLM_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,OffOn[str_select]);
  if (str_select) {
    sprintf(szText,"(%d sl. buffered)",(uint) ((ppu_state & PPU_LLM_SLBUF_FB_GETMASK) >> PPU_LLM_SLBUF_FB_OFFSET));
    vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET+3,INFO_LLM_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,&szText[0]);
  }

  // 240p DeBlur
  vd_clear_lineend(VD_TEXT,INFO_VALS_H_OFFSET, INFO_DEBLUR_V_OFFSET);
  if (scanmode == INTERLACED) {
    vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET,INFO_DEBLUR_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_GREY,text_480i_576i_br);
  } else {
    str_select = ((ppu_state & PPU_240P_DEBLUR_GETMASK) >> PPU_240P_DEBLUR_OFFSET);
    vd_print_string(VD_TEXT,INFO_VALS_H_OFFSET, INFO_DEBLUR_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,OffOn[str_select]);
  }

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
  cfg_offon_t val_is_ref;

  cfg_offon_t use_sl_linked_vals = OFF;
  alt_u8 v_run_offset = 0;
  if (is_slcfg_screen(current_menu)) {
    if ((cfg_get_value(&scanline_selection,0) == PPU_TIMING_CURRENT && scanmode == INTERLACED) ||
         cfg_get_value(&scanline_selection,0) == NTSC_INTERLACED || cfg_get_value(&scanline_selection,0) == PAL_INTERLACED) {
      v_run_offset = (current_menu)->number_selections;
      if (is_vicfg_480i_sl_are_linked()) use_sl_linked_vals = ON;
    }
  }

  background_color = BACKGROUNDCOLOR_STANDARD;

  for (v_run = v_run_offset; v_run < current_menu->number_selections + v_run_offset; v_run++) {
    h_l_offset = current_menu->leaves[v_run].arrow_desc->hpos + 3;
    v_offset   = current_menu->leaves[v_run].id;

    if (use_sl_linked_vals && v_run_offset > 0 && v_run > SL_LINKED_480I_SELECTION) {
      v_run = v_run - v_run_offset;
      v_run_offset = 0;
    }


    switch (current_menu->leaves[v_run].leavetype) {
      case ICONFIG:
        val_select = cfg_get_value(current_menu->leaves[v_run].config_value,0);
        ref_val_select = cfg_get_value(current_menu->leaves[v_run].config_value,use_flash);
        if (is_vicfg_screen(current_menu)){
          if (v_run == DEBLUR_CURRENT_SELECTION    || v_run == M16BIT_CURRENT_SELECTION   ) ref_val_select = val_select;
          if (v_run == DEBLUR_POWERCYCLE_SELECTION || v_run == M16BIT_POWERCYCLE_SELECTION) ref_val_select = cfg_get_value(current_menu->leaves[v_run-1].config_value,use_flash);
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

        // check scanline screen
        if (is_slcfg_screen(current_menu)) {
          if (((cfg_get_value(&sl_en,0) == OFF) && v_run > SL_EN_SELECTION && v_run < SL_INPUT_480I_SELECTION)        ||
              ((cfg_get_value(&sl_en_480i,0) == OFF) && v_run > SL_EN_480I_SELECTION )                                ||
              (use_sl_linked_vals && v_run_offset == 0 && (cfg_get_value(&sl_en,0) == OFF) && v_run > SL_EN_SELECTION) )
            font_color = val_is_ref ? FONTCOLOR_GREY : FONTCOLOR_DARKGOLD;
        }

        // check scaling menu
        if (is_viscaling_screen(current_menu)) {
          if (v_run == HORISCALE_SELECTION && cfg_get_value(&link_hv_scale,0)) {
            val_select = cfg_get_value(current_menu->leaves[v_run-1].config_value,0);
            ref_val_select = cfg_get_value(current_menu->leaves[v_run-1].config_value,use_flash);
            font_color = (val_select == ref_val_select) ? FONTCOLOR_GREY : FONTCOLOR_DARKGOLD;
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
      case ICFGFUNC:
        val_select = current_menu->leaves[v_run].cfgfct_call(v_run-1,0,0) + 1;
        ref_val_select = current_menu->leaves[v_run].cfgfct_call(v_run-1,0,1) + 1;
        val_is_ref = ((val_select != v_run && ref_val_select != v_run) || val_select == ref_val_select);
        font_color = val_is_ref ? FONTCOLOR_WHITE : FONTCOLOR_YELLOW;
        flag2set_func(val_select == v_run);
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
