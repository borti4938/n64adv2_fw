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
// Module Name:    vector_reg_sync
// Project Name:   N64 Advanced RGB/YPbPr DAC Mod
// Target Devices: universial
// Tool versions:  Altera Quartus Prime
// Description:    cdc for vector signals
//
//////////////////////////////////////////////////////////////////////////////////


module vector_reg_sync #(
  parameter reg_width = 16,
  parameter reg_preset = {reg_width{1'b0}}
) (
  clk_i,
  clk_en_i,
  nrst_i,
  vecreg_i,
  clk_o,
  clk_en_o,
  nrst_o,
  vecreg_o
);

input clk_i;
input clk_en_i;
input nrst_i;
input [reg_width-1:0] vecreg_i;

input clk_o;
input clk_en_o;
input nrst_o;
output [reg_width-1:0] vecreg_o;


localparam resync_stages = 2;


// tx clock domain logic

wire tx_rdy;
reg [resync_stages-1:0] toggle_on_rd_txsync = {resync_stages{1'b0}};
reg toggle_on_wr = 1'b0;
reg [reg_width-1:0] vecreg_0 = reg_preset;


assign tx_rdy = toggle_on_rd_txsync[resync_stages-1] ~^ toggle_on_wr;

always @(posedge clk_i or negedge nrst_i)
  if (!nrst_i) begin
    toggle_on_rd_txsync <= {resync_stages{1'b0}};
    toggle_on_wr <= 1'b0;
    vecreg_0 <= reg_preset;
  end else begin
    if (clk_en_i) begin
      toggle_on_rd_txsync <= {toggle_on_rd_txsync[resync_stages-2:0],toggle_on_rd};
      if (tx_rdy) begin
        toggle_on_wr <= ~toggle_on_wr;
        vecreg_0 <= vecreg_i;
      end
    end
  end


// rx clock domain logic

wire rx_avail;
reg [resync_stages-1:0] toggle_on_wr_rxsync = {resync_stages{1'b0}};
reg toggle_on_rd = 1'b0;
reg [reg_width-1:0] vecreg_1 = reg_preset;


assign rx_avail = toggle_on_wr_rxsync[resync_stages-1] ^ toggle_on_rd;

always @(posedge clk_o or negedge nrst_o)
  if (!nrst_o) begin
    toggle_on_wr_rxsync <= {resync_stages{1'b0}};
    toggle_on_rd <= 1'b0;
    vecreg_1 <= reg_preset;
  end else begin
    if (clk_en_o) begin
      toggle_on_wr_rxsync <= {toggle_on_wr_rxsync[resync_stages-2:0],toggle_on_wr};
      if (rx_avail) begin
        toggle_on_rd <= ~toggle_on_rd;
        vecreg_1 <= vecreg_0;
      end
    end
  end


// assign outputs

assign vecreg_o = vecreg_1;

endmodule
