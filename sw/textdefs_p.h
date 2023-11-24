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
 * menu_text/textdefs_p.h
 *
 *  Created on: 14.01.2018
 *      Author: Peter Bartmann
 *
 ********************************************************************************/

#include <string.h>
#include <unistd.h>
#include "app_cfg.h"


#ifndef MENU_TEXT_TEXTDEFS_P_H_
#define MENU_TEXT_TEXTDEFS_P_H_

#define HEADER_UNDERLINE      0x08
#define HOME_LOWSEC_UNDERLINE 0x01

#define SMILEY              0x02
#define HEART               0x03
#define CHECKBOX_TICK       0x0D
#define TRIANGLE_LEFT       0x10
#define TRIANGLE_RIGHT      0x11
#define ARROW_LEFT          0x1A
#define ARROW_RIGHT         0x1B
#define EMPTY               0x20

#define OVERLAY_H_OFFSET       0
#define OVERLAY_V_OFFSET       0
#define TEXTOVERLAY_H_OFFSET   0
#define HOMEOVERLAY_H_OFFSET   3

#define VD_240P_HEADER_H_OFFSET   9
#define VD_240P_OVERLAY_V_OFFSET  4
#define VD_480I_OVERLAY_V_OFFSET  5
#define VD_240P_OVERLAY_H_OFFSET  7

#define COPYRIGHT_H_OFFSET      (VD_WIDTH - 16)
#define COPYRIGHT_V_OFFSET      0

#define VERSION_H_OFFSET (OVERLAY_H_OFFSET + 19)
#define VERSION_V_OFFSET (OVERLAY_V_OFFSET +  4)

#define  BNT_FCT_H_OFFSET 27
#define  BNT_FCT_V_OFFSET (VD_TXT_WIDTH - 1)

#define CONFIRM_H_LENGTH 9
#define CONFIRM_BTN_H_LENGTH  23
#define UNLOCK1140P_H_LENGTH 41

#define RESCFG_OVERLAY_H_OFFSET     OVERLAY_H_OFFSET
#define RESCFG_OVERLAY_V_OFFSET     OVERLAY_V_OFFSET
#define RESCFG_VALS_H_OFFSET        (29 + OVERLAY_H_OFFSET)
#define RESCFG_VALS_V_OFFSET        OVERLAY_V_OFFSET
#define RESCFG_INPUT_V_OFFSET       ( 0 + RESCFG_VALS_V_OFFSET)
#define RESCFG_240P_V_OFFSET        ( 2 + RESCFG_VALS_V_OFFSET)
#define RESCFG_480P_V_OFFSET        ( 3 + RESCFG_VALS_V_OFFSET)
#define RESCFG_720P_V_OFFSET        ( 4 + RESCFG_VALS_V_OFFSET)
#define RESCFG_960P_V_OFFSET        ( 5 + RESCFG_VALS_V_OFFSET)
#define RESCFG_1080P_V_OFFSET       ( 6 + RESCFG_VALS_V_OFFSET)
#define RESCFG_1200P_V_OFFSET       ( 7 + RESCFG_VALS_V_OFFSET)
#define RESCFG_1440P_V_OFFSET       ( 8 + RESCFG_VALS_V_OFFSET)
#define RESCFG_1440WP_V_OFFSET      ( 9 + RESCFG_VALS_V_OFFSET)
#define RESCFG_USE_VGA_RES_V_OFFSET (10 + RESCFG_VALS_V_OFFSET)
#define RESCFG_USE_SRCSYNC_V_OFFSET (11 + RESCFG_VALS_V_OFFSET)
#define RESCFG_FORCE_5060_V_OFFSET  (12 + RESCFG_VALS_V_OFFSET)

