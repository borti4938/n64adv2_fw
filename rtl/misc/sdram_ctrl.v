//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the N64 RGB/YPbPr DAC project.
//
// Copyright (C) 2015-2023 by Peter Bartmann <borti4938@gmail.com>
//
// N64 RGB/YPbPr DAC is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
//////////////////////////////////////////////////////////////////////////////////
//
// Company:  Circuit-Board.de
// Engineer: borti4938
//
// Module Name:    sdram_ctrl
// Project Name:   N64 Advanced
// Target Devices: 
// Tool versions:  Altera Quartus Prime
// Description:    
//
//////////////////////////////////////////////////////////////////////////////////

module sdram_ctrl #(
  parameter SDRAM_MHZ             = 100,    // clock speed in MHz: needs to be set in order to calculate appropriate delays
  parameter SDRAM_CL              = 2,      // clock latency; should be at least 2 and 3 if clock is above 133MHz
  parameter INPUT_SHIFT_WINDOW    = 0,      // possibly needs to be assigned if sdram clock leads internal clock
  parameter SDRAM_START_DELAY_US  = 200,    // startup delay in us
  parameter SDRAM_TREFI_NS        = 15625,  // Maximum auto Refresh period per row in ns (README: probably need to allow some skew!)
  parameter SDRAM_TRC_NS          = 63,     // Row cycle time (same bank)
  parameter SDRAM_TRFC_NS         = 63,     // Refresh time in ns (often equals tRC (row cycle time))
  parameter SDRAM_TRCD_NS         = 21,     // Active to read/write time in ns (#RAS to #CAS# delay (same bank))
  parameter SDRAM_TRP_NS          = 21,     // Precharged time in ns (Precharge to refresh/row activate command (same bank))
//   parameter SDRAM_TRRD_NS         = 14,     // Row activate to row activate delay (different banks) <- unused / not implemented as never undercutted in practice
  parameter SDRAM_TRAS_NS         = 42      // Minimum Row Active to precharge time in ns (same bank) / maximum cannot be exceeded due to auto refresh cycles
//   parameter SDRAM_TCCD_NS         = 10  // #CAS to #CAS# delay <- unused / not implemented as never undercutted in practice
) (
  CLK_i,
  nRST_i,

  // User Interface
  req_i,
  we_i,
  addr_i,
  data_i,
  data_o,
  cmd_ack_o,
  data_ack_o,
  sdram_ctrl_rdy_o,
  
  // SDRAM Interface
  sdram_cke_o,
  sdram_cs_o,
  sdram_ras_o,
  sdram_cas_o,
  sdram_we_o,
  sdram_dqm_o,
  sdram_addr_o,
  sdram_ba_o,
  sdram_data_io
);

localparam SDRAM_BANK_W  = 2;
localparam SDRAM_ADDR_W  = 24;
localparam SDRAM_BICOL_W = 8;
localparam SDRAM_DQM_W   = 2;

localparam SDRAM_BANKS  = 2 ** SDRAM_BANK_W;
localparam SDRAM_ROW_W  = SDRAM_ADDR_W - SDRAM_BANK_W - SDRAM_BICOL_W - 1;
localparam SDRAM_DATA_W = (SDRAM_DQM_W * 8);


// Clock and Reset
input CLK_i;
input nRST_i;

// User Interface
input req_i;
input we_i;
input [SDRAM_ADDR_W-2:0] addr_i; // {(2bits bank),(13bits row),(8bits dblcolumn)}
input [2*SDRAM_DATA_W-1:0] data_i;
output [2*SDRAM_DATA_W-1:0] data_o;
output reg cmd_ack_o;
output reg data_ack_o;
output reg sdram_ctrl_rdy_o;

// SDRAM Interface
output                    sdram_cke_o;
output                    sdram_cs_o;
output                    sdram_ras_o;
output                    sdram_cas_o;
output                    sdram_we_o;
output [SDRAM_DQM_W-1:0]  sdram_dqm_o;
output [SDRAM_ROW_W-1:0]  sdram_addr_o;
output [SDRAM_BANK_W-1:0] sdram_ba_o;
inout  [SDRAM_DATA_W-1:0] sdram_data_io;

