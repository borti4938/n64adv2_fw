//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the N64 RGB/YPbPr DAC project.
//
// Copyright (C) 2016-2021 by Peter Bartmann <borti4938@gmail.com>
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
// Module Name:    spdif_tx
// Project Name:   N64 Advanced HMDI Mod
// Target Devices: 
// Tool versions:  Altera Quartus Prime
// Description:
//
// Dependencies:
// (more dependencies may appear in other files)
//
// Revision:
// Features: see repository readme
//
//////////////////////////////////////////////////////////////////////////////////



module spdif_tx (
  MCLK_i,
  nRST_i,

  // Parallel Input
  PDATA_LEFT_i,
  PDATA_RIGHT_i,
  PDATA_VALID_i,

  // Seriell SPDIF Audio Output
  SPDIF_en,
  SPDIF_o
);

input MCLK_i;
input nRST_i;

input [23:0] PDATA_LEFT_i;
input [23:0] PDATA_RIGHT_i;
input PDATA_VALID_i;

input SPDIF_en;
output reg SPDIF_o;


// parameter (preambles in reversed order)
// due to even parity the inverted version is not needed
localparam preamble_b = 8'b00010111;  // start of channel 1 (left / A) at start of a 192 frame block      (1st sub-frame)
localparam preamble_m = 8'b01000111;  // start of channel 1 (left / A) but not start of a 192 frame block (1st sub-frame)
localparam preamble_w = 8'b00100111;  // start of channel 2 (right / B)                                   (2nd sub-frame)

localparam STATE_INIT       = 3'b000;
localparam STATE_PREAMBLE   = 3'b001;
localparam STATE_AUDIO      = 3'b010;
localparam STATE_VALID_BIT  = 3'b011;
localparam STATE_USER_BIT   = 3'b100;
localparam STATE_CHANNEL_ST = 3'b101;
localparam STATE_PARITY     = 3'b110;

// wires
wire mclk_en_w;
wire nRST_SPDIF_enc;

// regs
reg signed [23:0] audio_lr_i [0:1];
reg trigger_tx;
reg [1:0] mclk_en_cnt;

reg [2:0] spdif_tx_state;

reg signed [23:0] audio_lr_buf [0:1];
reg [7:0] frame_cnt;
reg subframe_sel;
reg [4:0] bit_o_sel;

reg bmc_phase;

// input reg - store valid values for transmitter
// generate mclk_en signalling

