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

filename = 'n64_advanced2_header.png';

[X,map,alpha] = imread(filename);
header = double((alpha(:,:,1)-X(:,:,1)) > 0);

size = [1 8; 1 128];

init_val = [];
for row_idx = 1:(size(1,2)-size(1,1)+1)
    for col_idx = 1:4:(size(2,2)-size(2,1)+1)
        value = 0;
        for idx = 0:3
            value = value + header(row_idx,col_idx+idx)*2^idx;
        end
        init_val = [dec2hex(value) init_val]; % reverse order
    end
end
init_val = [int2str(128*8) '''h' init_val];