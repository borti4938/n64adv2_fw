

module scaler(
  VCLK_i,
  nRST_i,
  vinfo_i,
  vdata_i,
  vdata_valid_i,
  vdata_hvshift,
  scaler_nresync_i,

  VCLK_o,
  nRST_o,
  video_config_i,
  video_llm_i,
  vinfo_txsynced_i,
  
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
  
  HSYNC_o,
  VSYNC_o,
  DE_o,
  vdata_o
);


//`include "vh/n64adv_vparams.vh"
//`include "vh/videotimings.vh"
`include "../../vh/n64adv_vparams.vh"
`include "../../vh/videotimings.vh"


input VCLK_i;
input nRST_i;
input [1:0] vinfo_i;
input vdata_valid_i;
input [`VDATA_O_FU_SLICE] vdata_i;
input [11:0] vdata_hvshift;
input scaler_nresync_i;

input VCLK_o;
input nRST_o;
input [`VID_CFG_W-1:0] video_config_i;
input video_llm_i;
input [1:0] vinfo_txsynced_i;

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

output reg HSYNC_o = 1'b0;
output reg VSYNC_o = 1'b0;
output reg DE_o = 1'b0;
output reg [`VDATA_O_CO_SLICE] vdata_o = {(3*color_width_o){1'b0}};


// parameter
localparam hcnt_width = $clog2(`PIXEL_PER_LINE_MAX);
//localparam vcnt_width = $clog2(2*`TOTAL_LINES_PAL_LX1); // consider interlaced content
localparam vcnt_width = $clog2(`TOTAL_LINES_PAL_LX1); // should be 9
localparam hpos_width = $clog2(`ACTIVE_PIXEL_PER_LINE);

localparam low_latency_pre_lines = 24;
localparam free_running_pre_lines = `ACTIVE_LINES_PAL_LX1/2;

localparam ST_SDRAM_WAIT      = 3'b000; // wait for new line to begin (FIFO is already flushed)
localparam ST_SDRAM_FIFO2RAM0 = 3'b010; // prepare first FIFO element into SDRAM
localparam ST_SDRAM_FIFO2RAM1 = 3'b011; // write frist FIFO element into SDRAM
localparam ST_SDRAM_FIFO2RAM2 = 3'b100; // write concurrent FIFO elements into SDRAM
localparam ST_SDRAM_RAM2BUF0  = 3'b101; // prepare sdram data to buffer
localparam ST_SDRAM_RAM2BUF1  = 3'b110; // write sdram data to buffer

// misc
wire hshift_direction = vdata_hvshift[11];
wire [ 4:0] hshift    = vdata_hvshift[11] ? vdata_hvshift[10: 6] : ~vdata_hvshift[10: 6] + 1'b1;
wire vshift_direction = vdata_hvshift[ 5];
wire [ 4:0] vshift    = vdata_hvshift[ 5] ? vdata_hvshift[ 4: 0] : ~vdata_hvshift[ 4: 0] + 1'b1;
wire palmode = vinfo_i[1];
wire interlaced = vinfo_i[0];

wire palmode_resynced = vinfo_txsynced_i[1];
wire interlaced_resynced = vinfo_txsynced_i[0];


// wires
wire nHS_i, nVS_i;
wire negedge_nHSYNC, negedge_nVSYNC;

wire vdata_i_vactive_w, vdata_i_hactive_w;

wire sdram_llm_resynced;
wire wrpage_sdrambuf_resynced;
wire [`VDATA_O_CO_SLICE] sdrambuf_data_o;
wire [vcnt_width+2:0] sdrambuf_pageinfo_resynced;

wire sdram_cmd_ack_o, sdram_data_ack_o, sdram_ctrl_rdy_o, sdram_ctrl_rdy_resynced;
wire [7:0] sdram_data_dummy_o;
wire [`VDATA_O_CO_SLICE] sdram_data_o;



wire rdpage_slbuf_resynced;
wire [11:0] vcnt_o_resynced;

wire trigger_resynced;

wire [`VDATA_O_CO_SLICE] rd_vdata_slbuf;