always @(posedge MCLK_i or negedge nRST_i)
  if (!nRST_i) begin
    audio_lr_i[0] <= {24{1'b0}};
    audio_lr_i[1] <= {24{1'b0}};
    trigger_tx <= 1'b0;
    mclk_en_cnt <= 2'b00;
  end else begin
    if (PDATA_VALID_i) begin
      audio_lr_i[0] <= PDATA_LEFT_i;  // left  goes into '0' as it is transmitted in 1st subframe
      audio_lr_i[1] <= PDATA_RIGHT_i; // right goes into '1' as it is transmitted in 2nd subframe
      trigger_tx <= SPDIF_en;
    end
    if (trigger_tx)
      mclk_en_cnt <= mclk_en_cnt + 2'b01;
    else
      mclk_en_cnt <= 2'b00;
  end

assign mclk_en_w = &mclk_en_cnt;  // MCLK is only enabled every fourth clock cycle
assign nRST_SPDIF_enc = nRST_i & trigger_tx;

// SPDIF encoder

// some information:
// - 24.576MHz = 512 x 48kHz audio
// - Clock required: 48kHz x 2 sub-frames/sample x 32bit/sub-frame x 2 baud/bit = 6,144Mbaud
//   o 4 MCLKs per biphase mark code symbol
// - transmitting audio samples is organized in 192 frame long blocks due to channel status bits

always @(posedge MCLK_i or negedge nRST_SPDIF_enc)
  if (!nRST_SPDIF_enc) begin
    spdif_tx_state <= STATE_INIT;
    audio_lr_buf[0] <= {24{1'b0}};
    audio_lr_buf[1] <= {24{1'b0}};
    frame_cnt <= 8'd0;
    subframe_sel <= 1'b0;
    bit_o_sel <= 5'd0;
    bmc_phase <= 1'b0;
    SPDIF_o <= 1'b0;
  end else begin
    if (mclk_en_w) begin
      case (spdif_tx_state)
        STATE_INIT: begin
            spdif_tx_state <= STATE_PREAMBLE;
            audio_lr_buf[0] <= audio_lr_i[0];
            audio_lr_buf[1] <= audio_lr_i[1];
            frame_cnt <= 8'd0;
            subframe_sel <= 1'b0;
            bit_o_sel <= 5'd0;
            bmc_phase <= 1'b0;
            SPDIF_o <= 1'b0;
          end
        STATE_PREAMBLE: begin
            if (subframe_sel) begin
              SPDIF_o <= preamble_w[bit_o_sel];
            end else if (|frame_cnt) begin
              SPDIF_o <= preamble_m[bit_o_sel];
            end else begin
              SPDIF_o <= preamble_b[bit_o_sel];
            end
            if (bit_o_sel == 5'd7) begin // last preamble phase
              spdif_tx_state <= STATE_AUDIO;
              
              bit_o_sel <= 5'd0;
//              bmc_phase <= 1'b0;  // should be zero anyway
            end else begin
              bit_o_sel <= bit_o_sel + 1'b1;
            end
          end
        STATE_AUDIO: begin
            if (!bmc_phase) begin // first bmc phase
              SPDIF_o <= ~SPDIF_o;
            end else begin        // second bmc phase
              SPDIF_o <= SPDIF_o ^ audio_lr_buf[subframe_sel][bit_o_sel];
              if (bit_o_sel == 5'd23) begin // last audio bit (MSB)
                spdif_tx_state <= STATE_VALID_BIT;
                bit_o_sel <= 5'd0;
              end else begin
                bit_o_sel <= bit_o_sel + 1'b1;
              end
            end
            bmc_phase <= ~bmc_phase;
          end
        STATE_VALID_BIT: begin
            if (!bmc_phase) begin // first bmc phase
              SPDIF_o <= ~SPDIF_o;
            end else begin        // second bmc phase (valid bit is always zero)
              SPDIF_o <= SPDIF_o;
              spdif_tx_state <= STATE_USER_BIT;
            end
            bmc_phase <= ~bmc_phase;
          end
        STATE_USER_BIT: begin
            if (!bmc_phase) begin // first bmc phase
              SPDIF_o <= ~SPDIF_o;
            end else begin        // second bmc phase (user date bit is zero by default as used here)
              SPDIF_o <= SPDIF_o;
              spdif_tx_state <= STATE_CHANNEL_ST;
            end
            bmc_phase <= ~bmc_phase;
          end
        STATE_CHANNEL_ST: begin
            if (!bmc_phase) begin // first bmc phase
              SPDIF_o <= ~SPDIF_o;
            end else begin        // second bmc phase
              SPDIF_o <= SPDIF_o; // always zero (consumer general)
              spdif_tx_state <= STATE_PARITY;
            end
            bmc_phase <= ~bmc_phase;
          end
        STATE_PARITY: begin
            if (!bmc_phase) begin // first bmc phase
              SPDIF_o <= ~SPDIF_o;
            end else begin        // second bmc phase
              SPDIF_o <= 1'b0;    // due to even parity, SPDIF_o always goes low here (ToDo: verify in testbench / in system first)
              if (subframe_sel) begin
                if (frame_cnt == 8'd191)
                  frame_cnt <= 8'd0;
                else
                  frame_cnt <= frame_cnt + 1'b1;
              end
              subframe_sel <= ~subframe_sel;
              spdif_tx_state <= STATE_PREAMBLE;
              audio_lr_buf[0] <= audio_lr_i[0];
              audio_lr_buf[1] <= audio_lr_i[1];
            end
            bmc_phase <= ~bmc_phase;
          end
        default: begin
            spdif_tx_state <= STATE_INIT;
          end
      endcase
    end
  end

endmodule
