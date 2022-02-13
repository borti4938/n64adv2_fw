
module scaler_cfggen(
  SYS_CLK,
  
  palmode_i,
  palmode_boxed_i,
  use_interlaced_full_i,
  nvideblur_i,
  
  video_config_i,
  
  vlines_out_i,
  hpixels_out_i,
  
  vpos_1st_rdline_o,
  vlines_in_needed_o,
  vlines_in_full_o,
  vlines_out_o,
  v_interp_factor_o,
  
  hpos_1st_rdpixel_o,
  hpixels_in_needed_o,
  hpixels_in_full_o,
  hpixels_out_o,
  h_interp_factor_o
);

`include "../../lib/n64adv_vparams.vh"
`include "../../lib/videotimings.vh"

`include "../../lib/setVideoTimings.tasks.v"

input SYS_CLK;

input palmode_i;
input palmode_boxed_i;
input use_interlaced_full_i;
input nvideblur_i;

input [`VID_CFG_W-1:0] video_config_i;

input [10:0] vlines_out_i;
input [11:0] hpixels_out_i;

output reg [9:0] vpos_1st_rdline_o;   // first line to read (needed if scaling factor is so high such that not all lines are needed)
output reg [9:0] vlines_in_needed_o;  // number of lines needed to scale for active lines
output reg [9:0] vlines_in_full_o;    // number of lines at input (either 240 in NTSC or 288 in PAL (or doubled for interlaced with weave and fully buffered deinterlacing))
output reg [10:0] vlines_out_o;       // number of lines after scaling (max. 2047)
output reg [17:0] v_interp_factor_o;  // factor needed to determine actual position during interpolation

output reg [9:0] hpos_1st_rdpixel_o;  // first horizontal pixel to read (needed if scaling factor is so high such that not all pixels are needed)
output reg [9:0] hpixels_in_needed_o; // number of horizontal pixel needed to scale for active lines
output reg [9:0] hpixels_in_full_o;   // number of horizontal pixel at input (should be 640, later 320 or 640)
output reg [11:0] hpixels_out_o;      // number of horizontal pixel after scaling (max. 4093)
output reg [17:0] h_interp_factor_o;  // factor needed to determine actual position during interpolation


// params

localparam dividend_length = 18;  // DO NOT CHANGE THIS

localparam ST_CFGGEN_RDY = 2'b00;
localparam ST_CFGGEN_DIVWAIT = 2'b01;
localparam ST_CFGGEN_WAIT = 2'b10;
localparam ST_CFGGEN_OUT = 2'b11;



// wires
wire vmode_pal_L_w;
wire [9:0] n64_vlines_ntsc_w, n64_vlines_pal_w, n64_vlines_w;
wire [9:0] n64_hpixels_w;

wire [dividend_length-1:0] v_appr_mult_factor_w, h_appr_mult_factor_w;
wire v_divide_busy_w, v_divide_done_w, h_divide_busy_w, h_divide_done_w;

wire [26:0] inv_vscale_w;
wire [36:0] vlines_in_resmax_full_w;
wire [9:0] vpos_1st_rdline_normal_w, vpos_1st_rdline_pal_boxed_w;

wire [27:0] inv_hscale_w;
wire [39:0] hpixels_in_resmax_full_w;

// regs
reg palmode_L, palmode_boxed_L, use_interlaced_full_L, nvideblur_L;
reg tgl_trigger_v_cfggen_phases_i, tgl_trigger_v_cfggen_phases_o;
reg tgl_trigger_h_cfggen_phases_i, tgl_trigger_h_cfggen_phases_o;

reg [1:0] v_cfggen_phase = ST_CFGGEN_RDY;
reg [2:0] v_cfggen_phase_wait_cnt;

reg v_divide_cmd_LL;
reg [10:0] v_divisor_L, v_divisor_LL;
reg [10:0] vactive_LL, vactive_L;
reg [26:0] inv_vscale_L;
reg [36:0] vlines_in_resmax_full_L;
reg [10:0] vlines_in_resmax_L;
reg [9:0] vlines_in_needed_L;
reg [9:0] vlines_in_full_L;
reg [9:0] vpos_1st_rdline_L;

reg [1:0] h_cfggen_phase = ST_CFGGEN_RDY;
reg [2:0] h_cfggen_phase_wait_cnt;

reg h_divide_cmd_LL;
reg [11:0] h_divisor_L, h_divisor_LL;
reg [11:0] hactive_LL, hactive_L;
reg [27:0] inv_hscale_L;
reg [39:0] hpixels_in_resmax_full_L;
reg [11:0] hpixels_in_resmax_L;
reg [9:0]  hpixels_in_needed_L;
reg [9:0] hpixels_in_full_L;
reg [9:0] hpos_1st_rdpixel_L;



