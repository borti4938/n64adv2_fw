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
 * config.h
 *
 *  Created on: 11.01.2018
 *      Author: Peter Bartmann
 *
 ********************************************************************************/

#include <string.h>
#include "alt_types.h"
#include "altera_avalon_pio_regs.h"
#include "system.h"


#ifndef CONFIG_H_
#define CONFIG_H_

typedef enum {
  MISC = 0,
  VIDEO,
  LINEX,
} cfg_word_type_t;

#define NUM_CFG_B32WORDS    3

typedef enum {
  NTSC = 0,
  PAL
} vmode_t;
#define LINEX_TYPES 2

typedef enum {
  PROGRESSIVE = 0,
  INTERLACED
} scanmode_t;


typedef enum {
  PPU_NTSC = 0,
  PPU_PAL,
  PPU_RES_CURRENT
} cfg_res_model_sel_type_t;
#define NUM_RES_MODES  2

typedef enum {
  PPU_TIMING_CURRENT = 0,
  NTSC_PROGRESSIVE,
  NTSC_INTERLACED,
  PAL_PROGRESSIVE,
  PAL_INTERLACED
} cfg_timing_model_sel_type_t;
#define NUM_TIMING_MODES  4

typedef enum {
  PPU_SCALING_CURRENT = 0,
  NTSC_TO_480,
  NTSC_TO_720,
  NTSC_TO_960,
  NTSC_TO_1080,
  NTSC_TO_1200,
  PAL_TO_576,
  PAL_TO_720,
  PAL_TO_960,
  PAL_TO_1080,
  PAL_TO_1200
} cfg_scaler_in2out_sel_type_t;
#define NUM_SCALING_MODES  10

typedef enum {
  PAL_PAT0 = 0,
  PAL_PAT1
} cfg_pal_pattern_t;


typedef enum {
  OFF = 0,
  ON
} cfg_offon_t;

typedef struct {
  const alt_u32 cfg_word_mask;
  alt_u32       cfg_word_val;
  alt_u32       cfg_ref_word_val;
} cfg_b32word_t;

typedef struct {
	cfg_b32word_t* cfg_word_def[NUM_CFG_B32WORDS];
} configuration_t;

typedef enum {
  FLAG,
  FLAGTXT,
  TXTVALUE,
  NUMVALUE
} config_type_t;

typedef struct {
  const alt_u32 setflag_mask;
  const alt_u32 clrflag_mask;
} config_flag_t;

typedef struct {
  const alt_u32 getvalue_mask;
  const alt_u8 max_value;
} config_value_t;

typedef void (*val2char_func_call)(alt_u8);

typedef struct {
  cfg_b32word_t       *cfg_word;
  union {
    alt_u8              cfg_word_offset;
    alt_u8              cfg_value;
  };
  const config_type_t cfg_type;
  union {
    const config_flag_t  flag_masks;
    const config_value_t value_details;
  };
  union {
    const char*        *value_string;
    val2char_func_call val2char_func;
  };
} config_t;

typedef struct {
  alt_u32 config_val;
  alt_u32 config_ref_val;
} config_tray_t;

typedef struct {
  alt_u16 config_val;
  alt_u16 config_ref_val;
} config_tray_u16_t;

#define VPLL_TEST_FAILED       10
#define CFG_VERSION_INVALID   100
#define CFG_FLASH_NOT_USED    101
#define CFG_FLASH_SAVE_ABORT  102
#define CFG_FLASH_LOAD_ABORT  CFG_FLASH_SAVE_ABORT
#define CFG_N64DEF_LOAD_ABORT CFG_FLASH_SAVE_ABORT
#define CFG_DEF_LOAD_ABORT    CFG_FLASH_SAVE_ABORT

// the overall masks
#define CFG_MISC_GETALL_MASK      0x007F0F7F
#define CFG_VIDEO_GETALL_MASK     0xFFFFF81F
#define CFG_LINEX_GETALL_MASK     0xFFFFFE07

