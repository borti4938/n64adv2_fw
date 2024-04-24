
`timescale 1ns / 1ps

module scanline_correction_concept_tb();

// generate a beautifull clock

reg mclk = 1'b0;

initial begin
  mclk <= 1'b0;
  forever #10 mclk <= ~mclk; // generates a 50MHz clock
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

// parameter cfg_interpolation_mode = 2'b00; // integer
parameter cfg_interpolation_mode = 2'b01; // bilinear
parameter cfg_SL_str = 8'd179;  // just a random number

parameter SL_thickness = 8'h40; // area in middle in which the SL is fully drawn
                                // must not exceed 8'h40!!!
parameter SL_softening = 8'h40; // area width at each border where the SL strength becomes reduced until reaching zero
                                // must be 8'h40, 8'h20, 8'h10  or 8'h08
                                //         0.25,  0.125, 0.0625 or 0.03125

// simulation - testing different scale_vpos_rel_w values 
reg [7:0] scale_vpos_rel_L;

always @(posedge mclk or negedge nrst)
  if (!nrst) begin
    scale_vpos_rel_L <= 0;
  end else begin
    scale_vpos_rel_L <= scale_vpos_rel_L + 1;
  end

wire [7:0] sl_vpos_rel_w;

// Scanline emulation
// ==================
/*

assign sl_vpos_rel_w = scale_vpos_rel_L;

reg [2:0] cfg_drawSL;
reg [7:0] Y_SL_str_vcorrection_L;
reg [8:0] Y_SL_str_vcorrection_LL;
reg [10:0] Y_SL_str_vcorrection_LLL;
reg [7:0] cfg_SL_str_corrected;

wire [15:0] Y_cfg_SL_str_corrected_full_w = Y_SL_str_vcorrection_LLL[8:0] * cfg_SL_str;

always @(posedge mclk) begin
  if (|cfg_interpolation_mode) begin  // non-integer interpolation
    Y_SL_str_vcorrection_L <= sl_vpos_rel_w > 8'h80 ? sl_vpos_rel_w - 8'h80 : 8'h80 - sl_vpos_rel_w;
  end else begin  // integer interpolation
    Y_SL_str_vcorrection_L <= sl_vpos_rel_w > 8'hC0 ? ~sl_vpos_rel_w + 1'b1 : sl_vpos_rel_w;
  end
  Y_SL_str_vcorrection_LL <= Y_SL_str_vcorrection_L > 8'h40 ? 8'h00 : {1'b0,~Y_SL_str_vcorrection_L} + 1'b1;
  cfg_drawSL <= {3{Y_SL_str_vcorrection_L <= 8'h40}};
  
  Y_SL_str_vcorrection_LLL <= {Y_SL_str_vcorrection_LL,2'b00} - 11'h300;
  
  cfg_SL_str_corrected <= Y_cfg_SL_str_corrected_full_w[15:8];
end
*/

assign sl_vpos_rel_w = ~|cfg_interpolation_mode ? scale_vpos_rel_L + 8'h80 : scale_vpos_rel_L; // correct position for integer scaling such that the scanline gen is at transition between two pixels

reg cfg_drawSL;
reg [7:0] Y_SL_str_vcorrection_L;
reg [7:0] Y_SL_str_vcorrection_LL;
reg [12:0] Y_SL_str_vcorrection_LLL;
reg [7:0] cfg_SL_str_corrected;

wire [15:0] Y_cfg_SL_str_corrected_full_w = Y_SL_str_vcorrection_LLL[8:0] * cfg_SL_str;

always @(posedge mclk) begin
  Y_SL_str_vcorrection_L <= sl_vpos_rel_w > 8'h80 ? sl_vpos_rel_w - 8'h80 : 8'h80 - sl_vpos_rel_w;    // check how far we are from the scanline middle
  Y_SL_str_vcorrection_LL <= Y_SL_str_vcorrection_L > SL_softening + SL_thickness/2 ? 8'h00 : 
                             Y_SL_str_vcorrection_L <                SL_thickness/2 ? 8'h00 : ~(Y_SL_str_vcorrection_L - SL_thickness/2) + 1'b1; // apply correction if we are in the softening area
  cfg_drawSL <= Y_SL_str_vcorrection_L <= SL_softening + SL_thickness/2;
  
  case (SL_softening)
    8'h40:   Y_SL_str_vcorrection_LLL <= {3'b000,Y_SL_str_vcorrection_LL,2'b00} - 13'h0300; // x4 - 3
    8'h20:   Y_SL_str_vcorrection_LLL <= {2'b00 ,Y_SL_str_vcorrection_LL,3'b00} - 13'h0700; // x8 - 7
    8'h10:   Y_SL_str_vcorrection_LLL <= {1'b0  ,Y_SL_str_vcorrection_LL,4'b00} - 13'h0F00; // x16 - 15
    // 8'h08:   Y_SL_str_vcorrection_LLL <= {       Y_SL_str_vcorrection_LL,5'b00} - 13'h1F00; // x32 - 31
    default: Y_SL_str_vcorrection_LLL <= {       Y_SL_str_vcorrection_LL,5'b00} - 13'h1F00; // x32 - 31
  endcase
  
  
  cfg_SL_str_corrected <= Y_cfg_SL_str_corrected_full_w[15:8];
end

wire sl_thickness_i = SL_thickness == 8'h40 ? 0 : 1;
localparam proc_stages = 9;
integer int_idx;

reg [proc_stages-2:1] Y_drawSL;
reg [2:1] Y_max_SL_str;
reg [7:0] Y_SL_str_correction_factor_0L;
reg [5:0] Y_SL_str_correction_factor_1L;
reg [7:0] Y_SL_str_correction_factor_2L, Y_SL_str_corrected_3L, Y_SL_str_corrected_4L;

wire [7:0] SL_str_correction_factor_1L_w = sl_thickness_i ? Y_SL_str_correction_factor_0L - 8'b01000000 : Y_SL_str_correction_factor_0L - 8'b00100000; // subtract with 0.25 for thin or 0.125 for normal sl thickness
wire [15:0] SL_str_corrected_3L_full_w = Y_SL_str_correction_factor_2L * cfg_SL_str;

always @(posedge mclk) begin
  for (int_idx = 3; int_idx < proc_stages-1; int_idx = int_idx + 1)
    Y_drawSL[int_idx] <= Y_drawSL[int_idx-1];
  Y_drawSL[2] <= Y_drawSL[1];
//  Y_drawSL[1] <= sl_thickness_i ? |Y_SL_str_correction_factor_0L[7:6] : |Y_SL_str_correction_factor_0L[7:5];  // for thin sl, draw if value is over 0.25; for normal sl, over 0.125
  Y_drawSL[1] <= sl_thickness_i ? Y_SL_str_correction_factor_0L > 8'b01000000 : Y_SL_str_correction_factor_0L > 8'b00100000;  // for thin sl, draw if value is over 0.25; for normal sl, over 0.125
   
  Y_max_SL_str[2] <= Y_max_SL_str[1];
//  Y_max_SL_str[1] <= sl_thickness_i ? Y_SL_str_correction_factor_0L >= 8'b10000000 : Y_SL_str_correction_factor_0L >= 8'b01100000; // for thin sl, maxed out at 0.5; for normal sl, maxed out at 0.375
  Y_max_SL_str[1] <= sl_thickness_i ? Y_SL_str_correction_factor_0L[7] : Y_SL_str_correction_factor_0L[7:5] >= 3'b011; // for thin sl, maxed out at 0.5; for normal sl, maxed out at 0.375
  
  Y_SL_str_correction_factor_0L <= scale_vpos_rel_L > 8'h80 ? ~scale_vpos_rel_L + 1'b1 : scale_vpos_rel_L; //  map everything between 0 and 0.5 (from 8'h00 to 8'h80)
  Y_SL_str_correction_factor_1L <= SL_str_correction_factor_1L_w[5:0];                  // 6bits are fine here
  Y_SL_str_correction_factor_2L <= {Y_SL_str_correction_factor_1L,2'b00};               // insert profile here
  
  Y_SL_str_corrected_3L <= Y_max_SL_str[2] ? cfg_SL_str : SL_str_corrected_3L_full_w[15:8];
  Y_SL_str_corrected_4L <= Y_SL_str_corrected_3L;
end


endmodule
