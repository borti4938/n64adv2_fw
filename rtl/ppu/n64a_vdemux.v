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
// Company:  Circuit-Board.de
// Engineer: borti4938
//
// Module Name:    n64a_vdemux
// Project Name:   N64 Advanced RGB/YPbPr DAC Mod
// Target Devices: Cyclone IV and Cyclone 10 LP devices
// Tool versions:  Altera Quartus Prime
// Description:    demux the video data from the input data stream
//
// Dependencies: vh/n64a_params.vh
//
//////////////////////////////////////////////////////////////////////////////////


module n64a_vdemux(
  VCLK,
  nRST,
  nVDSYNC,

  VD_i,
  demuxparams_i,

  vdata_valid_0,
  vdata_r_sy_0,
  vdata_valid_1,
  vdata_r_1
);

`include "../../lib/n64adv_vparams.vh"

input VCLK;
input nRST;
input nVDSYNC;

input  [color_width_i-1:0] VD_i;
input  [              2:0] demuxparams_i;

output reg vdata_valid_0 = 1'b0;
output [`VDATA_I_SY_SLICE] vdata_r_sy_0;
output reg vdata_valid_1 = 1'b0;
output reg [`VDATA_I_FU_SLICE] vdata_r_1 = {vdata_width_i{1'b0}}; // (unpacked array types in ports requires system verilog)


// unpack demux info

wire palmode     = demuxparams_i[  2];
wire ndo_deblur  = demuxparams_i[  1];
wire n16bit_mode = demuxparams_i[  0];

wire posedge_nCSYNC = !vdata_r_0[3*color_width_i] &  VD_i[0];


// start of rtl

reg [1:0] data_cnt = 2'b00;
reg nblank_rgb = 1'b1;
reg [`VDATA_I_FU_SLICE] vdata_r_0 = {vdata_width_i{1'b0}}; // buffer for sync, red, green and blue


always @(posedge VCLK or negedge nRST)  // data register management
  if (!nRST)
    data_cnt <= 2'b00;
  else begin
    if (!nVDSYNC)
      data_cnt <= 2'b01;  // reset data counter
    else
      data_cnt <= data_cnt + 1'b1;  // increment data counter
  end


always @(posedge VCLK or negedge nRST)
  if (!nRST) begin
    nblank_rgb <= 1'b1;
  end else if (!nVDSYNC) begin
    if (ndo_deblur) begin
      nblank_rgb <= 1'b1;
    end else begin
      if(posedge_nCSYNC) // posedge nCSYNC -> reset blanking
        nblank_rgb <= palmode;
      else
        nblank_rgb <= ~nblank_rgb;
    end
  end


always @(posedge VCLK or negedge nRST) // data register management
  if (!nRST) begin
    vdata_valid_0 <= 1'b0;
    vdata_r_0 <= {vdata_width_i{1'b0}};
    vdata_valid_1 <= 1'b0;
    vdata_r_1 <= {vdata_width_i{1'b0}};
  end else begin
    vdata_valid_0 <= 1'b0;
    vdata_valid_1 <= 1'b0;
    if (!nVDSYNC) begin
      vdata_valid_1 <= 1'b1; // set also valid flag for 
      // shift data to output registers
      vdata_r_1[`VDATA_I_SY_SLICE] <= vdata_r_0[`VDATA_I_SY_SLICE];
      if (nblank_rgb)  // deblur active: pass RGB only if not blanked
        vdata_r_1[`VDATA_I_CO_SLICE] <= vdata_r_0[`VDATA_I_CO_SLICE];

      // get new sync data
      vdata_valid_0 <= 1'b1;
      vdata_r_0[`VDATA_I_SY_SLICE] <= VD_i[3:0];
    end else begin
      // demux of RGB
      case(data_cnt)
        2'b01: vdata_r_0[`VDATA_I_RE_SLICE] <= n16bit_mode ? VD_i : {VD_i[6:2], 2'b00};
        2'b10: vdata_r_0[`VDATA_I_GR_SLICE] <= n16bit_mode ? VD_i : {VD_i[6:1], 1'b0};
        2'b11: vdata_r_0[`VDATA_I_BL_SLICE] <= n16bit_mode ? VD_i : {VD_i[6:2], 2'b00};
      endcase
    end
  end
  
assign vdata_r_sy_0 = vdata_r_0[`VDATA_I_SY_SLICE];

endmodule
