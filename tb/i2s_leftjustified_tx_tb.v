module i2s_leftjustified_tx_tb();

reg AMCLK_i, nARST, APDATA_INT_VALID_COMB;

initial begin
  AMCLK_i = 1'b0;
  nARST = 1'b0;
  APDATA_INT_VALID_COMB = 1'b0;
end


always begin
  #20 AMCLK_i = 1'b1;
  #20 AMCLK_i = 1'b0;
end

always @(posedge AMCLK_i) begin
  nARST <= 1'b1;
  APDATA_INT_VALID_COMB <= 1'b1;
end

reg signed [23:0] APDATA_INT [0:1];
initial begin
  APDATA_INT[1] = 32'd0;
  APDATA_INT[0] = 32'd0;
end

reg [8:0] cnt_512x = 9'd00;

always @(posedge AMCLK_i) begin
  cnt_512x <= cnt_512x + 1;
  
  if (~|cnt_512x) begin
    APDATA_INT[1] <= APDATA_INT[1] + 1;
    APDATA_INT[0] <= APDATA_INT[0] - 1;
  end
end



wire ASCLK_o, ASDATA_o, ALRCLK_o;

i2s_leftjustified_tx i2s_tx_dut(
  .AMCLK_i(AMCLK_i),
  .nARST(nARST),
  .APDATA_LEFT_i(APDATA_INT[1]),
  .APDATA_RIGHT_i(APDATA_INT[0]),
  .APDATA_VALID_i({APDATA_INT_VALID_COMB,APDATA_INT_VALID_COMB}),
  .ASCLK_o(ASCLK_o),
  .ASDATA_o(ASDATA_o),
  .ALRCLK_o(ALRCLK_o)
);


endmodule
