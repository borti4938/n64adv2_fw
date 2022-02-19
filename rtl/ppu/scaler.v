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
// Module Name:    scaler
// Project Name:   N64 Advanced
// Target Devices: 
// Tool versions:  Altera Quartus Prime
// Description:    
//
//////////////////////////////////////////////////////////////////////////////////


module scaler(
  async_nRST_i,

  VCLK_i,
  vinfo_i,
  vdata_i,
  vdata_valid_i,
  vdata_hvshift_i,
  vdata_bob_deinterlacing_mode_i,
  
  DRAM_CLK_i,
  DRAM_nRST_i,
  
  DRAM_ADDR,
  DRAM_BA,
  DRAM_nCAS,
  DRAM_CKE,
  DRAM_nCS,
  DRAM_DQ,
  DRAM_DQM,
  DRAM_nRAS,
  DRAM_nWE,
  
  vinfo_dramsynced_i,
  video_deinterlacing_mode_i,
  video_vpos_1st_rdline_i,

  VCLK_o,
  
  vinfo_txsynced_i,
  video_config_i,
  video_llm_i,
  video_interpolation_mode_i,
  video_pal_boxed_i,
  
  vinfo_llm_slbuf_fb_o,
  
  video_vlines_in_needed_i,
  video_vlines_in_full_i,
  video_vlines_out_i,
  video_v_interpfactor_i,
  
  video_hpos_1st_rdpixel_i,
  video_hpixel_in_needed_i,
  video_hpixel_in_full_i,
  video_hpixel_out_i,
  video_h_interpfactor_i,
  
  scale_vpos_rel_o,
  scale_hpos_rel_o,
  HSYNC_o,
  VSYNC_o,
  DE_o,
  vdata_o
);


`include "../../lib/n64adv_vparams.vh"
`include "../../lib/videotimings.vh"

`include "../../lib/setVideoTimings.tasks.v"

input async_nRST_i;

input VCLK_i;
input [1:0] vinfo_i;
input vdata_valid_i;
input [`VDATA_O_FU_SLICE] vdata_i;
input [9:0] vdata_hvshift_i;
input vdata_bob_deinterlacing_mode_i;

input         DRAM_CLK_i;
input         DRAM_nRST_i;

output [12:0] DRAM_ADDR;
output [ 1:0] DRAM_BA;
output        DRAM_nCAS;
output        DRAM_CKE;
output        DRAM_nCS;
inout  [15:0] DRAM_DQ;
output [ 1:0] DRAM_DQM;
output        DRAM_nRAS;
output        DRAM_nWE;

input [1:0] vinfo_dramsynced_i;
input video_deinterlacing_mode_i;
input [9:0] video_vpos_1st_rdline_i;  // first line to read (needed if scaling factor is so high such that not all lines are needed)

input VCLK_o;

input [1:0] vinfo_txsynced_i;
input [`VID_CFG_W-1:0] video_config_i;
input video_llm_i;
input [1:0] video_interpolation_mode_i;
input video_pal_boxed_i;

output reg [8:0] vinfo_llm_slbuf_fb_o;

input [9:0] video_vlines_in_needed_i; // number of lines needed to scale for active lines
input [9:0] video_vlines_in_full_i;   // number of lines at input (either 240 in NTSC or 288 in PAL or x2 if interlaced processed as weave/fully buffered)
input [10:0] video_vlines_out_i;      // number of lines after scaling (max. 2047)
input [17:0] video_v_interpfactor_i;  // factor needed to determine actual position during interpolation

input [9:0] video_hpos_1st_rdpixel_i; // first horizontal pixel to read (needed if scaling factor is so high such that not all pixels are needed)
input [9:0] video_hpixel_in_needed_i; // number of horizontal pixel needed to scale for active lines
input [9:0] video_hpixel_in_full_i;   // number of horizontal pixel at input (should be 640, later 320 or 640)
input [11:0] video_hpixel_out_i;      // number of horizontal pixel after scaling (max. 4093)
input [17:0] video_h_interpfactor_i;  // factor needed to determine actual position during interpolation

output reg [7:0] scale_vpos_rel_o;
output reg [7:0] scale_hpos_rel_o;
output reg HSYNC_o;
output reg VSYNC_o;
output reg DE_o;
output reg [`VDATA_O_CO_SLICE] vdata_o;


// parameter
localparam resync_stages = 3;

localparam hcnt_width = $clog2(`PIXEL_PER_LINE_MAX);
localparam vcnt_width = $clog2(`TOTAL_LINES_PAL_LX1); // should be 9
localparam hpos_width = $clog2(`ACTIVE_PIXEL_PER_LINE);

localparam pre_lines_ntsc = `TOTAL_LINES_NTSC_LX1/4;
localparam pre_lines_pal  = `TOTAL_LINES_PAL_LX1/4;

localparam FILT_AX_SHARP_TH = 8'hA0;

localparam ST_SDRAM_WAIT      = 3'b000; // wait for new line to begin (FIFO is already flushed)
localparam ST_SDRAM_FIFO2RAM0 = 3'b001; // write frist FIFO element into SDRAM
localparam ST_SDRAM_FIFO2RAM1 = 3'b010; // write concurrent FIFO elements into SDRAM
localparam ST_SDRAM_RAM2BUF0  = 3'b101; // prepare sdram data to buffer
localparam ST_SDRAM_RAM2BUF1  = 3'b110; // write sdram data to buffer

localparam HVSCALE_PHASE_INIT = 2'b00;
localparam HVSCALE_PHASE_MAIN = 2'b01;
localparam HVSCALE_PHASE_POST = 2'b10;
localparam HVSCALE_PHASE_INVALID = 2'b11;

localparam GEN_SIGNALLING_DELAY = 1;
localparam LOAD_PIXEL_BUF_DELAY = 2;
localparam VERT_INTERP_DELAY = 3;
localparam HORI_INTERP_DELAY = 3;
localparam POST_BUF_DELAY = 1;
localparam Videogen_Pipeline_Length = GEN_SIGNALLING_DELAY+LOAD_PIXEL_BUF_DELAY+VERT_INTERP_DELAY+HORI_INTERP_DELAY+POST_BUF_DELAY;
// current pipeline stages:
// - generate counter (zeroth stage)
// - generate HSYNC, VSYNC and DE / generate loading signals for BRAM
// - two clock cycles until data is loaded from BRAM
// - three clock cycle vertical interpolation
// - three clock cycle horizontal interpolation
// - final output register

localparam H_A0_CALC_DELAY = 3;

// misc
integer int_idx;

wire palmode = vinfo_i[1];
wire interlaced = vinfo_i[0];
wire palmode_dramclk_resynced = vinfo_dramsynced_i[1];
wire interlaced_dramclk_resynced = vinfo_dramsynced_i[0];
wire palmode_vclk_o_resynced = vinfo_txsynced_i[1];
wire interlaced_vclk_o_resynced = vinfo_txsynced_i[0];

wire hshift_direction = vdata_hvshift_i[9];
wire [3:0] hshift    = vdata_hvshift_i[9] ? vdata_hvshift_i[8:5] : ~vdata_hvshift_i[8:5] + 1'b1;
wire vshift_direction = vdata_hvshift_i[4];
wire [3:0] vshift    = vdata_hvshift_i[4] ? vdata_hvshift_i[3:0] : ~vdata_hvshift_i[3:0] + 1'b1;


// wires

// wires for resets in different clock domains
wire nRST_i, nRST_DRAM_proc, nRST_o;

// wires for input rtl
wire sdram_rdy_vclk_i_resynced, output_proc_en_vclk_i_resynced;

wire nHS_i, nVS_i;
wire negedge_nHSYNC, negedge_nVSYNC;

// wires for sdram rtl
wire [3:0] datainfo_pre_sdram_buf_sdr_clk_resynced;
wire lineid_pre_sdram_buf_sdr_clk_resynced;

wire [11:0] vcnt_o_sdr_clk_resynced;
wire [1:0] rdpage_slbuf_sdr_clk_resynced;

wire [7:0] sdram_data_dummy_o;
wire [`VDATA_O_CO_SLICE] sdram_data_o;
wire sdram_cmd_ack_o, sdram_data_ack_o, sdram_ctrl_rdy_o;

wire wren_post_sdram_buf_p0_w, wren_post_sdram_buf_p1_w, wren_post_sdram_buf_p2_w;

wire datainfo_pre_sdram_buf_field_id_w;
wire [1:0] datainfo_pre_sdram_buf_bank_sel_w;
wire datainfo_pre_sdram_buf_field_rdy4out_w;

// wires for output rtl
wire [8:0] vcnt_i_vclk_o_resynced;
wire in2out_en_resynced;

wire [11:0] X_hpos_px_offset_w;
wire [10:0] X_vpos_px_offset_w;

wire rden_post_sdram_buf_p0_w, rden_post_sdram_buf_p1_w, rden_post_sdram_buf_p2_w;

wire [7:0] pix_v_a0_current_w, pix_v_a1_current_w, pix_h_a0_current_w, pix_h_a1_current_w;
wire pix_v_bypass_z0_w, pix_v_bypass_z1_w, pix_h_bypass_z0_w, pix_h_bypass_z1_w;
wire [1:0] fir_v_calcopcode_w, fir_h_calcopcode_w;

wire [`VDATA_O_CO_SLICE] rd_vdata_slbuf_p0, rd_vdata_slbuf_p1, rd_vdata_slbuf_p2, rd_vdata_slbuf, rd_vdata_next_slbuf;

wire [color_width_o-1:0] red_v_interp_out, gr_v_interp_out, bl_v_interp_out;
wire [color_width_o-1:0] red_h_interp_out, gr_h_interp_out, bl_h_interp_out;


// cmb regs
reg [1:0] wrpage_post_sdram_buf_cmb, rdpage_post_sdram_buf_cmb;
reg [7:0] wraddr_post_sdram_buf_main_next_cmb;
reg [1:0] wraddr_post_sdram_buf_sub_next_cmb;

reg [11:0] Y_vline_cnt_cmb;
reg [28:0] Y_a0_v_full_cmb;

reg [11:0] hpixel_cnt_cmb;
reg [29:0] a0_h_full_cmb;


// regs

// buffer used throughout the design to organize data before and after the sdram
reg [`VDATA_O_CO_SLICE] vdata_pre_sdram_buf [0:1023]; // FIFO BRAM buffer for video input