#define SCALERCFG_OVERLAY_H_OFFSET      OVERLAY_H_OFFSET
#define SCALERCFG_OVERLAY_V_OFFSET      OVERLAY_V_OFFSET
#define SCALERCFG_VALS_H_OFFSET         (30 + OVERLAY_H_OFFSET)
#define SCALERCFG_VALS_V_OFFSET         OVERLAY_V_OFFSET
#define SCALERCFG_V_INTERP_V_OFFSET     ( 0 + SCALERCFG_VALS_V_OFFSET)
#define SCALERCFG_H_INTERP_V_OFFSET     ( 1 + SCALERCFG_VALS_V_OFFSET)
#define SCALERCFG_IN2OUT_V_OFFSET       ( 3 + SCALERCFG_VALS_V_OFFSET)
#define SCALERCFG_LINKVH_V_OFFSET       ( 4 + SCALERCFG_VALS_V_OFFSET)
#define SCALERCFG_VHSTEPS_V_OFFSET      ( 5 + SCALERCFG_VALS_V_OFFSET)
#define SCALERCFG_VERTSCALE_V_OFFSET    ( 6 + SCALERCFG_VALS_V_OFFSET)
#define SCALERCFG_HORISCALE_V_OFFSET    ( 7 + SCALERCFG_VALS_V_OFFSET)
#define SCALERCFG_PALBOXED_V_OFFSET     ( 8 + SCALERCFG_VALS_V_OFFSET)
#define SCALERCFG_INSHIFTMODE_V_OFFSET  (10 + SCALERCFG_VALS_V_OFFSET)
#define SCALERCFG_VERTSHIFT_V_OFFSET    (11 + SCALERCFG_VALS_V_OFFSET)
#define SCALERCFG_HORISHIFT_V_OFFSET    (12 + SCALERCFG_VALS_V_OFFSET)

#define SLCFG_OVERLAY_H_OFFSET    OVERLAY_H_OFFSET
#define SLCFG_OVERLAY_V_OFFSET    OVERLAY_V_OFFSET
#define SLCFG_VALS_H_OFFSET       (26 + SLCFG_OVERLAY_H_OFFSET)
#define SLCFG_VALS_V_OFFSET       SLCFG_OVERLAY_V_OFFSET
#define SLCFG_INPUT_OFFSET        ( 0 + SLCFG_VALS_V_OFFSET)
#define SLCFG_CALC_BASE_V_OFFSET  ( 1 + SLCFG_VALS_V_OFFSET)
#define SLCFG_HEN_V_OFFSET        ( 2 + SLCFG_VALS_V_OFFSET)
#define SLCFG_HTHICKNESS_V_OFFSET ( 3 + SLCFG_VALS_V_OFFSET)
#define SLCFG_HPROFILE_V_OFFSET   ( 4 + SLCFG_VALS_V_OFFSET)
#define SLCFG_HSTR_V_OFFSET       ( 5 + SLCFG_VALS_V_OFFSET)
#define SLCFG_HHYB_STR_V_OFFSET   ( 6 + SLCFG_VALS_V_OFFSET)
#define SLCFG_VEN_V_OFFSET        ( 7 + SLCFG_VALS_V_OFFSET)
#define SLCFG_VLINK_OFFSET        ( 8 + SLCFG_VALS_V_OFFSET)
#define SLCFG_VTHICKNESS_V_OFFSET ( 9 + SLCFG_VALS_V_OFFSET)
#define SLCFG_VPROFILE_V_OFFSET   (10 + SLCFG_VALS_V_OFFSET)
#define SLCFG_VSTR_V_OFFSET       (11 + SLCFG_VALS_V_OFFSET)
#define SLCFG_VHYB_STR_V_OFFSET   (12 + SLCFG_VALS_V_OFFSET)

