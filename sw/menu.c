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
#include "n64.h"
#include "config.h"
#include "menu.h"

#include "textdefs_p.h"
#include "vd_driver.h"
#include "fw.h"

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

static const arrow_t vicfg_sel_arrow = {
    .shape = &selection_arrow,
    .hpos = (VICFG_VALS_H_OFFSET - 2)
};

static const arrow_t vicfg_opt_arrow = {
    .shape = &optval_arrow,
    .hpos = (VICFG_VALS_H_OFFSET - 2)
};

static const arrow_t vicfg_res_opt_arrow0 = {
    .shape = &optval_arrow,
    .hpos = (VICFG_RES_VALS_H_OFFSET - 17)
};

static const arrow_t vicfg_res_opt_arrow1 = {
    .shape = &optval_arrow,
    .hpos = (VICFG_RES_VALS_H_OFFSET - 2)
};

static const arrow_t vicfg_res_sel_arrow1 = {
    .shape = &selection_arrow,
    .hpos = (VICFG_RES_VALS_H_OFFSET - 2)
};

static const arrow_t vicfg_sl_opt_arrow0 = {
    .shape = &optval_arrow,
    .hpos = (VICFG_SL_VALS_H_OFFSET - 11)
};

static const arrow_t vicfg_sl_opt_arrow1 = {
    .shape = &optval_arrow,
    .hpos = (VICFG_SL_VALS_H_OFFSET - 2)
};

static const arrow_t vicfg_timing_opt_arrow0 = {
    .shape = &optval_arrow,
    .hpos = (VICFG_VTIMSUB_VALS_H_OFFSET - 6)
};

static const arrow_t vicfg_timing_opt_arrow1 = {
    .shape = &optval_arrow,
    .hpos = (VICFG_VTIMSUB_VALS_H_OFFSET - 2)
};

static const arrow_t vicfg_timing_sel_arrow1 = {
    .shape = &selection_arrow,
    .hpos = (VICFG_VTIMSUB_VALS_H_OFFSET - 2)
};

static const arrow_t vicfg_scaling_opt_arrow0 = {
    .shape = &optval_arrow,
    .hpos = (VICFG_SCALESUB_VALS_H_OFFSET - 11)
};

static const arrow_t vicfg_scaling_opt_arrow1 = {
    .shape = &optval_arrow,
    .hpos = (VICFG_SCALESUB_VALS_H_OFFSET - 2)
};

static const arrow_t misc_opt_arrow = {
    .shape = &optval_arrow,
    .hpos = (MISC_VALS_H_OFFSET - 2)
};
menu_t home_menu, vinfo_screen, vicfg1_screen, vicfg2_screen, vicfg_res_subscreen, vicfg_scanline_opt_subscreen,
       vicfg_timing_subscreen, vicfg_scaling_subscreen, misc_screen, rwdata_screen, about_screen, thanks_screen, license_screen;


menu_t home_menu = {
    .type = HOME,
    .header  = &home_header,
    .overlay = &home_overlay,
    .current_selection = 1,
    .number_selections = 7,
    .leaves = {
        {.id = MAIN2VINFO_V_OFFSET  , .arrow_desc = &front_sel_arrow, .leavetype = ISUBMENU, .submenu = &vinfo_screen},
        {.id = MAIN2CFG_V_OFFSET    , .arrow_desc = &front_sel_arrow, .leavetype = ISUBMENU, .submenu = &vicfg1_screen},
        {.id = MAIN2MISC_V_OFFSET   , .arrow_desc = &front_sel_arrow, .leavetype = ISUBMENU, .submenu = &misc_screen},
        {.id = MAIN2SAVE_V_OFFSET   , .arrow_desc = &front_sel_arrow, .leavetype = ISUBMENU, .submenu = &rwdata_screen},
        {.id = MAIN2ABOUT_V_OFFSET  , .arrow_desc = &front_sel_arrow, .leavetype = ISUBMENU, .submenu = &about_screen},
        {.id = MAIN2THANKS_V_OFFSET , .arrow_desc = &front_sel_arrow, .leavetype = ISUBMENU, .submenu = &thanks_screen},
        {.id = MAIN2LICENSE_V_OFFSET, .arrow_desc = &front_sel_arrow, .leavetype = ISUBMENU, .submenu = &license_screen}
    }
};

#define VICONFIG_SUBMENU_SELECTION  1
#define MISC_SUBMENU_SELECTION      2

menu_t vinfo_screen = {
    .type = VINFO,
    .header = &vinfo_header,
    .overlay = &vinfo_overlay,
    .parent = &home_menu
};

menu_t vicfg1_screen = {
    .type = CONFIG,
    .header = &vicfg1_header,
    .overlay = &vicfg1_overlay,
    .parent = &home_menu,
    .current_selection = 0,
    .number_selections = 5,
    .leaves = {
        {.id = VICFG1_RESOLUTION_V_OFFSET, .arrow_desc = &vicfg_sel_arrow, .leavetype = ISUBMENU, .submenu = &vicfg_res_subscreen},
        {.id = VICFG1_SCANLINES_V_OFFSET , .arrow_desc = &vicfg_sel_arrow, .leavetype = ISUBMENU, .submenu = &vicfg_scanline_opt_subscreen},
        {.id = VICFG1_SCALER_OPT_V_OFFSET, .arrow_desc = &vicfg_sel_arrow, .leavetype = ISUBMENU, .submenu = &vicfg_scaling_subscreen},
        {.id = VICFG1_TIMING_V_OFFSET    , .arrow_desc = &vicfg_sel_arrow, .leavetype = ISUBMENU, .submenu = &vicfg_timing_subscreen},
        {.id = VICFG1_PAGE2_V_OFFSET     , .arrow_desc = &vicfg_sel_arrow, .leavetype = ISUBMENU, .submenu = &vicfg2_screen}
    }
};

