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
#define HEADER_H_OFFSET       24
#define HEADER_V_OFFSET        0
#define OVERLAY_H_OFFSET       0
#define OVERLAY_V_OFFSET       0
#define OVERLAY_V_OFFSET_WH    0
#define TEXTOVERLAY_H_OFFSET   0
#define HOMEOVERLAY_H_OFFSET   3

#define VD_240P_HEADER_H_OFFSET   9
#define VD_240P_OVERLAY_V_OFFSET  4
#define VD_480I_OVERLAY_V_OFFSET  5
#define VD_240P_OVERLAY_H_OFFSET  7

#define COPYRIGHT_SIGN          0x0A
#define COPYRIGHT_H_OFFSET      (VD_WIDTH - 14)
#define COPYRIGHT_V_OFFSET      0
#define COPYRIGHT_SIGN_H_OFFSET (COPYRIGHT_H_OFFSET - 2)

#define CR_SIGN_LICENSE_H_OFFSET  17
#define CR_SIGN_LICENSE_V_OFFSET   2

#define VERSION_H_OFFSET (OVERLAY_H_OFFSET + 17)
#define VERSION_V_OFFSET (OVERLAY_V_OFFSET +  4)

#define CHECKBOX_TICK 0x0D

#define VICFG_OVERLAY_H_OFFSET    OVERLAY_H_OFFSET
#define VICFG_OVERLAY_V_OFFSET    OVERLAY_V_OFFSET_WH
#define VICFG_VALS_H_OFFSET       (31 + VICFG_OVERLAY_H_OFFSET)
#define VICFG_VALS_V_OFFSET       VICFG_OVERLAY_V_OFFSET
#define VICFG1_RESOLUTION_V_OFFSET          ( 0 + VICFG_VALS_V_OFFSET)
#define VICFG1_DEINTERLACING_V_OFFSET       ( 2 + VICFG_VALS_V_OFFSET)
#define VICFG1_SCANLINES_V_OFFSET           ( 3 + VICFG_VALS_V_OFFSET)
#define VICFG1_SCALER_OPT_V_OFFSET          ( 4 + VICFG_VALS_V_OFFSET)
#define VICFG1_TIMING_V_OFFSET              ( 5 + VICFG_VALS_V_OFFSET)
#define VICFG1_PAGE2_V_OFFSET               ( 7 + VICFG_VALS_V_OFFSET)
#define VICFG2_GAMMA_V_OFFSET               ( 0 + VICFG_VALS_V_OFFSET)
#define VICFG2_LIMRGB_V_OFFSET              ( 1 + VICFG_VALS_V_OFFSET)
#define VICFG2_DEBLURMODE_V_OFFSET          ( 2 + VICFG_VALS_V_OFFSET)
#define VICFG2_DEBLURMODE_DEF_V_OFFSET      ( 3 + VICFG_VALS_V_OFFSET)
#define VICFG2_16BIT_V_OFFSET               ( 4 + VICFG_VALS_V_OFFSET)
#define VICFG2_16BIT_DEF_V_OFFSET           ( 5 + VICFG_VALS_V_OFFSET)
#define VICFG2_PAGE1_V_OFFSET               ( 7 + VICFG_VALS_V_OFFSET)

#define VICFG_RES_OVERLAY_H_OFFSET  OVERLAY_H_OFFSET
#define VICFG_RES_OVERLAY_V_OFFSET  OVERLAY_V_OFFSET_WH
#define VICFG_RES_VALS_H_OFFSET     (32 + VICFG_SL_OVERLAY_H_OFFSET)
#define VICFG_RES_VALS_V_OFFSET     VICFG_SL_OVERLAY_V_OFFSET
#define VICFG_RES_INPUT_V_OFFSET    ( 0 + VICFG_RES_VALS_V_OFFSET)
#define VICFG_RES_OUTPUT_V_OFFSET   ( 1 + VICFG_RES_VALS_V_OFFSET)
#define VICFG_USE_VGA_RES_V_OFFSET  ( 2 + VICFG_RES_VALS_V_OFFSET)
#define VICFG_USE_SRCSYNC_V_OFFSET  ( 3 + VICFG_RES_VALS_V_OFFSET)
#define VICFG_FORCE_5060_V_OFFSET   ( 4 + VICFG_RES_VALS_V_OFFSET)
#define VICFG_RES_SCALER_V_OFFSET   ( 6 + VICFG_RES_VALS_V_OFFSET)

