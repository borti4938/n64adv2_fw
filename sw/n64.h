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
 * n64.h
 *
 *  Created on: 06.01.2018
 *      Author: Peter Bartmann
 *
 ********************************************************************************/

#include "alt_types.h"
#include "common_types.h"
#include "altera_avalon_pio_regs.h"
#include "system.h"
#include "config.h"


#ifndef N64_H_
#define N64_H_

#define CTRL_A_OFFSET      0
#define CTRL_B_OFFSET      1
#define CTRL_Z_OFFSET      2
#define CTRL_START_OFFSET  3
#define CTRL_DU_OFFSET     4
#define CTRL_DD_OFFSET     5
#define CTRL_DL_OFFSET     6
#define CTRL_DR_OFFSET     7
#define CTRL_L_OFFSET     10
#define CTRL_R_OFFSET     11
#define CTRL_CU_OFFSET    12
#define CTRL_CD_OFFSET    13
#define CTRL_CL_OFFSET    14
#define CTRL_CR_OFFSET    15
#define CTRL_XAXIS_OFFSET 16
#define CTRL_YAXIS_OFFSET 24

#define CTRL_GETALL_MASK          0xFFFFFFFF
#define CTRL_GETALL_DIGITAL_MASK  0x0000FFFF
#define CTRL_GETALL_ANALOG_MASK   0xFFFF0000
#define CTRL_A_GETMASK            (1<<CTRL_A_OFFSET)
#define CTRL_A_SETMASK            (1<<CTRL_A_OFFSET)
#define CTRL_B_GETMASK            (1<<CTRL_B_OFFSET)
#define CTRL_B_SETMASK            (1<<CTRL_B_OFFSET)
#define CTRL_Z_GETMASK            (1<<CTRL_Z_OFFSET)
#define CTRL_Z_SETMASK            (1<<CTRL_Z_OFFSET)
#define CTRL_START_GETMASK        (1<<CTRL_START_OFFSET)
#define CTRL_START_SETMASK        (1<<CTRL_START_OFFSET)
#define CTRL_DU_GETMASK           (1<<CTRL_DU_OFFSET)
#define CTRL_DU_SETMASK           (1<<CTRL_DU_OFFSET)
#define CTRL_DD_GETMASK           (1<<CTRL_DD_OFFSET)
#define CTRL_DD_SETMASK           (1<<CTRL_DD_OFFSET)
#define CTRL_DL_GETMASK           (1<<CTRL_DL_OFFSET)
#define CTRL_DL_SETMASK           (1<<CTRL_DL_OFFSET)
#define CTRL_DR_GETMASK           (1<<CTRL_DR_OFFSET)
#define CTRL_DR_SETMASK           (1<<CTRL_DR_OFFSET)
#define CTRL_L_GETMASK            (1<<CTRL_L_OFFSET)
#define CTRL_L_SETMASK            (1<<CTRL_L_OFFSET)
#define CTRL_R_GETMASK            (1<<CTRL_R_OFFSET)
#define CTRL_R_SETMASK            (1<<CTRL_R_OFFSET)
#define CTRL_CU_GETMASK           (1<<CTRL_CU_OFFSET)
#define CTRL_CU_SETMASK           (1<<CTRL_CU_OFFSET)
#define CTRL_CD_GETMASK           (1<<CTRL_CD_OFFSET)
#define CTRL_CD_SETMASK           (1<<CTRL_CD_OFFSET)
#define CTRL_CL_GETMASK           (1<<CTRL_CL_OFFSET)
#define CTRL_CL_SETMASK           (1<<CTRL_CL_OFFSET)
#define CTRL_CR_GETMASK           (1<<CTRL_CR_OFFSET)
#define CTRL_CR_SETMASK           (1<<CTRL_CR_OFFSET)
#define CTRL_XAXIS_GETMASK        (0xFF<<CTRL_XAXIS_OFFSET)
#define CTRL_YAXIS_GETMASK        (0xFF<<CTRL_YAXIS_OFFSET)


