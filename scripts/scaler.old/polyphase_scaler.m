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
% along with this program.  If not, see <http:/www.gnu.org/licenses/>.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% This script generates some proper loading pattern and bilinear scaling
% factors for a polyphase scaler

%% parameter
pixel_in.num = 240;

scaling = 3.25;
factor_bits = 8;

method = 1; % 0 = nearest neighbor, 1 = bilinear, 2 = lanczos-2

init_phase_two_loads = 1;

print_results = 1;
print_verilog = 1; % needs print_results = 1;

%% calculation stuff

pixel_out.num = floor(pixel_in.num * scaling);
scaling = pixel_out.num/pixel_in.num;

pixel_in.idx= 0:pixel_in.num-1;
pixel_in.pos = (0.5:pixel_in.num)*scaling;
pixel_out.idx= 0:pixel_out.num-1;
pixel_out.pos = 0.5:pixel_out.num;

scaler.load4next_pattern = zeros(1,pixel_out.num-1);
scaler.load_pattern = zeros(1,pixel_out.num);
% scaler.load_pattern2 = zeros(1,pixel_out.num);
scaler.mem_elem = zeros(3,pixel_out.num);
scaler.fir_a = zeros(3,pixel_out.num);


switch method
  case 0
%     current_pos = pixel_in.num/2;
    idx = 1;
    for odx = 1:pixel_out.num
      if (pixel_out.pos(odx) < pixel_in.pos(1))
        scaler.fir_a(1,odx) = 1;
      elseif (pixel_out.pos(odx) > pixel_in.pos(end) || idx == (pixel_in.idx(end) + 1)) 
        scaler.mem_elem(1,odx) = pixel_in.idx(idx);
        % scaler.mem_elem(2,odx) = pixel_in.idx(idx-1);
        scaler.mem_elem(2,odx) = pixel_in.idx(idx);
        scaler.fir_a(1,odx) = 1;
      else
        if abs(pixel_out.pos(odx) - pixel_in.pos(idx)) == abs(pixel_out.pos(odx) - pixel_in.pos(idx+1))
          idx = idx + 1;
          scaler.mem_elem(1,odx) = pixel_in.idx(idx);
          scaler.mem_elem(2,odx) = pixel_in.idx(idx-1);
          % scaler.fir_a(:,odx) = 0.5;
          scaler.fir_a(:,odx) = [1 - abs(pixel_out.pos(odx) - pixel_in.pos(idx))/scaling;1 - abs(pixel_out.pos(odx) - pixel_in.pos(idx-1))/scaling];
          scaler.fir_a(:,odx) = scaler.fir_a(:,odx)./sum(scaler.fir_a(:,odx));
        elseif abs(pixel_out.pos(odx) - pixel_in.pos(idx)) > abs(pixel_out.pos(odx) - pixel_in.pos(idx+1))
          idx = idx + 1;
          scaler.mem_elem(1,odx) = pixel_in.idx(idx);
          scaler.mem_elem(2,odx) = pixel_in.idx(idx-1);
          scaler.fir_a(:,odx) = [1;0];
        else
          if odx == 1
            scaler.mem_elem(:,odx) = [0;0];
          else
            scaler.mem_elem(:,odx) = scaler.mem_elem(:,odx-1);
          end
          scaler.fir_a(:,odx) = [1;0];
        end
      end
%         if odx == 1
%             scaler.load_pattern2(odx) = 1;
%         else
%             if current_pos > pixel_out.num
%                 current_pos = current_pos - pixel_out.num;
%                 scaler.load_pattern2(odx) = 1;
%             end
%             
%         end
%         current_pos = current_pos + pixel_in.num;
    end
    
  case 1