#define VICFG_OVERLAY_H_OFFSET      OVERLAY_H_OFFSET
#define VICFG_OVERLAY_V_OFFSET      OVERLAY_V_OFFSET
#define VICFG_VALS_H_OFFSET         (27 + OVERLAY_H_OFFSET)
#define VICFG_VALS_V_OFFSET         OVERLAY_V_OFFSET
#define VICFG_DEINTERL_V_OFFSET     ( 1 + VICFG_VALS_V_OFFSET)
#define VICFG_GAMMA_V_OFFSET        ( 2 + VICFG_VALS_V_OFFSET)
#define VICFG_COLORSPACE_V_OFFSET   ( 4 + VICFG_VALS_V_OFFSET)
#define VICFG_LIMITEDRANGE_V_OFFSET ( 5 + VICFG_VALS_V_OFFSET)
#define VICFG_DEBLUR_V_OFFSET       ( 6 + VICFG_VALS_V_OFFSET)
#define VICFG_PCDEBLUR_V_OFFSET     ( 7 + VICFG_VALS_V_OFFSET)
#define VICFG_16BITMODE_V_OFFSET    ( 8 + VICFG_VALS_V_OFFSET)
#define VICFG_PC16BITMODE_V_OFFSET  ( 9 + VICFG_VALS_V_OFFSET)

#define AUD_OVERLAY_H_OFFSET              OVERLAY_H_OFFSET
#define AUD_OVERLAY_V_OFFSET              OVERLAY_V_OFFSET
#define AUD_VALS_H_OFFSET                 (21 + AUD_OVERLAY_H_OFFSET)
#define AUD_FILTER_BYPASS_V_OFFSET        ( 2 + AUD_OVERLAY_V_OFFSET)
#define AUD_MUTE_V_OFFSET                 ( 4 + AUD_OVERLAY_V_OFFSET)
#define AUD_SWAP_LR_V_OFFSET              ( 5 + AUD_OVERLAY_V_OFFSET)
#define AUD_AMP_V_OFFSET                  ( 6 + AUD_OVERLAY_V_OFFSET)
#define AUD_SPDIF_EN_V_OFFSET             ( 8 + AUD_OVERLAY_V_OFFSET)

#define MISC_OVERLAY_H_OFFSET             OVERLAY_H_OFFSET
#define MISC_OVERLAY_V_OFFSET             OVERLAY_V_OFFSET
#define MISC_VALS_H_OFFSET                (26 + MISC_OVERLAY_H_OFFSET)
#define MISC_VALS_V_OFFSET                VICFG_OVERLAY_V_OFFSET
#define MISC_IGR_RESET_V_OFFSET           ( 2 + MISC_VALS_V_OFFSET)
#define MISC_IGR_DEBLUR_V_OFFSET          ( 3 + MISC_VALS_V_OFFSET)
#define MISC_IGR_16BITMODE_V_OFFSET       ( 4 + MISC_VALS_V_OFFSET)
#define MISC_RST_MASKING_V_OFFSET         ( 5 + MISC_VALS_V_OFFSET)
#define MISC_SWAP_LED_V_OFFSET            ( 7 + MISC_VALS_V_OFFSET)
#define MISC_DEBUG_BOOT_V_OFFSET          ( 8 + MISC_VALS_V_OFFSET)
#define MISC_LUCKY_1440P_V_OFFSET         ( 9 + MISC_VALS_V_OFFSET)

#define RWDATA_OVERLAY_H_OFFSET           ( 1 + OVERLAY_H_OFFSET)
#define RWDATA_OVERLAY_V_OFFSET           OVERLAY_V_OFFSET
#define RWDATA_VALS_H_OFFSET              (26 + RWDATA_OVERLAY_H_OFFSET)
#define RWDATA_VALS_V_OFFSET              VICFG_OVERLAY_V_OFFSET
#define RWDATA_AUTOSAVE_V_OFFSET          ( 1 + RWDATA_OVERLAY_V_OFFSET)
#define RWDATA_SAVE_FL_V_OFFSET           ( 2 + RWDATA_OVERLAY_V_OFFSET)
#define RWDATA_LOAD_FL_V_OFFSET           ( 4 + RWDATA_OVERLAY_V_OFFSET)
#define RWDATA_LOAD_FBDEFAULTS_V_OFFSET   ( 5 + RWDATA_OVERLAY_V_OFFSET)
#define RWDATA_CPYCFG_DIRECTION_V_OFFSET  ( 7 + RWDATA_OVERLAY_V_OFFSET)
#define RWDATA_CPYCFG_FUNCTION_V_OFFSET   ( 8 + RWDATA_OVERLAY_V_OFFSET)
#define RWDATA_FALLBACK_V_OFFSET          ( 9 + RWDATA_OVERLAY_V_OFFSET)

