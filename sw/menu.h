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
 * menu.h
 *
 *  Created on: 09.01.2018
 *      Author: Peter Bartmann
 *
 ********************************************************************************/

#include "alt_types.h"
#include "altera_avalon_pio_regs.h"
#include "system.h"
#include "config.h"
#include "n64.h"
#include "vd_driver.h"


#ifndef MENU_H_
#define MENU_H_

#define OPT_WINDOW_WIDTH  21
#define OPT_WINDOWCOLOR_BG    BACKGROUNDCOLOR_WHITE
#define OPT_WINDOWCOLOR_FONT  FONTCOLOR_BLACK

#define BTN_OVERLAY_H_OFFSET  (VD_WIDTH - 13)
#define BTN_OVERLAY_V_OFFSET  (VD_TXT_HEIGHT - 2)

extern char szText[];

typedef enum {
  NON = 0,
  MENU_OPEN,
  MENU_MUTE,
  MENU_UNMUTE,
  MENU_CLOSE,
  NEW_OVERLAY,
  NEW_SELECTION,
  NEW_CONF_VALUE,
  RW_DONE,
  RW_FAILED,
  RW_ABORT
} updateaction_t;

typedef enum {
  HOME = 0,
  VINFO,
  CONFIG,
  RWDATA,
  TEXT
} screentype_t;

typedef enum {
  ICONFIG,
  ISUBMENU,
  IFUNC
} leavetype_t;

typedef struct {
  alt_u8 left;
  alt_u8 right;
} arrowshape_t;

typedef struct {
  const arrowshape_t *shape;
  alt_u8       hpos;
} arrow_t;

typedef int (*sys_call_0)(void);
typedef int (*sys_call_1)(alt_u8);
typedef int (*sys_call_2)(alt_u8,alt_u8);

typedef struct {
  alt_u8        id;
  const arrow_t *arrow_desc;
  leavetype_t   leavetype;
  union {
    struct menu *submenu;
    config_t    *config_value;
    union {
      sys_call_0 sys_fun_0;
      sys_call_1 sys_fun_1;
      sys_call_2 sys_fun_2;
    };
  };
} leaves_t;

typedef struct menu {
  const screentype_t  type;
  const char*         *header;
  const char*         *overlay;
  struct menu         *parent;
  alt_u8              current_selection;
  const alt_u8        number_selections;
  leaves_t            leaves[];

} menu_t;

extern menu_t home_menu;

void val2txt_func(alt_u8 v);
void val2txt_5b_binaryoffset_func(alt_u8 v);
void val2txt_scale_sel_func(alt_u8 v);
void val2txt_hscale_func(alt_u8 v);
void val2txt_vscale_func(alt_u8 v);
void audioamp2txt_func(alt_u8 v);
void flag2set_func(alt_u8 v);
void scanline_str2txt_func(alt_u8 v);
void scanline_hybrstr2txt_func(alt_u8 v);
void gamma2txt_func(alt_u8 v);

void print_current_timing_mode(void);
void print_ctrl_data(void);

void update_vmode_menu(menu_t *menu);

updateaction_t modify_menu(cmd_t command, menu_t** current_menu);
void print_overlay(menu_t* current_menu);
void print_selection_arrow(menu_t* current_menu);
int update_vinfo_screen(menu_t* current_menu);
int update_cfg_screen(menu_t* current_menu);

#endif /* MENU_H_ */
