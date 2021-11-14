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
 * led.c
 *
 *  Created on: 01.01.2019
 *      Author: Peter Bartmann
 *
 ********************************************************************************/

#include <string.h>
#include <stddef.h>
#include <unistd.h>
#include "led.h"
#include "alt_types.h"
#include "altera_avalon_pio_regs.h"
#include "system.h"


void led_drive(led_idx_t led_idx, led_state_t led_state) {
  if (led_state == LED_OFF) IOWR_ALTERA_AVALON_PIO_DATA(LED_OUT_BASE,IORD_ALTERA_AVALON_PIO_DATA(LED_OUT_BASE) & ~(1<<led_idx));
  else                      IOWR_ALTERA_AVALON_PIO_DATA(LED_OUT_BASE,IORD_ALTERA_AVALON_PIO_DATA(LED_OUT_BASE) |  (1<<led_idx));
}