#define N64DEBUG_OVERLAY_H_OFFSET       OVERLAY_H_OFFSET
#define N64DEBUG_OVERLAY_V_OFFSET       OVERLAY_V_OFFSET
#define N64DEBUG_VALS_H_OFFSET          (19 + N64DEBUG_OVERLAY_H_OFFSET)
#define N64DEBUG_VALS_V_OFFSET          N64DEBUG_OVERLAY_V_OFFSET
#define N64DEBUG_N64ADV_STATE_V_OFFSET  ( 1 + N64DEBUG_VALS_V_OFFSET)
  #define N64DEBUG_N64ADV_VI_H_OFFSET     (19 + OVERLAY_H_OFFSET)
  #define N64DEBUG_N64ADV_VI_V_OFFSET     ( 1 + N64DEBUG_N64ADV_STATE_V_OFFSET)
  #define N64DEBUG_SSM_H_OFFSET           (19 + OVERLAY_H_OFFSET)
  #define N64DEBUG_SSM_V_OFFSET           ( 2 + N64DEBUG_N64ADV_STATE_V_OFFSET)
#define N64DEBUG_PIN_STATE_V_OFFSET     ( 4 + N64DEBUG_VALS_V_OFFSET)
  #define N64DEBUG_PIN_CLK_LINE0_V_OFFSET ( 1 + N64DEBUG_PIN_STATE_V_OFFSET)
  #define N64DEBUG_PIN_CLK_LINE1_V_OFFSET ( 2 + N64DEBUG_PIN_STATE_V_OFFSET)
  #define N64DEBUG_PIN_CLK_PLL1_H_OFFSET  (19 + N64DEBUG_OVERLAY_H_OFFSET)
  #define N64DEBUG_PIN_CLK_PLL0_H_OFFSET  (21 + N64DEBUG_OVERLAY_H_OFFSET)
  #define N64DEBUG_PIN_PLL_SRC_H_OFFSET   (23 + N64DEBUG_OVERLAY_H_OFFSET)
  #define N64DEBUG_PIN_CLK_SYS_H_OFFSET   (19 + N64DEBUG_OVERLAY_H_OFFSET)
  #define N64DEBUG_PIN_CLK_AUD_H_OFFSET   (28 + N64DEBUG_OVERLAY_H_OFFSET)
  #define N64DEBUG_PIN_CLK_N64_H_OFFSET   (36 + N64DEBUG_OVERLAY_H_OFFSET)
  #define N64DEBUG_PIN_VDATA_V_OFFSET     ( 3 + N64DEBUG_PIN_STATE_V_OFFSET)
  #define N64DEBUG_PIN_VD_SYNC_H_OFFSET   (19 + N64DEBUG_OVERLAY_H_OFFSET)
  #define N64DEBUG_PIN_VD_DATA_H_OFFSET   (28 + N64DEBUG_OVERLAY_H_OFFSET)
  #define N64DEBUG_PIN_AUDIO_V_OFFSET     ( 4 + N64DEBUG_PIN_STATE_V_OFFSET)
  #define N64DEBUG_PIN_AUDIO_LRC_H_OFFSET (19 + N64DEBUG_OVERLAY_H_OFFSET)
  #define N64DEBUG_PIN_AUDIO_SD_H_OFFSET  (28 + N64DEBUG_OVERLAY_H_OFFSET)
  #define N64DEBUG_PIN_AUDIO_SC_H_OFFSET  (36 + N64DEBUG_OVERLAY_H_OFFSET)
