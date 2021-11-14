//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the N64 RGB/YPbPr DAC project.
//
// Copyright (C) 2015-2021 by Peter Bartmann <borti4938@gmail.com>
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

input      clk;
input      clk_en;
input      async_nrst_i;
output reg rst_o = active_state;


reg rst_pre = active_state;

always @(posedge clk or negedge async_nrst_i) begin
  if (!async_nrst_i) begin
    rst_o   <= active_state;
    rst_pre <= active_state;
  end else if (clk_en) begin
    rst_o   <= rst_pre;
    rst_pre <= ~active_state;
  end
end

endmodule