#define VICFG_SL_OVERLAY_H_OFFSET	OVERLAY_H_OFFSET
#define VICFG_SL_OVERLAY_V_OFFSET OVERLAY_V_OFFSET_WH
#define VICFG_SL_VALS_H_OFFSET    (26 + VICFG_SL_OVERLAY_H_OFFSET)
#define VICFG_SL_VALS_V_OFFSET    VICFG_SL_OVERLAY_V_OFFSET
#define VICFG_SL_INPUT_OFFSET     ( 0 + VICFG_SL_VALS_V_OFFSET)
#define VICFG_SL_EN_V_OFFSET      ( 2 + VICFG_SL_VALS_V_OFFSET)
#define VICFG_SL_METHOD_V_OFFSET  ( 3 + VICFG_SL_VALS_V_OFFSET)
#define VICFG_SL_ID_V_OFFSET      ( 4 + VICFG_SL_VALS_V_OFFSET)
#define VICFG_SL_STR_V_OFFSET     ( 5 + VICFG_SL_VALS_V_OFFSET)
#define VICFG_SL_HYB_STR_V_OFFSET ( 6 + VICFG_SL_VALS_V_OFFSET)

#define VICFG_VTIMSUB_OVERLAY_H_OFFSET  TEXTOVERLAY_H_OFFSET
#define VICFG_VTIMSUB_OVERLAY_V_OFFSET  OVERLAY_V_OFFSET_WH
#define VICFG_VTIMSUB_VALS_H_OFFSET     (26 + VICFG_VTIMSUB_OVERLAY_H_OFFSET)
#define VICFG_VTIMSUB_MODE_V_OFFSET     ( 0 + VICFG_VTIMSUB_OVERLAY_V_OFFSET)
#define VICFG_VTIMSUB_VSHIFT_V_OFFSET   ( 2 + VICFG_VTIMSUB_OVERLAY_V_OFFSET)
#define VICFG_VTIMSUB_HSHIFT_V_OFFSET   ( 3 + VICFG_VTIMSUB_OVERLAY_V_OFFSET)
#define VICFG_VTIMSUB_RESET_V_OFFSET    ( 5 + VICFG_VTIMSUB_OVERLAY_V_OFFSET)

#define VICFG_SCALESUB_OVERLAY_H_OFFSET   TEXTOVERLAY_H_OFFSET
#define VICFG_SCALESUB_OVERLAY_V_OFFSET   OVERLAY_V_OFFSET_WH
#define VICFG_SCALESUB_VALS_H_OFFSET      (30 + VICFG_SCALESUB_OVERLAY_H_OFFSET)
#define VICFG_SCALESUB_MODE_V_OFFSET      ( 0 + VICFG_SCALESUB_OVERLAY_V_OFFSET)
#define VICFG_SCALESUB_INTERPM_V_OFFSET   ( 2 + VICFG_SCALESUB_OVERLAY_V_OFFSET)
#define VICFG_SCALESUB_HVLINK_V_OFFSET    ( 3 + VICFG_SCALESUB_OVERLAY_V_OFFSET)
#define VICFG_SCALESUB_VSCALE_V_OFFSET    ( 4 + VICFG_SCALESUB_OVERLAY_V_OFFSET)
#define VICFG_SCALESUB_HSCALE_V_OFFSET    ( 5 + VICFG_SCALESUB_OVERLAY_V_OFFSET)
#define VICFG_SCALESUB_PALBOX_V_OFFSET    ( 6 + VICFG_SCALESUB_OVERLAY_V_OFFSET)

