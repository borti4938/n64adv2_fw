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
// Module Name:    mult_add_2
// Project Name:   N64 Advanced
// Target Devices: 
// Tool versions:  Altera Quartus Prime
// Description:    
//
//////////////////////////////////////////////////////////////////////////////////


module mult_add_2 #(
  parameter INPUT_DATA_A_W = 8,
  parameter INPUT_DATA_B_W = 8,
  parameter OUTPUT_DATA_W = 8,
  parameter POST_REGS = 0
) (
  CLK_i,
  nRST_i,
  
  inopcode_i,
  calcopcode_i,
  
  data_a0_i,
  data_b0_i,
  
  data_a1_i,
  data_b1_i,
  
  result_data_o
);

input CLK_i;
input nRST_i;

input [1:0] inopcode_i;
input [1:0] calcopcode_i;

input [INPUT_DATA_A_W-1:0] data_a0_i;
input [INPUT_DATA_B_W-1:0] data_b0_i;

input [INPUT_DATA_A_W-1:0] data_a1_i;
input [INPUT_DATA_B_W-1:0] data_b1_i;

output [OUTPUT_DATA_W-1:0] result_data_o;


// opcodes
localparam [1:0] inop_nop         = 2'b00;
localparam [1:0] inop_normal      = 2'b01;
localparam [1:0] inop_fir_mode    = 2'b10;
localparam [1:0] inop_reserved     = 2'b11;

localparam [1:0] calcop_normal    = 2'b00;
localparam [1:0] calcop_bypass_a0 = 2'b01;
localparam [1:0] calcop_bypass_a1 = 2'b10;
localparam [1:0] calcop_reserved  = 2'b11;

// misc
integer int_idx;

// wires

// registers
reg [INPUT_DATA_A_W-1:0] data_a0_L, data_a1_L;
reg [INPUT_DATA_B_W-1:0] data_b0_L, data_b1_L;

reg [1:0] calcopcode_LL, calcopcode_L;
reg [INPUT_DATA_A_W-1:0] bypass_mult_result;
reg [INPUT_DATA_A_W+INPUT_DATA_B_W-1:0] bypass_result, mult_result_0, mult_result_1;
reg [INPUT_DATA_A_W+INPUT_DATA_B_W:0] overall_result [0:POST_REGS];

// rtl

always @(posedge CLK_i or negedge nRST_i)
  if (!nRST_i) begin
    data_a0_L <= {INPUT_DATA_A_W{1'b0}};
    data_a1_L <= {INPUT_DATA_A_W{1'b0}};
    data_b0_L <= {INPUT_DATA_B_W{1'b0}};
    data_b1_L <= {INPUT_DATA_B_W{1'b0}};
  end else begin
    case (inopcode_i)
      inop_normal: begin
          data_a0_L <= data_a0_i;
          data_a1_L <= data_a1_i;
        end
      inop_fir_mode: begin
          data_a0_L <= data_a0_i;
          data_a1_L <= data_a0_L;
        end
      default: begin
          data_a0_L <= data_a0_L;
          data_a1_L <= data_a1_L;
        end
    endcase
    data_b0_L <= data_b0_i;
    data_b1_L <= data_b1_i;    
  end

always @(posedge CLK_i or negedge nRST_i)
  if (!nRST_i) begin
    calcopcode_LL <= calcop_normal;
    calcopcode_L <= calcop_normal;
    bypass_mult_result <= {INPUT_DATA_A_W{1'b0}};
    mult_result_0 <= {(INPUT_DATA_A_W+INPUT_DATA_B_W){1'b0}};
    mult_result_1 <= {(INPUT_DATA_A_W+INPUT_DATA_B_W){1'b0}};
    overall_result[0] <= {(INPUT_DATA_A_W+INPUT_DATA_B_W+1){1'b0}};
    for (int_idx = 0; int_idx < POST_REGS; int_idx = int_idx+1) begin
      overall_result[int_idx+1] <= {(INPUT_DATA_A_W+INPUT_DATA_B_W+1){1'b0}};
    end
  end else begin
    calcopcode_LL <= calcopcode_L;
    calcopcode_L <= calcopcode_i;
    bypass_mult_result <= calcopcode_L[1] ? data_a1_L : data_a0_L;
//    mult_result_0 <= data_a0_L * data_b0_L;
//    mult_result_1 <= data_a1_L * data_b1_L;
    mult_result_0 <= data_a0_L * (* multstyle = "dsp" *) data_b0_L;
    mult_result_1 <= data_a1_L * (* multstyle = "dsp" *) data_b1_L;
    overall_result[0] <= ^calcopcode_LL ? {1'b0,bypass_mult_result,{(INPUT_DATA_B_W){1'b0}}} : mult_result_0 + mult_result_1;
    for (int_idx = 0; int_idx < POST_REGS; int_idx = int_idx+1) begin
      overall_result[int_idx+1] <= overall_result[int_idx];
    end
  end

assign result_data_o = overall_result[POST_REGS][INPUT_DATA_A_W+INPUT_DATA_B_W-1:INPUT_DATA_A_W+INPUT_DATA_B_W-OUTPUT_DATA_W];

endmodule
