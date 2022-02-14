//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the N64 RGB/YPbPr DAC project.
//
// Copyright (C) 2015-2022 by Peter Bartmann <borti4938@gmail.com>
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
// Company: Circuit-Board.de
// Engineer: borti4938
//
// V-file Name:    getScanlineProfile.tasks.v
// Project Name:   N64 Advanced Mod
// Target Devices: several devices
// Tool versions:  Altera Quartus Prime
// Description:
//
//////////////////////////////////////////////////////////////////////////////////


task getHannProfile;

  input [5:0] x;
  output [7:0] y;
  
  begin
    case(x)
      6'd0: y <= 8'd1;
      6'd1: y <= 8'd1;
      6'd2: y <= 8'd2;
      6'd3: y <= 8'd4;
      6'd4: y <= 8'd5;
      6'd5: y <= 8'd7;
      6'd6: y <= 8'd9;
      6'd7: y <= 8'd11;
      6'd8: y <= 8'd14;
      6'd9: y <= 8'd17;
      6'd10: y <= 8'd20;
      6'd11: y <= 8'd23;
      6'd12: y <= 8'd27;
      6'd13: y <= 8'd30;
      6'd14: y <= 8'd34;
      6'd15: y <= 8'd39;
      6'd16: y <= 8'd43;
      6'd17: y <= 8'd48;
      6'd18: y <= 8'd52;
      6'd19: y <= 8'd57;
      6'd20: y <= 8'd62;
      6'd21: y <= 8'd67;
      6'd22: y <= 8'd73;
      6'd23: y <= 8'd78;
      6'd24: y <= 8'd84;
      6'd25: y <= 8'd90;
      6'd26: y <= 8'd95;
      6'd27: y <= 8'd101;
      6'd28: y <= 8'd107;
      6'd29: y <= 8'd113;
      6'd30: y <= 8'd119;
      6'd31: y <= 8'd125;
      6'd32: y <= 8'd131;
      6'd33: y <= 8'd137;
      6'd34: y <= 8'd143;
      6'd35: y <= 8'd149;
      6'd36: y <= 8'd155;
      6'd37: y <= 8'd161;
      6'd38: y <= 8'd166;
      6'd39: y <= 8'd172;
      6'd40: y <= 8'd178;
      6'd41: y <= 8'd183;
      6'd42: y <= 8'd189;
      6'd43: y <= 8'd194;
      6'd44: y <= 8'd199;
      6'd45: y <= 8'd204;
      6'd46: y <= 8'd208;
      6'd47: y <= 8'd213;
      6'd48: y <= 8'd217;
      6'd49: y <= 8'd222;
      6'd50: y <= 8'd226;
      6'd51: y <= 8'd229;
      6'd52: y <= 8'd233;
      6'd53: y <= 8'd236;
      6'd54: y <= 8'd239;
      6'd55: y <= 8'd242;
      6'd56: y <= 8'd245;
      6'd57: y <= 8'd247;
      6'd58: y <= 8'd249;
      6'd59: y <= 8'd251;
      6'd60: y <= 8'd252;
      6'd61: y <= 8'd254;
      6'd62: y <= 8'd255;
      default: y <= 8'd255;
    endcase
  end
  
endtask


task getGaussProfile;

  input [5:0] x;
  output [7:0] y;
  
  begin
    case(x)
      6'd0: y <= 8'd1;
      6'd1: y <= 8'd1;
      6'd2: y <= 8'd1;
      6'd3: y <= 8'd1;
      6'd4: y <= 8'd1;
      6'd5: y <= 8'd1;
      6'd6: y <= 8'd2;
      6'd7: y <= 8'd2;
      6'd8: y <= 8'd2;
      6'd9: y <= 8'd3;
      6'd10: y <= 8'd3;
      6'd11: y <= 8'd4;
      6'd12: y <= 8'd4;
      6'd13: y <= 8'd5;
      6'd14: y <= 8'd6;
      6'd15: y <= 8'd7;
      6'd16: y <= 8'd8;
      6'd17: y <= 8'd9;
      6'd18: y <= 8'd10;
      6'd19: y <= 8'd12;
      6'd20: y <= 8'd13;
      6'd21: y <= 8'd15;
      6'd22: y <= 8'd17;
      6'd23: y <= 8'd20;
      6'd24: y <= 8'd22;
      6'd25: y <= 8'd25;
      6'd26: y <= 8'd28;
      6'd27: y <= 8'd32;
      6'd28: y <= 8'd36;
      6'd29: y <= 8'd40;
      6'd30: y <= 8'd44;
      6'd31: y <= 8'd49;
      6'd32: y <= 8'd54;
      6'd33: y <= 8'd59;
      6'd34: y <= 8'd65;
      6'd35: y <= 8'd71;
      6'd36: y <= 8'd78;
      6'd37: y <= 8'd84;
      6'd38: y <= 8'd91;
      6'd39: y <= 8'd99;
      6'd40: y <= 8'd106;
      6'd41: y <= 8'd114;
      6'd42: y <= 8'd122;
      6'd43: y <= 8'd131;
      6'd44: y <= 8'd139;
      6'd45: y <= 8'd148;
      6'd46: y <= 8'd156;
      6'd47: y <= 8'd165;
      6'd48: y <= 8'd173;
      6'd49: y <= 8'd182;
      6'd50: y <= 8'd190;
      6'd51: y <= 8'd198;
      6'd52: y <= 8'd206;
      6'd53: y <= 8'd213;
      6'd54: y <= 8'd220;
      6'd55: y <= 8'd226;
      6'd56: y <= 8'd232;
      6'd57: y <= 8'd238;
      6'd58: y <= 8'd242;
      6'd59: y <= 8'd246;
      6'd60: y <= 8'd250;
      6'd61: y <= 8'd253;
      6'd62: y <= 8'd254;
      default: y <= 8'd255;
    endcase
  end
  
endtask
