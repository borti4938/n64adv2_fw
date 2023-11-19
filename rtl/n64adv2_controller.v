//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the N64 RGB/YPbPr DAC project.
//
// Copyright (C) 2016-2023 by Peter Bartmann <borti4938@gmx.de>
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
// Module Name:    n64adv2_controller
// Project Name:   N64 Advanced HDMI Mod
// Target Devices: 
// Tool versions:  Altera Quartus Prime
// Description:
//
// Dependencies:
//
// Features:
// Latest change:
//
//////////////////////////////////////////////////////////////////////////////////


module n64adv2_controller #(
  parameter [11:0] hdl_fw = 12'h000 // number is a dummy; defined in and passed from top module
)(
  N64_nRST_io,
  nRST_Masking_o,
  
  SCLKs,
  nSRSTs,

  CTRL_i,

  I2C_SCL,
  I2C_SDA,
  Interrupt_i,
  HDMI_cfg_done_o,

  run_pincheck_o,
  pincheck_status_i,

  APUConfigSet,

  PPUState,
  PPUConfigSet,
  OSD_VSync,
  OSDWrVector,
  OSDInfo,

  N64_CLK_i,
  N64_nVRST_i,
  nVDSYNC_i,
  VD_VS_i,
  VD_HS_i,

  LED_o,
  PCB_ID_i
);


`include "../lib/n64adv_cparams.vh"
`include "../lib/n64adv2_config.vh"

inout N64_nRST_io;
output reg [1:0] nRST_Masking_o;

input [1:0] SCLKs;
input [1:0] nSRSTs;

input CTRL_i;

inout       I2C_SCL;
inout       I2C_SDA;
input [1:0] Interrupt_i;
output      HDMI_cfg_done_o;

output run_pincheck_o;
input [15:0] pincheck_status_i;

output reg [`APUConfig_WordWidth-1:0] APUConfigSet;
input      [`PPU_State_Width-1:0] PPUState;
output reg [`PPUConfig_WordWidth-1:0] PPUConfigSet;

input             OSD_VSync;
output reg [20:0] OSDWrVector;
output reg [ 1:0] OSDInfo;

input N64_CLK_i;
input N64_nVRST_i;
input nVDSYNC_i;
input VD_VS_i;
input VD_HS_i;

output [ 1:0] LED_o;
input [ 2:0] PCB_ID_i;


// start of rtl

// misc stuff
wire SYS_CLK = SCLKs[1];
wire CTRL_CLK = SCLKs[0];

wire SYS_nRST = nSRSTs[1];
wire CTRL_nRST = nSRSTs[0];


// parameters
localparam ST_WAIT4N64 = 2'b00; // wait for N64 sending request to controller
localparam ST_N64_RD   = 2'b01; // N64 request sniffing
localparam ST_CTRL_RD  = 2'b10; // controller response

// wires

wire        vd_wrctrl_w;
wire [19:0] vd_wrdata_w;

wire FallbackMode_resynced, FallbackMode_valid_resynced;
wire [`PPU_State_Width-1:0] PPUState_resynced;
wire ctrl_detected_resynced;
wire OSD_VSync_resynced;

wire nVSYNC_buf_resynced;
wire new_ctrl_data_resynced;
wire ctrl_data_tack, ctrl_data_tack_resynced;

wire nVSYNC_CPU_w;

wire CHIP_ID_valid_w;
wire [63:0] CHIP_ID_pre_w, CHIP_ID_w;

wire [15:0] SysConfigSet3;                                // general structure of ConfigSet -> see vh/n64adv2_ppuconfig.vh
wire [31:0] SysConfigSet2, SysConfigSet1 ,SysConfigSet0;  // general structure of ConfigSet -> see vh/n64adv2_ppuconfig.vh

wire [2:0] hw_info_sel;
wire [15:0] hw_info;

wire use_igr_resynced;

wire ctrl_negedge, ctrl_posedge;
wire ctrl_bit;

// registers
reg nVSYNC_buf = 1'b0;
reg [1:0] nHSYNC_buf = 2'b0;