// misc (set 2)
#define CFG_MISC_OUT_BASE   CFG_SET2_OUT_BASE

#define CFG_AUDIO_AMP_OFFSET      18
#define CFG_AUDIO_SWAP_LR_OFFSET  17
#define CFG_AUDIO_SPDIF_EN_OFFSET 16
#define CFG_SHOWLOGO_OFFSET       11
#define CFG_SHOWOSD_OFFSET        10
#define CFG_MUTEOSDTMP_OFFSET      9
#define CFG_IGRRST_OFFSET          8
#define CFG_GAMMA_OFFSET           3
#define CFG_LIMITED_RGB_OFFSET     2
#define CFG_DEBLUR_MODE_OFFSET     1
#define CFG_16BITMODE_OFFSET       0

#define CFG_AUDIO_AMP_GETMASK         (0x1F<<CFG_AUDIO_AMP_OFFSET)
  #define CFG_AUDIO_AMP_RSTMASK         (CFG_MISC_GETALL_MASK & ~CFG_AUDIO_AMP_GETMASK)
  #define CFG_AUDIO_AMP_CLRMASK         (CFG_MISC_GETALL_MASK & ~CFG_AUDIO_AMP_GETMASK)
#define CFG_AUDIO_SWAP_LR_GETMASK   (1<<CFG_AUDIO_SWAP_LR_OFFSET)
  #define CFG_AUDIO_SWAP_LR_SETMASK   (1<<CFG_AUDIO_SWAP_LR_OFFSET)
  #define CFG_AUDIO_SWAP_LR_CLRMASK   (CFG_MISC_GETALL_MASK & ~CFG_AUDIO_SWAP_LR_SETMASK)
#define CFG_AUDIO_SPDIF_EN_GETMASK  (1<<CFG_AUDIO_SPDIF_EN_OFFSET)
  #define CFG_AUDIO_SPDIF_EN_SETMASK  (1<<CFG_AUDIO_SPDIF_EN_OFFSET)
  #define CFG_AUDIO_SPDIF_EN_CLRMASK  (CFG_MISC_GETALL_MASK & ~CFG_AUDIO_SPDIF_EN_SETMASK)
#define CFG_SHOWLOGO_GETMASK        (1<<CFG_SHOWLOGO_OFFSET)
  #define CFG_SHOWLOGO_SETMASK        (1<<CFG_SHOWLOGO_OFFSET)
  #define CFG_SHOWLOGO_CLRMASK        (CFG_MISC_GETALL_MASK & ~CFG_SHOWLOGO_SETMASK)
#define CFG_SHOWOSD_GETMASK         (1<<CFG_SHOWOSD_OFFSET)
  #define CFG_SHOWOSD_SETMASK         (1<<CFG_SHOWOSD_OFFSET)
  #define CFG_SHOWOSD_CLRMASK         (CFG_MISC_GETALL_MASK & ~CFG_SHOWOSD_SETMASK)
#define CFG_MUTEOSDTMP_GETMASK      (1<<CFG_MUTEOSDTMP_OFFSET)
  #define CFG_MUTEOSDTMP_SETMASK      (1<<CFG_MUTEOSDTMP_OFFSET)
  #define CFG_MUTEOSDTMP_CLRMASK      (CFG_MISC_GETALL_MASK & ~CFG_MUTEOSDTMP_SETMASK)
#define CFG_IGRRST_GETMASK          (1<<CFG_IGRRST_OFFSET)
  #define CFG_IGRRST_SETMASK          (1<<CFG_IGRRST_OFFSET)
  #define CFG_IGRRST_CLRMASK          (CFG_MISC_GETALL_MASK & ~CFG_IGRRST_SETMASK)
#define CFG_GAMMA_GETMASK             (0xF<<CFG_GAMMA_OFFSET)
  #define CFG_GAMMASEL_RSTMASK          (CFG_MISC_GETALL_MASK & ~CFG_GAMMA_GETMASK)
  #define CFG_GAMMA_CLRMASK             (CFG_MISC_GETALL_MASK & ~CFG_GAMMA_GETMASK)