#define MISC_OVERLAY_H_OFFSET         OVERLAY_H_OFFSET
#define MISC_OVERLAY_V_OFFSET         OVERLAY_V_OFFSET_WH
#define MISC_VALS_H_OFFSET            (27 + MISC_OVERLAY_H_OFFSET)
#define MISC_VALS_V_OFFSET            VICFG_OVERLAY_V_OFFSET
#define MISC_AUDIO_SWAP_LR_V_OFFSET   ( 1 + MISC_VALS_V_OFFSET)
#define MISC_AUDIO_AMP_V_OFFSET       ( 2 + MISC_VALS_V_OFFSET)
#define MISC_AUDIO_SPDIF_EN_V_OFFSET  ( 3 + MISC_VALS_V_OFFSET)
#define MISC_IGR_RESET_V_OFFSET       ( 5 + MISC_VALS_V_OFFSET)
#define MISC_IGR_DEBLUR_V_OFFSET      ( 6 + MISC_VALS_V_OFFSET)
#define MISC_IGR_16BITMODE_V_OFFSET   ( 7 + MISC_VALS_V_OFFSET)

#define RWDATA_OVERLAY_H_OFFSET       OVERLAY_H_OFFSET
#define RWDATA_OVERLAY_V_OFFSET       OVERLAY_V_OFFSET_WH
#define RWDATA_SAVE_FL_V_OFFSET       (1 + RWDATA_OVERLAY_V_OFFSET)
#define RWDATA_LOAD_FL_V_OFFSET       (3 + RWDATA_OVERLAY_V_OFFSET)
#define RWDATA_LOAD_N64_480P_V_OFFSET (4 + RWDATA_OVERLAY_V_OFFSET)
#define RWDATA_LOAD_N64_V_OFFSET      (5 + RWDATA_OVERLAY_V_OFFSET)


#define INFO_OVERLAY_H_OFFSET OVERLAY_H_OFFSET
#define INFO_OVERLAY_V_OFFSET OVERLAY_V_OFFSET_WH
#define INFO_VALS_H_OFFSET    (27 + INFO_OVERLAY_H_OFFSET)
#define INFO_VALS_V_OFFSET    INFO_OVERLAY_V_OFFSET

#define INFO_PPU_STATE_V_OFFSET (0 + INFO_VALS_V_OFFSET)
#define INFO_VIN_V_OFFSET       (2 + INFO_VALS_V_OFFSET)
#define INFO_VOUT_V_OFFSET      (3 + INFO_VALS_V_OFFSET)
#define INFO_LLM_V_OFFSET       (4 + INFO_VALS_V_OFFSET)
#define INFO_DEBLUR_V_OFFSET    (6 + INFO_VALS_V_OFFSET)
#define INFO_GAMMA_V_OFFSET     (7 + INFO_VALS_V_OFFSET)


#define MAIN_OVERLAY_H_OFFSET 2
#define MAIN_OVERLAY_V_OFFSET OVERLAY_V_OFFSET_WH

#define MAIN2VINFO_V_OFFSET   (0 + MAIN_OVERLAY_V_OFFSET)
#define MAIN2CFG_V_OFFSET     (1 + MAIN_OVERLAY_V_OFFSET)
#define MAIN2MISC_V_OFFSET    (2 + MAIN_OVERLAY_V_OFFSET)
#define MAIN2SAVE_V_OFFSET    (3 + MAIN_OVERLAY_V_OFFSET)
#define MAIN2ABOUT_V_OFFSET   (5 + MAIN_OVERLAY_V_OFFSET)
#define MAIN2THANKS_V_OFFSET  (6 + MAIN_OVERLAY_V_OFFSET)
#define MAIN2LICENSE_V_OFFSET (7 + MAIN_OVERLAY_V_OFFSET)


static const char *copyright_note __ufmdata_section__ =
    "2021 borti4938"; /* 14 chars */

const char *btn_overlay_0 =
    "A ... Enter\n"
    "B ... Close";

