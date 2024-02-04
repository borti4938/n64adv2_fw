
%% Preparation
fid = fopen('msx_reg_vals.h','wt');
fprintf(fid,'const unsigned char msx_reg_vals[NUM_SUPPORTED_CONFIGS][NUM_VARIABLE_MSx_REGS] __ufmdata_section__  = {\n');

%% NTSC
filetext = fileread('NTSC_SourceSync_240p-Registers.h');
fprintf(fid,'  {');
for idx = 0:8
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'\n');
fprintf(fid,'   ');
for idx = 9:16
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'0x%c%c },  // NTSC_N64_DIRECT\n',filetext(17*18+8),filetext(17*18+9));

filetext = fileread('NTSC_SourceSync_VGA-Registers.h');
fprintf(fid,'  {');
for idx = 0:8
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'\n');
fprintf(fid,'   ');
for idx = 9:16
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'0x%c%c },  // NTSC_N64_VGA\n',filetext(17*18+8),filetext(17*18+9));

filetext = fileread('NTSC_SourceSync_480p-Registers.h');
fprintf(fid,'  {');
for idx = 0:8
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'\n');
fprintf(fid,'   ');
for idx = 9:16
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'0x%c%c },  // NTSC_N64_480p\n',filetext(17*18+8),filetext(17*18+9));

filetext = fileread('NTSC_SourceSync_720p-Registers.h');
fprintf(fid,'  {');
for idx = 0:8
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'\n');
fprintf(fid,'   ');
for idx = 9:16
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'0x%c%c },  // NTSC_N64_720p\n',filetext(17*18+8),filetext(17*18+9));

filetext = fileread('NTSC_SourceSync_960p-Registers.h');
fprintf(fid,'  {');
for idx = 0:8
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'\n');
fprintf(fid,'   ');
for idx = 9:16
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'0x%c%c },  // NTSC_N64_960p\n',filetext(17*18+8),filetext(17*18+9));

filetext = fileread('NTSC_SourceSync_1080p-Registers.h');
fprintf(fid,'  {');
for idx = 0:8
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'\n');
fprintf(fid,'   ');
for idx = 9:16
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'0x%c%c },  // NTSC_N64_1080p\n',filetext(17*18+8),filetext(17*18+9));

filetext = fileread('NTSC_SourceSync_1200p-Registers.h');
fprintf(fid,'  {');
for idx = 0:8
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'\n');
fprintf(fid,'   ');
for idx = 9:16
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'0x%c%c },  // NTSC_N64_1200p\n',filetext(17*18+8),filetext(17*18+9));

filetext = fileread('NTSC_SourceSync_1440p-Registers.h');
fprintf(fid,'  {');
for idx = 0:8
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'\n');
fprintf(fid,'   ');
for idx = 9:16
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'0x%c%c },  // NTSC_N64_1440p\n',filetext(17*18+8),filetext(17*18+9));

filetext = fileread('NTSC_SourceSync_1440Wp-Registers.h');
fprintf(fid,'  {');
for idx = 0:8
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'\n');
fprintf(fid,'   ');
for idx = 9:16
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'0x%c%c },  // NTSC_N64_1440Wp\n',filetext(17*18+8),filetext(17*18+9));

%% PAL 0

filetext = fileread('PAL0_SourceSync_288p-Registers.h');
fprintf(fid,'  {');
for idx = 0:8
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'\n');
fprintf(fid,'   ');
for idx = 9:16
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'0x%c%c },  // PAL0_N64_DIRECT\n',filetext(17*18+8),filetext(17*18+9));

filetext = fileread('PAL0_SourceSync_VGA-Registers.h');
fprintf(fid,'  {');
for idx = 0:8
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'\n');
fprintf(fid,'   ');
for idx = 9:16
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'0x%c%c },  // PAL0_N64_VGA\n',filetext(17*18+8),filetext(17*18+9));

filetext = fileread('PAL0_SourceSync_576p-Registers.h');
fprintf(fid,'  {');
for idx = 0:8
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'\n');
fprintf(fid,'   ');
for idx = 9:16
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'0x%c%c },  // PAL0_N64_576p\n',filetext(17*18+8),filetext(17*18+9));

filetext = fileread('PAL0_SourceSync_720p-Registers.h');
fprintf(fid,'  {');
for idx = 0:8
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'\n');
fprintf(fid,'   ');
for idx = 9:16
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'0x%c%c },  // PAL0_N64_720p\n',filetext(17*18+8),filetext(17*18+9));

filetext = fileread('PAL0_SourceSync_960p-Registers.h');
fprintf(fid,'  {');
for idx = 0:8
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'\n');
fprintf(fid,'   ');
for idx = 9:16
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'0x%c%c },  // PAL0_N64_960p\n',filetext(17*18+8),filetext(17*18+9));

filetext = fileread('PAL0_SourceSync_1080p-Registers.h');
fprintf(fid,'  {');
for idx = 0:8
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'\n');
fprintf(fid,'   ');
for idx = 9:16
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'0x%c%c },  // PAL0_N64_1080p\n',filetext(17*18+8),filetext(17*18+9));

filetext = fileread('PAL0_SourceSync_1200p-Registers.h');
fprintf(fid,'  {');
for idx = 0:8
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'\n');
fprintf(fid,'   ');
for idx = 9:16
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'0x%c%c },  // PAL0_N64_1200p\n',filetext(17*18+8),filetext(17*18+9));