#define N64DEBUG_FUNC_H_OFFSET          (27 + N64DEBUG_OVERLAY_H_OFFSET)
#define N64DEBUG_FUNC_V_OFFSET          (10 + N64DEBUG_VALS_V_OFFSET)
  #define N64DEBUG_RESYNC_VI_PL_V_OFFSET  ( 0 + N64DEBUG_FUNC_V_OFFSET)
  #define N64DEBUG_LOCK_MENU_V_OFFSET     ( 1 + N64DEBUG_FUNC_V_OFFSET)

#define MAIN_OVERLAY_H_OFFSET   ( 3 + OVERLAY_H_OFFSET)
#define MAIN_OVERLAY_V_OFFSET   OVERLAY_V_OFFSET
#define MAIN2RES_V_OFFSET       ( 0 + MAIN_OVERLAY_V_OFFSET)
#define MAIN2SCALER_V_OFFSET    ( 1 + MAIN_OVERLAY_V_OFFSET)
#define MAIN2SCANLINE_V_OFFSET  ( 2 + MAIN_OVERLAY_V_OFFSET)
#define MAIN2VIPROC_V_OFFSET    ( 3 + MAIN_OVERLAY_V_OFFSET)
#define MAIN2AUDPROC_V_OFFSET   ( 4 + MAIN_OVERLAY_V_OFFSET)
#define MAIN2MISC_V_OFFSET      ( 5 + MAIN_OVERLAY_V_OFFSET)
#define MAIN2SAVE_V_OFFSET      ( 6 + MAIN_OVERLAY_V_OFFSET)
#define MAIN2DEBUG_V_OFFSET     ( 7 + MAIN_OVERLAY_V_OFFSET)
#define MAIN2ABOUT_V_OFFSET     ( 9 + MAIN_OVERLAY_V_OFFSET)
#define MAIN2THANKS_V_OFFSET    (10 + MAIN_OVERLAY_V_OFFSET)
#define MAIN2LICENSE_V_OFFSET   (11 + MAIN_OVERLAY_V_OFFSET)
#define MAIN2NOTICE_V_OFFSET    (12 + MAIN_OVERLAY_V_OFFSET)


const alt_u8 confirm_messages_color[] = {FONTCOLOR_GREEN,FONTCOLOR_RED,FONTCOLOR_MAGENTA,FONTCOLOR_NAVAJOWHITE};
const char *confirm_messages[] __ufmdata_section__  = {"< Success >","< Failed >","< Aborted >","< Sure? >","< Keep? >"};
const char *btn_fct_confirm_overlay __ufmdata_section__ = "(A..Confirm, B..Cancel)";

const char *Unlock_1440p_Message __ufmdata_section__ = "On your own risk, so good luck I guess. ";

static const char *copyright_note __ufmdata_section__ =
    " 2023 borti4938"; /* 14 chars */

static const char *resolution_header __ufmdata_section__ =
    "Resolution";
static const char *resolution_overlay __ufmdata_section__ =
    "* Input mode:\n"
    "* Output resolution:\n"
    "  - 240p/288p ( 4:3):\n"
    "  - 480p/576p ( 4:3):\n"
    "  -      720p (16:9):\n"
    "  -      960p ( 4:3):\n"
    "  -     1080p (16:9):\n"
    "  -     1200p ( 4:3):\n"
    "  -     1440p ( 4:3):\n"
    "  -     1440p (16:9):\n"
    "* Use VGA instead of 480p:\n"
    "* Frame-Locked mode:\n"
    "* Force 50/60:";

static const char *scaler_header __ufmdata_section__ =
    "Scaler";
static const char *scaler_overlay __ufmdata_section__ =
    "* Vertical interpolation:\n"
    "* Horizontal interpolation:\n"
    "* Scaling:\n"
    "  - Settings for:\n"
    "  - Link v/h factors:\n"
    "  - V/h scaling steps:\n"
    "  - Vertical scale value:\n"
    "  - Horizontal scale value:\n"
    "* Use PAL in 240p box:\n"
    "* Shift N64 input image:\n"
    "  - Input Mode:\n"
    "  - Vertical shift:\n"
    "  - Horizontal shift:";

