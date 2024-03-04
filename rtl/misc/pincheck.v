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
// Module Name:    pincheck
// Project Name:   N64 Advanced 2
// Target Devices: 
// Tool versions:  Altera Quartus Prime
// Description:    
//
//////////////////////////////////////////////////////////////////////////////////


module pincheck #(
  parameter clk_transfer_run_i = "ON",
  parameter clk_transfer_outputs = "ON"
) (
  clk_i,
  run_i,
  
  CLK_SYS_i,
  CLK_AUD_i,
  CLK_ePLL1_i,
  CLK_ePLL0_i,
  
  VD_i,
  nVDSYNC_i,
  N64_CLK_i,
  
  ALRCLK_i,
  ASDATA_i,
  ASCLK_i,
  
  status_o
);

input clk_i;
input run_i;

input CLK_SYS_i;
input CLK_AUD_i;
input CLK_ePLL1_i;
input CLK_ePLL0_i;

input [6:0] VD_i; // Pin 15, 18, 19, 20, 23, 24, 25
input nVDSYNC_i;  // Pin 14
input N64_CLK_i;  // Pin 11
input ALRCLK_i;   // Pin 10
input ASDATA_i;   // Pin 7
input ASCLK_i;    // Pin 6
// Note: missing pins are always a (VCC,GND)-pair

output [15:0] status_o;


// start of rtl

// wires
wire run_clk_sys_w, run_clk_aud_w, run_clk_epll0_w, run_clk_epll1_w, run_n64_clk_w;
wire ALRCLK_w, ASDATA_w, ASCLK_w;

// regs
reg [3:0] clk_sys_cnt = 4'h0;
reg clk_sys_ok = 1'b0;
reg [3:0] clk_aud_cnt = 4'h0;
reg clk_aud_ok = 1'b0;
reg [3:0] clk_epll1_cnt = 4'h0;
reg clk_epll1_ok = 1'b0;
reg [3:0] clk_epll0_cnt = 4'h0;
reg clk_epll0_ok = 1'b0;
reg [3:0] clk_n64_cnt = 4'h0;
reg clk_n64_ok = 1'b0;

reg [1:0] pin25to24_ok = 2'b00; // check pin 25 against 26 technically not possible
reg [1:0] pin24to23_ok = 2'b00;
reg pin23toVcc_ok = 1'b0;
reg pin20toGND_ok = 1'b0;
reg [1:0] pin20to19_ok = 2'b00;
reg [1:0] pin19to18_ok = 2'b00;
reg pin18toVcc_ok = 1'b0;
reg pin15toGND_ok = 1'b0;
reg [1:0] pin15to14_ok = 2'b00;
reg pin14toVcc_ok = 1'b0;
reg [1:0] pin10check_ok = 2'b00;
reg pin7toGND_ok = 1'b0;
reg [1:0] pin7to6_ok = 2'b00;

reg pin25_ok = 1'b0;
reg pin24_ok = 1'b0;
reg pin23_ok = 1'b0;
reg pin20_ok = 1'b0;
reg pin19_ok = 1'b0;
reg pin18_ok = 1'b0;
reg pin15_ok = 1'b0;
reg pin14_ok = 1'b0;
reg pin10_ok = 1'b0;
reg pin7_ok = 1'b0;
reg pin6_ok = 1'b0;


