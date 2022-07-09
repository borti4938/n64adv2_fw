//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the N64 RGB/YPbPr DAC project.
//
// Copyright (C) 2016-2022 by Peter Bartmann <borti4938@gmx.de>
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
// Module Name:    n64adv2_apu_top
// Project Name:   N64 Advanced HMDI Mod
// Target Devices: several
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


module n64adv2_apu_top (
  MCLK_i,
  nRST_i,

  APUConfigSet,

  // N64 Audio Input
  SCLK_i,
  SDATA_i,
  LRCLK_i,

  // Audio Output
  SCLK_o,
  SDATA_o,
  LRCLK_o,
  SPDIF_o
);

`include "../lib/n64adv2_config.vh"


input MCLK_i;
input nRST_i;

input [`APUConfig_WordWidth-1:0] APUConfigSet;

input SCLK_i;
input SDATA_i;
input LRCLK_i;

output SCLK_o;
output SDATA_o;
output LRCLK_o;
output SPDIF_o;


// wires
wire audio_filter_bypass;
wire [4:0] audio_level_amp;
wire audio_swap_lr;
wire audio_spdif_en;

wire signed [15:0] PDATA [0:1];
wire PDATA_VALID;

wire [23:0] source_data;
wire source_valid, source_sop, source_eop, source_channel;

wire signed [23:0] PDATA_OUT_left_w;
wire signed [23:0] PDATA_OUT_right_w;

// regs
reg [1:0] tdm = 2'b11;
reg signed [15:0] sink_data_buf_0, sink_data_buf_1, sink_data;
reg sink_valid, sink_sop, sink_eop;

reg signed [23:0] PDATA_INT_pre [0:1];
reg [1:0] PDATA_INT_pre_VALID;

reg signed [23:0] PDATA_INT [0:1];
reg PDATA_INT_VALID, DATA_SUBSAMPL_DROP;

reg signed [9:0] cfg_amp_factor;
reg PDATA_MULT_pre_VALID, PDATA_MULT_VALID;
reg signed [32:0] PDATA_MULT_pre[0:1];
reg signed [23:0] PDATA_MULT[0:1];