// rtl

initial begin
  tgl_trigger_v_cfggen_phases_i = 1'b0;
  tgl_trigger_v_cfggen_phases_o = 1'b1;
  tgl_trigger_h_cfggen_phases_i = 1'b0;
  tgl_trigger_h_cfggen_phases_o = 1'b1;
end

always @(posedge SYS_CLK) begin
  if (((palmode_L != palmode_i) | (palmode_boxed_L != palmode_boxed_i) | (use_interlaced_full_L != use_interlaced_full_i)) & (v_cfggen_phase == ST_CFGGEN_RDY)) begin
    use_interlaced_full_L <= use_interlaced_full_i;
    palmode_L <= palmode_i;
    palmode_boxed_L <= palmode_boxed_i;
    tgl_trigger_v_cfggen_phases_i <= ~tgl_trigger_v_cfggen_phases_i;
  end
  if ((nvideblur_L != nvideblur_i) & (h_cfggen_phase == ST_CFGGEN_RDY)) begin
    nvideblur_L <= nvideblur_i;
    tgl_trigger_h_cfggen_phases_i <= ~tgl_trigger_h_cfggen_phases_i;
  end
end


assign vmode_pal_L_w = !palmode_boxed_L & palmode_L;
assign n64_vlines_ntsc_w = use_interlaced_full_L ? 2*`ACTIVE_LINES_NTSC_LX1 : `ACTIVE_LINES_NTSC_LX1;
assign n64_vlines_pal_w = use_interlaced_full_L ? 2*`ACTIVE_LINES_PAL_LX1 : `ACTIVE_LINES_PAL_LX1;

assign n64_vlines_w = vmode_pal_L_w ? n64_vlines_pal_w : n64_vlines_ntsc_w;
assign inv_vscale_w = v_appr_mult_factor_w * (* multstyle = "dsp" *) n64_vlines_w;

assign vlines_in_resmax_full_w = inv_vscale_L * (* multstyle = "dsp" *) vactive_LL;