menu_t vicfg2_screen = {
    .type = CONFIG,
    .header = &vicfg2_header,
    .overlay = &vicfg2_overlay,
    .parent = &home_menu,
    .current_selection = 6,
    .number_selections = 7,
    .leaves = {
        {.id = VICFG2_GAMMA_V_OFFSET         , .arrow_desc = &vicfg_opt_arrow, .leavetype = ICONFIG , .config_value = &gamma_lut},
        {.id = VICFG2_LIMRGB_V_OFFSET        , .arrow_desc = &vicfg_opt_arrow, .leavetype = ICONFIG , .config_value = &limited_rgb},
        {.id = VICFG2_DEBLURMODE_V_OFFSET    , .arrow_desc = &vicfg_opt_arrow, .leavetype = ICONFIG , .config_value = &deblur_mode},
        {.id = VICFG2_DEBLURMODE_DEF_V_OFFSET, .arrow_desc = &vicfg_opt_arrow, .leavetype = ICONFIG , .config_value = &deblur_mode_powercycle},
        {.id = VICFG2_16BIT_V_OFFSET         , .arrow_desc = &vicfg_opt_arrow, .leavetype = ICONFIG , .config_value = &mode16bit},
        {.id = VICFG2_16BIT_DEF_V_OFFSET     , .arrow_desc = &vicfg_opt_arrow, .leavetype = ICONFIG , .config_value = &mode16bit_powercycle},
        {.id = VICFG2_PAGE1_V_OFFSET         , .arrow_desc = &vicfg_sel_arrow, .leavetype = ISUBMENU, .submenu      = &vicfg1_screen}
    }
};

#define DEBLUR_CURRENT_SELECTION    2
#define DEBLUR_POWERCYCLE_SELECTION 3
#define M16BIT_CURRENT_SELECTION    4
#define M16BIT_POWERCYCLE_SELECTION 5


menu_t vicfg_res_subscreen = {
    .type = CONFIG,
    .header = &rescfg_opt_header,
    .overlay = &rescfg_opt_overlay,
    .parent = &vicfg1_screen,
    .current_selection = 0,
    .number_selections = 6,
    .leaves = {
        {.id = VICFG_RES_INPUT_V_OFFSET  , .arrow_desc = &vicfg_res_opt_arrow0, .leavetype = ICONFIG , .config_value = &res_selection},
        {.id = VICFG_RES_OUTPUT_V_OFFSET , .arrow_desc = &vicfg_res_opt_arrow1, .leavetype = ICONFIG , .config_value = &linex_resolution},
        {.id = VICFG_USE_VGA_RES_V_OFFSET, .arrow_desc = &vicfg_res_opt_arrow1, .leavetype = ICONFIG , .config_value = &vga_for_480p},
        {.id = VICFG_USE_SRCSYNC_V_OFFSET, .arrow_desc = &vicfg_res_opt_arrow1, .leavetype = ICONFIG , .config_value = &low_latency_mode},
        {.id = VICFG_FORCE_5060_V_OFFSET , .arrow_desc = &vicfg_res_opt_arrow1, .leavetype = ICONFIG , .config_value = &linex_force_5060},
        {.id = VICFG_RES_SCALER_V_OFFSET , .arrow_desc = &vicfg_res_sel_arrow1, .leavetype = ISUBMENU, .submenu = &vicfg_scaling_subscreen}
    }
};

#define FORCE5060_SELECTION 4

menu_t vicfg_scanline_opt_subscreen = {
    .type = CONFIG,
    .header = &slcfg_opt_header,
    .overlay = &slcfg_opt_overlay,
    .parent = &vicfg1_screen,
    .current_selection = 0,
    .number_selections = 6,
    .leaves = {
        {.id = VICFG_SL_INPUT_OFFSET    , .arrow_desc = &vicfg_sl_opt_arrow0, .leavetype = ICONFIG , .config_value = &scanline_selection},
        {.id = VICFG_SL_EN_V_OFFSET     , .arrow_desc = &vicfg_sl_opt_arrow1, .leavetype = ICONFIG , .config_value = &sl_en},
        {.id = VICFG_SL_METHOD_V_OFFSET , .arrow_desc = &vicfg_sl_opt_arrow1, .leavetype = ICONFIG , .config_value = &sl_method},
        {.id = VICFG_SL_ID_V_OFFSET     , .arrow_desc = &vicfg_sl_opt_arrow1, .leavetype = ICONFIG , .config_value = &sl_id},
        {.id = VICFG_SL_STR_V_OFFSET    , .arrow_desc = &vicfg_sl_opt_arrow1, .leavetype = ICONFIG , .config_value = &sl_str},
        {.id = VICFG_SL_HYB_STR_V_OFFSET, .arrow_desc = &vicfg_sl_opt_arrow1, .leavetype = ICONFIG , .config_value = &slhyb_str},
        {.id = VICFG_SL_INPUT_OFFSET    , .arrow_desc = &vicfg_sl_opt_arrow0, .leavetype = ICONFIG , .config_value = &scanline_selection},
        {.id = VICFG_SL_EN_V_OFFSET     , .arrow_desc = &vicfg_sl_opt_arrow1, .leavetype = ICONFIG , .config_value = &sl_en_480i},
        {.id = VICFG_SL_METHOD_V_OFFSET , .arrow_desc = &vicfg_sl_opt_arrow1, .leavetype = ICONFIG , .config_value = &sl_method_480i},
        {.id = VICFG_SL_ID_V_OFFSET     , .arrow_desc = &vicfg_sl_opt_arrow1, .leavetype = ICONFIG , .config_value = &sl_id_480i},
        {.id = VICFG_SL_STR_V_OFFSET    , .arrow_desc = &vicfg_sl_opt_arrow1, .leavetype = ICONFIG , .config_value = &sl_str_480i},
        {.id = VICFG_SL_HYB_STR_V_OFFSET, .arrow_desc = &vicfg_sl_opt_arrow1, .leavetype = ICONFIG , .config_value = &slhyb_str_480i}
    }
};

