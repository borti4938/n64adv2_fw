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

font_width = 12;
font8x12 = reshape(hex2dec([  ...
 '00';'00';'00';'00';'00';'00';'00';'00';'00';'00';'00';'00'; ... 0x00 (empty)
 '00';'00';'00';'00';'00';'00';'00';'00';'00';'FF';'00';'00'; ... 0x01 (long underline)
 '00';'7E';'C3';'81';'A5';'81';'BD';'99';'C3';'7E';'00';'00'; ... 0x02 (smiley)
 '00';'00';'22';'77';'7F';'7F';'7F';'3E';'1C';'08';'00';'00'; ... 0x03 (heart)
 '00';'08';'1C';'3E';'7F';'7F';'3E';'1C';'08';'00';'00';'00'; ... 0x04 (diamond)
 '00';'18';'3C';'3C';'FF';'E7';'E7';'18';'18';'7E';'00';'00'; ... 0x05 (clubs)
 '00';'18';'3C';'7E';'FF';'FF';'7E';'18';'18';'7E';'00';'00'; ... 0x06 (spade)
 '00';'00';'FF';'00';'00';'00';'00';'00';'00';'00';'00';'00'; ... 0x07 (long underline of upper line)
 '00';'00';'FF';'00';'FF';'00';'00';'00';'00';'00';'00';'00'; ... 0x08 (long double underline of upper line)
 '00';'1C';'22';'5D';'55';'5D';'4D';'55';'22';'1C';'00';'00'; ... 0x09 (registered trademark)
 '00';'1C';'22';'5D';'45';'45';'45';'5D';'22';'1C';'00';'00'; ... 0x0A (copyright)
 '00';'7C';'70';'5C';'4E';'1F';'33';'33';'33';'1E';'00';'00'; ... 0x0B (male)
 '00';'3C';'66';'66';'66';'3C';'18';'7E';'18';'18';'00';'00'; ... 0x0C (female)
 '00';'00';'00';'63';'36';'1C';'1C';'36';'63';'00';'00';'00'; ... 0x0D (x mark)
 '00';'FE';'C6';'FE';'C6';'C6';'C6';'E6';'E7';'67';'03';'00'; ... 0x0E (notes)
 '00';'00';'18';'DB';'7E';'E7';'E7';'7E';'DB';'18';'00';'00'; ... 0x0F (sun)
 '00';'40';'60';'70';'7C';'7F';'7C';'70';'60';'40';'00';'00'; ... 0x10 (large triangle left)
 '00';'01';'03';'07';'1F';'7F';'1F';'07';'03';'01';'00';'00'; ... 0x11 (large triangle right)
 '00';'18';'3C';'7E';'18';'18';'18';'7E';'3C';'18';'00';'00'; ... 0x12 (arrow up/down)
 '00';'66';'66';'66';'66';'66';'00';'00';'66';'66';'00';'00'; ... 0x13 (!!)
 '00';'FE';'DB';'DB';'DB';'DE';'D8';'D8';'D8';'D8';'00';'00'; ... 0x14 (new paragraph)
 '00';'7E';'C6';'0C';'3C';'66';'66';'3C';'30';'63';'7E';'00'; ... 0x15 (paragraph sign)
 '00';'00';'00';'00';'00';'00';'00';'7F';'7F';'7F';'00';'00'; ... 0x16 (underline)
 '00';'18';'3C';'7E';'18';'18';'18';'7E';'3C';'18';'7E';'00'; ... 0x17 (arrow up/down with underline)
 '00';'18';'3C';'7E';'18';'18';'18';'18';'18';'18';'00';'00'; ... 0x18 (arrow up)
 '00';'18';'18';'18';'18';'18';'18';'7E';'3C';'18';'00';'00'; ... 0x19 (arrow down)
 '00';'00';'00';'0C';'06';'7F';'06';'0C';'00';'00';'00';'00'; ... 0x1A (arrow left)
 '00';'00';'00';'18';'30';'7F';'30';'18';'00';'00';'00';'00'; ... 0x1B (arrow right)
 '00';'00';'00';'00';'03';'03';'03';'7F';'00';'00';'00';'00'; ... 0x1C (new line)
 '00';'00';'00';'24';'66';'FF';'66';'24';'00';'00';'00';'00'; ... 0x1D (arrow left/right)
 '00';'00';'08';'08';'1C';'1C';'3E';'3E';'7F';'7F';'00';'00'; ... 0x1E (large triangle up)
 '00';'00';'7F';'7F';'3E';'3E';'1C';'1C';'08';'08';'00';'00'; ... 0x1F (triangle down)
 '00';'00';'00';'00';'00';'00';'00';'00';'00';'00';'00';'00'; ... 0x20
 '00';'0C';'1E';'1E';'1E';'0C';'0C';'00';'0C';'0C';'00';'00'; ... 0x21
 '00';'66';'66';'66';'24';'00';'00';'00';'00';'00';'00';'00'; ... 0x22
 '00';'36';'36';'7F';'36';'36';'36';'7F';'36';'36';'00';'00'; ... 0x23
 '0C';'0C';'3E';'03';'03';'1E';'30';'30';'1F';'0C';'0C';'00'; ... 0x24
 '00';'00';'00';'23';'33';'18';'0C';'06';'33';'31';'00';'00'; ... 0x25
 '00';'0E';'1B';'1B';'0E';'5F';'7B';'33';'3B';'6E';'00';'00'; ... 0x26
 '00';'0C';'0C';'0C';'06';'00';'00';'00';'00';'00';'00';'00'; ... 0x27
 '00';'30';'18';'0C';'06';'06';'06';'0C';'18';'30';'00';'00'; ... 0x28
 '00';'06';'0C';'18';'30';'30';'30';'18';'0C';'06';'00';'00'; ... 0x29
 '00';'00';'00';'66';'3C';'FF';'3C';'66';'00';'00';'00';'00'; ... 0x2A
 '00';'00';'00';'18';'18';'7E';'18';'18';'00';'00';'00';'00'; ... 0x2B
 '00';'00';'00';'00';'00';'00';'00';'00';'1C';'1C';'06';'00'; ... 0x2C
 '00';'00';'00';'00';'00';'7F';'00';'00';'00';'00';'00';'00'; ... 0x2D
 '00';'00';'00';'00';'00';'00';'00';'00';'1C';'1C';'00';'00'; ... 0x2E
 '00';'00';'40';'60';'30';'18';'0C';'06';'03';'01';'00';'00'; ... 0x2F
 '00';'3E';'63';'73';'7B';'6B';'6F';'67';'63';'3E';'00';'00'; ... 0x30
 '00';'08';'0C';'0F';'0C';'0C';'0C';'0C';'0C';'3F';'00';'00'; ... 0x31
 '00';'1E';'33';'33';'30';'18';'0C';'06';'33';'3F';'00';'00'; ... 0x32
 '00';'1E';'33';'30';'30';'1C';'30';'30';'33';'1E';'00';'00'; ... 0x33
 '00';'30';'38';'3C';'36';'33';'7F';'30';'30';'78';'00';'00'; ... 0x34
 '00';'3F';'03';'03';'03';'1F';'30';'30';'33';'1E';'00';'00'; ... 0x35
 '00';'1C';'06';'03';'03';'1F';'33';'33';'33';'1E';'00';'00'; ... 0x36
 '00';'7F';'63';'63';'60';'30';'18';'0C';'0C';'0C';'00';'00'; ... 0x37
 '00';'1E';'33';'33';'33';'1E';'33';'33';'33';'1E';'00';'00'; ... 0x38
 '00';'1E';'33';'33';'33';'3E';'18';'18';'0C';'0E';'00';'00'; ... 0x39
 '00';'00';'00';'1C';'1C';'00';'00';'1C';'1C';'00';'00';'00'; ... 0x3A
 '00';'00';'00';'1C';'1C';'00';'00';'1C';'1C';'18';'0C';'00'; ... 0x3B
 '00';'30';'18';'0C';'06';'03';'06';'0C';'18';'30';'00';'00'; ... 0x3C
 '00';'00';'00';'00';'7E';'00';'7E';'00';'00';'00';'00';'00'; ... 0x3D
 '00';'06';'0C';'18';'30';'60';'30';'18';'0C';'06';'00';'00'; ... 0x3E
 '00';'1E';'33';'30';'18';'0C';'0C';'00';'0C';'0C';'00';'00'; ... 0x3F
 '00';'3E';'63';'63';'7B';'7B';'7B';'03';'03';'3E';'00';'00'; ... 0x40
 '00';'0C';'1E';'33';'33';'33';'3F';'33';'33';'33';'00';'00'; ... 0x41
 '00';'3F';'66';'66';'66';'3E';'66';'66';'66';'3F';'00';'00'; ... 0x42
 '00';'3C';'66';'63';'03';'03';'03';'63';'66';'3C';'00';'00'; ... 0x43
 '00';'1F';'36';'66';'66';'66';'66';'66';'36';'1F';'00';'00'; ... 0x44
 '00';'7F';'46';'06';'26';'3E';'26';'06';'46';'7F';'00';'00'; ... 0x45
 '00';'7F';'66';'46';'26';'3E';'26';'06';'06';'0F';'00';'00'; ... 0x46
 '00';'3C';'66';'63';'03';'03';'73';'63';'66';'7C';'00';'00'; ... 0x47
 '00';'33';'33';'33';'33';'3F';'33';'33';'33';'33';'00';'00'; ... 0x48
 '00';'1E';'0C';'0C';'0C';'0C';'0C';'0C';'0C';'1E';'00';'00'; ... 0x49
 '00';'78';'30';'30';'30';'30';'33';'33';'33';'1E';'00';'00'; ... 0x4A
 '00';'67';'66';'36';'36';'1E';'36';'36';'66';'67';'00';'00'; ... 0x4B
 '00';'0F';'06';'06';'06';'06';'46';'66';'66';'7F';'00';'00'; ... 0x4C
 '00';'63';'77';'7F';'7F';'6B';'63';'63';'63';'63';'00';'00'; ... 0x4D
 '00';'63';'63';'67';'6F';'7F';'7B';'73';'63';'63';'00';'00'; ... 0x4E
 '00';'1C';'36';'63';'63';'63';'63';'63';'36';'1C';'00';'00'; ... 0x4F
 '00';'3F';'66';'66';'66';'3E';'06';'06';'06';'0F';'00';'00'; ... 0x50
 '00';'1C';'36';'63';'63';'63';'73';'7B';'3E';'30';'78';'00'; ... 0x51
 '00';'3F';'66';'66';'66';'3E';'36';'66';'66';'67';'00';'00'; ... 0x52
 '00';'1E';'33';'33';'03';'0E';'18';'33';'33';'1E';'00';'00'; ... 0x53
 '00';'3F';'2D';'0C';'0C';'0C';'0C';'0C';'0C';'1E';'00';'00'; ... 0x54
 '00';'33';'33';'33';'33';'33';'33';'33';'33';'1E';'00';'00'; ... 0x55
 '00';'33';'33';'33';'33';'33';'33';'33';'1E';'0C';'00';'00'; ... 0x56
 '00';'63';'63';'63';'63';'6B';'6B';'36';'36';'36';'00';'00'; ... 0x57
 '00';'33';'33';'33';'1E';'0C';'1E';'33';'33';'33';'00';'00'; ... 0x58
 '00';'33';'33';'33';'33';'1E';'0C';'0C';'0C';'1E';'00';'00'; ... 0x59
 '00';'7F';'73';'19';'18';'0C';'06';'46';'63';'7F';'00';'00'; ... 0x5A
 '00';'3C';'0C';'0C';'0C';'0C';'0C';'0C';'0C';'3C';'00';'00'; ... 0x5B
 '00';'00';'01';'03';'06';'0C';'18';'30';'60';'40';'00';'00'; ... 0x5C
 '00';'3C';'30';'30';'30';'30';'30';'30';'30';'3C';'00';'00'; ... 0x5D
 '08';'1C';'36';'63';'00';'00';'00';'00';'00';'00';'00';'00'; ... 0x5E
 '00';'00';'00';'00';'00';'00';'00';'00';'00';'00';'FF';'00'; ... 0x5F
 '0C';'0C';'18';'00';'00';'00';'00';'00';'00';'00';'00';'00'; ... 0x60
 '00';'00';'00';'00';'1E';'30';'3E';'33';'33';'6E';'00';'00'; ... 0x61
 '00';'07';'06';'06';'3E';'66';'66';'66';'66';'3B';'00';'00'; ... 0x62
 '00';'00';'00';'00';'1E';'33';'03';'03';'33';'1E';'00';'00'; ... 0x63
 '00';'38';'30';'30';'3E';'33';'33';'33';'33';'6E';'00';'00'; ... 0x64
 '00';'00';'00';'00';'1E';'33';'3F';'03';'33';'1E';'00';'00'; ... 0x65
 '00';'1C';'36';'06';'06';'1F';'06';'06';'06';'0F';'00';'00'; ... 0x66
 '00';'00';'00';'00';'6E';'33';'33';'33';'3E';'30';'33';'1E'; ... 0x67
 '00';'07';'06';'06';'36';'6E';'66';'66';'66';'67';'00';'00'; ... 0x68
 '00';'18';'18';'00';'1E';'18';'18';'18';'18';'7E';'00';'00'; ... 0x69
 '00';'30';'30';'00';'3C';'30';'30';'30';'30';'33';'33';'1E'; ... 0x6A
 '00';'07';'06';'06';'66';'36';'1E';'36';'66';'67';'00';'00'; ... 0x6B
 '00';'1E';'18';'18';'18';'18';'18';'18';'18';'7E';'00';'00'; ... 0x6C
 '00';'00';'00';'00';'3F';'6B';'6B';'6B';'6B';'63';'00';'00'; ... 0x6D
 '00';'00';'00';'00';'1F';'33';'33';'33';'33';'33';'00';'00'; ... 0x6E
 '00';'00';'00';'00';'1E';'33';'33';'33';'33';'1E';'00';'00'; ... 0x6F
 '00';'00';'00';'00';'3B';'66';'66';'66';'66';'3E';'06';'0F'; ... 0x70
 '00';'00';'00';'00';'6E';'33';'33';'33';'33';'3E';'30';'78'; ... 0x71
 '00';'00';'00';'00';'37';'76';'6E';'06';'06';'0F';'00';'00'; ... 0x72
 '00';'00';'00';'00';'1E';'33';'06';'18';'33';'1E';'00';'00'; ... 0x73
 '00';'00';'04';'06';'3F';'06';'06';'06';'36';'1C';'00';'00'; ... 0x74
 '00';'00';'00';'00';'33';'33';'33';'33';'33';'6E';'00';'00'; ... 0x75
 '00';'00';'00';'00';'33';'33';'33';'33';'1E';'0C';'00';'00'; ... 0x76
 '00';'00';'00';'00';'63';'63';'6B';'6B';'36';'36';'00';'00'; ... 0x77
 '00';'00';'00';'00';'63';'36';'1C';'1C';'36';'63';'00';'00'; ... 0x78
 '00';'00';'00';'00';'66';'66';'66';'66';'3C';'30';'18';'0F'; ... 0x79
 '00';'00';'00';'00';'3F';'31';'18';'06';'23';'3F';'00';'00'; ... 0x7A
 '00';'38';'0C';'0C';'06';'03';'06';'0C';'0C';'38';'00';'00'; ... 0x7B
 '00';'18';'18';'18';'18';'00';'18';'18';'18';'18';'00';'00'; ... 0x7C
 '00';'07';'0C';'0C';'18';'30';'18';'0C';'0C';'07';'00';'00'; ... 0x7D
 '00';'CE';'5B';'73';'00';'00';'00';'00';'00';'00';'00';'00'; ... 0x7E
 '00';'00';'00';'08';'1C';'36';'63';'63';'7F';'00';'00';'00'  ... 0x7F
 ]),font_width,[])';

font8x12 = reshape(font8x12,1,[]);