reg [4:0] n64_clk_cnt = 5'd0;
reg pal_pattern = 1'b0;

reg [9:0] time_out = 10'd1023;
reg FallbackMode  = 1'b0;
reg FallbackMode_valid = 1'b0;

reg [1:0] ctrl_data_tack_resynced_L = 2'b00;
reg [1:0] nVSYNC_resynced_L = 2'b00;
reg use_igr = 1'b0;


reg [1:0] rd_state = 2'b0; // state machine

reg [7:0] wait_cnt  = 8'h0; // counter for wait state (needs appr. 48us at CTRL_CLK = 4MHz clock to fill up from 0 to 255)
reg [2:0] ctrl_hist = 3'h7;

reg [7:0] ctrl_low_cnt = 8'h0;
reg [31:0] serial_data[0:2];
initial begin
  serial_data[2] <= 32'h0;
  serial_data[1] <= 32'h0;
  serial_data[0] <= 32'h0;
end
reg [ 4:0] ctrl_data_cnt    = 5'h0;
reg [ 1:0] new_ctrl_data    = 2'b00;

reg ctrl_detected = 1'b0;

reg initiate_nrst = 1'b0;
reg       drv_rst =  1'b0;
reg [19:0] rst_cnt = 20'b0; // ~230ms are needed to count from max downto 0 with CTRL_CLK being 4MHz.


// logic