#define SL_INPUT_SELECTION        0
#define SL_EN_SELECTION           1
#define SL_METHOD_SELECTION       2
#define SL_INPUT_480I_SELECTION   6
#define SL_EN_480I_SELECTION      7
#define SL_LINKED_480I_SELECTION  7
#define SL_METHOD_480I_SELECTION  8


menu_t vicfg_timing_subscreen = {
    .type = CONFIG,
    .header = &vicfg_timing_opt_header,
    .overlay = &vicfg_timing_opt_overlay,
    .parent = &vicfg1_screen,
    .current_selection = 0,
    .number_selections = 4,
    .leaves = {
        {.id = VICFG_VTIMSUB_MODE_V_OFFSET   , .arrow_desc = &vicfg_timing_opt_arrow0, .leavetype = ICONFIG, .config_value = &timing_selection},
        {.id = VICFG_VTIMSUB_VSHIFT_V_OFFSET , .arrow_desc = &vicfg_timing_opt_arrow1, .leavetype = ICONFIG, .config_value = &vert_shift},
        {.id = VICFG_VTIMSUB_HSHIFT_V_OFFSET , .arrow_desc = &vicfg_timing_opt_arrow1, .leavetype = ICONFIG, .config_value = &hor_shift},
        {.id = VICFG_VTIMSUB_RESET_V_OFFSET  , .arrow_desc = &vicfg_timing_sel_arrow1, .leavetype = IFUNC , .sys_fun_0    = &cfg_reset_timing}
    }
};

#define TIMING_PAGE_SELECTION     0
#define VERTSHIFT_SELECTION       1
#define HORSHIFT_SELECTION        2
#define RESET_TIMINGS_SECLECTION  3


menu_t vicfg_scaling_subscreen = {
    .type = CONFIG,
    .header = &vicfg_scaler_opt_header,
    .overlay = &vicfg_scaler_overlay,
    .parent = &vicfg1_screen,
    .current_selection = 0,
    .number_selections = 6,
    .leaves = {
        {.id = VICFG_SCALESUB_MODE_V_OFFSET   , .arrow_desc = &vicfg_scaling_opt_arrow0, .leavetype = ICONFIG, .config_value = &scaling_selection},
        {.id = VICFG_SCALESUB_INTERPM_V_OFFSET, .arrow_desc = &vicfg_scaling_opt_arrow1, .leavetype = ICONFIG, .config_value = &interpolation_mode},
        {.id = VICFG_SCALESUB_HVLINK_V_OFFSET , .arrow_desc = &vicfg_scaling_opt_arrow1, .leavetype = ICONFIG, .config_value = &link_hv_scale},
        {.id = VICFG_SCALESUB_VSCALE_V_OFFSET , .arrow_desc = &vicfg_scaling_opt_arrow1, .leavetype = ICONFIG, .config_value = &vert_scale},
        {.id = VICFG_SCALESUB_HSCALE_V_OFFSET , .arrow_desc = &vicfg_scaling_opt_arrow1, .leavetype = ICONFIG, .config_value = &hor_scale},
        {.id = VICFG_SCALESUB_PALBOX_V_OFFSET , .arrow_desc = &vicfg_scaling_opt_arrow1 ,.leavetype = ICONFIG, .config_value = &pal_boxed_mode}
    }
};

#define SCALING_PAGE_SELECTION  0
#define VERTSCALE_SELECTION     3
#define HORISCALE_SELECTION     4
#define PAL_BOX_SELECTION       5