#define CFG_LIMITED_RGB_GETMASK     (1<<CFG_LIMITED_RGB_OFFSET)
  #define CFG_LIMITED_RGB_SETMASK     (1<<CFG_LIMITED_RGB_OFFSET)
  #define CFG_LIMITED_RGB_CLRMASK     (CFG_MISC_GETALL_MASK & ~CFG_LIMITED_RGB_SETMASK)
#define CFG_DEBLUR_MODE_GETMASK       (1<<CFG_DEBLUR_MODE_OFFSET)
  #define CFG_DEBLUR_MODE_SETMASK       (1<<CFG_DEBLUR_MODE_OFFSET)
  #define CFG_DEBLUR_MODE_CLRMASK       (CFG_MISC_GETALL_MASK & ~CFG_DEBLUR_MODE_GETMASK)
#define CFG_16BITMODE_GETMASK         (1<<CFG_16BITMODE_OFFSET)
  #define CFG_16BITMODE_SETMASK         (1<<CFG_16BITMODE_OFFSET)
  #define CFG_16BITMODE_CLRMASK         (CFG_MISC_GETALL_MASK & ~CFG_16BITMODE_SETMASK)


// video (set 1)
#define CFG_VIDEO_OUT_BASE  CFG_SET1_OUT_BASE

#define CFG_HORSHIFT_OFFSET       27
#define CFG_VERTSHIFT_OFFSET      22
#define CFG_LINK_HVSCALE_OFFSET   21
#define CFG_HORSCALE_OFFSET       16
#define CFG_VERTSCALE_OFFSET      11
#define CFG_DEINTER_MODE_OFFSET    3
#define CFG_INTERP_MODE_OFFSET     1
#define CFG_PAL_BOXED_MODE_OFFSET  0


#define CFG_HORSHIFT_GETMASK          (0x1F<<CFG_HORSHIFT_OFFSET)
  #define CFG_HORSHIFT_RSTMASK          (CFG_VIDEO_GETALL_MASK & ~CFG_HORSHIFT_GETMASK)
  #define CFG_HORSHIFT_CLRMASK          (CFG_VIDEO_GETALL_MASK & ~CFG_HORSHIFT_GETMASK)
#define CFG_VERTSHIFT_GETMASK         (0x1F<<CFG_VERTSHIFT_OFFSET)
  #define CFG_VERTSHIFT_RSTMASK         (CFG_VIDEO_GETALL_MASK & ~CFG_VERTSHIFT_GETMASK)
  #define CFG_VERTSHIFT_CLRMASK         (CFG_VIDEO_GETALL_MASK & ~CFG_VERTSHIFT_GETMASK)
#define CFG_LINK_HVSCALE_GETMASK      (1<<CFG_LINK_HVSCALE_OFFSET)
  #define CFG_LINK_HVSCALE_SETMASK      (1<<CFG_LINK_HVSCALE_OFFSET)
  #define CFG_LINK_HVSCALE_CLRMASK      (CFG_VIDEO_GETALL_MASK & ~CFG_LINK_HVSCALE_OFFSET)
#define CFG_HORSCALE_GETMASK          (0x1F<<CFG_HORSCALE_OFFSET)
  #define CFG_HORSCALE_RSTMASK          (CFG_VIDEO_GETALL_MASK & ~CFG_HORSCALE_GETMASK)
  #define CFG_HORSCALE_CLRMASK          (CFG_VIDEO_GETALL_MASK & ~CFG_HORSCALE_GETMASK)
#define CFG_VERTSCALE_GETMASK         (0x1F<<CFG_VERTSCALE_OFFSET)
  #define CFG_VERTSCALE_RSTMASK         (CFG_VIDEO_GETALL_MASK & ~CFG_VERTSCALE_GETMASK)
  #define CFG_VERTSCALE_CLRMASK         (CFG_VIDEO_GETALL_MASK & ~CFG_VERTSCALE_GETMASK)
