//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the N64 RGB/YPbPr DAC project.
//
// Copyright (C) 2015-2022 by Peter Bartmann <borti4938@gmail.com>
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
// Module Name:    scanline_emu
// Project Name:   N64 Advanced
// Target Devices: 
// Tool versions:  Altera Quartus Prime
// Description:    
//
//////////////////////////////////////////////////////////////////////////////////


module scanline_emu (
  VCLK_i,
  nVRST_i,

  HSYNC_i,
  VSYNC_i,
  DE_i,
  vdata_i,
  
  sl_en_i,
  sl_per_channel_i,
  sl_thickness_i,
  sl_profile_i,
  sl_rel_pos_i,
  sl_strength_i,
  sl_bloom_i,
  
  HSYNC_o,
  VSYNC_o,
  DE_o,
  vdata_o

);

`include "../../lib/n64adv_vparams.vh"

`include "../../lib/getScanlineProfile.tasks.v"

input VCLK_i;
input nVRST_i;

input HSYNC_i;
input VSYNC_i;
input DE_i;
input [`VDATA_O_CO_SLICE] vdata_i;

input sl_en_i;
input sl_per_channel_i;
input [1:0] sl_thickness_i;
input [1:0] sl_profile_i;
input [7:0] sl_rel_pos_i; // used to correct scanline strength value
input [7:0] sl_strength_i;
input [4:0] sl_bloom_i;

output reg HSYNC_o;
output reg VSYNC_o;
output reg DE_o;
output reg [`VDATA_O_CO_SLICE] vdata_o;


// misc
localparam proc_stages = 10;

localparam [7:0] sl_profile_width = 8'b01000000;
localparam [7:0] sl_half_profile_width = 8'b00100000;
localparam [7:0] val_0p5 = 8'b10000000;
localparam [7:0] val_0p25 = 8'b01000000;
localparam [7:0] val_0p1875 = 8'b00110000;
localparam [7:0] val_0p125 = 8'b00100000;
localparam [7:0] val_0p0625 = 8'b00010000;

localparam SL_bloom_calc_width = 8; // do not change this localparam!

integer int_idx;


// wires
wire [7:0] red_i_w, green_i_w, blue_i_w;

wire [7:0] sl_adapt_val_R_w, sl_adapt_val_G_w, sl_adapt_val_B_w;
wire [15:0] SL_str_corrected_R_4L_full_w, SL_str_corrected_G_4L_full_w, SL_str_corrected_B_4L_full_w;

wire [color_width_o+5:0] Rval_ref_pre_full_3L_w, Gval_ref_pre_full_3L_w, Bval_ref_pre_full_3L_w;
wire [color_width_o+SL_bloom_calc_width:0] Rval_ref_full_5L_w, Gval_ref_full_5L_w, Bval_ref_full_5L_w;
wire [color_width_o+SL_bloom_calc_width-1:0] R_sl_full_w, G_sl_full_w, B_sl_full_w;


// regs
reg [proc_stages-2:0] HSYNC_L, VSYNC_L, DE_L  /* synthesis ramstyle = "logic" */;
reg [color_width_o-1:0] R_L [0:proc_stages-2] /* synthesis ramstyle = "logic" */;
reg [color_width_o-1:0] G_L [0:proc_stages-2] /* synthesis ramstyle = "logic" */;
reg [color_width_o-1:0] B_L [0:proc_stages-2] /* synthesis ramstyle = "logic" */;

reg [color_width_o:0] RpB_L;
reg [color_width_o:0] Rref_L [1:2];
reg [color_width_o:0] Gref_L [1:2];
reg [color_width_o:0] Bref_L [1:2];

reg [proc_stages-2:2] drawSL_R, drawSL_G, drawSL_B  /* synthesis ramstyle = "logic" */;
reg [3:2] max_SL_str_R, max_SL_str_G, max_SL_str_B;
reg [7:0] SL_str_corrected_L [0:1];
reg [7:0] SL_str_corrected_R_L [2:5];
reg [7:0] SL_str_corrected_G_L [2:5];
reg [7:0] SL_str_corrected_B_L [2:5];