menu_t misc_screen = {
    .type = CONFIG,
    .header = &misc_header,
    .overlay = &misc_overlay,
    .parent = &home_menu,
    .current_selection = 0,
    .number_selections = 6,
    .leaves = {
        {.id = MISC_AUDIO_SWAP_LR_V_OFFSET , .arrow_desc = &misc_opt_arrow, .leavetype = ICONFIG, .config_value = &audio_swap_lr},
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
    .overlay = &rwdata_overlay,
    .parent = &home_menu,
    .current_selection = 0,
    .number_selections = 4,
    .leaves = {
        {.id = RWDATA_SAVE_FL_V_OFFSET      , .arrow_desc = &front_sel_arrow, .leavetype = IFUNC, .sys_fun_1 = &cfg_save_to_flash},
        {.id = RWDATA_LOAD_FL_V_OFFSET      , .arrow_desc = &front_sel_arrow, .leavetype = IFUNC, .sys_fun_1 = &cfg_load_from_flash},
        {.id = RWDATA_LOAD_N64_480P_V_OFFSET, .arrow_desc = &front_sel_arrow, .leavetype = IFUNC, .sys_fun_2 = &cfg_load_defaults},
        {.id = RWDATA_LOAD_N64_V_OFFSET     , .arrow_desc = &front_sel_arrow, .leavetype = IFUNC, .sys_fun_2 = &cfg_load_defaults}
    }
};

#define RW_SAVE_CFG_SELECTION       0
#define RW_LOAD_CFG_SELECTION       1
#define RW_LOAD_N64_480P_SELECTION  2
#define RW_LOAD_N64_DEF_SELECTION   3

menu_t about_screen = {
   .type = TEXT,
   .overlay = &about_overlay,
   .parent = &home_menu
};

menu_t thanks_screen = {
   .type = TEXT,
   .overlay = &thanks_overlay,
   .parent = &home_menu
};

menu_t license_screen = {
   .type = TEXT,
   .overlay = &license_overlay,
   .parent = &home_menu
};


static inline alt_u8 is_home_menu (menu_t *menu)
  {  return (menu == &home_menu); }
static inline alt_u8 is_vicfg1_screen (menu_t *menu)
  {  return (menu == &vicfg1_screen); }
static inline alt_u8 is_vicfg2_screen (menu_t *menu)
  {  return (menu == &vicfg2_screen); }
static inline alt_u8 is_vicfg_res_screen (menu_t *menu)
  {  return (menu == &vicfg_res_subscreen); }
static inline alt_u8 is_vicfg_sl_screen (menu_t *menu)
  {  return (menu == &vicfg_scanline_opt_subscreen); }
static inline alt_u8 is_vicfg_480i_sl_are_linked ()
  {  return ( cfg_get_value(&sl_en_480i,0) == CFG_480I_SL_EN_MAX_VALUE); }
static inline alt_u8 is_vicfg_timing_screen (menu_t *menu)
  {  return (menu == &vicfg_timing_subscreen); }
static inline alt_u8 is_vicfg_scaling_screen (menu_t *menu)
  {  return (menu == &vicfg_scaling_subscreen); }
static inline alt_u8 is_misc_screen (menu_t *menu)
  {  return (menu == &misc_screen); }


void val2txt_func(alt_u8 v) { sprintf(szText,"%u", v); };
void val2txt_6b_binaryoffset_func(alt_u8 v) { if (v & 0x20) sprintf(szText," %2u", (v&0x1F)); else sprintf(szText,"-%2u", (v^0x1F)+1); };
void val2txt_scale_sel_func(alt_u8 v) {
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
void val2txt_hscale_func(alt_u8 v) { sprintf(szText,"%1u.%03ux", v/8+1, 125*(v&7)); };
void val2txt_vscale_func(alt_u8 v) { sprintf(szText,"%1u.%02ux", v/4+2, 25*(v&3)); };
void audioamp2txt_func(alt_u8 v) { if (v < 19) sprintf(szText,"-%02udB",19-v); else sprintf(szText," %02udB",v-19); };
void flag2set_func(alt_u8 v) { sprintf(szText,"[ ]"); if (v) szText[1] = (char) CHECKBOX_TICK; };
void scanline_str2txt_func(alt_u8 v) { v++; sprintf(szText,"%3u.%02u%%", (v*625)/100, 25*(v&3)); };
void scanline_hybrstr2txt_func(alt_u8 v) { sprintf(szText,"%3u.%02u%%", (v*625)/100, 25*(v&3)); };
void gamma2txt_func(alt_u8 v) { sprintf(szText,"%u.%02u", v > 4, 5* v + 75 - (100 * (v > 4))); };


void print_palbox_overlay(vmode_t vmode) {
  alt_u8 font_color = vmode ? FONTCOLOR_WHITE : FONTCOLOR_GREY;
  vd_print_string(VICFG_SCALESUB_OVERLAY_H_OFFSET+3,VICFG_SCALESUB_PALBOX_V_OFFSET,BACKGROUNDCOLOR_STANDARD,font_color,vicfg_scaler_overlay1);
}

void print_current_timing_mode()
{
  sprintf(szText,"Current:");
  vd_print_string(0, VD_HEIGHT-1, BACKGROUNDCOLOR_STANDARD, FONTCOLOR_NAVAJOWHITE, &szText[0]);
  val2txt_scale_sel_func(scaling_n64adv);
  vd_print_string(9, VD_HEIGHT-1, BACKGROUNDCOLOR_STANDARD, FONTCOLOR_NAVAJOWHITE, &szText[0]);
}

void print_ctrl_data() {
  sprintf(szText,"Ctrl.Data: 0x%08x",(uint) ctrl_data);
  vd_print_string(0, VD_HEIGHT-1, BACKGROUNDCOLOR_STANDARD, FONTCOLOR_NAVAJOWHITE, &szText[0]);
}

void print_fw_version()
{
  alt_u16 ext_fw = (alt_u16) get_pcb_version();
  vd_print_string(VERSION_H_OFFSET,VERSION_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,pcb_rev[ext_fw]);

  sprintf(szText,"0x%08x%08x",(uint) get_chip_id(1),(uint) get_chip_id(0));
  vd_print_string(VERSION_H_OFFSET,VERSION_V_OFFSET+1,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,&szText[0]);

  ext_fw = get_hdl_version();
  sprintf(szText,"%1d.%02d",((ext_fw & HDL_FW_GETMAIN_MASK) >> HDL_FW_MAIN_OFFSET),
                            ((ext_fw & HDL_FW_GETSUB_MASK) >> HDL_FW_SUB_OFFSET));
  vd_print_string(VERSION_H_OFFSET,VERSION_V_OFFSET+2,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,&szText[0]);

  sprintf(szText,"%1d.%02d",SW_FW_MAIN,SW_FW_SUB);
  vd_print_string(VERSION_H_OFFSET,VERSION_V_OFFSET+3,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,&szText[0]);
}

void update_vmode_menu(menu_t *menu)
{
  if (is_vicfg_res_screen(menu)) {
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

  static alt_u8 vicfg_page = 1;

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
      if (is_vicfg1_screen(*current_menu)) {
        *current_menu = &vicfg2_screen;
        vicfg_page = 2;
        return NEW_OVERLAY;
      }
      if (is_vicfg2_screen(*current_menu)) {
        (*current_menu)->parent->current_selection = VICONFIG_SUBMENU_SELECTION; // tell home that we are now at misc config;
        *current_menu = &misc_screen;
        return NEW_OVERLAY;
      }
      if (is_misc_screen(*current_menu)) {
        (*current_menu)->parent->current_selection = VICONFIG_SUBMENU_SELECTION; // tell home that we are now at VI-config;
        *current_menu = &vicfg1_screen;
        vicfg_page = 1;
        return NEW_OVERLAY;
      }
      if (is_vicfg_res_screen(*current_menu)) {
        cfg_inc_value(&res_selection);
        update_vmode_menu(*current_menu);
        cfg_load_linex_word(vmode_menu);
        todo = NEW_OVERLAY;
        break;
      }
      if (is_vicfg_sl_screen(*current_menu)) {
        cfg_inc_value(&scanline_selection);
        update_vmode_menu(*current_menu);
        cfg_load_linex_word(vmode_menu);
        todo = NEW_OVERLAY;
        break;
      }
      if (is_vicfg_timing_screen(*current_menu)){
        cfg_inc_value(&timing_selection);
        timing_menu = cfg_get_value(&timing_selection,0);
        if (timing_menu == PPU_TIMING_CURRENT) timing_menu = timing_n64adv;
        cfg_load_timing_word(timing_menu);
        todo = NEW_OVERLAY;
        break;
      }
      if (is_vicfg_scaling_screen(*current_menu)){
        cfg_inc_value(&scaling_selection);
        scaling_menu = cfg_get_value(&scaling_selection,0);
        if (scaling_menu == PPU_SCALING_CURRENT) scaling_menu = scaling_n64adv;
        cfg_load_scaling_word(scaling_menu);
        todo = NEW_OVERLAY;
        break;
      }
      break;
    case CMD_MENU_PAGE_LEFT:
      if (is_vicfg1_screen(*current_menu)) {
        (*current_menu)->parent->current_selection = VICONFIG_SUBMENU_SELECTION; // tell home that we are now at misc config;
        *current_menu = &misc_screen;
        return NEW_OVERLAY;
      }
      if (is_vicfg2_screen(*current_menu)) {
        *current_menu = &vicfg1_screen;
        vicfg_page = 1;
        return NEW_OVERLAY;
      }
      if (is_misc_screen(*current_menu)) {
        (*current_menu)->parent->current_selection = VICONFIG_SUBMENU_SELECTION; // tell home that we are now at VI-config;
        *current_menu = &vicfg2_screen;
        vicfg_page = 2;
        return NEW_OVERLAY;
      }
      if (is_vicfg_res_screen(*current_menu)) {
        cfg_dec_value(&res_selection);
        update_vmode_menu(*current_menu);
        cfg_load_linex_word(vmode_menu);
        todo = NEW_OVERLAY;
        break;
      }
      if (is_vicfg_sl_screen(*current_menu)) {
        cfg_dec_value(&scanline_selection);
        update_vmode_menu(*current_menu);
        cfg_load_linex_word(vmode_menu);
        todo = NEW_OVERLAY;
        break;
      }
      if (is_vicfg_timing_screen(*current_menu)){
        cfg_dec_value(&timing_selection);
        timing_menu = cfg_get_value(&timing_selection,0);
        if (timing_menu == PPU_TIMING_CURRENT) timing_menu = timing_n64adv;
        cfg_load_timing_word(timing_menu);
        todo = NEW_OVERLAY;
        break;
      }
      if (is_vicfg_scaling_screen(*current_menu)){
        cfg_dec_value(&scaling_selection);
        scaling_menu = cfg_get_value(&scaling_selection,0);
        if (scaling_menu == PPU_SCALING_CURRENT) scaling_menu = scaling_n64adv;
        cfg_load_scaling_word(scaling_menu);
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

  if (is_vicfg_res_screen(*current_menu)) {
    if (cfg_get_value(&low_latency_mode,0) == ON && current_sel == FORCE5060_SELECTION)
      (*current_menu)->current_selection = (command == CMD_MENU_DOWN) ? FORCE5060_SELECTION + 1 : FORCE5060_SELECTION - 1;
  }

  if (is_vicfg_sl_screen(*current_menu)) {
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

  if (is_vicfg_timing_screen(*current_menu)) {
    if (cfg_get_value(&timing_selection,0) == PPU_TIMING_CURRENT && current_sel == RESET_TIMINGS_SECLECTION) // reset timings not allowed in PPU_CURRENT
      (*current_menu)->current_selection = (command == CMD_MENU_DOWN) ? TIMING_PAGE_SELECTION : HORSHIFT_SELECTION;
    current_sel = (*current_menu)->current_selection;
  }

  if (is_vicfg_scaling_screen(*current_menu)) {
    if (cfg_get_value(&link_hv_scale,0) && current_sel == HORISCALE_SELECTION)
      current_sel = (command == CMD_MENU_DOWN) ? PAL_BOX_SELECTION : VERTSCALE_SELECTION;
    if (current_sel == PAL_BOX_SELECTION) {
      if (cfg_get_value(&scaling_selection,0) == PPU_SCALING_CURRENT) {
        if (palmode == NTSC) // palbox not available in NTSC
          current_sel = (command == CMD_MENU_DOWN) ? SCALING_PAGE_SELECTION :
                    cfg_get_value(&link_hv_scale,0) ? VERTSCALE_SELECTION : HORISCALE_SELECTION;
      } else {
        if (cfg_get_value(&scaling_selection,0) < PAL_TO_576) // palbox not available in NTSC
          current_sel = (command == CMD_MENU_DOWN) ? SCALING_PAGE_SELECTION :
                   cfg_get_value(&link_hv_scale,0) ? VERTSCALE_SELECTION : HORISCALE_SELECTION;
      }
    }
    (*current_menu)->current_selection = current_sel;
  }

  if (todo == NEW_OVERLAY || todo == NEW_SELECTION) return todo;

  if ((*current_menu)->leaves[current_sel].leavetype == ISUBMENU) {
    switch (command) {
      case CMD_MENU_RIGHT:
      case CMD_MENU_ENTER:
        if ((*current_menu)->leaves[current_sel].submenu) { // check for existing submenu
          if (is_vicfg_scaling_screen((*current_menu)->leaves[current_sel].submenu))
            (*current_menu)->leaves[current_sel].submenu->parent = (*current_menu);
          if (is_home_menu(*current_menu) && current_sel == VICONFIG_SUBMENU_SELECTION) {
            if (vicfg_page == 1) *current_menu = &vicfg1_screen;  // open vi-config page 1
            else *current_menu = &vicfg2_screen;                  // open vi-config page 2
          } else *current_menu = (*current_menu)->leaves[current_sel].submenu;
          if (is_vicfg1_screen(*current_menu)) vicfg_page = 1;    // remember vi-config page 1
          if (is_vicfg2_screen(*current_menu)) vicfg_page = 2;    // remember vi-config page 1
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
      if (is_vicfg_timing_screen((*current_menu)) &&
          ((current_sel == VERTSHIFT_SELECTION) || (current_sel == HORSHIFT_SELECTION)) &&
          (cfg_get_value((*current_menu)->leaves[current_sel].config_value,0) == 0)) { // all-zero not allowed for vert./hor. shift
        if (command == CMD_MENU_RIGHT) cfg_inc_value((*current_menu)->leaves[current_sel].config_value);
        else                           cfg_dec_value((*current_menu)->leaves[current_sel].config_value);
      }
    }
    return todo;
  }


  if ((*current_menu)->leaves[current_sel].leavetype == IFUNC) {
    if ((command == CMD_MENU_RIGHT) || (command == CMD_MENU_ENTER)) {
      int retval;


      if (is_vicfg_timing_screen((*current_menu))) {
        retval = (*current_menu)->leaves[current_sel].sys_fun_0();
      } else { // rw screen
        if ((*current_menu)->current_selection < RW_LOAD_N64_480P_SELECTION)
          retval = (*current_menu)->leaves[current_sel].sys_fun_1(1);
        else
          retval = (*current_menu)->leaves[current_sel].sys_fun_2(RW_LOAD_N64_DEF_SELECTION-(*current_menu)->current_selection,1);
      }
      return (retval == 0                     ? RW_DONE  :
              retval == -CFG_FLASH_SAVE_ABORT ? RW_ABORT :
                                                RW_FAILED);
    }
  }

  return NON;
}

void print_overlay(menu_t* current_menu)
{
  alt_u8 h_run;
  alt_u8 overlay_h_offset = (current_menu->type == TEXT) ? TEXTOVERLAY_H_OFFSET : HOMEOVERLAY_H_OFFSET;
  alt_u8 overlay_v_offset = 0;

  VD_CLEAR_SCREEN;

  if (current_menu->header) {
    overlay_v_offset = OVERLAY_V_OFFSET_WH;
    vd_print_string(VD_WIDTH-strlen(*current_menu->header),HEADER_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_DARKORANGE,*current_menu->header);

    for (h_run = 0; h_run < VD_WIDTH; h_run++)
      vd_print_char(h_run,1,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_NAVAJOWHITE,(char) HEADER_UNDERLINE);
  }
  vd_print_string(overlay_h_offset,overlay_v_offset,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,*current_menu->overlay);

  if (current_menu->type == HOME) vd_print_string(BTN_OVERLAY_H_OFFSET,BTN_OVERLAY_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_GREEN,btn_overlay_0);
  if (current_menu->type == RWDATA) vd_print_string(BTN_OVERLAY_H_OFFSET,BTN_OVERLAY_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_GREEN,btn_overlay_1);

  switch (current_menu->type) {
    case HOME:
    case CONFIG:
    case VINFO:
    case RWDATA:
      vd_print_string(COPYRIGHT_H_OFFSET,COPYRIGHT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_DARKORANGE,copyright_note);
      vd_print_char(COPYRIGHT_SIGN_H_OFFSET,COPYRIGHT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_DARKORANGE,(char) COPYRIGHT_SIGN);
      for (h_run = 0; h_run < VD_WIDTH; h_run++)
        vd_print_char(h_run,VD_HEIGHT-2,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_NAVAJOWHITE,(char) HOME_LOWSEC_UNDERLINE);
      break;
    case TEXT:
      if (&(*current_menu->overlay) == &about_overlay)
        print_fw_version();
      if (&(*current_menu->overlay) == &license_overlay)
        vd_print_char(CR_SIGN_LICENSE_H_OFFSET,CR_SIGN_LICENSE_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,(char) COPYRIGHT_SIGN);
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
        vd_print_char(h_r_offset,v_offset,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,(char) current_menu->leaves[v_run].arrow_desc->shape->right);
        vd_print_char(h_l_offset,v_offset,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,(char) current_menu->leaves[v_run].arrow_desc->shape->left);
      } else {
        vd_clear_char(h_l_offset,v_offset);
        vd_clear_char(h_r_offset,v_offset);
      }
    }
}

int update_vinfo_screen(menu_t* current_menu)
{
  if (current_menu->type != VINFO) return -1;

  alt_u8 str_select;

  // PPU state
  vd_clear_lineend(INFO_VALS_H_OFFSET,INFO_PPU_STATE_V_OFFSET);
  sprintf(szText,"0x%08x",(uint) ppu_state);
  vd_print_string(INFO_VALS_H_OFFSET,INFO_PPU_STATE_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,&szText[0]);

  // Video Input
  str_select = (palmode << 1) | scanmode;
  vd_clear_lineend(INFO_VALS_H_OFFSET,INFO_VIN_V_OFFSET);
  vd_print_string(INFO_VALS_H_OFFSET,INFO_VIN_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VideoMode[str_select]);
  vd_print_string(INFO_VALS_H_OFFSET + 5,INFO_VIN_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VRefresh[palmode]);

  // Video Output
  alt_u8 ppu_output_res_val = ((ppu_state & (PPU_FORCE5060_GETMASK | PPU_USE_VGA_FOR_480P_GETMASK | PPU_RESOLUTION_GETMASK)) >> PPU_RESOLUTION_OFFSET);
  vd_clear_lineend(INFO_VALS_H_OFFSET,INFO_VOUT_V_OFFSET);
  switch (ppu_output_res_val) { // 2bit 50/60, 1 bit VGA, 3 bit resolution
    case 0b000000:
      if (palmode) vd_print_string(INFO_VALS_H_OFFSET,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,Resolution576p);
      else vd_print_string(INFO_VALS_H_OFFSET,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,Resolution480p);
      vd_print_string(INFO_VALS_H_OFFSET + 5,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VRefresh[palmode]);
      break;
    case 0b001000:
      if (palmode) {
        vd_print_string(INFO_VALS_H_OFFSET    ,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,Resolution576p);
        vd_print_string(INFO_VALS_H_OFFSET + 5,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VRefresh[1]);
      }
      else {
        vd_print_string(INFO_VALS_H_OFFSET     ,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,ResolutionVGA);
        vd_print_string(INFO_VALS_H_OFFSET + 14,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VRefresh[0]);
      }
      break;
    case 0b010000:
      vd_print_string(INFO_VALS_H_OFFSET    ,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,Resolution480p);
      vd_print_string(INFO_VALS_H_OFFSET + 5,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VRefresh[0]);
      break;
    case 0b011000:
      vd_print_string(INFO_VALS_H_OFFSET     ,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,ResolutionVGA);
      vd_print_string(INFO_VALS_H_OFFSET + 14,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VRefresh[0]);
      break;
    case 0b100000:
    case 0b101000:
      vd_print_string(INFO_VALS_H_OFFSET    ,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,Resolution576p);
      vd_print_string(INFO_VALS_H_OFFSET + 5,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VRefresh[1]);
      break;
    case 0b000001:
    case 0b001001:
      vd_print_string(INFO_VALS_H_OFFSET    ,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,Resolutions[1]);
      vd_print_string(INFO_VALS_H_OFFSET + 5,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VRefresh[palmode]);
      break;
    case 0b010001:
    case 0b011001:
      vd_print_string(INFO_VALS_H_OFFSET    ,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,Resolutions[1]);
      vd_print_string(INFO_VALS_H_OFFSET + 5,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VRefresh[0]);
      break;
    case 0b100001:
    case 0b101001:
      vd_print_string(INFO_VALS_H_OFFSET    ,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,Resolutions[1]);
      vd_print_string(INFO_VALS_H_OFFSET + 5,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VRefresh[1]);
      break;
    case 0b000010:
    case 0b001010:
      vd_print_string(INFO_VALS_H_OFFSET    ,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,Resolutions[2]);
      vd_print_string(INFO_VALS_H_OFFSET + 6,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VRefresh[palmode]);
      break;
    case 0b010010:
    case 0b011010:
      vd_print_string(INFO_VALS_H_OFFSET    ,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,Resolutions[2]);
      vd_print_string(INFO_VALS_H_OFFSET + 6,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VRefresh[0]);
      break;
    case 0b100010:
    case 0b101010:
      vd_print_string(INFO_VALS_H_OFFSET    ,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,Resolutions[2]);
      vd_print_string(INFO_VALS_H_OFFSET + 6,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VRefresh[1]);
      break;
    case 0b000011:
    case 0b001011:
      vd_print_string(INFO_VALS_H_OFFSET    ,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,Resolutions[3]);
      vd_print_string(INFO_VALS_H_OFFSET + 6,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VRefresh[palmode]);
      break;
    case 0b010011:
    case 0b011011:
      vd_print_string(INFO_VALS_H_OFFSET    ,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,Resolutions[3]);
      vd_print_string(INFO_VALS_H_OFFSET + 6,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VRefresh[0]);
      break;
    case 0b100011:
    case 0b101011:
      vd_print_string(INFO_VALS_H_OFFSET    ,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,Resolutions[3]);
      vd_print_string(INFO_VALS_H_OFFSET + 6,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VRefresh[1]);
      break;
    case 0b000100:
    case 0b001100:
      vd_print_string(INFO_VALS_H_OFFSET    ,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,Resolutions[4]);
      vd_print_string(INFO_VALS_H_OFFSET + 6,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VRefresh[palmode]);
      break;
    case 0b010100:
    case 0b011100:
      vd_print_string(INFO_VALS_H_OFFSET    ,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,Resolutions[4]);
      vd_print_string(INFO_VALS_H_OFFSET + 6,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VRefresh[0]);
      break;
    case 0b100100:
    case 0b101100:
      vd_print_string(INFO_VALS_H_OFFSET    ,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,Resolutions[4]);
      vd_print_string(INFO_VALS_H_OFFSET + 6,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,VRefresh[1]);
      break;
    default:
      vd_print_string(INFO_VALS_H_OFFSET,INFO_VOUT_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_GREY,not_available);
  }

  // Source-Sync. Mode
  str_select = ((ppu_state & PPU_LOWLATENCYMODE_GETMASK) >> PPU_LOWLATENCYMODE_OFFSET);
  vd_clear_lineend(INFO_VALS_H_OFFSET,INFO_LLM_V_OFFSET);
  vd_print_string(INFO_VALS_H_OFFSET,INFO_LLM_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,OffOn[str_select]);
  if (str_select) {
    sprintf(szText,"(%d sl. buffered)",(uint) ((ppu_state & PPU_LLM_SLBUF_FB_GETMASK) >> PPU_LLM_SLBUF_FB_OFFSET));
    vd_print_string(INFO_VALS_H_OFFSET+3,INFO_LLM_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,&szText[0]);
  }

  // 240p DeBlur
  vd_clear_lineend(INFO_VALS_H_OFFSET, INFO_DEBLUR_V_OFFSET);
  if (scanmode == INTERLACED) {
    vd_print_string(INFO_VALS_H_OFFSET,INFO_DEBLUR_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_GREY,text_480i_576i_br);
  } else {
    str_select = ((ppu_state & PPU_240P_DEBLUR_GETMASK) >> PPU_240P_DEBLUR_OFFSET);
    vd_print_string(INFO_VALS_H_OFFSET, INFO_DEBLUR_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,OffOn[str_select]);
  }

  // Gamma Table
  gamma2txt_func((ppu_state & PPU_GAMMA_TABLE_GETMASK) >> PPU_GAMMA_TABLE_OFFSET);
  vd_clear_lineend(INFO_VALS_H_OFFSET,INFO_GAMMA_V_OFFSET);
  vd_print_string(INFO_VALS_H_OFFSET,INFO_GAMMA_V_OFFSET,BACKGROUNDCOLOR_STANDARD,FONTCOLOR_WHITE,&szText[0]);

  return 0;
}


int update_cfg_screen(menu_t* current_menu)
{
  if (current_menu->type != CONFIG) return -1;

  alt_u8 h_l_offset;
  alt_u8 v_run, v_offset;
  alt_u8 background_color, font_color;
  alt_u8 val_select, ref_val_select, val_is_ref;

  cfg_offon_t use_sl_linked_vals = OFF;
  alt_u8 v_run_offset = 0;
  if (is_vicfg_sl_screen(current_menu)) {
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
      case ISUBMENU:
        font_color = FONTCOLOR_WHITE;
        vd_print_string(h_l_offset,v_offset,background_color,font_color,EnterSubMenu);
        break;
      case IFUNC:
        if (is_vicfg_timing_screen(current_menu)) {
          font_color = cfg_get_value(&timing_selection,0) > PPU_TIMING_CURRENT ? FONTCOLOR_WHITE : FONTCOLOR_GREY;
          vd_print_string(VICFG_VTIMSUB_OVERLAY_H_OFFSET+3,v_offset,background_color,font_color,vicfg_timing_opt_overlay1);
          vd_print_string(h_l_offset,v_offset,background_color,font_color,LoadTimingDefaults);
        }
        break;
      case ICONFIG:
        val_select = cfg_get_value(current_menu->leaves[v_run].config_value,0);
        ref_val_select = cfg_get_value(current_menu->leaves[v_run].config_value,use_flash);
        if (is_vicfg2_screen(current_menu)){
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
        if (is_vicfg_res_screen(current_menu)) {
          if (cfg_get_value(&low_latency_mode,0) == ON && v_run == FORCE5060_SELECTION) {
            val_select = 0;
            font_color = FONTCOLOR_GREY;
          }
        }

        // check scanline screen
        if (is_vicfg_sl_screen(current_menu)) {
          if (((cfg_get_value(&sl_en,0) == OFF) && v_run > SL_EN_SELECTION && v_run < SL_INPUT_480I_SELECTION)        ||
              ((cfg_get_value(&sl_en_480i,0) == OFF) && v_run > SL_EN_480I_SELECTION )                                ||
              (use_sl_linked_vals && v_run_offset == 0 && (cfg_get_value(&sl_en,0) == OFF) && v_run > SL_EN_SELECTION) )
            font_color = val_is_ref ? FONTCOLOR_GREY : FONTCOLOR_DARKGOLD;
        }

        // check scaling menu
        if (is_vicfg_scaling_screen(current_menu)) {
          if (v_run == HORISCALE_SELECTION && cfg_get_value(&link_hv_scale,0)) {
            val_select = cfg_get_value(current_menu->leaves[v_run-1].config_value,0);
            ref_val_select = cfg_get_value(current_menu->leaves[v_run-1].config_value,use_flash);
            font_color = (val_select == ref_val_select) ? FONTCOLOR_GREY : FONTCOLOR_DARKGOLD;
          }
          if (v_run == PAL_BOX_SELECTION) {
            if (cfg_get_value(&scaling_selection,0) == PPU_SCALING_CURRENT) {
              print_palbox_overlay(palmode);
              if (!palmode) {
                font_color = FONTCOLOR_GREY;
                sprintf(szText,not_available);
              } else {
                flag2set_func(val_select);
              }
            } else {
              if (cfg_get_value(&scaling_selection,0) < PAL_TO_576) {
                print_palbox_overlay(NTSC);
                font_color = FONTCOLOR_GREY;
                sprintf(szText,not_available);
              } else {
                print_palbox_overlay(PAL);
                flag2set_func(val_select);
              }
            }
          }
        }

//        if (v_run == current_menu->current_selection)
        vd_clear_area(h_l_offset,h_l_offset + OPT_WINDOW_WIDTH,v_offset,v_offset);

        if (current_menu->leaves[v_run].config_value->cfg_type == FLAGTXT ||
          current_menu->leaves[v_run].config_value->cfg_type == NUMVALUE ) {
          if (!(is_vicfg_scaling_screen(current_menu) && v_run == PAL_BOX_SELECTION)) current_menu->leaves[v_run].config_value->val2char_func(val_select); // val2char_func already executed in scaling screen for palbox
          vd_print_string(h_l_offset,v_offset,background_color,font_color,&szText[0]);
        } else {
          vd_print_string(h_l_offset,v_offset,background_color,font_color,current_menu->leaves[v_run].config_value->value_string[val_select]);
        }
        break;
      default:
        break;
    }
  }

  return 0;
}