filetext = fileread('PAL0_SourceSync_1440p-Registers.h');
fprintf(fid,'  {');
for idx = 0:8
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'\n');
fprintf(fid,'   ');
for idx = 9:16
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'0x%c%c },  // PAL0_N64_1440p\n',filetext(17*18+8),filetext(17*18+9));

filetext = fileread('PAL0_SourceSync_1440Wp-Registers.h');
fprintf(fid,'  {');
for idx = 0:8
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'\n');
fprintf(fid,'   ');
for idx = 9:16
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'0x%c%c },  // PAL0_N64_1440Wp\n',filetext(17*18+8),filetext(17*18+9));

%% PAL 1

filetext = fileread('PAL1_SourceSync_288p-Registers.h');
fprintf(fid,'  {');
for idx = 0:8
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'\n');
fprintf(fid,'   ');
for idx = 9:16
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'0x%c%c },  // PAL1_N64_DIRECT\n',filetext(17*18+8),filetext(17*18+9));

filetext = fileread('PAL1_SourceSync_VGA-Registers.h');
fprintf(fid,'  {');
for idx = 0:8
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'\n');
fprintf(fid,'   ');
for idx = 9:16
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'0x%c%c },  // PAL1_N64_VGA\n',filetext(17*18+8),filetext(17*18+9));

filetext = fileread('PAL1_SourceSync_576p-Registers.h');
fprintf(fid,'  {');
for idx = 0:8
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'\n');
fprintf(fid,'   ');
for idx = 9:16
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'0x%c%c },  // PAL1_N64_576p\n',filetext(17*18+8),filetext(17*18+9));

filetext = fileread('PAL1_SourceSync_720p-Registers.h');
fprintf(fid,'  {');
for idx = 0:8
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'\n');
fprintf(fid,'   ');
for idx = 9:16
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'0x%c%c },  // PAL1_N64_720p\n',filetext(17*18+8),filetext(17*18+9));

filetext = fileread('PAL1_SourceSync_960p-Registers.h');
fprintf(fid,'  {');
for idx = 0:8
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'\n');
fprintf(fid,'   ');
for idx = 9:16
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'0x%c%c },  // PAL1_N64_960p\n',filetext(17*18+8),filetext(17*18+9));

filetext = fileread('PAL1_SourceSync_1080p-Registers.h');
fprintf(fid,'  {');
for idx = 0:8
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'\n');
fprintf(fid,'   ');
for idx = 9:16
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'0x%c%c },  // PAL1_N64_1080p\n',filetext(17*18+8),filetext(17*18+9));

filetext = fileread('PAL1_SourceSync_1200p-Registers.h');
fprintf(fid,'  {');
for idx = 0:8
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'\n');
fprintf(fid,'   ');
for idx = 9:16
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'0x%c%c },  // PAL1_N64_1200p\n',filetext(17*18+8),filetext(17*18+9));

filetext = fileread('PAL1_SourceSync_1440p-Registers.h');
fprintf(fid,'  {');
for idx = 0:8
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'\n');
fprintf(fid,'   ');
for idx = 9:16
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'0x%c%c },  // PAL1_N64_1440p\n',filetext(17*18+8),filetext(17*18+9));

filetext = fileread('PAL1_SourceSync_1440Wp-Registers.h');
fprintf(fid,'  {');
for idx = 0:8
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'\n');
fprintf(fid,'   ');
for idx = 9:16
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'0x%c%c },  // PAL1_N64_1440Wp\n',filetext(17*18+8),filetext(17*18+9));

%% Free

filetext = fileread('Uni_VGA60_480p-Registers.h');
fprintf(fid,'  {');
for idx = 0:8
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'\n');
fprintf(fid,'   ');
for idx = 9:16
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'0x%c%c },  // FREE_VGA60_480p\n',filetext(17*18+8),filetext(17*18+9));

filetext = fileread('Uni_VGA50_576p-Registers.h');
fprintf(fid,'  {');
for idx = 0:8
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'\n');
fprintf(fid,'   ');
for idx = 9:16
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'0x%c%c },  // FREE_VGA50_576p\n',filetext(17*18+8),filetext(17*18+9));

filetext = fileread('Uni_720p_960p-Registers.h');
fprintf(fid,'  {');
for idx = 0:8
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'\n');
fprintf(fid,'   ');
for idx = 9:16
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'0x%c%c },  // FREE_720p_960p\n',filetext(17*18+8),filetext(17*18+9));

filetext = fileread('Uni_1080p_1200p-Registers.h');
fprintf(fid,'  {');
for idx = 0:8
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'\n');
fprintf(fid,'   ');
for idx = 9:16
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'0x%c%c },  // FREE_1080p_1200p\n',filetext(17*18+8),filetext(17*18+9));

filetext = fileread('Uni_1440p-Registers.h');
fprintf(fid,'  {');
for idx = 0:8
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'\n');
fprintf(fid,'   ');
for idx = 9:16
  fprintf(fid,'0x%c%c,',filetext(idx*18+8),filetext(idx*18+9));
end
fprintf(fid,'0x%c%c }   // FREE_1440p\n',filetext(17*18+8),filetext(17*18+9));

%% End
fprintf(fid,'};');
fclose(fid);