#define CFG_DEINTER_MODE_GETMASK      (0x3<<CFG_DEINTER_MODE_OFFSET)
  #define CFG_DEINTER_MODE_RSTMASK      (CFG_VIDEO_GETALL_MASK & ~CFG_DEINTER_MODE_GETMASK)
  #define CFG_DEINTER_MODE_CLRMASK      (CFG_VIDEO_GETALL_MASK & ~CFG_DEINTER_MODE_GETMASK)
#define CFG_INTERP_MODE_GETMASK       (0x3<<CFG_INTERP_MODE_OFFSET)
  #define CFG_INTERP_MODE_RSTMASK       (CFG_VIDEO_GETALL_MASK & ~CFG_INTERP_MODE_GETMASK)
  #define CFG_INTERP_MODE_CLRMASK       (CFG_VIDEO_GETALL_MASK & ~CFG_INTERP_MODE_GETMASK)
#define CFG_PAL_BOXED_MODE_GETMASK    (1<<CFG_PAL_BOXED_MODE_OFFSET)
  #define CFG_PAL_BOXED_MODE_SETMASK    (1<<CFG_PAL_BOXED_MODE_OFFSET)
  #define CFG_PAL_BOXED_MODE_CLRMASK    (CFG_VIDEO_GETALL_MASK & ~CFG_PAL_BOXED_MODE_SETMASK)

#define CFG_VIDEO_GETTIMINGS_MASK     (CFG_HORSHIFT_GETMASK | CFG_VERTSHIFT_GETMASK)
#define CFG_VIDEO_GETNONTIMINGS_MASK  (CFG_VIDEO_GETALL_MASK & ~CFG_VIDEO_GETTIMINGS_MASK)
#define CFG_VIDEO_GETSCALING_MASK     (CFG_LINK_HVSCALE_GETMASK | CFG_HORSCALE_GETMASK | CFG_VERTSCALE_GETMASK)
#define CFG_VIDEO_GETNONSCALING_MASK  (CFG_VIDEO_GETALL_MASK & ~CFG_VIDEO_GETSCALING_MASK)


// image for 240p and 480i (set 0)
#define CFG_LINEX_OUT_BASE  CFG_SET0_OUT_BASE

#define CFG_FORCE_5060_OFFSET       30
  #define CFG_FORCE_5060MSB_OFFSET    31
  #define CFG_FORCE_5060LSB_OFFSET    30
#define CFG_VGAFOR480P_OFFSET       29
#define CFG_LOWLATENCYMODE_OFFSET   28
#define CFG_RESOLUTION_OFFSET       25
  #define CFG_RESOLUTIONMSB_OFFSET    27
  #define CFG_RESOLUTIONLSB_OFFSET    25
#define CFG_240P_SLHYBDEP_OFFSET    20
  #define CFG_240P_SLHYBDEPMSB_OFFSET 24
  #define CFG_240P_SLHYBDEPLSB_OFFSET 20
#define CFG_240P_SLSTR_OFFSET       16
  #define CFG_240P_SLSTRMSB_OFFSET    19
  #define CFG_240P_SLSTRLSB_OFFSET    16
#define CFG_240P_SL_METHOD_OFFSET   15
#define CFG_240P_SL_ID_OFFSET       14
#define CFG_240P_SL_EN_OFFSET       13
#define CFG_480I_SLHYBDEP_OFFSET     8
  #define CFG_480I_SLHYBDEPMSB_OFFSET 12
  #define CFG_480I_SLHYBDEPLSB_OFFSET  8
#define CFG_480I_SLSTR_OFFSET        4
  #define CFG_480I_SLSTRMSB_OFFSET     7
  #define CFG_480I_SLSTRLSB_OFFSET     4
#define CFG_480I_SL_METHOD_OFFSET    3
#define CFG_480I_SL_ID_OFFSET        2
#define CFG_480I_SL_EN_OFFSET        0