const char *btn_overlay_1 =
    "A ... Enter\n"
    "B ... Back";

const char *btn_overlay_2 =
    "A ... Confirm\n"
    "B ... Cancel";

static const char *vinfo_header __ufmdata_section__ =
    "Video-Info";
static const char *vinfo_overlay __ufmdata_section__ =
    "* PPU state value:\n"
    "* Video mode\n"
    "  - Input resolution:\n"
    "  - Output resolution:\n"
    "  - Low latency mode:\n"
    "* Filter Options\n"
    "  - LowRes. VI-DeBlur:\n"
    "  - Gamma boost exponent:";

static const char *vicfg1_header __ufmdata_section__ =
    "VI config. 1";
static const char *vicfg1_overlay __ufmdata_section__ =
    "* Output resolution:\n"
    "* Advanced picture settings\n"
    "  - De-Interlacing mode:\n"
    "  - Scanline emulation:\n"
    "  - Scaler options:\n"
    "  - V/H position/timing:\n\n"
    "* VI config page 2:";

static const char *vicfg2_header __ufmdata_section__ =
    "VI config. 2";
static const char *vicfg2_overlay __ufmdata_section__ =
    "* Gamma Value:\n"
    "* Limited RGB:\n"
    "* LowRes.-DeBlur:\n"
    "  - power-cycle default:\n"
    "* 16bit mode:\n"
    "  - power-cycle default:\n\n"
    "* VI config page 1:";

static const char *rescfg_opt_header __ufmdata_section__ =
    "Cfg. (Resolution)";
static const char *rescfg_opt_overlay __ufmdata_section__ =
    "* Input mode:\n"
    "* Output resolution:\n"
    "  - Use VGA instead of 480p:\n"
    "  - Low latency mode:\n"
    "  - Force 50Hz/60Hz:\n\n"
    "* Scaler options:";

static const char *slcfg_opt_header __ufmdata_section__ =
    "Config. (Scanlines)";
static const char *slcfg_opt_overlay __ufmdata_section__ =
    "* Input mode:\n\n"
    "* Use Scanlines:\n"
    "  - Method:\n"
    "  - Scanline ID:\n"
    "  - Scanline Strength:\n"
    "  - Hybrid Depth:";


static const char *vicfg_timing_opt_header __ufmdata_section__ =
    "Config. (Position)";
static const char *vicfg_timing_opt_overlay __ufmdata_section__ =
    "* Settings for:\n\n"
    "* Vertical shift:\n"
    "* Horizontal shift:";
static const char *vicfg_timing_opt_overlay1 __ufmdata_section__ =
    "* Reset values:";


static const char *vicfg_scaler_opt_header __ufmdata_section__ =
    "Config. (Scaler)";
static const char *vicfg_scaler_overlay __ufmdata_section__ =
    "* Settings for:\n"
    "* Scaler Mode:\n"
    "  - Interpolation type:\n"
    "  - Link h/v factors:\n"
    "  - Vertical scaling:\n"
    "  - Horizontal scaling:";
static const char *vicfg_scaler_overlay1 __ufmdata_section__ =
    "  - Use PAL in 240p box:";


static const char *misc_header __ufmdata_section__ =
    "Miscellaneous";
static const char *misc_overlay __ufmdata_section__ =
    "* Audio Settings:\n"
    "  - Swap L/R:\n"
    "  - Post filter gain:\n"
    "  - S/PDIF enabled:\n"
    "* In-Game Routines:\n"
    "  - Reset:\n"
    "  - VI-DeBlur:\n"
    "  - 16bit Mode:";

static const char *rwdata_header __ufmdata_section__ =
    "Load/Save";
static const char *rwdata_overlay __ufmdata_section__ =
    "Save:\n"
    " - Configuration\n"
    "Load:\n"
    " - Last Configuration\n"
    " - Defaults for 480p\n"
    " - N64 Standard";

static const char *thanks_header __ufmdata_section__ =
    "Acknowledgment";