//-----------------------------------------------------------------
// Defines / Local params
//-----------------------------------------------------------------
  
// SDRAM timing
localparam SDRAM_TCK_CYCLES = 1;

localparam SDRAM_START_DELAY_CYCLES = SDRAM_START_DELAY_US * SDRAM_MHZ;
localparam SDRAM_TREFI_CYCLES = SDRAM_TREFI_NS*SDRAM_MHZ/1000; // max value
localparam SDRAM_TRC_CYCLES = (SDRAM_TRC_NS + (1000/SDRAM_MHZ - 1))*SDRAM_MHZ/1000 + 1;
localparam SDRAM_TRFC_CYCLES = (SDRAM_TRFC_NS + (1000/SDRAM_MHZ - 1))*SDRAM_MHZ/1000 + 1;
localparam SDRAM_TRCD_CYCLES = (SDRAM_TRCD_NS + (1000/SDRAM_MHZ - 1))*SDRAM_MHZ/1000 + 1;
localparam SDRAM_TRP_CYCLES  = (SDRAM_TRP_NS + (1000/SDRAM_MHZ - 1))*SDRAM_MHZ/1000 + 1;
// localparam SDRAM_TRRD_CYCLES = (SDRAM_TRRD_NS + (1000/SDRAM_MHZ - 1))*SDRAM_MHZ/1000 + 1;
localparam SDRAM_TRAS_CYCLES = (SDRAM_TRAS_NS + (1000/SDRAM_MHZ - 1))*SDRAM_MHZ/1000 + 1;

localparam SDRAM_TMRD_CYCLES = 2;
localparam BOOT_SEQUENCE_LENGTH = SDRAM_START_DELAY_CYCLES + 2*SDRAM_TCK_CYCLES + SDRAM_TRP_CYCLES + 2*SDRAM_TRFC_CYCLES + SDRAM_TMRD_CYCLES;

localparam DELAY_CNT_W = $clog2(SDRAM_TRC_CYCLES+1);         // should be the maximum number of needed to represent tRCD, tRP, tRFC (check synthesis warnings if unsure)
localparam REFRESH_CNT_W = $clog2(BOOT_SEQUENCE_LENGTH+1);  // counter width to check for pending auto refresh cycles and control init sequence (check synthesis warnings if unsure)
//localparam DELAY_CNT_W = 4;  // counter width to check for pending auto refresh cycles and control init sequence (check synthesis warnings if unsure)
//localparam REFRESH_CNT_W = 12;  // counter width to check for pending auto refresh cycles and control init sequence (check synthesis warnings if unsure)

