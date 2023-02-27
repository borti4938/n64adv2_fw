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
// Module Name:    register_sync_2
// Project Name:   N64 Advanced RGB/YPbPr DAC Mod
// Target Devices: universial
// Tool versions:  Altera Quartus Prime
// Description:    generates a reset signal (low-active by default) with duration of
//                 two clock cycles
//
//////////////////////////////////////////////////////////////////////////////////


module register_sync_2 #(
  parameter reg_width = 16,
  parameter reg_preset = {reg_width{1'b0}},
  parameter resync_stages = 3,
  parameter check_valid_data = "ON",
  parameter use_valid_o = "ON"
) (
  nrst,
  
  clk_i,
  clk_i_en,
  reg_i,
  
  clk_o,
  clk_o_en,
  reg_o
);


input nrst;

input clk_i;
input clk_i_en;
input [reg_width-1:0] reg_i;

input clk_o;
input clk_o_en;
output reg [reg_width-1:0] reg_o;


// misc

localparam IN_STATE_IDATA_WAIT   = 2'b00;
localparam IN_STATE_ORDY_WAIT    = 2'b01;
localparam IN_STATE_OACK_WAIT    = 2'b10;

localparam OUT_STATE_IDATA_WAIT  = 2'b00;
localparam OUT_STATE_ICONF_WAIT0 = 2'b01;
localparam OUT_STATE_ICONF_WAIT1 = 2'b10;
localparam OUT_STATE_ROUND_WAIT  = 2'b11;

integer int_idx;

// wire

wire nrst_i, nrst_o;
wire reg_o_buf_valid_check_w;

// regs

reg [resync_stages-1:0] rdy_fb_i;
reg [resync_stages-1:0] ack_fb_i;
reg [1:0] in_state;
reg [reg_width-1:0] reg_i_buf [0:1] /* synthesis ramstyle = "logic" */;
reg req_i;
reg conf_i;

reg [resync_stages-1:0] req_fwd_o;
reg [resync_stages-1:0] conf_fwd_o;
reg [1:0] out_state;
reg rdy_o;
reg ack_o;
reg [reg_width-1:0] reg_o_buf [0:resync_stages-1] /* synthesis ramstyle = "logic" */;
reg reg_o_buf_valid;


// rtl

// generate reset signals first

reset_generator reset_clk_i_u(
  .clk(clk_i),
  .clk_en(clk_i_en),
  .async_nrst_i(nrst),
  .rst_o(nrst_i)
);


reset_generator reset_clk_o_u(
  .clk(clk_o),
  .clk_en(clk_o_en),
  .async_nrst_i(nrst),
  .rst_o(nrst_o)
);

// transfer logic with handshake

always @(posedge clk_i or negedge nrst_i)
  if (!nrst_i) begin
    rdy_fb_i <= {resync_stages{1'b0}};
    ack_fb_i <= {resync_stages{1'b0}};
    
    in_state <= IN_STATE_IDATA_WAIT;
    reg_i_buf[1] <= reg_preset;
    reg_i_buf[0] <= reg_preset;
    req_i <= 1'b0;
    conf_i <= 1'b0;
  end else if (clk_i_en) begin
    rdy_fb_i <= {rdy_fb_i[resync_stages-2:0],rdy_o};
    ack_fb_i <= {ack_fb_i[resync_stages-2:0],ack_o};
    
    case (in_state)
      IN_STATE_IDATA_WAIT:
        if (reg_i_buf[0] != reg_i && !ack_fb_i[resync_stages-1]) begin
          in_state <= IN_STATE_ORDY_WAIT;
          reg_i_buf[0] <= reg_i;
          req_i <= 1'b1;
        end
      IN_STATE_ORDY_WAIT:
        if (rdy_fb_i[resync_stages-1]) begin
          in_state <= IN_STATE_OACK_WAIT;
          reg_i_buf[1] <= reg_i_buf[0];
          req_i <= 1'b0;
          conf_i <= 1'b1;
        end
      IN_STATE_OACK_WAIT:
        if (ack_fb_i[resync_stages-1]) begin
          in_state <= IN_STATE_IDATA_WAIT;
          conf_i <= 1'b0;
        end
      default:
        in_state <= IN_STATE_IDATA_WAIT;
    endcase
  end

generate
  if (check_valid_data == "ON" && resync_stages >= 3)
    assign reg_o_buf_valid_check_w = reg_o_buf[resync_stages-1] == reg_o_buf[resync_stages-2];
  else
    assign reg_o_buf_valid_check_w = 1'b1;
endgenerate

always @(posedge clk_o or negedge nrst_o)
  if (!nrst_o) begin
    req_fwd_o <= {resync_stages{1'b0}};
    conf_fwd_o <= {resync_stages{1'b0}};
    
    out_state <= OUT_STATE_IDATA_WAIT;
    rdy_o <= 1'b0;
    ack_o <= 1'b0;
    for (int_idx = 0; int_idx < resync_stages; int_idx = int_idx + 1)
      reg_o_buf[int_idx] <= reg_preset;
    reg_o_buf_valid <= 1'b0;
  end else if (clk_o_en) begin
    req_fwd_o <= {req_fwd_o[resync_stages-2:0],req_i};
    conf_fwd_o <= {conf_fwd_o[resync_stages-2:0],conf_i};
    
    case (out_state)
      OUT_STATE_IDATA_WAIT: begin
          if (req_fwd_o[resync_stages-1]) begin
            out_state <= OUT_STATE_ICONF_WAIT0;
            rdy_o <= 1'b1;
          end
          reg_o_buf_valid <= 1'b0;
        end
      OUT_STATE_ICONF_WAIT0:
        if (conf_fwd_o[resync_stages-1]) begin
          out_state <= OUT_STATE_ICONF_WAIT1;
          rdy_o <= 1'b0;
          reg_o_buf[0] <= reg_i_buf[1];
        end
      OUT_STATE_ICONF_WAIT1: begin
          out_state <= OUT_STATE_ROUND_WAIT;
          ack_o <= 1'b1;
          reg_o_buf[0] <= reg_i_buf[1];
        end
      OUT_STATE_ROUND_WAIT:
        if (!conf_fwd_o[resync_stages-1] && 
            reg_o_buf_valid_check_w) begin
          out_state <= OUT_STATE_IDATA_WAIT;
          ack_o <= 1'b0;
          reg_o_buf_valid <= 1'b1;
        end
      default:
        out_state <= OUT_STATE_IDATA_WAIT;
    endcase
    
    for (int_idx = 1; int_idx < resync_stages; int_idx = int_idx + 1)
      reg_o_buf[int_idx] <= reg_o_buf[int_idx-1];
  end

generate
  if (use_valid_o == "ON") begin
    always @(posedge clk_o or negedge nrst_o)
      if (!nrst_o) begin
        reg_o <= reg_preset;
      end else if (clk_o_en) begin
        if (reg_o_buf_valid)
          reg_o <= reg_o_buf[resync_stages-1];
      end
  end else begin
    always @(*)
      reg_o <= reg_o_buf[resync_stages-1];
  end
endgenerate

endmodule
