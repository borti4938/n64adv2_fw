/*********************************************************************************
 *
 * This file is part of the N64 RGB/YPbPr DAC project.
 *
 * Copyright (C) 2015-2024 by Peter Bartmann <borti4938@gmail.com>
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
 * flash.c
 *
 *  Created on: 31.01.2018
 *      Author: Peter Bartmann
 *
 *********************************************************************************
 *
 * This file is inspired by the Open Source Scan Converter project (file flash.c)
 * which is
 *
 * Copyright (C) 2015-2016  Markus Hiienkari <mhiienka@niksula.hut.fi>
 *
 * The OSSC project is published under the GPL license version 3 at GitHub
 * <https://github.com/marqs85/ossc>
 *
 ********************************************************************************/

#include <unistd.h>
#include "system.h"
#include "sys/alt_sys_init.h"
#include "altera_onchip_flash.h"
#include "altera_onchip_flash_regs.h"
#include "flash.h"

ALTERA_ONCHIP_FLASH_DATA_CSR_INSTANCE ( ONCHIP_FLASH_0, ONCHIP_FLASH_0_DATA, ONCHIP_FLASH_0_CSR, onchip_flash_0);
alt_onchip_flash_dev* ufm_dev = &onchip_flash_0;

int init_flash()
{
  altera_onchip_flash_init(ufm_dev);

  if ((ufm_dev == NULL) || !(!ufm_dev->is_read_only && (ufm_dev->page_size == PAGESIZE)))
    return -FLASH_DETECT_ERROR;

  return 0;
}

int read_flash(alt_u32 offset, alt_u32 length, alt_u8 *dstbuf)
{
  int retval, i;

  retval = alt_onchip_flash_read(&ufm_dev->dev, offset, dstbuf, length);
  if (retval != 0) return -FLASH_READ_ERROR;

  for (i=0; i<length; i++)
    dstbuf[i] = ALT_CI_NIOS_CUSTOM_INSTR_BITSWAP_0(dstbuf[i]) >> 24;

  return 0;
}

int write_flash(alt_u32 offset, alt_u32 length, alt_u8 *pagedata)
{
  int retval, i;

  // Bit-reverse bytes for flash
  for (i=0; i<length; i++)
    pagedata[i] = ALT_CI_NIOS_CUSTOM_INSTR_BITSWAP_0(pagedata[i]) >> 24;

  retval = alt_onchip_flash_write(&ufm_dev->dev, offset, pagedata, length);

  if (retval != 0) return -FLASH_WRITE_ERROR;

  return 0;
}

int write_flash_page(alt_u8 *pagedata, alt_u32 length, alt_u32 pagenum)
{
  int retval, i;

  if ((pagenum % PAGES_PER_SECTOR) == 0) {
    retval = alt_onchip_flash_erase_block(&ufm_dev->dev, pagenum*PAGESIZE);
    if (retval != 0) return -FLASH_ERASE_ERROR;
  }

  // Bit-reverse bytes for flash
  for (i=0; i<length; i++)
    pagedata[i] = ALT_CI_NIOS_CUSTOM_INSTR_BITSWAP_0(pagedata[i]) >> 24;

  retval = alt_onchip_flash_write_block(&ufm_dev->dev, (pagenum/PAGES_PER_SECTOR)*PAGES_PER_SECTOR*PAGESIZE, pagenum*PAGESIZE, pagedata, length);

  if (retval != 0) return -FLASH_WRITE_PAGE_ERROR;

  return 0;
}
