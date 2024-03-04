%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This file is part of the N64 RGB/YPbPr DAC project.
%
% Copyright (C) 2015-2024 by Peter Bartmann <borti4938@gmail.com>
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
%
% This file was initially created for the OSSC project by marqs.
% For more information about the scanline development there see
% 
%   https://www.videogameperfection.com/forums/topic/hybrid-scanlines/
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all

I = (0:255)/255; % input intensitiy (e.g. RGB, normalized between 0 and 1, assume 8bit word)
sl_str = [0.25 0.5 0.625 0.875 1]; % scanline strengh (also normalized between 0 (no sl) and 1 (100% darkening)


for method = 1 % 0 = initial suggestion by paulb_nl, 1 = new, sl_str independent
               % read VGP forums discussion thread: https://www.videogameperfection.com/forums/topic/hybrid-scanlines/

    if method % hybrid coefficient for sl_str independent method 
              % (normalized to 1, can be overshoot above 1)
%         hc = [0 0.5 0.625 0.875 1 1.25];
%         hc = [1 1.125];
        hc = (0:2:16)*12.5/100;
    else % hybrid coefficient for paulb_nl initial suggestion
%         hc = [0 0.5 0.625 0.875];
        hc = 0.875;
    end
    for idx = 1:length(sl_str)
        for jdx = 1:length(hc)
            Io_sub = zeros(1,256);  % output intensity, sl calculated by subtraction
            Io_mul = zeros(1,256);  % output intensity, sl calculated by multiplication
            for kdx = 1:256
                if method
                    sl_str_cur = (hc(jdx)*I(kdx)<1)*(sl_str(idx)*(1 - hc(jdx)*I(kdx)));
                else
                    sl_str_cur = (sl_str(idx)>hc(jdx)*I(kdx))*(sl_str(idx) - hc(jdx)*I(kdx));
                end
                Io_sub(kdx) = (I(kdx)>sl_str_cur)*(I(kdx) - sl_str_cur);
                Io_mul(kdx) = I(kdx) * (1-sl_str_cur);
            end
            
            figure(100*(method+1)+10*idx+jdx)
            subplot(2,1,1), plot(I,Io_sub,'r',I,Io_mul,'b')
            grid on
            xlabel('I\_in');
            ylabel('I\_out');
            title(['sl\_str=' int2str(floor(sl_str(idx))) '.' int2str((mod(100*sl_str(idx),100))) ', hc=' int2str(floor(hc(jdx))) '.' int2str((mod(100*hc(jdx),100)))])
            xlim([0 1])
            ylim([0 1])
            subplot(2,1,2), plot(I,Io_sub./I,'r',I,Io_mul./I,'b')
            grid on
            xlabel('I\_in');
            ylabel('I\_out/I\_in');
            title(['sl\_str=' int2str(floor(sl_str(idx))) '.' int2str((mod(100*sl_str(idx),100))) ', hc=' int2str(floor(hc(jdx))) '.' int2str((mod(100*hc(jdx),100)))])
            xlim([0 1])
            ylim([0 1])
            
            
            figure(1000+100*(method+1))
            subplot(length(sl_str),length(hc),length(hc)*(idx-1)+jdx), plot(I,Io_sub,'r',I,Io_mul,'b')
            hold on
            grid on
            xlabel('I\_in');
            ylabel('I\_out');
            title(['sl\_str=' int2str(floor(sl_str(idx))) '.' int2str((mod(100*sl_str(idx),100))) ', hc=' int2str(floor(hc(jdx))) '.' int2str((mod(100*hc(jdx),100)))])
            
            figure(2000+100*(method+1))
            subplot(length(sl_str),length(hc),length(hc)*(idx-1)+jdx),  plot(I,Io_sub./I,'r',I,Io_mul./I,'b')
            grid on
            xlabel('I\_in');
            ylabel('I\_out/I\_in');
            title(['sl\_str=' int2str(floor(sl_str(idx))) '.' int2str((mod(100*sl_str(idx),100))) ', hc=' int2str(floor(hc(jdx))) '.' int2str((mod(100*hc(jdx),100)))])
            xlim([0 1])
            ylim([0 1])
        end
    end
end