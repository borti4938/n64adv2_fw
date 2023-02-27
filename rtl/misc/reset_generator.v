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
// Module Name:    reset_generator
// Project Name:   N64 Advanced RGB/YPbPr DAC Mod
// Target Devices: universial
// Tool versions:  Altera Quartus Prime
// Description:    generates a reset signal (low-active by default) with duration of
//                 two clock cycles
//
//////////////////////////////////////////////////////////////////////////////////


module reset_generator(
  clk,
  clk_en,
  async_nrst_i,
  rst_o
);


parameter active_state = 1'b0;
parameter rst_length = 2;

input  clk;
input  clk_en;
input  async_nrst_i;
output reg rst_o = active_state;

integer int_idx;
reg  rst_pl [0:rst_length-2];
initial begin
  for (int_idx = 0; int_idx < rst_length-1; int_idx = int_idx + 1)
    rst_pl[int_idx] <= active_state;
end

always @(posedge clk or negedge async_nrst_i) begin
  if (!async_nrst_i) begin
    rst_o <= active_state;
    for (int_idx = 0; int_idx < rst_length-1; int_idx = int_idx + 1)
      rst_pl[int_idx] <= active_state;
  end else if (clk_en) begin
    rst_o <= rst_pl[rst_length-2];
    for (int_idx = 1; int_idx < rst_length-1; int_idx = int_idx + 1)
      rst_pl[int_idx] <= rst_pl[int_idx-1];
    rst_pl[0] <= ~active_state;
  end
end

endmodule
