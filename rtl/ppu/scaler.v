
module scaler(
  async_nRST_i,

  VCLK_i,
  vinfo_i,
  vdata_i,
  vdata_valid_i,
  vdata_hvshift,

  VCLK_o,
  video_config_i,
  video_llm_i,
  video_interpolation_mode_i,
  video_pal_boxed_i,
  video_vscale_factor_i,
  video_vpixel_out_i,
  video_inv_vscale_i,
  video_vfactor_lin_i,
  video_hscale_factor_i,
  video_hpixel_out_i,
  video_inv_hscale_i,
  video_hfactor_lin_i,
  vinfo_txsynced_i,
  vinfo_llm_slbuf_fb_o,
  
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
  
  drawSL,
  HSYNC_o,
  VSYNC_o,
  DE_o,
  vdata_o
);


`include "../../vh/n64adv_vparams.vh"
`include "../../vh/videotimings.vh"

`include "../../tasks/setVideoTimings.tasks.v"
`include "../../tasks/setScalerConfig.tasks.v"

input async_nRST_i;

input VCLK_i;
input [1:0] vinfo_i;
input vdata_valid_i;
input [`VDATA_O_FU_SLICE] vdata_i;
input [9:0] vdata_hvshift;

input VCLK_o;
input [`VID_CFG_W-1:0] video_config_i;
input [1:0] video_interpolation_mode_i;
input video_pal_boxed_i;
input [4:0] video_vscale_factor_i;
input [10:0] video_vpixel_out_i;
input [26:0] video_inv_vscale_i;
input [17:0] video_vfactor_lin_i;
input [4:0] video_hscale_factor_i;
input [11:0] video_hpixel_out_i;
input [27:0] video_inv_hscale_i;
input [17:0] video_hfactor_lin_i;
input video_llm_i;
input [1:0] vinfo_txsynced_i;
output reg [8:0] vinfo_llm_slbuf_fb_o;

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

output reg [2:0] drawSL = 3'b000;
output reg HSYNC_o = 1'b0;
output reg VSYNC_o = 1'b0;
output reg DE_o = 1'b0;
output reg [`VDATA_O_CO_SLICE] vdata_o = {(3*color_width_o){1'b0}};


// parameter
localparam resync_stages = 3;

localparam hcnt_width = $clog2(`PIXEL_PER_LINE_MAX);
//localparam vcnt_width = $clog2(2*`TOTAL_LINES_PAL_LX1); // consider interlaced content
localparam vcnt_width = $clog2(`TOTAL_LINES_PAL_LX1); // should be 9
localparam hpos_width = $clog2(`ACTIVE_PIXEL_PER_LINE);

localparam pre_lines_ntsc = `TOTAL_LINES_NTSC_LX1/4;
localparam pre_lines_pal  = `TOTAL_LINES_PAL_LX1/4;

localparam FILT_AX_SHARP_TH = 8'hA0;

localparam ST_SDRAM_WAIT      = 3'b000; // wait for new line to begin (FIFO is already flushed)
localparam ST_SDRAM_FIFO2RAM0 = 3'b010; // prepare first FIFO element into SDRAM
localparam ST_SDRAM_FIFO2RAM1 = 3'b011; // write frist FIFO element into SDRAM
localparam ST_SDRAM_FIFO2RAM2 = 3'b100; // write concurrent FIFO elements into SDRAM
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

localparam H_A0_CALC_DELAY = 2;

// misc
integer int_idx;

wire palmode = vinfo_i[1];
wire interlaced = vinfo_i[0];
wire palmode_vclk_o_resynced = vinfo_txsynced_i[1];
wire interlaced_vclk_o_resynced = vinfo_txsynced_i[0];

wire hshift_direction = vdata_hvshift[9];
wire [3:0] hshift    = vdata_hvshift[9] ? vdata_hvshift[8:5] : ~vdata_hvshift[8:5] + 1'b1;
wire vshift_direction = vdata_hvshift[4];
wire [3:0] vshift    = vdata_hvshift[4] ? vdata_hvshift[3:0] : ~vdata_hvshift[3:0] + 1'b1;


// wires
wire nRST_i, nRST_DRAM_proc, nRST_o;

wire nHS_i, nVS_i;
wire negedge_nHSYNC, negedge_nVSYNC;

wire vdata_i_vactive_w, vdata_i_hactive_w;

wire sdram_llm_sdr_clk_resynced;
wire [1:0] wrpage_sdrambuf_sdr_clk_resynced;
wire [`VDATA_O_CO_SLICE] sdrambuf_data_o;
wire [3:0] sdrambuf_pageinfo_sdr_clk_resynced;
wire [vcnt_width-1:0] vpos_1st_rdline_clk_resynced;

wire sdram_rdy_vclk_i_resynced, output_proc_en_vclk_i_resynced;

wire sdram_cmd_ack_o, sdram_data_ack_o, sdram_ctrl_rdy_o;
wire [7:0] sdram_data_dummy_o;
wire [`VDATA_O_CO_SLICE] sdram_data_o;


wire [1:0] rdpage_slbuf_sdr_clk_resynced;
wire [11:0] vcnt_o_sdr_clk_resynced;
wire [10:0] vsynclen_o_resynced;

wire [8:0] vcnt_i_vclk_o_resynced;
wire video_llm_vclk_o_resynced;
wire in2out_en_resynced;

