
`timescale 1ns / 1ps

module divide_concept_tb();

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


reg [3:0] test_phase;
reg [20:0] dividend_i, divisor_i;
reg [20:0] expected;
reg divide_i, divide_cmd_active;

wire [20:0] quotient_o;
wire done_o;

always @(posedge mclk or negedge nrst)
  if (!nrst) begin
    test_phase <= 4'h0;
    dividend_i <= 21'b0;
    divisor_i <= 21'b0;
    expected <= 42'b0;
    divide_i <= 1'b0;
    divide_cmd_active <= 1'b0;
  end else begin
    case (test_phase)
      4'h0: begin
          if (done_o) begin
            test_phase <= 4'h1;
            divide_cmd_active <= 1'b0; 
            if (expected == quotient_o) $display("Phase %d: expectation matched",test_phase);
            else $display("Phase %d: expectation not matched (%d expected, but %d is result",test_phase,expected,quotient_o);
          end else if (!divide_i & !divide_cmd_active) begin
            dividend_i <= 14388;
            divisor_i <= 64;
            expected <= 224;
            divide_i <= 1'b1;
            divide_cmd_active <= 1'b1;
          end else begin
            divide_i <= 1'b0;
          end
        end
      4'h1: begin
          if (done_o) begin
            test_phase <= 4'h2;
            divide_cmd_active <= 1'b0; 
            if (expected == quotient_o) $display("Phase %d: expectation matched",test_phase);
            else $display("Phase %d: expectation not matched (%d expected, but %d is result",test_phase,expected,quotient_o);
          end else if (!divide_i & !divide_cmd_active) begin
            dividend_i <= 12271;
            divisor_i <= 125;
            expected <= 98;
            divide_i <= 1'b1;
            divide_cmd_active <= 1'b1;
          end else begin
            divide_i <= 1'b0;
          end
        end
      4'h2: begin
          if (done_o) begin
            test_phase <= 4'h3;
            divide_cmd_active <= 1'b0; 
            if (expected == quotient_o) $display("Phase %d: expectation matched",test_phase);
            else $display("Phase %d: expectation not matched (%d expected, but %d is result",test_phase,expected,quotient_o);
          end else if (!divide_i & !divide_cmd_active) begin
            dividend_i <= 14388;
            divisor_i <= 186;
            expected <= 77;
            divide_i <= 1'b1;
            divide_cmd_active <= 1'b1;
          end else begin
            divide_i <= 1'b0;
          end
        end
      4'h3: begin
          if (done_o) begin
            test_phase <= 4'h4;
            divide_cmd_active <= 1'b0; 
            if (expected == quotient_o) $display("Phase %d: expectation matched",test_phase);
            else $display("Phase %d: expectation not matched (%d expected, but %d is result",test_phase,expected,quotient_o);
          end else if (!divide_i & !divide_cmd_active) begin
            dividend_i <= 1459324;
            divisor_i <= 85621;
            expected <= 17;
            divide_i <= 1'b1;
            divide_cmd_active <= 1'b1;
          end else begin
            divide_i <= 1'b0;
          end
        end
      4'h4: begin
          if (done_o) begin
            test_phase <= 4'h0;
            divide_cmd_active <= 1'b0; 
            if (expected == quotient_o) $display("Phase %d: expectation matched",test_phase);
            else $display("Phase %d: expectation not matched (%d expected, but %d is result",test_phase,expected,quotient_o);
          end else if (!divide_i & !divide_cmd_active) begin
            dividend_i <= 14388;
            divisor_i <= 64;
            expected <= 224;
            divide_i <= 1'b1;
            divide_cmd_active <= 1'b1;
          end else begin
            divide_i <= 1'b0;
          end
        end
      default: begin
          test_phase <= 4'h0;
          divide_i <= 1'b0;
          divide_cmd_active <= 1'b0;
        end
    endcase
  end


serial_divide #(
  .DIVIDEND_WIDTH(21),
  .DIVISOR_WIDTH(21),
  .REMINDER_WIDTH(0),
  .COUNT_WIDTH(6)
) serial_divide_dut_0 (
  .clk_i(mclk),
  .nrst_i(nrst),
  .divide_cmd_i(divide_i),
  .dividend_i(dividend_i),
  .divisor_i(divisor_i),
  .quotient_o(quotient_o),
  .done_o(done_o)
  );

/* 

localparam input_pixel = 320;
localparam scaling = 3.5;

//localparam output_pixel = scaling * input_pixel;
localparam output_pixel = 1920;
//localparam init_phase = input_pixel/2 + output_pixel/2;
localparam init_phase = output_pixel/2;

localparam dividend_length = 18;

reg [9:0] pixel_in;
reg [11:0] pixel_out;

reg divide_cmd, appr_mult_factor_valid;

reg [12:0] accu_val_cmb;
reg [11:0] accu_val;
reg [dividend_length + 11:0] product_all, product_cmb;
reg [7:0] my_result;

wire [dividend_length-1:0] appr_mult_factor_w;
wire divide_busy_w, divide_done_w;

always @(*) begin
  accu_val_cmb <= accu_val + input_pixel;
  product_cmb <= accu_val * appr_mult_factor_w;
end


always @(posedge mclk or negedge nrst)
  if (!nrst) begin
    pixel_in <= input_pixel;
    pixel_out <= output_pixel;
    divide_cmd <= 1'b0;
    appr_mult_factor_valid <= 1'b0;
  end else begin
    if (appr_mult_factor_valid) begin
      product_all <= product_cmb;
      // my_result <= product_cmb[23] ? 8'hff : product_cmb[22:15] + product_cmb[14];
      my_result <= product_cmb[22:15] + product_cmb[14];
      if (accu_val_cmb >= pixel_out)
        accu_val <= accu_val_cmb - {1'b0,pixel_out};
      else
        accu_val <= accu_val_cmb;
    end else begin
      if (divide_done_w) begin
        appr_mult_factor_valid <= 1'b1;
        $display("divide operation done");
        accu_val <= init_phase;
        $display("init_phase set");
      end else begin
        pixel_in <= input_pixel;
        pixel_out <= output_pixel;
        divide_cmd <= ~divide_busy_w;
      end
    end
    
  end
serial_divide #(
  .DIVIDEND_WIDTH(dividend_length),
  .DIVISOR_WIDTH(12)
) serial_divide_dut (
  .clk_i(mclk),
  .nrst_i(nrst),
  .divide_cmd_i(divide_cmd),
  .dividend_i({1'b1,{(dividend_length-1){1'b0}}}),
  .divisor_i(pixel_out),
  .quotient_o(appr_mult_factor_w),
  .busy_o(divide_busy_w),
  .done_o(divide_done_w)
  );
  
//wire [11:0] HACTIVE = 640;
//wire [11:0] HACTIVE = 720;
//wire [11:0] HACTIVE = 1280;
wire [11:0] HACTIVE = 1920;
//wire [11:0] HACTIVE = 1600;

wire [dividend_length + 9 : 0] inv_scale = appr_mult_factor_w * pixel_in;
wire [dividend_length + 11 + 9:0] target_pixels_resmax = inv_scale * HACTIVE;

wire [10:0] target_pixels_resmax_final = target_pixels_resmax[35:25] + target_pixels_resmax[24];

//*/

///* 
  

localparam input_pixel = 240;
localparam scaling = 2.875;

//localparam output_pixel = scaling * input_pixel;
localparam output_pixel = 1440;
// localparam init_phase = input_pixel/2 + output_pixel/2;
localparam init_phase = output_pixel/2;

localparam dividend_length = 18;

reg [8:0] pixel_in;
reg [10:0] pixel_out;

reg divide_cmd, appr_mult_factor_valid;

reg [10:0] accu_val, accu_val_cmb;
reg [dividend_length + 10:0] product_all, product_cmb;
reg [7:0] my_result;

wire [dividend_length-1:0] appr_mult_factor_w;
wire divide_busy_w, divide_done_w;

always @(*) begin
  accu_val_cmb <= accu_val + pixel_in;
  product_cmb <= accu_val * appr_mult_factor_w;
end


always @(posedge mclk or negedge nrst)
  if (!nrst) begin
    pixel_in <= input_pixel;
    pixel_out <= output_pixel;
    divide_cmd <= 1'b0;
    appr_mult_factor_valid <= 1'b0;
  end else begin
    if (appr_mult_factor_valid) begin
      product_all <= product_cmb;
      // my_result <= product_cmb[24] ? 8'hff : product_cmb[23:16] + product_cmb[15];
      my_result <= product_cmb[23:16] + product_cmb[15];
      if (accu_val_cmb >= pixel_out)
        accu_val <= accu_val_cmb - pixel_out;
      else
        accu_val <= accu_val_cmb;
    end else begin
      if (divide_done_w) begin
        appr_mult_factor_valid <= 1'b1;
        $display("divide operation done");
        accu_val <= init_phase;
        $display("init_phase set");
      end else begin
        pixel_in <= input_pixel;
        pixel_out <= output_pixel;
        divide_cmd <= ~divide_busy_w;
      end
    end
    
  end

serial_divide #(
  .DIVIDEND_WIDTH(dividend_length),
  .DIVISOR_WIDTH(11)
) serial_divide_dut (
  .clk_i(mclk),
  .nrst_i(nrst),
  .divide_cmd_i(divide_cmd),
  .dividend_i({1'b1,{(dividend_length-1){1'b0}}}),
  .divisor_i(pixel_out),
  .quotient_o(appr_mult_factor_w),
  .busy_o(divide_busy_w),
  .done_o(divide_done_w)
  );

//wire [10:0] VACTIVE = 480;
//wire [10:0] VACTIVE = 576;
//wire [10:0] VACTIVE = 720;
//wire [10:0] VACTIVE = 960;
wire [10:0] VACTIVE = 1080;
//wire [10:0] VACTIVE = 1200;

wire [dividend_length + 8 : 0] inv_scale = appr_mult_factor_w * pixel_in;
wire [dividend_length + 10 + 8:0] target_lines_resmax = inv_scale * VACTIVE;

wire [10:0] target_lines_resmax_final = target_lines_resmax[34:24] + target_lines_resmax[23];

//*/

endmodule