assign vpos_1st_rdline_normal_w = (vlines_in_resmax_L < {1'b0,n64_vlines_w}) ? (n64_vlines_w - vlines_in_resmax_L[9:0]) >> 1 : 0;
assign vpos_1st_rdline_pal_boxed_w = (vlines_in_resmax_L < {1'b0,n64_vlines_ntsc_w}) ? (n64_vlines_pal_w - vlines_in_resmax_L[9:0]) >> 1 :
                                                               use_interlaced_full_L ? 48 : 24;


assign n64_hpixels_w = nvideblur_L ? `ACTIVE_PIXEL_PER_LINE : `ACTIVE_PIXEL_PER_LINE/2;
assign inv_hscale_w = h_appr_mult_factor_w * (* multstyle = "dsp" *) n64_hpixels_w;

assign hpixels_in_resmax_full_w = inv_hscale_L * (* multstyle = "dsp" *) hactive_LL;


always @(posedge SYS_CLK) begin
  setVideoVidACTIVEwOS(video_config_i,vactive_L,hactive_L);
  v_divisor_L <= vlines_out_i;
  inv_vscale_L <= inv_vscale_w;
  vlines_in_resmax_full_L <= vlines_in_resmax_full_w;
  vlines_in_resmax_L <= vlines_in_resmax_full_L[34:24] + vlines_in_resmax_full_L[23];
  vlines_in_needed_L <= (vlines_in_resmax_L < {1'b0,n64_vlines_w}) ? vlines_in_resmax_L[9:0] : n64_vlines_w;
  vlines_in_full_L <= n64_vlines_w;
  vpos_1st_rdline_L <= !(palmode_L & palmode_boxed_L) ? vpos_1st_rdline_normal_w : vpos_1st_rdline_pal_boxed_w;
  
  case(v_cfggen_phase)
    ST_CFGGEN_DIVWAIT: begin
      v_divide_cmd_LL <= 1'b0;
      if (v_divide_done_w) begin
        v_cfggen_phase <= ST_CFGGEN_WAIT;
        v_cfggen_phase_wait_cnt <= 3'b100;
      end
    end
    ST_CFGGEN_WAIT: begin
        if (~|v_cfggen_phase_wait_cnt) 
          v_cfggen_phase <= ST_CFGGEN_OUT;
        else
          v_cfggen_phase_wait_cnt <= v_cfggen_phase_wait_cnt - 1;
      end
    ST_CFGGEN_OUT: begin
      v_cfggen_phase <= ST_CFGGEN_RDY;
      vpos_1st_rdline_o <= vpos_1st_rdline_L;
      vlines_in_needed_o <= vlines_in_needed_L;
      vlines_in_full_o <= vlines_in_full_L;
      vlines_out_o <= v_divisor_LL;
      v_interp_factor_o <= v_appr_mult_factor_w;
    end
    default: begin  // ST_CFGGEN_RDY
        if (((tgl_trigger_v_cfggen_phases_o != tgl_trigger_v_cfggen_phases_i) |
             (vactive_LL != vactive_L) |
             (v_divisor_LL != v_divisor_L)) & !v_divide_busy_w) begin
          v_cfggen_phase <= ST_CFGGEN_DIVWAIT;
          tgl_trigger_v_cfggen_phases_o <= tgl_trigger_v_cfggen_phases_i;
          v_divide_cmd_LL <= 1'b1;
          vactive_LL <= vactive_L;
          v_divisor_LL <= v_divisor_L;
        end
      end
  endcase
  
  h_divisor_L <= hpixels_out_i;
  inv_hscale_L <= inv_hscale_w;
  hpixels_in_resmax_full_L <= hpixels_in_resmax_full_w;
  hpixels_in_resmax_L <= hpixels_in_resmax_full_L[34:23] + hpixels_in_resmax_full_L[22];
  hpixels_in_needed_L <= (hpixels_in_resmax_L < {2'b00,n64_hpixels_w}) ? hpixels_in_resmax_L[9:0] : n64_hpixels_w;
  hpixels_in_full_L <= n64_hpixels_w;
  hpos_1st_rdpixel_L <= (hpixels_in_resmax_L < {2'b00,n64_hpixels_w}) ? (n64_hpixels_w - hpixels_in_resmax_L[9:0]) >> 1 : 0;
  
  case(h_cfggen_phase)
    ST_CFGGEN_DIVWAIT: begin
      h_divide_cmd_LL <= 1'b0;
      if (h_divide_done_w) begin
        h_cfggen_phase <= ST_CFGGEN_WAIT;
        h_cfggen_phase_wait_cnt <= 3'b100;
      end
    end
    ST_CFGGEN_WAIT: begin
        if (~|h_cfggen_phase_wait_cnt) 
          h_cfggen_phase <= ST_CFGGEN_OUT;
        else
          h_cfggen_phase_wait_cnt <= h_cfggen_phase_wait_cnt - 1;
      end
    ST_CFGGEN_OUT: begin
      h_cfggen_phase <= ST_CFGGEN_RDY;
      hpos_1st_rdpixel_o <= hpos_1st_rdpixel_L;
      hpixels_in_needed_o <= hpixels_in_needed_L;
      hpixels_in_full_o <= hpixels_in_full_L;
      hpixels_out_o <= h_divisor_LL;
      h_interp_factor_o <= h_appr_mult_factor_w;
    end
    default: begin  // ST_CFGGEN_RDY
        if (((tgl_trigger_h_cfggen_phases_o != tgl_trigger_h_cfggen_phases_i) |
             (hactive_LL != hactive_L) |
             (h_divisor_LL != h_divisor_L)) & !h_divide_busy_w) begin
          h_cfggen_phase <= ST_CFGGEN_DIVWAIT;
          tgl_trigger_h_cfggen_phases_o <= tgl_trigger_h_cfggen_phases_i;
          h_divide_cmd_LL <= 1'b1;
          hactive_LL <= hactive_L;
          h_divisor_LL <= h_divisor_L;
        end
      end
  endcase
end

serial_divide #(
  .DIVIDEND_WIDTH(dividend_length),
  .DIVISOR_WIDTH(11)
) v_serial_divide_u (
  .clk_i(SYS_CLK),
  .nrst_i(1'b1),
  .divide_cmd_i(v_divide_cmd_LL),
  .dividend_i({1'b1,{(dividend_length-1){1'b0}}}),
  .divisor_i(v_divisor_LL),
  .quotient_o(v_appr_mult_factor_w),
  .busy_o(v_divide_busy_w),
  .done_o(v_divide_done_w)
);

serial_divide #(
  .DIVIDEND_WIDTH(dividend_length),
  .DIVISOR_WIDTH(12)
) h_serial_divide_u (
  .clk_i(SYS_CLK),
  .nrst_i(1'b1),
  .divide_cmd_i(h_divide_cmd_LL),
  .dividend_i({1'b1,{(dividend_length-1){1'b0}}}),
  .divisor_i(h_divisor_LL),
  .quotient_o(h_appr_mult_factor_w),
  .busy_o(h_divide_busy_w),
  .done_o(h_divide_done_w)
);


endmodule
