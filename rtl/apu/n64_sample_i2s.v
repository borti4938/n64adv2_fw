//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the N64 RGB/YPbPr DAC project.
//
// Copyright (C) 2016-2024 by Peter Bartmann <borti4938@gmx.de>
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
// Module Name:    n64_sample_i2s.v
// Project Name:   N64 Advanced HMDI Mod
// Target Devices: Cyclone 10 LP: 10CL025YE144
// Tool versions:  Altera Quartus Prime
// Description:
//
// Revision:
// Features: see repository readme
//
//////////////////////////////////////////////////////////////////////////////////




module n64_sample_i2s (
  MCLK_i,
  nRST_i,

  // N64 Audio Input
  SCLK_i,
  SDATA_i,
  LRCLK_i,

  // Parallel Output
  PDATA_LEFT_o,
  PDATA_RIGHT_o,
  PDATA_VALID_o
);

input MCLK_i;
input nRST_i;

input SCLK_i;
input SDATA_i;
input LRCLK_i;

output reg signed [15:0] PDATA_LEFT_o = 16'h0;
output reg signed [15:0] PDATA_RIGHT_o = 16'h0;
output reg PDATA_VALID_o = 1'b0;


// wires
wire new_sample,get_sdata;
wire ch_i_sel;
wire rst_marker;

// regs
reg [2:0] SCLK_ibuf;
reg [2:0] SDATA_ibuf;
reg [2:0] LRCLK_ibuf;

reg signed [15:0] audio_lr_tmp [0:1];
reg [1:0] pdata_valid_tmp = 2'b00;

reg [3:0] bit_i_sel;
reg [1:0] ch_rd_done;

reg [7:0] cnt_256x;


// synchronize inputs with new MCLK_i

always @(posedge MCLK_i or negedge nRST_i)
  if (!nRST_i) begin
    SCLK_ibuf <= 3'b0;
    SDATA_ibuf <= 3'b0;
    LRCLK_ibuf <= 3'b0;
  end else begin
    SCLK_ibuf <= {SCLK_ibuf[1:0],SCLK_i};
    SDATA_ibuf <= {SDATA_ibuf[1:0],SDATA_i};
    LRCLK_ibuf <= {LRCLK_ibuf[1:0],LRCLK_i};
  end


// seriell to parallel conversion of inputs

// some information:
// - N64 uses a BU9480F 16bit audio DAC
// - LRCLK -> Left channel data up, right channel down
// - ASDATA in 2'compl., 16bit each channel latches on posedge of ASCLK

assign new_sample = !LRCLK_ibuf[2] & LRCLK_ibuf[1];
assign get_sdata = !SCLK_ibuf[2] & SCLK_ibuf[1];
assign ch_i_sel = LRCLK_ibuf[1];
assign rst_marker = (!LRCLK_ibuf[2] &  LRCLK_ibuf[1]) |
                    ( LRCLK_ibuf[2] & !LRCLK_ibuf[1]);

always @(posedge MCLK_i or negedge nRST_i)
  if (!nRST_i) begin
    audio_lr_tmp[1] <= 16'h0;
    audio_lr_tmp[0] <= 16'h0;
    PDATA_LEFT_o <= 16'h0;
    PDATA_RIGHT_o <= 16'h0;
    pdata_valid_tmp <= 2'b00;
    bit_i_sel <= 4'd15;
    ch_rd_done <= 2'b00;
  end else begin
    if (get_sdata & !ch_rd_done[1]) begin
      audio_lr_tmp[ch_i_sel][bit_i_sel] <= SDATA_ibuf[1];
      if (~|bit_i_sel) begin
        ch_rd_done[1] <= ch_rd_done[0];
        ch_rd_done[0] <= 1'b1;
      end
      bit_i_sel <= bit_i_sel - 1'b1;
    end
    if (rst_marker) begin
      bit_i_sel <= 4'd0;
      ch_rd_done <= 2'b00;
    end
    if (new_sample) begin
      PDATA_LEFT_o <= audio_lr_tmp[1];
      PDATA_RIGHT_o <= audio_lr_tmp[0];
      pdata_valid_tmp <= {pdata_valid_tmp[0],1'b1};
    end
  end


// generate 96kHz valid signal

always @(posedge MCLK_i or negedge nRST_i)
  if (!nRST_i) begin
    PDATA_VALID_o <= 1'b0;
    cnt_256x <= 8'h00;
  end else begin
    if (pdata_valid_tmp[1]) begin
      PDATA_VALID_o <= ~|cnt_256x;
      cnt_256x <= cnt_256x + 1'b1;
    end
  end

endmodule