#define CFG_FORCE_5060_GETMASK        (3<<CFG_FORCE_5060_OFFSET)
  #define CFG_FORCE_50_SETMASK          (2<<CFG_FORCE_5060_OFFSET)
  #define CFG_FORCE_60_SETMASK          (1<<CFG_FORCE_5060_OFFSET)
  #define CFG_FORCE_AUTO_SETMASK        (0<<CFG_FORCE_5060_OFFSET)
  #define CFG_FORCE_5060_RSTMASK        (CFG_LINEX_GETALL_MASK & ~CFG_FORCE_5060_GETMASK)
#define CFG_VGAFOR480P_GETMASK        (3<<CFG_VGAFOR480P_OFFSET)
  #define CFG_VGAFOR480P_SETMASK        (1<<CFG_VGAFOR480P_OFFSET)
  #define CFG_VGAFOR480P_CLRMASK        (CFG_LINEX_GETALL_MASK & ~CFG_VGAFOR480P_GETMASK)
#define CFG_LOWLATENCYMODE_GETMASK    (1<<CFG_LOWLATENCYMODE_OFFSET)
  #define CFG_LOWLATENCYMODE_SETMASK    (1<<CFG_LOWLATENCYMODE_OFFSET)
  #define CFG_LOWLATENCYMODE_CLRMASK    (CFG_LINEX_GETALL_MASK & ~CFG_LOWLATENCYMODE_GETMASK)
#define CFG_RESOLUTION_GETMASK        (0x7<<CFG_RESOLUTION_OFFSET)
  #define CFG_RESOLUTION_FHD_SETMASK    (2<<CFG_RESOLUTION_OFFSET)
  #define CFG_RESOLUTION_HDR_SETMASK    (1<<CFG_RESOLUTION_OFFSET)
  #define CFG_RESOLUTION_ED_SETMASK     (0<<CFG_RESOLUTION_OFFSET)
  #define CFG_RESOLUTION_RSTMASK        (CFG_LINEX_GETALL_MASK & ~CFG_RESOLUTION_GETMASK)
#define CFG_240P_SLHYBDEP_GETMASK     (0x1F<<CFG_240P_SLHYBDEP_OFFSET)
  #define CFG_240P_SLHYBDEP_RSTMASK     (CFG_LINEX_GETALL_MASK & ~CFG_240P_SLHYBDEP_GETMASK)
  #define CFG_240P_SLHYBDEP_CLRMASK     (CFG_LINEX_GETALL_MASK & ~CFG_240P_SLHYBDEP_GETMASK)
#define CFG_240P_SLSTR_GETMASK        (0xF<<CFG_240P_SLSTR_OFFSET)
  #define CFG_240P_SLSTR_RSTMASK        (CFG_LINEX_GETALL_MASK & ~CFG_240P_SLSTR_GETMASK)
#define CFG_240P_SLSTR_CLRMASK        (CFG_LINEX_GETALL_MASK & ~CFG_240P_SLSTR_GETMASK)
#define CFG_240P_SL_METHOD_GETMASK    (1<<CFG_240P_SL_METHOD_OFFSET)
  #define CFG_240P_SL_METHOD_SETMASK    (1<<CFG_240P_SL_METHOD_OFFSET)
  #define CFG_240P_SL_METHOD_CLRMASK    (CFG_LINEX_GETALL_MASK & ~CFG_240P_SL_METHOD_SETMASK)
#define CFG_240P_SL_ID_GETMASK        (1<<CFG_240P_SL_ID_OFFSET)
  #define CFG_240P_SL_ID_SETMASK        (1<<CFG_240P_SL_ID_OFFSET)
  #define CFG_240P_SL_ID_CLRMASK        (CFG_LINEX_GETALL_MASK & ~CFG_240P_SL_ID_SETMASK)
