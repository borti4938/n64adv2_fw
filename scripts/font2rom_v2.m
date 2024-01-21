%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This file is part of the N64 RGB/YPbPr DAC project.
%
% Copyright (C) 2015-2023 by Peter Bartmann <borti4938@gmail.com>
%
% N64 RGB/YPbPr DAC is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http:/www.gnu.org/licenses/>.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%#ok<*UNRCH>

fileName = 'font_rom_v2'; % file-name for verilog file (/wo extension)
targetFolder = '../rtl/misc/';   % target folder for rom file

% load_font;
load_reduced_font;
% load_reduced_shifted_font;

separated_cases = 1;
reduce_cases = 1;

fid = fopen([fileName '.v'],'w');

fprintf(fid, ...
  ['//////////////////////////////////////////////////////////////////////////////////\n' ...
   '//\n' ...
   '// This file is part of the N64 RGB/YPbPr DAC project.\n' ...
   '//\n' ...
   '// Copyright (C) 2015-2023 by Peter Bartmann <borti4938@gmail.com>\n' ...
   '//\n' ...
   '// N64 RGB/YPbPr DAC is free software: you can redistribute it and/or modify\n' ...
   '// it under the terms of the GNU General Public License as published by\n' ...
   '// the Free Software Foundation, either version 3 of the License, or\n' ...
   '// any later version.\n' ...
   '//\n' ...
   '// This program is distributed in the hope that it will be useful,\n' ...
   '// but WITHOUT ANY WARRANTY; without even the implied warranty of\n' ...
   '// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n' ...
   '// GNU General Public License for more details.\n' ...
   '//\n' ...
   '// You should have received a copy of the GNU General Public License\n' ...
   '// along with this program.  If not, see <http://www.gnu.org/licenses/>.\n' ...
   '//\n' ...
   '//////////////////////////////////////////////////////////////////////////////////\n' ...
   '//\n' ...
   '// Company:  Circuit-Board.de\n' ...
   '// Engineer: borti4938\n' ...
   '//\n' ...
   '// Module Name:    ' fileName '\n' ...
   '// Project Name:   N64 Advanced RGB/YPbPr DAC Mod\n' ...
   '// Target Devices: Max10, Cyclone IV and Cyclone 10 LP devices\n' ...
   '// Tool versions:  Altera Quartus Prime\n' ...
   '// Description:    simple line-multiplying\n' ...
   '//\n' ...
   '// Features: ip independent implementation of font rom\n' ...
   '//\n' ...
   '// This file is auto generated by script/font2rom.m\n' ...
   '//\n' ...
   '//////////////////////////////////////////////////////////////////////////////////\n' ...
   '\n\n'  ...
   'module ' fileName '(\n' ...
   '  CLK,\n' ...
   '  nRST,\n' ...
   '  char_addr,\n' ...
   '  char_line,\n' ...
   '  rden,\n' ...
   '  rddata\n' ...
   ');' ...
   '\n\n' ...
   'input       CLK;\n' ...
   'input       nRST;\n' ...
   'input [6:0] char_addr;\n' ...
   'input [3:0] char_line;\n' ...
   'input       rden;\n' ...
   '\n' ...
   'output reg [7:0] rddata = 8''h0;\n' ...
   '\n\n' ...
   'reg [7:0] rddata_opt [0:3];\n' ...
   'initial begin\n' ...
   '  rddata_opt[0] = 8''h0;\n' ...
   '  rddata_opt[1] = 8''h0;\n' ...
   '  rddata_opt[2] = 8''h0;\n' ...
   '  rddata_opt[3] = 8''h0;\n' ...
   'end\n' ...
   'reg [1:0] lsb_addr_r = 2''h00;\n' ...
   'reg           rden_r = 1''b0;\n']);