static const char *thanks_overlay __ufmdata_section__ =
    "The N64 RGB project would not be what it is without\n"
    "the contributions of many other people. Here, I want\n"
    "to point out especially:\n"
    " - viletim  : First public DIY N64 RGB DAC project\n"
    " - Ikari_01 : Initial implementation of PAL/NTSC\n"
    "              as well as 480i/576i detection\n"
    " - marqs85:   Feedback and final concept for low\n"
    "              latency mode PLL configuration\n"
    " - ArcadeTV:  Logo design\n"
    "Visit the GitHub project:\n"
    "      <https://github.com/borti4938/n64rgb>\n"
    "Any contribution in any kind is highly welcomed!";
  /* 1234567890123456789012345678901234567890123456789012 */

static const char *about_header __ufmdata_section__ =
    "About";
static const char *about_overlay __ufmdata_section__ =
    "The N64 RGB project is open source, i.e. PCB files,\n"
    "HDL and SW sources are provided to you FOR FREE!\n\n"
    "Your version\n"
    " - PCB version:\n"
    " - FPGA Chip ID:\n"
    " - firmware (HDL):\n"
    " - firmware (SW) :\n\n"
    "Questions / (limited) Support:\n"
    " - GitHub: <https://github.com/borti4938/n64rgb>\n"
    " - Email:  <borti4938@gmail.com>";
  /* 1234567890123456789012345678901234567890123456789012 */

static const char *license_header __ufmdata_section__ =
    "License";
static const char *license_overlay __ufmdata_section__ =
    "The N64Advanced v2 is part of the\n"
    "N64 RGB/YPbPr Digital2Digital and DAC project\n"
    "       Copyright   2015 - 2021 Peter Bartmann\n"
    "This project is published under GNU GPL v3.0 or\n"
    "later. You should have received a copy of the GNU\n"
    "General Public License along with this project.\n"
    "If not, see\n"
    "        <http://www.gnu.org/licenses/>.\n\n"
    "What ever you do, also respect licenses of third\n"
    "party vendors providing the design tools...";
  /* 1234567890123456789012345678901234567890123456789012 */

static const char *home_header __ufmdata_section__ =
    "Main Menu";
static const char *home_overlay __ufmdata_section__ =
    "[Video-Info]\n"
    "[Configuration]\n"
    "[Miscellaneous]\n"
    "[Load/Save]\n\n"
    "About...\n"
    "Acknowledgment...\n"
    "License...";

const char *EnterSubMenu       = "[Enter submenu]";
const char *LoadTimingDefaults = "[Load defaults]";
const char *Global             = "Global";
const char *not_available      = "-----";

const char *OffOn[]         = {"Off","On"};
const char *NTSCPAL_SEL[]   = {"NTSC  ","PAL   ", "Current"};
const char *Force5060[]     = {"Off (N64 Auto)","60Hz","50Hz"};
const char *Resolutions[]   = {"480p/576p","720p","960p","1080p","1200p"};
const char *DeInterModes[]  = {"Bob","Weave","Fully Buffered"};
const char *InterpModes[]   = {"Integer","Bilinear (sharp)","Bilinear (soft)"};
const char *VTimingSel[]    = {"Current","NTSC Progressive","NTSC Interlaced","PAL Progressive","PAL Interlaced"};
const char *EvenOdd[]       = {"Even","Odd "};
const char *AdvSL[]         = {"Simple","Mean"};
const char *LinkSL[]        = {"Off","Individual","Linked to progressive"};
const char *VideoMode[]     = {"240p","480i","288p","576i"};
const char *VRefresh[]      = {"@ 60Hz","@ 50Hz"};
const char *VideoColor[]    = {"21bit","16bit"};

const char *ResolutionVGA     = "VGA (640x480)";
const char *Resolution480p    = "480p";
const char *Resolution576p    = "576p";
const char *text_480i_576i_br = "(480i/576i)";

const char *pcb_rev[] __ufmdata_section__ = {"N64Adv2_20210521"};

#endif /* MENU_TEXT_TEXTDEFS_P_H_ */