static const char *slcfg_opt_header __ufmdata_section__ =
    "Scanlines Config";
static const char *slcfg_opt_overlay __ufmdata_section__ =
    "* Input mode:\n"
    "* Calculation mode:\n"
    "* Horizontal scanlines:\n"
    "  - Thickness:\n"
    "  - Profile:\n"
    "  - Strength:\n"
    "  - Blooming effect:\n"
    "* Vertical scanlines:\n"
    "  - Link to horizontal:\n"
    "  - Thickness:\n"
    "  - Profile:\n"
    "  - Strength:\n"
    "  - Blooming effect:";

static const char *vicfg_header __ufmdata_section__ =
    "VI-Processing";
static const char *vicfg_overlay __ufmdata_section__ =
    "\n"
    "* De-Interlacing mode:\n"
    "* Gamma value:\n"
    "* Color space:\n"
    "  - Format:\n"
    "  - Limited range:\n"
    "* LowRes.-DeBlur:\n"
    "  - Power-cycle default:\n"
    "* 16bit mode:\n"
    "  - Power-cycle default:";

static const char *audcfg_header __ufmdata_section__ =
    "Audio-Processing";
static const char *audcfg_overlay __ufmdata_section__ =
    "\n* Filter Options:\n"
    "  - Bypass filter:\n"
    "* Output Settings:\n"
    "  - Mute Audio:\n"
    "  - Swap L/R:\n"
    "  - Output gain:\n"
    "* S/PDIF-Support:\n"
    "  - Enable:";

static const char *misc_header __ufmdata_section__ =
    "Miscellaneous";
static const char *misc_overlay __ufmdata_section__ =
    "\n* Controller routines:\n"
    "  - Reset:\n"
    "  - VI-DeBlur:\n"
    "  - 16bit mode:\n"
    "* Reset masking:\n"
    "* Menu-Variations:\n"
    "  - Swap R/G-LED:\n"
    "  - Debug-Boot:\n"
    "* Unlock lucky 1440p:";

static const char *rwdata_header __ufmdata_section__ =
    "Save/Load";
static const char *rwdata_overlay __ufmdata_section__ =
    "* Save\n"
    "  - Autosave:\n"
    "  - Configuration now:\n"
    "* Load\n"
    "  - Last configuration:\n"
    "  - Fallback defaults:\n"
    "* Copy:\n"
    "  - Direction:\n"
    "  - Copy config now:\n"
    "* Fallback config:";

static const char *n64debug_header __ufmdata_section__ =
    "Debug-Info";
static const char *n64debug_overlay __ufmdata_section__ =
    "\n"
    "* PPU state value:\n"
    "  - VI mode:\n"
    "  - Frame-Lock:\n"
    "* Pin check value:\n"
    "  - CLKs:    PLL : -/\n"
    "             Sys.: -, Aud.: -, N64:\n"
    "  - VI:      Sync: -, Data: -/-/-/-/-/-/\n"
    "  - Audio:   ALRC: -, ASD : -, ASC:\n\n"
    "* Re-sync VI pipeline:\n"
    "* Lock menu (ctrl. test):";
  /* 123456789012345678901234567890123456789012345678 */

