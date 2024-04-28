//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the N64 RGB/YPbPr DAC project.
//
// Copyright (C) 2015-2024 by Peter Bartmann <borti4938@gmail.com>
//
// N64 RGB/YPbPr DAC is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
//////////////////////////////////////////////////////////////////////////////////
//
// Company: Circuit-Board.de
// Engineer: borti4938
//
// VH-file Name:   videotimings.vh
// Project Name:   N64 Advanced Mod
// Target Devices: several devices
// Tool versions:  Altera Quartus Prime
// Description:
//
//////////////////////////////////////////////////////////////////////////////////


`ifndef _videotimings_vh_
`define _videotimings_vh_

  `define VID_CFG_W         5
  `define VID_CFG_50HZ_BIT  `VID_CFG_W - 1
  
  `define HOVERSCAN_MAX 7
  `define VOVERSCAN_MAX 3
  
  // 240p-60, 4:3 (2x/4x pixelrep, mode 2)
  `define USE_240p60            5'b00000
  `define HSYNC_active_240p60   1'b1
  `define HFRONTPORCH_240p60    19
  `define HSYNCLEN_240p60       96
  `define HBACKPORCH_240p60     45
  `define HACTIVE_240p60        640
  `define HTOTAL_240p60         800
  `define VSYNC_active_240p60   1'b1
  `define VFRONTPORCH_240p60    5
  `define VSYNCLEN_240p60       3
  `define VBACKPORCH_240p60     15
  `define VACTIVE_240p60        240
  `define VTOTAL_240p60         263

  // VGA-60 (640x480), 4:3
  `define USE_VGAp60            5'b00001
  `define HSYNC_active_VGAp60   1'b0
  `define HFRONTPORCH_VGAp60    16
  `define HSYNCLEN_VGAp60       96
  `define HBACKPORCH_VGAp60     48
  `define HACTIVE_VGAp60        640
  `define HTOTAL_VGAp60         800
  `define VSYNC_active_VGAp60   1'b0
  `define VFRONTPORCH_VGAp60    10
  `define VSYNCLEN_VGAp60       2
  `define VBACKPORCH_VGAp60     33
  `define VACTIVE_VGAp60        480
  `define VTOTAL_VGAp60         525
  
  // 480p-60, 4:3 / 16:9
  `define USE_480p60            5'b00010
  `define HSYNC_active_480p60   1'b0
  `define HFRONTPORCH_480p60    16
  `define HSYNCLEN_480p60       62
  `define HBACKPORCH_480p60     60
  `define HACTIVE_480p60        720
  `define HTOTAL_480p60         858
  `define VSYNC_active_480p60   1'b0
  `define VFRONTPORCH_480p60    9
  `define VSYNCLEN_480p60       6
  `define VBACKPORCH_480p60     30
  `define VACTIVE_480p60        480
  `define VTOTAL_480p60         525
  
  // 720p-60, 16:9
  `define USE_720p60            5'b00011
  `define HSYNC_active_720p60   1'b1
  `define HFRONTPORCH_720p60    110
  `define HSYNCLEN_720p60       40
  `define HBACKPORCH_720p60     220
  `define HACTIVE_720p60        1280
  `define HTOTAL_720p60         1650
  `define VSYNC_active_720p60   1'b1
  `define VFRONTPORCH_720p60    5
  `define VSYNCLEN_720p60       5
  `define VBACKPORCH_720p60     20
  `define VACTIVE_720p60        720
  `define VTOTAL_720p60         750
  
  // 960p-60, 4:3
  `define USE_960p60            5'b00100
  `define HSYNC_active_960p60   1'b1
  `define HFRONTPORCH_960p60    48
  `define HSYNCLEN_960p60       32
  `define HBACKPORCH_960p60     80
  `define HACTIVE_960p60        1280
  `define HTOTAL_960p60         1440
  `define VSYNC_active_960p60   1'b0
  `define VFRONTPORCH_960p60    3
  `define VSYNCLEN_960p60       4
  `define VBACKPORCH_960p60     21
  `define VACTIVE_960p60        960
  `define VTOTAL_960p60         988
  
  // 1080p-60, 16:9
  `define USE_1080p60           5'b00101
  `define HSYNC_active_1080p60  1'b1
  `define HFRONTPORCH_1080p60   88
  `define HSYNCLEN_1080p60      44
  `define HBACKPORCH_1080p60    148
  `define HACTIVE_1080p60       1920
  `define HTOTAL_1080p60        2200
  `define VSYNC_active_1080p60  1'b1
  `define VFRONTPORCH_1080p60   4
  `define VSYNCLEN_1080p60      5
  `define VBACKPORCH_1080p60    36
  `define VACTIVE_1080p60       1080
  `define VTOTAL_1080p60        1125
  
  // 1200p-60, 4:3 (CVT-RB)
  `define USE_1200p60           5'b00110
  `define HSYNC_active_1200p60  1'b1
  `define HFRONTPORCH_1200p60   48
  `define HSYNCLEN_1200p60      32
  `define HBACKPORCH_1200p60    80
  `define HACTIVE_1200p60       1600
  `define HTOTAL_1200p60        1760
  `define VSYNC_active_1200p60  1'b0
  `define VFRONTPORCH_1200p60   3
  `define VSYNCLEN_1200p60      4
  `define VBACKPORCH_1200p60    28
  `define VACTIVE_1200p60       1200
  `define VTOTAL_1200p60        1235
  
  // 1440p-60, 4:3 (compromise between CVT-RB and CVT-RBv2)
  `define USE_1440p60           5'b00111
  `define HSYNC_active_1440p60  1'b1
  `define HFRONTPORCH_1440p60   30
  `define HSYNCLEN_1440p60      32
  `define HBACKPORCH_1440p60    58
  `define HACTIVE_1440p60       1920
  `define HTOTAL_1440p60        2040
  `define VSYNC_active_1440p60  1'b0
  `define VFRONTPORCH_1440p60   3
  `define VSYNCLEN_1440p60      4
  `define VBACKPORCH_1440p60    28
  `define VACTIVE_1440p60       1440
  `define VTOTAL_1440p60        1475
  
  // 1440p-60, 16:9 (CVT-RB, 2x pixelrep to achieve horizontal resolution)
  `define USE_1440Wp60            5'b01000
  `define HSYNC_active_1440Wp60   1'b1
  `define HFRONTPORCH_1440Wp60    24
  `define HSYNCLEN_1440Wp60       16
  `define HBACKPORCH_1440Wp60     40
  `define HACTIVE_1440Wp60        1280
  `define HTOTAL_1440Wp60         1360
  `define VSYNC_active_1440Wp60   1'b0
  `define VFRONTPORCH_1440Wp60    3
  `define VSYNCLEN_1440Wp60       5
  `define VBACKPORCH_1440Wp60     33
  `define VACTIVE_1440Wp60        1440
  `define VTOTAL_1440Wp60         1481
  
  // 288p-50, 4:3 (2x/4x pixelrep, mode 8)
  `define USE_288p50            5'b10000
  `define HSYNC_active_288p50   1'b1
  `define HFRONTPORCH_288p50    12
  `define HSYNCLEN_288p50       98
  `define HBACKPORCH_288p50     56
  `define HACTIVE_288p50        640
  `define HTOTAL_288p50         806
  `define VSYNC_active_288p50   1'b1
  `define VFRONTPORCH_288p50    3
  `define VSYNCLEN_288p50       3
  `define VBACKPORCH_288p50     19
  `define VACTIVE_288p50        288
  `define VTOTAL_288p50         313
  
  // VGA-50 (640x576), 4:3
  `define USE_VGAp50            5'b10001
  `define HSYNC_active_VGAp50   1'b0
  `define HFRONTPORCH_VGAp50    12
  `define HSYNCLEN_VGAp50       98
  `define HBACKPORCH_VGAp50     56
  `define HACTIVE_VGAp50        640
  `define HTOTAL_VGAp50         806
  `define VSYNC_active_VGAp50   1'b0
  `define VFRONTPORCH_VGAp50    6
  `define VSYNCLEN_VGAp50       2
  `define VBACKPORCH_VGAp50     41
  `define VACTIVE_VGAp50        576
  `define VTOTAL_VGAp50         625
  
  // 576p-50, 4:3 / 16:9
  `define USE_576p50            5'b10010
  `define HSYNC_active_576p50   1'b0
  `define HFRONTPORCH_576p50    12
  `define HSYNCLEN_576p50       64
  `define HBACKPORCH_576p50     68
  `define HACTIVE_576p50        720
  `define HTOTAL_576p50         864
  `define VSYNC_active_576p50   1'b0
  `define VFRONTPORCH_576p50    5
  `define VSYNCLEN_576p50       5
  `define VBACKPORCH_576p50     39
  `define VACTIVE_576p50        576
  `define VTOTAL_576p50         625
  
  // 720p-50, 16:9
  `define USE_720p50            5'b10011
  `define HSYNC_active_720p50   1'b1
  `define HFRONTPORCH_720p50    440
  `define HSYNCLEN_720p50       40
  `define HBACKPORCH_720p50     220
  `define HACTIVE_720p50        1280
  `define HTOTAL_720p50         1980
  `define VSYNC_active_720p50   1'b1
  `define VFRONTPORCH_720p50    5
  `define VSYNCLEN_720p50       5
  `define VBACKPORCH_720p50     20
  `define VACTIVE_720p50        720
  `define VTOTAL_720p50         750
  
  // 960p-50, 4:3
  `define USE_960p50            5'b10100
  `define HSYNC_active_960p50   1'b1
  `define HFRONTPORCH_960p50    336
  `define HSYNCLEN_960p50       32
  `define HBACKPORCH_960p50     80
  `define HACTIVE_960p50        1280
  `define HTOTAL_960p50         1728
  `define VSYNC_active_960p50   1'b0
  `define VFRONTPORCH_960p50    3
  `define VSYNCLEN_960p50       4
  `define VBACKPORCH_960p50     21
  `define VACTIVE_960p50        960
  `define VTOTAL_960p50         988
  
  // 1080p-50, 16:9
  `define USE_1080p50           5'b10101
  `define HSYNC_active_1080p50  1'b1
  `define HFRONTPORCH_1080p50   528
  `define HSYNCLEN_1080p50      44
  `define HBACKPORCH_1080p50    148
  `define HACTIVE_1080p50       1920
  `define HTOTAL_1080p50        2640
  `define VSYNC_active_1080p50  1'b1
  `define VFRONTPORCH_1080p50   4
  `define VSYNCLEN_1080p50      5
  `define VBACKPORCH_1080p50    36
  `define VACTIVE_1080p50       1080
  `define VTOTAL_1080p50        1125
  
  // 1200p-50, 4:3 (CVT-RB)
  `define USE_1200p50           5'b10110
  `define HSYNC_active_1200p50  1'b0
  `define HFRONTPORCH_1200p50   400
  `define HSYNCLEN_1200p50      32
  `define HBACKPORCH_1200p50    80
  `define HACTIVE_1200p50       1600
  `define HTOTAL_1200p50        2112
  `define VSYNC_active_1200p50  1'b1
  `define VFRONTPORCH_1200p50   3
  `define VSYNCLEN_1200p50      4
  `define VBACKPORCH_1200p50    28
  `define VACTIVE_1200p50       1200
  `define VTOTAL_1200p50        1235
  
  // 1440p-50, 4:3 (compromise between CVT-RB and CVT-RBv2)
  `define USE_1440p50           5'b10111
  `define HSYNC_active_1440p50  1'b1
  `define HFRONTPORCH_1440p50   438
  `define HSYNCLEN_1440p50      32
  `define HBACKPORCH_1440p50    58
  `define HACTIVE_1440p50       1920
  `define HTOTAL_1440p50        2448
  `define VSYNC_active_1440p50  1'b0
  `define VFRONTPORCH_1440p50   3
  `define VSYNCLEN_1440p50      4
  `define VBACKPORCH_1440p50    28
  `define VACTIVE_1440p50       1440
  `define VTOTAL_1440p50        1475
  
  // 1440p-50, 16:9 (CVT-RB, 2x pixelrep to achieve horizontal resolution)
  `define USE_1440Wp50            5'b11000
  `define HSYNC_active_1440Wp50   1'b1
  `define HFRONTPORCH_1440Wp50    296
  `define HSYNCLEN_1440Wp50       16
  `define HBACKPORCH_1440Wp50     40
  `define HACTIVE_1440Wp50        1280
  `define HTOTAL_1440Wp50         1632
  `define VSYNC_active_1440Wp50   1'b0
  `define VFRONTPORCH_1440Wp50    3
  `define VSYNCLEN_1440Wp50       5
  `define VBACKPORCH_1440Wp50     33
  `define VACTIVE_1440Wp50        1440
  `define VTOTAL_1440Wp50         1481

  `define STARTING_LINE_SDRAM_READ_DV1  15  // shortest sync+bp is @ 240p60 with 18 lines (18 - overscan = 18 - 3 = 15)
  `define STARTING_LINE_SDRAM_READ_STD  22  // shortest sync+bp is @ 960p60 with 25 lines (25 - overscan = 25 - 3 = 22)
  
  `define USE_FXD60            5'b01111
  `define USE_FXD50            5'b11111

`endif