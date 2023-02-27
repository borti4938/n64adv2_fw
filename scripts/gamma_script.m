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
% along with this program.  If not, see <http:%www.gnu.org/licenses/>.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bit_width = 7;
max_value = 2^7-1;
rgb_i = 0:max_value;

gamma = [0.75 0.8 0.85 0.9 0.95 1.05 1.1 1.15];   % gamma values
fileName = 'gamma_vals.hex'; % file-name for mem-init
targetFolder = '../ip/';     % target folder for mem-init file

rgb_o = round(((rgb_i.'*ones(1,length(gamma)))/max_value).^...
               (ones(max_value+1,1)*gamma)*max_value);

rgb_o = reshape(rgb_o,1,[]);

intelhex_gen(rgb_o,fileName);

movefile(fileName,[targetFolder fileName]); 