#ifndef DEBUG
  static const char *thanks_header __ufmdata_section__ =
      "Acknowledgment";
  static const char *thanks_overlay __ufmdata_section__ =
      "The N64 RGB project would not be what it is\n"
      "without the contributions of many other people.\n"
      "Here, I want to point out especially:\n"
      " - Ikari_01: DIY USB Blaster module;\n"
      "     initial PAL/NTSC and 480i/576i detection\n"
      " - marqs85: Concept for low latency mode PLL\n"
      "     config.; very useful feedback in general\n"
      " - ArcadeTV: Logo design\n"
      " - ManCloud, donking2000: 3D prints for N64Adv2\n"
      "Visit the GitHub project:\n"
      "   <https://github.com/borti4938/\n"
      "                      n64rgb_project_overview>\n"
      "Any contribution in any kind is highly welcomed!";
    /* 123456789012345678901234567890123456789012345678 */

  static const char *about_header __ufmdata_section__ =
      "About";
  static const char *about_overlay __ufmdata_section__ =
      "The N64 RGB project is open source, i.e. PCB\n"
      "files, HDL and SW sources are provided to you\n"
      "FOR FREE!\n"
      "Your version\n"
      " - PCB version:\n"
      " - FPGA Chip ID:\n"
      " - firmware (HDL):\n"
      " - firmware (SW) :\n"
      "Questions / (limited) Support:\n"
      " - GitHub:\n"
      "      <https://github.com/borti4938/n64adv2_pcb>\n"
      "      <https://github.com/borti4938/n64adv2_fw>\n"
      " - Email:  <borti4938@gmail.com>";
    /* 123456789012345678901234567890123456789012345678 */

  static const char *license_header __ufmdata_section__ =
      "License";
  static const char *license_overlay __ufmdata_section__ =
      "The N64Advanced v2 is part of the\n"
      "N64 RGB/YPbPr Digital2Digital and DAC project\n"
      "    Copyright  2015 - 2023 Peter Bartmann\n"
      "This project is published under the following\n"
      "licenses:\n"
      " - Hardware: CERN-OHL-W v2\n"
      " - Software: GNU GPL v3.0\n"
      "or later. You should have received a copy of the\n"
      "licenses along with this project. If not, you\n"
      "will find license files / text in the GitHub\n"
      "repositories (URLs see About page).\n"
      "What ever you do, also respect licenses of third\n"
      "party vendors providing the design tools...";
    /* 123456789012345678901234567890123456789012345678 */

  #ifdef USE_NOTICE_SECTION
    static const char *notice_header __ufmdata_section__ =
        "Example Note";
    static const char *notice_overlay __ufmdata_section__ =
        "123456789012345678901234567890123456789012345678\n"
        "2\n"
        "3\n"
        "4\n"
        "5\n"
        "6\n"
        "7\n"
        "8\n"
        "9\n"
        "0\n"
        "1\n"
        "2\n"
        "3\n"
        "4";
      /* 123456789012345678901234567890123456789012345678 */
  #endif
#endif

static const char *home_header __ufmdata_section__ =
    "Main Menu";
static const char *home_overlay __ufmdata_section__ =
    "[Resolution]\n"
    "[Scaler]\n"
    "[Scanlines]\n"
    "[VI-Processing]\n"
    "[Audio-Processing]\n"
    "[Miscellaneous]\n"
    "[Save/Load/Fallback]\n"
    "[Debug-Info]\n\n"
#ifndef DEBUG
    "About...\n"
    "Acknowledgment...\n"
    "License...\n"
  #ifdef USE_NOTICE_SECTION
    "Special Note..."
  #endif
#else
    "*** DEBUG BUILD ***"
#endif
  ;
  /* 123456789012345678901234567890123456789012345678 */


const char *EnterSubMenu  __ufmdata_section__ = "[Enter ...]";
const char *RunFunction   __ufmdata_section__ = "[Run ...]";
const char *not_available __ufmdata_section__ = "-----";
const char *Global        __ufmdata_section__ = "Global";