reg [3*3*color_width_o-1:0] vdata3_post_sdram_buf_p0 [0:213]; // BRAM buffer for video output
reg [3*3*color_width_o-1:0] vdata3_post_sdram_buf_p1 [0:213]; // BRAM buffer for video output
reg [3*3*color_width_o-1:0] vdata3_post_sdram_buf_p2 [0:213]; // BRAM buffer for video output

reg [`VDATA_O_CO_SLICE] vdata_pixel_buf_p0 [0:2]  /* synthesis ramstyle = "logic" */; // pixel buffer to work with during interpolation
reg [`VDATA_O_CO_SLICE] vdata_pixel_buf_p1 [0:2]  /* synthesis ramstyle = "logic" */; // pixel buffer to work with during interpolation
reg [`VDATA_O_CO_SLICE] vdata_pixel_buf_p2 [0:2]  /* synthesis ramstyle = "logic" */; // pixel buffer to work with during interpolation

// regs for input rtl
reg nHS_i_L = 1'b0;
reg nVS_i_L = 1'b0;
reg [hcnt_width-1:0] hcnt_i_L = {hcnt_width{1'b0}};
reg [vcnt_width-1:0] Y_vcnt_i_L = {vcnt_width{1'b0}};
reg [`VDATA_O_CO_SLICE] vdata_i_L = {(3*color_width_o){1'b0}};

reg [hcnt_width-1:0] X_hstart_i = `HSTART_NTSC;
//reg [hcnt_width-1:0] X_hstop_i  = `HSTOP_NTSC;
//reg [vcnt_width-2:0] X_vstart_i = `VSTART_NTSC_LX1;
//reg [vcnt_width-2:0] X_vstop_i  = `VSTOP_NTSC_LX1;
reg [vcnt_width-1:0] X_vstart_i = `VSTART_NTSC_LX1;
reg [vcnt_width-1:0] X_vstop_i  = `VSTOP_NTSC_LX1;

reg Y_field_id_i;
reg [1:0] Y_field_cnt_i;
reg Y_input_proc_en;
reg Y_in2out_en;
reg Y_field_rdy4out;

reg [9:0] vdata_pre_sdram_buf_in_cnt;

reg lineid_pre_sdram_buf = 1'b0;
reg [hpos_width-1:0] hcnt_pre_sdram_buf;
reg [3:0] datainfo_pre_sdram_buf;
reg datainfo_rdy;

// regs for sdram rtl
reg [vcnt_width:0] X_vpos_1st_rdline; // first line to read (needed if scaling factor is so high such that not all lines are needed)

reg sdram_proc_en = 1'b0;
reg [2:0] sdram_ctrl_state  = ST_SDRAM_WAIT; // state machine

reg sdram_req_i;
reg sdram_wr_en_i;
reg [22:0] sdram_addr_i; // (13bits row),(2bits bank),(8bits dblcolumn)
reg [`VDATA_O_CO_SLICE] sdram_data_i;

reg sdram_wr_lineid;
reg [1:0] sdram_wr_bank_sel_odd, sdram_wr_bank_sel_even;
reg [vcnt_width-1:0] sdram_wr_vcnt;
reg [hpos_width-1:0] sdram_wr_hcnt;

reg [9:0] vdata_pre_sdram_buf_out_cnt;

reg sdram_use_interlaced_out;
reg [1:0] sdram_bank_rdy4out_odd, sdram_bank_rdy4out_even;
reg [1:0] sdram_rd_bank_sel_current, sdram_rd_bank_sel_odd, sdram_rd_bank_sel_even;
reg [vcnt_width  :0] sdram_rd_vcnt;
reg [hpos_width-1:0] sdram_rd_hcnt;

reg wren_post_sdram_buf;
reg [1:0] wrpage_post_sdram_buf;
reg [hpos_width-1:0] wrcnt_post_sdram_buf;
reg [7:0] wraddr_post_sdram_buf_main;
reg [1:0] wraddr_post_sdram_buf_sub;

reg [2:0] wren_post_sdram_buf_p_L;
reg [`VDATA_O_CO_SLICE] vdata3_for_post_sdram_buf [0:2];

// regs for output rtl
reg Y_cfg_v_update_window;
reg [3:0] Y_cfg_h_update_window;
reg X_VSYNC_active = `VSYNC_active_480p60;
reg [10:0] X_VSYNCLEN = `VSYNCLEN_480p60;
reg [10:0] X_VSTART = `VSYNCLEN_480p60 + `VBACKPORCH_480p60;
reg [10:0] X_VACTIVE = `VACTIVE_480p60;
reg [10:0] X_VSTOP = `VSYNCLEN_480p60 + `VBACKPORCH_480p60 + `VACTIVE_480p60;
reg [10:0] X_VSTART_OS = `VSYNCLEN_480p60;
reg [10:0] X_VACTIVE_OS = `VBACKPORCH_480p60 + `VACTIVE_480p60 + `VFRONTPORCH_480p60;
reg [10:0] X_VSTOP_OS = `VSYNCLEN_480p60 + `VBACKPORCH_480p60 + `VACTIVE_480p60 + `VFRONTPORCH_480p60;
reg [10:0] X_VTOTAL = `VTOTAL_480p60;
reg X_HSYNC_active = `HSYNC_active_480p60;
reg [11:0] X_HSYNCLEN = `HSYNCLEN_480p60;
reg [11:0] X_HSTART = `HSYNCLEN_480p60 + `HBACKPORCH_480p60;
reg [11:0] X_HACTIVE = `HACTIVE_480p60;
reg [11:0] X_HSTOP = `HSYNCLEN_480p60 + `HBACKPORCH_480p60 + `HACTIVE_480p60;
reg [11:0] X_HSTART_OS = `HSYNCLEN_480p60;
reg [11:0] X_HACTIVE_OS = `HBACKPORCH_480p60 + `HACTIVE_480p60 + `HFRONTPORCH_480p60;
reg [11:0] X_HSTOP_OS = `HSYNCLEN_480p60 + `HBACKPORCH_480p60 + `HACTIVE_480p60 + `HFRONTPORCH_480p60;
reg [11:0] X_HTOTAL = `HTOTAL_480p60;

reg [10:0] X_VSTART_px = `VSYNCLEN_480p60;
reg [10:0] X_VSTOP_px = `VSYNCLEN_480p60 + `VBACKPORCH_480p60 + `VACTIVE_480p60 + `VFRONTPORCH_480p60;
reg [11:0] X_HSTART_px = `HSYNCLEN_480p60 + `HBACKPORCH_480p60;
reg [11:0] X_HSTOP_px = `HSYNCLEN_480p60 + `HBACKPORCH_480p60 + `HACTIVE_480p60 + `HFRONTPORCH_480p60;

reg [1:0] X_video_interpolation_mode;

reg [9:0] X_pix_vlines_in_needed = `ACTIVE_LINES_NTSC_LX1;        // number of lines needed to scale for active lines
reg [10:0] X_pix_vlines_in_full = `ACTIVE_LINES_NTSC_LX1;         // number of lines at input (either 240 in NTSC or 288 in PAL)
reg [10:0] X_pix_vlines_out_max = `HACTIVE_480p60;                // number of lines after scaling (max. 2047)
reg [10:0] X_pix_init_vline_cnt_phase = `ACTIVE_LINES_NTSC_LX1/2; // initial position for interpolation
reg [17:0] X_pix_v_interpfactor = 18'b001000100010001000;         // factor needed to determine actual position during interpolation

reg X_pix_hpixel_addr_mult2 = 1'b0;                             // increment horizontal buffer read address by factor 2 if deblur is enabled (i.e. 320 input pixel)
reg [9:0] X_pix_hpixel_in_needed = `ACTIVE_PIXEL_PER_LINE;      // number of horizontal pixel needed to scale for active lines
reg [11:0] X_pix_hpixel_in_full = `ACTIVE_PIXEL_PER_LINE;       // number of horizontal pixel at input (should be 320 or 640)
reg [11:0] X_pix_hpixel_out_max = `ACTIVE_PIXEL_PER_LINE;       // number of horizontal pixel after scaling (max. 4095)
reg [11:0] X_init_hpixel_cnt_phase = `ACTIVE_PIXEL_PER_LINE/2;  // initial position for interpolation
reg [17:0] X_pix_h_interpfactor = 18'b000011001100110011;       // factor needed to determine actual position during interpolation

reg [9:0] hpos_1st_rdpixel_decr;                                // first horizontal pixel to read (needed if scaling factor is so high such that not all pixels are needed) ...
reg [7:0] X_hpos_1st_rdpixel_main, hpos_1st_rdpixel_main;       // ... will be converted to main and sub address
reg [1:0] X_hpos_1st_rdpixel_sub, hpos_1st_rdpixel_sub;         //     due to BRAM optimization

reg output_proc_en = 1'b0;

reg [11:0] hcnt_o_L, Y_vcnt_o_L;
reg Y_v_active_de;
reg h_active_de;
reg Y_v_active_px;
reg h_active_px;

reg rden_post_sdram_buf;
reg [2:0] rden_post_sdram_buf_L;
reg [1:0] rdpage_post_sdram_buf;
reg [hpos_width-1:0] rdcnt_post_sdram_buf;
reg [7:0] rdaddr_post_sdram_buf_main, rdaddr_post_sdram_buf_main_L;
reg [1:0] rdaddr_post_sdram_buf_sub, rdaddr_post_sdram_buf_sub_L, rdaddr_post_sdram_buf_sub_LL;

reg [1:0] Y_vscale_phase = HVSCALE_PHASE_INVALID;
reg Y_vphase_init_delay = 1'b1;
reg [10:0] Y_vline_cnt = 11'd0;
reg [9:0]  Y_vline_load_cnt = 10'd0;
reg Y_pix_v_bypass_z0_current = 1'b0;
reg Y_pix_v_bypass_z1_current = 1'b1;
reg [8:0] Y_pix_v_a0_current = 9'h080;
reg [8:0] Y_pix_v_a0_pre = 9'h100;

reg [1:0] hscale_phase = HVSCALE_PHASE_INVALID;
reg [11:0] hpixel_cnt;
reg [9:0] hpixel_load_cnt;
reg [GEN_SIGNALLING_DELAY+LOAD_PIXEL_BUF_DELAY+VERT_INTERP_DELAY-1:0] pix_h_bypass_z0_current /* synthesis ramstyle = "logic" */;
reg [GEN_SIGNALLING_DELAY+LOAD_PIXEL_BUF_DELAY+VERT_INTERP_DELAY-1:0] pix_h_bypass_z1_current /* synthesis ramstyle = "logic" */;
reg [8:0] pix_h_a0_pre;
reg [8:0] pix_h_a0_current[GEN_SIGNALLING_DELAY+LOAD_PIXEL_BUF_DELAY+VERT_INTERP_DELAY-1:H_A0_CALC_DELAY-1] /* synthesis ramstyle = "logic" */;

reg [7:0] Y_scale_vpos_rel;
reg [7:0] scale_hpos_rel [H_A0_CALC_DELAY-1:Videogen_Pipeline_Length-1] /* synthesis ramstyle = "logic" */;

reg [Videogen_Pipeline_Length-2:0] DE_virt_vpl_L  /* synthesis ramstyle = "logic" */;
reg [Videogen_Pipeline_Length-1:0] HSYNC_vpl_L    /* synthesis ramstyle = "logic" */;
reg [Videogen_Pipeline_Length-1:0] VSYNC_vpl_L    /* synthesis ramstyle = "logic" */;
reg [Videogen_Pipeline_Length-1:0] DE_vpl_L       /* synthesis ramstyle = "logic" */;
reg [`VDATA_O_CO_SLICE] vdata_vpl_end_L;


// start of rtl

// generate resets

reset_generator #(
  .rst_length(8)
) reset_scaler_input_u(
  .clk(VCLK_i),
  .clk_en(1'b1),
  .async_nrst_i(async_nRST_i),
  .rst_o(nRST_i)
);

reset_generator #(
  .rst_length(8)
) reset_DRAM_proc_u(
  .clk(DRAM_CLK_i),
  .clk_en(1'b1),
  .async_nrst_i(async_nRST_i),
  .rst_o(nRST_DRAM_proc)
);

reset_generator #(
  .rst_length(8)
) reset_scaler_output_u(
  .clk(VCLK_o),
  .clk_en(1'b1),
  .async_nrst_i(async_nRST_i),
  .rst_o(nRST_o)
);


// +-----------+
// | input rtl |
// +-----------+

register_sync_2 #(
  .reg_width(1),
  .reg_preset(1'b0),
  .resync_stages(resync_stages)
) register_sync_dram2in_u0 (
  .nrst(async_nRST_i),
  .clk_i(DRAM_CLK_i),
  .clk_i_en(1'b1),
  .reg_i(sdram_ctrl_rdy_o & sdram_proc_en),
  .clk_o(VCLK_i),
  .clk_o_en(1'b1),
  .reg_o(sdram_rdy_vclk_i_resynced)
);

register_sync_2 #(
  .reg_width(1),
  .reg_preset(1'b0),
  .resync_stages(resync_stages)
) register_sync_out2in_u0 (
  .nrst(async_nRST_i),
  .clk_i(VCLK_o),
  .clk_i_en(1'b1),
  .reg_i(output_proc_en),
  .clk_o(VCLK_i),
  .clk_o_en(1'b1),
  .reg_o(output_proc_en_vclk_i_resynced)
);


assign nHS_i = vdata_i[3*color_width_o+1];
assign nVS_i = vdata_i[3*color_width_o+3];
assign negedge_nHSYNC =  nHS_i_L & !nHS_i;
assign negedge_nVSYNC =  nVS_i_L & !nVS_i;

always @(posedge VCLK_i or negedge nRST_i)
  if (!nRST_i) begin
    nHS_i_L <= 1'b0;
    nVS_i_L <= 1'b0;
    hcnt_i_L <= {hcnt_width{1'b0}};
    Y_vcnt_i_L <= {vcnt_width{1'b0}};
    vdata_i_L <= {(3*color_width_o){1'b0}};
    
    X_hstart_i <= `HSTART_NTSC;
//    X_hstop_i  <= `HSTOP_NTSC;
    X_vstart_i <= `VSTART_NTSC_LX1;
    X_vstop_i  <= `VSTOP_NTSC_LX1;
    
    Y_field_id_i <= 1'b1;
    Y_field_cnt_i <= 2'b00;
    Y_input_proc_en <= 1'b0;
    Y_in2out_en <= 1'b0;
    Y_field_rdy4out <= 1'b0;
  end else begin
    if (vdata_valid_i) begin
      nHS_i_L <= nHS_i;
      nVS_i_L <= nVS_i;
      vdata_i_L <= vdata_i[`VDATA_O_CO_SLICE];
      
      if (Y_input_proc_en) begin
        if (negedge_nHSYNC) begin
          hcnt_i_L <= 10'd0;
          Y_vcnt_i_L <= Y_vcnt_i_L + 1'b1;
          if (((Y_vcnt_i_L == pre_lines_ntsc) && !palmode) ||
              ((Y_vcnt_i_L == pre_lines_pal)  &&  palmode) ) begin
            Y_in2out_en <= 1'b1;
            Y_field_rdy4out <= 1'b1;
          end else begin
            Y_field_rdy4out <= 1'b0;
          end
        end else begin
          hcnt_i_L <= hcnt_i_L + 1'b1;
        end
      end

      if (negedge_nVSYNC) begin
        Y_input_proc_en <= sdram_rdy_vclk_i_resynced & output_proc_en_vclk_i_resynced;
        // set new info
        if (palmode) begin
          X_hstart_i <= !hshift_direction ? `HSTART_PAL + hshift : `HSTART_PAL - hshift;
//          X_hstop_i  <= !hshift_direction ? `HSTOP_PAL  + hshift : `HSTOP_PAL  - hshift;
          X_vstart_i <=  vshift_direction ? `VSTART_PAL_LX1 + vshift : `VSTART_PAL_LX1 - vshift;
          X_vstop_i  <=  vshift_direction ? `VSTOP_PAL_LX1  + vshift : `VSTOP_PAL_LX1  - vshift;
        end else begin
          X_hstart_i <= !hshift_direction ? `HSTART_NTSC + hshift : `HSTART_NTSC - hshift;
//          X_hstop_i  <= !hshift_direction ? `HSTOP_NTSC  + hshift : `HSTOP_NTSC  - hshift;
          X_vstart_i <=  vshift_direction ? `VSTART_NTSC_LX1 + vshift : `VSTART_NTSC_LX1 - vshift;
          X_vstop_i  <=  vshift_direction ? `VSTOP_NTSC_LX1  + vshift : `VSTOP_NTSC_LX1  - vshift;
        end
      
        if (interlaced & !vdata_bob_deinterlacing_mode_i) begin
          Y_field_id_i <= negedge_nHSYNC; // negedge at nHSYNC, too -> odd frame
          Y_field_cnt_i  <= negedge_nHSYNC ? Y_field_cnt_i + 1'b1 : Y_field_cnt_i;
        end else begin
          Y_field_id_i <= 1'b1;
          Y_field_cnt_i <= Y_field_cnt_i + 1'b1;
        end
        Y_vcnt_i_L <= {vcnt_width{1'b0}};
      end
    end
  end

always @(posedge VCLK_i or negedge nRST_i)
  if (!nRST_i) begin
    lineid_pre_sdram_buf <= 1'b0;
    hcnt_pre_sdram_buf <= {hpos_width{1'b0}};
    vdata_pre_sdram_buf_in_cnt <= 10'd0;
    datainfo_pre_sdram_buf <= 4'h0;
    datainfo_rdy <= 1'b0;
  end else begin
    if (vdata_valid_i) begin
      if (Y_input_proc_en & ((Y_vcnt_i_L >= X_vstart_i && Y_vcnt_i_L < X_vstop_i))) begin
        if (hcnt_i_L >= X_hstart_i) begin
          if (hcnt_pre_sdram_buf < `ACTIVE_PIXEL_PER_LINE) begin
            vdata_pre_sdram_buf[vdata_pre_sdram_buf_in_cnt] <= vdata_i_L;
            vdata_pre_sdram_buf_in_cnt <= vdata_pre_sdram_buf_in_cnt + 10'd1; // increase running counter by 1
          end
          hcnt_pre_sdram_buf <= hcnt_pre_sdram_buf + 1'b1;
        end else begin
          hcnt_pre_sdram_buf <= 0;
        end
        if (hcnt_pre_sdram_buf == `ACTIVE_PIXEL_PER_LINE - 52) begin // write page info early
          datainfo_pre_sdram_buf <= {Y_field_id_i,Y_field_cnt_i,Y_field_rdy4out};
          datainfo_rdy <= 1'b1;
        end
      end
      if (datainfo_rdy) begin // change page delayed to page info write to avoid racing conditions to SDRAM clock domain
        lineid_pre_sdram_buf <= ~lineid_pre_sdram_buf;
        datainfo_rdy <= 1'b00;
      end
    end
  end


// +-----------+
// | sdram rtl |
// +-----------+

// resync register

register_sync_2 #(
  .reg_width(5),
  .reg_preset(5'd0),
  .resync_stages(resync_stages)
) register_sync_vclki2dram_u0 (
  .nrst(async_nRST_i),
  .clk_i(VCLK_i),
  .clk_i_en(1'b1),
  .reg_i({datainfo_pre_sdram_buf,lineid_pre_sdram_buf}),
  .clk_o(DRAM_CLK_i),
  .clk_o_en(1'b1),
  .reg_o({datainfo_pre_sdram_buf_sdr_clk_resynced,lineid_pre_sdram_buf_sdr_clk_resynced})
);

register_sync_2 #(
  .reg_width(12),
  .reg_preset({12{1'b0}}),
  .resync_stages(resync_stages)
) register_sync_vclko2dram_u1 (
  .nrst(async_nRST_i),
  .clk_i(VCLK_o),
  .clk_i_en(1'b1),
  .reg_i(Y_vcnt_o_L),
  .clk_o(DRAM_CLK_i),
  .clk_o_en(1'b1),
  .reg_o(vcnt_o_sdr_clk_resynced)
);

register_sync_2 #(
  .reg_width(2),
  .reg_preset(2'b00),
  .resync_stages(resync_stages)
) register_sync_vclko2dram_u2 (
  .nrst(async_nRST_i),
  .clk_i(VCLK_o),
  .clk_i_en(1'b1),
  .reg_i(rdpage_post_sdram_buf),
  .clk_o(DRAM_CLK_i),
  .clk_o_en(1'b1),
  .reg_o(rdpage_slbuf_sdr_clk_resynced)
);


// sdram controller
sdram_ctrl #(
  .SDRAM_MHZ(1000/7),
  .SDRAM_CL(3),
  .INPUT_SHIFT_WINDOW(1),
  .SDRAM_TREFI_NS(15500)
) sdram_ctrl_u (
  .CLK_i(DRAM_CLK_i),
  .nRST_i(DRAM_nRST_i),
  .req_i(sdram_req_i),
  .we_i(sdram_wr_en_i),
  .addr_i(sdram_addr_i),
  .data_i({4'h0,sdram_data_i[23:12],4'h0,sdram_data_i[11:0]}),
  .data_o({sdram_data_dummy_o[7:4],sdram_data_o[23:12],sdram_data_dummy_o[3:0],sdram_data_o[11:0]}),
  .cmd_ack_o(sdram_cmd_ack_o),
  .data_ack_o(sdram_data_ack_o),
  .sdram_ctrl_rdy_o(sdram_ctrl_rdy_o),
  .sdram_cke_o(DRAM_CKE),
  .sdram_cs_o(DRAM_nCS),
  .sdram_ras_o(DRAM_nRAS),
  .sdram_cas_o(DRAM_nCAS),
  .sdram_we_o(DRAM_nWE),
  .sdram_dqm_o(DRAM_DQM),
  .sdram_addr_o(DRAM_ADDR),
  .sdram_ba_o(DRAM_BA),
  .sdram_data_io(DRAM_DQ)
);

// read configuration
always @(posedge DRAM_CLK_i)
  if (vcnt_o_sdr_clk_resynced == 0)
    X_vpos_1st_rdline <= video_vpos_1st_rdline_i;

// write data from sdram into post buffer
assign wren_post_sdram_buf_p0_w = (wrpage_post_sdram_buf == 2'b00) & wren_post_sdram_buf;
assign wren_post_sdram_buf_p1_w = (wrpage_post_sdram_buf == 2'b01) & wren_post_sdram_buf;
assign wren_post_sdram_buf_p2_w = (wrpage_post_sdram_buf == 2'b10) & wren_post_sdram_buf;

always @(posedge DRAM_CLK_i) begin
  if (wren_post_sdram_buf_p_L[0])
    vdata3_post_sdram_buf_p0[wraddr_post_sdram_buf_main] <= {vdata3_for_post_sdram_buf[0],vdata3_for_post_sdram_buf[1],vdata3_for_post_sdram_buf[2]};
  if (wren_post_sdram_buf_p_L[1])
    vdata3_post_sdram_buf_p1[wraddr_post_sdram_buf_main] <= {vdata3_for_post_sdram_buf[0],vdata3_for_post_sdram_buf[1],vdata3_for_post_sdram_buf[2]};
  if (wren_post_sdram_buf_p_L[2])
    vdata3_post_sdram_buf_p2[wraddr_post_sdram_buf_main] <= {vdata3_for_post_sdram_buf[0],vdata3_for_post_sdram_buf[1],vdata3_for_post_sdram_buf[2]};
  
  wren_post_sdram_buf_p_L <= {wren_post_sdram_buf_p2_w,wren_post_sdram_buf_p1_w,wren_post_sdram_buf_p0_w};
end

// sdram control logic
// SDRAM addr_usage:
// - row LSB0 and 8bits dblcolumn: pixel count per line
// - row (11:1): line count
// - row (12  ): one unused bit
// - bank: frame page (allows for four frames in sdram)
//
// deinterlacing:
//   - bob deinterlacing -> pushing even and odd frames into different frame pages (first implementation attempt)
//   - true interlacing -> pushing even and odd frame into same frame page
//                         repeating each frame twice

assign datainfo_pre_sdram_buf_field_id_w = datainfo_pre_sdram_buf_sdr_clk_resynced[3];
assign datainfo_pre_sdram_buf_bank_sel_w = datainfo_pre_sdram_buf_sdr_clk_resynced[2:1];
assign datainfo_pre_sdram_buf_field_rdy4out_w = datainfo_pre_sdram_buf_sdr_clk_resynced[0];

always @(*) begin
  if (wrpage_post_sdram_buf[1]) begin
    wrpage_post_sdram_buf_cmb <= 2'b00;
  end else begin
    wrpage_post_sdram_buf_cmb[1] <=  wrpage_post_sdram_buf[0];
    wrpage_post_sdram_buf_cmb[0] <= ~wrpage_post_sdram_buf[0];
  end
end

always @(*) begin
  if (wraddr_post_sdram_buf_sub == 2'b10) begin
    wraddr_post_sdram_buf_main_next_cmb <= wraddr_post_sdram_buf_main + 1'b1;
    wraddr_post_sdram_buf_sub_next_cmb <= 2'b00;
  end else begin
    wraddr_post_sdram_buf_main_next_cmb <= wraddr_post_sdram_buf_main;
    wraddr_post_sdram_buf_sub_next_cmb <= wraddr_post_sdram_buf_sub + 1'b01;
  end
end

always @(posedge DRAM_CLK_i or negedge nRST_DRAM_proc)
  if (!nRST_DRAM_proc) begin
    sdram_proc_en <= 1'b0;
    sdram_ctrl_state <= ST_SDRAM_WAIT;
    
    sdram_req_i <= 1'b0;
    sdram_wr_en_i <= 1'b0;
    sdram_addr_i <= {23{1'b0}};
    sdram_data_i <= {(3*color_width_o){1'b0}};
    
    sdram_wr_lineid <= 1'b0;
    sdram_wr_bank_sel_odd <= 2'b00;
    sdram_wr_bank_sel_even <= 2'b00;
    sdram_wr_vcnt <= {vcnt_width{1'b0}};
    sdram_wr_hcnt <= {hpos_width{1'b0}};

    vdata_pre_sdram_buf_out_cnt <= 10'd0;
    
    sdram_use_interlaced_out <= 1'b0;
    sdram_bank_rdy4out_odd <= 2'b00;
    sdram_bank_rdy4out_even <= 2'b00;
    sdram_rd_bank_sel_current <= 2'b00;
    sdram_rd_bank_sel_odd <= 2'b00;
    sdram_rd_bank_sel_even <= 2'b00;
    sdram_rd_vcnt <= {(vcnt_width+1){1'b0}};
    sdram_rd_hcnt <= {hpos_width{1'b0}};
    
    wren_post_sdram_buf <= 1'b0;
    wrcnt_post_sdram_buf <= {hpos_width{1'b0}};
    wraddr_post_sdram_buf_main <= 8'h00;
    wraddr_post_sdram_buf_sub <= 2'b00;
    wrpage_post_sdram_buf <= 2'b00;
    
    vdata3_for_post_sdram_buf[0] <= {(3*color_width_o){1'b0}};
    vdata3_for_post_sdram_buf[1] <= {(3*color_width_o){1'b0}};
    vdata3_for_post_sdram_buf[2] <= {(3*color_width_o){1'b0}};
  end else begin
    case (sdram_ctrl_state)
      ST_SDRAM_WAIT: begin
          sdram_proc_en <= 1'b1;
          if (sdram_wr_lineid ^ lineid_pre_sdram_buf_sdr_clk_resynced) begin
            // - Buffer hat umgeschaltet -> Elemente im SDRAM sichern
            if (datainfo_pre_sdram_buf_field_id_w) begin
              if (datainfo_pre_sdram_buf_bank_sel_w  != sdram_wr_bank_sel_odd) begin
                sdram_wr_bank_sel_odd  <= datainfo_pre_sdram_buf_bank_sel_w;  // set new bank for frame
                sdram_wr_vcnt <= {vcnt_width{1'b0}};                          // reset vertical position
                sdram_addr_i[22:21] <= datainfo_pre_sdram_buf_bank_sel_w;     // use new bank for frame
                sdram_addr_i[19:10] <= {{vcnt_width{1'b0}},1'b1};             // use vertical position zero
              end else begin
                sdram_addr_i[22:21] <= sdram_wr_bank_sel_odd; // set bank for frame
                sdram_addr_i[19:10] <= {sdram_wr_vcnt,1'b1};  // set vertical position
              end
              if (datainfo_pre_sdram_buf_field_rdy4out_w) // update output field if current input field is fairly ahead
                sdram_bank_rdy4out_odd  <= sdram_wr_bank_sel_odd;
            end else begin
              if (datainfo_pre_sdram_buf_bank_sel_w != sdram_wr_bank_sel_even) begin
                sdram_wr_bank_sel_even  <= datainfo_pre_sdram_buf_bank_sel_w; // set new bank for frame
                sdram_wr_vcnt <= {vcnt_width{1'b0}};                          // reset vertical position
                sdram_addr_i[22:21] <= datainfo_pre_sdram_buf_bank_sel_w;     // use new bank for frame
                sdram_addr_i[19:10] <= {{vcnt_width{1'b0}},1'b0};             // use vertical position zero
              end else begin
                sdram_addr_i[22:21] <= sdram_wr_bank_sel_even;  // set bank for frame
                sdram_addr_i[19:10] <= {sdram_wr_vcnt,1'b0};    // set vertical position
              end
              if (datainfo_pre_sdram_buf_field_rdy4out_w) // update output field if current input field is fairly ahead
                sdram_bank_rdy4out_even <= sdram_wr_bank_sel_even;
            end
            sdram_addr_i[20   ] <= 1'b0;                // unused
            sdram_addr_i[ 9: 0] <= {hpos_width{1'b0}};  // horizontal position
            sdram_wr_hcnt <= {hpos_width{1'b0}};
            sdram_ctrl_state <= ST_SDRAM_FIFO2RAM0;
          end else if (vcnt_o_sdr_clk_resynced == 1) begin // fetch first line
            sdram_use_interlaced_out <= interlaced_dramclk_resynced & video_deinterlacing_mode_i; // handle bob deinterlacing as non-deinterlacing
            if (interlaced_dramclk_resynced & video_deinterlacing_mode_i) begin
              sdram_rd_bank_sel_current <= X_vpos_1st_rdline[0] ? sdram_bank_rdy4out_even : sdram_bank_rdy4out_odd;
              sdram_rd_vcnt <= X_vpos_1st_rdline;
            end else begin
              sdram_rd_bank_sel_current <= sdram_bank_rdy4out_odd;
              sdram_rd_vcnt <= {X_vpos_1st_rdline,1'b1};  // X_vpos_1st_rdline is in this case maxed out due to progressive mode, so consider 2x
            end
            sdram_rd_bank_sel_odd  <= sdram_bank_rdy4out_odd;
            sdram_rd_bank_sel_even <= sdram_bank_rdy4out_even;
            sdram_rd_hcnt <= {hpos_width{1'b0}};
            wrpage_post_sdram_buf <= 2'b00;
            wrcnt_post_sdram_buf <= {hpos_width{1'b1}};
            wraddr_post_sdram_buf_main <= 8'hff;
            wraddr_post_sdram_buf_sub <= 2'b10;
            sdram_ctrl_state <= ST_SDRAM_RAM2BUF0;
          end else if (vcnt_o_sdr_clk_resynced > 1 &&
                       wrpage_post_sdram_buf_cmb != rdpage_slbuf_sdr_clk_resynced ) begin  // fetch concurrent lines on demand
            if (sdram_use_interlaced_out) begin
              sdram_rd_bank_sel_current <= sdram_rd_vcnt[0] ? sdram_rd_bank_sel_even : sdram_rd_bank_sel_odd; // toggle between even and odd field bank
              sdram_rd_vcnt <= sdram_rd_vcnt + 1'b1;
            end else begin
              sdram_rd_bank_sel_current <= sdram_rd_bank_sel_odd;
              sdram_rd_vcnt <= sdram_rd_vcnt + 2'b10;
            end
            sdram_rd_hcnt <= {hpos_width{1'b0}};
            wrpage_post_sdram_buf <= wrpage_post_sdram_buf_cmb;
            wrcnt_post_sdram_buf <= {hpos_width{1'b1}};
            wraddr_post_sdram_buf_main <= 8'hff;
            wraddr_post_sdram_buf_sub <= 2'b10;
            sdram_ctrl_state <= ST_SDRAM_RAM2BUF0;
          end
        end
      ST_SDRAM_FIFO2RAM0: begin
          // - frage Schreiben in SDRAM an
          sdram_req_i <= 1'b1;
          sdram_wr_en_i <= 1'b1;
          sdram_data_i <= vdata_pre_sdram_buf[vdata_pre_sdram_buf_out_cnt];
          vdata_pre_sdram_buf_out_cnt <= vdata_pre_sdram_buf_out_cnt + 10'd1;
          sdram_wr_hcnt <= sdram_wr_hcnt + 1'b1;
          sdram_ctrl_state <= ST_SDRAM_FIFO2RAM1;
        end
      ST_SDRAM_FIFO2RAM1: begin
          // - frage Schreiben an
          // - setze mit oberstem FIFO-Element Startadresse für kommenden 640 Elemente
          // - schreibe 640 Elemente in SDRAM
          if (sdram_cmd_ack_o) begin
            sdram_addr_i[9:0] <= sdram_wr_hcnt;
            if (sdram_wr_hcnt < `ACTIVE_PIXEL_PER_LINE) begin
              sdram_data_i <= vdata_pre_sdram_buf[vdata_pre_sdram_buf_out_cnt];
              vdata_pre_sdram_buf_out_cnt <= vdata_pre_sdram_buf_out_cnt + 10'd1;
            end
            sdram_wr_hcnt <= sdram_wr_hcnt + 1'b1;
            if (sdram_wr_hcnt == `ACTIVE_PIXEL_PER_LINE) begin
              sdram_req_i <= 1'b0;
              sdram_wr_en_i <= 1'b0;
              sdram_ctrl_state <= ST_SDRAM_WAIT;
              sdram_wr_vcnt <= sdram_wr_vcnt + 1'b1;  // increment vertical position
              sdram_wr_lineid <= ~sdram_wr_lineid;
            end
          end
        end
      ST_SDRAM_RAM2BUF0: begin
          sdram_req_i <= 1'b1;
          sdram_addr_i[22:21] <= sdram_rd_bank_sel_current; // bank for frame
          sdram_addr_i[20   ] <= 1'b0;              // unused
          sdram_addr_i[19:10] <= sdram_rd_vcnt;     // vertical position
          sdram_addr_i[ 9: 0] <= sdram_rd_hcnt;     // horizontal position
          sdram_rd_hcnt <= sdram_rd_hcnt + 1'b1;
          sdram_ctrl_state <= ST_SDRAM_RAM2BUF1;
        end
      ST_SDRAM_RAM2BUF1: begin
          if (sdram_cmd_ack_o) begin
            sdram_req_i <= (sdram_rd_hcnt < `ACTIVE_PIXEL_PER_LINE);
            sdram_addr_i[ 9: 0] <= sdram_rd_hcnt;   // horizontal position
            sdram_rd_hcnt <= sdram_rd_hcnt + 1'b1;
          end
          if (sdram_data_ack_o) begin
            wren_post_sdram_buf <= 1'b1;
            wrcnt_post_sdram_buf <= wrcnt_post_sdram_buf + 1'b1;
            wraddr_post_sdram_buf_main <= wraddr_post_sdram_buf_main_next_cmb;
            wraddr_post_sdram_buf_sub <= wraddr_post_sdram_buf_sub_next_cmb;
            vdata3_for_post_sdram_buf[wraddr_post_sdram_buf_sub_next_cmb] <= sdram_data_o;
          end else begin
            wren_post_sdram_buf <= 1'b0;
            if (wrcnt_post_sdram_buf == `ACTIVE_PIXEL_PER_LINE - 1)
              sdram_ctrl_state <= ST_SDRAM_WAIT;
          end
        end
      default:
        sdram_ctrl_state <= ST_SDRAM_WAIT;
    endcase
  end



// +------------+
// | output rtl |
// +------------+

// resync registers
register_sync_2 #(
  .reg_width(vcnt_width),
  .reg_preset({(vcnt_width){1'b0}}),
  .resync_stages(resync_stages)
) register_sync_input2hdmi_u0 (
  .nrst(async_nRST_i),
  .clk_i(VCLK_i),
  .clk_i_en(1'b1),
  .reg_i(Y_vcnt_i_L),
  .clk_o(VCLK_o),
  .clk_o_en(1'b1),
  .reg_o(vcnt_i_vclk_o_resynced)
);

register_sync_2 #(
  .reg_width(1),
  .reg_preset(1'b0),
  .resync_stages(resync_stages)
) register_sync_input2hdmi_u1 (
  .nrst(async_nRST_i),
  .clk_i(VCLK_i),
  .clk_i_en(1'b1),
  .reg_i(Y_in2out_en),
  .clk_o(VCLK_o),
  .clk_o_en(1'b1),
  .reg_o(in2out_en_resynced)
);

// read configuration for output
assign X_vpos_px_offset_w = (video_vlines_out_i < X_VACTIVE_OS) ? (X_VACTIVE_OS - video_vlines_out_i)/2 : 11'd0;
assign X_hpos_px_offset_w = (video_hpixel_out_i < X_HACTIVE_OS) ? (X_HACTIVE_OS - video_hpixel_out_i)/2 : 12'd0;

always @(posedge VCLK_o)
  if (Y_cfg_v_update_window) begin
    if (Y_cfg_h_update_window == 4'h0) begin
      setVideoVTimings(video_config_i,X_VSYNC_active,X_VSYNCLEN,X_VSTART,X_VACTIVE,X_VSTOP,X_VSTART_OS,X_VACTIVE_OS,X_VSTOP_OS,X_VTOTAL);
      setVideoHTimings(video_config_i,X_HSYNC_active,X_HSYNCLEN,X_HSTART,X_HACTIVE,X_HSTOP,X_HSTART_OS,X_HACTIVE_OS,X_HSTOP_OS,X_HTOTAL);
    end else if (Y_cfg_h_update_window == 4'h4) begin
      X_VSTART_px <= X_VSTART_OS + X_vpos_px_offset_w;
      X_VSTOP_px <= X_VSTOP_OS - X_vpos_px_offset_w;
      X_HSTART_px <= X_HSTART_OS + X_hpos_px_offset_w;
      X_HSTOP_px <= X_HSTOP_OS - X_hpos_px_offset_w;
      
      X_video_interpolation_mode <= video_interpolation_mode_i;
      
      X_pix_vlines_in_needed <= video_vlines_in_needed_i;
      X_pix_vlines_in_full <= {1'b0,video_vlines_in_full_i};
      X_pix_vlines_out_max <= video_vlines_out_i;
      X_pix_init_vline_cnt_phase <= |X_video_interpolation_mode ? video_vlines_out_i/2 : 0;
      X_pix_v_interpfactor <= video_v_interpfactor_i;
      
      X_pix_hpixel_addr_mult2 <= ~video_hpixel_in_full_i[9];
      X_pix_hpixel_in_needed <= video_hpixel_in_needed_i;
      X_pix_hpixel_in_full <= {2'b00,video_hpixel_in_full_i};
      X_pix_hpixel_out_max <= video_hpixel_out_i;
      X_init_hpixel_cnt_phase <= |X_video_interpolation_mode ? video_hpixel_out_i/2 : 0;
      X_pix_h_interpfactor <= video_h_interpfactor_i;
      
      hpos_1st_rdpixel_decr <= video_hpos_1st_rdpixel_i;
      hpos_1st_rdpixel_main <= 8'h00;
      hpos_1st_rdpixel_sub <= ~video_hpixel_in_full_i[9] ? 2'b00 : {1'b0,!palmode_vclk_o_resynced};
    end else begin
      if (|hpos_1st_rdpixel_decr) begin
        hpos_1st_rdpixel_decr <= hpos_1st_rdpixel_decr - 1'b1;
        if (X_pix_hpixel_addr_mult2) begin
          if (|hpos_1st_rdpixel_sub)
            hpos_1st_rdpixel_main <= hpos_1st_rdpixel_main + 1'b1;
          hpos_1st_rdpixel_sub[0] <= hpos_1st_rdpixel_sub[1];
          hpos_1st_rdpixel_sub[1] <= ~|hpos_1st_rdpixel_sub;
        end else begin
          if (hpos_1st_rdpixel_sub[1]) begin
            hpos_1st_rdpixel_main <= hpos_1st_rdpixel_main + 1'b1;
            hpos_1st_rdpixel_sub <= 2'b00;
          end else begin
            hpos_1st_rdpixel_main <= hpos_1st_rdpixel_main;
            hpos_1st_rdpixel_sub[1] <= hpos_1st_rdpixel_sub[0];
            hpos_1st_rdpixel_sub[0] <= ~hpos_1st_rdpixel_sub[0];
          end
        end
      end else begin
        X_hpos_1st_rdpixel_main <= hpos_1st_rdpixel_main;
        X_hpos_1st_rdpixel_sub <= hpos_1st_rdpixel_sub;
      end
    end
  end

// read pixel data from post sdram buffer into pre-fetch buffer for interpolation
assign rden_post_sdram_buf_p0_w = ((rdpage_post_sdram_buf == 2'b00) & rden_post_sdram_buf) | ((rdpage_post_sdram_buf_cmb == 2'b00) & rden_post_sdram_buf);
assign rden_post_sdram_buf_p1_w = ((rdpage_post_sdram_buf == 2'b01) & rden_post_sdram_buf) | ((rdpage_post_sdram_buf_cmb == 2'b01) & rden_post_sdram_buf);
assign rden_post_sdram_buf_p2_w = ((rdpage_post_sdram_buf == 2'b10) & rden_post_sdram_buf) | ((rdpage_post_sdram_buf_cmb == 2'b10) & rden_post_sdram_buf);

always @(posedge VCLK_o) begin
  if (rden_post_sdram_buf_L[0])
    {vdata_pixel_buf_p0[0],vdata_pixel_buf_p0[1],vdata_pixel_buf_p0[2]} <= vdata3_post_sdram_buf_p0[rdaddr_post_sdram_buf_main_L];
  if (rden_post_sdram_buf_L[1])
    {vdata_pixel_buf_p1[0],vdata_pixel_buf_p1[1],vdata_pixel_buf_p1[2]} <= vdata3_post_sdram_buf_p1[rdaddr_post_sdram_buf_main_L];
  if (rden_post_sdram_buf_L[2])
    {vdata_pixel_buf_p2[0],vdata_pixel_buf_p2[1],vdata_pixel_buf_p2[2]} <= vdata3_post_sdram_buf_p2[rdaddr_post_sdram_buf_main_L];
  
  rden_post_sdram_buf_L <= {rden_post_sdram_buf_p2_w,rden_post_sdram_buf_p1_w,rden_post_sdram_buf_p0_w};
  rdaddr_post_sdram_buf_main_L <= rdaddr_post_sdram_buf_main;
  rdaddr_post_sdram_buf_sub_LL <= rdaddr_post_sdram_buf_sub_L;
  rdaddr_post_sdram_buf_sub_L <= rdaddr_post_sdram_buf_sub;
end


// filter / interpolation
assign pix_v_a0_current_w = Y_pix_v_a0_current[7:0];
assign pix_v_a1_current_w = ~Y_pix_v_a0_current[7:0] + 8'h01;

assign pix_v_bypass_z1_w = (!X_video_interpolation_mode[1] & (pix_v_a1_current_w > FILT_AX_SHARP_TH)) | ~|Y_pix_v_a0_current  | Y_pix_v_bypass_z1_current;
assign pix_v_bypass_z0_w = (!X_video_interpolation_mode[1] & (pix_v_a0_current_w > FILT_AX_SHARP_TH)) | Y_pix_v_a0_current[8] | Y_pix_v_bypass_z0_current;

assign fir_v_calcopcode_w[1] = pix_v_bypass_z1_w |  pix_v_bypass_z0_w;
assign fir_v_calcopcode_w[0] = pix_v_bypass_z1_w & ~pix_v_bypass_z0_w;

assign pix_h_a0_current_w = pix_h_a0_current[GEN_SIGNALLING_DELAY+LOAD_PIXEL_BUF_DELAY+VERT_INTERP_DELAY-1][7:0];
assign pix_h_a1_current_w = ~pix_h_a0_current[GEN_SIGNALLING_DELAY+LOAD_PIXEL_BUF_DELAY+VERT_INTERP_DELAY-1][7:0] + 8'h01;

assign pix_h_bypass_z1_w = (!X_video_interpolation_mode[1] & (pix_h_a1_current_w > FILT_AX_SHARP_TH)) | ~|pix_h_a0_current[GEN_SIGNALLING_DELAY+LOAD_PIXEL_BUF_DELAY+VERT_INTERP_DELAY-1]  | pix_h_bypass_z1_current[GEN_SIGNALLING_DELAY+LOAD_PIXEL_BUF_DELAY+VERT_INTERP_DELAY-1];
assign pix_h_bypass_z0_w = (!X_video_interpolation_mode[1] & (pix_h_a0_current_w > FILT_AX_SHARP_TH)) | pix_h_a0_current[GEN_SIGNALLING_DELAY+LOAD_PIXEL_BUF_DELAY+VERT_INTERP_DELAY-1][8] | pix_h_bypass_z0_current[GEN_SIGNALLING_DELAY+LOAD_PIXEL_BUF_DELAY+VERT_INTERP_DELAY-1];

assign fir_h_calcopcode_w[1] = pix_h_bypass_z1_w |  pix_h_bypass_z0_w;
assign fir_h_calcopcode_w[0] = pix_h_bypass_z1_w & ~pix_h_bypass_z0_w;

assign rd_vdata_slbuf_p0 = vdata_pixel_buf_p0[rdaddr_post_sdram_buf_sub_LL];
assign rd_vdata_slbuf_p1 = vdata_pixel_buf_p1[rdaddr_post_sdram_buf_sub_LL];
assign rd_vdata_slbuf_p2 = vdata_pixel_buf_p2[rdaddr_post_sdram_buf_sub_LL];

assign rd_vdata_slbuf = (rdpage_post_sdram_buf == 2'b00) ? rd_vdata_slbuf_p0 :
                        (rdpage_post_sdram_buf == 2'b01) ? rd_vdata_slbuf_p1 :
                                                  rd_vdata_slbuf_p2;
assign rd_vdata_next_slbuf = (rdpage_post_sdram_buf_cmb == 2'b00) ? rd_vdata_slbuf_p0 :
                             (rdpage_post_sdram_buf_cmb == 2'b01) ? rd_vdata_slbuf_p1 :
                                                                    rd_vdata_slbuf_p2;

polyphase_2step_fir v_interpolate_red_u (
  .CLK_i(VCLK_o),
  .nRST_i(nRST_o),
  .fir_inopcode_i(3'b100),
  .fir_calcopcode_i(fir_v_calcopcode_w),
  .fir_data_i(8'h00),
  .coeff_a0_i(pix_v_a0_current_w),
  .coeff_a1_i(pix_v_a1_current_w),
  .fir_data_z0_init_i(rd_vdata_next_slbuf[`VDATA_O_RE_SLICE]),
  .fir_data_z1_init_i(rd_vdata_slbuf[`VDATA_O_RE_SLICE]),
  .result_data_o(red_v_interp_out)
);

polyphase_2step_fir h_interpolate_red_u (
  .CLK_i(VCLK_o),
  .nRST_i(nRST_o),
  .fir_inopcode_i(3'b001),
  .fir_calcopcode_i(fir_h_calcopcode_w),
  .fir_data_i(red_v_interp_out),
  .coeff_a0_i(pix_h_a0_current_w),
  .coeff_a1_i(pix_h_a1_current_w),
  .fir_data_z0_init_i(8'h00),
  .fir_data_z1_init_i(8'h00),
  .result_data_o(red_h_interp_out)
);

polyphase_2step_fir v_interpolate_gr_u (
  .CLK_i(VCLK_o),
  .nRST_i(nRST_o),
  .fir_inopcode_i(3'b100),
  .fir_calcopcode_i(fir_v_calcopcode_w),
  .fir_data_i(8'h00),
  .coeff_a0_i(pix_v_a0_current_w),
  .coeff_a1_i(pix_v_a1_current_w),
  .fir_data_z0_init_i(rd_vdata_next_slbuf[`VDATA_O_GR_SLICE]),
  .fir_data_z1_init_i(rd_vdata_slbuf[`VDATA_O_GR_SLICE]),
  .result_data_o(gr_v_interp_out)
);

polyphase_2step_fir h_interpolate_gr_u (
  .CLK_i(VCLK_o),
  .nRST_i(nRST_o),
  .fir_inopcode_i(3'b001),
  .fir_calcopcode_i(fir_h_calcopcode_w),
  .fir_data_i(gr_v_interp_out),
  .coeff_a0_i(pix_h_a0_current_w),
  .coeff_a1_i(pix_h_a1_current_w),
  .fir_data_z0_init_i(8'h00),
  .fir_data_z1_init_i(8'h00),
  .result_data_o(gr_h_interp_out)
);

polyphase_2step_fir v_interpolate_bl_u (
  .CLK_i(VCLK_o),
  .nRST_i(nRST_o),
  .fir_inopcode_i(3'b100),
  .fir_calcopcode_i(fir_v_calcopcode_w),
  .fir_data_i(8'h00),
  .coeff_a0_i(pix_v_a0_current_w),
  .coeff_a1_i(pix_v_a1_current_w),
  .fir_data_z0_init_i(rd_vdata_next_slbuf[`VDATA_O_BL_SLICE]),
  .fir_data_z1_init_i(rd_vdata_slbuf[`VDATA_O_BL_SLICE]),
  .result_data_o(bl_v_interp_out)
);

polyphase_2step_fir h_interpolate_bl_u (
  .CLK_i(VCLK_o),
  .nRST_i(nRST_o),
  .fir_inopcode_i(3'b001),
  .fir_calcopcode_i(fir_h_calcopcode_w),
  .fir_data_i(bl_v_interp_out),
  .coeff_a0_i(pix_h_a0_current_w),
  .coeff_a1_i(pix_h_a1_current_w),
  .fir_data_z0_init_i(8'h00),
  .fir_data_z1_init_i(8'h00),
  .result_data_o(bl_h_interp_out)
);

// control logic for output video
always @(*) begin
  if (rdpage_post_sdram_buf[1]) begin
    rdpage_post_sdram_buf_cmb <= 2'b00;
  end else begin
    rdpage_post_sdram_buf_cmb[1] <=  rdpage_post_sdram_buf[0];
    rdpage_post_sdram_buf_cmb[0] <= ~rdpage_post_sdram_buf[0];
  end
end

always @(*) begin
  Y_vline_cnt_cmb <= Y_vline_cnt + X_pix_vlines_in_full;
  Y_a0_v_full_cmb <= Y_vline_cnt * (* multstyle = "dsp" *) X_pix_v_interpfactor;
  
  hpixel_cnt_cmb <= hpixel_cnt + X_pix_hpixel_in_full;
  a0_h_full_cmb <= hpixel_cnt * (* multstyle = "dsp" *) X_pix_h_interpfactor;
end

always @(posedge VCLK_o or negedge nRST_o)
  if (!nRST_o) begin
    output_proc_en <= 1'b0;
    
    Y_cfg_v_update_window <= 1'b1;
    Y_cfg_h_update_window <= 4'h0;
    
    hcnt_o_L <= 0;
    Y_vcnt_o_L <= 0;
    Y_v_active_de <= 1'b0;
    h_active_de <= 1'b0;
    Y_v_active_px <= 1'b0;
    h_active_px <= 1'b0;
    
    rden_post_sdram_buf <= 1'b0;
    rdpage_post_sdram_buf <= 2'b00;
    rdaddr_post_sdram_buf_main <= 8'h00;
    rdaddr_post_sdram_buf_sub <= 2'b00;
    
    Y_vscale_phase <= HVSCALE_PHASE_INVALID;
    Y_vphase_init_delay <= 1'b1;
    Y_vline_cnt <= 11'd0;
    Y_vline_load_cnt <= 10'd0;
    Y_pix_v_bypass_z0_current <= 1'b0;
    Y_pix_v_bypass_z1_current <= 1'b1;
    Y_pix_v_a0_current <= 9'h080;
    Y_pix_v_a0_pre <= 9'h100;
    
    hscale_phase <= HVSCALE_PHASE_INVALID;
    hpixel_cnt <= 12'd0;
    hpixel_load_cnt <= 10'd0;
    
    pix_h_bypass_z0_current <= {(GEN_SIGNALLING_DELAY+LOAD_PIXEL_BUF_DELAY+VERT_INTERP_DELAY){1'b1}};
    pix_h_bypass_z1_current <= {(GEN_SIGNALLING_DELAY+LOAD_PIXEL_BUF_DELAY+VERT_INTERP_DELAY){1'b0}};
    for (int_idx = H_A0_CALC_DELAY-1; int_idx < (GEN_SIGNALLING_DELAY+LOAD_PIXEL_BUF_DELAY+VERT_INTERP_DELAY); int_idx = int_idx + 1)
      pix_h_a0_current[int_idx] <= 9'h080;
    pix_h_a0_pre <= 9'h100;
    
    Y_scale_vpos_rel <= 8'h00;
    for (int_idx = Videogen_Pipeline_Length-1; int_idx >= H_A0_CALC_DELAY-1; int_idx = int_idx - 1)
      scale_hpos_rel[int_idx] <= 8'h00;
    
    DE_virt_vpl_L <= {(Videogen_Pipeline_Length-GEN_SIGNALLING_DELAY-1){1'b0}};
    HSYNC_vpl_L <= {Videogen_Pipeline_Length{1'b0}};
    VSYNC_vpl_L <= {Videogen_Pipeline_Length{1'b0}};
    DE_vpl_L <= {Videogen_Pipeline_Length{1'b0}};
    vdata_vpl_end_L <= {(3*color_width_o){1'b0}};
    
    vinfo_llm_slbuf_fb_o <= 9'd0;
  end else begin
    output_proc_en <= 1'b1;
    // generate sync
    if (in2out_en_resynced) begin
      if (hcnt_o_L < X_HTOTAL - 1) begin
        Y_cfg_h_update_window <= &Y_cfg_h_update_window ? Y_cfg_h_update_window : Y_cfg_h_update_window + 4'h1;
        hcnt_o_L <= hcnt_o_L + 1;
      end else begin
        Y_cfg_h_update_window <= 4'h0;
        hcnt_o_L <= 0;
      end
      if ((hcnt_o_L == X_HSTART-1) || (hcnt_o_L == X_HSTOP-1))        // next clock cycle either hcnt_o_L == X_HSTART or hcnt_o_L == X_HSTOP
        h_active_de <= ~h_active_de;
      if ((hcnt_o_L == X_HSTART_px-1) || (hcnt_o_L == X_HSTOP_px-1))  // next clock cycle either hcnt_o_L == X_HSTART_px or hcnt_o_L == X_HSTOP_px
        h_active_px <= ~h_active_px;
      if (hcnt_o_L == X_HTOTAL-1) begin
        if (Y_vcnt_o_L < X_VTOTAL - 1) begin
          Y_cfg_v_update_window <= 1'b0;
          Y_vcnt_o_L <= Y_vcnt_o_L + 1;
        end else begin
          Y_cfg_v_update_window <= 1'b1;
          Y_vcnt_o_L <= 0;
          vinfo_llm_slbuf_fb_o <= video_llm_i ? vcnt_i_vclk_o_resynced : 9'd0;
        end
        if ((Y_vcnt_o_L == X_VSTART-1) || (Y_vcnt_o_L == X_VSTOP-1))        // next clock cycle either Y_vcnt_o_L == X_VSTART or Y_vcnt_o_L == X_VSTOP
          Y_v_active_de <= ~Y_v_active_de;
        if ((Y_vcnt_o_L == X_VSTART_px-1) || (Y_vcnt_o_L == X_VSTOP_px-1))  // next clock cycle either Y_vcnt_o_L == X_VSTART_px or Y_vcnt_o_L == X_VSTOP_px
          Y_v_active_px <= ~Y_v_active_px;
      end
    end else begin
      Y_cfg_v_update_window <= 1'b1;
      Y_cfg_h_update_window <= 4'h0;
      Y_vcnt_o_L <= 0;
      hcnt_o_L <= 0;
      Y_v_active_de <= 1'b0;
      h_active_de <= 1'b0;
      Y_v_active_px <= 1'b0;
      h_active_px <= 1'b0;
    end
    if (Y_v_active_px) begin
      if (hcnt_o_L == 0) begin
        case (Y_vscale_phase)
          HVSCALE_PHASE_INIT: begin
              if (Y_vline_cnt_cmb >= {1'b0,X_pix_vlines_out_max} && Y_vline_load_cnt[0]) begin
                Y_vscale_phase <= HVSCALE_PHASE_MAIN;
                Y_pix_v_bypass_z0_current <= 1'b0;
                Y_pix_v_bypass_z1_current <= Y_vline_cnt_cmb[10:0] == X_pix_vlines_out_max;
                Y_vline_cnt <= Y_vline_cnt_cmb - {1'b0,X_pix_vlines_out_max};
              end else begin
                if (Y_vphase_init_delay) begin
                  Y_vphase_init_delay <= 1'b0;
                end else begin
                  Y_vline_cnt <= Y_vline_cnt_cmb[10:0];
                  Y_vline_load_cnt <= 10'd1;
                end
              end
            end
          HVSCALE_PHASE_MAIN: begin
              if (Y_vline_cnt_cmb >= {1'b0,X_pix_vlines_out_max}) begin
                if (Y_vline_load_cnt == X_pix_vlines_in_needed - 1'b1)
                  Y_vscale_phase <= HVSCALE_PHASE_POST;
                Y_vline_cnt <= Y_vline_cnt_cmb - {1'b0,X_pix_vlines_out_max};
                rdpage_post_sdram_buf <= rdpage_post_sdram_buf_cmb;
                Y_pix_v_bypass_z0_current <= 1'b0;
                Y_pix_v_bypass_z1_current <= Y_vline_cnt_cmb[10:0] == X_pix_vlines_out_max;
              end else begin
                Y_vline_cnt <= Y_vline_cnt_cmb[10:0];
                Y_pix_v_bypass_z0_current <= ~|X_video_interpolation_mode;
                Y_pix_v_bypass_z1_current <= 1'b0;
              end
              if (Y_vline_cnt < X_pix_vlines_in_full)
                Y_vline_load_cnt <= Y_vline_load_cnt + 10'd1;
            end
          HVSCALE_PHASE_POST: begin
              if (Y_vline_cnt_cmb >= {1'b0,X_pix_vlines_out_max}) begin
                Y_vscale_phase <= HVSCALE_PHASE_INVALID;
                Y_pix_v_bypass_z0_current <= 1'b1;
                Y_pix_v_bypass_z1_current <= 1'b0;
              end else begin
                Y_vline_cnt <= Y_vline_cnt_cmb[10:0];
                Y_pix_v_bypass_z0_current <= ~|X_video_interpolation_mode;
                Y_pix_v_bypass_z1_current <= 1'b0;
              end
            end
        endcase
      end
    end else begin
      rdpage_post_sdram_buf <= 2'b00;
      Y_vphase_init_delay <= 1'b1;
      Y_vscale_phase <= HVSCALE_PHASE_INIT;
      Y_vline_cnt <= X_pix_init_vline_cnt_phase;
      Y_vline_load_cnt <= 10'd0;
      Y_pix_v_a0_pre <= 9'h100;
      Y_pix_v_bypass_z0_current <= 1'b0;
      Y_pix_v_bypass_z1_current <= 1'b1;
    end
    if (Y_v_active_px & h_active_px) begin
      case (hscale_phase)
        HVSCALE_PHASE_INIT: begin
            hscale_phase <= HVSCALE_PHASE_MAIN;
            hpixel_load_cnt <= 1;
            pix_h_bypass_z0_current[0] <= 1'b1; // always!
            pix_h_bypass_z1_current[0] <= 1'b0; // always!
          end
        HVSCALE_PHASE_MAIN: begin
            if (hpixel_cnt_cmb >= X_pix_hpixel_out_max) begin
              if (hpixel_load_cnt == X_pix_hpixel_in_needed - 1'b1)
                hscale_phase <= HVSCALE_PHASE_POST;
              hpixel_cnt <= hpixel_cnt_cmb - X_pix_hpixel_out_max;
              if (X_pix_hpixel_addr_mult2) begin
                if (|rdaddr_post_sdram_buf_sub)
                  rdaddr_post_sdram_buf_main <= rdaddr_post_sdram_buf_main + 1'b1;
                rdaddr_post_sdram_buf_sub[0] <= rdaddr_post_sdram_buf_sub[1];
                rdaddr_post_sdram_buf_sub[1] <= ~|rdaddr_post_sdram_buf_sub;
              end else begin
                if (rdaddr_post_sdram_buf_sub == 2'b10) begin
                  rdaddr_post_sdram_buf_main <= rdaddr_post_sdram_buf_main + 1'b1;
                  rdaddr_post_sdram_buf_sub <= 2'b00;
                end else begin
                  rdaddr_post_sdram_buf_main <= rdaddr_post_sdram_buf_main;
                  rdaddr_post_sdram_buf_sub[1] <= rdaddr_post_sdram_buf_sub[0];
                  rdaddr_post_sdram_buf_sub[0] <= ~rdaddr_post_sdram_buf_sub[0];
                end
              end
              if (|X_video_interpolation_mode) begin
                pix_h_bypass_z0_current[0] <= 1'b0;
                pix_h_bypass_z1_current[0] <= hpixel_cnt_cmb == X_pix_hpixel_out_max;
              end else begin
                pix_h_bypass_z0_current[0] <= hpixel_cnt_cmb > X_pix_hpixel_out_max ;
                pix_h_bypass_z1_current[0] <= 1'b0;
              end
            end else begin
              hpixel_cnt <= hpixel_cnt_cmb;
              pix_h_bypass_z0_current[0] <= hpixel_load_cnt == 10'd1 ? 1'b1 : ~|X_video_interpolation_mode;
            end
            if (hpixel_cnt < X_pix_hpixel_in_full)
              hpixel_load_cnt <= hpixel_load_cnt + 10'd1;
          end
        HVSCALE_PHASE_POST: begin
            if (hpixel_cnt_cmb >= X_pix_hpixel_out_max) begin
              hscale_phase <= HVSCALE_PHASE_INVALID;
              pix_h_bypass_z0_current[0] <= 1'b1;
              pix_h_bypass_z1_current[0] <= 1'b0;
            end else begin
              hpixel_cnt <= hpixel_cnt_cmb;
              pix_h_bypass_z0_current[0] <= ~|X_video_interpolation_mode;
              pix_h_bypass_z1_current[0] <= 1'b0;
            end
          end
      endcase
      pix_h_a0_pre <= a0_h_full_cmb[22:14];
    end else begin
      hscale_phase <= HVSCALE_PHASE_INIT;
      hpixel_load_cnt <= 10'd0;
      pix_h_bypass_z0_current[0] <= 1'b1;
      pix_h_bypass_z1_current[0] <= 1'b0;
      rdaddr_post_sdram_buf_main <= X_hpos_1st_rdpixel_main;
      rdaddr_post_sdram_buf_sub <= X_hpos_1st_rdpixel_sub;
      hpixel_cnt <= X_init_hpixel_cnt_phase;
      pix_h_a0_pre <= 9'h100;
    end
    
    rden_post_sdram_buf <= Y_v_active_px & h_active_px;
    Y_pix_v_a0_current <= |X_video_interpolation_mode ? {1'b0,Y_pix_v_a0_pre[8:1]} + Y_pix_v_a0_pre[0] : 9'h080;
    Y_pix_v_a0_pre <= Y_a0_v_full_cmb[23:15];
    
    pix_h_bypass_z0_current[GEN_SIGNALLING_DELAY+LOAD_PIXEL_BUF_DELAY+VERT_INTERP_DELAY-1:1] <= pix_h_bypass_z0_current[GEN_SIGNALLING_DELAY+LOAD_PIXEL_BUF_DELAY+VERT_INTERP_DELAY-2:0];
    pix_h_bypass_z1_current[GEN_SIGNALLING_DELAY+LOAD_PIXEL_BUF_DELAY+VERT_INTERP_DELAY-1:1] <= pix_h_bypass_z1_current[GEN_SIGNALLING_DELAY+LOAD_PIXEL_BUF_DELAY+VERT_INTERP_DELAY-2:0];
    for (int_idx = GEN_SIGNALLING_DELAY+LOAD_PIXEL_BUF_DELAY+VERT_INTERP_DELAY-1; int_idx >= H_A0_CALC_DELAY; int_idx = int_idx - 1)
      pix_h_a0_current[int_idx] <= pix_h_a0_current[int_idx-1];
    pix_h_a0_current[H_A0_CALC_DELAY-1] <= |X_video_interpolation_mode ? {1'b0,pix_h_a0_pre[8:1]} + pix_h_a0_pre[0] : 9'h080;
    
    Y_scale_vpos_rel <= {~Y_pix_v_a0_pre[8],Y_pix_v_a0_pre[7:1]} + Y_pix_v_a0_pre[0];
    for (int_idx = Videogen_Pipeline_Length-1; int_idx >= H_A0_CALC_DELAY; int_idx = int_idx - 1)
      scale_hpos_rel[int_idx] <= scale_hpos_rel[int_idx-1];
    scale_hpos_rel[H_A0_CALC_DELAY-1] <= {~pix_h_a0_pre[8],pix_h_a0_pre[7:1]} + pix_h_a0_pre[0];
    
    DE_virt_vpl_L <= {DE_virt_vpl_L[Videogen_Pipeline_Length-3:0],(Y_v_active_px & h_active_px)};
    HSYNC_vpl_L <= {HSYNC_vpl_L[Videogen_Pipeline_Length-2:0],(hcnt_o_L < X_HSYNCLEN) ~^ X_HSYNC_active};
    VSYNC_vpl_L <= {VSYNC_vpl_L[Videogen_Pipeline_Length-2:0],(Y_vcnt_o_L < X_VSYNCLEN) ~^ X_VSYNC_active};
    DE_vpl_L <= {DE_vpl_L[Videogen_Pipeline_Length-2:0],(h_active_de && Y_v_active_de)};
    
    if (DE_virt_vpl_L[Videogen_Pipeline_Length-2] & DE_vpl_L[Videogen_Pipeline_Length-2])
      vdata_vpl_end_L <= {red_h_interp_out,gr_h_interp_out,bl_h_interp_out};
    else
      vdata_vpl_end_L <= {(3*color_width_o){1'b0}};
  end

// assign final outputs
always @(*) begin
  scale_vpos_rel_o <= Y_scale_vpos_rel;
  scale_hpos_rel_o <= scale_hpos_rel[Videogen_Pipeline_Length-1];
  HSYNC_o <= HSYNC_vpl_L[Videogen_Pipeline_Length-1];
  VSYNC_o <= VSYNC_vpl_L[Videogen_Pipeline_Length-1];
  DE_o <= DE_vpl_L[Videogen_Pipeline_Length-1];
  vdata_o <= vdata_vpl_end_L;
end

endmodule