wire wren_slbuf_p0, wren_slbuf_p1, wren_slbuf_p2;
wire rden_slbuf_cmb, rden_slbuf_p0, rden_slbuf_p1, rden_slbuf_p2;
wire [`VDATA_O_CO_SLICE] rd_vdata_slbuf_p0, rd_vdata_slbuf_p1, rd_vdata_slbuf_p2, rd_vdata_slbuf, rd_vdata_next_slbuf;

wire [7:0] pix_v_a0_current_w, pix_v_a1_current_w, pix_h_a0_current_w, pix_h_a1_current_w;
wire pix_v_bypass_z0, pix_v_bypass_z1, pix_h_bypass_z0, pix_h_bypass_z1;
wire [1:0] fir_v_calcopcode_w, fir_h_calcopcode_w;

wire [color_width_o-1:0] red_v_interp_out, gr_v_interp_out, bl_v_interp_out;
wire [color_width_o-1:0] red_h_interp_out, gr_h_interp_out, bl_h_interp_out;


wire use_pal_lines;
wire [11:0] X_hpos_offset_w;
wire [10:0] X_vpos_offset_w;
wire [10:0] X_pix_v_org_input_lines_w;
wire [9:0] X_pix_v_input_lines_needed_pal_w, X_pix_v_input_lines_needed_ntsc_w;
wire [36:0] target_lines_resmax_full_w;
wire [39:0] target_hpixel_resmax_full_w;
wire [vcnt_width-1:0] X_vpos_1st_rdline_ntsc_w, X_vpos_1st_rdline_pal_w, X_vpos_1st_rdline_pal_boxed_w;


// cmb regs
reg [1:0] wrpage_sdrambuf_cmb, rdpage_sdrambuf_cmb;
reg [1:0] wrpage_slbuf_cmb, rdpage_slbuf_cmb;

reg [10:0] v_pixel_next_cnt_cmb, v_pixel_cnt_cmb;
reg [28:0] a0_v_full_cmb;

reg [11:0] h_pixel_cnt_cmb;
reg [29:0] a0_h_full_cmb;


// regs
reg nHS_i_L = 1'b0;
reg nVS_i_L = 1'b0;
reg [`VDATA_O_CO_SLICE] vdata_i_L = {(3*color_width_o){1'b0}};

reg input_proc_en;
reg FrameID_i;
reg [hcnt_width-1:0] hcnt_i_L = {hcnt_width{1'b0}};
reg [vcnt_width-1:0] vcnt_i_L = {vcnt_width{1'b0}};
reg [1:0] frame_cnt_i;

reg [hcnt_width-1:0] hstart_i = `HSTART_NTSC;
reg [hcnt_width-1:0] hstop_i  = `HSTOP_NTSC;

//reg [vcnt_width-2:0] vstart_i = `VSTART_NTSC_LX1;
//reg [vcnt_width-2:0] vstop_i  = `VSTOP_NTSC_LX1;
reg [vcnt_width-1:0] vstart_i = `VSTART_NTSC_LX1;
reg [vcnt_width-1:0] vstop_i  = `VSTOP_NTSC_LX1;

reg in2out_en;
reg frame_rdy4out;

reg wren_sdrambuf = 1'b0;
reg [1:0] wrpage_sdrambuf_pre = 2'b10;
reg [1:0] wrpage_sdrambuf = 2'b00;
reg [hpos_width-1:0] wraddr_sdrambuf = {hpos_width{1'b0}};
reg [`VDATA_O_CO_SLICE] sdrambuf_data_i_LL; // data for sdram buffer
reg [3:0] sdrambuf_pageinfo [0:2];
reg [1:0] pageinfo_rdy;

reg sdram_proc_en = 1'b0;

reg rden_sdrambuf = 1'b0;
reg [1:0] rdpage_sdrambuf = 2'b00;
reg [hpos_width-1:0] rdaddr_sdrambuf = {hpos_width{1'b0}};


reg [2:0] sdram_ctrl_state  = ST_SDRAM_WAIT; // state machine

reg sdram_req_i = 1'b0;
reg [22:0] sdram_addr_i = {23{1'b0}}; // (13bits row),(2bits bank),(8bits dblcolumn)

reg sdram_wr_en_i = 1'b0;
reg [1:0] sdram_wr_bank_sel;
reg [vcnt_width-1:0] sdram_wr_vcnt;
reg [`VDATA_O_CO_SLICE] sdram_data_i = {(3*color_width_o){1'b0}};
reg [1:0] frame_cnt_o;

reg [1:0] sdram_rd_bank_sel;
reg [vcnt_width-1:0] sdram_rd_vcnt;
reg [hpos_width-1:0] sdram_rd_hcnt;

reg wren_slbuf, rden_slbuf;
reg [1:0] wrpage_slbuf, rdpage_slbuf;
reg [hpos_width-1:0] wraddr_slbuf, rdaddr_slbuf;
reg [`VDATA_O_CO_SLICE] wr_vdata_slbuf;

reg X_HSYNC_active = `HSYNC_active_480p60;
reg [11:0] X_HSYNCLEN = `HSYNCLEN_480p60;
reg [11:0] X_HSTART = `HSYNCLEN_480p60 + `HBACKPORCH_480p60;
reg [11:0] X_HACTIVE = `HACTIVE_480p60;
reg [11:0] X_HSTOP = `HSYNCLEN_480p60 + `HBACKPORCH_480p60 + `HACTIVE_480p60;
reg [11:0] X_HTOTAL = `HTOTAL_480p60;
reg X_VSYNC_active = `VSYNC_active_480p60;
reg [10:0] X_VSYNCLEN = `VSYNCLEN_480p60;
reg [10:0] X_VSTART = `VSYNCLEN_480p60 + `VBACKPORCH_480p60;
reg [10:0] X_VACTIVE = `VACTIVE_480p60;
reg [10:0] X_VSTOP = `VSYNCLEN_480p60 + `VBACKPORCH_480p60 + `VACTIVE_480p60;
reg [10:0] X_VTOTAL = `VTOTAL_480p60;

reg [11:0] X_HSTART_px = `HSYNCLEN_480p60 + `HBACKPORCH_480p60;
reg [11:0] X_HSTOP_px = `HSYNCLEN_480p60 + `HBACKPORCH_480p60 + `HACTIVE_480p60;
reg [10:0] X_VSTART_px = `VSYNCLEN_480p60 + `VBACKPORCH_480p60;
reg [10:0] X_VSTOP_px = `VSYNCLEN_480p60 + `VBACKPORCH_480p60 + `VACTIVE_480p60;

reg [9:0] X_pix_v_input_lines_needed = `ACTIVE_LINES_NTSC_LX1;
reg [36:0] target_lines_resmax_full;
reg [9:0] X_pix_v_target_input_lines_resmax = `ACTIVE_LINES_NTSC_LX1;
reg [10:0] X_pix_v_active_target_length = 11'd480;

reg [9:0] X_pix_h_input_pixel_needed = `ACTIVE_PIXEL_PER_LINE;
reg [36:0] target_hpixel_resmax_full;
reg [10:0] X_pix_h_target_input_pixel_resmax = `ACTIVE_PIXEL_PER_LINE;
reg [11:0] X_pix_h_active_target_length = 12'd640;

reg [10:0] X_pix_v_org_input_pixel = 11'd240;
reg [10:0] X_pix_v_init_pixel_phase = 11'd120;
reg [10:0] X_pix_v_target_output_pixel = 11'd480;
reg [17:0] X_pix_v_lin_pixel_factor = 18'b001000100010001000;

reg [11:0] X_pix_h_org_input_pixel = 12'd640;
reg [11:0] X_pix_h_init_pixel_phase = 12'd320;
reg [11:0] X_pix_h_target_output_pixel = 12'd640;
reg [17:0] X_pix_h_lin_pixel_factor = 18'b000011001100110011;

reg [hpos_width-1:0] X_hpos_1st_rdpixel;
reg [vcnt_width-1:0] X_vpos_1st_rdline;

reg output_proc_en = 1'b0;

reg [11:0] hcnt_o_L, vcnt_o_L;
reg v_active_de;
reg h_active_de;
reg v_active_px;
reg h_active_px;


reg vphase_init_delay = 1'b1;
reg [1:0] vscale_phase = HVSCALE_PHASE_INVALID;
reg [1:0] hscale_phase = HVSCALE_PHASE_INVALID;

reg [10:0] v_pixel_cnt = 11'd0;
reg [8:0]  v_pixel_load_cnt = 9'd0;
reg pix_v_bypass_z0_current = 1'b0;
reg pix_v_bypass_z1_current = 1'b1;
reg [7:0] pix_v_a0_current = 8'h80;
reg [8:0] pix_v_a0_pre = 9'h100;

reg [11:0] h_pixel_cnt;
reg [9:0] h_pixel_load_cnt;
reg [GEN_SIGNALLING_DELAY+LOAD_PIXEL_BUF_DELAY+VERT_INTERP_DELAY-1:0] pix_h_bypass_z0_current /* synthesis ramstyle = "logic" */;
reg [GEN_SIGNALLING_DELAY+LOAD_PIXEL_BUF_DELAY+VERT_INTERP_DELAY-1:0] pix_h_bypass_z1_current /* synthesis ramstyle = "logic" */;
reg [8:0] pix_h_a0_pre;
reg [7:0] pix_h_a0_current[(GEN_SIGNALLING_DELAY+LOAD_PIXEL_BUF_DELAY+VERT_INTERP_DELAY)-1:H_A0_CALC_DELAY] /* synthesis ramstyle = "logic" */;

reg [Videogen_Pipeline_Length-2:GEN_SIGNALLING_DELAY] DE_virt_vpl_L /* synthesis ramstyle = "logic" */;
reg [Videogen_Pipeline_Length-2:0] HSYNC_vpl_L                      /* synthesis ramstyle = "logic" */;
reg [Videogen_Pipeline_Length-2:0] VSYNC_vpl_L                      /* synthesis ramstyle = "logic" */;
reg [Videogen_Pipeline_Length-2:0] DE_vpl_L                         /* synthesis ramstyle = "logic" */;


// modules

// generate resets

reset_generator reset_scaler_input_u(
  .clk(VCLK_i),
  .clk_en(1'b1),
  .async_nrst_i(async_nRST_i),
  .rst_o(nRST_i)
);

reset_generator reset_DRAM_proc_u(
  .clk(DRAM_CLK_i),
  .clk_en(1'b1),
  .async_nrst_i(async_nRST_i),
  .rst_o(nRST_DRAM_proc)
);

reset_generator reset_scaler_output_u(
  .clk(VCLK_o),
  .clk_en(1'b1),
  .async_nrst_i(async_nRST_i),
  .rst_o(nRST_o)
);

// use a bram buffer for two lines 'in front of' the SRAM
ram2port #(
  .input_regs("OFF"),
  .num_of_pages(3),
  .pagesize(`BUF_DEPTH_PER_PAGE),
  .data_width(3*color_width_o)
) sdram_prebuffer_u(
  .wrCLK(VCLK_i),
  .wren(wren_sdrambuf),
  .wrpage(wrpage_sdrambuf),
  .wraddr(wraddr_sdrambuf),
  .wrdata(sdrambuf_data_i_LL),
  .rdCLK(DRAM_CLK_i),
  .rden(rden_sdrambuf),
  .rdpage(rdpage_sdrambuf),
  .rdaddr(rdaddr_sdrambuf),
  .rddata(sdrambuf_data_o)
);


sdram_ctrl #(
//sdram #(
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


// use a bram buffer 'behind' the SRAM

// generate enable signals for different pages
assign wren_slbuf_p0 = (wrpage_slbuf == 2'b00) & wren_slbuf;
assign wren_slbuf_p1 = (wrpage_slbuf == 2'b01) & wren_slbuf;
assign wren_slbuf_p2 = (wrpage_slbuf == 2'b10) & wren_slbuf;

assign rden_slbuf_p0 = ((rdpage_slbuf == 2'b00) & rden_slbuf) | ((rdpage_slbuf_cmb == 2'b00) & rden_slbuf);
assign rden_slbuf_p1 = ((rdpage_slbuf == 2'b01) & rden_slbuf) | ((rdpage_slbuf_cmb == 2'b01) & rden_slbuf);
assign rden_slbuf_p2 = ((rdpage_slbuf == 2'b10) & rden_slbuf) | ((rdpage_slbuf_cmb == 2'b10) & rden_slbuf);



ram2port #(
  .num_of_pages(1),
  .pagesize(`BUF_DEPTH_PER_PAGE),
  .data_width(3*color_width_o)
) scanlinebuffer_p0_u (
  .wrCLK(DRAM_CLK_i),
  .wren(wren_slbuf_p0),
  .wrpage(1'b0),
  .wraddr(wraddr_slbuf),
  .wrdata(wr_vdata_slbuf),
  .rdCLK(VCLK_o),
  .rden(rden_slbuf_p0),
  .rdpage(1'b0),
  .rdaddr(rdaddr_slbuf),
  .rddata(rd_vdata_slbuf_p0)
);

ram2port #(
  .num_of_pages(1),
  .pagesize(`BUF_DEPTH_PER_PAGE),
  .data_width(3*color_width_o)
) scanlinebuffer_p1_u (
  .wrCLK(DRAM_CLK_i),
  .wren(wren_slbuf_p1),
  .wrpage(1'b0),
  .wraddr(wraddr_slbuf),
  .wrdata(wr_vdata_slbuf),
  .rdCLK(VCLK_o),
  .rden(rden_slbuf_p1),
  .rdpage(1'b0),
  .rdaddr(rdaddr_slbuf),
  .rddata(rd_vdata_slbuf_p1)
);

ram2port #(
  .num_of_pages(1),
  .pagesize(`BUF_DEPTH_PER_PAGE),
  .data_width(3*color_width_o)
) scanlinebuffer_p2_u (
  .wrCLK(DRAM_CLK_i),
  .wren(wren_slbuf_p2),
  .wrpage(1'b0),
  .wraddr(wraddr_slbuf),
  .wrdata(wr_vdata_slbuf),
  .rdCLK(VCLK_o),
  .rden(rden_slbuf_p2),
  .rdpage(1'b0),
  .rdaddr(rdaddr_slbuf),
  .rddata(rd_vdata_slbuf_p2)
);

// merge page outputs
assign rd_vdata_slbuf = (rdpage_slbuf == 2'b00) ? rd_vdata_slbuf_p0 :
                        (rdpage_slbuf == 2'b01) ? rd_vdata_slbuf_p1 :
                                                  rd_vdata_slbuf_p2;

assign rd_vdata_next_slbuf = (rdpage_slbuf_cmb == 2'b00) ? rd_vdata_slbuf_p0 :
                             (rdpage_slbuf_cmb == 2'b01) ? rd_vdata_slbuf_p1 :
                                                           rd_vdata_slbuf_p2;

assign pix_v_a0_current_w = pix_v_a0_current;
assign pix_v_a1_current_w = ~pix_v_a0_current + 8'h01;

assign pix_v_bypass_z1 = (!video_interpolation_mode_i[1] & (pix_v_a1_current_w > FILT_AX_SHARP_TH)) | pix_v_bypass_z1_current;
assign pix_v_bypass_z0 = (!video_interpolation_mode_i[1] & (pix_v_a0_current_w > FILT_AX_SHARP_TH)) | pix_v_bypass_z0_current;

assign fir_v_calcopcode_w[1] = pix_v_bypass_z1 | pix_v_bypass_z0;
assign fir_v_calcopcode_w[0] = pix_v_bypass_z1;

assign pix_h_a0_current_w = pix_h_a0_current[(GEN_SIGNALLING_DELAY+LOAD_PIXEL_BUF_DELAY+VERT_INTERP_DELAY)-1];
assign pix_h_a1_current_w = ~pix_h_a0_current[(GEN_SIGNALLING_DELAY+LOAD_PIXEL_BUF_DELAY+VERT_INTERP_DELAY)-1] + 8'h01;

assign pix_h_bypass_z1 = (!video_interpolation_mode_i[1] & (pix_h_a1_current_w > FILT_AX_SHARP_TH)) | pix_h_bypass_z1_current[Videogen_Pipeline_Length-5];
assign pix_h_bypass_z0 = (!video_interpolation_mode_i[1] & (pix_h_a0_current_w > FILT_AX_SHARP_TH)) | pix_h_bypass_z0_current[Videogen_Pipeline_Length-5];

assign fir_h_calcopcode_w[1] = pix_h_bypass_z1 | pix_h_bypass_z0;
assign fir_h_calcopcode_w[0] = pix_h_bypass_z1;

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


// logic

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
    vdata_i_L <= {(3*color_width_o){1'b0}};
    input_proc_en <= 1'b0;
    FrameID_i <= 1'b0;
    hstart_i <= `HSTART_NTSC;
    hstop_i  <= `HSTOP_NTSC;
    vstart_i <= `VSTART_NTSC_LX1;
    vstop_i  <= `VSTOP_NTSC_LX1;
    nHS_i_L <= 1'b0;
    nVS_i_L <= 1'b0;
    hcnt_i_L <= {hcnt_width{1'b0}};
    vcnt_i_L <= {vcnt_width{1'b0}};
    frame_cnt_i <= 2'b00;
    in2out_en <= 1'b0;
    frame_rdy4out <= 1'b0;
  end else begin
    if (vdata_valid_i) begin
      nHS_i_L <= nHS_i;
      nVS_i_L <= nVS_i;
      vdata_i_L <= vdata_i[`VDATA_O_CO_SLICE];
      
      if (input_proc_en) begin
        if (negedge_nHSYNC) begin
          hcnt_i_L <= 10'd0;
  //        vcnt_i_L <= vcnt_i_L + 2'b10;
          vcnt_i_L <= vcnt_i_L + 1'b1;
          if (((vcnt_i_L == pre_lines_ntsc) && !palmode) ||
              ((vcnt_i_L == pre_lines_pal)  &&  palmode) ) begin
            in2out_en <= 1'b1;
            frame_rdy4out <= 1'b1;
          end
        end else begin
          hcnt_i_L <= hcnt_i_L + 1'b1;
        end
      end

      if (negedge_nVSYNC) begin
        input_proc_en <= sdram_rdy_vclk_i_resynced & output_proc_en_vclk_i_resynced;
        // set new info
        if (palmode) begin
          hstart_i <= !hshift_direction ? `HSTART_PAL + hshift : `HSTART_PAL - hshift;
          hstop_i  <= !hshift_direction ? `HSTOP_PAL  + hshift : `HSTOP_PAL  - hshift;
          vstart_i <=  vshift_direction ? `VSTART_PAL_LX1 + vshift : `VSTART_PAL_LX1 - vshift;
          vstop_i  <=  vshift_direction ? `VSTOP_PAL_LX1  + vshift : `VSTOP_PAL_LX1  - vshift;
        end else begin
          hstart_i <= !hshift_direction ? `HSTART_NTSC + hshift : `HSTART_NTSC - hshift;
          hstop_i  <= !hshift_direction ? `HSTOP_NTSC  + hshift : `HSTOP_NTSC  - hshift;
          vstart_i <=  vshift_direction ? `VSTART_NTSC_LX1 + vshift : `VSTART_NTSC_LX1 - vshift;
          vstop_i  <=  vshift_direction ? `VSTOP_NTSC_LX1  + vshift : `VSTOP_NTSC_LX1  - vshift;
        end
      
        FrameID_i <= negedge_nHSYNC; // negedge at nHSYNC, too -> odd frame
        vcnt_i_L <= {vcnt_width{1'b0}};
        if (in2out_en) begin
  //        if (negedge_nHSYNC)
            frame_cnt_i <= frame_cnt_i + 1'b1;
        end else begin
          frame_cnt_i <= 2'b00;
        end
        frame_rdy4out <= 1'b0;
      end
    end
  end


always @(*) begin
  if (wrpage_sdrambuf[1]) begin
    wrpage_sdrambuf_cmb <= 2'b00;
  end else begin
    wrpage_sdrambuf_cmb[1] <=  wrpage_sdrambuf[0];
    wrpage_sdrambuf_cmb[0] <= ~wrpage_sdrambuf[0];
  end
end

assign vdata_i_vactive_w = (vcnt_i_L >= vstart_i && vcnt_i_L < vstop_i);
assign vdata_i_hactive_w = (hcnt_i_L >= hstart_i && hcnt_i_L < hstop_i);

always @(posedge VCLK_i or negedge nRST_i)
  if (!nRST_i) begin
    wren_sdrambuf <= 1'b0;
    wrpage_sdrambuf_pre <= 2'b10;
    wrpage_sdrambuf <= 2'b00;
    wraddr_sdrambuf <= {hpos_width{1'b0}};
    sdrambuf_data_i_LL <= {(3*color_width_o){1'b0}};
    sdrambuf_pageinfo[0] <= 4'h0;
    sdrambuf_pageinfo[1] <= 4'h0;
    sdrambuf_pageinfo[2] <= 4'h0;
    pageinfo_rdy <= 2'b00;
  end else begin
    if (vdata_valid_i) begin
      if (vdata_i_vactive_w & input_proc_en) begin
        if (vdata_i_hactive_w) begin
          sdrambuf_data_i_LL <= vdata_i_L;
          wren_sdrambuf <= 1'b1;
          wraddr_sdrambuf <= (hcnt_i_L == hstart_i) ? {hpos_width{1'b0}} : wraddr_sdrambuf + 1'b1;
        end
        if (hcnt_i_L == hstop_i) begin // write page info
          sdrambuf_pageinfo[wrpage_sdrambuf] <= {frame_cnt_i,frame_rdy4out,FrameID_i};
          pageinfo_rdy[0] <= 1'b1;
        end
      end
      if (pageinfo_rdy[0] && !pageinfo_rdy[1]) begin
        wrpage_sdrambuf_pre <= wrpage_sdrambuf;
      end
      if (pageinfo_rdy[1]) begin // change page delayed to page info write to avoid racing conditions to SDRAM clock domain
        wrpage_sdrambuf <= wrpage_sdrambuf_cmb;
        pageinfo_rdy <= 2'b00;
      end else begin
        pageinfo_rdy[1] <= pageinfo_rdy[0];
      end
    end else begin
      wren_sdrambuf <= 1'b0;
    end
  end


register_sync #(
  .reg_width(1),
  .reg_preset(1'b0)
) register_sync_vclki2dram_u0 (
  .clk(DRAM_CLK_i),
  .clk_en(1'b1),
  .nrst(1'b1),
  .reg_i(video_llm_i),
  .reg_o(sdram_llm_sdr_clk_resynced)
);

register_sync_2 #(
  .reg_width(6),
  .reg_preset(6'h00),
  .resync_stages(resync_stages)
) register_sync_vclki2dram_u1 (
  .nrst(async_nRST_i),
  .clk_i(VCLK_i),
  .clk_i_en(1'b1),
  .reg_i({sdrambuf_pageinfo[wrpage_sdrambuf_pre],wrpage_sdrambuf}),
  .clk_o(DRAM_CLK_i),
  .clk_o_en(1'b1),
  .reg_o({sdrambuf_pageinfo_sdr_clk_resynced,wrpage_sdrambuf_sdr_clk_resynced})
);

register_sync #(
  .reg_width(vcnt_width),
  .reg_preset(`VSYNCLEN_480p60 + `VBACKPORCH_480p60)
) register_sync_vclko2dram_u0 (
  .clk(DRAM_CLK_i),
  .clk_en(1'b1),
  .nrst(nRST_DRAM_proc),
  .reg_i(X_vpos_1st_rdline),
  .reg_o(vpos_1st_rdline_clk_resynced)
);

register_sync #(
  .reg_width(11),
  .reg_preset(`VSYNCLEN_480p60)
) register_sync_vclko2dram_u1 (
  .clk(DRAM_CLK_i),
  .clk_en(1'b1),
  .nrst(1'b1),
//  .nrst(nRST_DRAM_proc),
  .reg_i(X_VSYNCLEN),
  .reg_o(vsynclen_o_resynced)
);

register_sync_2 #(
  .reg_width(12),
  .reg_preset({12{1'b0}}),
  .resync_stages(resync_stages)
) register_sync_vclko2dram_u2 (
  .nrst(async_nRST_i),
  .clk_i(VCLK_o),
  .clk_i_en(1'b1),
  .reg_i(vcnt_o_L),
  .clk_o(DRAM_CLK_i),
  .clk_o_en(1'b1),
  .reg_o(vcnt_o_sdr_clk_resynced)
);

register_sync_2 #(
  .reg_width(2),
  .reg_preset(2'b00),
  .resync_stages(resync_stages)
) register_sync_vclko2dram_u3 (
  .nrst(async_nRST_i),
  .clk_i(VCLK_o),
  .clk_i_en(1'b1),
  .reg_i(rdpage_slbuf),
  .clk_o(DRAM_CLK_i),
  .clk_o_en(1'b1),
  .reg_o(rdpage_slbuf_sdr_clk_resynced)
);

// SDRAM addr_usage:
// - row LSB0 and 8bits dblcolumn: pixel count per line
// - row (10:1): line count
// - row (12:11): two unused bits
// - bank: frame page (allows for four frames in sdram)
//
// deinterlacing:
//   - bob deinterlacing -> pushing even and odd frames into different frame pages (first implementation attempt)
//   - true interlacing -> pushing even and odd frame into same frame page
//                         repeating each frame twice

always @(*) begin
  if (rdpage_sdrambuf[1]) begin
    rdpage_sdrambuf_cmb <= 2'b00;
  end else begin
    rdpage_sdrambuf_cmb[1] <=  rdpage_sdrambuf[0];
    rdpage_sdrambuf_cmb[0] <= ~rdpage_sdrambuf[0];
  end
  if (wrpage_slbuf[1]) begin
    wrpage_slbuf_cmb <= 2'b00;
  end else begin
    wrpage_slbuf_cmb[1] <=  wrpage_slbuf[0];
    wrpage_slbuf_cmb[0] <= ~wrpage_slbuf[0];
  end
end

always @(posedge DRAM_CLK_i or negedge nRST_DRAM_proc)
  if (!nRST_DRAM_proc) begin
    sdram_proc_en <= 1'b0;
    
    rden_sdrambuf <= 1'b0;
    rdpage_sdrambuf <= 2'b00;
    rdaddr_sdrambuf <= {hpos_width{1'b0}};
  
    sdram_ctrl_state <= ST_SDRAM_WAIT;
    sdram_req_i <= 1'b0;
    sdram_wr_en_i <= 1'b0;
    sdram_wr_bank_sel <= 2'b00;
    sdram_wr_vcnt <= {vcnt_width{1'b0}};
    sdram_data_i <= {(3*color_width_o){1'b0}};
    
    frame_cnt_o <= 2'b00;
    sdram_rd_bank_sel <= 2'b00;
    sdram_rd_vcnt <= {vcnt_width{1'b0}};
    sdram_rd_hcnt <= {hpos_width{1'b0}};
    
    wren_slbuf <= 1'b0;
    wraddr_slbuf <= {hpos_width{1'b0}};
    wrpage_slbuf <= 2'b00;
    wr_vdata_slbuf <= {(3*color_width_o){1'b0}}; // ggf. als wire direkt an Ausgangs-Buffer
  end else begin
    case (sdram_ctrl_state)
      ST_SDRAM_WAIT: begin
          sdram_proc_en <= 1'b1;
          if (rdpage_sdrambuf != wrpage_sdrambuf_sdr_clk_resynced) begin
            // - Buffer hat umgeschaltet -> Elemente im SDRAM sichern
            sdram_addr_i[20:19] <= 2'b00;               // unused
            sdram_addr_i[ 9: 0] <= {hpos_width{1'b0}};  // horizontal position
            if (sdrambuf_pageinfo_sdr_clk_resynced[3:2] != sdram_wr_bank_sel) begin
              sdram_wr_bank_sel <= sdrambuf_pageinfo_sdr_clk_resynced[3:2];   // set new bank for frame
              sdram_wr_vcnt <= {vcnt_width{1'b0}};                            // reset vertical position
              sdram_addr_i[22:21] <= sdrambuf_pageinfo_sdr_clk_resynced[3:2]; // use new bank for frame
              sdram_addr_i[18:10] <= {vcnt_width{1'b0}};                      // use vertical position zero
            end else begin
              sdram_addr_i[22:21] <= sdram_wr_bank_sel; // set bank for frame
              sdram_addr_i[18:10] <= sdram_wr_vcnt;     // set vertical position
            end
            if (sdram_llm_sdr_clk_resynced) begin
              frame_cnt_o <= sdrambuf_pageinfo_sdr_clk_resynced[3:2];   // set output frame to current frame in low latency mode
            end else begin
              if (sdrambuf_pageinfo_sdr_clk_resynced[1])                // current input frame is fairly ahead for free running mode, ...
                frame_cnt_o <= sdrambuf_pageinfo_sdr_clk_resynced[3:2]; // ... so set output frame to current frame 
            end
            rden_sdrambuf <= 1'b1;
            rdaddr_sdrambuf <= {hpos_width{1'b0}};
            sdram_ctrl_state <= ST_SDRAM_FIFO2RAM0;
          end else if (vcnt_o_sdr_clk_resynced == vsynclen_o_resynced) begin // fetch first line
            sdram_rd_bank_sel <= frame_cnt_o;
            sdram_rd_vcnt <= vpos_1st_rdline_clk_resynced;
            sdram_rd_hcnt <= {hpos_width{1'b0}};
            wrpage_slbuf <= 2'b00;
            wraddr_slbuf <= {hpos_width{1'b1}};
            sdram_ctrl_state <= ST_SDRAM_RAM2BUF0;
          end else if (vcnt_o_sdr_clk_resynced > vsynclen_o_resynced &&
                       wrpage_slbuf_cmb != rdpage_slbuf_sdr_clk_resynced ) begin  // fetch concurrent lines on demand
            sdram_rd_vcnt <= sdram_rd_vcnt + 1'b1;
            sdram_rd_hcnt <= {hpos_width{1'b0}};
            wrpage_slbuf <= wrpage_slbuf_cmb;
            wraddr_slbuf <= {hpos_width{1'b1}};
            sdram_ctrl_state <= ST_SDRAM_RAM2BUF0;
          end
        end
      ST_SDRAM_FIFO2RAM0: begin
          rdaddr_sdrambuf[0] <= 1'b1; // fetch next element
          sdram_ctrl_state <= ST_SDRAM_FIFO2RAM1;
        end
      ST_SDRAM_FIFO2RAM1: begin
          // - frage Schreiben in SDRAM an
          sdram_req_i <= 1'b1;
          sdram_wr_en_i <= 1'b1;
          sdram_data_i <= sdrambuf_data_o;
          rden_sdrambuf <= 1'b0;
          sdram_ctrl_state <= ST_SDRAM_FIFO2RAM2;
        end
      ST_SDRAM_FIFO2RAM2: begin
          // - frage Schreiben an
          // - setze mit oberstem FIFO-Element Startadresse für kommenden 640 Elemente
          // - schreibe 640 Elemente in SDRAM          
          if (sdram_cmd_ack_o) begin
            sdram_data_i <= sdrambuf_data_o;
            sdram_addr_i[9:0] <= rdaddr_sdrambuf;
            rden_sdrambuf <= (rdaddr_sdrambuf < `ACTIVE_PIXEL_PER_LINE);
            rdaddr_sdrambuf <= rdaddr_sdrambuf + 1'b1;
            if (rdaddr_sdrambuf == `ACTIVE_PIXEL_PER_LINE) begin
              sdram_req_i <= 1'b0;
              sdram_wr_en_i <= 1'b0;
              sdram_ctrl_state <= ST_SDRAM_WAIT;
              sdram_wr_vcnt <= sdram_wr_vcnt + 1'b1;  // increment vertical position
              rdpage_sdrambuf <= rdpage_sdrambuf_cmb;
            end
          end else
            rden_sdrambuf <= 1'b0;
        end
      ST_SDRAM_RAM2BUF0: begin
          sdram_req_i <= 1'b1;
          sdram_addr_i[22:21] <= sdram_rd_bank_sel; // bank for frame
          sdram_addr_i[20:19] <= 2'b00;             // unused
          sdram_addr_i[18:10] <= sdram_rd_vcnt;     // vertical position
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
            wren_slbuf <= 1'b1;
            wraddr_slbuf <= wraddr_slbuf + 1'b1;
            wr_vdata_slbuf <= sdram_data_o;
          end else begin
            wren_slbuf <= 1'b0;
            if (wraddr_slbuf == `ACTIVE_PIXEL_PER_LINE - 1)
              sdram_ctrl_state <= ST_SDRAM_WAIT;
          end
        end
      default:
        sdram_ctrl_state <= ST_SDRAM_WAIT;
    endcase
  end


register_sync_2 #(
  .reg_width(vcnt_width),
  .reg_preset({(vcnt_width){1'b0}}),
  .resync_stages(resync_stages)
) register_sync_input2hdmi_u0 (
  .nrst(async_nRST_i),
  .clk_i(VCLK_i),
  .clk_i_en(1'b1),
  .reg_i(vcnt_i_L),
  .clk_o(VCLK_o),
  .clk_o_en(1'b1),
  .reg_o(vcnt_i_vclk_o_resynced)
);

register_sync #(
  .reg_width(1),
  .reg_preset(1'b0)
) register_sync_input2hdmi_u1 (
  .clk(VCLK_o),
  .clk_en(1'b1),
  .nrst(1'b1),
  .reg_i(video_llm_i),
  .reg_o(video_llm_vclk_o_resynced)
);

register_sync_2 #(
  .reg_width(1),
  .reg_preset(1'b0),
  .resync_stages(resync_stages)
) register_sync_input2hdmi_u2 (
  .nrst(async_nRST_i),
  .clk_i(VCLK_i),
  .clk_i_en(1'b1),
  .reg_i(in2out_en),
  .clk_o(VCLK_o),
  .clk_o_en(1'b1),
  .reg_o(in2out_en_resynced)
);


assign use_pal_lines = palmode_vclk_o_resynced && !video_pal_boxed_i;

assign X_pix_v_input_lines_needed_pal_w  = (X_pix_v_target_input_lines_resmax < `ACTIVE_LINES_PAL_LX1)  ? X_pix_v_target_input_lines_resmax : `ACTIVE_LINES_PAL_LX1;
assign X_pix_v_input_lines_needed_ntsc_w = (X_pix_v_target_input_lines_resmax < `ACTIVE_LINES_NTSC_LX1) ? X_pix_v_target_input_lines_resmax : `ACTIVE_LINES_NTSC_LX1;

assign X_pix_v_org_input_lines_w = use_pal_lines ? `ACTIVE_LINES_PAL_LX1 : `ACTIVE_LINES_NTSC_LX1;

assign X_vpos_offset_w = (X_pix_v_active_target_length < X_VACTIVE) ? (X_VACTIVE - X_pix_v_active_target_length)/2 : 11'd0;
assign X_hpos_offset_w = (X_pix_h_active_target_length < X_HACTIVE) ? (X_HACTIVE - X_pix_h_active_target_length)/2 : 12'd0;

assign target_lines_resmax_full_w = video_inv_vscale_i * (* multstyle = "dsp" *) X_VACTIVE;
assign target_hpixel_resmax_full_w = video_inv_hscale_i * (* multstyle = "dsp" *) X_HACTIVE;

assign X_vpos_1st_rdline_ntsc_w = (X_pix_v_target_input_lines_resmax < `ACTIVE_LINES_NTSC_LX1) ? (`ACTIVE_LINES_NTSC_LX1 - X_pix_v_target_input_lines_resmax)/2 : {vcnt_width{1'b0}};
assign X_vpos_1st_rdline_pal_w = (X_pix_v_target_input_lines_resmax < `ACTIVE_LINES_PAL_LX1) ? (`ACTIVE_LINES_PAL_LX1 - X_pix_v_target_input_lines_resmax)/2 : {vcnt_width{1'b0}};
assign X_vpos_1st_rdline_pal_boxed_w = (X_pix_v_target_input_lines_resmax < `ACTIVE_LINES_NTSC_LX1) ? (`ACTIVE_LINES_PAL_LX1 - X_pix_v_target_input_lines_resmax)/2 : {{(vcnt_width-5){1'b0}},5'd24};

always @(posedge VCLK_o) 
  if (vcnt_o_L == 0 && hcnt_o_L[11:4] == 0) begin
    if (hcnt_o_L[3:0] == 4'd0) begin  // setup video timings for this frame
      setVideoVTimings(video_config_i,X_VSYNC_active,X_VSYNCLEN,X_VSTART,X_VACTIVE,X_VSTOP,X_VTOTAL);
      setVideoHTimings(video_config_i,X_HSYNC_active,X_HSYNCLEN,X_HSTART,X_HACTIVE,X_HSTOP,X_HTOTAL);
    end
    if (hcnt_o_L[3:0] == 4'd2) begin  // setup scaling a bit delayed to have stable video timings
      setVScaleTargets(video_vscale_factor_i,use_pal_lines,X_pix_v_active_target_length);
      target_lines_resmax_full <= target_lines_resmax_full_w;
      
      setHScaleTargets(video_hscale_factor_i,X_pix_h_active_target_length);
      target_hpixel_resmax_full <= target_hpixel_resmax_full_w;
      
      X_pix_v_org_input_pixel <= X_pix_v_org_input_lines_w;
      X_pix_v_target_output_pixel <= video_vpixel_out_i;
      X_pix_v_lin_pixel_factor <= video_vfactor_lin_i;
      
      X_pix_h_org_input_pixel <= `ACTIVE_PIXEL_PER_LINE;
      X_pix_h_target_output_pixel <= video_hpixel_out_i;
      X_pix_h_lin_pixel_factor <= video_hfactor_lin_i;
    end
    if (hcnt_o_L[3:0] == 4'd4) begin  // setup some configs even more delayed
      X_HSTART_px <= X_HSTART + X_hpos_offset_w;
      X_HSTOP_px <= X_HSTOP - X_hpos_offset_w;
      X_VSTART_px <= X_VSTART + X_vpos_offset_w;
      X_VSTOP_px <= X_VSTOP - X_vpos_offset_w;
      
      X_pix_v_target_input_lines_resmax <= target_lines_resmax_full[33:24] + target_lines_resmax_full[23];
      X_pix_h_target_input_pixel_resmax <= target_hpixel_resmax_full[33:23] + target_hpixel_resmax_full[22];
      
      X_pix_v_init_pixel_phase <= |video_interpolation_mode_i ? X_pix_v_org_input_pixel/2 + X_pix_v_target_output_pixel/2 : X_pix_v_org_input_pixel/2;
      X_pix_h_init_pixel_phase <= |video_interpolation_mode_i ? X_pix_h_org_input_pixel/2 + X_pix_h_target_output_pixel/2 : X_pix_h_org_input_pixel/2;
    end
    if (hcnt_o_L[3:0] == 4'd6) begin  // setup some configs even much more delayed
      X_pix_v_input_lines_needed <= use_pal_lines ? X_pix_v_input_lines_needed_pal_w : X_pix_v_input_lines_needed_ntsc_w;
      X_pix_h_input_pixel_needed <= (X_pix_h_target_input_pixel_resmax < `ACTIVE_PIXEL_PER_LINE) ? X_pix_h_target_input_pixel_resmax : `ACTIVE_PIXEL_PER_LINE;
      X_vpos_1st_rdline <= !palmode_vclk_o_resynced ? X_vpos_1st_rdline_ntsc_w :
                                  video_pal_boxed_i ? X_vpos_1st_rdline_pal_boxed_w : X_vpos_1st_rdline_pal_w;
      X_hpos_1st_rdpixel <= (X_pix_h_target_input_pixel_resmax < `ACTIVE_PIXEL_PER_LINE) ? `ACTIVE_PIXEL_PER_LINE/2 - X_pix_h_target_input_pixel_resmax/2 : 0;
    end
  end


always @(*) begin
  if (rdpage_slbuf[1]) begin
    rdpage_slbuf_cmb <= 2'b00;
  end else begin
    rdpage_slbuf_cmb[1] <=  rdpage_slbuf[0];
    rdpage_slbuf_cmb[0] <= ~rdpage_slbuf[0];
  end
end

always @(*) begin
  v_pixel_next_cnt_cmb <= 2*v_pixel_cnt + X_pix_v_org_input_pixel;
  v_pixel_cnt_cmb <= v_pixel_cnt + X_pix_v_org_input_pixel;
  a0_v_full_cmb <= v_pixel_cnt * (* multstyle = "dsp" *) X_pix_v_lin_pixel_factor;
  
  h_pixel_cnt_cmb <= h_pixel_cnt + X_pix_h_org_input_pixel;
  a0_h_full_cmb <= h_pixel_cnt * (* multstyle = "dsp" *) X_pix_h_lin_pixel_factor;
end


always @(posedge VCLK_o or negedge nRST_o)
  if (!nRST_o) begin
    output_proc_en <= 1'b0;
    
    hcnt_o_L <= 0;
    vcnt_o_L <= 0;
    v_active_de <= 1'b0;
    h_active_de <= 1'b0;
    v_active_px <= 1'b0;
    h_active_px <= 1'b0;
    
    rden_slbuf <= 1'b0;
    rdpage_slbuf <= 2'b00;
    rdaddr_slbuf <= {hpos_width{1'b0}};
    
    vphase_init_delay <= 1'b1;
    vscale_phase <= HVSCALE_PHASE_INVALID;
    v_pixel_cnt <= 11'd0;
    v_pixel_load_cnt <= 9'd0;
    pix_v_bypass_z0_current <= 1'b0;
    pix_v_bypass_z1_current <= 1'b1;
    pix_v_a0_current <= 8'h80;
    
    hscale_phase <= HVSCALE_PHASE_INVALID;
    h_pixel_cnt <= 12'd0;
    h_pixel_load_cnt <= 10'd0;
    
    pix_h_bypass_z0_current <= {(GEN_SIGNALLING_DELAY+LOAD_PIXEL_BUF_DELAY+VERT_INTERP_DELAY){1'b0}};
    pix_h_bypass_z1_current <= {(GEN_SIGNALLING_DELAY+LOAD_PIXEL_BUF_DELAY+VERT_INTERP_DELAY){1'b0}};
    for (int_idx = H_A0_CALC_DELAY; int_idx < (GEN_SIGNALLING_DELAY+LOAD_PIXEL_BUF_DELAY+VERT_INTERP_DELAY); int_idx = int_idx + 1)
      pix_h_a0_current[int_idx] <= 8'h80;
    pix_h_a0_pre <= 9'h040;
    
    DE_virt_vpl_L <= {(Videogen_Pipeline_Length-GEN_SIGNALLING_DELAY-1){1'b0}};
    HSYNC_vpl_L <= {(Videogen_Pipeline_Length-1){1'b0}};
    VSYNC_vpl_L <= {(Videogen_Pipeline_Length-1){1'b0}};
    DE_vpl_L <= {(Videogen_Pipeline_Length-1){1'b0}};
    
    vinfo_llm_slbuf_fb_o <= 9'b0;
    
    drawSL <= 3'b000;
    HSYNC_o <= 1'b0;
    VSYNC_o <= 1'b0;
    DE_o <= 1'b0;
    vdata_o <= {(3*color_width_o){1'b0}};
  end else begin
    output_proc_en <= 1'b1;
    // generate sync
    if (in2out_en_resynced) begin
      if (hcnt_o_L < X_HTOTAL - 1) begin
        hcnt_o_L <= hcnt_o_L + 1;
      end else begin
        hcnt_o_L <= 0;
      end
      if ((hcnt_o_L == X_HSTART-1) || (hcnt_o_L == X_HSTOP-1)) // next clock cycle either hcnt_o_L == X_HSTART or hcnt_o_L == X_HSTOP
        h_active_de <= ~h_active_de;
      if ((hcnt_o_L == X_HSTART_px-1) || (hcnt_o_L == X_HSTOP_px-1)) // next clock cycle either hcnt_o_L == X_HSTART_px or hcnt_o_L == X_HSTOP_px
        h_active_px <= ~h_active_px;
      if (hcnt_o_L == X_HTOTAL-1) begin
        if (vcnt_o_L < X_VTOTAL - 1) begin
          vcnt_o_L <= vcnt_o_L + 1;
        end else begin
          vcnt_o_L <= 0;
        end
        if ((vcnt_o_L == X_VSTART-1) || (vcnt_o_L == X_VSTOP-1)) // next clock cycle either vcnt_o_L == X_VSTART or vcnt_o_L == X_VSTOP
          v_active_de <= ~v_active_de;
        if ((vcnt_o_L == X_VSTART_px-1) || (vcnt_o_L == X_VSTOP_px-1)) // next clock cycle either vcnt_o_L == X_VSTART_px or vcnt_o_L == X_VSTOP_px
          v_active_px <= ~v_active_px;
      end
      if (vcnt_o_L == 0 && hcnt_o_L == 4 && video_llm_vclk_o_resynced)
        vinfo_llm_slbuf_fb_o <= vcnt_i_vclk_o_resynced;
    end else begin
      vcnt_o_L <= 0;
      hcnt_o_L <= 0;
      v_active_de <= 1'b0;
      h_active_de <= 1'b0;
      v_active_px <= 1'b0;
      h_active_px <= 1'b0;
    end
    if (v_active_px) begin
      if (hcnt_o_L == 0) begin
        case (vscale_phase)
          HVSCALE_PHASE_INIT: begin
              if (v_pixel_cnt_cmb >= X_pix_v_target_output_pixel && v_pixel_load_cnt[0]) begin
                drawSL[0] <= 1'b0;
                vscale_phase <= HVSCALE_PHASE_MAIN;
                if (|video_interpolation_mode_i) begin
                  pix_v_bypass_z0_current <= 1'b0;
                  pix_v_bypass_z1_current <= v_pixel_cnt_cmb == X_pix_v_target_output_pixel;
                end else begin
                  pix_v_bypass_z0_current <= v_pixel_cnt_cmb > X_pix_v_target_output_pixel ;
                  pix_v_bypass_z1_current <= 1'b0;
                end
                v_pixel_cnt <= v_pixel_cnt_cmb - X_pix_v_target_output_pixel;
                v_pixel_load_cnt <= v_pixel_load_cnt + 9'd1;
              end else begin
                if (vphase_init_delay) begin
                  vphase_init_delay <= 1'b0;
                end else begin
                  drawSL[0] <= (v_pixel_next_cnt_cmb >= X_pix_v_target_output_pixel);
                  v_pixel_cnt <= v_pixel_cnt_cmb;
                  v_pixel_load_cnt <= 9'd1;
                end
              end
            end
          HVSCALE_PHASE_MAIN: begin
              if (v_pixel_cnt_cmb >= X_pix_v_target_output_pixel) begin
                drawSL[0] <= 1'b0;
                if (v_pixel_load_cnt == X_pix_v_input_lines_needed - 1)
                  vscale_phase <= HVSCALE_PHASE_POST;
                v_pixel_cnt <= v_pixel_cnt_cmb - X_pix_v_target_output_pixel;
                v_pixel_load_cnt <= v_pixel_load_cnt + 9'd1;
                rdpage_slbuf <= rdpage_slbuf_cmb;
                if (|video_interpolation_mode_i) begin
                  pix_v_bypass_z0_current <= 1'b0;
                  pix_v_bypass_z1_current <= v_pixel_cnt_cmb == X_pix_v_target_output_pixel;
                end else begin
                  pix_v_bypass_z0_current <= v_pixel_cnt_cmb > X_pix_v_target_output_pixel ;
                  pix_v_bypass_z1_current <= 1'b0;
                end
              end else begin
                drawSL[0] <= (v_pixel_next_cnt_cmb >= X_pix_v_target_output_pixel);
                v_pixel_cnt <= v_pixel_cnt_cmb;
                pix_v_bypass_z0_current <= ~|video_interpolation_mode_i;
                pix_v_bypass_z1_current <= 1'b0;
              end
            end
          HVSCALE_PHASE_POST: begin
              drawSL[0] <= 1'b0;
              if (v_pixel_cnt_cmb >= X_pix_v_target_output_pixel) begin
                vscale_phase <= HVSCALE_PHASE_INVALID;
                pix_v_bypass_z0_current <= 1'b1;
                pix_v_bypass_z1_current <= 1'b0;
              end else begin
                v_pixel_cnt <= v_pixel_cnt_cmb;
                pix_v_bypass_z0_current <= ~|video_interpolation_mode_i;
                pix_v_bypass_z1_current <= 1'b0;
              end
            end
        endcase        
      end
//      pix_v_a0_current <= pix_v_a0_pre[8:1] + pix_v_a0_pre[0];
//      pix_v_a0_pre <= |video_interpolation_mode_i ? a0_v_full_cmb[23:15] : 9'h100;
    end else begin
      drawSL[0] <= 1'b0;
      rdpage_slbuf <= 2'b00;
      vphase_init_delay <= 1'b1;
      vscale_phase <= HVSCALE_PHASE_INIT;
      v_pixel_cnt <= X_pix_v_init_pixel_phase;
      v_pixel_load_cnt <= 9'd0;
      pix_v_a0_pre <= 9'h100;
      pix_v_bypass_z0_current <= 1'b0;
      pix_v_bypass_z1_current <= 1'b1;
    end
    if (v_active_px & h_active_px) begin
      case (hscale_phase)
        HVSCALE_PHASE_INIT: begin
            hscale_phase <= HVSCALE_PHASE_MAIN;
            h_pixel_load_cnt <= 10'd1;
            pix_h_bypass_z0_current[0] <= 1'b1; // always!
            pix_h_bypass_z1_current[0] <= 1'b0; // always!
          end
        HVSCALE_PHASE_MAIN: begin
            if (h_pixel_cnt_cmb >= X_pix_h_target_output_pixel) begin
              if (h_pixel_load_cnt == X_pix_h_input_pixel_needed - 1)
                hscale_phase <= HVSCALE_PHASE_POST;
              h_pixel_cnt <= h_pixel_cnt_cmb - X_pix_h_target_output_pixel;
              rdaddr_slbuf <= rdaddr_slbuf + 1'b1;
              h_pixel_load_cnt <= h_pixel_load_cnt + 10'd1;
              if (|video_interpolation_mode_i) begin
                pix_h_bypass_z0_current[0] <= 1'b0;
                pix_h_bypass_z1_current[0] <= h_pixel_cnt_cmb == X_pix_h_target_output_pixel;
              end else begin
                pix_h_bypass_z0_current[0] <= h_pixel_cnt_cmb > X_pix_h_target_output_pixel ;
                pix_h_bypass_z1_current[0] <= 1'b0;
              end
            end else begin
              h_pixel_cnt <= h_pixel_cnt_cmb;
              pix_h_bypass_z0_current[0] <= h_pixel_load_cnt == 10'd1 ? 1'b1 : ~|video_interpolation_mode_i;
            end
          end
        HVSCALE_PHASE_POST: begin
            if (h_pixel_cnt_cmb >= X_pix_h_input_pixel_needed) begin
              hscale_phase <= HVSCALE_PHASE_INVALID;
              pix_h_bypass_z0_current[0] <= 1'b1;
              pix_h_bypass_z1_current[0] <= 1'b0;
            end else begin
              h_pixel_cnt <= h_pixel_cnt_cmb;
              pix_h_bypass_z0_current[0] <= ~|video_interpolation_mode_i;
              pix_h_bypass_z1_current[0] <= 1'b0;
            end
          end
      endcase
      pix_h_a0_pre <= |video_interpolation_mode_i ? a0_h_full_cmb[22:14] : 9'h040;
    end else begin
      hscale_phase <= HVSCALE_PHASE_INIT;
      h_pixel_load_cnt <= 10'd0;
      pix_h_bypass_z0_current[0] <= 1'b0;
      pix_h_bypass_z1_current[0] <= 1'b0;
      rdaddr_slbuf <= X_hpos_1st_rdpixel;
      h_pixel_cnt <= X_pix_h_init_pixel_phase;
      pix_h_a0_pre <= 9'h100;
    end
    
    drawSL[2:1] <= drawSL[1:0];
    
    rden_slbuf <= v_active_px & h_active_px;
    pix_v_a0_current <= pix_v_a0_pre[8:1] + pix_v_a0_pre[0];
    pix_v_a0_pre <= |video_interpolation_mode_i ? a0_v_full_cmb[23:15] : 9'h100;
    
    pix_h_bypass_z0_current[GEN_SIGNALLING_DELAY+LOAD_PIXEL_BUF_DELAY+VERT_INTERP_DELAY-1:1] <= pix_h_bypass_z0_current[GEN_SIGNALLING_DELAY+LOAD_PIXEL_BUF_DELAY+VERT_INTERP_DELAY-2:0];
    pix_h_bypass_z1_current[GEN_SIGNALLING_DELAY+LOAD_PIXEL_BUF_DELAY+VERT_INTERP_DELAY-1:1] <= pix_h_bypass_z1_current[GEN_SIGNALLING_DELAY+LOAD_PIXEL_BUF_DELAY+VERT_INTERP_DELAY-2:0];
    for (int_idx = (GEN_SIGNALLING_DELAY+LOAD_PIXEL_BUF_DELAY+VERT_INTERP_DELAY)-1; int_idx > H_A0_CALC_DELAY; int_idx = int_idx - 1)
      pix_h_a0_current[int_idx] <= pix_h_a0_current[int_idx-1];
    pix_h_a0_current[H_A0_CALC_DELAY] <= pix_h_a0_pre[8:1] + pix_h_a0_pre[0];
    
    DE_virt_vpl_L <= {DE_virt_vpl_L[Videogen_Pipeline_Length-3:GEN_SIGNALLING_DELAY],rden_slbuf};
    HSYNC_vpl_L <= {HSYNC_vpl_L[Videogen_Pipeline_Length-3:0],(hcnt_o_L < X_HSYNCLEN) ~^ X_HSYNC_active};
    VSYNC_vpl_L <= {VSYNC_vpl_L[Videogen_Pipeline_Length-3:0],(vcnt_o_L < X_VSYNCLEN) ~^ X_VSYNC_active};
    DE_vpl_L <= {DE_vpl_L[Videogen_Pipeline_Length-3:0],(h_active_de && v_active_de)};
    
    HSYNC_o <= HSYNC_vpl_L[Videogen_Pipeline_Length-2];
    VSYNC_o <= VSYNC_vpl_L[Videogen_Pipeline_Length-2];
    DE_o <= DE_vpl_L[Videogen_Pipeline_Length-2];
    
    if (DE_virt_vpl_L[Videogen_Pipeline_Length-2] & DE_vpl_L[Videogen_Pipeline_Length-2])
      vdata_o <= {red_h_interp_out,gr_h_interp_out,bl_h_interp_out};
    else
      vdata_o <= {(3*color_width_o){1'b0}};
  end

endmodule
