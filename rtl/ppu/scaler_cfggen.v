
module scaler_cfggen(
  SYS_CLK,
  
  palmode_i,
  palmode_boxed_i,
  
  video_config_i,
  
  vscale_factor_i,
  hscale_factor_i,
  
  vpos_1st_rdline_o,
  vlines_in_needed_o,
  vlines_out_o,
  v_interp_factor_o,
  
  hpos_1st_rdpixel_o,
  hlines_in_needed_o,
  hpixels_out_o,
  h_interp_factor_o
);

`include "../../vh/n64adv_vparams.vh"
`include "../../vh/videotimings.vh"

`include "../../tasks/setVideoTimings.tasks.v"
`include "../../tasks/setScalerConfig.tasks.v"

input SYS_CLK;

input palmode_i;
input palmode_boxed_i;

input [`VID_CFG_W-1:0] video_config_i;

input [4:0] vscale_factor_i;
input [4:0] hscale_factor_i;

output reg [8:0] vpos_1st_rdline_o;
output reg [8:0] vlines_in_needed_o;
output reg [10:0] vlines_out_o;
output reg [17:0] v_interp_factor_o;

output reg [9:0] hpos_1st_rdpixel_o;
output reg [9:0] hlines_in_needed_o;
output reg [11:0] hpixels_out_o;
output reg [17:0] h_interp_factor_o;


// params

localparam dividend_length = 18;  // DO NOT CHANGE THIS

localparam ST_CFGGEN_RDY = 2'b00;
localparam ST_CFGGEN_DIVWAIT = 2'b01;
localparam ST_CFGGEN_WAIT = 2'b10;
localparam ST_CFGGEN_OUT = 2'b11;



// wires
wire vmode_pal_i_w, vmode_pal_L_w;
wire [8:0] n64_vlines_w;
wire [9:0] n64_hpixels_w;

wire [dividend_length-1:0] v_appr_mult_factor_w, h_appr_mult_factor_w;
wire v_divide_busy_w, v_divide_done_w, h_divide_busy_w, h_divide_done_w;

wire [26:0] inv_vscale_w;
wire [36:0] vlines_in_resmax_full_w;
wire [8:0] vlines_in_needed_pal_w, vlines_in_needed_ntsc_w;
wire [8:0] vpos_1st_rdline_ntsc_w, vpos_1st_rdline_pal_w, vpos_1st_rdline_pal_boxed_w;

wire [27:0] inv_hscale_w;
wire [39:0] hpixels_in_resmax_full_w;

// regs
reg palmode_L, palmode_boxed_L;
reg trigger_v_cfggen_phases, trigger_h_cfggen_phases;

reg [1:0] v_cfggen_phase = ST_CFGGEN_RDY;
reg [2:0] v_cfggen_phase_wait_cnt;

reg v_divide_cmd_LL;
reg [10:0] v_divisor_L, v_divisor_LL;
reg [10:0] vactive_LL, vactive_L;
reg [26:0] inv_vscale_L;
reg [36:0] vlines_in_resmax_full_L;
reg [9:0] vlines_in_resmax_L;
reg [8:0] vlines_in_needed_L;
reg [8:0] vpos_1st_rdline_L;

reg [1:0] h_cfggen_phase = ST_CFGGEN_RDY;
reg [2:0] h_cfggen_phase_wait_cnt;

reg h_divide_cmd_LL;
reg [11:0] h_divisor_L, h_divisor_LL;
reg [11:0] hactive_LL, hactive_L;
reg [27:0] inv_hscale_L;
reg [39:0] hpixels_in_resmax_full_L;
reg [10:0] hpixels_in_resmax_L;
reg [9:0]  hlines_in_needed_L;
reg [9:0] hpos_1st_rdpixel_L;



// rtl
always @(posedge SYS_CLK) begin
  if (((palmode_L != palmode_i) | (palmode_boxed_L != palmode_boxed_i)) & !v_divide_busy_w) begin
    palmode_L <= palmode_i;
    palmode_boxed_L <= palmode_boxed_i;
    trigger_v_cfggen_phases <= 1'b1;
    trigger_h_cfggen_phases <= 1'b1;
  end
  if (v_cfggen_phase == ST_CFGGEN_DIVWAIT)
    trigger_v_cfggen_phases <= 1'b0;
  if (h_cfggen_phase == ST_CFGGEN_DIVWAIT)
    trigger_h_cfggen_phases <= 1'b0;
end


assign vmode_pal_i_w = !palmode_boxed_i & palmode_i;
assign vmode_pal_L_w = !palmode_boxed_L & palmode_L;

assign n64_vlines_w = vmode_pal_L_w ? `ACTIVE_LINES_PAL_LX1 : `ACTIVE_LINES_NTSC_LX1;
assign inv_vscale_w = v_appr_mult_factor_w * (* multstyle = "dsp" *) n64_vlines_w;

assign vlines_in_resmax_full_w = inv_vscale_L * (* multstyle = "dsp" *) vactive_LL;

assign vlines_in_needed_pal_w  = (vlines_in_resmax_L < `ACTIVE_LINES_PAL_LX1)  ? vlines_in_resmax_L : `ACTIVE_LINES_PAL_LX1;
assign vlines_in_needed_ntsc_w = (vlines_in_resmax_L < `ACTIVE_LINES_NTSC_LX1) ? vlines_in_resmax_L : `ACTIVE_LINES_NTSC_LX1;

assign vpos_1st_rdline_ntsc_w = (vlines_in_resmax_L < `ACTIVE_LINES_NTSC_LX1) ? (`ACTIVE_LINES_NTSC_LX1 - vlines_in_resmax_L)/2 : 9'd0;
assign vpos_1st_rdline_pal_w = (vlines_in_resmax_L < `ACTIVE_LINES_PAL_LX1) ? (`ACTIVE_LINES_PAL_LX1 - vlines_in_resmax_L)/2 : 9'd0;
assign vpos_1st_rdline_pal_boxed_w = (vlines_in_resmax_L < `ACTIVE_LINES_NTSC_LX1) ? (`ACTIVE_LINES_PAL_LX1 - vlines_in_resmax_L)/2 : 9'd24;


assign n64_hpixels_w = `ACTIVE_PIXEL_PER_LINE;
assign inv_hscale_w = h_appr_mult_factor_w * (* multstyle = "dsp" *) n64_hpixels_w;

assign hpixels_in_resmax_full_w = inv_hscale_L * (* multstyle = "dsp" *) hactive_LL;


always @(posedge SYS_CLK) begin
  setVideoVidACTIVE(video_config_i,vactive_L,hactive_L);
  
  getVPixels(vmode_pal_i_w,vscale_factor_i,v_divisor_L);  
  inv_vscale_L <= inv_vscale_w;
  vlines_in_resmax_full_L <= vlines_in_resmax_full_w;
  vlines_in_resmax_L <= vlines_in_resmax_full_L[33:24] + vlines_in_resmax_full_L[23];
  vlines_in_needed_L <= vmode_pal_L_w ? vlines_in_needed_pal_w : vlines_in_needed_ntsc_w;
  vpos_1st_rdline_L <= !palmode_L ? vpos_1st_rdline_ntsc_w :
                  palmode_boxed_L ? vpos_1st_rdline_pal_boxed_w : vpos_1st_rdline_pal_w;
  
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
      vlines_out_o <= v_divisor_LL;
      v_interp_factor_o <= v_appr_mult_factor_w;
    end
    default: begin  // ST_CFGGEN_RDY
        if ((trigger_v_cfggen_phases |
             (vactive_LL != vactive_L) |
             (v_divisor_LL != v_divisor_L)) & !v_divide_busy_w) begin
          v_cfggen_phase <= ST_CFGGEN_DIVWAIT;
          v_divide_cmd_LL <= 1'b1;
          vactive_LL <= vactive_L;
          v_divisor_LL <= v_divisor_L;
        end
      end
  endcase
  
  getHPixels(hscale_factor_i,h_divisor_L);
  inv_hscale_L <= inv_hscale_w;
  hpixels_in_resmax_full_L <= hpixels_in_resmax_full_w;
  hpixels_in_resmax_L <= hpixels_in_resmax_full_L[33:23] + hpixels_in_resmax_full_L[22];
  hlines_in_needed_L <= (hpixels_in_resmax_L < `ACTIVE_PIXEL_PER_LINE) ? hpixels_in_resmax_L : `ACTIVE_PIXEL_PER_LINE;
  hpos_1st_rdpixel_L <= (hpixels_in_resmax_L < `ACTIVE_PIXEL_PER_LINE) ? `ACTIVE_PIXEL_PER_LINE/2 - hpixels_in_resmax_L/2 : 0;
  
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
      hlines_in_needed_o <= hlines_in_needed_L;
      hpixels_out_o <= h_divisor_LL;
      h_interp_factor_o <= h_appr_mult_factor_w;
    end
    default: begin  // ST_CFGGEN_RDY
        if ((trigger_h_cfggen_phases |
             (hactive_LL != hactive_L) |
             (h_divisor_LL != h_divisor_L)) & !h_divide_busy_w) begin
          h_cfggen_phase <= ST_CFGGEN_DIVWAIT;
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
