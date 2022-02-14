//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the N64 RGB/YPbPr DAC project.
//
// Copyright (C) 2016-2022 by Peter Bartmann <borti4938@gmx.de>
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
// Module Name:    i2s_leftjustified_tx
// Project Name:   N64 Advanced HMDI Mod
// Target Devices: Cyclone 10 LP: 10CL025YE144
// Tool versions:  Altera Quartus Prime
// Description:
//
// Dependencies:
// (more dependencies may appear in other files)
//
// Revision:
// Features: see repository readme
//
//////////////////////////////////////////////////////////////////////////////////



module i2s_leftjustified_tx (
  MCLK_i,
  nRST_i,

  // Parallel Input
  PDATA_LEFT_i,
  PDATA_RIGHT_i,
  PDATA_VALID_i,

  // Seriell Audio Output
  SCLK_o,
  SDATA_o,
  LRCLK_o
);

input MCLK_i;
input nRST_i;

input [23:0] PDATA_LEFT_i;
input [23:0] PDATA_RIGHT_i;
input PDATA_VALID_i;

output reg SCLK_o;
output reg SDATA_o;
output reg LRCLK_o;


// regs
reg signed [23:0] audio_lr_i [0:1];
reg trigger_tx;

reg init_begin = 1'b1;
reg [7:0] cnt_256x = 8'h00;

reg signed [31:0] audio_lr_o_tmp [0:1];

reg ch_o_sel = 1'b0;
reg [4:0] bit_o_sel = 5'd31;


// input reg - store valid values for transmitter

always @(posedge MCLK_i or negedge nRST_i)
  if (!nRST_i) begin
    audio_lr_i[1] <= {24{1'b0}};
    audio_lr_i[0] <= {24{1'b0}};
    trigger_tx <= 1'b0;
  end else begin
    if (PDATA_VALID_i) begin
      audio_lr_i[1] <= PDATA_LEFT_i;
      audio_lr_i[0] <= PDATA_RIGHT_i;
      trigger_tx <= 1'b1;
    end
  end


// I2S transmitter

// some information:
// - 24.576MHz = 512 x 48kHz audio
// - left justified audio timing
//   o LRCLK up for left channel, down for right channel
//   o 256 MCLKs per section
// - 32bit for each channel
//   o 32 clocks per LRCLK edge change
//   o negedge alligned with LRCLK edge
//   o each bit alligned with negedge, i.e. stable at posedge for receiver
//   o 4 MCLKs per SCLK section

always @(posedge MCLK_i or negedge nRST_i)
  if (!nRST_i) begin
    init_begin <= 1'b1;
    cnt_256x <= 8'h00;
    audio_lr_o_tmp[1] <= 32'h0;
    audio_lr_o_tmp[0] <= 32'h0;
    ch_o_sel <= 1'b0;
    bit_o_sel <= 5'd31;
    SCLK_o <= 1'b1;
    SDATA_o <= 1'b0;
    LRCLK_o <= 1'b0;
  end else begin
    if (~|cnt_256x[1:0])
      SCLK_o <= ~SCLK_o;
    if (~|cnt_256x[2:0]) begin
      SDATA_o <= audio_lr_o_tmp[ch_o_sel][bit_o_sel];
      bit_o_sel <= bit_o_sel - 1'b1;
    end
    if (~|cnt_256x)
      LRCLK_o <= ~LRCLK_o;

    if (&cnt_256x) begin
      if (!ch_o_sel) begin
        audio_lr_o_tmp[1] = {audio_lr_i[1],{8{audio_lr_i[1][0]}}};
        audio_lr_o_tmp[0] = {audio_lr_i[0],{8{audio_lr_i[0][0]}}};
      end
      ch_o_sel <= ~ch_o_sel;
      bit_o_sel <= 5'd31;
    end

    cnt_256x <= cnt_256x + 1'b1;

    if (init_begin) begin
      init_begin <= 1'b0;
      cnt_256x <= 8'h00;

      audio_lr_o_tmp[1] = {audio_lr_i[1],{8{audio_lr_i[1][0]}}};
      audio_lr_o_tmp[0] = {audio_lr_i[0],{8{audio_lr_i[0][0]}}};
      ch_o_sel <= 1'b1;
      bit_o_sel <= 5'd31;

      SCLK_o <= 1'b1;
      SDATA_o <= 1'b0;
      LRCLK_o <= 1'b0;
    end

    if (!trigger_tx) begin
      init_begin <= 1'b1;
      SCLK_o <= 1'b1;
      SDATA_o <= 1'b0;
      LRCLK_o <= 1'b0;
    end
  end

endmodule