%     current_pos = 3*pixel_out.num/4;
    idx = 1;
    for odx = 1:pixel_out.num
      if (pixel_out.pos(odx) <= pixel_in.pos(1))
        scaler.fir_a(1,odx) = 1;
      elseif (pixel_out.pos(odx) > pixel_in.pos(end))
        scaler.mem_elem(1,odx) = pixel_in.idx(idx);
        % scaler.mem_elem(2,odx) = pixel_in.idx(idx-1);
        scaler.mem_elem(2,odx) = pixel_in.idx(idx);
        scaler.fir_a(1,odx) = 1;
      else
        if (pixel_out.pos(odx) > pixel_in.pos(idx))
          idx = idx + 1;
        end
        scaler.mem_elem(1,odx) = pixel_in.idx(idx);
        scaler.mem_elem(2,odx) = pixel_in.idx(idx-1);
        scaler.fir_a(1:2,odx) = [1 - abs(pixel_out.pos(odx) - pixel_in.pos(idx))/scaling;1 - abs(pixel_out.pos(odx) - pixel_in.pos(idx-1))/scaling];
        scaler.fir_a(1:2,odx) = scaler.fir_a(1:2,odx)./sum(scaler.fir_a(1:2,odx));
      end
%         if odx == 1
%             scaler.load_pattern2(odx) = 1;
%         else
%             if current_pos > pixel_out.num
%                 current_pos = current_pos - pixel_out.num;
%                 scaler.load_pattern2(odx) = 1;
%             end
%             
%         end
%         current_pos = current_pos + pixel_in.num;
    end
  case 2
    for odx = 1:pixel_out.num
        
    end
  otherwise
    error('polyphase_scaler(): method not yet implemented');
end

scaler.load4next_pattern(1:end) = scaler.mem_elem(1,2:end) - scaler.mem_elem(1,1:end-1);
scaler.load4next_pattern(end) = scaler.mem_elem(2,end) - scaler.mem_elem(2,end-1);

scaler.load_pattern(1) = 1;
scaler.load_pattern(2:end-1) = scaler.mem_elem(1,2:end-1) - scaler.mem_elem(1,1:end-2);
scaler.load_pattern(end) = scaler.mem_elem(2,end) - scaler.mem_elem(2,end-1);

scaler.bypass_a0 = zeros(1,pixel_out.num);
scaler.bypass_a0(scaler.fir_a(1,:) == 1) = 1;
scaler.fir_a = round(scaler.fir_a*2^factor_bits);
scaler.fir_a0_char = dec2hex(scaler.fir_a(1,:));
scaler.fir_a1_char = dec2hex(scaler.fir_a(2,:));
scaler.fir_a_increment = mod([scaler.fir_a(:,1) (scaler.fir_a(:,2:end) - scaler.fir_a(:,1:end-1))],2^factor_bits);
scaler.fir_a0_inc_char = dec2hex(scaler.fir_a_increment(1,:));
scaler.fir_a = scaler.fir_a/2^factor_bits;


%% print some results