#define BTN_OPEN_OSDMENU  (CTRL_L_SETMASK|CTRL_R_SETMASK|CTRL_DR_SETMASK|CTRL_CR_SETMASK)
#define BTN_CLOSE_OSDMENU (CTRL_L_SETMASK|CTRL_R_SETMASK|CTRL_DL_SETMASK|CTRL_CL_SETMASK)

#define BTN_MUTE_OSDMENU  (CTRL_L_SETMASK|CTRL_Z_SETMASK)

#define BTN_DEBLUR_QUICK_ON   (CTRL_Z_SETMASK|CTRL_START_SETMASK|CTRL_R_SETMASK|CTRL_CR_SETMASK)
#define BTN_DEBLUR_QUICK_OFF  (CTRL_Z_SETMASK|CTRL_START_SETMASK|CTRL_R_SETMASK|CTRL_CL_SETMASK)
#define BTN_16BIT_QUICK_ON    (CTRL_Z_SETMASK|CTRL_START_SETMASK|CTRL_R_SETMASK|CTRL_CD_SETMASK)
#define BTN_16BIT_QUICK_OFF   (CTRL_Z_SETMASK|CTRL_START_SETMASK|CTRL_R_SETMASK|CTRL_CU_SETMASK)

#define BTN_MENU_ENTER  CTRL_A_SETMASK
#define BTN_MENU_BACK   CTRL_B_SETMASK

#define N64ADV_INPUT_CTRL_DETECTED_OFFSET     26
#define N64ADV_INPUT_VDATA_DETECTED_OFFSET    25
#define N64ADV_INPUT_PALPATTERN_OFFSET        24
#define N64ADV_INPUT_PALMODE_OFFSET           23
#define N64ADV_INPUT_INTERLACED_OFFSET        22
#define N64ADV_FORCE5060_OFFSET               20
#define N64ADV_USE_VGA_FOR_480P_OFFSET        19
#define N64ADV_RESOLUTION_OFFSET              16
#define N64ADV_LLM_SLBUF_FB_OFFSET             7
#define N64ADV_LOWLATENCYMODE_OFFSET           6
#define N64ADV_240P_DEBLUR_OFFSET              5
#define N64ADV_COLOR_16BIT_MODE_OFFSET         4
#define N64ADV_GAMMA_TABLE_OFFSET              0

#define N64ADV_FEEDBACK_GETALL_MASK           0x7FFFFFF
#define N64ADV_INPUT_CTRL_DETECTED_GETMASK    (1<<N64ADV_INPUT_CTRL_DETECTED_OFFSET)
#define N64ADV_INPUT_VDATA_DETECTED_GETMASK   (1<<N64ADV_INPUT_VDATA_DETECTED_OFFSET)
#define N64ADV_INPUT_PALPATTERN_GETMASK       (1<<N64ADV_INPUT_PALPATTERN_OFFSET)
#define N64ADV_INPUT_PALMODE_GETMASK          (1<<N64ADV_INPUT_PALMODE_OFFSET)
#define N64ADV_INPUT_INTERLACED_GETMASK       (1<<N64ADV_INPUT_INTERLACED_OFFSET)
#define N64ADV_FORCE5060_GETMASK              (0x3<<N64ADV_FORCE5060_OFFSET)
#define N64ADV_USE_VGA_FOR_480P_GETMASK       (1<<N64ADV_USE_VGA_FOR_480P_OFFSET)
#define N64ADV_RESOLUTION_GETMASK             (0x7<<N64ADV_RESOLUTION_OFFSET)
#define N64ADV_LLM_SLBUF_FB_GETMASK           (0x1FF<<N64ADV_LLM_SLBUF_FB_OFFSET)
#define N64ADV_LOWLATENCYMODE_GETMASK         (1<<N64ADV_LOWLATENCYMODE_OFFSET)
#define N64ADV_240P_DEBLUR_GETMASK            (1<<N64ADV_240P_DEBLUR_OFFSET)
#define N64ADV_COLOR_16BIT_MODE_GETMASK       (1<<N64ADV_COLOR_16BIT_MODE_OFFSET)
#define N64ADV_GAMMA_TABLE_GETMASK            (0xF<<N64ADV_GAMMA_TABLE_OFFSET)

