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


module scanline_emu #(
  parameter FALSE_PATH_STR_CORRECTION = "OFF" // must be ON or OFF
                                              // set_false_path -from [get_registers {<<path_to_module>>|Y_*}] must be added to sdc to make this working
) (
  VCLK_i,
  nVRST_i,

  HSYNC_i,
  VSYNC_i,
  DE_i,
  vdata_i,
  
  sl_en_i,
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
input sl_thickness_i;
input [1:0] sl_profile_i;
input [7:0] sl_rel_pos_i; // used to correct scanline strength value
input [7:0] sl_strength_i;
input [4:0] sl_bloom_i;

output reg HSYNC_o;
output reg VSYNC_o;
output reg DE_o;
output reg [`VDATA_O_CO_SLICE] vdata_o;


// misc
localparam proc_stages = 9;
localparam Y_width = color_width_o+1;
localparam SL_bloom_calc_width = 8; // do not change this localparam!

integer int_idx;


// wires
wire [7:0] sl_thickness_w;      // area in middle in which the SL is fully drawn
                                // must not exceed 8'h40!!!
wire [7:0] sl_edge_softening_w; // area width at each border where the SL strength becomes reduced until reaching zero
                                // must be 8'h40, 8'h20, 8'h10  or 8'h08
                                //         0.25,  0.125, 0.0625 or 0.03125

wire drawSL_w;
wire [15:0] SL_str_corrected_3L_full_w;
wire [7:0]  SL_str_corrected_3L_w, SL_str_corrected_4L_w;

wire [Y_width+4:0] Y_ref_pre_full_w;
wire [Y_width+SL_bloom_calc_width-1:0] Y_ref_full_w;
wire [color_width_o+SL_bloom_calc_width-1:0] R_sl_full_w, G_sl_full_w, B_sl_full_w;


// regs
generate
  if (FALSE_PATH_STR_CORRECTION == "ON") begin
    reg [3:1] Y_drawSL;
    reg [2:1] Y_max_SL_str;
    reg [7:0] Y_SL_str_corrected_L [0:4];
  end else begin
    reg [proc_stages-2:1] drawSL;
    reg [2:1] max_SL_str;
    reg [7:0] SL_str_corrected_L [0:4];
  end
endgenerate

reg [proc_stages-2:0] HSYNC_l, VSYNC_l, DE_l  /* synthesis ramstyle = "logic" */;
reg [color_width_o-1:0] R_l [0:proc_stages-2] /* synthesis ramstyle = "logic" */;
reg [color_width_o-1:0] G_l [0:proc_stages-2] /* synthesis ramstyle = "logic" */;
reg [color_width_o-1:0] B_l [0:proc_stages-2] /* synthesis ramstyle = "logic" */;

reg [color_width_o:0] RpB_l;
reg [Y_width-1:0] Yval_l;

reg [Y_width-1:0] Yval_ref_pre_l;
reg [Y_width-1:0] Yval_ref_l;

reg [SL_bloom_calc_width-1:0] SL_bloom_rval_l, SL_bloomed_str_l;

reg [color_width_o-1:0] R_sl_l, G_sl_l ,B_sl_l;


// begin of rtl

// strength correction first depending on profile
// method also generates drawSL indicator

localparam [7:0] profile_width = 8'b01000000;
localparam [7:0] pos_0p25 = 8'b01000000;
localparam [7:0] pos_0p125 = 8'b00100000;

generate
  if (FALSE_PATH_STR_CORRECTION == "ON") begin
    assign SL_str_corrected_3L_full_w = Y_SL_str_corrected_L[2] * (* multstyle = "dsp" *) sl_strength_i;

    always @(posedge VCLK_i) begin
      Y_drawSL[3] <= sl_en_i & Y_drawSL[2];
      Y_drawSL[2] <= &sl_profile_i ? Y_SL_str_corrected_L[1][5] & Y_drawSL[1] : Y_drawSL[1];                    // correct if flat top profile
      Y_drawSL[1] <= sl_thickness_i ? Y_SL_str_corrected_L[0] > pos_0p125 : Y_SL_str_corrected_L[0] > pos_0p25; // for thick sl, draw if value is over 0.125; for normal sl, if value is over 0.25
      
      Y_max_SL_str[2] <= &sl_profile_i ? Y_SL_str_corrected_L[1][5] : Y_max_SL_str[1];                          // correct if flat top profile
      Y_max_SL_str[1] <= sl_thickness_i ? Y_SL_str_corrected_L[0][7:5] >= 3'b011 : Y_SL_str_corrected_L[0][7];  // for thick sl, maxed out at 0.375; for normal sl, maxed out at 0.5
//      Y_max_SL_str[1] <= sl_thickness_i ? Y_SL_str_corrected_L[0] >= pos_0p125 + profile_width : Y_SL_str_corrected_L[0] >= pos_0p25 + profile_width; // for thick sl, maxed out at 0.375; for normal sl, maxed out at 0.5
      
      Y_SL_str_corrected_L[0] <= sl_rel_pos_i > 8'h80 ? ~sl_rel_pos_i + 1'b1 : sl_rel_pos_i;                                // map everything between 0 and 0.5 (from 8'h00 to 8'h80)
      Y_SL_str_corrected_L[1] <= sl_thickness_i ? Y_SL_str_corrected_L[0] - pos_0p125 : Y_SL_str_corrected_L[0] - pos_0p25; // subtract with 0.125 for thick sl or 0.25 for normal
      case(sl_profile_i)
        2'b00:  // hanning
          getHannProfile(Y_SL_str_corrected_L[1][5:0],Y_SL_str_corrected_L[2]);
        2'b01:  // gaussian
          getGaussProfile(Y_SL_str_corrected_L[1][5:0],Y_SL_str_corrected_L[2]);
        default:  // rectangular and flat top
          Y_SL_str_corrected_L[2] <= {Y_SL_str_corrected_L[1][5:0],Y_SL_str_corrected_L[1][5:4]};
      endcase
      Y_SL_str_corrected_L[3] <= Y_max_SL_str[2] ? sl_strength_i : SL_str_corrected_3L_full_w[15:8];
      Y_SL_str_corrected_L[4] <= Y_SL_str_corrected_L[3];
    end
  
    assign drawSL_w = Y_drawSL[3];
    assign SL_str_corrected_3L_w = Y_SL_str_corrected_L[3];
    assign SL_str_corrected_4L_w = Y_SL_str_corrected_L[4];
  end else begin
    assign SL_str_corrected_3L_full_w = SL_str_corrected_L[2] * (* multstyle = "dsp" *) sl_strength_i;

    always @(posedge VCLK_i) begin
      for (int_idx = 4; int_idx < proc_stages-1; int_idx = int_idx + 1)
        drawSL[int_idx] <= drawSL[int_idx-1];
      drawSL[3] <= sl_en_i & drawSL[2];
      drawSL[2] <= &sl_profile_i ? SL_str_corrected_L[1][5] & drawSL[1] : drawSL[1];                      // correct if flat top profile
      drawSL[1] <= sl_thickness_i ? SL_str_corrected_L[0] > pos_0p125 : SL_str_corrected_L[0] > pos_0p25; // for thick sl, draw if value is over 0.125; for normal sl, if value is over 0.25
      
      max_SL_str[2] <= &sl_profile_i ? SL_str_corrected_L[1][5] : max_SL_str[1];                          // correct if flat top profile
      max_SL_str[1] <= sl_thickness_i ? SL_str_corrected_L[0][7:5] >= 3'b011 : SL_str_corrected_L[0][7];  // for thick sl, maxed out at 0.375; for normal sl, maxed out at 0.5
//      max_SL_str[1] <= sl_thickness_i ? SL_str_corrected_L[0] >= pos_0p125 + profile_width : SL_str_corrected_L[0] >= pos_0p25 + profile_width; // for thick sl, maxed out at 0.375; for normal sl, maxed out at 0.5
      
      SL_str_corrected_L[0] <= sl_rel_pos_i > 8'h80 ? ~sl_rel_pos_i + 1'b1 : sl_rel_pos_i;                            // map everything between 0 and 0.5 (from 8'h00 to 8'h80)
      SL_str_corrected_L[1] <= sl_thickness_i ? SL_str_corrected_L[0] - pos_0p125 : SL_str_corrected_L[0] - pos_0p25; // subtract with 0.125 for thick sl or 0.25 for normal
      case(sl_profile_i)
        2'b00:  // hanning
          getHannProfile(SL_str_corrected_L[1][5:0],SL_str_corrected_L[2]);
        2'b01:  // gaussian
          getGaussProfile(SL_str_corrected_L[1][5:0],SL_str_corrected_L[2]);
        default:  // rectangular and flat top
          SL_str_corrected_L[2] <= {SL_str_corrected_L[1][5:0],SL_str_corrected_L[1][5:4]};
      endcase
      SL_str_corrected_L[3] <= max_SL_str[2] ? sl_strength_i : SL_str_corrected_3L_full_w[15:8];
      SL_str_corrected_L[4] <= SL_str_corrected_L[3];
    end
  
    assign drawSL_w = drawSL[proc_stages-2];
    assign SL_str_corrected_3L_w = SL_str_corrected_L[3];
    assign SL_str_corrected_4L_w = SL_str_corrected_L[4];
  end
endgenerate



// calculate output pixel values
assign Y_ref_pre_full_w = Yval_l * (* multstyle = "dsp" *) sl_bloom_i;
assign Y_ref_full_w = Yval_ref_pre_l * (* multstyle = "dsp" *) SL_str_corrected_3L_w;
assign R_sl_full_w = R_l[proc_stages-3] * (* multstyle = "dsp" *) SL_bloomed_str_l;
assign G_sl_full_w = G_l[proc_stages-3] * (* multstyle = "dsp" *) SL_bloomed_str_l;
assign B_sl_full_w = B_l[proc_stages-3] * (* multstyle = "dsp" *) SL_bloomed_str_l;


always @(posedge VCLK_i or negedge nVRST_i)
  if (!nVRST_i) begin
    HSYNC_l <= {(proc_stages-1){1'b0}};
    VSYNC_l <= {(proc_stages-1){1'b0}};
    DE_l <= {(proc_stages-1){1'b0}};
    for (int_idx = 0; int_idx < proc_stages-1; int_idx = int_idx + 1) begin
      R_l[int_idx] <= {color_width_o{1'b0}};
      G_l[int_idx] <= {color_width_o{1'b0}};
      B_l[int_idx] <= {color_width_o{1'b0}};
    end
    
    RpB_l <= {(color_width_o+1){1'b0}};
    Yval_l = {Y_width{1'b0}};
    
    Yval_ref_pre_l <= {Y_width{1'b0}};
    Yval_ref_l <= {Y_width{1'b0}};
    
    SL_bloom_rval_l <= {SL_bloom_calc_width{1'b0}};
    SL_bloomed_str_l <= {SL_bloom_calc_width{1'b0}};
    
    R_sl_l <= {color_width_o{1'b0}};
    G_sl_l <= {color_width_o{1'b0}};
    B_sl_l <= {color_width_o{1'b0}};
    
    HSYNC_o <= 1'b0;
    VSYNC_o <= 1'b0;
    DE_o <= 1'b0;
    vdata_o <= {3*color_width_o{1'b0}};
  end else begin
    HSYNC_l <= {HSYNC_l[proc_stages-3:0],HSYNC_i};
    VSYNC_l <= {VSYNC_l[proc_stages-3:0],VSYNC_i};
    DE_l <= {DE_l[proc_stages-3:0],DE_i};
    for (int_idx = 1; int_idx < proc_stages-1; int_idx = int_idx + 1) begin
      R_l[int_idx] <= R_l[int_idx-1];
      G_l[int_idx] <= G_l[int_idx-1];
      B_l[int_idx] <= B_l[int_idx-1];
    end
    
    // wait for one processing stage
    R_l[0] <= vdata_i[`VDATA_O_RE_SLICE];
    G_l[0] <= vdata_i[`VDATA_O_GR_SLICE];
    B_l[0] <= vdata_i[`VDATA_O_BL_SLICE];
    
    // approximate luma (2 proc. stages)
    RpB_l <= {1'b0,R_l[0]} + {1'b0,G_l[0]};                   // to stage [1]
    Yval_l <= {1'b0,G_l[1]} + {1'b0,RpB_l[color_width_o:1]};  // to stage [2]

    // bloom strength reference (2 proc. stages)
    Yval_ref_pre_l <= Y_ref_pre_full_w[Y_width+4:5];                                   // to stage [3]
    Yval_ref_l     <= Y_ref_full_w[Y_width+SL_bloom_calc_width-1:SL_bloom_calc_width]; // to stage [4]

    // adaptation of sl_str. (2 proc. stages)
    SL_bloom_rval_l <= {1'b0,SL_str_corrected_4L_w} < Yval_ref_l ? 8'h0 : SL_str_corrected_4L_w - Yval_ref_l[7:0]; // to stage [5]
    SL_bloomed_str_l  <= 8'hff - SL_bloom_rval_l;                                                                  // to stage [6]
    
    // calculate SL (1 proc. stage)
//    R_sl_l <= R_sl_full_w[color_width_o+SL_bloom_calc_width-2:SL_bloom_calc_width-1]; // to stage [7]
//    G_sl_l <= G_sl_full_w[color_width_o+SL_bloom_calc_width-2:SL_bloom_calc_width-1]; // to stage [7]
//    B_sl_l <= B_sl_full_w[color_width_o+SL_bloom_calc_width-2:SL_bloom_calc_width-1]; // to stage [7]
    R_sl_l <= R_sl_full_w[color_width_o+SL_bloom_calc_width-1:SL_bloom_calc_width]; // to stage [7]
    G_sl_l <= G_sl_full_w[color_width_o+SL_bloom_calc_width-1:SL_bloom_calc_width]; // to stage [7]
    B_sl_l <= B_sl_full_w[color_width_o+SL_bloom_calc_width-1:SL_bloom_calc_width]; // to stage [7]
    
    // decide for output (1 proc. stage)
    HSYNC_o <= HSYNC_l[proc_stages-2];
    VSYNC_o <= VSYNC_l[proc_stages-2];
    DE_o <= DE_l[proc_stages-2];
    
    if (DE_l[proc_stages-2] && drawSL_w)
      vdata_o <= {R_sl_l,G_sl_l,B_sl_l};
    else
      vdata_o <= {R_l[proc_stages-2],G_l[proc_stages-2],B_l[proc_stages-2]};
  end


endmodule
