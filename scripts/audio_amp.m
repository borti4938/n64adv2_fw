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


factor_bits = 8;
factor_frac_bit = 5;

amp_db_range = -19:12;
amp_lin = 10.^(amp_db_range/20);


amp_lin_scaled = amp_lin*2^factor_frac_bit;
amp_lin_scaled_rounded = round(amp_lin_scaled);

amp_bin = zeros(length(amp_lin_scaled_rounded),factor_bits+1);

for idx = 1:length(amp_lin_scaled_rounded)
  amp_lin_scaled_current = amp_lin_scaled_rounded(idx);
  for jdx = 1:factor_bits
    amp_bin(idx,jdx+1) = floor(amp_lin_scaled_current/2^(factor_bits-jdx));
    amp_lin_scaled_current = amp_lin_scaled_current - amp_bin(idx,jdx+1)*2^(factor_bits-jdx);
  end
end

disp('case(input)')
for idx = 1:length(amp_lin_scaled_rounded)
  txt = ['  5''d' int2str(idx-1) ': output <= ' int2str(factor_bits+1) '''b0'];
  for jdx = 1:factor_bits
    txt = [txt int2str(amp_bin(idx,jdx+1))];
  end
  txt = [txt ';'];
  disp(txt);
end
disp('endcase')