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
// Module Name:    osd_injection
// Project Name:   N64 Advanced / Advanced 2
//
//////////////////////////////////////////////////////////////////////////////////


module osd_injection #(
  parameter flavor = "N64Adv", // choose either N64Adv or N64Adv2
  parameter bits_per_color = color_width_i,
  parameter vcnt_width = $clog2(`TOTAL_LINES_PAL_LX1),
  parameter hcnt_width = $clog2(`PIXEL_PER_LINE_MAX)
) (
  OSDCLK,
  OSD_VSync,
  OSDWrVector,
  OSDInfo,

  VCLK,
  nVRST,
  
  osd_vscale,
  osd_hscale,
  osd_voffset,
  osd_hoffset,

  vdata_valid_i,
  vdata_i,
  
  active_vsync_i,
  active_hsync_i,
  
  vdata_valid_o,
  vdata_o
);


`include "../../vh/n64adv_cparams.vh"
`include "../../vh/n64adv_vparams.vh"


input OSDCLK;
output reg OSD_VSync;
input [24:0] OSDWrVector;
input [ 1:0] OSDInfo;

input VCLK;
input nVRST;

input [2:0] osd_vscale;
input [1:0] osd_hscale;
input [vcnt_width-1:0] osd_voffset;
input [hcnt_width-1:0] osd_hoffset;

input vdata_valid_i;
input [3*bits_per_color+3:0] vdata_i;

input active_vsync_i;
input active_hsync_i;