#define PIN_STATE_SYSCLK_OFFSET   15
#define PIN_STATE_AUDCLK_OFFSET   14
#define PIN_STATE_PLL1CLK_OFFSET  13
#define PIN_STATE_PLL0CLK_OFFSET  12
#define PIN_STATE_N64CLK_OFFSET   11
#define PIN_STATE_D0_OFFSET       10
#define PIN_STATE_D1_OFFSET        9
#define PIN_STATE_D2_OFFSET        8
#define PIN_STATE_D3_OFFSET        7
#define PIN_STATE_D4_OFFSET        6
#define PIN_STATE_D5_OFFSET        5
#define PIN_STATE_D6_OFFSET        4
#define PIN_STATE_DSYNC_OFFSET     3
#define PIN_STATE_ALRCLK_OFFSET    2
#define PIN_STATE_ASDATA_OFFSET    1
#define PIN_STATE_ASCLK_OFFSET     0

#define PIN_STATE_GETALL_MASK     0xFFFF
#define PIN_STATE_SYSCLK_GETMASK  (1<<PIN_STATE_SYSCLK_OFFSET)
#define PIN_STATE_AUDCLK_GETMASK  (1<<PIN_STATE_AUDCLK_OFFSET)
#define PIN_STATE_PLL1CLK_GETMASK (1<<PIN_STATE_PLL1CLK_OFFSET)
#define PIN_STATE_PLL0CLK_GETMASK (1<<PIN_STATE_PLL0CLK_OFFSET)
#define PIN_STATE_N64CLK_GETMASK  (1<<PIN_STATE_N64CLK_OFFSET)
#define PIN_STATE_D0_GETMASK      (1<<PIN_STATE_D0_OFFSET)
#define PIN_STATE_D1_GETMASK      (1<<PIN_STATE_D1_OFFSET)
#define PIN_STATE_D2_GETMASK      (1<<PIN_STATE_D2_OFFSET)
#define PIN_STATE_D3_GETMASK      (1<<PIN_STATE_D3_OFFSET)
#define PIN_STATE_D4_GETMASK      (1<<PIN_STATE_D4_OFFSET)
#define PIN_STATE_D5_GETMASK      (1<<PIN_STATE_D5_OFFSET)
#define PIN_STATE_D6_GETMASK      (1<<PIN_STATE_D6_OFFSET)
#define PIN_STATE_DSYNC_GETMASK   (1<<PIN_STATE_DSYNC_OFFSET)
#define PIN_STATE_ALRCLK_GETMASK  (1<<PIN_STATE_ALRCLK_OFFSET)
#define PIN_STATE_ASDATA_GETMASK  (1<<PIN_STATE_ASDATA_OFFSET)
#define PIN_STATE_ASCLK_GETMASK   (1<<PIN_STATE_ASCLK_OFFSET)

#define PIN_STATE_AUDIO_PINS_GETMASK    (PIN_STATE_ALRCLK_GETMASK | PIN_STATE_ASDATA_GETMASK | PIN_STATE_ASCLK_GETMASK)
#define PIN_STATE_NOAUDIO_PINS_GETMASK  (0xFFFF & ~PIN_STATE_AUDIO_PINS_GETMASK)

#define FALLBACKMODE_OFFSET        1
#define FALLBACKMODE_VALID_OFFSET  0

#define FALLBACK_GETALL_MASK        0x3
#define FALLBACKMODE_GETMASK        (1<<FALLBACKMODE_OFFSET)
#define FALLBACKMODE_VALID_GETMASK  (1<<FALLBACKMODE_VALID_OFFSET)

#define GAME_ID_VALID_IN_MASK       0x04
#define NEW_CTRL_DATA_IN_MASK       0x02
#define NVSYNC_IN_MASK              0x01

