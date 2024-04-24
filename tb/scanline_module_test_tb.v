
`timescale 1ns / 1ps

module scanline_module_test_tb();

// generate a beautifull clock

reg mclk = 1'b0;

initial begin
  mclk <= 1'b0;
  forever #10 mclk <= ~mclk; // generates a 50MHz clock
end

reg mclk_4 = 1'b0;

initial begin
  mclk_4 <= 1'b0;
  forever #40 mclk_4 <= ~mclk_4;  // generates a 12.5MHz clock
end  


// generate reset

reg nrst;

initial begin
  nrst <= 1'b1;
  #1
  nrst <= 1'b0;
  #100
  nrst <= 1'b1;
end

// setup parameter for the scanline module

localparam cfg_sl_en = 1'b1;  // obvious
localparam cfg_sl_per_channel = 1'b1;  // does not really matter for testing
localparam [1:0] cfg_sl_thickness = 2'b00;  // 00 = adaptive, 01 = thin, 10 = normal, 11 = thick
localparam [1:0] cfg_profile  = 2'b11;  // 00 = hanning, 01 = gaussian, 10 = rectangular, 11 = flat top
localparam [3:0] cfg_sl_strength_raw = 4'b1100; // raw value representing 6.25% to 100% in 6.25% steps
localparam [7:0] cfg_sl_strength = ((cfg_sl_strength_raw+8'h01)<<4)-1'b1;
localparam [4:0] cfg_sl_bloom = 5'b01010; // a 5 bit value for bloom factor from 0% to 150% in 6.25% steps, i.e. 11001 is max.

localparam [7:0] vdata_steps = 8'h02;
localparam [7:0] pos_steps = 8'h10;

// produce some data

reg [7:0] vdata_L_i;
reg [7:0] sl_rel_pos_i;

always @(posedge mclk_4 or negedge nrst) // use mclk_4 to update values just every fourth edge of nclk
  if(nrst == 1'b0) begin
    vdata_L_i <= 8'h0;
    sl_rel_pos_i <= ~pos_steps + 1'b1;
  end else begin
    if (sl_rel_pos_i < pos_steps) vdata_L_i <= vdata_L_i + vdata_steps;
    sl_rel_pos_i <= sl_rel_pos_i + pos_steps;
  end

// output wires

wire HSYNC_w, VSYNC_w, DE_w;
wire [23:0] vdata_w;

// Scanline emulation
// ==================

scanline_emu vertical_scanline_emu_u (
  .VCLK_i(mclk),
  .nVRST_i(nrst),
  .HSYNC_i(1'b1),
  .VSYNC_i(1'b1),
  .DE_i(1'b1),
  .vdata_i({3{vdata_L_i}}),
  .sl_en_i(cfg_sl_en),
  .sl_per_channel_i(cfg_sl_per_channel),
  .sl_thickness_i(cfg_sl_thickness),
  .sl_profile_i(cfg_profile),
  .sl_rel_pos_i(sl_rel_pos_i),
  .sl_strength_i(cfg_sl_strength),
  .sl_bloom_i(cfg_sl_bloom),
  .HSYNC_o(HSYNC_w),
  .VSYNC_o(VSYNC_w),
  .DE_o(DE_w),
  .vdata_o(vdata_w)
);


endmodule