wire [11:0] X_HSTART, X_HSTOP, X_VSTART, X_VSTOP;
wire [11:0] X_HSTART_px, X_HSTOP_px, X_VSTART_px, X_VSTOP_px;


// regs
reg [`VDATA_O_CO_SLICE] vdata_i_L = {(3*color_width_o){1'b0}};
reg nHS_i_L = 1'b0;
reg nVS_i_L = 1'b0;

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

reg trigger_out;


reg wren_sdrambuf = 1'b0;
reg wrpage_sdrambuf = 1'b0;
reg [hpos_width-1:0] wraddr_sdrambuf = {hpos_width{1'b0}};
reg [`VDATA_O_CO_SLICE] sdrambuf_data_i_LL; // data for sdram buffer
reg [vcnt_width+2:0] sdrambuf_pageinfo [0:1];
initial begin
  sdrambuf_pageinfo[0] = {(vcnt_width+3){1'b0}};
  sdrambuf_pageinfo[1] = {(vcnt_width+3){1'b0}};
end

reg rden_sdrambuf = 1'b0;
reg rdpage_sdrambuf = 1'b0;
reg [hpos_width-1:0] rdaddr_sdrambuf = {hpos_width{1'b0}};


reg [2:0] sdram_ctrl_state  = ST_SDRAM_WAIT; // state machine

reg sdram_req_i = 1'b0;
reg sdram_wr_en_i = 1'b0;
reg [22:0] sdram_addr_i = {23{1'b0}}; // (13bits row),(2bits bank),(8bits dblcolumn)
reg [`VDATA_O_CO_SLICE] sdram_data_i = {(3*color_width_o){1'b0}};

reg [1:0] frame_cnt_o;
    
reg [1:0] sdram_rd_bank_sel;
reg [vcnt_width-1:0] sdram_rd_vcnt;
reg [hpos_width-1:0] sdram_rd_hcnt;

reg wren_slbuf, wrpage_slbuf, rden_slbuf, rdpage_slbuf;
reg [hpos_width-1:0] wraddr_slbuf, rdaddr_slbuf;
reg [`VDATA_O_CO_SLICE] wr_vdata_slbuf;


reg [1:0] vinfo_txsynced_L;
reg [`VID_CFG_W-1:0] video_config_L = `USE_480p60;
reg [`VID_CFG_W-1:0] video_config_LL = `USE_480p60;

reg X_HSYNC_active = `HSYNC_active_480p60;
reg [11:0] X_HFRONTPORCH = `HFRONTPORCH_480p60;
reg [11:0] X_HSYNCLEN = `HSYNCLEN_480p60;
reg [11:0] X_HBACKPORCH = `HBACKPORCH_480p60;
reg [11:0] X_HACTIVE = `HACTIVE_480p60;
reg [11:0] X_HTOTAL = `HTOTAL_480p60;
reg X_VSYNC_active = `VSYNC_active_480p60;
reg [11:0] X_VFRONTPORCH = `VFRONTPORCH_480p60;
reg [11:0] X_VSYNCLEN = `VSYNCLEN_480p60;
reg [11:0] X_VBACKPORCH = `VBACKPORCH_480p60;
reg [11:0] X_VACTIVE = `VACTIVE_480p60;
reg [11:0] X_VTOTAL = `VTOTAL_480p60;

reg [2:0] X_pix_hrep_m1, X_pix_vrep_m1;
reg [11:0] X_hpos_offset, X_vpos_offset, X_vpos_1st_rdline;

reg [11:0] hcnt_o_L, vcnt_o_L;

reg [2:0] pix_hrep_cnt, pix_vrep_cnt;
reg DE_virt_LLLL, DE_virt_LLL;

reg HSYNC_o_LLLL, HSYNC_o_LLL, HSYNC_o_LL;
reg VSYNC_o_LLLL, VSYNC_o_LLL, VSYNC_o_LL;
reg DE_o_LLLL, DE_o_LLL, DE_o_LL;


// modules


// use a bram buffer for two lines 'in front of' the SRAM
ram2port #(
  .input_regs("OFF"),
  .num_of_pages(2),
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


//sdram #(
sdram_ctrl #(
  .SDRAM_MHZ(120),
  .INPUT_SHIFT_WINDOW(0)
) sdram_u
(
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


// use a bram buffer for two lines 'behind' the SRAM
ram2port #(
  .num_of_pages(2),
  .pagesize(`BUF_DEPTH_PER_PAGE),
  .data_width(3*color_width_o)
) scanlinebuffer_u(
  .wrCLK(DRAM_CLK_i),
  .wren(wren_slbuf),
  .wrpage(wrpage_slbuf),
  .wraddr(wraddr_slbuf),
  .wrdata(wr_vdata_slbuf),
  .rdCLK(VCLK_o),
  .rden(rden_slbuf & (pix_hrep_cnt == 3'b000)),
  .rdpage(rdpage_slbuf),
  .rdaddr(rdaddr_slbuf),
  .rddata(rd_vdata_slbuf)
);



// logic

register_sync #(
  .reg_width(1),
  .reg_preset(1'b0)
) register_sync4input_u (
  .clk(VCLK_i),
  .clk_en(1'b1),
  .nrst(1'b1),
  .reg_i(sdram_ctrl_rdy_o),
  .reg_o(sdram_ctrl_rdy_resynced)
);

assign nHS_i = vdata_i[3*color_width_o+1];
assign nVS_i = vdata_i[3*color_width_o+3];
assign negedge_nHSYNC =  nHS_i_L & !nHS_i;
assign negedge_nVSYNC =  nVS_i_L & !nVS_i;


always @(posedge VCLK_i or negedge nRST_i)
  if (!nRST_i) begin
    nHS_i_L <= 1'b0;
    nVS_i_L <= 1'b0;
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
    vdata_i_L <= {(3*color_width_o){1'b0}};
    trigger_out <= 1'b0;
  end else begin
    if (vdata_valid_i) begin
      nHS_i_L <= nHS_i;
      nVS_i_L <= nVS_i;
      vdata_i_L <= vdata_i[`VDATA_O_CO_SLICE];
      
      if (negedge_nHSYNC) begin
        hcnt_i_L <= 10'd0;
//        vcnt_i_L <= vcnt_i_L + 2'b10;
        vcnt_i_L <= vcnt_i_L + 1'b1;
        if (video_llm_i) begin
          if ((vcnt_i_L == low_latency_pre_lines) & sdram_ctrl_rdy_resynced)
            trigger_out <= 1'b1;
        end else begin
          if ((vcnt_i_L == free_running_pre_lines) & sdram_ctrl_rdy_resynced)
            trigger_out <= 1'b1;
        end
      end else begin
        hcnt_i_L <= hcnt_i_L + 1'b1;
      end

      if (negedge_nVSYNC) begin
        // set new info
        if (palmode) begin
          hstart_i <= hshift_direction ? `HSTART_PAL + hshift : `HSTART_PAL - hshift;
          hstop_i  <= hshift_direction ? `HSTOP_PAL  + hshift : `HSTOP_PAL  - hshift;
          vstart_i <= vshift_direction ? `VSTART_PAL_LX1 + vshift : `VSTART_PAL_LX1 - vshift;
          vstop_i  <= vshift_direction ? `VSTOP_PAL_LX1  + vshift : `VSTOP_PAL_LX1  - vshift;
        end else begin
          hstart_i <= hshift_direction ? `HSTART_NTSC + hshift : `HSTART_NTSC - hshift;
          hstop_i  <= hshift_direction ? `HSTOP_NTSC  + hshift : `HSTOP_NTSC  - hshift;
          vstart_i <= vshift_direction ? `VSTART_NTSC_LX1 + vshift : `VSTART_NTSC_LX1 - vshift;
          vstop_i  <= vshift_direction ? `VSTOP_NTSC_LX1  + vshift : `VSTOP_NTSC_LX1  - vshift;
        end
      
        FrameID_i <= negedge_nHSYNC; // negedge at nHSYNC, too -> odd frame
        vcnt_i_L <= {vcnt_width{1'b0}};
//        if (negedge_nHSYNC)
          frame_cnt_i <= frame_cnt_i + 1'b1;
      end
    end
    if (!scaler_nresync_i || !sdram_ctrl_rdy_resynced)
      trigger_out <= 1'b0;
  end


assign vdata_i_vactive_w = (vcnt_i_L >= vstart_i && vcnt_i_L < vstop_i);
assign vdata_i_hactive_w = (hcnt_i_L >= hstart_i && hcnt_i_L < hstop_i);

always @(posedge VCLK_i or negedge nRST_i)
  if (!nRST_i) begin
    wren_sdrambuf <= 1'b0;
    wrpage_sdrambuf <= 1'b0;
    wraddr_sdrambuf <= {hpos_width{1'b0}};
    sdrambuf_data_i_LL <= {(3*color_width_o){1'b0}};
    sdrambuf_pageinfo[0] <= {(vcnt_width+3){1'b0}};
    sdrambuf_pageinfo[1] <= {(vcnt_width+3){1'b0}};
  end else begin
    if (vdata_valid_i) begin
      if (vdata_i_vactive_w && vdata_i_hactive_w) begin
        sdrambuf_data_i_LL <= vdata_i_L;
        wren_sdrambuf <= 1'b1;
        wraddr_sdrambuf <= (hcnt_i_L == hstart_i) ? {hpos_width{1'b0}} : wraddr_sdrambuf + 1'b1;
      end else if (hcnt_i_L == hstop_i && vdata_i_vactive_w) begin // write page info and change page
        sdrambuf_pageinfo[wrpage_sdrambuf] <= {frame_cnt_i,FrameID_i,vcnt_i_L-vstart_i};
        wrpage_sdrambuf <= ~wrpage_sdrambuf;
      end
    end else begin
      wren_sdrambuf <= 1'b0;
    end
  end

register_sync #(
  .reg_width(vcnt_width+18),
  .reg_preset({(vcnt_width+18){1'b0}})
) register_sync4dram_u (
  .clk(DRAM_CLK_i),
  .clk_en(1'b1),
  .nrst(1'b1),
  .reg_i({video_llm_i,sdrambuf_pageinfo[~wrpage_sdrambuf],wrpage_sdrambuf,rdpage_slbuf,vcnt_o_L}),
  .reg_o({sdram_llm_resynced,sdrambuf_pageinfo_resynced,wrpage_sdrambuf_resynced,rdpage_slbuf_resynced,vcnt_o_resynced})
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

always @(posedge DRAM_CLK_i or negedge DRAM_nRST_i)
  if (!DRAM_nRST_i) begin
    rden_sdrambuf <= 1'b0;
    rdpage_sdrambuf <= 1'b0;
    rdaddr_sdrambuf <= {hpos_width{1'b0}};
  
    sdram_ctrl_state <= ST_SDRAM_WAIT;
    sdram_req_i <= 1'b0;
    sdram_wr_en_i <= 1'b0;
    sdram_data_i <= {(3*color_width_o){1'b0}};
    
    frame_cnt_o <= 2'b00;
    sdram_rd_bank_sel <= 2'b00;
    sdram_rd_vcnt <= {vcnt_width{1'b0}};
    sdram_rd_hcnt <= {hpos_width{1'b0}};
    
    
    wren_slbuf <= 1'b0;
    wraddr_slbuf <= {hpos_width{1'b0}};
    wrpage_slbuf <= 1'b0;
    wr_vdata_slbuf <= {(3*color_width_o){1'b0}}; // ggf. als wire direkt an Ausgangs-Buffer
  end else begin
    case (sdram_ctrl_state)
      ST_SDRAM_WAIT: begin
          if (rdpage_sdrambuf != wrpage_sdrambuf_resynced) begin
            // - Buffer hat umgeschaltet -> Elemente im SDRAM sichern
            sdram_addr_i[22:21] <= sdrambuf_pageinfo_resynced[vcnt_width+2:vcnt_width+1]; // bank for frame
            sdram_addr_i[20:19] <= 2'b00;                                                 // unused
            sdram_addr_i[18:10] <= sdrambuf_pageinfo_resynced[vcnt_width-1:0];            // vertical position
            sdram_addr_i[ 9: 0] <= {hpos_width{1'b0}};                                    // horizontal position
            if (sdram_llm_resynced) begin
              frame_cnt_o <= sdrambuf_pageinfo_resynced[vcnt_width+2:vcnt_width+1];       // set output frame to current frame in low latency mode
            end else begin
              if (sdrambuf_pageinfo_resynced[vcnt_width-1:0] > `ACTIVE_LINES_NTSC_LX1/2)  // current input frame is fairly ahead for free running mode, ...
                frame_cnt_o <= sdrambuf_pageinfo_resynced[vcnt_width+2:vcnt_width+1];     // ... so set output frame to current frame 
            end
            rden_sdrambuf <= 1'b1;
            rdaddr_sdrambuf <= {hpos_width{1'b0}};
            sdram_ctrl_state <= ST_SDRAM_FIFO2RAM0;
          end else if (vcnt_o_resynced == X_VSTART_px - 2) begin // fetch first line
            sdram_rd_bank_sel <= frame_cnt_o;
            sdram_rd_vcnt <= X_vpos_1st_rdline;
            sdram_rd_hcnt <= {hpos_width{1'b0}};
            wrpage_slbuf <= 1'b0;
            wraddr_slbuf <= {hpos_width{1'b1}};
            sdram_ctrl_state <= ST_SDRAM_RAM2BUF0;
          end else if (vcnt_o_resynced > X_VSTART_px - 1 &&
                       wrpage_slbuf == rdpage_slbuf_resynced) begin // fetch concurrent lines on demand
            sdram_rd_vcnt <= sdram_rd_vcnt + 1'b1;
            sdram_rd_hcnt <= {hpos_width{1'b0}};
            wrpage_slbuf <= ~wrpage_slbuf;
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
              rdpage_sdrambuf <= ~rdpage_sdrambuf;
            end
          end else
            rden_sdrambuf <= 1'b0;
            
//          if (rdaddr_sdrambuf == `ACTIVE_PIXEL_PER_LINE && sdram_data_ack_o) begin
//            sdram_req_i <= 1'b0;
//            sdram_wr_en_i <= 1'b0;
//            rden_sdrambuf <= 1'b0;
//            rdpage_sdrambuf <= ~rdpage_sdrambuf;
//            sdram_ctrl_state <= ST_SDRAM_WAIT;
//          end
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





register_sync #(
  .reg_width(1),
  .reg_preset(1'b0)
) register_sync4hdmi_u (
  .clk(VCLK_o),
  .clk_en(1'b1),
  .nrst(1'b1),
  .reg_i({trigger_out}),
  .reg_o({trigger_resynced})
);


// ToDo: consider
//   - Full screen in 1080p
//   - 4:3 windowing for 16:9 formats
//   - Force 50Hz / 60Hz hack

always @(posedge VCLK_o) begin
  if (vcnt_o_L == 0 && ((video_config_LL != video_config_L) || (vinfo_txsynced_L != vinfo_txsynced_i))) begin
    case (video_config_L)
      `USE_VGAp60: begin  // VGA (640x480), 4:3
        X_HSYNC_active <= `HSYNC_active_VGA;
        X_HFRONTPORCH <= `HFRONTPORCH_VGA;
        X_HSYNCLEN <= `HSYNCLEN_VGA;
        X_HBACKPORCH <= `HBACKPORCH_VGA;
        X_HACTIVE <= `HACTIVE_VGA;
        X_HTOTAL <= `HTOTAL_VGA;
        X_VSYNC_active <= `VSYNC_active_VGA;
        X_VFRONTPORCH <= `VFRONTPORCH_VGA;
        X_VSYNCLEN <= `VSYNCLEN_VGA;
        X_VBACKPORCH <= `VBACKPORCH_VGA;
        X_VACTIVE <= `VACTIVE_VGA;
        X_VTOTAL <= `VTOTAL_VGA;
        X_pix_hrep_m1 <= 0;
//        X_pix_vrep_m1 <= interlaced_resynced ? 0 : 1;
        X_pix_vrep_m1 <= 1;
        X_hpos_offset <= 0;
        X_vpos_offset <= 0;
        X_vpos_1st_rdline <= 0;
      end
      `USE_720p60: begin  // 720p-60, 16:9
        X_HSYNC_active <= `HSYNC_active_720p60;
        X_HFRONTPORCH <= `HFRONTPORCH_720p60;
        X_HSYNCLEN <= `HSYNCLEN_720p60;
        X_HBACKPORCH <= `HBACKPORCH_720p60;
        X_HACTIVE <= `HACTIVE_720p60;
        X_HTOTAL <= `HTOTAL_720p60;
        X_VSYNC_active <= `VSYNC_active_720p60;
        X_VFRONTPORCH <= `VFRONTPORCH_720p60;
        X_VSYNCLEN <= `VSYNCLEN_720p60;
        X_VBACKPORCH <= `VBACKPORCH_720p60;
        X_VACTIVE <= `VACTIVE_720p60;
        X_VTOTAL <= `VTOTAL_720p60;
        X_pix_hrep_m1 <= 1;
//        X_pix_vrep_m1 <= interlaced_resynced ? 0 : 2;
        X_pix_vrep_m1 <= 2;
        X_hpos_offset <= 0;
        X_vpos_offset <= 0;
        X_vpos_1st_rdline <= 0;
      end
      `USE_1080p60: begin // 1080p-60, 16:9
        X_HSYNC_active <= `HSYNC_active_1080p60;
        X_HFRONTPORCH <= `HFRONTPORCH_1080p60;
        X_HSYNCLEN <= `HSYNCLEN_1080p60;
        X_HBACKPORCH <= `HBACKPORCH_1080p60;
        X_HACTIVE <= `HACTIVE_1080p60;
        X_HTOTAL <= `HTOTAL_1080p60;
        X_VSYNC_active <= `VSYNC_active_1080p60;
        X_VFRONTPORCH <= `VFRONTPORCH_1080p60;
        X_VSYNCLEN <= `VSYNCLEN_1080p60;
        X_VBACKPORCH <= `VBACKPORCH_1080p60;
        X_VACTIVE <= `VACTIVE_1080p60;
        X_VTOTAL <= `VTOTAL_1080p60;
        X_pix_hrep_m1 <= 2;
//        X_pix_vrep_m1 <= interlaced_resynced ? 1 : 3;
        X_pix_vrep_m1 <= 3;
        X_hpos_offset <= 0;
        X_vpos_offset <= 60;
        X_vpos_1st_rdline <= 0;
      end
      `USE_720p50: begin // 720p-50, 16:9
        X_HSYNC_active <= `HSYNC_active_720p50;
        X_HFRONTPORCH <= `HFRONTPORCH_720p50;
        X_HSYNCLEN <= `HSYNCLEN_720p50;
        X_HBACKPORCH <= `HBACKPORCH_720p50;
        X_HACTIVE <= `HACTIVE_720p50;
        X_HTOTAL <= `HTOTAL_720p50;
        X_VSYNC_active <= `VSYNC_active_720p50;
        X_VFRONTPORCH <= `VFRONTPORCH_720p50;
        X_VSYNCLEN <= `VSYNCLEN_720p50;
        X_VBACKPORCH <= `VBACKPORCH_720p50;
        X_VACTIVE <= `VACTIVE_720p50;
        X_VTOTAL <= `VTOTAL_720p50;
        X_pix_hrep_m1 <= 1;
//        X_pix_vrep_m1 <= interlaced_resynced ? 0 : 2;
        X_pix_vrep_m1 <= 2;
        X_hpos_offset <= 0;
        X_vpos_offset <= 0;
        X_vpos_1st_rdline <= 36;
      end
      `USE_1080p50: begin // 1080p-50, 16:9
        X_HSYNC_active <= `HSYNC_active_1080p50;
        X_HFRONTPORCH <= `HFRONTPORCH_1080p50;
        X_HSYNCLEN <= `HSYNCLEN_1080p50;
        X_HBACKPORCH <= `HBACKPORCH_1080p50;
        X_HACTIVE <= `HACTIVE_1080p50;
        X_HTOTAL <= `HTOTAL_1080p50;
        X_VSYNC_active <= `VSYNC_active_1080p50;
        X_VFRONTPORCH <= `VFRONTPORCH_1080p50;
        X_VSYNCLEN <= `VSYNCLEN_1080p50;
        X_VBACKPORCH <= `VBACKPORCH_1080p50;
        X_VACTIVE <= `VACTIVE_1080p50;
        X_VTOTAL <= `VTOTAL_1080p50;
        X_pix_hrep_m1 <= 2;
//        X_pix_vrep_m1 <= interlaced_resynced ? 1 : 3;
        X_pix_vrep_m1 <= 3;
        X_hpos_offset <= 0;
        X_vpos_offset <= 0;
        X_vpos_1st_rdline <= 12;
      end
      default: begin
        if (video_config_L[`VID_CFG_50HZ_BIT]) begin // 576p-50, 4:3 / 16:9
          X_HSYNC_active <= `HSYNC_active_576p50;
          X_HFRONTPORCH <= `HFRONTPORCH_576p50;
          X_HSYNCLEN <= `HSYNCLEN_576p50;
          X_HBACKPORCH <= `HBACKPORCH_576p50;
          X_HACTIVE <= `HACTIVE_576p50;
          X_HTOTAL <= `HTOTAL_576p50;
          X_VSYNC_active <= `VSYNC_active_576p50;
          X_VFRONTPORCH <= `VFRONTPORCH_576p50;
          X_VSYNCLEN <= `VSYNCLEN_576p50;
          X_VBACKPORCH <= `VBACKPORCH_576p50;
          X_VACTIVE <= `VACTIVE_576p50;
          X_VTOTAL <= `VTOTAL_576p50;
        end else begin // 480p-60, 4:3 / 16:9
          X_HSYNC_active <= `HSYNC_active_480p60;
          X_HFRONTPORCH <= `HFRONTPORCH_480p60;
          X_HSYNCLEN <= `HSYNCLEN_480p60;
          X_HBACKPORCH <= `HBACKPORCH_480p60;
          X_HACTIVE <= `HACTIVE_480p60;
          X_HTOTAL <= `HTOTAL_480p60;
          X_VSYNC_active <= `VSYNC_active_480p60;
          X_VFRONTPORCH <= `VFRONTPORCH_480p60;
          X_VSYNCLEN <= `VSYNCLEN_480p60;
          X_VBACKPORCH <= `VBACKPORCH_480p60;
          X_VACTIVE <= `VACTIVE_480p60;
          X_VTOTAL <= `VTOTAL_480p60;
        end
        X_pix_hrep_m1 <= 0;
//        X_pix_vrep_m1 <= interlaced_resynced ? 0 : 1;
        X_pix_vrep_m1 <= 1;
        X_hpos_offset <= 40;
        X_vpos_offset <= 0;
        X_vpos_1st_rdline <= 0;
      end
    endcase
    video_config_LL <= video_config_L;
  end
  video_config_L <= video_config_i;
  vinfo_txsynced_L <= vinfo_txsynced_i;
end

assign X_HSTART = X_HSYNCLEN + X_HBACKPORCH;
assign X_HSTOP = X_HSYNCLEN + X_HBACKPORCH + X_HACTIVE;
assign X_VSTART = X_VSYNCLEN + X_VBACKPORCH;
assign X_VSTOP = X_VSYNCLEN + X_VBACKPORCH + X_VACTIVE;

assign X_HSTART_px = X_HSYNCLEN + X_HBACKPORCH + X_hpos_offset;
assign X_HSTOP_px = X_HSYNCLEN + X_HBACKPORCH + X_HACTIVE - X_hpos_offset;
assign X_VSTART_px = X_VSYNCLEN + X_VBACKPORCH + X_vpos_offset;
assign X_VSTOP_px = X_VSYNCLEN + X_VBACKPORCH + X_VACTIVE - X_vpos_offset;


always @(posedge VCLK_o or negedge nRST_o)
  if (!nRST_o) begin
    hcnt_o_L <= 0;
    vcnt_o_L <= 0;
    
    rden_slbuf <= 1'b0;
    rdpage_slbuf <= 1'b0;
    rdaddr_slbuf <= {hpos_width{1'b0}};
    pix_hrep_cnt <= 3'b000;
    pix_vrep_cnt <= 3'b000;
    DE_virt_LLLL <= 1'b0;
    DE_virt_LLL <= 1'b0;

    HSYNC_o_LLLL <= 1'b0;
    HSYNC_o_LLL <= 1'b0;
    HSYNC_o_LL <= 1'b0;
    VSYNC_o_LLLL <= 1'b0;
    VSYNC_o_LLL <= 1'b0;
    VSYNC_o_LL <= 1'b0;
    DE_o_LLLL <= 1'b0;
    DE_o_LLL <= 1'b0;
    DE_o_LL <= 1'b0;
    HSYNC_o <= 1'b0;
    VSYNC_o <= 1'b0;
    DE_o <= 1'b0;
    vdata_o <= {(3*color_width_o){1'b0}};
  
  end else begin
    // generate sync
    if (trigger_resynced) begin
      if (hcnt_o_L < X_HTOTAL - 1) begin
        hcnt_o_L <= hcnt_o_L + 1;
      end else begin
        hcnt_o_L <= 0;
      end
      if (hcnt_o_L == X_HTOTAL-1) begin
        if (vcnt_o_L < X_VTOTAL - 1) begin
          vcnt_o_L <= vcnt_o_L + 1;
        end else begin
          vcnt_o_L <= 0;
        end
      end
    end else begin
      vcnt_o_L <= 0;
      hcnt_o_L <= 0;
    end
    
    if (vcnt_o_L >= X_VSTART_px && vcnt_o_L < X_VSTOP_px) begin
      if (hcnt_o_L == X_HSTART_px) begin
        rden_slbuf <= 1'b1;
        rdaddr_slbuf <= {hpos_width{1'b0}};
        pix_hrep_cnt <= 0;
      end else if (rden_slbuf && hcnt_o_L < X_HSTOP_px) begin
        if (pix_hrep_cnt == X_pix_hrep_m1) begin
          rdaddr_slbuf <= rdaddr_slbuf + 1;
          pix_hrep_cnt <= 0;
        end else begin
          pix_hrep_cnt <= pix_hrep_cnt + 1;
        end
      end else begin
        rden_slbuf <= 1'b0;
      end
      if (hcnt_o_L == X_HSTOP_px) begin
        if (pix_vrep_cnt == X_pix_vrep_m1) begin
          rdpage_slbuf <= ~rdpage_slbuf;
          pix_vrep_cnt <= 0;
        end else begin
          pix_vrep_cnt <= pix_vrep_cnt + 1;
        end
      end
    end else if (vcnt_o_L == 0) begin
      rdpage_slbuf <= 1'b0;
    end
    
    HSYNC_o_LLLL <= HSYNC_o_LLL;
    HSYNC_o_LLL <= HSYNC_o_LL;
    HSYNC_o_LL <= (hcnt_o_L < X_HSYNCLEN) ~^ X_HSYNC_active;
    VSYNC_o_LLLL <= VSYNC_o_LLL;
    VSYNC_o_LLL <= VSYNC_o_LL;
    VSYNC_o_LL <= (vcnt_o_L < X_VSYNCLEN) ~^ X_VSYNC_active;
    DE_o_LLLL <= DE_o_LLL;
    DE_o_LLL <= DE_o_LL;
    DE_o_LL <= (hcnt_o_L >= X_HSTART && hcnt_o_L < X_HSTOP && vcnt_o_L >= X_VSTART && vcnt_o_L < X_VSTOP);
    
    DE_virt_LLLL <= DE_virt_LLL; // rd_vdata_slbuf valid with DE_virt_LLLL active
    DE_virt_LLL <= rden_slbuf;
  
    // final outputs
    HSYNC_o <= HSYNC_o_LLLL;
    VSYNC_o <= VSYNC_o_LLLL;
    DE_o <= DE_o_LLLL;
    if (DE_virt_LLLL & DE_o_LLLL)
      vdata_o <= rd_vdata_slbuf;
    else
      vdata_o <= {(3*color_width_o){1'b0}};
  end

endmodule
