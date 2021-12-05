
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


task setVScaleTargets;

  input [`VID_CFG_W-1:0] video_config;
  input [4:0] video_vscale_factor;
  input use_pal_lines;
  output [9:0] target_input_lines_resmax;
  output [10:0] active_target_length;
  
  begin
    case (video_vscale_factor)
      5'h01: begin  // 2.25x
          case (video_config)
            `USE_VGAp60:  target_input_lines_resmax <= 10'd213;
            `USE_480p60:  target_input_lines_resmax <= 10'd213;
            `USE_720p60:  target_input_lines_resmax <= 10'd320;
            `USE_960p60:  target_input_lines_resmax <= 10'd426;
            `USE_1080p60: target_input_lines_resmax <= 10'd480;
            `USE_1200p60: target_input_lines_resmax <= 10'd533;
            `USE_576p50:  target_input_lines_resmax <= 10'd256;
            `USE_720p50:  target_input_lines_resmax <= 10'd320;
            `USE_960p50:  target_input_lines_resmax <= 10'd426;
            `USE_1080p50: target_input_lines_resmax <= 10'd480;
            `USE_1200p50: target_input_lines_resmax <= 10'd533;
            default:      target_input_lines_resmax <= use_pal_lines ? 10'd288 : 10'd240;
          endcase
          active_target_length <= use_pal_lines ? 11'd648 : 11'd540;
        end
      5'h02: begin  // 2.5x
          case (video_config)
            `USE_VGAp60:  target_input_lines_resmax <= 10'd192;
            `USE_480p60:  target_input_lines_resmax <= 10'd192;
            `USE_720p60:  target_input_lines_resmax <= 10'd288;
            `USE_960p60:  target_input_lines_resmax <= 10'd384;
            `USE_1080p60: target_input_lines_resmax <= 10'd432;
            `USE_1200p60: target_input_lines_resmax <= 10'd480;
            `USE_576p50:  target_input_lines_resmax <= 10'd230;
            `USE_720p50:  target_input_lines_resmax <= 10'd288;
            `USE_960p50:  target_input_lines_resmax <= 10'd384;
            `USE_1080p50: target_input_lines_resmax <= 10'd432;
            `USE_1200p50: target_input_lines_resmax <= 10'd480;
            default:      target_input_lines_resmax <= use_pal_lines ? 10'd288 : 10'd240;
          endcase
          active_target_length <= use_pal_lines ? 11'd720 : 11'd600;
        end
      5'h03: begin  // 2.75x
          case (video_config)
            `USE_VGAp60:  target_input_lines_resmax <= 10'd174;
            `USE_480p60:  target_input_lines_resmax <= 10'd174;
            `USE_720p60:  target_input_lines_resmax <= 10'd261;
            `USE_960p60:  target_input_lines_resmax <= 10'd349;
            `USE_1080p60: target_input_lines_resmax <= 10'd392;
            `USE_1200p60: target_input_lines_resmax <= 10'd436;
            `USE_576p50:  target_input_lines_resmax <= 10'd209;
            `USE_720p50:  target_input_lines_resmax <= 10'd261;
            `USE_960p50:  target_input_lines_resmax <= 10'd349;
            `USE_1080p50: target_input_lines_resmax <= 10'd392;
            `USE_1200p50: target_input_lines_resmax <= 10'd436;
            default:      target_input_lines_resmax <= use_pal_lines ? 10'd288 : 10'd240;
          endcase
          active_target_length <= use_pal_lines ? 11'd792 : 11'd660;
        end
      5'h04: begin  // 3.0x
          case (video_config)
            `USE_VGAp60:  target_input_lines_resmax <= 10'd160;
            `USE_480p60:  target_input_lines_resmax <= 10'd160;
            `USE_720p60:  target_input_lines_resmax <= 10'd240;
            `USE_960p60:  target_input_lines_resmax <= 10'd320;
            `USE_1080p60: target_input_lines_resmax <= 10'd360;
            `USE_1200p60: target_input_lines_resmax <= 10'd400;
            `USE_576p50:  target_input_lines_resmax <= 10'd192;
            `USE_720p50:  target_input_lines_resmax <= 10'd240;
            `USE_960p50:  target_input_lines_resmax <= 10'd320;
            `USE_1080p50: target_input_lines_resmax <= 10'd360;
            `USE_1200p50: target_input_lines_resmax <= 10'd400;
            default:      target_input_lines_resmax <= use_pal_lines ? 10'd288 : 10'd240;
          endcase
          active_target_length <= use_pal_lines ? 11'd864 : 11'd720;
        end
      5'h05: begin  // 3.25x
          case (video_config)
            `USE_VGAp60:  target_input_lines_resmax <= 10'd147;
            `USE_480p60:  target_input_lines_resmax <= 10'd147;
            `USE_720p60:  target_input_lines_resmax <= 10'd221;
            `USE_960p60:  target_input_lines_resmax <= 10'd295;
            `USE_1080p60: target_input_lines_resmax <= 10'd332;
            `USE_1200p60: target_input_lines_resmax <= 10'd369;
            `USE_576p50:  target_input_lines_resmax <= 10'd177;
            `USE_720p50:  target_input_lines_resmax <= 10'd221;
            `USE_960p50:  target_input_lines_resmax <= 10'd295;
            `USE_1080p50: target_input_lines_resmax <= 10'd332;
            `USE_1200p50: target_input_lines_resmax <= 10'd369;
            default:      target_input_lines_resmax <= use_pal_lines ? 10'd288 : 10'd240;
          endcase
          active_target_length <= use_pal_lines ? 11'd936 : 11'd780;
        end
      5'h06: begin  // 3.5x
          case (video_config)
            `USE_VGAp60:  target_input_lines_resmax <= 10'd137;
            `USE_480p60:  target_input_lines_resmax <= 10'd137;
            `USE_720p60:  target_input_lines_resmax <= 10'd205;
            `USE_960p60:  target_input_lines_resmax <= 10'd274;
            `USE_1080p60: target_input_lines_resmax <= 10'd308;
            `USE_1200p60: target_input_lines_resmax <= 10'd342;
            `USE_576p50:  target_input_lines_resmax <= 10'd164;
            `USE_720p50:  target_input_lines_resmax <= 10'd205;
            `USE_960p50:  target_input_lines_resmax <= 10'd274;
            `USE_1080p50: target_input_lines_resmax <= 10'd308;
            `USE_1200p50: target_input_lines_resmax <= 10'd342;
            default:      target_input_lines_resmax <= use_pal_lines ? 10'd288 : 10'd240;
          endcase
          active_target_length <= use_pal_lines ? 11'd1008 : 11'd840;
        end
      5'h07: begin  // 3.75x
          case (video_config)
            `USE_VGAp60:  target_input_lines_resmax <= 10'd128;
            `USE_480p60:  target_input_lines_resmax <= 10'd128;
            `USE_720p60:  target_input_lines_resmax <= 10'd192;
            `USE_960p60:  target_input_lines_resmax <= 10'd256;
            `USE_1080p60: target_input_lines_resmax <= 10'd288;
            `USE_1200p60: target_input_lines_resmax <= 10'd320;
            `USE_576p50:  target_input_lines_resmax <= 10'd153;
            `USE_720p50:  target_input_lines_resmax <= 10'd192;
            `USE_960p50:  target_input_lines_resmax <= 10'd256;
            `USE_1080p50: target_input_lines_resmax <= 10'd288;
            `USE_1200p50: target_input_lines_resmax <= 10'd320;
            default:      target_input_lines_resmax <= use_pal_lines ? 10'd288 : 10'd240;
          endcase
          active_target_length <= use_pal_lines ? 11'd1080 : 11'd900;
        end
      5'h08: begin  // 4.0x
          case (video_config)
            `USE_VGAp60:  target_input_lines_resmax <= 10'd120;
            `USE_480p60:  target_input_lines_resmax <= 10'd120;
            `USE_720p60:  target_input_lines_resmax <= 10'd180;
            `USE_960p60:  target_input_lines_resmax <= 10'd240;
            `USE_1080p60: target_input_lines_resmax <= 10'd270;
            `USE_1200p60: target_input_lines_resmax <= 10'd300;
            `USE_576p50:  target_input_lines_resmax <= 10'd144;
            `USE_720p50:  target_input_lines_resmax <= 10'd180;
            `USE_960p50:  target_input_lines_resmax <= 10'd240;
            `USE_1080p50: target_input_lines_resmax <= 10'd270;
            `USE_1200p50: target_input_lines_resmax <= 10'd300;
            default:      target_input_lines_resmax <= use_pal_lines ? 10'd288 : 10'd240;
          endcase
          active_target_length <= use_pal_lines ? 11'd1152 : 11'd960;
        end
      5'h09: begin  // 4.25x
          case (video_config)
            `USE_VGAp60:  target_input_lines_resmax <= 10'd122;
            `USE_480p60:  target_input_lines_resmax <= 10'd122;
            `USE_720p60:  target_input_lines_resmax <= 10'd169;
            `USE_960p60:  target_input_lines_resmax <= 10'd225;
            `USE_1080p60: target_input_lines_resmax <= 10'd254;
            `USE_1200p60: target_input_lines_resmax <= 10'd282;
            `USE_576p50:  target_input_lines_resmax <= 10'd135;
            `USE_720p50:  target_input_lines_resmax <= 10'd169;
            `USE_960p50:  target_input_lines_resmax <= 10'd225;
            `USE_1080p50: target_input_lines_resmax <= 10'd254;
            `USE_1200p50: target_input_lines_resmax <= 10'd282;
            default:      target_input_lines_resmax <= use_pal_lines ? 10'd288 : 10'd240;
          endcase
          active_target_length <= use_pal_lines ? 11'd1200 : 11'd1020; // pal: limited to max vertical output
        end
      5'h0A: begin  // 4.5x
          case (video_config)
            `USE_VGAp60:  target_input_lines_resmax <= 10'd106;
            `USE_480p60:  target_input_lines_resmax <= 10'd106;
            `USE_720p60:  target_input_lines_resmax <= 10'd160;
            `USE_960p60:  target_input_lines_resmax <= 10'd213;
            `USE_1080p60: target_input_lines_resmax <= 10'd240;
            `USE_1200p60: target_input_lines_resmax <= 10'd266;
            `USE_576p50:  target_input_lines_resmax <= 10'd128;
            `USE_720p50:  target_input_lines_resmax <= 10'd160;
            `USE_960p50:  target_input_lines_resmax <= 10'd213;
            `USE_1080p50: target_input_lines_resmax <= 10'd240;
            `USE_1200p50: target_input_lines_resmax <= 10'd266;
            default:      target_input_lines_resmax <= use_pal_lines ? 10'd288 : 10'd240;
          endcase
          active_target_length <= use_pal_lines ? 11'd1200 : 11'd1080; // pal: limited to max vertical output
        end
      5'h0B: begin  // 4.75x
          case (video_config)
            `USE_VGAp60:  target_input_lines_resmax <= 10'd101;
            `USE_480p60:  target_input_lines_resmax <= 10'd101;
            `USE_720p60:  target_input_lines_resmax <= 10'd151;
            `USE_960p60:  target_input_lines_resmax <= 10'd202;
            `USE_1080p60: target_input_lines_resmax <= 10'd227;
            `USE_1200p60: target_input_lines_resmax <= 10'd252;
            `USE_576p50:  target_input_lines_resmax <= 10'd121;
            `USE_720p50:  target_input_lines_resmax <= 10'd151;
            `USE_960p50:  target_input_lines_resmax <= 10'd202;
            `USE_1080p50: target_input_lines_resmax <= 10'd227;
            `USE_1200p50: target_input_lines_resmax <= 10'd252;
            default:      target_input_lines_resmax <= use_pal_lines ? 10'd288 : 10'd240;
          endcase
          active_target_length <= use_pal_lines ? 11'd1200 : 11'd1140; // pal: limited to max vertical output
        end
      5'h0C: begin  // 5.0x
          case (video_config)
            `USE_VGAp60:  target_input_lines_resmax <= 10'd96;
            `USE_480p60:  target_input_lines_resmax <= 10'd96;
            `USE_720p60:  target_input_lines_resmax <= 10'd144;
            `USE_960p60:  target_input_lines_resmax <= 10'd192;
            `USE_1080p60: target_input_lines_resmax <= 10'd216;
            `USE_1200p60: target_input_lines_resmax <= 10'd240;
            `USE_576p50:  target_input_lines_resmax <= 10'd115;
            `USE_720p50:  target_input_lines_resmax <= 10'd144;
            `USE_960p50:  target_input_lines_resmax <= 10'd192;
            `USE_1080p50: target_input_lines_resmax <= 10'd216;
            `USE_1200p50: target_input_lines_resmax <= 10'd240;
            default:      target_input_lines_resmax <= use_pal_lines ? 10'd288 : 10'd240;
          endcase
          active_target_length <= 11'd1200; // pal: limited to max vertical output
        end
      5'h0D: begin  // 5.25x
          case (video_config)
            `USE_VGAp60:  target_input_lines_resmax <= 10'd91;
            `USE_480p60:  target_input_lines_resmax <= 10'd91;
            `USE_720p60:  target_input_lines_resmax <= 10'd137;
            `USE_960p60:  target_input_lines_resmax <= 10'd182;
            `USE_1080p60: target_input_lines_resmax <= 10'd205;
            `USE_1200p60: target_input_lines_resmax <= 10'd228;
            `USE_576p50:  target_input_lines_resmax <= 10'd109;
            `USE_720p50:  target_input_lines_resmax <= 10'd137;
            `USE_960p50:  target_input_lines_resmax <= 10'd182;
            `USE_1080p50: target_input_lines_resmax <= 10'd205;
            `USE_1200p50: target_input_lines_resmax <= 10'd228;
            default:      target_input_lines_resmax <= use_pal_lines ? 10'd288 : 10'd240;
          endcase
          active_target_length <= 11'd1200; // pal: limited to max vertical output
        end
      5'h0E: begin  // 5.5x
          case (video_config)
            `USE_VGAp60:  target_input_lines_resmax <= 10'd87;
            `USE_480p60:  target_input_lines_resmax <= 10'd87;
            `USE_720p60:  target_input_lines_resmax <= 10'd130;
            `USE_960p60:  target_input_lines_resmax <= 10'd174;
            `USE_1080p60: target_input_lines_resmax <= 10'd196;
            `USE_1200p60: target_input_lines_resmax <= 10'd218;
            `USE_576p50:  target_input_lines_resmax <= 10'd104;
            `USE_720p50:  target_input_lines_resmax <= 10'd130;
            `USE_960p50:  target_input_lines_resmax <= 10'd174;
            `USE_1080p50: target_input_lines_resmax <= 10'd196;
            `USE_1200p50: target_input_lines_resmax <= 10'd218;
            default:      target_input_lines_resmax <= use_pal_lines ? 10'd288 : 10'd240;
          endcase
          active_target_length <= 11'd1200; // pal: limited to max vertical output
        end
      5'h0F: begin  // 5.75x
          case (video_config)
            `USE_VGAp60:  target_input_lines_resmax <= 10'd83;
            `USE_480p60:  target_input_lines_resmax <= 10'd83;
            `USE_720p60:  target_input_lines_resmax <= 10'd125;
            `USE_960p60:  target_input_lines_resmax <= 10'd166;
            `USE_1080p60: target_input_lines_resmax <= 10'd187;
            `USE_1200p60: target_input_lines_resmax <= 10'd208;
            `USE_576p50:  target_input_lines_resmax <= 10'd100;
            `USE_720p50:  target_input_lines_resmax <= 10'd125;
            `USE_960p50:  target_input_lines_resmax <= 10'd166;
            `USE_1080p50: target_input_lines_resmax <= 10'd187;
            `USE_1200p50: target_input_lines_resmax <= 10'd208;
            default:      target_input_lines_resmax <= use_pal_lines ? 10'd288 : 10'd240;
          endcase
          active_target_length <= 11'd1200; // pal: limited to max vertical output
        end
      5'h10: begin  // 6.0x
          case (video_config)
            `USE_VGAp60:  target_input_lines_resmax <= 10'd80;
            `USE_480p60:  target_input_lines_resmax <= 10'd80;
            `USE_720p60:  target_input_lines_resmax <= 10'd120;
            `USE_960p60:  target_input_lines_resmax <= 10'd160;
            `USE_1080p60: target_input_lines_resmax <= 10'd180;
            `USE_1200p60: target_input_lines_resmax <= 10'd200;
            `USE_576p50:  target_input_lines_resmax <= 10'd96;
            `USE_720p50:  target_input_lines_resmax <= 10'd120;
            `USE_960p50:  target_input_lines_resmax <= 10'd160;
            `USE_1080p50: target_input_lines_resmax <= 10'd180;
            `USE_1200p50: target_input_lines_resmax <= 10'd200;
            default:      target_input_lines_resmax <= use_pal_lines ? 10'd288 : 10'd240;
          endcase
          active_target_length <= 11'd1200; // pal: limited to max vertical output
        end
      default: begin  // 2.0x
          case (video_config)
            `USE_VGAp60:  target_input_lines_resmax <= 10'd240;
            `USE_480p60:  target_input_lines_resmax <= 10'd240;
            `USE_720p60:  target_input_lines_resmax <= 10'd360;
            `USE_960p60:  target_input_lines_resmax <= 10'd480;
            `USE_1080p60: target_input_lines_resmax <= 10'd540;
            `USE_1200p60: target_input_lines_resmax <= 10'd600;
            `USE_576p50:  target_input_lines_resmax <= 10'd288;
            `USE_720p50:  target_input_lines_resmax <= 10'd360;
            `USE_960p50:  target_input_lines_resmax <= 10'd480;
            `USE_1080p50: target_input_lines_resmax <= 10'd540;
            `USE_1200p50: target_input_lines_resmax <= 10'd600;
            default:      target_input_lines_resmax <= use_pal_lines ? 10'd288 : 10'd240;
          endcase
          active_target_length <= use_pal_lines ? 11'd576 : 11'd480;
        end
    endcase

  end
endtask


task setHScaleTargets;

  input [`VID_CFG_W-1:0] video_config;
  input [4:0] video_hscale_factor;
  output [9:0] target_input_pixel;
  output [11:0] active_target_length;
  
  begin
  
    case (video_hscale_factor)
      5'h01: begin    // 1.125x
          if (video_config == 4'b0000) // VGA
            target_input_pixel <= 10'd569;
          else                              // all others
            target_input_pixel <= 10'd640;
          active_target_length <= 12'd720;
        end
      5'h02: begin    // 1.25x
          if (|video_config[2:1]) // 720p/960p/1080p/1200p
            target_input_pixel <= 10'd640;
          else if (video_config[0]) // 480p/576p
            target_input_pixel <= 10'd576;
          else                        // VGA
            target_input_pixel <= 10'd512;
          active_target_length <= 12'd800;
        end
      5'h03: begin    // 1.375x
          if (|video_config[2:1]) // 720p/960p/1080p/1200p
            target_input_pixel <= 10'd640;
          else if (video_config[0]) // 480p/576p
            target_input_pixel <= 10'd524;
          else                        // VGA
            target_input_pixel <= 10'd465;
          active_target_length <= 12'd880;
        end
      5'h04: begin    // 1.5x
          if (|video_config[2:1]) // 720p/960p/1080p/1200p
            target_input_pixel <= 10'd640;
          else if (video_config[0]) // 480p/576p
            target_input_pixel <= 10'd480;
          else                        // VGA
            target_input_pixel <= 10'd427;
          active_target_length <= 12'd960;
        end
      5'h05: begin    // 1.625x
          if (|video_config[2:1]) // 720p/960p/1080p/1200p
            target_input_pixel <= 10'd640;
          else if (video_config[0]) // 480p/576p
            target_input_pixel <= 10'd443;
          else                        // VGA
            target_input_pixel <= 10'd394;
          active_target_length <= 12'd1040;
        end
      5'h06: begin    // 1.75x
          if (|video_config[2:1]) // 720p/960p/1080p/1200p
            target_input_pixel <= 10'd640;
          else if (video_config[0]) // 480p/576p
            target_input_pixel <= 10'd411;
          else                        // VGA
            target_input_pixel <= 10'd366;
          active_target_length <= 12'd1120;
        end
      5'h07: begin    // 1.875x
          if (|video_config[2:1]) // 720p/960p/1080p/1200p
            target_input_pixel <= 10'd640;
          else if (video_config[0]) // 480p/576p
            target_input_pixel <= 10'd384;
          else                        // VGA
            target_input_pixel <= 10'd341;
          active_target_length <= 12'd1200;
        end
      5'h08: begin    // 2.0x
          if (|video_config[2:1]) // 720p/960p/1080p/1200p
            target_input_pixel <= 10'd640;
          else if (video_config[0]) // 480p/576p
            target_input_pixel <= 10'd360;
          else                        // VGA
            target_input_pixel <= 10'd320;
          active_target_length <= 12'd1280;
        end
      5'h09: begin    // 2.125x
          if (|video_config[2:1]) begin// 720p/960p/1080p/1200p
            if (video_config[2])  // 1080p / 1200p
              target_input_pixel <= 10'd640;
            else                    // 720p / 960p
              target_input_pixel <= 10'd602;
          end else begin
            if (video_config[0])  // 480p/576p
              target_input_pixel <= 10'd339;
            else                    // VGA
              target_input_pixel <= 10'd301;
          end
          active_target_length <= 12'd1360;
        end
      5'h0A: begin    // 2.25x
          if (|video_config[2:1]) begin// 720p/960p/1080p/1200p
            if (video_config[2])  // 1080p / 1200p
              target_input_pixel <= 10'd640;
            else                    // 720p / 960p
              target_input_pixel <= 10'd569;
          end else begin
            if (video_config[0])  // 480p/576p
              target_input_pixel <= 10'd320;
            else                    // VGA
              target_input_pixel <= 10'd284;
          end
          active_target_length <= 12'd1440;
        end
      5'h0B: begin    // 2.375x
          if (|video_config[2:1]) begin// 720p/960p/1080p/1200p
            if (video_config[2])  // 1080p / 1200p
              target_input_pixel <= 10'd640;
            else                    // 720p / 960p
              target_input_pixel <= 10'd539;
          end else begin
            if (video_config[0])  // 480p/576p
              target_input_pixel <= 10'd303;
            else                    // VGA
              target_input_pixel <= 10'd269;
          end
          active_target_length <= 12'd1520;
        end
      5'h0C: begin    // 2.5x
          if (|video_config[2:1]) begin// 720p/960p/1080p/1200p
            if (video_config[2])  // 1080p / 1200p
              target_input_pixel <= 10'd640;
            else                    // 720p / 960p
              target_input_pixel <= 10'd512;
          end else begin
            if (video_config[0])  // 480p/576p
              target_input_pixel <= 10'd288;
            else                    // VGA
              target_input_pixel <= 10'd256;
          end
          active_target_length <= 12'd1600;
        end
      5'h0D: begin    // 2.625x
          if (|video_config[2:1]) begin// 720p/960p/1080p/1200p
            if (video_config[2])  // 1080p / 1200p
              target_input_pixel <= video_config[0] ? 10'd610 : 10'd640;  // 1200p / 1080p
            else                    // 720p / 960p
              target_input_pixel <= 10'd488;
          end else begin
            if (video_config[0])  // 480p/576p
              target_input_pixel <= 10'd274;
            else                    // VGA
              target_input_pixel <= 10'd244;
          end
          active_target_length <= 12'd1680;
        end
      5'h0E: begin    // 2.75x
          if (|video_config[2:1]) begin// 720p/960p/1080p/1200p
            if (video_config[2])  // 1080p / 1200p
              target_input_pixel <= video_config[0] ? 10'd581 : 10'd640;  // 1200p / 1080p
            else                    // 720p / 960p
              target_input_pixel <= 10'd466;
          end else begin
            if (video_config[0])  // 480p/576p
              target_input_pixel <= 10'd262;
            else                    // VGA
              target_input_pixel <= 10'd233;
          end
          active_target_length <= 12'd1760;
        end
      5'h0F: begin    // 2.875x
          if (|video_config[2:1]) begin// 720p/960p/1080p/1200p
            if (video_config[2])  // 1080p / 1200p
              target_input_pixel <= video_config[0] ? 10'd557 : 10'd640;  // 1200p / 1080p
            else                    // 720p / 960p
              target_input_pixel <= 10'd445;
          end else begin
            if (video_config[0])  // 480p/576p
              target_input_pixel <= 10'd250;
            else                    // VGA
              target_input_pixel <= 10'd223;
          end
          active_target_length <= 12'd1840;
        end
      5'h10: begin    // 3.0x
          if (|video_config[2:1]) begin// 720p/960p/1080p/1200p
            if (video_config[2])  // 1080p / 1200p
              target_input_pixel <= video_config[0] ? 10'd533 : 10'd640;  // 1200p / 1080p
            else                    // 720p / 960p
              target_input_pixel <= 10'd427;
          end else begin
            if (video_config[0])  // 480p/576p
              target_input_pixel <= 10'd240;
            else                    // VGA
              target_input_pixel <= 10'd213;
          end
          active_target_length <= 12'd1920;
        end
      5'h11: begin    // 3.125x
          if (|video_config[2:1]) begin// 720p/960p/1080p/1200p
            if (video_config[2])  // 1080p / 1200p
              target_input_pixel <= video_config[0] ? 10'd512 : 10'd614;  // 1200p / 1080p
            else                    // 720p / 960p
              target_input_pixel <= 10'd410;
          end else begin
            if (video_config[0])  // 480p/576p
              target_input_pixel <= 10'd230;
            else                    // VGA
              target_input_pixel <= 10'd205;
          end
          active_target_length <= 12'd1920; // limited to max horizontal output
        end
      5'h12: begin    // 3.25x
          if (|video_config[2:1]) begin// 720p/960p/1080p/1200p
            if (video_config[2])  // 1080p / 1200p
              target_input_pixel <= video_config[0] ? 10'd492 : 10'd591;  // 1200p / 1080p
            else                    // 720p / 960p
              target_input_pixel <= 10'd394;
          end else begin
            if (video_config[0])  // 480p/576p
              target_input_pixel <= 10'd221;
            else                    // VGA
              target_input_pixel <= 10'd197;
          end
          active_target_length <= 12'd1920; // limited to max horizontal output
        end
      5'h13: begin    // 3.375x
          if (|video_config[2:1]) begin// 720p/960p/1080p/1200p
            if (video_config[2])  // 1080p / 1200p
              target_input_pixel <= video_config[0] ? 10'd474 : 10'd569;  // 1200p / 1080p
            else                    // 720p / 960p
              target_input_pixel <= 10'd380;
          end else begin
            if (video_config[0])  // 480p/576p
              target_input_pixel <= 10'd213;
            else                    // VGA
              target_input_pixel <= 10'd190;
          end
          active_target_length <= 12'd1920; // limited to max horizontal output
        end
      5'h14: begin    // 3.5x
          if (|video_config[2:1]) begin// 720p/960p/1080p/1200p
            if (video_config[2])  // 1080p / 1200p
              target_input_pixel <= video_config[0] ? 10'd457 : 10'd548;  // 1200p / 1080p
            else                    // 720p / 960p
              target_input_pixel <= 10'd366;
          end else begin
            if (video_config[0])  // 480p/576p
              target_input_pixel <= 10'd206;
            else                    // VGA
              target_input_pixel <= 10'd183;
          end
          active_target_length <= 12'd1920; // limited to max horizontal output
        end
      default : begin // 1.0x
          target_input_pixel <= 10'd640; // all modes: 640
          active_target_length <= 12'd640;
        end
    endcase
    
  end
endtask