#define CFG_240P_SL_EN_GETMASK        (1<<CFG_240P_SL_EN_OFFSET)
  #define CFG_240P_SL_EN_SETMASK        (1<<CFG_240P_SL_EN_OFFSET)
  #define CFG_240P_SL_EN_CLRMASK        (CFG_LINEX_GETALL_MASK & ~CFG_240P_SL_EN_SETMASK)
#define CFG_480I_SLHYBDEP_GETMASK     (0x1F<<CFG_480I_SLHYBDEP_OFFSET)
  #define CFG_480I_SLHYBDEP_RSTMASK     (CFG_LINEX_GETALL_MASK & ~CFG_480I_SLHYBDEP_GETMASK)
  #define CFG_480I_SLHYBDEP_CLRMASK     (CFG_LINEX_GETALL_MASK & ~CFG_480I_SLHYBDEP_GETMASK)
#define CFG_480I_SLSTR_GETMASK        (0xF<<CFG_480I_SLSTR_OFFSET)
  #define CFG_480I_SLSTR_RSTMASK        (CFG_LINEX_GETALL_MASK & ~CFG_480I_SLSTR_GETMASK)
  #define CFG_480I_SLSTR_CLRMASK        (CFG_LINEX_GETALL_MASK & ~CFG_480I_SLSTR_GETMASK)
#define CFG_480I_SL_METHOD_GETMASK    (1<<CFG_480I_SL_METHOD_OFFSET)
  #define CFG_480I_SL_METHOD_SETMASK    (1<<CFG_480I_SL_METHOD_OFFSET)
  #define CFG_480I_SL_METHOD_CLRMASK    (CFG_LINEX_GETALL_MASK & ~CFG_480I_SL_METHOD_SETMASK)
#define CFG_480I_SL_ID_GETMASK        (1<<CFG_480I_SL_ID_OFFSET)
  #define CFG_480I_SL_ID_SETMASK        (1<<CFG_480I_SL_ID_OFFSET)
  #define CFG_480I_SL_ID_CLRMASK        (CFG_LINEX_GETALL_MASK & ~CFG_480I_SL_ID_SETMASK)
#define CFG_480I_SL_EN_GETMASK        (3<<CFG_480I_SL_EN_OFFSET)
  #define CFG_480I_SL_EN_RSTMASK         (CFG_LINEX_GETALL_MASK & ~CFG_480I_SL_EN_GETMASK)
  #define CFG_480I_SL_EN_CLRMASK         (CFG_LINEX_GETALL_MASK & ~CFG_480I_SL_EN_GETMASK)


// some max values
#define CFG_AUDIO_AMP_MAX_VALUE    31
#define CFG_GAMMA_MAX_VALUE         8
#define CFG_HORSHIFT_MAX_VALUE     31
#define CFG_VERTSHIFT_MAX_VALUE    31
#define CFG_HORSCALE_MAX_VALUE     20
#define CFG_VERTSCALE_MAX_VALUE    16
#define CFG_DEINTER_MODE_MAX_VALUE  2
#define CFG_INTERP_MODE_MAX_VALUE   2
#define CFG_FORCE5060_MAX_VALUE     2
#define CFG_RESOLUTION_MAX_VALUE    4
#define CFG_SLSTR_MAX_VALUE        15
#define CFG_SLHYBDEP_MAX_VALUE     24
#define CFG_480I_SL_EN_MAX_VALUE    2


// some default values other than 0 (go into default value of config)
// these are N64 defaults
#define CFG_AUDIO_AMP_DEFAULTVAL              19
  #define CFG_AUDIO_AMP_DEFAULT_SETMASK         (CFG_AUDIO_AMP_DEFAULTVAL << CFG_AUDIO_AMP_OFFSET)
#define CFG_GAMMA_DEFAULTVAL                   5
  #define CFG_GAMMA_DEFAULT_SETMASK             (CFG_GAMMA_DEFAULTVAL << CFG_GAMMA_OFFSET)