if (print_results)
  pattern_length = scaling * 8;
  
  cycle = 1;
  while(cycle)
    cycle = 0;
    if (mod(pattern_length,2) == 0)
      pattern_length = pattern_length/2;
      cycle = 1;
    end
    if (pattern_length == scaling)
      cycle = 0;
    end
  end
  if pattern_length == 1
    pattern_length = scaling;
  end
  pattern_start = 2;
  
  cycle = 1;
  while (cycle)
    cycle = 0;
    %   while(~isequal(scaler.load_pattern(pattern_start:pattern_start+pattern_length-1), ...
    %       scaler.load_pattern(pattern_start+pattern_length:pattern_start+2*pattern_length-1)))
    %     pattern_length = pattern_length + 1;
    %     cycle = 1;
    %   end
    while(~isequal(scaler.fir_a0_char(pattern_start:pattern_start+pattern_length-1,2:3), ...
        scaler.fir_a0_char(pattern_start+pattern_length:pattern_start+2*pattern_length-1,2:3)))
      pattern_start = pattern_start + 1;
      cycle = 1;
    end
    if sum(scaler.load_pattern(1:pattern_start-1)) < 2*init_phase_two_loads
      pattern_start = pattern_start + 1;
      cycle = 1;
    end
  end
  
  pattern_length_main = pattern_length
  pattern_start_main = pattern_start
  
  init_load = scaler.load_pattern(1:pattern_start-1)
  init_bypass = scaler.bypass_a0(1:pattern_start-1)
  init_a0 = scaler.fir_a0_char(1:pattern_start-1,2:3)
  
  main_load = ['['];
  main_a0 = ['['];
  for idx= 0:pattern_length-1
    main_load = [main_load int2str(scaler.load_pattern(pattern_start+idx)) ' '];
    main_a0 = [main_a0 scaler.fir_a0_char(pattern_start+idx,2:3) ' '];
  end
  main_load(end) = ']'
  main_bypass = scaler.bypass_a0(pattern_start:pattern_start+pattern_length-1)
  main_a0(end) = ']'
  
  if init_phase_two_loads  % otherwise it does not work
    main_a0_init = scaler.fir_a(1,pattern_start-1)*2^factor_bits
    main_a0_incr = min(scaler.fir_a_increment(1,pattern_start:pattern_start+pattern_length-1))
    main_a0_additional_increment = scaler.fir_a_increment(1,pattern_start:pattern_start+pattern_length-1) - main_a0_incr
    main_a0_additional_increment_bin = '32''b';
    for idx = length(main_a0_additional_increment):-1:1
      main_a0_additional_increment_bin = [main_a0_additional_increment_bin int2str(main_a0_additional_increment(idx))];
    end
    main_a0_additional_increment_bin
    main_a0_init_hex = dec2hex(main_a0_init)
    main_a0_incr_hex = dec2hex(main_a0_incr)
  end
  
%  post_length = sum(scaler.mem_elem(1,pattern_start:end) == scaler.mem_elem(2,pattern_start:end));
  post_length = sum(scaler.mem_elem(1,end-15:end) == scaler.mem_elem(2,end-15:end));
  post_load = scaler.load_pattern(end-post_length+1:end)
  post_bypass = scaler.bypass_a0(end-post_length+1:end)
  
  % check
  
  valid_0a = isequal(scaler.load_pattern(pattern_start:pattern_start+pattern_length-1), ...
    scaler.load_pattern(pattern_start+pattern_length:pattern_start+2*pattern_length-1));
  valid_0b = isequal(scaler.load_pattern(end-pattern_length-post_length+1:end-post_length), ...
    scaler.load_pattern(end-2*pattern_length-post_length+1:end-pattern_length-post_length));
  valid_1a = isequal(scaler.fir_a0_char(pattern_start:pattern_start+pattern_length-1,2:3), ...
    scaler.fir_a0_char(pattern_start+pattern_length:pattern_start+2*pattern_length-1,2:3));
  valid_1b = isequal(scaler.fir_a0_char(end-pattern_length-post_length+1:end-post_length,2:3), ...
    scaler.fir_a0_char(end-2*pattern_length-post_length+1:end-pattern_length-post_length,2:3));
  
  if (print_verilog)
    if (valid_0a && valid_0b && valid_1a && valid_1b)
      verilog_load_pattern_main = int2str(pattern_length);
      verilog_load_pattern_main = [verilog_load_pattern_main '''b'];
      verilog_fir_a0_main = int2str(pattern_length*factor_bits);
      verilog_fir_a0_main = [verilog_fir_a0_main '''h'];
      verilog_fir_a0_bypass_main = int2str(pattern_length);
      verilog_fir_a0_bypass_main = [verilog_fir_a0_bypass_main '''b'];
      for idx= 0:pattern_length-1
        verilog_load_pattern_main = [verilog_load_pattern_main int2str(scaler.load_pattern(pattern_start+pattern_length-1-idx))];
        verilog_fir_a0_main = [verilog_fir_a0_main scaler.fir_a0_char(pattern_start+pattern_length-1-idx,2:3)];
        verilog_fir_a0_bypass_main = [verilog_fir_a0_bypass_main int2str(scaler.bypass_a0(pattern_start+pattern_length-1-idx))];
      end
      verilog_load_pattern_main
      verilog_fir_a0_main
      verilog_fir_a0_bypass_main
    else
      error('polyphase_scaler(): error at valid checks');
    end
  end
end