output reg vdata_valid_o = 1'b0;
output reg [3*bits_per_color+3:0] vdata_o = {(3*bits_per_color+4){1'b0}};


// Display OSD Menu
// ================

// concept:
// - OSD is virtual screen of size 12x48 chars; each char stored in 2bit color + 8bit ASCCI-code.
//   (for simplicity atm. RAM has 48x16 words)
// - content is mapped into memory and written by NIOSII processor
// - Font is looked up in an extra ROM




// mist stuff (incl. unpacking inputs)
// flavor params
generate
  if (flavor == "N64Adv") begin
    localparam [1023:0] n64adv_logo = 1024'h1FF7FCFF9C1B033FE7FD8180300FF3833FF7FEFFDE1B037FEFFD8180301FFBC330300600DF1B03606C0D8180FFD81BE33037FE00DB9BFF606C0DFF80FFDFFB733037FE00D9DBFF606C0DFF8030CFFB3B30300600D8FB03606C0D818030C01B1F3FF7FEFFD87BFF606FFDFF8030CFFB0F1FF7FCFF9839FE6067FCFF0030CFF307;
    
    localparam vdata_valid_init = 1'b0;
    
    localparam [`VDATA_I_CO_SLICE] osd_logo_color = `OSD_LOGO_COLOR;
    localparam [`VDATA_I_CO_SLICE] font_color_default        = `OSD_TXT_COLOR_WHITE;
    localparam [`VDATA_I_CO_SLICE] osd_txt_color_black       = `OSD_TXT_COLOR_BLACK;
    localparam [`VDATA_I_CO_SLICE] osd_txt_color_grey        = `OSD_TXT_COLOR_GREY;
    localparam [`VDATA_I_CO_SLICE] osd_txt_color_lightgrey   = `OSD_TXT_COLOR_LIGHTGREY;
    localparam [`VDATA_I_CO_SLICE] osd_txt_color_white       = `OSD_TXT_COLOR_WHITE;
    localparam [`VDATA_I_CO_SLICE] osd_txt_color_red         = `OSD_TXT_COLOR_RED;
    localparam [`VDATA_I_CO_SLICE] osd_txt_color_green       = `OSD_TXT_COLOR_GREEN;
    localparam [`VDATA_I_CO_SLICE] osd_txt_color_blue        = `OSD_TXT_COLOR_BLUE;
    localparam [`VDATA_I_CO_SLICE] osd_txt_color_yellow      = `OSD_TXT_COLOR_YELLOW;
    localparam [`VDATA_I_CO_SLICE] osd_txt_color_cyan        = `OSD_TXT_COLOR_CYAN;
    localparam [`VDATA_I_CO_SLICE] osd_txt_color_magenta     = `OSD_TXT_COLOR_MAGENTA;
    localparam [`VDATA_I_CO_SLICE] osd_txt_color_darkorange  = `OSD_TXT_COLOR_DARKORANGE;
    localparam [`VDATA_I_CO_SLICE] osd_txt_color_darkmagenta = `OSD_TXT_COLOR_DARKMAGENTA;
    localparam [`VDATA_I_CO_SLICE] osd_txt_color_tomato      = `OSD_TXT_COLOR_TOMATO;
    localparam [`VDATA_I_CO_SLICE] osd_txt_color_navajowhite = `OSD_TXT_COLOR_NAVAJOWHITE;
    localparam [`VDATA_I_CO_SLICE] osd_txt_color_darkgold    = `OSD_TXT_COLOR_DARKGOLD;
  end else begin
    localparam [1023:0] n64adv_logo = 1024'h000000FE7003FFFFB9F338FF981C3EE60000008148060810654EA5827433E19500000079C805CF9F2340E57204204C8D000000C3A4054F91214ED35274124C850000009FA4054C11284ED3527412E0A1000000997205CF9F2C65B9732C11BCB100000043520208106A53A982981321A90000003ECE01FFFFD9CE677E700E1F67;
    
    localparam vdata_valid_init = 1'b1;
    
    localparam [`VDATA_O_CO_SLICE] osd_logo_color = `OSD_LOGO_COLOR_24;
    localparam [`VDATA_O_CO_SLICE] font_color_default        = `OSD_TXT_COLOR_WHITE_24;
    localparam [`VDATA_O_CO_SLICE] osd_txt_color_black       = `OSD_TXT_COLOR_BLACK_24;
    localparam [`VDATA_O_CO_SLICE] osd_txt_color_grey        = `OSD_TXT_COLOR_GREY_24;
    localparam [`VDATA_O_CO_SLICE] osd_txt_color_lightgrey   = `OSD_TXT_COLOR_LIGHTGREY_24;
    localparam [`VDATA_O_CO_SLICE] osd_txt_color_white       = `OSD_TXT_COLOR_WHITE_24;
    localparam [`VDATA_O_CO_SLICE] osd_txt_color_red         = `OSD_TXT_COLOR_RED_24;
    localparam [`VDATA_O_CO_SLICE] osd_txt_color_green       = `OSD_TXT_COLOR_GREEN_24;
    localparam [`VDATA_O_CO_SLICE] osd_txt_color_blue        = `OSD_TXT_COLOR_BLUE_24;
    localparam [`VDATA_O_CO_SLICE] osd_txt_color_yellow      = `OSD_TXT_COLOR_YELLOW_24;
    localparam [`VDATA_O_CO_SLICE] osd_txt_color_cyan        = `OSD_TXT_COLOR_CYAN_24;
    localparam [`VDATA_O_CO_SLICE] osd_txt_color_magenta     = `OSD_TXT_COLOR_MAGENTA_24;
    localparam [`VDATA_O_CO_SLICE] osd_txt_color_darkorange  = `OSD_TXT_COLOR_DARKORANGE_24;
    localparam [`VDATA_O_CO_SLICE] osd_txt_color_darkmagenta = `OSD_TXT_COLOR_DARKMAGENTA_24;
    localparam [`VDATA_O_CO_SLICE] osd_txt_color_tomato      = `OSD_TXT_COLOR_TOMATO_24;
    localparam [`VDATA_O_CO_SLICE] osd_txt_color_navajowhite = `OSD_TXT_COLOR_NAVAJOWHITE_24;
    localparam [`VDATA_O_CO_SLICE] osd_txt_color_darkgold    = `OSD_TXT_COLOR_DARKGOLD_24;
  end
endgenerate

// other misc
integer int_idx;

localparam logo_vcnt_width = 4;
localparam logo_hcnt_width = 8;

localparam osd_letter_vcnt_width = $clog2(`MAX_HDR_ROWS + `MAX_TEXT_ROWS + `MAX_INFO_ROWS + 3);
localparam font_vcnt_width = $clog2(`OSD_FONT_HEIGHT+1);
localparam txt_vcnt_width = osd_letter_vcnt_width + font_vcnt_width;

localparam osd_letter_hcnt_width = $clog2(`MAX_CHARS_PER_ROW+1);
localparam font_hcnt_width = $clog2(`OSD_FONT_WIDTH+1);
localparam txt_hcnt_width = osd_letter_hcnt_width + font_hcnt_width;

localparam bg_color_sel_width = 2;
localparam bg_color_width = 9; // three bits per channel (do not change this)
localparam [bg_color_width-1:0] window_bg_color_default = `OSD_WINDOW_BGCOLOR_DARKBLUE;

localparam font_color_sel_width = 4;

localparam color_mem_width = bg_color_sel_width + font_color_sel_width;
localparam txt_mem_width = 7;


wire [                      1:0] vd_wrctrl_w       = OSDWrVector[24:23];
wire [osd_letter_hcnt_width-1:0] vd_wrpage_w       = OSDWrVector[22:17];
wire [osd_letter_vcnt_width-1:0] vd_wraddr_w       = OSDWrVector[16:13];
wire [      color_mem_width-1:0] vd_color_wrdata_w = OSDWrVector[12: 7];
wire [        txt_mem_width-1:0] vd_txt_wrdata_w   = OSDWrVector[ 6: 0];

wire show_osd_logo = OSDInfo[1];
wire show_osd      = OSDInfo[0];

wire HSYNC_cur = vdata_i[3*bits_per_color+1];
wire VSYNC_cur = vdata_i[3*bits_per_color+3];


// wires

wire [osd_letter_hcnt_width-1:0] txt_xrdaddr;
wire [osd_letter_vcnt_width-1:0] txt_yrdaddr;
wire [bg_color_sel_width-1:0] bg_color_sel_tmp;
wire [font_color_sel_width-1:0] font_color_sel_tmp;
wire [txt_mem_width-1:0] font_char_select;

wire [`OSD_FONT_WIDTH:0] font_lineword_tmp;

wire [bg_color_width-1:0] window_bg_color_tmp;
wire [3*bits_per_color-1:0] txt_color_tmp; 


// regs
reg [2:0] vd_wrcolor, vd_wrtxt;
reg [osd_letter_hcnt_width-1:0] vd_wrcolor_page, vd_wrtxt_page;
reg [osd_letter_vcnt_width-1:0] vd_wrcolor_addr, vd_wrtxt_addr;
reg [      color_mem_width-1:0] vd_wrcolor_data;
reg [        txt_mem_width-1:0] vd_wrtxt_data;

reg HSYNC_pre = 1'b0;
reg VSYNC_pre = 1'b0;

reg [2:0] Y_vcnt_delay = 3'b000;
reg [1:0] hcnt_delay = 2'b00;
reg [vcnt_width-1:0] Y_vcnt = {vcnt_width{1'b0}};
reg [hcnt_width-1:0] hcnt = {hcnt_width{1'b0}};

reg [vcnt_width-1:0] X_osd_window_vstart;
reg [vcnt_width-1:0] X_osd_window_vstop;
reg [hcnt_width-1:0] X_osd_window_hstart;
reg [hcnt_width-1:0] X_osd_window_hstop;

reg [vcnt_width-1:0] X_osd_logo_vstart;
reg [vcnt_width-1:0] X_osd_logo_vstop;
reg [hcnt_width-1:0] X_osd_logo_hstart;
reg [hcnt_width-1:0] X_osd_logo_hstop;

reg [vcnt_width-1:0] X_osd_hdr_txt_vstart;
reg [vcnt_width-1:0] X_osd_hdr_txt_vstop;
reg [vcnt_width-1:0] X_osd_txt_vstart;
reg [vcnt_width-1:0] X_osd_txt_vstop;
reg [vcnt_width-1:0] X_osd_info_txt_vstart;
reg [vcnt_width-1:0] X_osd_info_txt_vstop;
reg [hcnt_width-1:0] X_osd_txt_hstart;
reg [hcnt_width-1:0] X_osd_txt_hstop;

reg [2:0] Y_logo_vcnt_delay = 3'b000;
reg [1:0] logo_hcnt_delay = 2'b00;
reg [logo_vcnt_width-1:0] Y_logo_vcnt = {logo_vcnt_width{1'b0}};
reg [logo_hcnt_width-1:0] logo_hcnt = {logo_hcnt_width{1'b1}};

reg [2:0] Y_txt_vcnt_delay = 3'b000;
reg [1:0] txt_hcnt_delay = 2'b00;
reg [osd_letter_vcnt_width-1:0] Y_txt_vcnt_msb = {osd_letter_vcnt_width{1'b0}}; // MSB indexing actual letter (vertical count)
reg [font_vcnt_width-1:0] Y_txt_vcnt_lsb = {font_vcnt_width{1'b0}};             // LSB indexing actual (vertical) position in letter
reg [osd_letter_hcnt_width-1:0] Y_txt_hcnt_msb = {osd_letter_hcnt_width{1'b0}};   // MSB indexing actual letter (horizontal count)
reg [font_hcnt_width-1:0] txt_hcnt_lsb = `OSD_FONT_WIDTH;                       // LSB indexing actual (horizontal) position in letter

reg [7:0] vdata_valid_L = {8{vdata_valid_init}};
reg [3*bits_per_color+3:0] vdata_L [0:7] /* synthesis ramstyle = "logic" */;
initial 
  for (int_idx = 0; int_idx < 8; int_idx = int_idx+1)
    vdata_L[int_idx] = {(3*bits_per_color+4){1'b0}};

reg [7:1] draw_osd_window = 7'h0  /* synthesis ramstyle = "logic" */; // draw window
reg [7:1]       draw_logo = 7'h0  /* synthesis ramstyle = "logic" */; // show logo
reg [7:1]     act_logo_px = 7'h0  /* synthesis ramstyle = "logic" */; // indicates an active pixel in logo
reg [7:1]        en_txtrd = 7'h0  /* synthesis ramstyle = "logic" */; // introduce six delay taps
reg [7:2]       en_fontrd = 6'h0  /* synthesis ramstyle = "logic" */; // read font


reg [bg_color_sel_width-1:0] bg_color_sel = {bg_color_sel_width{1'b0}};
reg [font_color_sel_width-1:0] font_color_sel = {font_color_sel_width{1'b0}};

reg [font_hcnt_width+1:0] font_pixel_select_4x = {font_hcnt_width+2{1'b0}};
reg [`OSD_FONT_WIDTH:0] font_lineword = {(`OSD_FONT_WIDTH+1){1'b0}};
reg act_char_px = 1'b0;

reg [bg_color_width-1:0] window_bg_color = window_bg_color_default;
reg [3*bits_per_color-1:0] txt_color = font_color_default;


// flavor wires and assignments
wire vdata_valid_i_w;

wire VSYNC_reset, HSYNC_reset;

wire [2:0] osd_vscale_w;
wire [1:0] osd_hscale_w;
wire [vcnt_width-1:0] osd_voffset_w;
wire [hcnt_width-1:0] osd_hoffset_w;

wire [font_hcnt_width+1:0] init_font_pixel_select_4x_w;
wire [font_hcnt_width+1:0] next_font_pixel_select_4x_w;
wire font_pixel_select_done_w;

generate
  if (flavor == "N64Adv") begin
    assign vdata_valid_i_w = vdata_valid_i;
    
    assign HSYNC_reset = HSYNC_pre & !HSYNC_cur;
    assign VSYNC_reset = VSYNC_pre & !VSYNC_cur;
    
    assign init_font_pixel_select_4x_w = {{(font_hcnt_width+1){1'b0}},1'b1};
    assign next_font_pixel_select_4x_w = font_pixel_select_4x + 1'b1;
    assign font_pixel_select_done_w = (font_pixel_select_4x[font_hcnt_width+1:2] == `OSD_FONT_WIDTH && font_pixel_select_4x[1:0] == 2'b11);
  end else begin
    assign vdata_valid_i_w = 1'b1;
    
    assign HSYNC_reset = active_hsync_i ? !HSYNC_pre & HSYNC_cur : HSYNC_pre & !HSYNC_cur;
    assign VSYNC_reset = active_vsync_i ? !VSYNC_pre & VSYNC_cur : VSYNC_pre & !VSYNC_cur;
    
    assign init_font_pixel_select_4x_w = (osd_hscale == 2'b00) ? {{(font_hcnt_width-1){1'b0}},1'b1,2'b00} : {{(font_hcnt_width+1){1'b0}},1'b1};
    assign next_font_pixel_select_4x_w = (font_pixel_select_4x[1:0] == osd_hscale) ? {(font_pixel_select_4x[font_hcnt_width+1:2] + 1'b1),2'b00} : font_pixel_select_4x + 1'b1;
    assign font_pixel_select_done_w = (font_pixel_select_4x[font_hcnt_width+1:2] == `OSD_FONT_WIDTH && font_pixel_select_4x[1:0] == osd_hscale);
  end
endgenerate

assign osd_vscale_w = osd_vscale;
assign osd_hscale_w = osd_hscale;
assign osd_voffset_w = osd_voffset;
assign osd_hoffset_w = osd_hoffset;


// start of rtl

wire is_hdr_txt_v_area = (Y_vcnt >= X_osd_hdr_txt_vstart) && (Y_vcnt < X_osd_hdr_txt_vstop);
wire is_txt_v_area = (Y_vcnt >= X_osd_txt_vstart) && (Y_vcnt < X_osd_txt_vstop);
wire is_info_txt_v_area = (Y_vcnt >= X_osd_info_txt_vstart) && (Y_vcnt < X_osd_info_txt_vstop);

wire [txt_vcnt_width-font_vcnt_width-1:0] txt_area_offset_w = (Y_vcnt > X_osd_txt_vstart)     ? (`MAX_HDR_ROWS + `MAX_TEXT_ROWS + 2) :
                                                              (Y_vcnt > X_osd_hdr_txt_vstart) ? (`MAX_HDR_ROWS + 1) :
                                                                                                0;

always @(posedge VCLK or negedge nVRST)
  if (!nVRST) begin
    OSD_VSync <= 1'b0;
    
    HSYNC_pre <= 1'b0;
    VSYNC_pre <= 1'b0;
    
    Y_vcnt_delay <= 3'b000;
    hcnt_delay <= 2'b00;
    Y_vcnt <= {vcnt_width{1'b0}};
    hcnt <= {hcnt_width{1'b0}};
    
    Y_logo_vcnt_delay <= 3'b000;
    logo_hcnt_delay <= 2'b00;
    Y_logo_vcnt <= {logo_vcnt_width{1'b0}};
    logo_hcnt <= {logo_hcnt_width{1'b1}};
    
    Y_txt_vcnt_delay <= 3'b000;
    txt_hcnt_delay <= 2'b00;
    Y_txt_vcnt_msb <= {osd_letter_vcnt_width{1'b0}};
    Y_txt_vcnt_lsb <= {font_vcnt_width{1'b0}};
    Y_txt_hcnt_msb <= {osd_letter_hcnt_width{1'b0}};
    txt_hcnt_lsb <= `OSD_FONT_WIDTH;

    vdata_valid_L <= {8{vdata_valid_init}};
    for (int_idx = 0; int_idx < 8; int_idx = int_idx+1)
      vdata_L[int_idx] <= {(3*bits_per_color+4){1'b0}};
    
    draw_osd_window <= 7'h0;
    draw_logo       <= 7'h0;
    act_logo_px     <= 7'h0;
    en_txtrd        <= 7'h0;
    en_fontrd       <= 6'h0;
  end else begin
    if (vdata_valid_i_w) begin
      if (VSYNC_reset) begin
        X_osd_window_vstart <= osd_voffset_w;
        X_osd_window_vstop <= osd_voffset_w + `OSD_WINDOW_VACTIVE;
        X_osd_window_hstart <= osd_hoffset_w;
        X_osd_window_hstop <= osd_hoffset_w + `OSD_WINDOW_HACTIVE;
        X_osd_logo_vstart <= osd_voffset_w + `OSD_LOGO_VOFFSET;
        X_osd_logo_vstop <= osd_voffset_w + `OSD_LOGO_VOFFSET + `OSD_LOGO_VACTIVE;
        X_osd_logo_hstart <= osd_hoffset_w + `OSD_LOGO_HOFFSET;
        X_osd_logo_hstop <= osd_hoffset_w + `OSD_LOGO_HOFFSET + `OSD_LOGO_HACTIVE;
        X_osd_hdr_txt_vstart <= osd_voffset_w + `OSD_HDR_VOFFSET;
        X_osd_hdr_txt_vstop <= osd_voffset_w + `OSD_HDR_VOFFSET + `OSD_HDR_VACTIVE;
        X_osd_txt_vstart <= osd_voffset_w + `OSD_TXT_VOFFSET;
        X_osd_txt_vstop <= osd_voffset_w + `OSD_TXT_VOFFSET + `OSD_TXT_VACTIVE;
        X_osd_info_txt_vstart <= osd_voffset_w + `OSD_INFO_VOFFSET;
        X_osd_info_txt_vstop <= osd_voffset_w + `OSD_INFO_VOFFSET + `OSD_INFO_VACTIVE;
        X_osd_txt_hstart <= osd_hoffset_w + `OSD_TXT_HOFFSET;
        X_osd_txt_hstop <= osd_hoffset_w + `OSD_TXT_HOFFSET + `OSD_TXT_HACTIVE;
        
        Y_vcnt_delay <= 3'b000;
        Y_vcnt <= {vcnt_width{1'b0}};
      end else if (HSYNC_reset) begin
        if (Y_vcnt_delay == osd_vscale_w) begin
            Y_vcnt_delay <= 3'b000;
            Y_vcnt <= Y_vcnt + 1'b1;
          end else begin
            Y_vcnt_delay <= Y_vcnt_delay + 3'b001;
          end
      end
      
      if (HSYNC_reset) begin
        hcnt_delay <= 2'b00;
        hcnt <= {hcnt_width{1'b0}};
        
        if (Y_vcnt < X_osd_logo_vstart | Y_vcnt >= X_osd_logo_vstop) begin
          Y_logo_vcnt_delay <= 3'b000;
          Y_logo_vcnt <= {logo_vcnt_width{1'b0}};
        end else begin
          if (Y_logo_vcnt_delay == osd_vscale_w) begin
            Y_logo_vcnt_delay <= 3'b000;
            Y_logo_vcnt <= Y_logo_vcnt + 1'b1;
          end else begin
            Y_logo_vcnt_delay <= Y_logo_vcnt_delay + 3'b001;
          end
        end

        if (~|{is_hdr_txt_v_area,is_txt_v_area,is_info_txt_v_area}) begin
          Y_txt_vcnt_msb <= txt_area_offset_w;
          Y_txt_vcnt_lsb <= {font_vcnt_width{1'b0}};
        end else begin
          if (Y_txt_vcnt_delay == osd_vscale_w) begin
            Y_txt_vcnt_delay <= 3'b000;
            if (Y_txt_vcnt_lsb < `OSD_FONT_HEIGHT) begin
              Y_txt_vcnt_lsb <= Y_txt_vcnt_lsb + 1'b1;
            end else begin
              Y_txt_vcnt_msb <= Y_txt_vcnt_msb + 1'b1;
              Y_txt_vcnt_lsb <= {font_vcnt_width{1'b0}};
            end
          end else begin
            Y_txt_vcnt_delay <= Y_txt_vcnt_delay + 3'b001;
          end
        end
      end else begin
        if (hcnt_delay == osd_hscale_w) begin
          hcnt_delay <= 2'b00;
          hcnt <= hcnt + 1'b1;
        end else begin
          hcnt_delay <= hcnt_delay + 2'b01;
        end
      end
      
      HSYNC_pre <= HSYNC_cur;
      VSYNC_pre <= VSYNC_cur;
    end
    
    if (vdata_valid_L[1]) begin
      if (draw_logo[1]) begin
        if (logo_hcnt_delay == osd_hscale_w) begin
          logo_hcnt_delay <= 2'b00;
          logo_hcnt <= logo_hcnt + 1'b1;
        end else begin
          logo_hcnt_delay <= logo_hcnt_delay + 2'b01;
        end
      end else begin
        logo_hcnt_delay <= osd_hscale_w;
        logo_hcnt <= {logo_hcnt_width{1'b1}};
      end
      
      if (en_txtrd[1]) begin
        if (txt_hcnt_delay == osd_hscale_w) begin
          txt_hcnt_delay <= 2'b00;
          if (txt_hcnt_lsb < `OSD_FONT_WIDTH) begin
            txt_hcnt_lsb <= txt_hcnt_lsb + 1'b1;
          end else begin
            txt_hcnt_lsb <= {font_hcnt_width{1'b0}};
          end
          if (txt_hcnt_lsb == {font_hcnt_width{1'b0}}) begin
            Y_txt_hcnt_msb <= Y_txt_hcnt_msb + 1'b1;
          end
        end else begin
          txt_hcnt_delay <= txt_hcnt_delay + 2'b01;
        end
      end else begin
        txt_hcnt_delay <= osd_hscale_w;
        Y_txt_hcnt_msb <= {osd_letter_hcnt_width{1'b0}};
        txt_hcnt_lsb <= `OSD_FONT_WIDTH;
      end
    end

    vdata_valid_L[7:1] <= vdata_valid_L[6:0];
    vdata_valid_L[0] <= vdata_valid_i_w;
    for (int_idx = 1; int_idx < 8; int_idx = int_idx+1)
      vdata_L[int_idx] <= vdata_L[int_idx-1];
    vdata_L[0] <= vdata_i;

    OSD_VSync <= (Y_vcnt >= X_osd_window_vstart) && (Y_vcnt < X_osd_window_vstop);
    
    draw_osd_window[7:2] <= draw_osd_window[6:1];
    draw_osd_window[1] <= (Y_vcnt >= X_osd_window_vstart) && (Y_vcnt < X_osd_window_vstop) &&
                          (hcnt >= X_osd_window_hstart) && (hcnt < X_osd_window_hstop);
                          
    draw_logo[7:2] <= draw_logo[6:1];
    draw_logo[1] <= show_osd_logo &&
                    (Y_vcnt >= X_osd_logo_vstart) && (Y_vcnt < X_osd_logo_vstop) &&
                    (hcnt >= X_osd_logo_hstart) && (hcnt < X_osd_logo_hstop);

    act_logo_px[7:2] <= act_logo_px[6:1];
    act_logo_px[  1] <= n64adv_logo[{Y_logo_vcnt[logo_vcnt_width-1:1],logo_hcnt[logo_hcnt_width-1:1]}];

    en_txtrd[7:2] <= en_txtrd[6:1];
    en_txtrd[1]  <= |{is_hdr_txt_v_area,is_txt_v_area,is_info_txt_v_area} &&
                    (hcnt >= X_osd_txt_hstart) && (hcnt < X_osd_txt_hstop);
                    
    en_fontrd[7:3] <= en_fontrd[6:2];
    en_fontrd[2] <= en_txtrd[1] && (txt_hcnt_lsb == `OSD_FONT_WIDTH) && (txt_hcnt_delay == osd_hscale_w) && vdata_valid_L[1];
  end



assign txt_xrdaddr = Y_txt_hcnt_msb;
assign txt_yrdaddr = Y_txt_vcnt_msb;


always @(posedge OSDCLK) begin
  if (!vd_wrcolor[1] & vd_wrcolor[0]) begin // write new color data
    vd_wrcolor[2] <= 1'b1;
    vd_wrcolor_page <= vd_wrpage_w;
    vd_wrcolor_addr <= vd_wraddr_w;
    vd_wrcolor_data <= vd_color_wrdata_w;
  end else begin
    vd_wrcolor[2] <= 1'b0;
  end
  vd_wrcolor[1:0] <= {vd_wrcolor[0],vd_wrctrl_w[1]};
  if (!vd_wrtxt[1] & vd_wrtxt[0]) begin // write new txt data
    vd_wrtxt[2] <= 1'b1;
    vd_wrtxt_page <= vd_wrpage_w;
    vd_wrtxt_addr <= vd_wraddr_w;
    vd_wrtxt_data <= vd_txt_wrdata_w;
  end else begin
    vd_wrtxt[2] <= 1'b0;
  end
  vd_wrtxt[1:0] <= {vd_wrtxt[0],vd_wrctrl_w[0]};
end

ram2port #(
  .num_of_pages(`MAX_CHARS_PER_ROW+1),
  .pagesize(`MAX_HDR_TEXT_ROWS + `MAX_TEXT_ROWS + `MAX_INFO_TEXT_ROWS + 3),
  .data_width(color_mem_width)
) vd_color_u (
  .wrCLK(OSDCLK),
  .wren(vd_wrcolor[2]),
  .wrpage(vd_wrcolor_page),
  .wraddr(vd_wrcolor_addr),
  .wrdata(vd_wrcolor_data),
  .rdCLK(VCLK),
  .rden(en_fontrd[2]),
  .rdpage(txt_xrdaddr),
  .rdaddr(txt_yrdaddr),
  .rddata({bg_color_sel_tmp,font_color_sel_tmp})
);

ram2port #(
  .num_of_pages(`MAX_CHARS_PER_ROW+1),
  .pagesize(`MAX_HDR_TEXT_ROWS + `MAX_TEXT_ROWS + `MAX_INFO_TEXT_ROWS + 3),
  .data_width(txt_mem_width)
) vd_text_u (
  .wrCLK(OSDCLK),
  .wren(vd_wrtxt[2]),
  .wrpage(vd_wrtxt_page),
  .wraddr(vd_wrtxt_addr),
  .wrdata(vd_wrtxt_data),
  .rdCLK(VCLK),
  .rden(en_fontrd[2]),
  .rdpage(txt_xrdaddr),
  .rdaddr(txt_yrdaddr),
  .rddata(font_char_select)
);

always @(posedge VCLK or negedge nVRST) // delay font selection according to memory delay of chars and color
                                        // use the fact that pixel stays constant for´four clock cycles
  if (!nVRST) begin
    bg_color_sel <= {bg_color_sel_width{1'b0}};
    font_color_sel <= {font_color_sel_width{1'b0}};
  end else if (en_fontrd[4]) begin
    bg_color_sel   <= bg_color_sel_tmp;
    font_color_sel <= font_color_sel_tmp;
  end


font_rom font_rom_u(
  .CLK(VCLK),
  .nRST(nVRST),
  .char_addr(font_char_select),
  .char_line(Y_txt_vcnt_lsb),
  .rden(en_fontrd[4]),
  .rddata(font_lineword_tmp)
);


assign window_bg_color_tmp = (bg_color_sel == `OSD_BACKGROUND_WHITE) ? `OSD_WINDOW_BGCOLOR_WHITE   :
                             (bg_color_sel == `OSD_BACKGROUND_GREY)  ? `OSD_WINDOW_BGCOLOR_GREY    :
                             (bg_color_sel == `OSD_BACKGROUND_BLACK) ? `OSD_WINDOW_BGCOLOR_BLACK   :
                                                                       `OSD_WINDOW_BGCOLOR_DARKBLUE;
assign txt_color_tmp = (font_color_sel == `FONTCOLOR_BLACK)       ? osd_txt_color_black       :
                       (font_color_sel == `FONTCOLOR_GREY)        ? osd_txt_color_grey        :
                       (font_color_sel == `FONTCOLOR_LIGHTGREY)   ? osd_txt_color_lightgrey   :
                       (font_color_sel == `FONTCOLOR_WHITE)       ? osd_txt_color_white       :
                       (font_color_sel == `FONTCOLOR_RED)         ? osd_txt_color_red         :
                       (font_color_sel == `FONTCOLOR_GREEN)       ? osd_txt_color_green       :
                       (font_color_sel == `FONTCOLOR_BLUE)        ? osd_txt_color_blue        :
                       (font_color_sel == `FONTCOLOR_YELLOW)      ? osd_txt_color_yellow      :
                       (font_color_sel == `FONTCOLOR_CYAN)        ? osd_txt_color_cyan        :
                       (font_color_sel == `FONTCOLOR_MAGENTA)     ? osd_txt_color_magenta     :
                       (font_color_sel == `FONTCOLOR_DARKORANGE)  ? osd_txt_color_darkorange  :
                       (font_color_sel == `FONTCOLOR_TOMATO)      ? osd_txt_color_tomato      :
                       (font_color_sel == `FONTCOLOR_DARKMAGENTA) ? osd_txt_color_darkmagenta :
                       (font_color_sel == `FONTCOLOR_NAVAJOWHITE) ? osd_txt_color_navajowhite :
                       (font_color_sel == `FONTCOLOR_DARKGOLD)    ? osd_txt_color_darkgold    :
                                                                    font_color_default        ;




always @(posedge VCLK or negedge nVRST)
  if (!nVRST) begin
    font_pixel_select_4x <= {font_hcnt_width+2{1'b0}};
    font_lineword <= {(`OSD_FONT_WIDTH+1){1'b0}};
    act_char_px <= 1'b0;
    window_bg_color <= window_bg_color_default;
    txt_color = font_color_default;
  end else begin
    if (en_fontrd[6]) begin
      font_pixel_select_4x <= init_font_pixel_select_4x_w;
    end else begin
      if (|font_pixel_select_4x)
        font_pixel_select_4x <= next_font_pixel_select_4x_w;
      else if (font_pixel_select_done_w)
        font_pixel_select_4x <= {(font_hcnt_width+2){1'b0}};
    end
    
    if (en_fontrd[6]) begin
      font_lineword <= font_lineword_tmp;
      act_char_px <= (font_color_sel == `FONTCOLOR_NON) ? 1'b0 : font_lineword_tmp[0];
    end else if (en_txtrd[6]) begin
      if (vdata_valid_L[6])
        act_char_px <= (font_color_sel == `FONTCOLOR_NON) ? 1'b0 : font_lineword[font_pixel_select_4x[font_hcnt_width+1:2]];
      window_bg_color <= !draw_logo[6] ? window_bg_color_tmp : window_bg_color_default;
      txt_color <= txt_color_tmp;
    end
  end

always @(posedge VCLK or negedge nVRST)
  if (!nVRST) begin
    vdata_valid_o <= vdata_valid_init;
    vdata_o <= {(3*bits_per_color+4){1'b0}};
  end else begin
    // pass through vdata valid and sync
    vdata_valid_o <= vdata_valid_L[7];
    vdata_o[3*bits_per_color+3:3*bits_per_color] <= vdata_L[7][3*bits_per_color+3:3*bits_per_color];

    // draw menu window if needed
    if (show_osd & draw_osd_window[7]) begin
      if (draw_logo[7] & act_logo_px[7])
        vdata_o[3*bits_per_color-1:0] <= osd_logo_color;
      else if (&{en_txtrd[7],!draw_logo[7],act_char_px})
          vdata_o[3*bits_per_color-1:0] <= txt_color;
      else begin
      // modify red
        vdata_o[3*bits_per_color-1:3*bits_per_color-3] <= window_bg_color[bg_color_width-1:bg_color_width-3];
        vdata_o[3*bits_per_color-4:2*bits_per_color  ] <= vdata_L[7][3*bits_per_color-1:2*bits_per_color+3];
      // modify green
        vdata_o[2*bits_per_color-1:2*bits_per_color-3] <= window_bg_color[bg_color_width-4:bg_color_width-6];
        vdata_o[2*bits_per_color-4:  bits_per_color  ] <= vdata_L[7][2*bits_per_color-1:bits_per_color+3];
      // modify blue
        vdata_o[bits_per_color-1:bits_per_color-3] <= window_bg_color[bg_color_width-7:bg_color_width-9];
        vdata_o[bits_per_color-4:               0] <= vdata_L[7][bits_per_color-1:3];
      end
    end else begin
      vdata_o[3*bits_per_color-1:0] <= vdata_L[7][3*bits_per_color-1:0];
    end
  end

endmodule