#define CFG_MISC_DEFAULT          (CFG_AUDIO_AMP_DEFAULT_SETMASK | CFG_GAMMA_DEFAULT_SETMASK)
  #define CFG_MISC_GET_NODEFAULTS   (CFG_SHOWLOGO_GETMASK | CFG_SHOWOSD_GETMASK)
#define CFG_VIDEO_DEFAULT         0x00000000
  #define CFG_VIDEO_GET_NODEFAULTS  (CFG_VIDEO_GETTIMINGS_MASK)
#define CFG_LINEX_DEFAULT         0x00000000
  #define CFG_LINEX_GET_NODEFAULTS  0x00000000

#define CFG_TIMING_DEFAULTS           (1 << 9 | 1 << 4)
#define CFG_SCALING_NTSC_480_DEFAULT  0x0000
#define CFG_SCALING_NTSC_720_DEFAULT  0x0084
#define CFG_SCALING_NTSC_960_DEFAULT  0x0108
#define CFG_SCALING_NTSC_1080_DEFAULT 0x014A
#define CFG_SCALING_NTSC_1200_DEFAULT 0x018C
#define CFG_SCALING_PAL_576_DEFAULT   0x0000
#define CFG_SCALING_PAL_720_DEFAULT   0x0082
#define CFG_SCALING_PAL_960_DEFAULT   0x0106
#define CFG_SCALING_PAL_1080_DEFAULT  0x0147
#define CFG_SCALING_PAL_1200_DEFAULT  0x0189


#define RWM_H_OFFSET 5
#define RWM_V_OFFSET (VD_TXT_HEIGHT - 3)
#define RWM_LENGTH   10
#define RWM_SHOW_CNT 256


extern configuration_t sysconfig;

extern config_t audio_amp, audio_swap_lr, audio_spdif_en;
extern config_t res_selection, scanline_selection, timing_selection, scaling_selection;
extern config_t deblur_mode_powercycle, mode16bit_powercycle;
extern config_t show_logo, show_osd, mute_osd_tmp,
                igr_reset, igr_deblur, igr_16bitmode, pal_awareness;
extern config_t gamma_lut, limited_rgb, deblur_mode, mode16bit,
                hor_shift, vert_shift, link_hv_scale, hor_scale, vert_scale,
                deinterlace_mode, pal_boxed_mode, interpolation_mode;
extern config_t linex_force_5060, vga_for_480p, low_latency_mode, linex_resolution;
extern config_t slhyb_str, sl_str, sl_method, sl_id, sl_en;
extern config_t slhyb_str_480i, sl_str_480i, sl_method_480i, sl_id_480i, sl_en_480i;


static inline alt_u8 is_local_cfg(config_t* cfg_data)
  { return cfg_data->cfg_word == NULL;  }

void cfg_toggle_flag(config_t* cfg_data);
void cfg_set_flag(config_t* cfg_data);
void cfg_clear_flag(config_t* cfg_data);
void cfg_inc_value(config_t* cfg_data);
void cfg_dec_value(config_t* cfg_data);
alt_u8 cfg_get_value(config_t* cfg_data,alt_u8 get_reference);
void cfg_set_value(config_t* cfg_data, alt_u8 value);
int cfg_save_to_flash(alt_u8 need_confirm);
int cfg_load_from_flash(alt_u8 need_confirm);
int cfg_reset_timing(void);
int cfg_load_defaults(alt_u8 video480p,alt_u8 need_confirm);
void cfg_store_linex_word(vmode_t palmode_select);
void cfg_load_linex_word(vmode_t palmode_select);
void cfg_store_timing_word(cfg_timing_model_sel_type_t timing_select);
void cfg_load_timing_word(cfg_timing_model_sel_type_t timing_select);
void cfg_store_scaling_word(cfg_scaler_in2out_sel_type_t scaling_word_select);
void cfg_load_scaling_word(cfg_scaler_in2out_sel_type_t scaling_word_select);
void cfg_apply_to_logic(void);
void cfg_read_from_logic(void);
void cfg_clear_words(void);
void cfg_update_reference(void);

#endif /* CONFIG_H_ */
