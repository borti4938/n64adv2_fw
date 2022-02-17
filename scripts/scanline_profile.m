%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This file is part of the N64 RGB/YPbPr DAC project.
%
% Copyright (C) 2015-2022 by Peter Bartmann <borti4938@gmail.com>
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


fractional_bits = 6;
factor_bits = 8;

%% hanning profile

y_hann = hann(2*2^fractional_bits+7);
y_hann = y_hann(3:2^fractional_bits+2);
y_hann = round(y_hann*2^factor_bits);

disp('Hanning profile')
disp('case(x)')
for idx = 1:length(y_hann)
  txt = ['  ' int2str(fractional_bits) '''d' int2str(idx-1) ': y <= ' int2str(factor_bits) '''d' int2str(y_hann(idx)) ';'];
  disp(txt);
end
disp('endcase')

%% Gaussian profile

x_start = -sqrt(2*(factor_bits+1)*log(2)) + 1e-12;
x = linspace(x_start,0,2^fractional_bits+1);
x = x(1:end-1);
y_gauss = exp(-2\x.^2);
y_gauss = round(y_gauss*2^factor_bits);
y_gauss(end) = 2^factor_bits-1;

disp('Gaussian profile')
disp('case(x)')
for idx = 1:length(y_gauss)
  txt = ['  ' int2str(fractional_bits) '''d' int2str(idx-1) ': y <= ' int2str(factor_bits) '''d' int2str(y_gauss(idx)) ';'];
  disp(txt);
end
disp('endcase')