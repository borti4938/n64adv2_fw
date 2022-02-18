/*********************************************************************************
 *
 * This file is part of the N64 RGB/YPbPr DAC project.
 *
 * Copyright (C) 2015-2022 by Peter Bartmann <borti4938@gmail.com>
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
 * app_cfg.h
 *
 *  Created on: 19.12.2021
 *      Author: Peter Bartmann
 *
 ********************************************************************************/

#ifndef APP_CFG_H_
#define APP_CFG_H_

#define SW_FW_MAIN  2
#define SW_FW_SUB   8

#define CFG_FW_MAIN SW_FW_MAIN
#define CFG_FW_SUB  01

#ifndef DEBUG
  #define db_printf(...)
  #define __ufmdata_section__ __attribute__((section(".ufm_data_rom")))
#else
  #define db_printf(...) printf(__VA_ARGS__)
  #define __ufmdata_section__
#endif


#endif /* APP_CFG_H_ */
