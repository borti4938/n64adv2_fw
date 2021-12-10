
module serial_divide (
  clk_i,
  nrst_i,
  
  dividend_i,
  divisor_i,
  
  divide_cmd_i,
  busy_o,
  done_o,
  
  quotient_o
);

parameter DIVIDEND_WIDTH = 16;
parameter DIVISOR_WIDTH = 8;
parameter REMINDER_WIDTH = 0;
parameter COUNT_WIDTH = 5;    // 2^COUNT_WIDTH >= (DIVIDEND_WIDTH+REMINDER_WIDTH-1)

input  clk_i;
input  nrst_i;

input  [DIVIDEND_WIDTH-1:0] dividend_i;
input  [DIVISOR_WIDTH-1:0] divisor_i;

input  divide_cmd_i;
output reg busy_o;
output reg done_o;

output reg [DIVIDEND_WIDTH+REMINDER_WIDTH-1:0] quotient_o;

// local params

localparam STATE_RDY = 2'b00;
localparam STATE_RUN = 2'b01;
localparam STATE_FIN = 2'b10;
localparam STATE_RST = 2'b11;

// regs and wires

reg [1:0] serial_div_state;
reg  [COUNT_WIDTH-1:0] seial_div_cnt;

reg  [DIVIDEND_WIDTH+REMINDER_WIDTH-1:0] extended_dividend;
reg  [DIVIDEND_WIDTH+DIVISOR_WIDTH+REMINDER_WIDTH-2:0] extended_divisor;
reg  [DIVIDEND_WIDTH+REMINDER_WIDTH-1:0] quotient_int;

wire [DIVIDEND_WIDTH+DIVISOR_WIDTH+REMINDER_WIDTH-1:0] subtract_node;
wire [DIVIDEND_WIDTH+REMINDER_WIDTH-1:0] quotient_node;
wire [DIVIDEND_WIDTH+DIVISOR_WIDTH+REMINDER_WIDTH-2:0] divisor_node;

// start of rtl

assign subtract_node = {1'b0,extended_dividend} - {1'b0,extended_divisor};
assign quotient_node = {quotient_int[DIVIDEND_WIDTH+REMINDER_WIDTH-2:0],~subtract_node[DIVIDEND_WIDTH+DIVISOR_WIDTH+REMINDER_WIDTH-1]};
assign divisor_node  = {1'b0,extended_divisor[DIVIDEND_WIDTH+DIVISOR_WIDTH+REMINDER_WIDTH-2:1]};

always @(posedge clk_i or negedge nrst_i)
  if (!nrst_i) begin
    serial_div_state <= STATE_RST;
    seial_div_cnt <= {COUNT_WIDTH{1'b0}};
    
    extended_dividend <= {(DIVIDEND_WIDTH+REMINDER_WIDTH){1'b0}};
    extended_divisor <= {(DIVIDEND_WIDTH+REMINDER_WIDTH+REMINDER_WIDTH-1){1'b0}};
    quotient_int <= {(DIVIDEND_WIDTH+REMINDER_WIDTH){1'b0}};
    
    busy_o <= 1'b0;
    done_o <= 1'b0;
    quotient_o <= {(DIVIDEND_WIDTH+REMINDER_WIDTH){1'b0}};
  end else begin
    case (serial_div_state)
      STATE_RDY: begin
          done_o <= 1'b0;
          if (divide_cmd_i) begin
            seial_div_cnt <= {COUNT_WIDTH{1'b0}};
            extended_dividend <= dividend_i << REMINDER_WIDTH;
            extended_divisor <= divisor_i << (DIVISOR_WIDTH+REMINDER_WIDTH-1);
            quotient_int <= {(DIVIDEND_WIDTH+REMINDER_WIDTH){1'b0}};
            busy_o <= 1'b1;
            serial_div_state <= STATE_RUN;
          end
        end
      STATE_RUN: begin
          if (~subtract_node[DIVIDEND_WIDTH+DIVISOR_WIDTH+REMINDER_WIDTH-1])
            extended_dividend <= subtract_node;
          extended_divisor <= divisor_node;
          quotient_int <= quotient_node;
          if (seial_div_cnt < DIVIDEND_WIDTH+REMINDER_WIDTH-2)
            seial_div_cnt <= seial_div_cnt + 1'b1;
          else
            serial_div_state <= STATE_FIN;
        end
      STATE_FIN: begin
          busy_o <= 1'b0;
          done_o <= 1'b1;
          quotient_o <= quotient_node;
          serial_div_state <= STATE_RDY;
        end
      default: begin
          // busy_o <= 1'b0;
          // done_o <= 1'b0;
          serial_div_state <= STATE_RDY;
        end
    endcase
  end

endmodule
