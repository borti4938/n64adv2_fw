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
// Module Name:    polyphase_2step_fir
// Project Name:   N64 Advanced
// Target Devices: 
// Tool versions:  Altera Quartus Prime
// Description:    
//
//////////////////////////////////////////////////////////////////////////////////


module polyphase_2step_fir #(
  parameter INPUT_DATA_W = 8,
  parameter COEFF_W = 8,
  parameter OUTPUT_DATA_W = 8,
  parameter POST_REGS = 0
) (
  CLK_i,
  nRST_i,
  
  fir_inopcode_i,
  fir_calcopcode_i,
  
  fir_data_i,
  coeff_a0_i,
  coeff_a1_i,
  
  fir_data_z0_init_i,
  fir_data_z1_init_i,
  
  result_data_o
);

input CLK_i;
input nRST_i;

input [2:0] fir_inopcode_i;
input [1:0] fir_calcopcode_i;

input [INPUT_DATA_W-1:0] fir_data_i;
input [COEFF_W-1:0] coeff_a0_i;
input [COEFF_W-1:0] coeff_a1_i;

input [INPUT_DATA_W-1:0] fir_data_z0_init_i;
input [INPUT_DATA_W-1:0] fir_data_z1_init_i;

output [OUTPUT_DATA_W-1:0] result_data_o;


// opcodes
localparam [2:0] inop_nop         = 3'b000;
localparam [2:0] inop_next_data   = 3'b001;
localparam [2:0] inop_init_z0_z1  = 3'b100;
localparam [2:0] inop_init_z0     = 3'b110;
localparam [2:0] inop_init_z1     = 3'b111;


localparam [1:0] caclop_normal          = 2'b00;
localparam [1:0] caclop_normal_reserved = 2'b01;
localparam [1:0] calcop_bypass_z0       = 2'b10;
localparam [1:0] calcop_bypass_z1       = 2'b11;

// misc

integer int_idx;

// wires

// registers

reg [INPUT_DATA_W-1:0] fir_data_z0, fir_data_z1;
reg [COEFF_W-1:0] coeff_a0_L, coeff_a1_L;

reg [1:0] fir_calcopcode_LL, fir_calcopcode_L;
reg [INPUT_DATA_W-1:0] bypass_mult_result;
reg [INPUT_DATA_W+COEFF_W-1:0] bypass_result, mult_result_0, mult_result_1;
reg [INPUT_DATA_W+COEFF_W:0] overall_result [0:POST_REGS];

// rtl

always @(posedge CLK_i or negedge nRST_i)
  if (!nRST_i) begin
    fir_data_z0 <= {INPUT_DATA_W{1'b0}};
    fir_data_z1 <= {INPUT_DATA_W{1'b0}};
    coeff_a0_L <= {COEFF_W{1'b0}};
    coeff_a1_L <= {COEFF_W{1'b0}};
  end else begin
    coeff_a0_L <= coeff_a0_i;
    coeff_a1_L <= coeff_a1_i;
    case (fir_inopcode_i)
      inop_next_data: begin
          fir_data_z0 <= fir_data_i;
          fir_data_z1 <= fir_data_z0;
        end
      inop_init_z0_z1: begin
          fir_data_z0 <= fir_data_z0_init_i;
          fir_data_z1 <= fir_data_z1_init_i;
        end
      inop_init_z0: begin
          fir_data_z0 <= fir_data_z0_init_i;
          fir_data_z1 <= fir_data_z1;
        end
      inop_init_z1: begin
          fir_data_z0 <= fir_data_z0;
          fir_data_z1 <= fir_data_z1_init_i;
        end
      default: begin
          fir_data_z0 <= fir_data_z0;
          fir_data_z1 <= fir_data_z1;
        end
    endcase
    
  end

always @(posedge CLK_i or negedge nRST_i)
  if (!nRST_i) begin
    fir_calcopcode_LL <= caclop_normal;
    fir_calcopcode_L <= caclop_normal;
    bypass_mult_result <= {INPUT_DATA_W{1'b0}};
    mult_result_0 <= {(INPUT_DATA_W+COEFF_W){1'b0}};
    mult_result_1 <= {(INPUT_DATA_W+COEFF_W){1'b0}};
    overall_result[0] <= {(INPUT_DATA_W+COEFF_W+1){1'b0}};
    for (int_idx = 0; int_idx < POST_REGS; int_idx = int_idx+1) begin
      overall_result[int_idx+1] <= {(INPUT_DATA_W+COEFF_W+1){1'b0}};
    end
  end else begin
    fir_calcopcode_LL <= fir_calcopcode_L;
    fir_calcopcode_L <= fir_calcopcode_i;
    bypass_mult_result <= fir_calcopcode_L[0] ? fir_data_z1 : fir_data_z0;
//    mult_result_0 <= fir_data_z0 * coeff_a0_L;
//    mult_result_1 <= fir_data_z1 * coeff_a1_L;
    mult_result_0 <= fir_data_z0 * (* multstyle = "dsp" *) coeff_a0_L;
    mult_result_1 <= fir_data_z1 * (* multstyle = "dsp" *) coeff_a1_L;
    overall_result[0] <= fir_calcopcode_LL[1] ? {1'b0,bypass_mult_result,{(COEFF_W){1'b0}}} : mult_result_0 + mult_result_1;
    for (int_idx = 0; int_idx < POST_REGS; int_idx = int_idx+1) begin
      overall_result[int_idx+1] <= overall_result[int_idx];
    end
  end

assign result_data_o = overall_result[POST_REGS][INPUT_DATA_W+COEFF_W-1:INPUT_DATA_W+COEFF_W-OUTPUT_DATA_W];

endmodule
