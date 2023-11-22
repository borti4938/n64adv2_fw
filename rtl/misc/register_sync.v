//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the N64 RGB/YPbPr DAC project.
//
// Copyright (C) 2015-2023 by Peter Bartmann <borti4938@gmail.com>
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
// Module Name:    register_sync
// Project Name:   N64 Advanced RGB/YPbPr DAC Mod
// Target Devices: universial
// Tool versions:  Altera Quartus Prime
// Description:    generates a reset signal (low-active by default) with duration of
//                 two clock cycles
//
//////////////////////////////////////////////////////////////////////////////////


module register_sync #(
  parameter reg_width = 16,
  parameter reg_preset = {reg_width{1'b0}},
  parameter resync_stages = 2
) (
  clk,
  clk_en,
  nrst,
  reg_i,
  reg_o
);

input clk;
input clk_en;
input nrst;

input [reg_width-1:0] reg_i;
output [reg_width-1:0] reg_o;


reg [reg_width-1:0] reg_synced_1 = reg_preset;
reg [reg_width-1:0] reg_synced_0 = reg_preset;

genvar int_idx;

always @(posedge clk or negedge nrst)
  if (!nrst) begin
    reg_synced_1 <= reg_preset;
    reg_synced_0 <= reg_preset;
  end else begin
    if (clk_en) begin
      reg_synced_1 <= reg_synced_0;
      reg_synced_0 <= reg_i;
    end
  end

generate
  if (resync_stages < 3) begin : reg1_gen
    assign reg_o = reg_synced_1;
  end
endgenerate

generate
  if (resync_stages == 3) begin : reg2_gen
    reg [reg_width-1:0] reg_synced_2 = reg_preset;
    
    always @(posedge clk or negedge nrst)
      if (!nrst) begin
        reg_synced_2 <= reg_preset;
      end else begin
        if (clk_en)
          reg_synced_2 <= reg_synced_1;
      end
    
    assign reg_o = reg_synced_2;
  end
endgenerate

generate
  if (resync_stages > 3) begin : reg3_gen
    reg [reg_width-1:0] reg_synced_2 = reg_preset;
    reg [reg_width-1:0] reg_synced_3 = reg_preset;
    
    for (int_idx = 0; int_idx < reg_width; int_idx = int_idx+1) begin : gate3_gen
      always @(posedge clk or negedge nrst)
        if (!nrst) begin
          reg_synced_3[int_idx] <= reg_preset[int_idx];
        reg_synced_2 <= reg_preset;
        end else begin
          if (clk_en) begin
            if (reg_synced_2[int_idx] == reg_synced_1[int_idx])
              reg_synced_3[int_idx] <= reg_synced_2[int_idx];
            reg_synced_2 <= reg_synced_1;
          end
        end
    end
    
    assign reg_o = reg_synced_3;
  end
endgenerate

endmodule