// lets go
generate
  if (clk_transfer_run_i == "ON") begin
    register_sync #(
      .reg_width(1),
      .reg_preset(1'b0)
    ) run2sys_u(
      .clk(CLK_SYS_i),
      .clk_en(1'b1),
      .nrst(run_i),
      .reg_i(1'b1),
      .reg_o(run_clk_sys_w)
    );
  
    register_sync #(
      .reg_width(1),
      .reg_preset(1'b0)
    ) run2aud_u(
      .clk(CLK_AUD_i),
      .clk_en(1'b1),
      .nrst(run_i),
      .reg_i(1'b1),
      .reg_o(run_clk_aud_w)
    );
    
    register_sync #(
      .reg_width(1),
      .reg_preset(1'b0)
    ) run2pll1_u(
      .clk(CLK_ePLL1_i),
      .clk_en(1'b1),
      .nrst(run_i),
      .reg_i(1'b1),
      .reg_o(run_clk_epll1_w)
    );
  
    register_sync #(
      .reg_width(1),
      .reg_preset(1'b0)
    ) run2pll0_u(
      .clk(CLK_ePLL0_i),
      .clk_en(1'b1),
      .nrst(run_i),
      .reg_i(1'b1),
      .reg_o(run_clk_epll0_w)
    );
    
    register_sync #(
      .reg_width(1),
      .reg_preset(1'b0)
    ) run2n64_u(
      .clk(N64_CLK_i),
      .clk_en(1'b1),
      .nrst(run_i),
      .reg_i(1'b1),
      .reg_o(run_n64_clk_w)
    );
  end else begin
    assign run_clk_sys_w = run_i;
    assign run_clk_aud_w = run_i;
    assign run_clk_epll1_w = run_i;
    assign run_clk_epll0_w = run_i;
    assign run_n64_clk_w = run_i;
  end
endgenerate


// check clocks
always @(posedge CLK_SYS_i or negedge run_clk_sys_w)
  if (!run_clk_sys_w) begin
    clk_sys_cnt <= 4'h0;
    clk_sys_ok <= 1'b0;
  end else begin
    if (&clk_sys_cnt)
      clk_sys_ok <= 1'b1;
    else
      clk_sys_cnt <= clk_sys_cnt + 4'h1;
  end

always @(posedge CLK_AUD_i or negedge run_clk_aud_w)
  if (!run_clk_aud_w) begin
    clk_aud_cnt <= 4'h0;
    clk_aud_ok <= 1'b0;
  end else begin
    if (&clk_aud_cnt)
      clk_aud_ok <= 1'b1;
    else
      clk_aud_cnt <= clk_aud_cnt + 4'h1;
  end

always @(posedge CLK_ePLL1_i or negedge run_clk_epll1_w)
  if (!run_clk_epll1_w) begin
    clk_epll1_cnt <= 4'h0;
    clk_epll1_ok <= 1'b0;
  end else begin
    if (&clk_epll1_cnt)
      clk_epll1_ok <= 1'b1;
    else
      clk_epll1_cnt <= clk_epll1_cnt + 4'h1;
  end

always @(posedge CLK_ePLL0_i or negedge run_clk_epll0_w)
  if (!run_clk_epll0_w) begin
    clk_epll0_cnt <= 4'h0;
    clk_epll0_ok <= 1'b0;
  end else begin
    if (&clk_epll0_cnt)
      clk_epll0_ok <= 1'b1;
    else
      clk_epll0_cnt <= clk_epll0_cnt + 4'h1;
  end

always @(posedge N64_CLK_i or negedge run_n64_clk_w)
  if (!run_n64_clk_w) begin
    clk_n64_cnt <= 4'h0;
    clk_n64_ok <= 1'b0;
  end else begin
    if (&clk_n64_cnt)
      clk_n64_ok <= 1'b1;
    else
      clk_n64_cnt <= clk_n64_cnt + 4'h1;
  end


// audio wire to n64 clock domain
register_sync #(
  .reg_width(3),
  .reg_preset(3'b111)
) aud2n64_u(
  .clk(N64_CLK_i),
  .clk_en(1'b1),
  .nrst(1'b1),
  .reg_i({ALRCLK_i,ASDATA_i,ASCLK_i}),
  .reg_o({ALRCLK_w,ASDATA_w,ASCLK_w})
);

// check pins
always @(posedge N64_CLK_i or negedge run_n64_clk_w)
  if (!run_n64_clk_w) begin
    pin25to24_ok <= 2'b00;
    pin24to23_ok <= 2'b00;
    pin23toVcc_ok <= 1'b0;
    pin20toGND_ok <= 1'b0;
    pin20to19_ok <= 2'b00;
    pin19to18_ok <= 2'b00;
    pin18toVcc_ok <= 1'b0;
    pin15toGND_ok <= 1'b0;
    pin15to14_ok <= 2'b00;
    pin14toVcc_ok <= 1'b0;
    pin10check_ok <= 2'b00;
    pin7toGND_ok <= 1'b0;
    pin7to6_ok <= 2'b00;
    
    pin25_ok <= 1'b0;
    pin24_ok <= 1'b0;
    pin23_ok <= 1'b0;
    pin20_ok <= 1'b0;
    pin19_ok <= 1'b0;
    pin18_ok <= 1'b0;
    pin15_ok <= 1'b0;
    pin14_ok <= 1'b0;
    pin10_ok <= 1'b0;
    pin7_ok <= 1'b0;
    pin6_ok <= 1'b0;
  end else begin
    if (!VD_i[0] &  VD_i[1]) pin25to24_ok[1] <= 1'b1;
    if ( VD_i[0] & !VD_i[1]) pin25to24_ok[0] <= 1'b1;
    if (!VD_i[1] &  VD_i[2]) pin24to23_ok[1] <= 1'b1;
    if ( VD_i[1] & !VD_i[2]) pin24to23_ok[0] <= 1'b1;
    if (!VD_i[2]) pin23toVcc_ok <= 1'b1;  // becomes 1 if VD_i[2] is low for one cycle
    if ( VD_i[3]) pin20toGND_ok <= 1'b1;  // becomes 1 if VD_i[3] is high for one cycle
    if (!VD_i[3] &  VD_i[4]) pin20to19_ok[1] <= 1'b1;
    if ( VD_i[3] & !VD_i[4]) pin20to19_ok[0] <= 1'b1;
    if (!VD_i[4] &  VD_i[5]) pin19to18_ok[1] <= 1'b1;
    if ( VD_i[4] & !VD_i[5]) pin19to18_ok[0] <= 1'b1;
    if (!VD_i[5]) pin18toVcc_ok <= 1'b1;  // becomes 1 if VD_i[5] is low for one cycle
    if ( VD_i[6]) pin15toGND_ok <= 1'b1;  // becomes 1 if VD_i[6] is high for one cycle
    if (!VD_i[6] &  nVDSYNC_i) pin15to14_ok[1] <= 1'b1;
    if ( VD_i[6]) pin15to14_ok[0] <= 1'b1;  // VD[6] is always low if VDSYNC is low,
                                            // so just check if VD[6] is able to be high here
    if (!nVDSYNC_i) pin14toVcc_ok <= 1'b1;  // becomes 1 if nVDSYNC_i is low for one cycle
    if (!ALRCLK_w) pin10check_ok[1] <= 1'b1;
    if ( ALRCLK_w) pin10check_ok[0] <= 1'b1;
    if ( ASDATA_w) pin7toGND_ok <= 1'b1;  // becomes 1 if ASDATA_i is high for one cycle
    if (!ASDATA_w &  ASCLK_w) pin7to6_ok[1] <= 1'b1;
    if ( ASDATA_w & !ASCLK_w) pin7to6_ok[0] <= 1'b1;
    
    pin25_ok <= &pin25to24_ok;
    pin24_ok <= &pin24to23_ok;
    pin23_ok <= &{pin24to23_ok,pin23toVcc_ok};
    pin20_ok <= &{pin20toGND_ok,pin20to19_ok};
    pin19_ok <= &pin19to18_ok;
    pin18_ok <= &{pin19to18_ok,pin18toVcc_ok};
    pin15_ok <= &{pin15toGND_ok,pin15to14_ok};
    pin14_ok <= &{pin15to14_ok,pin14toVcc_ok};
    pin10_ok <= &pin10check_ok;
    pin7_ok <= &{pin7toGND_ok,pin7to6_ok};
    pin6_ok <= &pin7to6_ok;
  end


// generate output status
generate
  if (clk_transfer_outputs == "ON") begin
    register_sync #(
      .reg_width(16),
      .reg_preset(16'd0)
    ) status_gen_u(
      .clk(clk_i),
      .clk_en(1'b1),
      .nrst(1'b1),
      .reg_i({clk_sys_ok,clk_aud_ok,clk_epll1_ok,clk_epll0_ok,clk_n64_ok,pin25_ok,pin24_ok,pin23_ok,pin20_ok,pin19_ok,pin18_ok,pin15_ok,pin14_ok,pin10_ok,pin7_ok,pin6_ok}),
      .reg_o(status_o)
    );
  end else begin
    assign status_o[15] = clk_sys_ok;   // system clock
    assign status_o[14] = clk_aud_ok;   // audio clock
    assign status_o[13] = clk_epll1_ok; // external pll 1
    assign status_o[12] = clk_epll0_ok; // external pll 0
    assign status_o[11] = clk_n64_ok;   // n64 clock
    
    assign status_o[10] = pin25_ok;     // D0
    assign status_o[9] = pin24_ok;      // D1
    assign status_o[8] = pin23_ok;      // D2
    assign status_o[7] = pin20_ok;      // D3
    assign status_o[6] = pin19_ok;      // D4
    assign status_o[5] = pin18_ok;      // D5
    assign status_o[4] = pin15_ok;      // D6
    assign status_o[3] = pin14_ok;      // Data Sync
    assign status_o[2] = pin10_ok;      // Audio LR Clock
    assign status_o[1] = pin7_ok;       // Audio Data
    assign status_o[0] = pin6_ok;       // Audio Serial Clock
  end
endgenerate

endmodule
