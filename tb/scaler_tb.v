
`timescale 1ns / 1ps

module scaler_tb();


// N64
// ---------------

`include "../vh/n64adv_vparams.vh"

// generate a beautifull clock

reg n64_vclk;

initial begin
  n64_vclk <= 1'b0;
  forever #10 n64_vclk <= ~n64_vclk; // generates a 50MHz clock
end

// generate reset

reg nrst;

initial begin
  nrst <= 1'b0;
  #100
  nrst <= 1'b1;
end

// generate video data

reg [1:0] subpixel;
reg [31:0] hcnt, vcnt;
reg hsync;
reg vsync;
reg [`VDATA_O_CO_SLICE] vdata_n64;
reg [`VDATA_O_CO_SLICE] vdata_n64_data;
reg vdata_valid;


always @(posedge n64_vclk or negedge nrst)
  if (!nrst) begin
    subpixel <= 0;
    hcnt <= 0;
    vcnt <= 0;
    hsync <= 0;
    vsync <= 0;
    vdata_n64 <= 0;
    vdata_n64_data <= 0;
    vdata_valid <= 0;
  end else begin
    case (subpixel)
      0: begin
        if (hcnt < `PIXEL_PER_LINE_NTSC_normal1)
          hcnt <= hcnt + 1;
        else begin
          hcnt <= 0;
          if (vcnt < `TOTAL_LINES_NTSC_LX1)
            vcnt <= vcnt + 1;
          else
            vcnt <= 0;
        end
      end
      1: begin
        hsync <= ~(hcnt < 30);
        vsync <= ~(vcnt < 5);
        if (hcnt >= `HSTART_NTSC && hcnt < `HSTOP_NTSC && vcnt >= `VSTART_NTSC_LX1 && vcnt < `VSTOP_NTSC_LX1) begin
          vdata_n64 <= {vdata_n64_data,hcnt[9:0],vcnt[8:0]};
          vdata_n64_data <= vdata_n64_data + 1;
        end else
          vdata_n64 <= 0;
        vdata_valid <= 1;
      end
      2: begin
        vdata_valid <= 0;
      end
    endcase
    subpixel <= subpixel + 1;
  end

wire [`VDATA_O_FU_SLICE] vdata_full = {vsync,1'b0, hsync,1'b0,vdata_n64};
  
// video 

`define half_period_480p  #9.26
`define half_period_720p  #6.73
`define half_period_1080p #3.37

localparam [3:0] video_mode_vga_p = 4'b0000; // VGA
localparam [3:0] video_mode_480_p = 4'b0001; // 480p60
localparam [3:0] video_mode_720_p = 4'b0010; // 720p60
localparam [3:0] video_mode_1080_p = 4'b0011; // 1080p60

reg hdmi_clk_480p;
initial begin
  hdmi_clk_480p <= 1'b0;
  forever `half_period_480p hdmi_clk_480p <= ~hdmi_clk_480p;
end

reg hdmi_clk_720p;
initial begin
  hdmi_clk_720p <= 1'b0;
  forever `half_period_720p hdmi_clk_720p <= ~hdmi_clk_720p;
end

reg hdmi_clk_1080p;
initial begin
  hdmi_clk_1080p <= 1'b0;
  forever `half_period_1080p hdmi_clk_1080p <= ~hdmi_clk_1080p;
end

reg [3:0] video_mode;
initial begin
  video_mode <= video_mode_480_p;
  #100
  video_mode <= video_mode_720_p;
end

wire hdmi_clk = video_mode == video_mode_vga_p  ? hdmi_clk_480p :
                video_mode == video_mode_480_p  ? hdmi_clk_480p :
                video_mode == video_mode_720_p  ? hdmi_clk_720p :
                video_mode == video_mode_1080_p ? hdmi_clk_1080p :
                                                  hdmi_clk_480p;

// memory

reg dram_clk_i;
initial begin
  dram_clk_i <= 1'b0;
//  #1.563 // -135deg phase shift
  #4.688 // -45deg phase shift
  dram_clk_i <= 1'b1;
//  forever #5.00 dram_clk_i <= ~dram_clk_i; // 100MHz
  forever #6.25 dram_clk_i <= ~dram_clk_i;  // 80MHz
//  forever #10.00 dram_clk_i <= ~dram_clk_i;  // 50MHz
end

reg scaler_dram_clk_i;
initial begin
  scaler_dram_clk_i <= 1'b0;
//  forever #5.00 scaler_dram_clk_i <= ~scaler_dram_clk_i; // 100MHz
  forever #6.25 scaler_dram_clk_i <= ~scaler_dram_clk_i;  // 80MHz
//  forever #10.00 scaler_dram_clk_i <= ~scaler_dram_clk_i;  // 50MHz
end

// todo: include board dealys

wire [12:0] DRAM_ADDR;
wire [ 1:0] DRAM_BA;
wire        DRAM_nCAS;
wire        DRAM_CKE;
//wire        DRAM_CLK;
wire        DRAM_nCS;
wire  [15:0] DRAM_DQ;
wire [ 1:0] DRAM_DQM;
wire        DRAM_nRAS;
wire        DRAM_nWE;

mt48lc16m16a2 sdram_u(
  .Dq(DRAM_DQ),
  .Addr(DRAM_ADDR),
  .Ba(DRAM_BA),
//  .Clk(DRAM_CLK),
  .Clk(dram_clk_i),
  .Cke(DRAM_CKE),
  .Cs_n(DRAM_nCS),
  .Ras_n(DRAM_nRAS),
  .Cas_n(DRAM_nCAS),
  .We_n(DRAM_nWE),
  .Dqm(DRAM_DQM));


// dut

wire HSYNC_o, VSYNC_o, DE_o;
wire [`VDATA_O_CO_SLICE] vdata_o;

  
scaler scaler_dut_u(
  .VCLK_i(n64_vclk),
  .nRST_i(nrst),
  .vinfo_i(0),
  .vdata_i(vdata_full),
  .vdata_valid_i(vdata_valid),
  .vdata_hvshift(12'b100000100000),
  .scaler_nresync_i(1'b1),
  .VCLK_o(hdmi_clk),
  .nRST_o(nrst),
  .video_config_i(video_mode),
  .vinfo_txsynced_i(0),
  .DRAM_CLK_i(scaler_dram_clk_i),
  .DRAM_nRST_i(nrst),
  .DRAM_ADDR(DRAM_ADDR),
  .DRAM_BA(DRAM_BA),
  .DRAM_nCAS(DRAM_nCAS),
  .DRAM_CKE(DRAM_CKE),
//  .DRAM_CLK(DRAM_CLK),
  .DRAM_nCS(DRAM_nCS),
  .DRAM_DQ(DRAM_DQ),
  .DRAM_DQM(DRAM_DQM),
  .DRAM_nRAS(DRAM_nRAS),
  .DRAM_nWE(DRAM_nWE),
  .HSYNC_o(HSYNC_o),
  .VSYNC_o(VSYNC_o),
  .DE_o(DE_o),
  .vdata_o(vdata_o)
);

endmodule
