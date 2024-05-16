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
// Module Name:    n64_vinfo_ext
// Project Name:   N64 Advanced RGB/YPbPr DAC Mod
// Target Devices: universial
// Tool versions:  Altera Quartus Prime
// Description:    extracts video info from input
//
//////////////////////////////////////////////////////////////////////////////////


module n64_vinfo_ext(
  VCLK,
  nRST_unmasked,
  nRST,
  nVDSYNC,

  Sync_pre,
  Sync_cur,

  pal_boxed_mode,

  vinfo_o
);

`include "../../lib/n64adv_vparams.vh"

input VCLK;
input nRST_unmasked;
input nRST;
input nVDSYNC;

input  [3:0] Sync_pre;
input  [3:0] Sync_cur;

input [1:0] pal_boxed_mode;

output [3:0] vinfo_o;   // order: vdata_detected,pal_is_240p,palmode,n64_480i


// some pre-assignments

wire negedge_nVSYNC = Sync_pre[3] & !Sync_cur[3];
wire negedge_nHSYNC = Sync_pre[1] & !Sync_cur[1];
wire negedge_nCSYNC = Sync_pre[0] & !Sync_cur[0];


// check for video data running at all
// ===================================

reg [2:0] dsclk_cnt = 3'd0;
reg [8:0] vclk_cnt = 9'd0;
reg [9:0] hclk_cnt = 10'd0;
reg [10:0] cclk_cnt = 11'd0;
reg [3:0] vdata_detection_flags = 4'h0;
reg vdata_detected = 1'b0;

always @(posedge VCLK or negedge nRST)
  if (!nRST) begin
    dsclk_cnt <= 3'd0;
    vclk_cnt <= 9'd0;
    hclk_cnt <= 10'd0;
    cclk_cnt <= 10'd0;
    vdata_detection_flags <= 4'h0;
    vdata_detected <= 1'b0;
  end else begin
    vdata_detected <= &vdata_detection_flags[3:0];
    
    // manage detection flags (flag for dsync managed in counter section)
    if (dsclk_cnt[2]) // vdsync not detected - probably no video input running
      vdata_detection_flags[3] <= 1'b0;
    else
      vdata_detection_flags[3] <= 1'b1;
    
    if (&vclk_cnt) // vertical sync not detected - probably no video input running
      vdata_detection_flags[2] <= 1'b0;
    else
      vdata_detection_flags[2] <= 1'b1;
    
    if (&hclk_cnt) // horizontal sync not detected - probably no video input running
      vdata_detection_flags[1] <= 1'b0;
    else
      vdata_detection_flags[1] <= 1'b1;
    
    if (&cclk_cnt) // composite sync not detected - probably no video input running
      vdata_detection_flags[0] <= 1'b0;
    else
      vdata_detection_flags[0] <= 1'b1;
    
    // check for inputs and manage timeouts
    if (!nVDSYNC)
      dsclk_cnt <= 3'd0;
    else
      dsclk_cnt <= &dsclk_cnt ? dsclk_cnt : dsclk_cnt + 3'd1;  // saturate at 7
    
    if (!nVDSYNC) begin
      if (negedge_nVSYNC)
        vclk_cnt <= 9'd0;
      else if (negedge_nHSYNC)
        vclk_cnt <= &vclk_cnt ? vclk_cnt : vclk_cnt + 9'd1;  // saturate at 511
      else
        vclk_cnt <= vclk_cnt;
      
      if (negedge_nHSYNC)
        hclk_cnt <= 10'd0;
      else
        hclk_cnt <= &hclk_cnt ? hclk_cnt : hclk_cnt + 10'd1;  // saturate at 1023
      
      if (negedge_nCSYNC)
        cclk_cnt <= 11'd0;
      else
        cclk_cnt <= &cclk_cnt ? cclk_cnt : cclk_cnt + 11'd1;  // saturate at 2047
    end
  end


// estimation of 240p/288p
// =======================

reg field_id  = 1'b1; // 0 = even frame, 1 = odd frame; 240p: only even or only odd frames; 480i: even and odd frames
reg n64_480i  = 1'b1; // 0 = 240p/288p , 1= 480i/576i

always @(posedge VCLK or negedge nRST)
  if (!nRST) begin
    field_id  <= 1'b1;
    n64_480i <= 1'b1;
  end else begin
    if (!nVDSYNC) begin
      if (negedge_nVSYNC) begin 
        field_id <= negedge_nHSYNC;
        n64_480i <= field_id ^ negedge_nHSYNC;
      end
    end
  end


// determine vmode
// ===============

reg [1:0] line_cnt = 2'b00; // PAL: line_cnt[1:0] == 0x ; NTSC: line_cnt[1:0] = 1x
reg        palmode = 1'b0;  // PAL: palmode == 1        ; NTSC: palmode == 0

always @(posedge VCLK or negedge nRST)
  if (!nRST) begin
    line_cnt <= 2'b00;
    palmode  <= 1'b0;
  end else begin
    if (!nVDSYNC) begin
      if(negedge_nVSYNC) begin // reset line_cnt and set palmode
        line_cnt <= 2'b00;
        palmode  <= ~line_cnt[1];
      end else if(negedge_nHSYNC) // new line -> increase line_cnt
        line_cnt <= line_cnt + 1'b1;
    end
  end


// check for 240p in PAL mode (must use a non-masked reset)
// ========================================================

reg palmode_pre = 1'b0;
reg [3:0] pal_288p_sense_cnt = 4'h0;
reg pal_is_240p = 1'b1;
reg pal_in_240p_box = 1'b1;

always @(posedge VCLK or negedge nRST_unmasked)
  if (!nRST_unmasked) begin
    palmode_pre <= 1'b0;
    pal_288p_sense_cnt <= 4'h0;
    pal_is_240p <= 1'b1;
    pal_in_240p_box <= 1'b1;
  end else begin
    if (palmode) begin
      if ((vclk_cnt > `VSTART_PAL_LX1) && (vclk_cnt < `VSTART_PAL_LX1 + 24)) begin
        if (nVDSYNC && |Sync_cur && (pal_288p_sense_cnt < 4'hf))
          pal_288p_sense_cnt <= pal_288p_sense_cnt + 4'b1;
      end else begin
        if (&pal_288p_sense_cnt) pal_is_240p <= 1'b0;
        pal_288p_sense_cnt <= 4'd0;
      end
    end
    if (palmode_pre != palmode)
      pal_is_240p <= 1'b1;
    palmode_pre <= palmode;
    
    if (^pal_boxed_mode) pal_in_240p_box <= pal_boxed_mode[0];
    else                 pal_in_240p_box <= pal_is_240p;
  end


// pack vinfo_o vector
// ===================

assign vinfo_o = {vdata_detected,pal_in_240p_box,palmode,n64_480i};

endmodule
