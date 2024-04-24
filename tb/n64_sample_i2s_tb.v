
module n64_sample_i2s_tb();

reg AMCLK_i, nARST, ASCLK_i, ASDATA_i, ALRCLK_i;
reg signed [15:0] PDATA_LEFT_i, PDATA_RIGHT_i;

initial begin
  AMCLK_i = 1'b0;
  nARST = 1'b0;
  ASCLK_i = 1'b0;
  ASDATA_i = 1'b0;
  ALRCLK_i = 1'b0;
  PDATA_LEFT_i = 16'd0;
  PDATA_RIGHT_i = 16'd0;
end


always begin
  #20 AMCLK_i = 1'b1;
  #20 AMCLK_i = 1'b0;
  nARST = 1'b1;
end



always begin
    ALRCLK_i = 1'b1;
    ASDATA_i = 1'b0;
  #6750;
    ASCLK_i = 1'b1;
  #250;
    ASCLK_i = 1'b0;
    ASDATA_i = PDATA_LEFT_i[15];
  #250;
    ASCLK_i = 1'b1;
  #250;
    ASCLK_i = 1'b0;
    ASDATA_i = PDATA_LEFT_i[14];
  #250;
    ASCLK_i = 1'b1;
  #250;
    ASCLK_i = 1'b0;
    ASDATA_i = PDATA_LEFT_i[13];
  #250;
    ASCLK_i = 1'b1;
  #250;
    ASCLK_i = 1'b0;
    ASDATA_i = PDATA_LEFT_i[12];
  #250;
    ASCLK_i = 1'b1;
  #250;
    ASCLK_i = 1'b0;
    ASDATA_i = PDATA_LEFT_i[11];
  #250;
    ASCLK_i = 1'b1;
  #250;
    ASCLK_i = 1'b0;
    ASDATA_i = PDATA_LEFT_i[10];
  #250;
    ASCLK_i = 1'b1;
  #250;
    ASCLK_i = 1'b0;
    ASDATA_i = PDATA_LEFT_i[9];
  #250;
    ASCLK_i = 1'b1;
  #250;
    ASCLK_i = 1'b0;
    ASDATA_i = PDATA_LEFT_i[8];
  #250;
    ASCLK_i = 1'b1;
  #250;
    ASCLK_i = 1'b0;
    ASDATA_i = PDATA_LEFT_i[7];
  #250;
    ASCLK_i = 1'b1;
  #250;
    ASCLK_i = 1'b0;
    ASDATA_i = PDATA_LEFT_i[6];
  #250;
    ASCLK_i = 1'b1;
  #250;
    ASCLK_i = 1'b0;
    ASDATA_i = PDATA_LEFT_i[5];
  #250;
    ASCLK_i = 1'b1;
  #250;
    ASCLK_i = 1'b0;
    ASDATA_i = PDATA_LEFT_i[4];
  #250;
    ASCLK_i = 1'b1;
  #250;
    ASCLK_i = 1'b0;
    ASDATA_i = PDATA_LEFT_i[3];
  #250;
    ASCLK_i = 1'b1;
  #250;
    ASCLK_i = 1'b0;
    ASDATA_i = PDATA_LEFT_i[2];
  #250;
    ASCLK_i = 1'b1;
  #250;
    ASCLK_i = 1'b0;
    ASDATA_i = PDATA_LEFT_i[1];
  #250;
    ASCLK_i = 1'b1;
  #250;
    ASCLK_i = 1'b0;
    ASDATA_i = PDATA_LEFT_i[0];
  #250;
    ASCLK_i = 1'b1;
  #250;
    ASCLK_i = 1'b0;
  #250;
    ASCLK_i = 1'b1;
  #250;
    ASCLK_i = 1'b0;
    ALRCLK_i = 1'b0;
    ASDATA_i = 1'b0;
  #6750;
    ASCLK_i = 1'b1;
  #250;
    ASCLK_i = 1'b0;
    ASDATA_i = PDATA_RIGHT_i[15];
  #250;
    ASCLK_i = 1'b1;
  #250;
    ASCLK_i = 1'b0;
    ASDATA_i = PDATA_RIGHT_i[14];
  #250;
    ASCLK_i = 1'b1;
  #250;
    ASCLK_i = 1'b0;
    ASDATA_i = PDATA_RIGHT_i[13];
  #250;
    ASCLK_i = 1'b1;
  #250;
    ASCLK_i = 1'b0;
    ASDATA_i = PDATA_RIGHT_i[12];
  #250;
    ASCLK_i = 1'b1;
  #250;
    ASCLK_i = 1'b0;
    ASDATA_i = PDATA_RIGHT_i[11];
  #250;
    ASCLK_i = 1'b1;
  #250;
    ASCLK_i = 1'b0;
    ASDATA_i = PDATA_RIGHT_i[10];
  #250;
    ASCLK_i = 1'b1;
  #250;
    ASCLK_i = 1'b0;
    ASDATA_i = PDATA_RIGHT_i[9];
  #250;
    ASCLK_i = 1'b1;
  #250;
    ASCLK_i = 1'b0;
    ASDATA_i = PDATA_RIGHT_i[8];
  #250;
    ASCLK_i = 1'b1;
  #250;
    ASCLK_i = 1'b0;
    ASDATA_i = PDATA_RIGHT_i[7];
  #250;
    ASCLK_i = 1'b1;
  #250;
    ASCLK_i = 1'b0;
    ASDATA_i = PDATA_RIGHT_i[6];
  #250;
    ASCLK_i = 1'b1;
  #250;
    ASCLK_i = 1'b0;
    ASDATA_i = PDATA_RIGHT_i[5];
  #250;
    ASCLK_i = 1'b1;
  #250;
    ASCLK_i = 1'b0;
    ASDATA_i = PDATA_RIGHT_i[4];
  #250;
    ASCLK_i = 1'b1;
  #250;
    ASCLK_i = 1'b0;
    ASDATA_i = PDATA_RIGHT_i[3];
  #250;
    ASCLK_i = 1'b1;
  #250;
    ASCLK_i = 1'b0;
    ASDATA_i = PDATA_RIGHT_i[2];
  #250;
    ASCLK_i = 1'b1;
  #250;
    ASCLK_i = 1'b0;
    ASDATA_i = PDATA_RIGHT_i[1];
  #250;
    ASCLK_i = 1'b1;
  #250;
    ASCLK_i = 1'b0;
    ASDATA_i = PDATA_RIGHT_i[0];
  #250;
    ASCLK_i = 1'b1;
  #250;
    ASCLK_i = 1'b0;
  #250;
    ASCLK_i = 1'b1;
  #250;
    ASCLK_i = 1'b0;
    PDATA_LEFT_i = PDATA_LEFT_i + 1;
    PDATA_RIGHT_i = PDATA_RIGHT_i - 1;
end


wire [15:0] APDATA_LEFT_o, APDATA_RIGHT_o;
wire APDATA_VALID_o;


n64_sample_i2s i2s_rx_dut(
  .AMCLK_i(AMCLK_i),
  .nARST(nARST),
  .ASCLK_i(ASCLK_i),
  .ASDATA_i(ASDATA_i),
  .ALRCLK_i(ALRCLK_i),
  .APDATA_LEFT_o(APDATA_LEFT_o),
  .APDATA_RIGHT_o(APDATA_RIGHT_o),
  .APDATA_VALID_o(APDATA_VALID_o)
);


endmodule
