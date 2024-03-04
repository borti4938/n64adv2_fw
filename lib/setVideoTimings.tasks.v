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
// V-file Name:    setVideoTimings.tasks.v
// Project Name:   N64 Advanced Mod
// Target Devices: several devices
// Tool versions:  Altera Quartus Prime
// Description:
//
//////////////////////////////////////////////////////////////////////////////////


task setVideoSYNCactive;

  input [`VID_CFG_W-1:0] video_config;
  output VSYNC_active;
  output HSYNC_active;
  
  begin
    case (video_config)
      `USE_240p60: begin  // 240p-60, 4:3 (2x/4x pixelrep, mode 2)
          VSYNC_active <= `VSYNC_active_240p60;
          HSYNC_active <= `HSYNC_active_240p60;
        end
      `USE_VGAp60: begin  // VGA-60 (640x480), 4:3
          VSYNC_active <= `VSYNC_active_VGAp60;
          HSYNC_active <= `HSYNC_active_VGAp60;
        end
      `USE_480p60: begin  // 480p-60, 4:3 / 16:9
          VSYNC_active <= `VSYNC_active_480p60;
          HSYNC_active <= `HSYNC_active_480p60;
        end
      `USE_720p60: begin  // 720p-60, 16:9
          VSYNC_active <= `VSYNC_active_720p60;
          HSYNC_active <= `HSYNC_active_720p60;
        end
      `USE_960p60: begin  // 960p-60, 4:3
          VSYNC_active <= `VSYNC_active_960p60;
          HSYNC_active <= `HSYNC_active_960p60;
        end
//      `USE_1080p60: begin // 1080p-60, 16:9
//          VSYNC_active <= `VSYNC_active_1080p60;
//          HSYNC_active <= `HSYNC_active_1080p60;
//        end
      `USE_1200p60: begin // 1200p-60, 4:3
          VSYNC_active <= `VSYNC_active_1200p60;
          HSYNC_active <= `HSYNC_active_1200p60;
        end
      `USE_1440p60: begin // 1440p-600, 4:3
          VSYNC_active <= `VSYNC_active_1440p60;
          HSYNC_active <= `HSYNC_active_1440p60;
        end
      `USE_1440Wp60: begin // 1440p-60, 16:9 (2x pixelrep)
          VSYNC_active <= `VSYNC_active_1440Wp60;
          HSYNC_active <= `HSYNC_active_1440Wp60;
        end
      `USE_288p50: begin  // 288p-50, 4:3 (2x/4x pixelrep, mode 2)
          VSYNC_active <= `VSYNC_active_288p50;
          HSYNC_active <= `HSYNC_active_288p50;
        end
      `USE_VGAp50: begin  // VGA-50 (640x576), 4:3
          VSYNC_active <= `VSYNC_active_VGAp50;
          HSYNC_active <= `HSYNC_active_VGAp50;
        end
      `USE_576p50: begin  // 576p-50 (720x576), 4:3 / 16:9
          VSYNC_active <= `VSYNC_active_VGAp50;
          HSYNC_active <= `HSYNC_active_VGAp50;
        end
      `USE_720p50: begin // 720p-50, 16:9
          VSYNC_active <= `VSYNC_active_720p50;
          HSYNC_active <= `HSYNC_active_720p50;
        end
      `USE_960p50: begin // 960p-50, 4:3
          VSYNC_active <= `VSYNC_active_960p50;
          HSYNC_active <= `HSYNC_active_960p50;
        end
      `USE_1080p50: begin // 1080p-50, 16:9
          VSYNC_active <= `VSYNC_active_1080p50;
          HSYNC_active <= `HSYNC_active_1080p50;
        end
      `USE_1200p50: begin // 1200p-50, 4:3
          VSYNC_active <= `VSYNC_active_1200p50;
          HSYNC_active <= `HSYNC_active_1200p50;
        end
      `USE_1440p50: begin // 1440p-50, 4:3
          VSYNC_active <= `VSYNC_active_1440p50;
          HSYNC_active <= `HSYNC_active_1440p50;
        end
      `USE_1440Wp50: begin // 1440p-50, 16:9 (2x pixelrep)
          VSYNC_active <= `VSYNC_active_1440Wp50;
          HSYNC_active <= `HSYNC_active_1440Wp50;
        end
      default: begin // 1080p-60, 16:9
          VSYNC_active <= `VSYNC_active_1080p60;
          HSYNC_active <= `HSYNC_active_1080p60;
        end
    endcase
  end
  
endtask


task setVideoVidACTIVE;

  input [`VID_CFG_W-1:0] video_config;
  output [10:0] VACTIVE;
  output [11:0] HACTIVE;
  
  begin
    case (video_config)
      `USE_240p60: begin  // 240p-60, 4:3 (2x/4x pixelrep, mode 2)
          VACTIVE <= `VACTIVE_240p60;
          HACTIVE <= `HACTIVE_240p60;
        end
      `USE_VGAp60: begin  // VGA-60 (640x480), 4:3
          VACTIVE <= `VACTIVE_VGAp60;
          HACTIVE <= `HACTIVE_VGAp60;
        end
      `USE_480p60: begin  // 480p-60, 4:3 / 16:9
          VACTIVE <= `VACTIVE_480p60;
          HACTIVE <= `HACTIVE_480p60;
        end
      `USE_720p60: begin  // 720p-60, 16:9
          VACTIVE <= `VACTIVE_720p60;
          HACTIVE <= `HACTIVE_720p60;
        end
      `USE_960p60: begin  // 960p-60, 4:3
          VACTIVE <= `VACTIVE_960p60;
          HACTIVE <= `HACTIVE_960p60;
        end
//      `USE_1080p60: begin // 1080p-60, 16:9
//          VACTIVE <= `VACTIVE_1080p60;
//          HACTIVE <= `HACTIVE_1080p60;
//        end
      `USE_1200p60: begin // 1200p-60, 4:3
          VACTIVE <= `VACTIVE_1200p60;
          HACTIVE <= `HACTIVE_1200p60;
        end
      `USE_1440p60: begin // 1440p-60, 4:3
          VACTIVE <= `VACTIVE_1440p60;
          HACTIVE <= `HACTIVE_1440p60;
        end
      `USE_1440Wp60: begin  // 1440p-60, 16:9 (2x pixelrep)
          VACTIVE <= `VACTIVE_1440Wp60;
          HACTIVE <= `HACTIVE_1440Wp60;
        end
      `USE_288p50: begin  // 288p-50, 4:3 (2x/4x pixelrep, mode 2)
          VACTIVE <= `VACTIVE_288p50;
          HACTIVE <= `HACTIVE_288p50;
        end
      `USE_VGAp50: begin  // VGA-50 (640x576), 4:3
          VACTIVE <= `VACTIVE_VGAp50;
          HACTIVE <= `HACTIVE_VGAp50;
        end
      `USE_576p50: begin  // 576p-50 (720x576), 4:3 / 16:9
          VACTIVE <= `VACTIVE_576p50;
          HACTIVE <= `HACTIVE_576p50;
        end
      `USE_720p50: begin  // 720p-50, 16:9
          VACTIVE <= `VACTIVE_720p50;
          HACTIVE <= `HACTIVE_720p50;
        end
      `USE_960p50: begin  // 960p-50, 4:3
          VACTIVE <= `VACTIVE_960p50;
          HACTIVE <= `HACTIVE_960p50;
        end
      `USE_1080p50: begin // 1080p-50, 16:9
          VACTIVE <= `VACTIVE_1080p50;
          HACTIVE <= `HACTIVE_1080p50;
        end
      `USE_1200p50: begin // 1200p-50, 4:3
          VACTIVE <= `VACTIVE_1200p50;
          HACTIVE <= `HACTIVE_1200p50;
        end
      `USE_1440p50: begin // 1440p-50, 4:3
          VACTIVE <= `VACTIVE_1440p50;
          HACTIVE <= `HACTIVE_1440p50;
        end
      `USE_1440Wp50: begin  // 1440p-50, 16:9 (2x pixelrep)
          VACTIVE <= `VACTIVE_1440Wp50;
          HACTIVE <= `HACTIVE_1440Wp50;
        end
      default: begin  // 1080p-60, 16:9
          VACTIVE <= `VACTIVE_1080p60;
          HACTIVE <= `HACTIVE_1080p60;
        end
    endcase
  end

endtask


task setVideoVidACTIVEwOS;

  input [`VID_CFG_W-1:0] video_config;
  output [10:0] VACTIVE_OS;
  output [11:0] HACTIVE_OS;
  
  begin
    case (video_config)
      `USE_240p60: begin  // 240p-60, 4:3 (2x/4x pixelrep, mode 2)
          VACTIVE_OS <= `VACTIVE_240p60 + 2*`VOVERSCAN_MAX_240p60;
          HACTIVE_OS <= `HACTIVE_240p60 + 2*`HOVERSCAN_MAX_240p60;
        end
      `USE_VGAp60: begin  // VGA-60 (640x480), 4:3
          VACTIVE_OS <= `VACTIVE_VGAp60 + 2*`VOVERSCAN_MAX_VGAp60;
          HACTIVE_OS <= `HACTIVE_VGAp60 + 2*`HOVERSCAN_MAX_VGAp60;
        end
      `USE_480p60: begin  // 480p-60, 4:3 / 16:9
            VACTIVE_OS <= `VACTIVE_480p60 + 2*`VOVERSCAN_MAX_480p60;
            HACTIVE_OS <= `HACTIVE_480p60 + 2*`HOVERSCAN_MAX_480p60;
        end
      `USE_720p60: begin  // 720p-60, 16:9
          VACTIVE_OS <= `VACTIVE_720p60 + 2*`VOVERSCAN_MAX_720p60;
          HACTIVE_OS <= `HACTIVE_720p60 + 2*`HOVERSCAN_MAX_720p60;
        end
      `USE_960p60: begin  // 960p-60, 4:3
          VACTIVE_OS <= `VACTIVE_960p60 + 2*`VOVERSCAN_MAX_960p60;
          HACTIVE_OS <= `HACTIVE_960p60 + 2*`HOVERSCAN_MAX_960p60;
        end
//      `USE_1080p60: begin // 1080p-60, 16:9
//          VACTIVE_OS <= `VACTIVE_1080p60 + 2*`VOVERSCAN_MAX_1080p60;
//          HACTIVE_OS <= `HACTIVE_1080p60 + 2*`HOVERSCAN_MAX_1080p60;
//        end
      `USE_1200p60: begin // 1200p-60, 4:3
          VACTIVE_OS <= `VACTIVE_1200p60 + 2*`VOVERSCAN_MAX_1200p60;
          HACTIVE_OS <= `HACTIVE_1200p60 + 2*`HOVERSCAN_MAX_1200p60;
        end
      `USE_1440p60: begin // 1440p-60, 4:3
          VACTIVE_OS <= `VACTIVE_1440p60 + 2*`VOVERSCAN_MAX_1440p60;
          HACTIVE_OS <= `HACTIVE_1440p60 + 2*`HOVERSCAN_MAX_1440p60;
        end
      `USE_1440Wp60: begin  // 1440p-60, 16:9 (2x pixelrep)
          VACTIVE_OS <= `VACTIVE_1440Wp60 + 2*`VOVERSCAN_MAX_1440Wp60;
          HACTIVE_OS <= `HACTIVE_1440Wp60 + 2*`HOVERSCAN_MAX_1440Wp60;
        end
      `USE_288p50: begin  // 288p-50, 4:3 (2x/4x pixelrep, mode 2)
          VACTIVE_OS <= `VACTIVE_288p50 + 2*`VOVERSCAN_MAX_288p50;
          HACTIVE_OS <= `HACTIVE_288p50 + 2*`HOVERSCAN_MAX_288p50;
        end
      `USE_VGAp50: begin  // VGAp-50, 4:3 / 16:9
            VACTIVE_OS <= `VACTIVE_VGAp50 + 2*`VOVERSCAN_MAX_VGAp50;
            HACTIVE_OS <= `HACTIVE_VGAp50 + 2*`HOVERSCAN_MAX_VGAp50;
        end
      `USE_576p50: begin  // 576p-50, 4:3 / 16:9
            VACTIVE_OS <= `VACTIVE_576p50 + 2*`VOVERSCAN_MAX_576p50;
            HACTIVE_OS <= `HACTIVE_576p50 + 2*`HOVERSCAN_MAX_576p50;
        end
      `USE_720p50: begin  // 720p-50, 16:9
          VACTIVE_OS <= `VACTIVE_720p50 + 2*`VOVERSCAN_MAX_720p50;
          HACTIVE_OS <= `HACTIVE_720p50 + 2*`HOVERSCAN_MAX_720p50;
        end
      `USE_960p50: begin  // 960p-50, 4:3
          VACTIVE_OS <= `VACTIVE_960p50 + 2*`VOVERSCAN_MAX_960p50;
          HACTIVE_OS <= `HACTIVE_960p50 + 2*`HOVERSCAN_MAX_960p50;
        end
      `USE_1080p50: begin // 1080p-50, 16:9
          VACTIVE_OS <= `VACTIVE_1080p50 + 2*`VOVERSCAN_MAX_1080p50;
          HACTIVE_OS <= `HACTIVE_1080p50 + 2*`HOVERSCAN_MAX_1080p50;
        end
      `USE_1200p50: begin // 1200p-50, 4:3
          VACTIVE_OS <= `VACTIVE_1200p50 + 2*`VOVERSCAN_MAX_1200p50;
          HACTIVE_OS <= `HACTIVE_1200p50 + 2*`HOVERSCAN_MAX_1200p50;
        end
      `USE_1440p50: begin // 1440p-50, 4:3
          VACTIVE_OS <= `VACTIVE_1440p50 + 2*`VOVERSCAN_MAX_1440p50;
          HACTIVE_OS <= `HACTIVE_1440p50 + 2*`HOVERSCAN_MAX_1440p50;
        end
      `USE_1440Wp50: begin  // 1440p-50, 16:9 (2x pixelrep)
          VACTIVE_OS <= `VACTIVE_1440Wp50 + 2*`VOVERSCAN_MAX_1440Wp50;
          HACTIVE_OS <= `HACTIVE_1440Wp50 + 2*`HOVERSCAN_MAX_1440Wp50;
        end
      default: begin  // 1080p-60, 16:9
          VACTIVE_OS <= `VACTIVE_1080p60 + 2*`VOVERSCAN_MAX_1080p60;
          HACTIVE_OS <= `HACTIVE_1080p60 + 2*`HOVERSCAN_MAX_1080p60;
        end
    endcase
  end

endtask


task setVideoVTimings;

  input [`VID_CFG_W-1:0] video_config;
  output VSYNC_active;
  output [10:0] VSYNCLEN;
  output [10:0] VSTART;
  output [10:0] VACTIVE;
  output [10:0] VSTOP;
  output [10:0] VSTART_OS;
  output [10:0] VACTIVE_OS;
  output [10:0] VSTOP_OS;
  output [10:0] VTOTAL;
  
  begin
    case (video_config)
      `USE_240p60: begin  // 240p-60, 4:3 (2x/4x pixelrep, mode 2)
          VSYNC_active <= `VSYNC_active_240p60;
          VSYNCLEN <= `VSYNCLEN_240p60;
          VSTART <= `VSYNCLEN_240p60 + `VBACKPORCH_240p60;
          VACTIVE <= `VACTIVE_240p60;
          VSTOP <= `VSYNCLEN_240p60 + `VBACKPORCH_240p60 + `VACTIVE_240p60;
          VSTART_OS <= `VSYNCLEN_240p60 + `VBACKPORCH_240p60 - `VOVERSCAN_MAX_240p60;
          VACTIVE_OS <= `VACTIVE_240p60 + 2*`VOVERSCAN_MAX_240p60;
          VSTOP_OS <= `VSYNCLEN_240p60 + `VBACKPORCH_240p60 + `VACTIVE_240p60 + `VOVERSCAN_MAX_240p60;
          VTOTAL <= `VTOTAL_240p60;
        end
      `USE_VGAp60: begin  // VGA-60 (640x480), 4:3
          VSYNC_active <= `VSYNC_active_VGAp60;
          VSYNCLEN <= `VSYNCLEN_VGAp60;
          VSTART <= `VSYNCLEN_VGAp60 + `VBACKPORCH_VGAp60;
          VACTIVE <= `VACTIVE_VGAp60;
          VSTOP <= `VSYNCLEN_VGAp60 + `VBACKPORCH_VGAp60 + `VACTIVE_VGAp60;
          VSTART_OS <= `VSYNCLEN_VGAp60 + `VBACKPORCH_VGAp60 - `VOVERSCAN_MAX_VGAp60;
          VACTIVE_OS <= `VACTIVE_VGAp60 + 2*`VOVERSCAN_MAX_VGAp60;
          VSTOP_OS <= `VSYNCLEN_VGAp60 + `VBACKPORCH_VGAp60 + `VACTIVE_VGAp60 + `VOVERSCAN_MAX_VGAp60;
          VTOTAL <= `VTOTAL_VGAp60;
        end
      `USE_480p60: begin  // 480p-60, 4:3 / 16:9
          VSYNC_active <= `VSYNC_active_480p60;
          VSYNCLEN <= `VSYNCLEN_480p60;
          VSTART <= `VSYNCLEN_480p60 + `VBACKPORCH_480p60;
          VACTIVE <= `VACTIVE_480p60;
          VSTOP <= `VSYNCLEN_480p60 + `VBACKPORCH_480p60 + `VACTIVE_480p60;
          VSTART_OS <= `VSYNCLEN_480p60 + `VBACKPORCH_480p60 - `VOVERSCAN_MAX_480p60;
          VACTIVE_OS <= `VACTIVE_480p60 + 2*`VOVERSCAN_MAX_480p60;
          VSTOP_OS <= `VSYNCLEN_480p60 + `VBACKPORCH_480p60 + `VACTIVE_480p60 + `VOVERSCAN_MAX_480p60;
          VTOTAL <= `VTOTAL_480p60;
        end
      `USE_720p60: begin  // 720p-60, 16:9
          VSYNC_active <= `VSYNC_active_720p60;
          VSYNCLEN <= `VSYNCLEN_720p60;
          VSTART <= `VSYNCLEN_720p60 + `VBACKPORCH_720p60;
          VACTIVE <= `VACTIVE_720p60;
          VSTOP <= `VSYNCLEN_720p60 + `VBACKPORCH_720p60 + `VACTIVE_720p60;
          VSTART_OS <= `VSYNCLEN_720p60 + `VBACKPORCH_720p60 - `VOVERSCAN_MAX_720p60;
          VACTIVE_OS <= `VACTIVE_720p60 + 2*`VOVERSCAN_MAX_720p60;
          VSTOP_OS <= `VSYNCLEN_720p60 + `VBACKPORCH_720p60 + `VACTIVE_720p60 + `VOVERSCAN_MAX_720p60;
          VTOTAL <= `VTOTAL_720p60;
        end
      `USE_960p60: begin  // 960p-60, 4:3
          VSYNC_active <= `VSYNC_active_960p60;
          VSYNCLEN <= `VSYNCLEN_960p60;
          VSTART <= `VSYNCLEN_960p60 + `VBACKPORCH_960p60;
          VACTIVE <= `VACTIVE_960p60;
          VSTOP <= `VSYNCLEN_960p60 + `VBACKPORCH_960p60 + `VACTIVE_960p60;
          VSTART_OS <= `VSYNCLEN_960p60 + `VBACKPORCH_960p60 - `VOVERSCAN_MAX_960p60;
          VACTIVE_OS <= `VACTIVE_960p60 + 2*`VOVERSCAN_MAX_960p60;
          VSTOP_OS <= `VSYNCLEN_960p60 + `VBACKPORCH_960p60 + `VACTIVE_960p60 + `VOVERSCAN_MAX_960p60;
          VTOTAL <= `VTOTAL_960p60;
        end
//      `USE_1080p60: begin // 1080p-60, 16:9
//          VSYNC_active <= `VSYNC_active_1080p60;
//          VSYNCLEN <= `VSYNCLEN_1080p60;
//          VSTART <= `VSYNCLEN_1080p60 + `VBACKPORCH_1080p60;
//          VACTIVE <= `VACTIVE_1080p60;
//          VSTOP <= `VSYNCLEN_1080p60 + `VBACKPORCH_1080p60 + `VACTIVE_1080p60;
//          VSTART_OS <= `VSYNCLEN_1080p60 + `VBACKPORCH_1080p60 - `VOVERSCAN_MAX_1080p60;
//          VACTIVE_OS <= `VACTIVE_1080p60 + 2*`VOVERSCAN_MAX_1080p60;
//          VSTOP_OS <= `VSYNCLEN_1080p60 + `VBACKPORCH_1080p60 + `VACTIVE_1080p60 + `VOVERSCAN_MAX_1080p60;
//          VTOTAL <= `VTOTAL_1080p60;
//        end
      `USE_1200p60: begin // 1200p-60, 4:3
          VSYNC_active <= `VSYNC_active_1200p60;
          VSYNCLEN <= `VSYNCLEN_1200p60;
          VSTART <= `VSYNCLEN_1200p60 + `VBACKPORCH_1200p60;
          VACTIVE <= `VACTIVE_1200p60;
          VSTOP <= `VSYNCLEN_1200p60 + `VBACKPORCH_1200p60 + `VACTIVE_1200p60;
          VSTART_OS <= `VSYNCLEN_1200p60 + `VBACKPORCH_1200p60 - `VOVERSCAN_MAX_1200p60;
          VACTIVE_OS <= `VACTIVE_1200p60 + 2*`VOVERSCAN_MAX_1200p60;
          VSTOP_OS <= `VSYNCLEN_1200p60 + `VBACKPORCH_1200p60 + `VACTIVE_1200p60 + `VOVERSCAN_MAX_1200p60;
          VTOTAL <= `VTOTAL_1200p60;
        end
      `USE_1440p60: begin // 1440p-60, 4:3
          VSYNC_active <= `VSYNC_active_1440p60;
          VSYNCLEN <= `VSYNCLEN_1440p60;
          VSTART <= `VSYNCLEN_1440p60 + `VBACKPORCH_1440p60;
          VACTIVE <= `VACTIVE_1440p60;
          VSTOP <= `VSYNCLEN_1440p60 + `VBACKPORCH_1440p60 + `VACTIVE_1440p60;
          VSTART_OS <= `VSYNCLEN_1440p60 + `VBACKPORCH_1440p60 - `VOVERSCAN_MAX_1440p60;
          VACTIVE_OS <= `VACTIVE_1440p60 + 2*`VOVERSCAN_MAX_1440p60;
          VSTOP_OS <= `VSYNCLEN_1440p60 + `VBACKPORCH_1440p60 + `VACTIVE_1440p60 + `VOVERSCAN_MAX_1440p60;
          VTOTAL <= `VTOTAL_1440p60;
        end
      `USE_1440Wp60: begin  // 1440p-60, 16:9 (2x pixelrep)
          VSYNC_active <= `VSYNC_active_1440Wp60;
          VSYNCLEN <= `VSYNCLEN_1440Wp60;
          VSTART <= `VSYNCLEN_1440Wp60 + `VBACKPORCH_1440Wp60;
          VACTIVE <= `VACTIVE_1440Wp60;
          VSTOP <= `VSYNCLEN_1440Wp60 + `VBACKPORCH_1440Wp60 + `VACTIVE_1440Wp60;
          VSTART_OS <= `VSYNCLEN_1440Wp60 + `VBACKPORCH_1440Wp60 - `VOVERSCAN_MAX_1440Wp60;
          VACTIVE_OS <= `VACTIVE_1440Wp60 + 2*`VOVERSCAN_MAX_1440Wp60;
          VSTOP_OS <= `VSYNCLEN_1440Wp60 + `VBACKPORCH_1440Wp60 + `VACTIVE_1440Wp60 + `VOVERSCAN_MAX_1440Wp60;
          VTOTAL <= `VTOTAL_1440Wp60;
        end
      `USE_288p50: begin  // 288p-50, 4:3 (2x/4x pixelrep, mode 2)
          VSYNC_active <= `VSYNC_active_288p50;
          VSYNCLEN <= `VSYNCLEN_288p50;
          VSTART <= `VSYNCLEN_288p50 + `VBACKPORCH_288p50;
          VACTIVE <= `VACTIVE_288p50;
          VSTOP <= `VSYNCLEN_288p50 + `VBACKPORCH_288p50 + `VACTIVE_288p50;
          VSTART_OS <= `VSYNCLEN_288p50 + `VBACKPORCH_288p50 - `VOVERSCAN_MAX_288p50;
          VACTIVE_OS <= `VACTIVE_288p50 + 2*`VOVERSCAN_MAX_288p50;
          VSTOP_OS <= `VSYNCLEN_288p50 + `VBACKPORCH_288p50 + `VACTIVE_288p50 + `VOVERSCAN_MAX_288p50;
          VTOTAL <= `VTOTAL_288p50;
        end
      `USE_VGAp50: begin  // VGA-50, 4:3
            VSYNC_active <= `VSYNC_active_VGAp50;
            VSYNCLEN <= `VSYNCLEN_VGAp50;
            VSTART <= `VSYNCLEN_VGAp50 + `VBACKPORCH_VGAp50;
            VACTIVE <= `VACTIVE_VGAp50;
            VSTOP <= `VSYNCLEN_VGAp50 + `VBACKPORCH_VGAp50 + `VACTIVE_VGAp50;
            VSTART_OS <= `VSYNCLEN_VGAp50 + `VBACKPORCH_VGAp50 - `VOVERSCAN_MAX_VGAp50;
            VACTIVE_OS <= `VACTIVE_VGAp50 + 2*`VOVERSCAN_MAX_VGAp50;
            VSTOP_OS <= `VSYNCLEN_VGAp50 + `VBACKPORCH_VGAp50 + `VACTIVE_VGAp50 + `VOVERSCAN_MAX_VGAp50;
            VTOTAL <= `VTOTAL_VGAp50;
        end
      `USE_576p50: begin  // 576p-50, 4:3 / 16:9
            VSYNC_active <= `VSYNC_active_576p50;
            VSYNCLEN <= `VSYNCLEN_576p50;
            VSTART <= `VSYNCLEN_576p50 + `VBACKPORCH_576p50;
            VACTIVE <= `VACTIVE_576p50;
            VSTOP <= `VSYNCLEN_576p50 + `VBACKPORCH_576p50 + `VACTIVE_576p50;
            VSTART_OS <= `VSYNCLEN_576p50 + `VBACKPORCH_576p50 - `VOVERSCAN_MAX_576p50;
            VACTIVE_OS <= `VACTIVE_576p50 + 2*`VOVERSCAN_MAX_576p50;
            VSTOP_OS <= `VSYNCLEN_576p50 + `VBACKPORCH_576p50 + `VACTIVE_576p50 + `VOVERSCAN_MAX_576p50;
            VTOTAL <= `VTOTAL_576p50;
        end
      `USE_720p50: begin  // 720p-50, 16:9
          VSYNC_active <= `VSYNC_active_720p50;
          VSYNCLEN <= `VSYNCLEN_720p50;
          VSTART <= `VSYNCLEN_720p50 + `VBACKPORCH_720p50;
          VACTIVE <= `VACTIVE_720p50;
          VSTOP <= `VSYNCLEN_720p50 + `VBACKPORCH_720p50 + `VACTIVE_720p50;
          VSTART_OS <= `VSYNCLEN_720p50 + `VBACKPORCH_720p50 - `VOVERSCAN_MAX_720p50;
          VACTIVE_OS <= `VACTIVE_720p50 + 2*`VOVERSCAN_MAX_720p50;
          VSTOP_OS <= `VSYNCLEN_720p50 + `VBACKPORCH_720p50 + `VACTIVE_720p50 + `VOVERSCAN_MAX_720p50;
          VTOTAL <= `VTOTAL_720p50;
        end
      `USE_960p50: begin  // 960p-50, 4:3
          VSYNC_active <= `VSYNC_active_960p50;
          VSYNCLEN <= `VSYNCLEN_960p50;
          VSTART <= `VSYNCLEN_960p50 + `VBACKPORCH_960p50;
          VACTIVE <= `VACTIVE_960p50;
          VSTOP <= `VSYNCLEN_960p50 + `VBACKPORCH_960p50 + `VACTIVE_960p50;
          VSTART_OS <= `VSYNCLEN_960p50 + `VBACKPORCH_960p50 - `VOVERSCAN_MAX_960p50;
          VACTIVE_OS <= `VACTIVE_960p50 + 2*`VOVERSCAN_MAX_960p50;
          VSTOP_OS <= `VSYNCLEN_960p50 + `VBACKPORCH_960p50 + `VACTIVE_960p50 + `VOVERSCAN_MAX_960p50;
          VTOTAL <= `VTOTAL_960p50;
        end
      `USE_1080p50: begin // 1080p-50, 16:9
          VSYNC_active <= `VSYNC_active_1080p50;
          VSYNCLEN <= `VSYNCLEN_1080p50;
          VSTART <= `VSYNCLEN_1080p50 + `VBACKPORCH_1080p50;
          VACTIVE <= `VACTIVE_1080p50;
          VSTOP <= `VSYNCLEN_1080p50 + `VBACKPORCH_1080p50 + `VACTIVE_1080p50;
          VSTART_OS <= `VSYNCLEN_1080p50 + `VBACKPORCH_1080p50 - `VOVERSCAN_MAX_1080p50;
          VACTIVE_OS <= `VACTIVE_1080p50 + 2*`VOVERSCAN_MAX_1080p50;
          VSTOP_OS <= `VSYNCLEN_1080p50 + `VBACKPORCH_1080p50 + `VACTIVE_1080p50 + `VOVERSCAN_MAX_1080p50;
          VTOTAL <= `VTOTAL_1080p50;
        end
      `USE_1200p50: begin // 1200p-50, 4:3
          VSYNC_active <= `VSYNC_active_1200p50;
          VSYNCLEN <= `VSYNCLEN_1200p50;
          VSTART <= `VSYNCLEN_1200p50 + `VBACKPORCH_1200p50;
          VACTIVE <= `VACTIVE_1200p50;
          VSTOP <= `VSYNCLEN_1200p50 + `VBACKPORCH_1200p50 + `VACTIVE_1200p50;
          VSTART_OS <= `VSYNCLEN_1200p50 + `VBACKPORCH_1200p50 - `VOVERSCAN_MAX_1200p50;
          VACTIVE_OS <= `VACTIVE_1200p50 + 2*`VOVERSCAN_MAX_1200p50;
          VSTOP_OS <= `VSYNCLEN_1200p50 + `VBACKPORCH_1200p50 + `VACTIVE_1200p50 + `VOVERSCAN_MAX_1200p50;
          VTOTAL <= `VTOTAL_1200p50;
        end
      `USE_1440p50: begin // 1440p-50, 4:3
          VSYNC_active <= `VSYNC_active_1440p50;
          VSYNCLEN <= `VSYNCLEN_1440p50;
          VSTART_OS <= `VSYNCLEN_1440p50;
          VSTART <= `VSYNCLEN_1440p50 + `VBACKPORCH_1440p50;
          VACTIVE <= `VACTIVE_1440p50;
          VSTOP <= `VSYNCLEN_1440p50 + `VBACKPORCH_1440p50 + `VACTIVE_1440p50;
          VSTART_OS <= `VSYNCLEN_1440p50 + `VBACKPORCH_1440p50 - `VOVERSCAN_MAX_1440p50;
          VACTIVE_OS <= `VACTIVE_1440p50 + 2*`VOVERSCAN_MAX_1440p50;
          VSTOP_OS <= `VSYNCLEN_1440p50 + `VBACKPORCH_1440p50 + `VACTIVE_1440p50 + `VOVERSCAN_MAX_1440p50;
          VTOTAL <= `VTOTAL_1440p50;
        end
      `USE_1440Wp50: begin // 1440p-50, 16:9 (2x pixelrep)
          VSYNC_active <= `VSYNC_active_1440Wp50;
          VSYNCLEN <= `VSYNCLEN_1440Wp50;
          VSTART_OS <= `VSYNCLEN_1440Wp50;
          VSTART <= `VSYNCLEN_1440Wp50 + `VBACKPORCH_1440Wp50;
          VACTIVE <= `VACTIVE_1440Wp50;
          VSTOP <= `VSYNCLEN_1440Wp50 + `VBACKPORCH_1440Wp50 + `VACTIVE_1440Wp50;
          VSTART_OS <= `VSYNCLEN_1440Wp50 + `VBACKPORCH_1440Wp50 - `VOVERSCAN_MAX_1440Wp50;
          VACTIVE_OS <= `VACTIVE_1440Wp50 + 2*`VOVERSCAN_MAX_1440Wp50;
          VSTOP_OS <= `VSYNCLEN_1440Wp50 + `VBACKPORCH_1440Wp50 + `VACTIVE_1440Wp50 + `VOVERSCAN_MAX_1440Wp50;
          VTOTAL <= `VTOTAL_1440Wp50;
        end
      default: begin  // 1080p-60, 16:9
          VSYNC_active <= `VSYNC_active_1080p60;
          VSYNCLEN <= `VSYNCLEN_1080p60;
          VSTART <= `VSYNCLEN_1080p60 + `VBACKPORCH_1080p60;
          VACTIVE <= `VACTIVE_1080p60;
          VSTOP <= `VSYNCLEN_1080p60 + `VBACKPORCH_1080p60 + `VACTIVE_1080p60;
          VSTART_OS <= `VSYNCLEN_1080p60 + `VBACKPORCH_1080p60 - `VOVERSCAN_MAX_1080p60;
          VACTIVE_OS <= `VACTIVE_1080p60 + 2*`VOVERSCAN_MAX_1080p60;
          VSTOP_OS <= `VSYNCLEN_1080p60 + `VBACKPORCH_1080p60 + `VACTIVE_1080p60 + `VOVERSCAN_MAX_1080p60;
          VTOTAL <= `VTOTAL_1080p60;
        end
    endcase
  end

endtask


task setVideoHTimings;

  input [`VID_CFG_W-1:0] video_config;
  output HSYNC_active;
  output [11:0] HSYNCLEN;
  output [11:0] HSTART;
  output [11:0] HACTIVE;
  output [11:0] HSTOP;
  output [11:0] HSTART_OS;
  output [11:0] HACTIVE_OS;
  output [11:0] HSTOP_OS;
  output [11:0] HTOTAL;
  
  begin
    case (video_config)
      `USE_240p60: begin  // 240p-60, 4:3 (2x/4x pixelrep, mode 2)
          HSYNC_active <= `HSYNC_active_240p60;
          HSYNCLEN <= `HSYNCLEN_240p60;
          HSTART <= `HSYNCLEN_240p60 + `HBACKPORCH_240p60;
          HACTIVE <= `HACTIVE_240p60;
          HSTOP <= `HSYNCLEN_240p60 + `HBACKPORCH_240p60 + `HACTIVE_240p60;
          HSTART_OS <= `HSYNCLEN_240p60 + `HBACKPORCH_240p60 - `HOVERSCAN_MAX_240p60;
          HACTIVE_OS <= `HACTIVE_240p60 + 2*`HOVERSCAN_MAX_240p60;
          HSTOP_OS <= `HSYNCLEN_240p60 + `HBACKPORCH_240p60 + `HACTIVE_240p60 + `HOVERSCAN_MAX_240p60;
          HTOTAL <= `HTOTAL_240p60;
        end
      `USE_VGAp60: begin  // VGA-60 (640x480), 4:3
          HSYNC_active <= `HSYNC_active_VGAp60;
          HSYNCLEN <= `HSYNCLEN_VGAp60;
          HSTART <= `HSYNCLEN_VGAp60 + `HBACKPORCH_VGAp60;
          HACTIVE <= `HACTIVE_VGAp60;
          HSTOP <= `HSYNCLEN_VGAp60 + `HBACKPORCH_VGAp60 + `HACTIVE_VGAp60;
          HSTART_OS <= `HSYNCLEN_VGAp60 + `HBACKPORCH_VGAp60 - `HOVERSCAN_MAX_VGAp60;
          HACTIVE_OS <= `HACTIVE_VGAp60 + 2*`HOVERSCAN_MAX_VGAp60;
          HSTOP_OS <= `HSYNCLEN_VGAp60 + `HBACKPORCH_VGAp60 + `HACTIVE_VGAp60 + `HOVERSCAN_MAX_VGAp60;
          HTOTAL <= `HTOTAL_VGAp60;
        end
      `USE_480p60: begin  // 480p-60, 4:3 / 16:9
          HSYNC_active <= `HSYNC_active_480p60;
          HSYNCLEN <= `HSYNCLEN_480p60;
          HSTART <= `HSYNCLEN_480p60 + `HBACKPORCH_480p60;
          HACTIVE <= `HACTIVE_480p60;
          HSTOP <= `HSYNCLEN_480p60 + `HBACKPORCH_480p60 + `HACTIVE_480p60;
          HSTART_OS <= `HSYNCLEN_480p60 + `HBACKPORCH_480p60 - `HOVERSCAN_MAX_480p60;
          HACTIVE_OS <= `HACTIVE_480p60 + 2*`HOVERSCAN_MAX_480p60;
          HSTOP_OS <= `HSYNCLEN_480p60 + `HBACKPORCH_480p60 + `HACTIVE_480p60 + `HOVERSCAN_MAX_480p60;
          HTOTAL <= `HTOTAL_480p60;
        end
      `USE_720p60: begin  // 720p-60, 16:9
          HSYNC_active <= `HSYNC_active_720p60;
          HSYNCLEN <= `HSYNCLEN_720p60;
          HSTART <= `HSYNCLEN_720p60 + `HBACKPORCH_720p60;
          HACTIVE <= `HACTIVE_720p60;
          HSTOP <= `HSYNCLEN_720p60 + `HBACKPORCH_720p60 + `HACTIVE_720p60;
          HSTART_OS <= `HSYNCLEN_720p60 + `HBACKPORCH_720p60 - `HOVERSCAN_MAX_720p60;
          HACTIVE_OS <= `HACTIVE_720p60 + 2*`HOVERSCAN_MAX_720p60;
          HSTOP_OS <= `HSYNCLEN_720p60 + `HBACKPORCH_720p60 + `HACTIVE_720p60 + `HOVERSCAN_MAX_720p60;
          HTOTAL <= `HTOTAL_720p60;
        end
      `USE_960p60: begin  // 960p-60, 4:3
          HSYNC_active <= `HSYNC_active_960p60;
          HSYNCLEN <= `HSYNCLEN_960p60;
          HSTART <= `HSYNCLEN_960p60 + `HBACKPORCH_960p60;
          HACTIVE <= `HACTIVE_960p60;
          HSTOP <= `HSYNCLEN_960p60 + `HBACKPORCH_960p60 + `HACTIVE_960p60;
          HSTART_OS <= `HSYNCLEN_960p60 + `HBACKPORCH_960p60 - `HOVERSCAN_MAX_960p60;
          HACTIVE_OS <= `HACTIVE_960p60 + 2*`HOVERSCAN_MAX_960p60;
          HSTOP_OS <= `HSYNCLEN_960p60 + `HBACKPORCH_960p60 + `HACTIVE_960p60 + `HOVERSCAN_MAX_960p60;
          HTOTAL <= `HTOTAL_960p60;
        end
//      `USE_1080p60: begin // 1080p-60, 16:9
//          HSYNC_active <= `HSYNC_active_1080p60;
//          HSYNCLEN <= `HSYNCLEN_1080p60;
//          HSTART <= `HSYNCLEN_1080p60 + `HBACKPORCH_1080p60;
//          HACTIVE <= `HACTIVE_1080p60;
//          HSTOP <= `HSYNCLEN_1080p60 + `HBACKPORCH_1080p60 + `HACTIVE_1080p60;
//          HSTART_OS <= `HSYNCLEN_1080p60 + `HBACKPORCH_1080p60 - `HOVERSCAN_MAX_1080p60;
//          HACTIVE_OS <= `HACTIVE_1080p60 + 2*`HOVERSCAN_MAX_1080p60;
//          HSTOP_OS <= `HSYNCLEN_1080p60 + `HBACKPORCH_1080p60 + `HACTIVE_1080p60 + `HOVERSCAN_MAX_1080p60;
//          HTOTAL <= `HTOTAL_1080p60;
//        end
      `USE_1200p60: begin // 1200p-60, 4:3
          HSYNC_active <= `HSYNC_active_1200p60;
          HSYNCLEN <= `HSYNCLEN_1200p60;
          HSTART <= `HSYNCLEN_1200p60 + `HBACKPORCH_1200p60;
          HACTIVE <= `HACTIVE_1200p60;
          HSTOP <= `HSYNCLEN_1200p60 + `HBACKPORCH_1200p60 + `HACTIVE_1200p60;
          HSTART_OS <= `HSYNCLEN_1200p60 + `HBACKPORCH_1200p60 - `HOVERSCAN_MAX_1200p60;
          HACTIVE_OS <= `HACTIVE_1200p60 + 2*`HOVERSCAN_MAX_1200p60;
          HSTOP_OS <= `HSYNCLEN_1200p60 + `HBACKPORCH_1200p60 + `HACTIVE_1200p60 + `HOVERSCAN_MAX_1200p60;
          HTOTAL <= `HTOTAL_1200p60;
        end
      `USE_1440p60: begin // 1440p-60, 4:3
          HSYNC_active <= `HSYNC_active_1440p60;
          HSYNCLEN <= `HSYNCLEN_1440p60;
          HSTART <= `HSYNCLEN_1440p60 + `HBACKPORCH_1440p60;
          HACTIVE <= `HACTIVE_1440p60;
          HSTOP <= `HSYNCLEN_1440p60 + `HBACKPORCH_1440p60 + `HACTIVE_1440p60;
          HSTART_OS <= `HSYNCLEN_1440p60 + `HBACKPORCH_1440p60 - `HOVERSCAN_MAX_1440p60;
          HACTIVE_OS <= `HACTIVE_1440p60 + 2*`HOVERSCAN_MAX_1440p60;
          HSTOP_OS <= `HSYNCLEN_1440p60 + `HBACKPORCH_1440p60 + `HACTIVE_1440p60 + `HOVERSCAN_MAX_1440p60;
          HTOTAL <= `HTOTAL_1440p60;
        end
      `USE_1440Wp60: begin  // 1440p-60, 16:9 (2x pixelrep)
          HSYNC_active <= `HSYNC_active_1440Wp60;
          HSYNCLEN <= `HSYNCLEN_1440Wp60;
          HSTART <= `HSYNCLEN_1440Wp60 + `HBACKPORCH_1440Wp60;
          HACTIVE <= `HACTIVE_1440Wp60;
          HSTOP <= `HSYNCLEN_1440Wp60 + `HBACKPORCH_1440Wp60 + `HACTIVE_1440Wp60;
          HSTART_OS <= `HSYNCLEN_1440Wp60 + `HBACKPORCH_1440Wp60 - `HOVERSCAN_MAX_1440Wp60;
          HACTIVE_OS <= `HACTIVE_1440Wp60 + 2*`HOVERSCAN_MAX_1440p60;
          HSTOP_OS <= `HSYNCLEN_1440Wp60 + `HBACKPORCH_1440Wp60 + `HACTIVE_1440Wp60 + `HOVERSCAN_MAX_1440Wp60;
          HTOTAL <= `HTOTAL_1440Wp60;
        end
      `USE_288p50: begin // 288p-50, 4:3 (2x/4x pixelrep, mode 2)
          HSYNC_active <= `HSYNC_active_288p50;
          HSYNCLEN <= `HSYNCLEN_288p50;
          HSTART <= `HSYNCLEN_288p50 + `HBACKPORCH_288p50;
          HACTIVE <= `HACTIVE_288p50;
          HSTOP <= `HSYNCLEN_288p50 + `HBACKPORCH_288p50 + `HACTIVE_288p50;
          HSTART_OS <= `HSYNCLEN_288p50 + `HBACKPORCH_288p50 - `HOVERSCAN_MAX_288p50;
          HACTIVE_OS <= `HACTIVE_288p50 + 2*`HOVERSCAN_MAX_288p50;
          HSTOP_OS <= `HSYNCLEN_288p50 + `HBACKPORCH_288p50 + `HACTIVE_288p50 + `HOVERSCAN_MAX_288p50;
          HTOTAL <= `HTOTAL_288p50;
        end
      `USE_VGAp50: begin  // VGA-50 (640x576), 4:3
          HSYNC_active <= `HSYNC_active_VGAp50;
          HSYNCLEN <= `HSYNCLEN_VGAp50;
          HSTART <= `HSYNCLEN_VGAp50 + `HBACKPORCH_VGAp50;
          HACTIVE <= `HACTIVE_VGAp50;
          HSTOP <= `HSYNCLEN_VGAp50 + `HBACKPORCH_VGAp50 + `HACTIVE_VGAp50;
          HSTART_OS <= `HSYNCLEN_VGAp50 + `HBACKPORCH_VGAp50 - `HOVERSCAN_MAX_VGAp50;
          HACTIVE_OS <= `HACTIVE_VGAp50 + 2*`HOVERSCAN_MAX_VGAp50;
          HSTOP_OS <= `HSYNCLEN_VGAp50 + `HBACKPORCH_VGAp50 + `HACTIVE_VGAp50 + `HOVERSCAN_MAX_VGAp50;
          HTOTAL <= `HTOTAL_VGAp50;
        end
      `USE_576p50: begin  // 576p-50, 4:3 / 16:9
          HSYNC_active <= `HSYNC_active_576p50;
          HSYNCLEN <= `HSYNCLEN_576p50;
          HSTART <= `HSYNCLEN_576p50 + `HBACKPORCH_576p50;
          HACTIVE <= `HACTIVE_576p50;
          HSTOP <= `HSYNCLEN_576p50 + `HBACKPORCH_576p50 + `HACTIVE_576p50;
          HSTART_OS <= `HSYNCLEN_576p50 + `HBACKPORCH_576p50 - `HOVERSCAN_MAX_576p50;
          HACTIVE_OS <= `HACTIVE_576p50 + 2*`HOVERSCAN_MAX_576p50;
          HSTOP_OS <= `HSYNCLEN_576p50 + `HBACKPORCH_576p50 + `HACTIVE_576p50 + `HOVERSCAN_MAX_576p50;
          HTOTAL <= `HTOTAL_576p50;
        end
      `USE_720p50: begin  // 720p-50, 16:9
          HSYNC_active <= `HSYNC_active_720p50;
          HSYNCLEN <= `HSYNCLEN_720p50;
          HSTART <= `HSYNCLEN_720p50 + `HBACKPORCH_720p50;
          HACTIVE <= `HACTIVE_720p50;
          HSTOP <= `HSYNCLEN_720p50 + `HBACKPORCH_720p50 + `HACTIVE_720p50;
          HSTART_OS <= `HSYNCLEN_720p50 + `HBACKPORCH_720p50 - `HOVERSCAN_MAX_720p50;
          HACTIVE_OS <= `HACTIVE_720p50 + 2*`HOVERSCAN_MAX_720p50;
          HSTOP_OS <= `HSYNCLEN_720p50 + `HBACKPORCH_720p50 + `HACTIVE_720p50 + `HOVERSCAN_MAX_720p50;
          HTOTAL <= `HTOTAL_720p50;
        end
      `USE_960p50: begin  // 960p-50, 4:3
          HSYNC_active <= `HSYNC_active_960p50;
          HSYNCLEN <= `HSYNCLEN_960p50;
          HSTART <= `HSYNCLEN_960p50 + `HBACKPORCH_960p50;
          HACTIVE <= `HACTIVE_960p50;
          HSTOP <= `HSYNCLEN_960p50 + `HBACKPORCH_960p50 + `HACTIVE_960p50;
          HSTART_OS <= `HSYNCLEN_960p50 + `HBACKPORCH_960p50 - `HOVERSCAN_MAX_960p50;
          HACTIVE_OS <= `HACTIVE_960p50 + 2*`HOVERSCAN_MAX_960p50;
          HSTOP_OS <= `HSYNCLEN_960p50 + `HBACKPORCH_960p50 + `HACTIVE_960p50 + `HOVERSCAN_MAX_960p50;
          HTOTAL <= `HTOTAL_960p50;
        end
      `USE_1080p50: begin // 1080p-50, 16:9
          HSYNC_active <= `HSYNC_active_1080p50;
          HSYNCLEN <= `HSYNCLEN_1080p50;
          HSTART <= `HSYNCLEN_1080p50 + `HBACKPORCH_1080p50;
          HACTIVE <= `HACTIVE_1080p50;
          HSTOP <= `HSYNCLEN_1080p50 + `HBACKPORCH_1080p50 + `HACTIVE_1080p50;
          HSTART_OS <= `HSYNCLEN_1080p50 + `HBACKPORCH_1080p50 - `HOVERSCAN_MAX_1080p50;
          HACTIVE_OS <= `HACTIVE_1080p50 + 2*`HOVERSCAN_MAX_1080p50;
          HSTOP_OS <= `HSYNCLEN_1080p50 + `HBACKPORCH_1080p50 + `HACTIVE_1080p50 + `HOVERSCAN_MAX_1080p50;
          HTOTAL <= `HTOTAL_1080p50;
        end
      `USE_1200p50: begin // 1200p-50, 4:3
          HSYNC_active <= `HSYNC_active_1200p50;
          HSYNCLEN <= `HSYNCLEN_1200p50;
          HSTART <= `HSYNCLEN_1200p50 + `HBACKPORCH_1200p50;
          HACTIVE <= `HACTIVE_1200p50;
          HSTOP <= `HSYNCLEN_1200p50 + `HBACKPORCH_1200p50 + `HACTIVE_1200p50;
          HSTART_OS <= `HSYNCLEN_1200p50 + `HBACKPORCH_1200p50 - `HOVERSCAN_MAX_1200p50;
          HACTIVE_OS <= `HACTIVE_1200p50 + 2*`HOVERSCAN_MAX_1200p50;
          HSTOP_OS <= `HSYNCLEN_1200p50 + `HBACKPORCH_1200p50 + `HACTIVE_1200p50 + `HOVERSCAN_MAX_1200p50;
          HTOTAL <= `HTOTAL_1200p50;
        end
      `USE_1440p50: begin // 1440p-50, 4:3
          HSYNC_active <= `HSYNC_active_1440p50;
          HSYNCLEN <= `HSYNCLEN_1440p50;
          HSTART <= `HSYNCLEN_1440p50 + `HBACKPORCH_1440p50;
          HACTIVE <= `HACTIVE_1440p50;
          HSTOP <= `HSYNCLEN_1440p50 + `HBACKPORCH_1440p50 + `HACTIVE_1440p50;
          HSTART_OS <= `HSYNCLEN_1440p50 + `HBACKPORCH_1440p50 - `HOVERSCAN_MAX_1440p50;
          HACTIVE_OS <= `HACTIVE_1440p50 + 2*`HOVERSCAN_MAX_1440p50;
          HSTOP_OS <= `HSYNCLEN_1440p50 + `HBACKPORCH_1440p50 + `HACTIVE_1440p50 + `HOVERSCAN_MAX_1440p50;
          HTOTAL <= `HTOTAL_1440p50;
        end
      `USE_1440Wp50: begin  // 1440p-50, 16:9 (2x pixelrep)
          HSYNC_active <= `HSYNC_active_1440Wp50;
          HSYNCLEN <= `HSYNCLEN_1440Wp50;
          HSTART <= `HSYNCLEN_1440Wp50 + `HBACKPORCH_1440Wp50;
          HACTIVE <= `HACTIVE_1440Wp50;
          HSTOP <= `HSYNCLEN_1440Wp50 + `HBACKPORCH_1440Wp50 + `HACTIVE_1440Wp50;
          HSTART_OS <= `HSYNCLEN_1440Wp50 + `HBACKPORCH_1440Wp50 - `HOVERSCAN_MAX_1440Wp50;
          HACTIVE_OS <= `HACTIVE_1440Wp50 + 2*`HOVERSCAN_MAX_1440Wp50;
          HSTOP_OS <= `HSYNCLEN_1440Wp50 + `HBACKPORCH_1440Wp50 + `HACTIVE_1440Wp50 + `HOVERSCAN_MAX_1440Wp50;
          HTOTAL <= `HTOTAL_1440Wp50;
        end
      default: begin// 1080p-60, 16:9
          HSYNC_active <= `HSYNC_active_1080p60;
          HSYNCLEN <= `HSYNCLEN_1080p60;
          HSTART <= `HSYNCLEN_1080p60 + `HBACKPORCH_1080p60;
          HACTIVE <= `HACTIVE_1080p60;
          HSTOP <= `HSYNCLEN_1080p60 + `HBACKPORCH_1080p60 + `HACTIVE_1080p60;
          HSTART_OS <= `HSYNCLEN_1080p60 + `HBACKPORCH_1080p60 - `HOVERSCAN_MAX_1080p60;
          HACTIVE_OS <= `HACTIVE_1080p60 + 2*`HOVERSCAN_MAX_1080p60;
          HSTOP_OS <= `HSYNCLEN_1080p60 + `HBACKPORCH_1080p60 + `HACTIVE_1080p60 + `HOVERSCAN_MAX_1080p60;
          HTOTAL <= `HTOTAL_1080p60;
        end
    endcase
  end

endtask