#define PERIPHALS_CFG_RDY_OFFSET     5
#define EXT_INFO_SEL_OFFSET          2
#define RUN_PINCHECK_OFFSET          1
#define CTRL_TACK_BIT_OFFSET         0

#define SYNC_INFO_OUT_ALL_MASK      0x3F
#define PERIPHALS_CFG_RDY_SET_MASK  (1 << PERIPHALS_CFG_RDY_OFFSET)
#define PERIPHALS_CFG_RDY_CLR_MASK  (~PERIPHALS_CFG_RDY_SET_MASK & SYNC_INFO_OUT_ALL_MASK)
#define EXT_INFO_GET_MASK           (0x7 << EXT_INFO_SEL_OFFSET)
#define EXT_INFO_CLR_MASK           (~EXT_INFO_GET_MASK & SYNC_INFO_OUT_ALL_MASK)
#define RUN_PINCHECK_SET_MASK       (1 << RUN_PINCHECK_OFFSET)
#define RUN_PINCHECK_CLR_MASK       (~RUN_PINCHECK_SET_MASK & SYNC_INFO_OUT_ALL_MASK)
#define CTRL_TACK_BIT_SET_MASK      (1 << CTRL_TACK_BIT_OFFSET)
#define CTRL_TACK_BIT_CLR_MASK      (~CTRL_TACK_BIT_SET_MASK & SYNC_INFO_OUT_ALL_MASK)

#define PCB_REV_OFFSET      12
#define GET_PCB_REV_MASK    0x3000
#define HDL_FW_OFFSET       0
#define GET_HDL_FW_MASK     0x0FFF

#define HDL_FW_MAIN_OFFSET  8
#define HDL_FW_SUB_OFFSET   0
#define HDL_FW_GETALL_MASK  0xFFF
  #define HDL_FW_GETMAIN_MASK (0xF << HDL_FW_MAIN_OFFSET)
  #define HDL_FW_GETSUB_MASK  (0x0FF << HDL_FW_SUB_OFFSET)

#define CTRL_IGNORE_FRAMES 10

#define WAIT_2MS    2000
#define WAIT_500US  500


typedef enum {
  CMD_NON = 0,
  CMD_OPEN_MENU,
  CMD_CLOSE_MENU,
  CMD_MUTE_MENU,
  CMD_UNMUTE_MENU,
  CMD_DEBLUR_QUICK_ON,
  CMD_DEBLUR_QUICK_OFF,
  CMD_16BIT_QUICK_ON,
  CMD_16BIT_QUICK_OFF,
  CMD_MENU_ENTER,
  CMD_MENU_BACK,
  CMD_MENU_PAGE_RIGHT,
  CMD_MENU_PAGE_LEFT,
  CMD_MENU_UP,
  CMD_MENU_DOWN,
  CMD_MENU_LEFT,
  CMD_MENU_RIGHT
} cmd_t;

extern bool_t init_phase;

extern alt_u8 info_sync_val;
extern alt_u32 ctrl_data;
extern alt_u32 n64adv_state;
extern bool_t video_input_detected;
extern cfg_pal_pattern_t pal_pattern;
extern vmode_t palmode;
extern scanmode_t scanmode;
extern bool_t hor_hires;

extern alt_u8 game_id[10];

void periphals_clr_ready_bit(void);
void periphals_set_ready_bit(void);
void update_n64adv_state(void);
void run_pin_state(bool_t enable);
alt_u16 get_pin_state(void);
void update_ctrl_data(void);
cmd_t ctrl_data_to_cmd(bool_t no_fast_skip);
void loop_sync(bool_t with_escape);
int resync_vi_pipeline(void);
bool_t new_ctrl_available(void);
bool_t get_fallback_mode(void);
bool_t is_fallback_mode_valid(void);
bool_t get_game_id(void);
alt_u32 get_chip_id(cfg_offon_t msb_select);
alt_u16 get_hw_version(void);

#endif /* N64_H_ */