const char *OffOn[]                 __ufmdata_section__ = {"Off","On"};
const char *NTSCPAL_SEL[]           __ufmdata_section__ = {"NTSC  ","PAL   ","Current"};
const char *Force5060[]             __ufmdata_section__ = {"Off (N64 Auto)","60Hz","50Hz"};
const char *Resolutions[]           __ufmdata_section__ = {"240p/288p","480p/576p","720p","960p","1080p","1200p","1440p","1440p w."};
const char *FallbackRes[]           __ufmdata_section__ = {"1080p","240p/288p","480p/576p"};
const char *DeInterModes[]          __ufmdata_section__ = {"Frame Drop","Bob","Weave"};
const char *InterpModes[]           __ufmdata_section__ = {"Integer","Integer (soft)","Integer+Bilinear","Bilinear"};
const char *VTimingSel[]            __ufmdata_section__ = {"NTSC Progr.","NTSC Interl.","PAL Progr.","PAL Interl.","Current"};
const char *ScanlinesCalcBase[]     __ufmdata_section__ = {"Per color based","Luma based"};
const char *ScanlinesThickness[]    __ufmdata_section__ = {"Adaptive","Thin","Normal","Thick"};
const char *ScanlinesScaleProfile[] __ufmdata_section__ = {"Hanning","Gaussian","Rectangular"};

const char *RstMasking[] __ufmdata_section__ = {"None","VI pipeline","Audio","VI + Audio"};

const char *DebugBoot[] __ufmdata_section__ = {"Debug at no vi-input","Normal boot"};

const char *VideoMode[]  __ufmdata_section__ = {"240p","480i","288p","576i"};
const char *VRefresh[]   __ufmdata_section__ = {"@ 60Hz","@ 50Hz"};
const char *VideoColor[] __ufmdata_section__ = {"21bit (7/7/7)","16bit (5/6/5)"};

const char *ResolutionVGA        __ufmdata_section__ = "VGA (640x480)";
const char *Resolution240p480p[] __ufmdata_section__ = {"240p","480p"};
const char *Resolution288p576p[] __ufmdata_section__ = {"288p","576p"};
const char *text_480i_576i_br    __ufmdata_section__ = "(480i/576i)";

const char *ScaleSteps[]           __ufmdata_section__ = {"0.25x","Pixelwise"};
const char *PredefScaleSteps[]     __ufmdata_section__ = {"(2.00x)","(2.25x)","(2.50x)","(2.75x)",
                                                          "(3.00x)","(3.25x)","(3.50x)","(3.75x)",
                                                          "(4.00x)","(4.25x)","(4.50x)","(4.75x)",
                                                          "(5.00x)","(5.25x)","(5.50x)","(5.75x)",
                                                          "(6.00x)","(6.25x)","(6.50x)","(6.75x)",
                                                          "(7.00x)","(7.25x)","(7.50x)","(7.75x)",
                                                          "(8.00x)"};
const char *PredefScaleStepsHalf[] __ufmdata_section__ = {"(1.00x)","(1.25x)","(1.50x)","(1.75x)",
                                                          "(2.00x)","(2.25x)","(2.50x)","(2.75x)",
                                                          "(3.00x)","(3.25x)","(3.50x)","(3.75x)",
                                                          "(4.00x)"};
const char *ScaleVHLink[] __ufmdata_section__ = {"4:3 (PAR 1:1)","CRT (PAR 120:119)","16:9 (PAR 4:3)","Open"};

const char *ColorSpace[] __ufmdata_section__ = {"RGB","YCbCr (ITU601/SD)","YCbCr (ITU709/HD)",};

//const char *CopyCfg[] __ufmdata_section__ = {"NTSC->PAL","PAL->NTSC"};
const char *CopyCfg[] __ufmdata_section__ = {"NTSC  PAL","PAL  NTSC"};
const char *pcb_rev[] __ufmdata_section__ = {"N64Adv2_20210521","N64Adv2_20220729","N64Adv2_20231119","n.a."};

const alt_u8 Nok_Ok_color[3] = {FONTCOLOR_RED,FONTCOLOR_GREEN,FONTCOLOR_YELLOW};
const alt_u8 Nok_Ok[2] = {CHECKBOX_TICK,HEART};
const char *ClkSrc[]   __ufmdata_section__ = {"27Mhz","N64"};

const char *NoCtrlDetected  __ufmdata_section__ = "No controller detected";
const char *NoVideoDetected __ufmdata_section__ = "No video input detected";

#endif /* MENU_TEXT_TEXTDEFS_P_H_ */