// pass config to MCLK domain
register_sync #(
  .reg_width(`APUConfig_WordWidth),
  .reg_preset({`APUConfig_WordWidth{1'b0}})
) cfg_sync4mclk_u (
  .clk(MCLK_i),
  .clk_en(1'b1),
  .nrst(1'b1),
  .reg_i(APUConfigSet),
  .reg_o({audio_filter_bypass,audio_level_amp,audio_swap_lr,audio_spdif_en})
);

// parallization

n64_sample_i2s i2s_rx_u(
  .MCLK_i(MCLK_i),
  .nRST_i(nRST_i),
  .SCLK_i(SCLK_i),
  .SDATA_i(SDATA_i),
  .LRCLK_i(LRCLK_i),
  .PDATA_LEFT_o(PDATA[1]),
  .PDATA_RIGHT_o(PDATA[0]),
  .PDATA_VALID_o(PDATA_VALID)
);


// interpolation
// implementation used a multiplexed fir filter for left and right channel

always @(posedge MCLK_i or negedge nRST_i)
  if (!nRST_i) begin
    sink_valid <= 1'b0;
    sink_sop <= 1'b0;
    sink_eop <= 1'b0;
    tdm <= 2'b00;
  end else begin
    case (tdm)
      2'b00: if (PDATA_VALID) begin
        sink_data_buf_1 <= PDATA[1];
        sink_data_buf_0 <= PDATA[0];
        tdm <= 2'b01;
      end
      2'b01: begin  // process left first
        sink_data <= sink_data_buf_1;
        sink_valid <= 1'b1;
        sink_sop <= 1'b1;
        sink_eop <= 1'b0;
        tdm <= 2'b10;
      end
      2'b10: begin  // process right as second
        sink_data <= sink_data_buf_0;
        sink_valid <= 1'b1;
        sink_sop <= 1'b0;
        sink_eop <= 1'b1;
        tdm <= 2'b11;
      end
      2'b11: begin
        sink_valid <= 1'b0;
        sink_sop <= 1'b0;
        sink_eop <= 1'b0;
        tdm <= 2'b00;
      end
      default: tdm <= 2'b11;
    endcase
  end

fir_2ch_audio fir_2ch_audio_u(
  .clk(MCLK_i),
  .reset_n(nRST_i),
  .ast_sink_data(sink_data),
  .ast_sink_valid(sink_valid),
  .ast_sink_error(2'b00),
  .ast_sink_sop(sink_sop),
  .ast_sink_eop(sink_eop),
  .ast_source_data(source_data),
  .ast_source_valid(source_valid),
  .ast_source_sop(source_sop),
  .ast_source_eop(source_eop),
  .ast_source_channel(source_channel)
);

always @(posedge MCLK_i or negedge nRST_i)
  if (!nRST_i) begin
    PDATA_INT_pre[0] <= {24{1'b0}};
    PDATA_INT_pre[1] <= {24{1'b0}};
    PDATA_INT_pre_VALID <= 2'b00;
  end else begin
    if (source_valid) begin
      PDATA_INT_pre[source_sop] <= source_data;
      PDATA_INT_pre_VALID[source_sop] <= 1'b1;
      PDATA_INT_pre_VALID[source_eop] <= 1'b0;
    end else begin
      PDATA_INT_pre_VALID <= 2'b00;
    end
  end

always @(posedge MCLK_i or negedge nRST_i)
  if (!nRST_i) begin
    PDATA_INT[0] <= {24{1'b0}};
    PDATA_INT[1] <= {24{1'b0}};
    PDATA_INT_VALID <= 1'b0;
    DATA_SUBSAMPL_DROP <= 1'b0;
  end else begin
    PDATA_INT_VALID <= 1'b0;
    if (!DATA_SUBSAMPL_DROP) begin
      if (PDATA_INT_pre_VALID[1])
        PDATA_INT[1] <= audio_filter_bypass ? {sink_data_buf_1,8'b0} : PDATA_INT_pre[1]; // left comes first, so do not set valid flag here
      if (PDATA_INT_pre_VALID[0]) begin
        PDATA_INT[0] <= audio_filter_bypass ? {sink_data_buf_0,8'b0} : PDATA_INT_pre[0]; // second is right, so set valid flag here
        PDATA_INT_VALID <= 1'b1;
      end
    end
    if (PDATA_INT_pre_VALID[0]) // decimate from 96kHz to 48kHz as output runs at 48kHz
      DATA_SUBSAMPL_DROP <= ~DATA_SUBSAMPL_DROP;
  end


// amplify audio / multiplication

always @(posedge MCLK_i) begin
  case(audio_level_amp)
//    5'd0: cfg_amp_factor <= 9'b000000100;
//    5'd1: cfg_amp_factor <= 9'b000000100;
//    5'd2: cfg_amp_factor <= 9'b000000101;
//    5'd3: cfg_amp_factor <= 9'b000000101;
//    5'd4: cfg_amp_factor <= 9'b000000110;
    5'd0: cfg_amp_factor <= 9'b000000001;
    5'd1: cfg_amp_factor <= 9'b000000010;
    5'd2: cfg_amp_factor <= 9'b000000011;
    5'd3: cfg_amp_factor <= 9'b000000100;
    5'd4: cfg_amp_factor <= 9'b000000101;
    5'd5: cfg_amp_factor <= 9'b000000110;
    5'd6: cfg_amp_factor <= 9'b000000111;
    5'd7: cfg_amp_factor <= 9'b000001000;
    5'd8: cfg_amp_factor <= 9'b000001001;
    5'd9: cfg_amp_factor <= 9'b000001010;
    5'd10: cfg_amp_factor <= 9'b000001011;
    5'd11: cfg_amp_factor <= 9'b000001101;
    5'd12: cfg_amp_factor <= 9'b000001110;
    5'd13: cfg_amp_factor <= 9'b000010000;
    5'd14: cfg_amp_factor <= 9'b000010010;
    5'd15: cfg_amp_factor <= 9'b000010100;
    5'd16: cfg_amp_factor <= 9'b000010111;
    5'd17: cfg_amp_factor <= 9'b000011001;
    5'd18: cfg_amp_factor <= 9'b000011101;
    5'd19: cfg_amp_factor <= 9'b000100000;
    5'd20: cfg_amp_factor <= 9'b000100100;
    5'd21: cfg_amp_factor <= 9'b000101000;
    5'd22: cfg_amp_factor <= 9'b000101101;
    5'd23: cfg_amp_factor <= 9'b000110011;
    5'd24: cfg_amp_factor <= 9'b000111001;
    5'd25: cfg_amp_factor <= 9'b001000000;
    5'd26: cfg_amp_factor <= 9'b001001000;
    5'd27: cfg_amp_factor <= 9'b001010000;
    5'd28: cfg_amp_factor <= 9'b001011010;
    5'd29: cfg_amp_factor <= 9'b001100101;
    5'd30: cfg_amp_factor <= 9'b001110010;
    5'd31: cfg_amp_factor <= 9'b001111111;
  endcase
end

always @(posedge MCLK_i or negedge nRST_i)
  if (!nRST_i) begin
    PDATA_MULT_pre_VALID <= 1'b0;
    PDATA_MULT_pre[1] <= 32'd0;
    PDATA_MULT_pre[0] <= 32'd0;
    PDATA_MULT_VALID <= 1'b0;
    PDATA_MULT[1] <= 24'd0;
    PDATA_MULT[0] <= 24'd0;
  end else begin
    PDATA_MULT_pre_VALID <= PDATA_INT_VALID;
    PDATA_MULT_pre[1] <= cfg_amp_factor * (* multstyle = "dsp" *) PDATA_INT[1];
    PDATA_MULT_pre[0] <= cfg_amp_factor * (* multstyle = "dsp" *) PDATA_INT[0];
    
    PDATA_MULT_VALID <= PDATA_MULT_pre_VALID;
    
    if (PDATA_MULT_pre[1][32] && ~&PDATA_MULT_pre[1][31:29]) // negative overflow
      PDATA_MULT[1] <= {1'b1,{23{1'b0}}};
    else if (!PDATA_MULT_pre[1][32] && |PDATA_MULT_pre[1][31:29]) // positive overflow
      PDATA_MULT[1] <= {1'b0,{23{1'b1}}};
    else
      PDATA_MULT[1] <= PDATA_MULT_pre[1][28:5];
    
    if (PDATA_MULT_pre[0][32] && ~&PDATA_MULT_pre[0][31:29]) // negative overflow
      PDATA_MULT[0] <= {1'b1,{23{1'b0}}};
    else if (!PDATA_MULT_pre[0][32] && |PDATA_MULT_pre[0][31:29]) // positive overflow
      PDATA_MULT[0] <= {1'b0,{23{1'b1}}};
    else
      PDATA_MULT[0] <= PDATA_MULT_pre[0][28:5];
  end

assign PDATA_OUT_left_w  = PDATA_MULT[~audio_swap_lr]; // is 0 if swapped, i.e. initially right, and 1 (left) else
assign PDATA_OUT_right_w = PDATA_MULT[ audio_swap_lr]; // is 1 if swapped, i.e. initially left, and 0 (right) else

// generate I2S and SPDIF output
i2s_leftjustified_tx i2s_tx_u(
  .MCLK_i(MCLK_i),
  .nRST_i(nRST_i),
  .PDATA_LEFT_i(PDATA_OUT_left_w),
  .PDATA_RIGHT_i(PDATA_OUT_right_w),
  .PDATA_VALID_i(PDATA_MULT_VALID),
  .SCLK_o(SCLK_o),
  .SDATA_o(SDATA_o),
  .LRCLK_o(LRCLK_o)
);

spdif_tx spdif_tx_u(
  .MCLK_i(MCLK_i),
  .nRST_i(nRST_i),
  .PDATA_LEFT_i(PDATA_OUT_left_w),
  .PDATA_RIGHT_i(PDATA_OUT_right_w),
  .PDATA_VALID_i(PDATA_MULT_VALID),
  .SPDIF_en(audio_spdif_en),
  .SPDIF_o(SPDIF_o)
);

endmodule