always @(posedge N64_CLK_i)
  if (!N64_nVRST_i) begin
    nVSYNC_buf <= 1'b0;
    nHSYNC_buf <= 2'b0;
    n64_clk_cnt <= 5'd0;
    pal_pattern <= 1'b0;
  end else begin
    if (nHSYNC_buf[1] & !nHSYNC_buf[0]) begin
      if (n64_clk_cnt == 5'b01101)  // five LSBs of `PIXEL_PER_LINE_PAL_4x_long0 (leap pattern in WR64 like)
        pal_pattern <= 1'b0;
      if (!n64_clk_cnt[0])          // only `PIXEL_PER_LINE_PAL_4x_long1 has a zero here (leap pattern in SM64 like)
        pal_pattern <= 1'b1;
      n64_clk_cnt <= 5'd0;
    end else begin
      n64_clk_cnt <= n64_clk_cnt + 1'b1;
    end
    nHSYNC_buf[1] <= nHSYNC_buf[0];
    if (!nVDSYNC_i) begin
      nVSYNC_buf    <= VD_VS_i;
      nHSYNC_buf[0] <= VD_HS_i;
    end
  end

// Part 1: Instantiate NIOS II
// ===========================

always @(posedge N64_CLK_i)
  if (!FallbackMode_valid) begin
    if (~|time_out) begin
      FallbackMode <= ~N64_nVRST_i;
      FallbackMode_valid <= 1'b1;
    end
    time_out <= time_out - 10'd1;
  end


register_sync #(
  .reg_width(1 + `PPU_State_Width + 5), // 1 + PPU_State_Width + 1 + 1 + 1 + 1 + 1
  .reg_preset({(1 + `PPU_State_Width + 5){1'b0}})
) sync4cpu_u0(
  .clk(SYS_CLK),
  .clk_en(1'b1),
  .nrst(1'b1),
  .reg_i({ctrl_detected,PPUState[`PPU_State_Width-1],pal_pattern,PPUState[`PPU_State_Width-3:0],FallbackMode,FallbackMode_valid,new_ctrl_data[1],OSD_VSync,nVSYNC_buf}),
  .reg_o({ctrl_detected_resynced,PPUState_resynced,FallbackMode_resynced,FallbackMode_valid_resynced,new_ctrl_data_resynced,OSD_VSync_resynced,nVSYNC_buf_resynced})
);

chip_id chip_id_u(
  .clkin(SYS_CLK),
  .reset(~SYS_nRST),
  .data_valid(CHIP_ID_valid_w),
  .chip_id(CHIP_ID_pre_w)
);

assign nVSYNC_CPU_w = HDMI_cfg_done_o ? OSD_VSync_resynced : nVSYNC_buf_resynced;
assign CHIP_ID_w = CHIP_ID_valid_w ? CHIP_ID_pre_w : 64'h0;
assign hw_info = hw_info_sel == 3'b101 ? CHIP_ID_w[63:48] :
                 hw_info_sel == 3'b100 ? CHIP_ID_w[47:32] :
                 hw_info_sel == 3'b011 ? CHIP_ID_w[31:16] :
                 hw_info_sel == 3'b010 ? CHIP_ID_w[15: 0] :
                 hw_info_sel == 3'b001 ? pincheck_status_i :
                                         {hdl_fw,1'b0,PCB_ID_i};

system_n64adv2 system_u(
  .clk_clk(SYS_CLK),
  .rst_reset_n(SYS_nRST),
  .i2c_scl_pad_io(I2C_SCL),
  .i2c_sda_pad_io(I2C_SDA),
  .interrupts_n_export(~Interrupt_i),
  .sync_in_export({new_ctrl_data_resynced,nVSYNC_CPU_w}),
  .vd_wrctrl_export(vd_wrctrl_w),
  .vd_wrdata_export(vd_wrdata_w),
  .ctrl_data_in_export(serial_data[2]),
  .n64adv_state_in_export({ctrl_detected_resynced,PPUState_resynced}),
  .fallback_in_export({FallbackMode_resynced,FallbackMode_valid_resynced}),
  .cfg_set3_out_export(SysConfigSet3),
  .cfg_set2_out_export(SysConfigSet2),
  .cfg_set1_out_export(SysConfigSet1),
  .cfg_set0_out_export(SysConfigSet0),
  .info_sync_out_export({HDMI_cfg_done_o,hw_info_sel,run_pincheck_o,ctrl_data_tack}),
  .led_out_export(LED_o),
  .hw_info_in_export(hw_info)
);


always @(posedge SYS_CLK) begin
  if (nVSYNC_resynced_L[1] & !nVSYNC_resynced_L[0]) begin
    OSDInfo[1]   <= &{SysConfigSet1[`show_osd_logo_bit],SysConfigSet1[`show_osd_bit],!SysConfigSet1[`mute_osd_bit]};  // show logo only in OSD
    OSDInfo[0]   <= SysConfigSet1[`show_osd_bit] & !SysConfigSet1[`mute_osd_bit];
    PPUConfigSet <= {SysConfigSet2[`cfg2_scanline_slice],SysConfigSet1[`cfg1_ppu_config_slice],SysConfigSet0};
  end
  nVSYNC_resynced_L <= {nVSYNC_resynced_L[0],nVSYNC_buf_resynced};
end

always @(*) begin
  OSDWrVector    <= {vd_wrctrl_w,vd_wrdata_w};
  APUConfigSet   <= {SysConfigSet3[`cfg3_audio_config_slice],HDMI_cfg_done_o};
  use_igr        <= SysConfigSet1[`igr_reset_enable_bit];
  nRST_Masking_o <= SysConfigSet1[`rst_masks_slice];
end



// Part 2: Controller Sniffing
// ===========================

register_sync #(
  .reg_width(2),
  .reg_preset(2'b00)
) useigr2ctrlclk_u(
  .clk(CTRL_CLK),
  .clk_en(1'b1),
  .nrst(1'b1),
  .reg_i({use_igr,ctrl_data_tack}),
  .reg_o({use_igr_resynced,ctrl_data_tack_resynced})
);

assign ctrl_negedge =  ctrl_hist[2] & !ctrl_hist[1];
assign ctrl_posedge = !ctrl_hist[2] &  ctrl_hist[1];

assign ctrl_bit = ctrl_low_cnt < wait_cnt;



// controller data bits:
//  0: 7 - A, B, Z, St, Du, Dd, Dl, Dr
//  8:15 - 'Joystick reset', (0), L, R, Cu, Cd, Cl, Cr
// 16:23 - X axis
// 24:31 - Y axis
// 32    - Stop bit

always @(posedge CTRL_CLK or negedge CTRL_nRST)
  if (!CTRL_nRST) begin
    rd_state       <= ST_WAIT4N64;
    wait_cnt        <=  8'h0;
    ctrl_hist       <=  3'h7;
    ctrl_low_cnt    <=  8'h0;
    serial_data[2]  <= 32'h0;
    serial_data[1]  <= 32'h0;
    serial_data[0]  <= 32'h0;
    ctrl_data_cnt   <=  5'h0;
    new_ctrl_data   <=  2'b0;
    ctrl_detected   <=  1'b0;
    initiate_nrst   <=  1'b0;
    ctrl_data_tack_resynced_L <= 2'b00;
  end else begin
    case (rd_state)
      ST_WAIT4N64:
        if (&wait_cnt & ctrl_negedge) begin // waiting duration ends (exit wait state only if CTRL was high for a certain duration)
          rd_state       <= ST_N64_RD;
          serial_data[0] <= 32'h0;
          ctrl_data_cnt  <=  5'h0;
        end
      ST_N64_RD: begin
        if (ctrl_posedge)       // sample data part 1
          ctrl_low_cnt <= wait_cnt;
        if (ctrl_negedge) begin // sample data part 2
          if (!ctrl_data_cnt[3]) begin  // eight bits not read yet
            serial_data[0][29:22] <= {ctrl_bit,serial_data[0][29:23]};
            ctrl_data_cnt         <=  ctrl_data_cnt + 1'b1;
          end else if (serial_data[0][29:22] == 8'b10000000) begin // check command
            rd_state       <= ST_CTRL_RD;
            serial_data[0] <= 32'h0;
            ctrl_data_cnt  <=  5'h0;
          end else begin
            rd_state <= ST_WAIT4N64;
          end
        end
      end
      ST_CTRL_RD: begin
        if (ctrl_posedge)       // sample data part 1
          ctrl_low_cnt <= wait_cnt;
        if (ctrl_negedge) begin // sample data part 2
          if (~&ctrl_data_cnt) begin  // still reading
            serial_data[0] <= {ctrl_bit,serial_data[0][31:1]};
            ctrl_data_cnt  <=  ctrl_data_cnt + 1'b1;
          end else begin  // thirtytwo bits read
            rd_state         <= ST_WAIT4N64;
            serial_data[1]   <= {ctrl_bit,serial_data[0][31:1]};
            new_ctrl_data[0] <= 1'b1;  // signalling new controller data available
            ctrl_detected    <= 1'b1;
          end
        end
      end
      default: begin
        rd_state <= ST_WAIT4N64;
      end
    endcase

    if (ctrl_negedge | ctrl_posedge) begin // counter reset
      wait_cnt <= 8'h0;
    end else begin
      if (~&wait_cnt) begin // saturate counter if needed
        wait_cnt <= wait_cnt + 1'b1;
      end else begin        // counter saturated
        if (rd_state == ST_N64_RD)
          ctrl_detected <= 1'b0;
        rd_state <= ST_WAIT4N64;
      end
    end

    ctrl_hist <= {ctrl_hist[1:0],CTRL_i};

    if (new_ctrl_data[0] && new_ctrl_data[0]) begin
      serial_data[2] <= serial_data[1];
      new_ctrl_data  <= 2'b10;
    end
    if (^ctrl_data_tack_resynced_L)
      new_ctrl_data[1] <= 1'b0;
    ctrl_data_tack_resynced_L <= {ctrl_data_tack_resynced_L[0],ctrl_data_tack_resynced};
    
    if (use_igr_resynced & (serial_data[1][15:0] == `IGR_RESET))
      initiate_nrst <= 1'b1;
  end



// Part 3: Trigger Reset on Demand
// ===============================

always @(posedge CTRL_CLK) begin
  if (initiate_nrst == 1'b1) begin
    drv_rst <= 1'b1;      // reset system
    rst_cnt <= 20'hfffff;
  end else if (|rst_cnt) // decrement as long as rst_cnt is not zero
    rst_cnt <= rst_cnt - 1'b1;
  else
    drv_rst <= 1'b0; // end of reset
end

assign N64_nRST_io = drv_rst ? 1'b0 : 1'bz;

endmodule
