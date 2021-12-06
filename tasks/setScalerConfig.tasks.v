
task getVPixels;
  input palmode;
  input [4:0] video_vscale_factor;
  output [11:0] vpixels_out;
  
  begin
    if (palmode)
      case (video_vscale_factor)
        5'h01:    // 2.25x
          vpixels_out <= 12'd648;
        5'h02:    // 2.5x
          vpixels_out <= 12'd720;
        5'h03:    // 2.75x
          vpixels_out <= 12'd792;
        5'h04:    // 3.0x
          vpixels_out <= 12'd864;
        5'h05:    // 3.25x
          vpixels_out <= 12'd936;
        5'h06:    // 3.5x
          vpixels_out <= 12'd1008;
        5'h07:    // 3.75x
          vpixels_out <= 12'd1080;
        5'h08:    // 4.0x
          vpixels_out <= 12'd1152;
        5'h09:    // 4.25x
          vpixels_out <= 12'd1224;
        5'h0A:    // 4.5x
          vpixels_out <= 12'd1296;
        5'h0B:    // 4.75x
          vpixels_out <= 12'd1368;
        5'h0C:    // 5.0x
          vpixels_out <= 12'd1440;
        5'h0D:    // 5.25x
          vpixels_out <= 12'd1512;
        5'h0E:    // 5.5x
          vpixels_out <= 12'd1584;
        5'h0F:    // 5.75x
          vpixels_out <= 12'd1656;
        5'h10:    // 6.0x
          vpixels_out <= 12'd1728;
        default : // 2.0x
          vpixels_out <= 12'd576;
      endcase
    else
      case (video_vscale_factor)
        5'h01:    // 2.25x
          vpixels_out <= 12'd540;
        5'h02:    // 2.5x
          vpixels_out <= 12'd600;
        5'h03:    // 2.75x
          vpixels_out <= 12'd660;
        5'h04:    // 3.0x
          vpixels_out <= 12'd720;
        5'h05:    // 3.25x
          vpixels_out <= 12'd780;
        5'h06:    // 3.5x
          vpixels_out <= 12'd840;
        5'h07:    // 3.75x
          vpixels_out <= 12'd900;
        5'h08:    // 4.0x
          vpixels_out <= 12'd960;
        5'h09:    // 4.25x
          vpixels_out <= 12'd1020;
        5'h0A:    // 4.5x
          vpixels_out <= 12'd1080;
        5'h0B:    // 4.75x
          vpixels_out <= 12'd1140;
        5'h0C:    // 5.0x
          vpixels_out <= 12'd1200;
        5'h0D:    // 5.25x
          vpixels_out <= 12'd1260;
        5'h0E:    // 5.5x
          vpixels_out <= 12'd1320;
        5'h0F:    // 5.75x
          vpixels_out <= 12'd1380;
        5'h10:    // 6.0x
          vpixels_out <= 12'd1440;
        default : // 2.0x
          vpixels_out <= 12'd480;
      endcase
  end
endtask

task getHPixels;
  input [4:0] video_hscale_factor;
  output [11:0] hpixels_out;
  
  begin
    case (video_hscale_factor)
      5'h01:    // 1.125x
        hpixels_out <= 12'd720;
      5'h02:    // 1.25x
        hpixels_out <= 12'd800;
      5'h03:    // 1.375x
        hpixels_out <= 12'd880;
      5'h04:    // 1.5x
        hpixels_out <= 12'd960;
      5'h05:    // 1.625x
        hpixels_out <= 12'd1040;
      5'h06:    // 1.75x
        hpixels_out <= 12'd1120;
      5'h07:    // 1.875x
        hpixels_out <= 12'd1200;
      5'h08:    // 2.0x
        hpixels_out <= 12'd1280;
      5'h09:    // 2.125x
        hpixels_out <= 12'd1360;
      5'h0A:    // 2.25x
        hpixels_out <= 12'd1440;
      5'h0B:    // 2.375x
        hpixels_out <= 12'd1520;
      5'h0C:    // 2.5x
        hpixels_out <= 12'd1600;
      5'h0D:    // 2.625x
        hpixels_out <= 12'd1680;
      5'h0E:    // 2.75x
        hpixels_out <= 12'd1760;
      5'h0F:    // 2.875x
        hpixels_out <= 12'd1840;
      5'h10:    // 3.0x
        hpixels_out <= 12'd1920;
      5'h11:    // 3.125x
        hpixels_out <= 12'd2000;
      5'h12:    // 3.25x
        hpixels_out <= 12'd2080;
      5'h13:    // 3.375x
        hpixels_out <= 12'd2160;
      5'h14:    // 3.5x
        hpixels_out <= 12'd2240;
      default : // 1.0x
        hpixels_out <= 12'd640;
    endcase
  end
endtask
