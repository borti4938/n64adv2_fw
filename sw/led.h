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
 * led.h
 *
 *  Created on: 01.01.2019
 *      Author: Peter Bartmann
 *
 ********************************************************************************/

#include "alt_types.h"
#include "altera_avalon_pio_regs.h"
#include "system.h"


#ifndef LED_H_
#define LED_H_


typedef enum {
  LED_NOK = 0,
  LED_OK
} led_idx_t;

typedef enum {
  LED_OFF = 0,
  LED_ON
} led_state_t;

void clear_led_timeout(led_idx_t led_idx);
void dec_led_timeout(led_idx_t led_idx);
alt_u8 get_led_timout(led_idx_t led_idx);
void led_drive(led_idx_t led_idx, led_state_t led_state);


#endif /* LED_H_ */