reg [color_width_o:0] Rval_ref_pre_L [3:4];
reg [color_width_o:0] Gval_ref_pre_L [3:4];
reg [color_width_o:0] Bval_ref_pre_L [3:4];
reg [color_width_o:0] Rval_ref_5L, Gval_ref_5L, Bval_ref_5L;

reg [SL_bloom_calc_width-1:0] SL_bloomed_rval_R_6L, SL_bloomed_rval_G_6L, SL_bloomed_rval_B_6L;
reg [SL_bloom_calc_width-1:0] SL_bloomed_str_R_7L, SL_bloomed_str_G_7L, SL_bloomed_str_B_7L;

reg [color_width_o-1:0] R_sl_8L, G_sl_8L ,B_sl_8L;


// begin of rtl
assign red_i_w = vdata_i[`VDATA_O_RE_SLICE];
assign green_i_w = vdata_i[`VDATA_O_GR_SLICE];
assign blue_i_w = vdata_i[`VDATA_O_BL_SLICE];

// delay stages due to post processing pipeline
always @(posedge VCLK_i or negedge nVRST_i)
  if (!nVRST_i) begin
    HSYNC_L <= {(proc_stages-1){1'b0}};
    VSYNC_L <= {(proc_stages-1){1'b0}};
    DE_L <= {(proc_stages-1){1'b0}};
    for (int_idx = 0; int_idx < proc_stages-1; int_idx = int_idx + 1) begin
      R_L[int_idx] <= {color_width_o{1'b0}};
      G_L[int_idx] <= {color_width_o{1'b0}};
      B_L[int_idx] <= {color_width_o{1'b0}};
    end
  end else begin
    HSYNC_L <= {HSYNC_L[proc_stages-3:0],HSYNC_i};
    VSYNC_L <= {VSYNC_L[proc_stages-3:0],VSYNC_i};
    DE_L <= {DE_L[proc_stages-3:0],DE_i};
    for (int_idx = 1; int_idx < proc_stages-1; int_idx = int_idx + 1) begin
      R_L[int_idx] <= R_L[int_idx-1];
      G_L[int_idx] <= G_L[int_idx-1];
      B_L[int_idx] <= B_L[int_idx-1];
    end
    R_L[0] <= red_i_w;
    G_L[0] <= green_i_w;
    B_L[0] <= blue_i_w;
  end

// calculate an approximation for luma / get reference for red, green and blue scanline adaptation
always @(posedge VCLK_i or negedge nVRST_i)
  if (!nVRST_i) begin
    RpB_L <= {(color_width_o+1){1'b0}};
    Rref_L[1] = {(color_width_o+1){1'b0}};
    Gref_L[1] = {(color_width_o+1){1'b0}};
    Bref_L[1] = {(color_width_o+1){1'b0}};
    Rref_L[2] = {(color_width_o+1){1'b0}};
    Gref_L[2] = {(color_width_o+1){1'b0}};
    Bref_L[2] = {(color_width_o+1){1'b0}};
  end else begin
    RpB_L <= {1'b0,red_i_w} + {1'b0,blue_i_w};  // to pp-stage [0]
    
    Rref_L[1] <= sl_per_channel_i ? {R_L[0],1'b0} : {1'b0,G_L[0]} + {1'b0,RpB_L[color_width_o:1]}; // to pp-stage [1]
    Gref_L[1] <= sl_per_channel_i ? {G_L[0],1'b0} : {1'b0,G_L[0]} + {1'b0,RpB_L[color_width_o:1]}; // to pp-stage [1]
    Bref_L[1] <= sl_per_channel_i ? {B_L[0],1'b0} : {1'b0,G_L[0]} + {1'b0,RpB_L[color_width_o:1]}; // to pp-stage [1]
    
    Rref_L[2] <= Rref_L[1]; // to pp-stage [2]
    Gref_L[2] <= Gref_L[1]; // to pp-stage [2]
    Bref_L[2] <= Bref_L[1]; // to pp-stage [2]
  end

// strength correction first depending on profile
// method also generates drawSL indicator
assign sl_adapt_val_R_w = {2'b00, Rref_L[1][color_width_o:color_width_o-5]} + Rref_L[1][color_width_o-6];  // values between 0 (min red)  and 0.25 (max red)
assign sl_adapt_val_G_w = {2'b00, Gref_L[1][color_width_o:color_width_o-5]} + Gref_L[1][color_width_o-6];  // values between 0 (min green) and 0.25 (max green)
assign sl_adapt_val_B_w = {2'b00, Bref_L[1][color_width_o:color_width_o-5]} + Bref_L[1][color_width_o-6];  // values between 0 (min blue)  and 0.25 (max blue)
assign SL_str_corrected_R_4L_full_w = SL_str_corrected_R_L[3] * (* multstyle = "dsp" *) sl_strength_i;
assign SL_str_corrected_G_4L_full_w = SL_str_corrected_G_L[3] * (* multstyle = "dsp" *) sl_strength_i;
assign SL_str_corrected_B_4L_full_w = SL_str_corrected_B_L[3] * (* multstyle = "dsp" *) sl_strength_i;

always @(posedge VCLK_i) begin
  for (int_idx = 4; int_idx < proc_stages-1; int_idx = int_idx + 1) begin
    drawSL_R[int_idx] <= drawSL_R[int_idx-1];
    drawSL_G[int_idx] <= drawSL_G[int_idx-1];
    drawSL_B[int_idx] <= drawSL_B[int_idx-1];
  end
  drawSL_R[3] <= sl_en_i & drawSL_R[2];
  drawSL_G[3] <= sl_en_i & drawSL_G[2];
  drawSL_B[3] <= sl_en_i & drawSL_B[2];
  max_SL_str_R[3] <= max_SL_str_R[2];
  max_SL_str_G[3] <= max_SL_str_G[2];
  max_SL_str_B[3] <= max_SL_str_B[2];
  
  case (sl_thickness_i)
    2'b01: begin  // thin
        drawSL_R[2] <= SL_str_corrected_L[1] > val_0p1875;
        drawSL_G[2] <= SL_str_corrected_L[1] > val_0p1875;
        drawSL_B[2] <= SL_str_corrected_L[1] > val_0p1875;
        max_SL_str_R[2] <= SL_str_corrected_L[1] >= val_0p1875 + sl_profile_width;
        max_SL_str_G[2] <= SL_str_corrected_L[1] >= val_0p1875 + sl_profile_width;
        max_SL_str_B[2] <= SL_str_corrected_L[1] >= val_0p1875 + sl_profile_width;
        SL_str_corrected_R_L[2] <= SL_str_corrected_L[1] - val_0p1875;
        SL_str_corrected_G_L[2] <= SL_str_corrected_L[1] - val_0p1875;
        SL_str_corrected_B_L[2] <= SL_str_corrected_L[1] - val_0p1875;
      end
    2'b10: begin  // normal
        drawSL_R[2] <= SL_str_corrected_L[1] > val_0p125;
        drawSL_G[2] <= SL_str_corrected_L[1] > val_0p125;
        drawSL_B[2] <= SL_str_corrected_L[1] > val_0p125;
        max_SL_str_R[2] <= SL_str_corrected_L[1] >= val_0p125 + sl_profile_width;
        max_SL_str_G[2] <= SL_str_corrected_L[1] >= val_0p125 + sl_profile_width;
        max_SL_str_B[2] <= SL_str_corrected_L[1] >= val_0p125 + sl_profile_width;
        SL_str_corrected_R_L[2] <= SL_str_corrected_L[1] - val_0p125;
        SL_str_corrected_G_L[2] <= SL_str_corrected_L[1] - val_0p125;
        SL_str_corrected_B_L[2] <= SL_str_corrected_L[1] - val_0p125;
      end
    2'b11: begin  // thick
        drawSL_R[2] <= SL_str_corrected_L[1] > val_0p0625;
        drawSL_G[2] <= SL_str_corrected_L[1] > val_0p0625;
        drawSL_B[2] <= SL_str_corrected_L[1] > val_0p0625;
        max_SL_str_R[2] <= SL_str_corrected_L[1] >= val_0p0625 + sl_profile_width;
        max_SL_str_G[2] <= SL_str_corrected_L[1] >= val_0p0625 + sl_profile_width;
        max_SL_str_B[2] <= SL_str_corrected_L[1] >= val_0p0625 + sl_profile_width;
        SL_str_corrected_R_L[2] <= SL_str_corrected_L[1] - val_0p0625;
        SL_str_corrected_G_L[2] <= SL_str_corrected_L[1] - val_0p0625;
        SL_str_corrected_B_L[2] <= SL_str_corrected_L[1] - val_0p0625;
      end
    default: begin // adaptive
        drawSL_R[2] <= SL_str_corrected_L[1] > sl_adapt_val_R_w;
        drawSL_G[2] <= SL_str_corrected_L[1] > sl_adapt_val_G_w;
        drawSL_B[2] <= SL_str_corrected_L[1] > sl_adapt_val_B_w;
        max_SL_str_R[2] <= SL_str_corrected_L[1] >= sl_adapt_val_R_w + sl_profile_width;
        max_SL_str_G[2] <= SL_str_corrected_L[1] >= sl_adapt_val_G_w + sl_profile_width;
        max_SL_str_B[2] <= SL_str_corrected_L[1] >= sl_adapt_val_B_w + sl_profile_width;
        SL_str_corrected_R_L[2] <= SL_str_corrected_L[1] - sl_adapt_val_R_w;
        SL_str_corrected_G_L[2] <= SL_str_corrected_L[1] - sl_adapt_val_G_w;
        SL_str_corrected_B_L[2] <= SL_str_corrected_L[1] - sl_adapt_val_B_w;
      end
  endcase
  
  SL_str_corrected_L[0] <= sl_rel_pos_i > 8'h80 ? ~sl_rel_pos_i + 1'b1 : sl_rel_pos_i;  // map everything between 0 and 0.5 (from 8'h00 to 8'h80)
  SL_str_corrected_L[1] <= SL_str_corrected_L[0];                                       // wait for luma to be calculated
  // SL_str_corrected_L[2] calculated above depending on sl_thickness_i
  case(sl_profile_i)
    2'b01: begin  // gaussian
        getGaussProfile(SL_str_corrected_R_L[2][5:0],SL_str_corrected_R_L[3]);
        getGaussProfile(SL_str_corrected_G_L[2][5:0],SL_str_corrected_G_L[3]);
        getGaussProfile(SL_str_corrected_B_L[2][5:0],SL_str_corrected_B_L[3]);
      end
    2'b10: begin  // rectangular
        SL_str_corrected_R_L[3] <= {SL_str_corrected_R_L[2][5:0],SL_str_corrected_R_L[2][5:4]};
        SL_str_corrected_G_L[3] <= {SL_str_corrected_G_L[2][5:0],SL_str_corrected_G_L[2][5:4]};
        SL_str_corrected_B_L[3] <= {SL_str_corrected_B_L[2][5:0],SL_str_corrected_B_L[2][5:4]};
      end
    default: begin  // hanning
        getHannProfile(SL_str_corrected_R_L[2][5:0],SL_str_corrected_R_L[3]);
        getHannProfile(SL_str_corrected_G_L[2][5:0],SL_str_corrected_G_L[3]);
        getHannProfile(SL_str_corrected_B_L[2][5:0],SL_str_corrected_B_L[3]);
      end
  endcase
  SL_str_corrected_R_L[4] <= max_SL_str_R[3] ? sl_strength_i : SL_str_corrected_R_4L_full_w[15:8];
  SL_str_corrected_G_L[4] <= max_SL_str_G[3] ? sl_strength_i : SL_str_corrected_G_4L_full_w[15:8];
  SL_str_corrected_B_L[4] <= max_SL_str_B[3] ? sl_strength_i : SL_str_corrected_B_4L_full_w[15:8];
  SL_str_corrected_R_L[5] <= SL_str_corrected_R_L[4];
  SL_str_corrected_G_L[5] <= SL_str_corrected_G_L[4];
  SL_str_corrected_B_L[5] <= SL_str_corrected_B_L[4];
end

// calculate output pixel values
assign Rval_ref_pre_full_3L_w = Rref_L[2] * (* multstyle = "dsp" *) sl_bloom_i;
assign Gval_ref_pre_full_3L_w = Gref_L[2] * (* multstyle = "dsp" *) sl_bloom_i;
assign Bval_ref_pre_full_3L_w = Bref_L[2] * (* multstyle = "dsp" *) sl_bloom_i;
assign Rval_ref_full_5L_w = Rval_ref_pre_L[4] * (* multstyle = "dsp" *) SL_str_corrected_R_L[4];
assign Gval_ref_full_5L_w = Gval_ref_pre_L[4] * (* multstyle = "dsp" *) SL_str_corrected_G_L[4];
assign Bval_ref_full_5L_w = Bval_ref_pre_L[4] * (* multstyle = "dsp" *) SL_str_corrected_B_L[4];
assign R_sl_full_w = R_L[proc_stages-3] * (* multstyle = "dsp" *) SL_bloomed_str_R_7L;
assign G_sl_full_w = G_L[proc_stages-3] * (* multstyle = "dsp" *) SL_bloomed_str_G_7L;
assign B_sl_full_w = B_L[proc_stages-3] * (* multstyle = "dsp" *) SL_bloomed_str_B_7L;


always @(posedge VCLK_i or negedge nVRST_i)
  if (!nVRST_i) begin
    Rval_ref_pre_L[3] <= {(color_width_o+1){1'b0}};
    Gval_ref_pre_L[3] <= {(color_width_o+1){1'b0}};
    Bval_ref_pre_L[3] <= {(color_width_o+1){1'b0}};
    Rval_ref_pre_L[4] <= {(color_width_o+1){1'b0}};
    Gval_ref_pre_L[4] <= {(color_width_o+1){1'b0}};
    Bval_ref_pre_L[4] <= {(color_width_o+1){1'b0}};
    Rval_ref_5L <= {(color_width_o+1){1'b0}};
    Gval_ref_5L <= {(color_width_o+1){1'b0}};
    Bval_ref_5L <= {(color_width_o+1){1'b0}};
    
    SL_bloomed_rval_R_6L <= {SL_bloom_calc_width{1'b0}};
    SL_bloomed_rval_G_6L <= {SL_bloom_calc_width{1'b0}};
    SL_bloomed_rval_B_6L <= {SL_bloom_calc_width{1'b0}};
    SL_bloomed_str_R_7L <= {SL_bloom_calc_width{1'b0}};
    SL_bloomed_str_G_7L <= {SL_bloom_calc_width{1'b0}};
    SL_bloomed_str_B_7L <= {SL_bloom_calc_width{1'b0}};
    
    R_sl_8L <= {color_width_o{1'b0}};
    G_sl_8L <= {color_width_o{1'b0}};
    B_sl_8L <= {color_width_o{1'b0}};
    
    HSYNC_o <= 1'b0;
    VSYNC_o <= 1'b0;
    DE_o <= 1'b0;
    vdata_o <= {3*color_width_o{1'b0}};
  end else begin
    // bloom strength reference (2 + 1 proc. stages)
    Rval_ref_pre_L[3] <= Rval_ref_pre_full_3L_w[color_width_o+5:5]; // to pp-stage [3]
    Gval_ref_pre_L[3] <= Gval_ref_pre_full_3L_w[color_width_o+5:5]; // to pp-stage [3]
    Bval_ref_pre_L[3] <= Bval_ref_pre_full_3L_w[color_width_o+5:5]; // to pp-stage [3]
    
    Rval_ref_pre_L[4] <= Rval_ref_pre_L[3];  // to pp-stage [4] (wait for sl correction to be finished)
    Gval_ref_pre_L[4] <= Gval_ref_pre_L[3];  // to pp-stage [4] (wait for sl correction to be finished)
    Bval_ref_pre_L[4] <= Bval_ref_pre_L[3];  // to pp-stage [4] (wait for sl correction to be finished)
    
    Rval_ref_5L <= Rval_ref_full_5L_w[color_width_o+SL_bloom_calc_width:SL_bloom_calc_width]; // to pp-stage [5]
    Gval_ref_5L <= Gval_ref_full_5L_w[color_width_o+SL_bloom_calc_width:SL_bloom_calc_width]; // to pp-stage [5]
    Bval_ref_5L <= Bval_ref_full_5L_w[color_width_o+SL_bloom_calc_width:SL_bloom_calc_width]; // to pp-stage [5]

    // adaptation of sl_str. (2 proc. stages)
    SL_bloomed_rval_R_6L <= {1'b0,SL_str_corrected_R_L[5]} < Rval_ref_5L ? 8'h0 : SL_str_corrected_R_L[5] - Rval_ref_5L[7:0]; // to pp-stage [6]
    SL_bloomed_rval_G_6L <= {1'b0,SL_str_corrected_G_L[5]} < Gval_ref_5L ? 8'h0 : SL_str_corrected_G_L[5] - Gval_ref_5L[7:0]; // to pp-stage [6]
    SL_bloomed_rval_B_6L <= {1'b0,SL_str_corrected_B_L[5]} < Bval_ref_5L ? 8'h0 : SL_str_corrected_B_L[5] - Bval_ref_5L[7:0]; // to pp-stage [6]
    
    SL_bloomed_str_R_7L  <= 8'hff - SL_bloomed_rval_R_6L; // to pp-stage [7]
    SL_bloomed_str_G_7L  <= 8'hff - SL_bloomed_rval_G_6L; // to pp-stage [7]
    SL_bloomed_str_B_7L  <= 8'hff - SL_bloomed_rval_B_6L; // to pp-stage [7]
    
    // calculate SL (1 proc. stage)
    R_sl_8L <= R_sl_full_w[color_width_o+SL_bloom_calc_width-1:SL_bloom_calc_width];  // to pp-stage [8]
    G_sl_8L <= G_sl_full_w[color_width_o+SL_bloom_calc_width-1:SL_bloom_calc_width];  // to pp-stage [8]
    B_sl_8L <= B_sl_full_w[color_width_o+SL_bloom_calc_width-1:SL_bloom_calc_width];  // to pp-stage [8]
    
    // decide for output (1 proc. stage)
    HSYNC_o <= HSYNC_L[proc_stages-2];
    VSYNC_o <= VSYNC_L[proc_stages-2];
    DE_o <= DE_L[proc_stages-2];
    
    if (DE_L[proc_stages-2] && drawSL_R[proc_stages-2])
      vdata_o[`VDATA_O_RE_SLICE] <= R_sl_8L;
    else
      vdata_o[`VDATA_O_RE_SLICE] <= R_L[proc_stages-2];
    
    if (DE_L[proc_stages-2] && drawSL_G[proc_stages-2])
      vdata_o[`VDATA_O_GR_SLICE] <= G_sl_8L;
    else
      vdata_o[`VDATA_O_GR_SLICE] <= G_L[proc_stages-2];
    
    if (DE_L[proc_stages-2] && drawSL_B[proc_stages-2])
      vdata_o[`VDATA_O_BL_SLICE] <= B_sl_8L;
    else
      vdata_o[`VDATA_O_BL_SLICE] <= B_L[proc_stages-2];
  end


endmodule