fprintf(fid, ...
  ['\n' ...
   'always @(posedge CLK or negedge nRST)\n' ...
   '  if (!nRST) begin\n' ...
   '    rddata <= 8''h0;\n' ...
   '    rddata_opt[0] <= 8''h0;\n' ...
   '    rddata_opt[1] <= 8''h0;\n' ...
   '    rddata_opt[2] <= 8''h0;\n' ...
   '    rddata_opt[3] <= 8''h0;\n' ...
   '    lsb_addr_r <= 2''h00;\n' ...
   '    rden_r <= 1''b0;\n' ...
   '  end else begin\n' ...
   '    lsb_addr_r <= char_addr[1:0];\n' ...
   '    rden_r <= rden;\n' ...
   '  \n' ...
   '    if (rden) begin\n']);

if (separated_cases == 0)
  fprintf(fid,'      case ({char_line,char_addr[6:2]})\n');
  if (reduce_cases == 0)
    for idx = 0:length(font8x12)/4-1
      fprintf(fid,['        %04d: begin\n' ...
                   '            rddata_opt[0] <= %03d;\n' ...
                   '            rddata_opt[1] <= %03d;\n' ...
                   '            rddata_opt[2] <= %03d;\n' ...
                   '            rddata_opt[3] <= %03d;\n' ...
                   '          end\n'] ...
                   , idx, font8x12(4*idx+1), ...
                          font8x12(4*idx+2), ...
                          font8x12(4*idx+3), ...
                          font8x12(4*idx+4));
    end
    fprintf(fid,['      endcase\n' ...
                 '    end\n']);
  else
    for idx = 0:length(font8x12)/4-1
      if ~isequal(font8x12(4*idx+1:4*idx+4),[0 0 0 0])
        fprintf(fid,['        %04d: begin\n' ...
                     '            rddata_opt[0] <= %03d;\n' ...
                     '            rddata_opt[1] <= %03d;\n' ...
                     '            rddata_opt[2] <= %03d;\n' ...
                     '            rddata_opt[3] <= %03d;\n' ...
                     '          end\n'] ...
                     , idx, font8x12(4*idx+1), ...
                            font8x12(4*idx+2), ...
                            font8x12(4*idx+3), ...
                            font8x12(4*idx+4));
      end
    end
    fprintf(fid,['        default: begin\n' ...
                 '            rddata_opt[0] <= 000;\n' ...
                 '            rddata_opt[1] <= 000;\n' ...
                 '            rddata_opt[2] <= 000;\n' ...
                 '            rddata_opt[3] <= 000;\n' ...
                 '          end\n' ...
                 '      endcase\n' ...
                 '    end\n']);
  end
else
  if (reduce_cases == 0)
    for idx = 0:length(font8x12)/4-1
      fprintf(fid,['        %04d: begin\n' ...
                   '            rddata_opt[0] <= %03d;\n' ...
                   '            rddata_opt[1] <= %03d;\n' ...
                   '            rddata_opt[2] <= %03d;\n' ...
                   '            rddata_opt[3] <= %03d;\n' ...
                   '          end\n'] ...
                   , idx, font8x12(4*idx+1), ...
                          font8x12(4*idx+2), ...
                          font8x12(4*idx+3), ...
                          font8x12(4*idx+4));
    end
  else
    for jdx = 1:4
      fprintf(fid,'      case ({char_line,char_addr[6:2]})\n');
      for idx = 0:length(font8x12)/4-1
        if (font8x12(4*idx+jdx) ~= 0)
          fprintf(fid,'        %04d:    rddata_opt[%d] <= %03d;\n', idx, jdx-1, font8x12(4*idx+jdx));
        end
      end
      if (jdx < 4)
        fprintf(fid,['        default: rddata_opt[%d] <= 000;\n' ...
                     '      endcase\n\n'], jdx-1);
      else
        fprintf(fid,['        default: rddata_opt[%d] <= 000;\n' ...
                     '      endcase\n'], jdx-1);
      end
    end
    fprintf(fid,'    end\n');
  end
end
fprintf(fid, ...
  ['    if (rden_r)\n' ...
   '      rddata <= rddata_opt[lsb_addr_r];\n' ...
   '    end\n' ...
  '\n' ...
  'endmodule\n']);

fclose(fid);
movefile([fileName '.v'],[targetFolder fileName '.v'],'f'); 