// Mode: Burst Length = 4 bytes
localparam MODE_REG_BA = 2'b00; // RFU
localparam MODE_REG_A = {3'b000,1'b0,2'b00,SDRAM_CL[2:0],1'b0,3'b001}; // {RFU (3bits), WBL, Test Mode (2 bits), CAS Latency (3 bits), BT, BL (3 bits)}

// SDRAM Commands (nCS, nRAS, nCAS, nWE)
localparam CMD_W             = 4;
localparam CMD_NOP_INHIBIT   = 4'b1000;
localparam CMD_NOP           = 4'b0111;
localparam CMD_ACTIVE        = 4'b0011;
localparam CMD_READ          = 4'b0101;
localparam CMD_WRITE         = 4'b0100;
localparam CMD_TERMINATE     = 4'b0110;
localparam CMD_PRECHARGE     = 4'b0010;
localparam CMD_AUTOREFRESH   = 4'b0001;
localparam CMD_LOAD_MODE     = 4'b0000;

localparam AUTO_PRECHARGE_BIT = 10;
localparam ALL_BANKS_BIT      = 10;

// SM states
localparam STATE_W             = 4;
localparam STATE_INIT          = 4'd0;
localparam STATE_WAIT          = 4'd1;
localparam STATE_IDLE          = 4'd2;
localparam STATE_ACTIVATE      = 4'd3;
localparam STATE_READ_0        = 4'd4;
localparam STATE_READ_1        = 4'd5;
localparam STATE_WRITE_0       = 4'd6;
localparam STATE_WRITE_1       = 4'd7;
localparam STATE_PRECHARGE     = 4'd8;
localparam STATE_PRECHARGE_ALL = 4'd9;
localparam STATE_AUTOREFRESH   = 4'd10;



// misc stuff

integer int_idx;
localparam INT_READ_LATENCY = SDRAM_CL + INPUT_SHIFT_WINDOW + 1;


// wires

wire [SDRAM_DATA_W-1:0] sdram_data_in_w;
wire [SDRAM_BANK_W-1:0] addr_bank_w;
wire [SDRAM_ROW_W-1:0] addr_row_w, addr_col_w;

// cmb


// regs
reg [REFRESH_CNT_W-1:0] autorefresh_timer_r;
reg autorefresh_req_r;

reg [DELAY_CNT_W-1:0] delay_r;
reg [DELAY_CNT_W-1:0] delay_rc_r[0:SDRAM_BANKS-1];
reg [DELAY_CNT_W-1:0] delay_ras_r[0:SDRAM_BANKS-1];

reg [STATE_W-1:0] delayed_state_r, jump_state_r, state_r;

reg [SDRAM_BANKS-1:0] row_open_r; // remains zero if bank is not active
reg [SDRAM_ROW_W-1:0] active_row_r[0:SDRAM_BANKS-1];

reg cke_r;
reg [CMD_W-1:0] command_r;
reg [SDRAM_BANK_W-1:0] bank_r, bank_buf_r;
reg [SDRAM_ROW_W-1:0] addr_r, addr_col_buf_r, addr_row_buf_r;

reg [INT_READ_LATENCY-1:0] rd_cl_r;
reg [SDRAM_DQM_W-1:0] dqm_r;
reg oe_data_r;
reg [SDRAM_DATA_W-1:0] rd_data_r, rd_data_lsb_r;
reg [SDRAM_DATA_W-1:0] wr_data_r, wr_data_lsb_r, wr_data_msb_r;



// assign input wire
assign sdram_data_in_w = sdram_data_io;

// Decode address bits
assign addr_bank_w = addr_i[SDRAM_ADDR_W-2:SDRAM_ADDR_W-SDRAM_BANK_W-1];
assign addr_row_w  = addr_i[SDRAM_ADDR_W-SDRAM_BANK_W-2:SDRAM_BICOL_W];
assign addr_col_w  = {{(SDRAM_ROW_W-SDRAM_BICOL_W-1){1'b0}},addr_i[SDRAM_BICOL_W-1:0],1'b0};


// rtl



// refresh and delay management
always @ (posedge CLK_i or negedge nRST_i)
  if (!nRST_i) begin
    autorefresh_timer_r <= BOOT_SEQUENCE_LENGTH;
    autorefresh_req_r <= 1'b0;
  end else begin
    if (autorefresh_timer_r == {REFRESH_CNT_W{1'b0}}) begin
      autorefresh_timer_r <= SDRAM_TREFI_CYCLES;
      autorefresh_req_r <= 1'b1;
    end else begin
      autorefresh_timer_r <= autorefresh_timer_r - 1'b1;
      if (state_r == STATE_AUTOREFRESH)
      autorefresh_req_r <= 1'b0;
    end
  end



// processing clocked i/o beavior
always @ (posedge CLK_i or negedge nRST_i)
  if (!nRST_i) begin
    sdram_ctrl_rdy_o <= 1'b0;
    cmd_ack_o <= 1'b0;
    data_ack_o <= 1'b0;
    
    delay_r <= {DELAY_CNT_W{1'b0}};
    for (int_idx = 0; int_idx < SDRAM_BANKS; int_idx = int_idx + 1) begin
      delay_rc_r[int_idx] <= {DELAY_CNT_W{1'b0}};
      delay_ras_r[int_idx] <= {DELAY_CNT_W{1'b0}};
    end
    jump_state_r <= STATE_IDLE;
    state_r <= STATE_INIT;
    
    row_open_r <= {SDRAM_BANKS{1'b0}};
    for (int_idx=0;int_idx<SDRAM_BANKS;int_idx=int_idx+1)
      active_row_r[int_idx] <= {SDRAM_ROW_W{1'b0}};
    
    cke_r <= 1'b0; 
    command_r <= CMD_NOP;
    bank_r <= {SDRAM_BANK_W{1'b0}};
    addr_r <= {SDRAM_ROW_W{1'b0}};
    bank_buf_r <= {SDRAM_BANK_W{1'b0}};
    addr_row_buf_r <= {SDRAM_ROW_W{1'b0}};
    addr_col_buf_r <= {SDRAM_ROW_W{1'b0}};
    
    rd_cl_r <= {(INT_READ_LATENCY){1'b0}};
    dqm_r <= {SDRAM_DQM_W{1'b1}};
    oe_data_r <= 1'b0;
    rd_data_r <= {SDRAM_DATA_W{1'b0}};
    rd_data_lsb_r <= {SDRAM_DATA_W{1'b0}};
    wr_data_r <= {SDRAM_DATA_W{1'b0}};
    wr_data_lsb_r <= {SDRAM_DATA_W{1'b0}};
    wr_data_msb_r <= {SDRAM_DATA_W{1'b0}};
  end else begin
    cmd_ack_o <= 1'b0;
    data_ack_o <= rd_cl_r[INT_READ_LATENCY-1];
    
    rd_cl_r <= {rd_cl_r[INT_READ_LATENCY-2:0], (state_r == STATE_READ_1)};
    if (rd_cl_r[INT_READ_LATENCY-1]|rd_cl_r[INT_READ_LATENCY-2]) begin
      rd_data_lsb_r <= rd_data_r;
      rd_data_r <= sdram_data_in_w;
    end
    
    
    for (int_idx = 0; int_idx < SDRAM_BANKS; int_idx = int_idx + 1) begin
      delay_rc_r[int_idx] <= ~|delay_rc_r[int_idx] ? delay_rc_r[int_idx] - 1'b1 : {DELAY_CNT_W{1'b0}};
      delay_ras_r[int_idx] <= ~|delay_ras_r[int_idx] ? delay_ras_r[int_idx] - 1'b1 : {DELAY_CNT_W{1'b0}};
    end
    
    if (|delay_r) begin
      delay_r <= delay_r - 1'b1;
      command_r <= CMD_NOP;
      bank_r <= {SDRAM_BANK_W{1'b0}};
      addr_r <= {SDRAM_ROW_W{1'b0}};
      oe_data_r <= 1'b0;
    end else begin
      oe_data_r <= 1'b0;
      case (state_r)
        STATE_INIT: begin
            case (autorefresh_timer_r)
              2*SDRAM_TCK_CYCLES + SDRAM_TRP_CYCLES + 2*SDRAM_TRFC_CYCLES + SDRAM_TMRD_CYCLES: begin // Assert CKE after SDRAM_START_DELAY_US
                  cke_r <= 1'b1;
                end
              SDRAM_TRP_CYCLES + 2*SDRAM_TRFC_CYCLES + SDRAM_TMRD_CYCLES: begin // PRECHARGE (Precharge all banks)
                  command_r <= CMD_PRECHARGE;
                  bank_r <= {SDRAM_BANK_W{1'b0}};
                  addr_r <= {SDRAM_ROW_W{1'b0}};
                  addr_r[ALL_BANKS_BIT] <= 1'b1;
                end
              2*SDRAM_TRFC_CYCLES + SDRAM_TMRD_CYCLES: begin  // 2 x REFRESH (with at least tRFC wait)
                  command_r <= CMD_AUTOREFRESH;
                  bank_r <= {SDRAM_BANK_W{1'b0}};
                  addr_r <= {SDRAM_ROW_W{1'b0}};
                end
              SDRAM_TRFC_CYCLES + SDRAM_TMRD_CYCLES: begin
                  command_r <= CMD_AUTOREFRESH;
                  bank_r <= {SDRAM_BANK_W{1'b0}};
                  addr_r <= {SDRAM_ROW_W{1'b0}};
                end
              SDRAM_TMRD_CYCLES: begin  // Load mode register
                  command_r <= CMD_LOAD_MODE;
                  bank_r <= MODE_REG_BA;
                  addr_r <= MODE_REG_A;
                end
              default: begin  // Other cycles during init - just NOP
                  command_r <= CMD_NOP;
                  bank_r <= {SDRAM_BANK_W{1'b0}};
                  addr_r <= {SDRAM_ROW_W{1'b0}};
                end
            endcase
            state_r <= |autorefresh_timer_r ? STATE_INIT : STATE_IDLE;
            sdram_ctrl_rdy_o <= ~|autorefresh_timer_r;
            dqm_r <= {SDRAM_DQM_W{|autorefresh_timer_r}};
          end
        STATE_IDLE: begin
            command_r <= CMD_NOP;
            bank_r <= {SDRAM_BANK_W{1'b0}};
            addr_r <= {SDRAM_ROW_W{1'b0}};
            if (autorefresh_req_r) begin
              if (|row_open_r) begin // is any row open
                state_r <= STATE_PRECHARGE_ALL;
              end else begin
                state_r <= STATE_AUTOREFRESH;
              end
            end else if (req_i) begin
              if (row_open_r[addr_bank_w]) begin // row in requested bank is open
                if (addr_row_w == active_row_r[addr_bank_w]) begin // requested row is open
                  state_r <= we_i ? STATE_WRITE_0 : STATE_READ_0;
                  jump_state_r <= STATE_IDLE;
                end else begin
                  state_r <= STATE_PRECHARGE;
                  jump_state_r <= we_i ? STATE_WRITE_0 : STATE_READ_0;
                  delay_r <= delay_ras_r[addr_bank_w];
                end
              end else begin // no row in requested bank is open
                state_r <= STATE_ACTIVATE;
                jump_state_r <= we_i ? STATE_WRITE_0 : STATE_READ_0;
                delay_r <= delay_rc_r[addr_bank_w];
              end
              bank_buf_r <= addr_bank_w;
              addr_row_buf_r <= addr_row_w;
              addr_col_buf_r <= addr_col_w;
              wr_data_msb_r <= data_i[2*SDRAM_DATA_W-1:SDRAM_DATA_W];
              wr_data_lsb_r <= data_i[SDRAM_DATA_W-1:0];
              cmd_ack_o <= 1'b1;
            end
          end
        STATE_ACTIVATE: begin // Select a row and activate it
            command_r <= CMD_ACTIVE;
            bank_r <= bank_buf_r;
            addr_r <= addr_row_buf_r;
            row_open_r[bank_buf_r] <= 1'b1;    // open row of active bank
            active_row_r[bank_buf_r] <= addr_row_buf_r;
            state_r <= jump_state_r;
            delay_r <= SDRAM_TRCD_CYCLES;
            delay_rc_r[bank_buf_r] <= SDRAM_TRC_CYCLES;
            delay_ras_r[bank_buf_r] <= SDRAM_TRAS_CYCLES;
          end
        STATE_PRECHARGE: begin
            command_r <= CMD_PRECHARGE;
            bank_r <= bank_buf_r;
            addr_r <= {SDRAM_ROW_W{1'b0}};
            row_open_r[bank_buf_r] <= 1'b0;
            state_r <= STATE_ACTIVATE;
            delay_r <= SDRAM_TRP_CYCLES;
          end
        STATE_PRECHARGE_ALL: begin  // Precharge all banks (due to refresh)
            command_r <= CMD_PRECHARGE;
            bank_r <= {SDRAM_BANK_W{1'b0}};
            addr_r <= {SDRAM_ROW_W{1'b0}};
            addr_r[ALL_BANKS_BIT] <= 1'b1; // Precharge all banks (close all banks if target stage is REFRESH) or specific bank (else)
            row_open_r <= {SDRAM_BANKS{1'b0}};
            state_r <= STATE_AUTOREFRESH;
            delay_r <= SDRAM_TRP_CYCLES;
          end
        STATE_AUTOREFRESH: begin  // Auto refresh
            command_r <= CMD_AUTOREFRESH;
            bank_r <= {SDRAM_BANK_W{1'b0}};
            addr_r <= {SDRAM_ROW_W{1'b0}};
            delay_r <= SDRAM_TRFC_CYCLES;
            state_r <= STATE_IDLE;
          end
        STATE_READ_0: begin
            command_r <= CMD_READ;
            bank_r <= bank_buf_r;
            addr_r <= addr_col_buf_r;
//            addr_r[AUTO_PRECHARGE_BIT] <= 1'b0; // Disable auto precharge (auto close of row)
            state_r <= STATE_READ_1;
          end
        STATE_READ_1: begin
            command_r <= CMD_NOP; // Burst continuation
            bank_r <= {SDRAM_BANK_W{1'b0}};
            addr_r <= {SDRAM_ROW_W{1'b0}};
            if (!autorefresh_req_r && req_i && !we_i) begin // no auto refresh pending and another read request
              if (row_open_r[addr_bank_w] && active_row_r[addr_bank_w] == addr_row_w) begin // Open row hit
                state_r <= STATE_READ_0;
                bank_buf_r <= addr_bank_w;
                addr_col_buf_r <= addr_col_w;
                cmd_ack_o <= 1'b1;
              end else begin
                delay_r <= SDRAM_CL;    // wait clock latency
                state_r <= STATE_IDLE;  // go over state idle if row has to be activated
              end
            end else begin
              delay_r <= SDRAM_CL;
              state_r <= STATE_IDLE; // go back to idle
            end
          end
        STATE_WRITE_0: begin
            command_r <= CMD_WRITE;
            bank_r <= bank_buf_r;
            addr_r <= addr_col_buf_r;
//            addr_r[AUTO_PRECHARGE_BIT]  <= 1'b0; // Disable auto precharge (auto close of row)
            wr_data_r <= wr_data_lsb_r;
            oe_data_r <= 1'b1;
            state_r <= STATE_WRITE_1;
          end
        STATE_WRITE_1: begin
            command_r <= CMD_NOP; // Burst continuation
            bank_r <= {SDRAM_BANK_W{1'b0}};
            addr_r <= {SDRAM_ROW_W{1'b0}};
//            addr_r[AUTO_PRECHARGE_BIT] <= 1'b0; // Disable auto precharge (auto close of row)
            wr_data_r <= wr_data_msb_r;
            oe_data_r <= 1'b1;
            if (!autorefresh_req_r && req_i && we_i) begin // no auto refresh pending and another write request
              if (row_open_r[addr_bank_w] && active_row_r[addr_bank_w] == addr_row_w) begin // Open row hit
                state_r <= STATE_WRITE_0;
                bank_buf_r <= addr_bank_w;
                addr_col_buf_r <= addr_col_w;
                wr_data_msb_r <= data_i[2*SDRAM_DATA_W-1:SDRAM_DATA_W];
                wr_data_lsb_r <= data_i[SDRAM_DATA_W-1:0];
                cmd_ack_o <= 1'b1;
              end else begin
                state_r <= STATE_IDLE;  // go over state idle if row has to be activated
              end
            end else begin
              state_r <= STATE_IDLE; // go back to idle
            end
          end
        default: begin  // should not appear
            command_r <= CMD_NOP;
            bank_r <= {SDRAM_BANK_W{1'b0}};
            addr_r <= {SDRAM_ROW_W{1'b0}};
            state_r <= STATE_IDLE;
          end
      endcase
    end
  end

// final assignments for SDRAM I/O
assign sdram_data_io = oe_data_r ? wr_data_r : 16'bz;
assign sdram_cke_o = cke_r;
assign {sdram_cs_o,sdram_ras_o,sdram_cas_o,sdram_we_o} = command_r;
assign sdram_dqm_o  = dqm_r;
assign sdram_ba_o = bank_r;
assign sdram_addr_o = addr_r;

assign data_o = {rd_data_r,rd_data_lsb_r};

endmodule
