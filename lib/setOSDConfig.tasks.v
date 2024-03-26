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
// V-file Name:    setOSDConfig.tasks.v
// Project Name:   N64 Advanced Mod
// Target Devices: several devices
// Tool versions:  Altera Quartus Prime
// Description:
//
//////////////////////////////////////////////////////////////////////////////////


task setOSDConfig;
  input [`VID_CFG_W-1:0] videomode;
  
  output [2:0] osd_vscale;
  output [1:0] osd_hscale;
  output [10:0] osd_voffset;
  output [11:0] osd_hoffset;
  
  begin
    case (cfg_videomode)
      `USE_240p60: begin
          cfg_osd_vscale <= 3'b000;
          cfg_osd_hscale <= 2'b00;
          cfg_osd_voffset <=  36;   // (`VSYNCLEN_240p60 + `VBACKPORCH_240p60 + (`VACTIVE_240p60 - `OSD_WINDOW_VACTIVE)/2)
                                    // = (3 + 15 + (240 - 205)/2) = 35,5
          cfg_osd_hoffset <=  262;  // `HSYNCLEN_240p60 + `HBACKPORCH_240p60 + (`HACTIVE_240p60 - `OSD_WINDOW_HACTIVE)/2
                                    // = (96 + 45 + (640-399)/2) = 261,5
         end
      `USE_VGAp60: begin
          cfg_osd_vscale <= 3'b001;
          cfg_osd_hscale <= 2'b00;
          cfg_osd_voffset <=  35;   // (`VSYNCLEN_VGAp60 + `VBACKPORCH_VGAp60 + (`VACTIVE_VGAp60 - 2*`OSD_WINDOW_VACTIVE)/2)/2
                                    // = (2 + 33 +(480 - 2*205)/2)/2 = 35
          cfg_osd_hoffset <=  264;  // `HSYNCLEN_VGAp60 + `HBACKPORCH_VGAp60 + (`HACTIVE_VGAp60 - `OSD_WINDOW_HACTIVE)/2
                                    // = 96 + 48 + (640-399)/2 = 264,5
         end
      `USE_480p60: begin
          cfg_osd_vscale <= 3'b001;
          cfg_osd_hscale <= 2'b00;
          cfg_osd_voffset <= 35;  // (`VSYNCLEN_480p60 + `VBACKPORCH_480p60 + (`VACTIVE_480p60 - 2*`OSD_WINDOW_VACTIVE)/2)/2
                                  // = (6 + 30 + (480 - 2*205)/2)/2 = 35,5
          cfg_osd_hoffset <= 282; // `HSYNCLEN_480p60 + `HBACKPORCH_480p60 + (`HACTIVE_480p60 - `OSD_WINDOW_HACTIVE)/2
                                  // = 62 + 60 + (720 - 399)/2 = 282,5
         end
      `USE_720p60: begin
          cfg_osd_vscale <= 3'b010;
          cfg_osd_hscale <= 2'b01;
          cfg_osd_voffset <= 25;  // (`VSYNCLEN_720p60 + `VBACKPORCH_720p60 + (`VACTIVE_720P60 - 3*`OSD_WINDOW_VACTIVE)/2)/3;
                                  // = (5 + 20 + (720 - 3*205)/2)/3 = 25,83
          cfg_osd_hoffset <= 250; // (`HSYNCLEN_720p60 + `HBACKPORCH_720p60 + (`HACTIVE_720P60 - 2*`OSD_WINDOW_HACTIVE)/2)/2
                                  // = (40 + 220 + (1280 - 2*399)/2)/2 = 250,5
         end
      `USE_960p60: begin
          cfg_osd_vscale <= 3'b011;
          cfg_osd_hscale <= 2'b01;
          cfg_osd_voffset <= 24;  // (`VSYNCLEN_960p60 + `VBACKPORCH_960p60 + (`VACTIVE_960P60 - 5*`OSD_WINDOW_VACTIVE)/2)/4;
                                  // = (4 + 21 + (960 - 4*205)/2)/4 = 23,75
          cfg_osd_hoffset <= 176; // (`HSYNCLEN_960p60 + `HBACKPORCH_960p60 + (`HACTIVE_960P60 - 2*`OSD_WINDOW_HACTIVE)/2)/2
                                  // = (32 + 80 + (1280 - 2*399)/2)/2 = 176,5
         end
//      `USE_1080p60: begin
//          cfg_osd_vscale <= 3'b100;
//          cfg_osd_hscale <= 2'b10;
//          cfg_osd_voffset <= 14;  // (`VSYNCLEN_1080p60 + `VBACKPORCH_1080p60 + (`VACTIVE_1080P60 - 5*`OSD_WINDOW_VACTIVE)/2)/5
//                                  // = (5 + 36 + (1080 - 5*205)/2)/5 = 13,7
//          cfg_osd_hoffset <= 184; // (`HSYNCLEN_1080p60 + `HBACKPORCH_1080p60 + (`HACTIVE_1080P60 - 3*`OSD_WINDOW_HACTIVE)/2)/3
//                                  // = (44 + 148 + (1920 - 3*399)/2)/3 = 184,5
//         end
      `USE_1200p60: begin
          cfg_osd_vscale <= 3'b100;
          cfg_osd_hscale <= 2'b10;
          cfg_osd_voffset <= 24;  // (`VSYNCLEN_1200p60 + `VBACKPORCH_1200p60 + (`VACTIVE_1200P60 - 5*`OSD_WINDOW_VACTIVE)/2)/5
                                  // = (4 + 28 + (1200 - 5*205)/2)/5 = 23,9
          cfg_osd_hoffset <= 104; // (`HSYNCLEN_1200p60 + `HBACKPORCH_1200p60 + (`HACTIVE_1200P60 - 3*`OSD_WINDOW_HACTIVE)/2)/3
                                  // = (32 + 80 + (1600 - 3*399)/2)/3 = 104,5
         end
      `USE_1440p60: begin
          cfg_osd_vscale <= 3'b101;
          cfg_osd_hscale <= 2'b10;
          cfg_osd_voffset <= 20;  // (`VSYNCLEN_1440p60 + `VBACKPORCH_1440p60 + (`VACTIVE_1440p60 - 6*`OSD_WINDOW_VACTIVE)/2)/6
                                  // = (8 + 6 + (1440 - 6*205)/2)/6 = 19,83
          cfg_osd_hoffset <= 145; // (`HSYNCLEN_1440p60 + `HBACKPORCH_1440p60 + (`HACTIVE_1440p60 - 3*`OSD_WINDOW_HACTIVE)/2)/3
                                  // = (32 + 40 + (1920 - 3*399)/2)/3 = 144,5
         end
      `USE_1440Wp60: begin
          cfg_osd_vscale <= 3'b101;
          cfg_osd_hscale <= 2'b01;
          cfg_osd_voffset <= 24;  // (`VSYNCLEN_1440Wp60 + `VBACKPORCH_1440Wp60 + (`VACTIVE_1440Wp60 - 6*`OSD_WINDOW_VACTIVE)/2)/6
                                  // = (5 + 33 + (1440 - 6*205)/2)/6 = 23,83
          cfg_osd_hoffset <= 149; // (`HSYNCLEN_1440Wp60 + `HBACKPORCH_1440Wp60 + (`HACTIVE_1440Wp60 - 2*`OSD_WINDOW_HACTIVE)/2)/2
                                  // = (16 + 40 + (1280 - 2*399)/2)/2 = 148,5
         end
      `USE_288p50: begin
          cfg_osd_vscale <= 3'b000;
          cfg_osd_hscale <= 2'b00;
          cfg_osd_voffset <=  64;   // (`VSYNCLEN_288p50 + `VBACKPORCH_288p50 + (`VACTIVE_288p50 - `OSD_WINDOW_VACTIVE)/2)
                                    // = (3 + 19 + (288 - 205)/2) = 63,5
          cfg_osd_hoffset <=  275;  // `HSYNCLEN_288p50 + `HBACKPORCH_288p50 + (`HACTIVE_288p50 - `OSD_WINDOW_HACTIVE)/2
                                    // = (98 + 56 + (640-399)/2) = 274,5
         end
      `USE_VGAp50: begin
          cfg_osd_vscale <= 3'b001;
          cfg_osd_hscale <= 2'b00;
          cfg_osd_voffset <=  63;   // (`VSYNCLEN_VGAp50 + `VBACKPORCH_VGAp50 + (`VACTIVE_VGAp50 - 2*`OSD_WINDOW_VACTIVE)/2)/2
                                    // = (2 + 41 +(576 - 2*205)/2)/2 = 63
          cfg_osd_hoffset <=  272;  // `HSYNCLEN_VGAp50 + `HBACKPORCH_VGAp50 + (`HACTIVE_VGAp50 - `OSD_WINDOW_HACTIVE)/2
                                    // = 96 + 56 + (640-399)/2 = 272,5
         end
      `USE_576p50: begin
          cfg_osd_vscale <= 3'b001;
          cfg_osd_hscale <= 2'b00;
          cfg_osd_voffset <= 64;  // (`VSYNCLEN_576p50 + `VBACKPORCH_576p50 + (`VACTIVE_576p50 - 2*`OSD_WINDOW_VACTIVE)/2)/2
                                  // = (5 + 39 + (576 - 2*205)/2)/2 = 63,5
          cfg_osd_hoffset <= 292; // `HSYNCLEN_576p50 + `HBACKPORCH_576p50 + (`HACTIVE_576p50 - `OSD_WINDOW_HACTIVE)/2
                                  // = 64 + 68 + (720 - 399)/2 = 292,5
         end
      `USE_720p50: begin
          cfg_osd_vscale <= 3'b010;
          cfg_osd_hscale <= 2'b01;
          cfg_osd_voffset <= 26;  // (`VSYNCLEN_720p50 + `VBACKPORCH_720p50 + (`VACTIVE_720P50 - 3*`OSD_WINDOW_VACTIVE)/2)/3;
                                  // = (5 + 20 + (720 - 3*205)/2)/3 = 25,83
          cfg_osd_hoffset <= 250; // (`HSYNCLEN_720p50 + `HBACKPORCH_720p50 + (`HACTIVE_720P50 - 2*`OSD_WINDOW_HACTIVE)/2)/2
                                  // = (40 + 220 + (1280 - 2*399)/2)/2 = 250,5
         end
      `USE_960p50: begin
          cfg_osd_vscale <= 3'b011;
          cfg_osd_hscale <= 2'b01;
          cfg_osd_voffset <= 24;  // (`VSYNCLEN_960p50 + `VBACKPORCH_960p50 + (`VACTIVE_960P50 - 2*`OSD_WINDOW_VACTIVE)/2)/2;
                                  // = (4 + 21 + (960 - 4*205)/2)/4 = 23,75
          cfg_osd_hoffset <= 176; // (`HSYNCLEN_960p50 + `HBACKPORCH_960p50 + (`HACTIVE_960P50 - 2*`OSD_WINDOW_HACTIVE)/2)/2
                                  // = (32 + 80 + (1280 - 2*399)/2)/2 = 176,5
         end
      `USE_1080p50: begin
          cfg_osd_vscale <= 3'b100;
          cfg_osd_hscale <= 2'b10;
          cfg_osd_voffset <= 14;  // (`VSYNCLEN_1080p50 + `VBACKPORCH_1080p50 + (`VACTIVE_1080P50 - 5*`OSD_WINDOW_VACTIVE)/2)/5
                                  // = (5 + 36 + (1080 - 5*205)/2)/5 = 13,7
          cfg_osd_hoffset <= 184; // (`HSYNCLEN_1080p50 + `HBACKPORCH_1080p50 + (`HACTIVE_1080P50 - 3*`OSD_WINDOW_HACTIVE)/2)/3
                                  // = (44 + 148 + (1920 - 3*399)/2)/3 = 184,5
         end
      `USE_1200p50: begin
          cfg_osd_vscale <= 3'b100;
          cfg_osd_hscale <= 2'b10;
          cfg_osd_voffset <= 24;  // (`VSYNCLEN_1200p50 + `VBACKPORCH_1200p50 + (`VACTIVE_1200P50 - 5*`OSD_WINDOW_VACTIVE)/2)/5
                                  // = (4 + 28 + (1200 - 5*205)/2)/5 = 23,9
          cfg_osd_hoffset <= 104;  // (`HSYNCLEN_1200p50 + `HBACKPORCH_1200p50 + (`HACTIVE_1200P50 - 3*`OSD_WINDOW_HACTIVE)/2)/3
                                  // = (32 + 80 + (1600 - 3*399)/2)/3 = 104,5
         end
      `USE_1440p50: begin
          cfg_osd_vscale <= 3'b101;
          cfg_osd_hscale <= 2'b10;
          cfg_osd_voffset <= 20;  // (`VSYNCLEN_1440p50 + `VBACKPORCH_1440p50 + (`VACTIVE_1440p50 - 6*`OSD_WINDOW_VACTIVE)/2)/6
                                  // = (8 + 6 + (1440 - 6*205)/2)/6 = 19,83
          cfg_osd_hoffset <= 145; // (`HSYNCLEN_1440p50 + `HBACKPORCH_1440p50 + (`HACTIVE_1440p50 - 3*`OSD_WINDOW_HACTIVE)/2)/3
                                  // = (32 + 40 + (1920 - 3*399)/2)/3 = 144,5
         end
      `USE_1440Wp50: begin
          cfg_osd_vscale <= 3'b101;
          cfg_osd_hscale <= 2'b01;
          cfg_osd_voffset <= 24;  // (`VSYNCLEN_1440Wp50 + `VBACKPORCH_1440Wp50 + (`VACTIVE_1440Wp50 - 6*`OSD_WINDOW_VACTIVE)/2)/6
                                  // = (5 + 33 + (1440 - 6*205)/2)/6 = 23,83
          cfg_osd_hoffset <= 149; // (`HSYNCLEN_1440Wp50 + `HBACKPORCH_1440Wp50 + (`HACTIVE_1440Wp50 - 2*`OSD_WINDOW_HACTIVE)/2)/2
                                  // = (16 + 40 + (1280 - 2*399)/2)/2 = 148,5
         end
      default: begin
          cfg_osd_vscale <= 3'b100;
          cfg_osd_hscale <= 2'b10;
          cfg_osd_voffset <= 14;  // (`VSYNCLEN_1080p60 + `VBACKPORCH_1080p60 + (`VACTIVE_1080P60 - 5*`OSD_WINDOW_VACTIVE)/2)/5
                                  // = (5 + 36 + (1080 - 5*205)/2)/5 = 13,7
          cfg_osd_hoffset <= 184; // (`HSYNCLEN_1080p60 + `HBACKPORCH_1080p60 + (`HACTIVE_1080P60 - 3*`OSD_WINDOW_HACTIVE)/2)/3
                                  // = (44 + 148 + (1920 - 3*399)/2)/3 = 184,5
        end
    endcase
  end
endtask
