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
// Module Name:    gamma_module_v2
// Project Name:   N64 Advanced RGB/YPbPr DAC Mod
// Target Devices: Cyclone IV and Cyclone 10 LP devices
// Tool versions:  Altera Quartus Prime
// Description:    gamma correction (nDSYNC synchronuous)
//
//////////////////////////////////////////////////////////////////////////////////

module gamma_module_v2(
  VCLK,
  nRST,
  gammaparams_i,
  vdata_valid_i,
  vdata_i,
  vdata_valid_o,
  vdata_o
);

`include "../../lib/n64adv_vparams.vh"
`include "../../lib/n64adv2_config.vh"

input VCLK;
input nRST;

input [ 3:0] gammaparams_i;

input vdata_valid_i;
input [`VDATA_I_FU_SLICE] vdata_i;
output reg vdata_valid_o;
output reg [`VDATA_O_FU_SLICE] vdata_o = {vdata_width_o{1'b0}};


// translate gamma table
wire       en_gamma_boost     = ~(gammaparams_i == `GAMMA_TABLE_OFF);
wire [3:0] gamma_rom_page_tmp =  (gammaparams_i < `GAMMA_TABLE_OFF) ? gammaparams_i       :
                                                                      gammaparams_i - 1'b1;
wire [2:0] gamma_rom_page = gamma_rom_page_tmp[2:0];


// connect data tables (output has delay of two)
wire [`VDATA_I_CO_SLICE] gamma_vdata_out;

reg [1:0] vdata_i_cnt = 2'b00;
reg [color_width_i-1:0] gamma_vdata_i = {color_width_i{1'b0}};
wire [color_width_o-1:0] gamma_vdata_o;

always @(posedge VCLK or negedge nRST)
  if (!nRST) begin
    vdata_i_cnt <= 2'b00;
    gamma_vdata_i <= {color_width_i{1'b0}};
  end else begin
    if (vdata_valid_i) begin
      vdata_i_cnt <= 2'b01;
      gamma_vdata_i <= vdata_i[`VDATA_I_RE_SLICE];
    end else begin
      if (vdata_i_cnt == 2'b01)
        gamma_vdata_i <= vdata_i[`VDATA_I_GR_SLICE];
      if (vdata_i_cnt == 2'b10)
        gamma_vdata_i <= vdata_i[`VDATA_I_BL_SLICE];
      vdata_i_cnt <= vdata_i_cnt + 2'b01;
    end
  end

gamma_table_v2 gamma_table_u(
  .VCLK(VCLK),
  .nRST(nRST),
  .gamma_val(gamma_rom_page),
  .vdata_in(gamma_vdata_i),
  .nbypass(en_gamma_boost),
  .vdata_out(gamma_vdata_o)
);

// delay of remaining components

reg vdata_valid_L[0:2];
reg [3:0] vdata_sync_L[0:2];
integer int_idx;
initial begin
  vdata_valid_L[2] = 1'b0;
  vdata_valid_L[1] = 1'b0;
  vdata_valid_L[0] = 1'b0;
  vdata_sync_L[2] = 4'h0;
  vdata_sync_L[1] = 4'h0;
  vdata_sync_L[0] = 4'h0;
end

always @(posedge VCLK or negedge nRST)
  if (!nRST) begin
    vdata_valid_L[2] <= 1'b0;
    vdata_valid_L[1] <= 1'b0;
    vdata_valid_L[0] <= 1'b0;
    vdata_sync_L[2] <= 4'h0;
    vdata_sync_L[1] <= 4'h0;
    vdata_sync_L[0] <= 4'h0;
  end else begin
    vdata_valid_L[2] <= vdata_valid_L[1];
    vdata_valid_L[1] <= vdata_valid_L[0];
    vdata_valid_L[0] <= vdata_valid_i;
    vdata_sync_L[2] <= vdata_sync_L[1];
    vdata_sync_L[1] <= vdata_sync_L[0];
    vdata_sync_L[0] <= vdata_i[`VDATA_I_SY_SLICE];
  end

// collect outputs
reg [1:0] vdata_o_cnt = 2'b00;
reg [`VDATA_O_FU_SLICE] vdata_o_pre = {vdata_width_o{1'b0}};

always @(posedge VCLK or negedge nRST)
  if (!nRST) begin
    vdata_o_cnt <= 2'b00;
    vdata_o_pre <= {vdata_width_i{1'b0}};
  end else begin
    if (vdata_valid_L[2]) begin
      vdata_o_cnt <= 2'b01;
      vdata_o_pre[`VDATA_O_SY_SLICE] <= vdata_sync_L[2];
      vdata_o_pre[`VDATA_O_RE_SLICE] <= gamma_vdata_o;
    end else begin
      if (vdata_o_cnt == 2'b01)
        vdata_o_pre[`VDATA_O_GR_SLICE] <= gamma_vdata_o;
      if (vdata_o_cnt == 2'b10)
        vdata_o_pre[`VDATA_O_BL_SLICE] <= gamma_vdata_o;
      vdata_o_cnt <= vdata_o_cnt + 2'b01;
    end
  end

// registered output
always @(posedge VCLK or negedge nRST)
  if (!nRST) begin
    vdata_o <= {vdata_width_o{1'b0}};
  end else begin
    vdata_valid_o <= vdata_valid_L[2];
    if (vdata_valid_L[2])
      vdata_o <= vdata_o_pre;
  end

endmodule
