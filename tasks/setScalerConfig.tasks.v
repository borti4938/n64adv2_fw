
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
  output [9:0] target_input_lines;
  output [10:0] active_target_length;
  
  begin
  
    case (video_vscale_factor)
      5'h01: begin  // 2.25x
          if (|video_config[2:1]) begin // 720p/960p/1080p/1200p
            target_input_lines <= 10'd288;  // limited
          end else begin
            if (video_config[`VID_CFG_50HZ_BIT]) // 576p
              target_input_lines <= 10'd256;
            else  // 480p/VGA
              target_input_lines <= 10'd213;
          end
          active_target_length <= use_pal_lines ? 11'd648 : 11'd540;
        end
      5'h02: begin  // 2.5x
          if (|video_config[2:1]) begin // 720p/960p/1080p/1200p
            target_input_lines <= 10'd288;  // limited
          end else begin
            if (video_config[`VID_CFG_50HZ_BIT]) // 576p
              target_input_lines <= 10'd230;
            else  // 480p/VGA
              target_input_lines <= 10'd192;
          end
          active_target_length <= use_pal_lines ? 11'd720 : 11'd600;
        end
      5'h03: begin  // 2.75x
          if (|video_config[2:1]) begin // 720p/960p/1080p/1200p
            if (video_config[2:0] > 3'b010) // above 720p
              target_input_lines <= 10'd288;  // limited
            else
              target_input_lines <= 10'd262;
          end else begin
            if (video_config[`VID_CFG_50HZ_BIT]) // 576p
              target_input_lines <= 10'd209;
            else  // 480p/VGA
              target_input_lines <= 10'd175;
          end
          active_target_length <= use_pal_lines ? 11'd792 : 11'd660;
        end
      5'h04: begin  // 3.0x
          if (|video_config[2:1]) begin // 720p/960p/1080p/1200p
            if (video_config[2:0] > 3'b010) // above 720p
              target_input_lines <= 10'd288;  // limited
            else
              target_input_lines <= 10'd240;
          end else begin
            if (video_config[`VID_CFG_50HZ_BIT]) // 576p
              target_input_lines <= 10'd192;
            else  // 480p/VGA
              target_input_lines <= 10'd160;
          end
          active_target_length <= use_pal_lines ? 11'd864 : 11'd720;
        end
      5'h05: begin  // 3.25x
          if (|video_config[2:1]) begin // 720p/960p/1080p/1200p
            if (video_config[2:0] > 3'b010) // above 720p
              target_input_lines <= 10'd288;  // limited
            else
              target_input_lines <= 10'd222;
          end else begin
            if (video_config[`VID_CFG_50HZ_BIT]) // 576p
              target_input_lines <= 10'd177;
            else  // 480p/VGA
              target_input_lines <= 10'd148;
          end
          active_target_length <= use_pal_lines ? 11'd936 : 11'd780;
        end
      5'h06: begin  // 3.5x
          if (|video_config[2:1]) begin // 720p/960p/1080p/1200p
            if (video_config[2]) // above 960p
              target_input_lines <= 10'd288;  // limited
            else
              target_input_lines <= video_config[0] ? 10'd274 : 10'd206;  // 960p and 720p
          end else begin
            if (video_config[`VID_CFG_50HZ_BIT]) // 576p
              target_input_lines <= 10'd165;
            else  // 480p/VGA
              target_input_lines <= 10'd137;
          end
          active_target_length <= use_pal_lines ? 11'd1008 : 11'd840;
        end
      5'h07: begin  // 3.75x
          if (|video_config[2:1]) begin // 720p/960p/1080p/1200p
            if (video_config[2]) // above 960p
              target_input_lines <= 10'd288;  // limited
            else
              target_input_lines <= video_config[0] ? 10'd256 : 10'd192;  // 960p and 720p
          end else begin
            if (video_config[`VID_CFG_50HZ_BIT]) // 576p
              target_input_lines <= 10'd154;
            else  // 480p/VGA
              target_input_lines <= 10'd128;
          end
          active_target_length <= use_pal_lines ? 11'd1080 : 11'd900;
        end
      5'h08: begin  // 4.0x
          if (|video_config[2:1]) begin // 720p/960p/1080p/1200p
            if (video_config[2])
              target_input_lines <= video_config[0] ? 10'd288 : 10'd270;  // 1200p and 1080p
            else
              target_input_lines <= video_config[0] ? 10'd240 : 10'd180;  // 960p and 720p
          end else begin
            if (video_config[`VID_CFG_50HZ_BIT]) // 576p
              target_input_lines <= 10'd144;
            else  // 480p/VGA
              target_input_lines <= 10'd120;
          end
          active_target_length <= use_pal_lines ? 11'd1152 : 11'd960;
        end
      5'h09: begin  // 4.25x
          if (|video_config[2:1]) begin // 720p/960p/1080p/1200p
            if (video_config[2])
              target_input_lines <= video_config[0] ? 10'd282 : 10'd254;  // 1200p and 1080p
            else
              target_input_lines <= video_config[0] ? 10'd226 : 10'd169;  // 960p and 720p
          end else begin
            if (video_config[`VID_CFG_50HZ_BIT]) // 576p
              target_input_lines <= 10'd136;
            else  // 480p/VGA
              target_input_lines <= 10'd113;
          end
          active_target_length <= use_pal_lines ? 11'd1200 : 11'd1020; // pal: limited to max vertical output
        end
      5'h0A: begin  // 4.5x
          if (|video_config[2:1]) begin // 720p/960p/1080p/1200p
            if (video_config[2])
              target_input_lines <= video_config[0] ? 10'd267 : 10'd240;  // 1200p and 1080p
            else
              target_input_lines <= video_config[0] ? 10'd213 : 10'd160;  // 960p and 720p
          end else begin
            if (video_config[`VID_CFG_50HZ_BIT]) // 576p
              target_input_lines <= 10'd128;
            else  // 480p/VGA
              target_input_lines <= 10'd107;
          end
          active_target_length <= use_pal_lines ? 11'd1200 : 11'd1080; // pal: limited to max vertical output
        end
      5'h0B: begin  // 4.75x
          if (|video_config[2:1]) begin // 720p/960p/1080p/1200p
            if (video_config[2])
              target_input_lines <= video_config[0] ? 10'd253 : 10'd227;  // 1200p and 1080p
            else
              target_input_lines <= video_config[0] ? 10'd202 : 10'd152;  // 960p and 720p
          end else begin
            if (video_config[`VID_CFG_50HZ_BIT]) // 576p
              target_input_lines <= 10'd121;
            else  // 480p/VGA
              target_input_lines <= 10'd101;
          end
          active_target_length <= use_pal_lines ? 11'd1200 : 11'd1140; // pal: limited to max vertical output
        end
      5'h0C: begin  // 5.0x
          if (|video_config[2:1]) begin // 720p/960p/1080p/1200p
            if (video_config[2])
              target_input_lines <= video_config[0] ? 10'd240 : 10'd216;  // 1200p and 1080p
            else
              target_input_lines <= video_config[0] ? 10'd192 : 10'd144;  // 960p and 720p
          end else begin
            if (video_config[`VID_CFG_50HZ_BIT]) // 576p
              target_input_lines <= 10'd115;
            else  // 480p/VGA
              target_input_lines <= 10'd96;
          end
          active_target_length <= 11'd1200; // pal: limited to max vertical output
        end
      5'h0D: begin  // 5.25x
          if (|video_config[2:1]) begin // 720p/960p/1080p/1200p
            if (video_config[2])
              target_input_lines <= video_config[0] ? 10'd228 : 10'd206;  // 1200p and 1080p
            else
              target_input_lines <= video_config[0] ? 10'd183 : 10'd137;  // 960p and 720p
          end else begin
            if (video_config[`VID_CFG_50HZ_BIT]) // 576p
              target_input_lines <= 10'd110;
            else  // 480p/VGA
              target_input_lines <= 10'd91;
          end
          active_target_length <= 11'd1200; // pal: limited to max vertical output
        end
      5'h0E: begin  // 5.5x
          if (|video_config[2:1]) begin // 720p/960p/1080p/1200p
            if (video_config[2])
              target_input_lines <= video_config[0] ? 10'd218 : 10'd196;  // 1200p and 1080p
            else
              target_input_lines <= video_config[0] ? 10'd175 : 10'd131;  // 960p and 720p
          end else begin
            if (video_config[`VID_CFG_50HZ_BIT]) // 576p
              target_input_lines <= 10'd105;
            else  // 480p/VGA
              target_input_lines <= 10'd87;
          end
          active_target_length <= 11'd1200; // pal: limited to max vertical output
        end
      5'h0F: begin  // 5.75x
          if (|video_config[2:1]) begin // 720p/960p/1080p/1200p
            if (video_config[2])
              target_input_lines <= video_config[0] ? 10'd209 : 10'd188;  // 1200p and 1080p
            else
              target_input_lines <= video_config[0] ? 10'd167 : 10'd125;  // 960p and 720p
          end else begin
            if (video_config[`VID_CFG_50HZ_BIT]) // 576p
              target_input_lines <= 10'd100;
            else  // 480p/VGA
              target_input_lines <= 10'd83;
          end
          active_target_length <= 11'd1200; // pal: limited to max vertical output
        end
      5'h10: begin  // 6.0x
          if (|video_config[2:1]) begin // 720p/960p/1080p/1200p
            if (video_config[2])
              target_input_lines <= video_config[0] ? 10'd200 : 10'd180;  // 1200p and 1080p
            else
              target_input_lines <= video_config[0] ? 10'd160 : 10'd120;  // 960p and 720p
          end else begin
            if (video_config[`VID_CFG_50HZ_BIT]) // 576p
              target_input_lines <= 10'd96;
            else  // 480p/VGA
              target_input_lines <= 10'd80;
          end
          active_target_length <= 11'd1200; // pal: limited to max vertical output
        end
      default: begin  // 2.0x
          if (|video_config[2:1]) begin // 720p/960p/1080p/1200p
              target_input_lines <= 10'd288;  // limited
          end else begin
            if (video_config[`VID_CFG_50HZ_BIT]) // 576p
              target_input_lines <= 10'd288;
            else  // 480p/VGA
              target_input_lines <= 10'd240;
          end
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


function [4:0] scale_factor_func;
  input [4:0] scale_factor;
  input half_scale;
  begin
    if (half_scale) begin
      scale_factor_func = scale_factor;
    end else begin
      if (scale_factor < 6)
        scale_factor_func = 2*scale_factor + 5'd8;
      else
        scale_factor_func = scale_factor + 5'd14;
    end
  end
endfunction

task setScalerConstants;

  input [1:0] interpolation_mode;
  input [4:0] scale_factor;
  input half_scale;
  output [2:0] phase_length_init;
  output [5:0] pattern_length_main;
  output [2:0] phase_length_post;
  output [7:0] a0_last_init;
  output z0_last_init;
  output [31:0] load_pattern_main;
  output [7:0] a0_increment;
  output [31:0] a0_round_inc;
  output [31:0] z0_bypass_z0_pattern_main;
  
  reg [4:0] scale_factor_local;
  
  begin
//    if (half_scale) begin
//      scale_factor_local = scale_factor;
//    end else begin
//      if (scale_factor < 6)
//        scale_factor_local = 2*scale_factor + 5'd8;
//      else
//        scale_factor_local = scale_factor + 5'd14;
//    end
    if (interpolation_mode == 2'b00) begin
//      case (scale_factor_local)
      case (scale_factor_func(scale_factor,half_scale))
        1: begin //1.125x
            phase_length_init <= 3'd1;
            pattern_length_main <= 6'd8;
            phase_length_post <= 3'd0;
            a0_last_init <= 8'h80;
            z0_last_init <= 1'b1;
            load_pattern_main <= 32'b111110111;
            a0_increment <= 8'h00;
            a0_round_inc <= 32'b0;
            z0_bypass_z0_pattern_main <= 32'b111111011;
          end
        2: begin //1.250x
            phase_length_init <= 3'd1;
            pattern_length_main <= 6'd4;
            phase_length_post <= 3'd0;
            a0_last_init <= 8'h80;
            z0_last_init <= 1'b1;
            load_pattern_main <= 32'b11101;
            a0_increment <= 8'h00;
            a0_round_inc <= 32'b0;
            z0_bypass_z0_pattern_main <= 32'b11110;
          end
        3: begin //1.375x
            phase_length_init <= 3'd1;
            pattern_length_main <= 6'd10;
            phase_length_post <= 3'd0;
            a0_last_init <= 8'h80;
            z0_last_init <= 1'b1;
            load_pattern_main <= 32'b11101101110;
            a0_increment <= 8'h00;
            a0_round_inc <= 32'b0;
            z0_bypass_z0_pattern_main <= 32'b11111110111;
          end
        4: begin //1.500x
            phase_length_init <= 3'd1;
            pattern_length_main <= 6'd2;
            phase_length_post <= 3'd0;
            a0_last_init <= 8'h80;
            z0_last_init <= 1'b0;
            load_pattern_main <= 32'b110;
            a0_increment <= 8'h00;
            a0_round_inc <= 32'b0;
            z0_bypass_z0_pattern_main <= 32'b011;
          end
        5: begin //1.625x
            phase_length_init <= 3'd2;
            pattern_length_main <= 6'd12;
            phase_length_post <= 3'd0;
            a0_last_init <= 8'h80;
            z0_last_init <= 1'b1;
            load_pattern_main <= 32'b1010110101101;
            a0_increment <= 8'h00;
            a0_round_inc <= 32'b0;
            z0_bypass_z0_pattern_main <= 32'b1111111110111;
          end
        6: begin //1.750x
            phase_length_init <= 3'd2;
            pattern_length_main <= 6'd6;
            phase_length_post <= 3'd0;
            a0_last_init <= 8'h80;
            z0_last_init <= 1'b1;
            load_pattern_main <= 32'b1010101;
            a0_increment <= 8'h00;
            a0_round_inc <= 32'b0;
            z0_bypass_z0_pattern_main <= 32'b1111110;
          end
        7: begin //1.875x
            phase_length_init <= 3'd2;
            pattern_length_main <= 6'd14;
            phase_length_post <= 3'd0;
            a0_last_init <= 8'h80;
            z0_last_init <= 1'b1;
            load_pattern_main <= 32'b101010101011010;
            a0_increment <= 8'h00;
            a0_round_inc <= 32'b0;
            z0_bypass_z0_pattern_main <= 32'b111111111101111;
          end
        8: begin //2.000x
            phase_length_init <= 3'd2;
            pattern_length_main <= 6'd1;
            phase_length_post <= 3'd0;
            a0_last_init <= 8'h80;
            z0_last_init <= 1'b1;
            load_pattern_main <= 32'b10;
            a0_increment <= 8'h00;
            a0_round_inc <= 32'b0;
            z0_bypass_z0_pattern_main <= 32'b11;
          end
        9: begin //2.125x
            phase_length_init <= 3'd2;
            pattern_length_main <= 6'd16;
            phase_length_post <= 3'd0;
            a0_last_init <= 8'h80;
            z0_last_init <= 1'b1;
            load_pattern_main <= 32'b10101010100101010;
            a0_increment <= 8'h00;
            a0_round_inc <= 32'b0;
            z0_bypass_z0_pattern_main <= 32'b11111111111011111;
          end
        10: begin //2.250x
            phase_length_init <= 3'd2;
            pattern_length_main <= 6'd8;
            phase_length_post <= 3'd0;
            a0_last_init <= 8'h80;
            z0_last_init <= 1'b1;
            load_pattern_main <= 32'b101010010;
            a0_increment <= 8'h00;
            a0_round_inc <= 32'b0;
            z0_bypass_z0_pattern_main <= 32'b111111101;
          end
        11: begin //2.375x
            phase_length_init <= 3'd2;
            pattern_length_main <= 6'd18;
            phase_length_post <= 3'd0;
            a0_last_init <= 8'h80;
            z0_last_init <= 1'b1;
            load_pattern_main <= 32'b1010100101001010100;
            a0_increment <= 8'h00;
            a0_round_inc <= 32'b0;
            z0_bypass_z0_pattern_main <= 32'b1111111111110111111;
          end
        12: begin //2.500x
            phase_length_init <= 3'd2;
            pattern_length_main <= 6'd4;
            phase_length_post <= 3'd1;
            a0_last_init <= 8'h80;
            z0_last_init <= 1'b0;
            load_pattern_main <= 32'b10100;
            a0_increment <= 8'h00;
            a0_round_inc <= 32'b0;
            z0_bypass_z0_pattern_main <= 32'b01111;
          end
        13: begin //2.625x
            phase_length_init <= 3'd3;
            pattern_length_main <= 6'd20;
            phase_length_post <= 3'd1;
            a0_last_init <= 8'h80;
            z0_last_init <= 1'b1;
            load_pattern_main <= 32'b100100101001001010010;
            a0_increment <= 8'h00;
            a0_round_inc <= 32'b0;
            z0_bypass_z0_pattern_main <= 32'b111111111111110111111;
          end
        14: begin //2.750x
            phase_length_init <= 3'd3;
            pattern_length_main <= 6'd10;
            phase_length_post <= 3'd1;
            a0_last_init <= 8'h80;
            z0_last_init <= 1'b1;
            load_pattern_main <= 32'b10010010010;
            a0_increment <= 8'h00;
            a0_round_inc <= 32'b0;
            z0_bypass_z0_pattern_main <= 32'b11111111101;
          end
        15: begin //2.875x
            phase_length_init <= 3'd3;
            pattern_length_main <= 6'd22;
            phase_length_post <= 3'd1;
            a0_last_init <= 8'h80;
            z0_last_init <= 1'b1;
            load_pattern_main <= 32'b10010010010010010100100;
            a0_increment <= 8'h00;
            a0_round_inc <= 32'b0;
            z0_bypass_z0_pattern_main <= 32'b11111111111111101111111;
          end
        16: begin //3.000x
            phase_length_init <= 3'd3;
            pattern_length_main <= 6'd2;
            phase_length_post <= 3'd1;
            a0_last_init <= 8'h80;
            z0_last_init <= 1'b1;
            load_pattern_main <= 32'b100;
            a0_increment <= 8'h00;
            a0_round_inc <= 32'b0;
            z0_bypass_z0_pattern_main <= 32'b111;
          end
        17: begin //3.125x
            phase_length_init <= 3'd3;
            pattern_length_main <= 6'd24;
            phase_length_post <= 3'd1;
            a0_last_init <= 8'h80;
            z0_last_init <= 1'b1;
            load_pattern_main <= 32'b1001001001001000100100100;
            a0_increment <= 8'h00;
            a0_round_inc <= 32'b0;
            z0_bypass_z0_pattern_main <= 32'b1111111111111111011111111;
          end
        18: begin //3.250x
            phase_length_init <= 3'd3;
            pattern_length_main <= 6'd12;
            phase_length_post <= 3'd1;
            a0_last_init <= 8'h80;
            z0_last_init <= 1'b1;
            load_pattern_main <= 32'b1001001000100;
            a0_increment <= 8'h00;
            a0_round_inc <= 32'b0;
            z0_bypass_z0_pattern_main <= 32'b1111111111011;
          end
        19: begin //3.375x
            phase_length_init <= 3'd3;
            pattern_length_main <= 6'd26;
            phase_length_post <= 3'd1;
            a0_last_init <= 8'h80;
            z0_last_init <= 1'b1;
            load_pattern_main <= 32'b100100100010010001001001000;
            a0_increment <= 8'h00;
            a0_round_inc <= 32'b0;
            z0_bypass_z0_pattern_main <= 32'b111111111111111110111111111;
          end
        20: begin //3.500x
            phase_length_init <= 3'd3;
            pattern_length_main <= 6'd6;
            phase_length_post <= 3'd2;
            a0_last_init <= 8'h80;
            z0_last_init <= 1'b0;
            load_pattern_main <= 32'b1001000;
            a0_increment <= 8'h00;
            a0_round_inc <= 32'b0;
            z0_bypass_z0_pattern_main <= 32'b0111111;
          end
        21: begin //3.750x
            phase_length_init <= 3'd4;
            pattern_length_main <= 6'd14;
            phase_length_post <= 3'd2;
            a0_last_init <= 8'h80;
            z0_last_init <= 1'b1;
            load_pattern_main <= 32'b100010001000100;
            a0_increment <= 8'h00;
            a0_round_inc <= 32'b0;
            z0_bypass_z0_pattern_main <= 32'b111111111111011;
          end
        22: begin //4.000x
            phase_length_init <= 3'd4;
            pattern_length_main <= 6'd3;
            phase_length_post <= 3'd2;
            a0_last_init <= 8'h80;
            z0_last_init <= 1'b1;
            load_pattern_main <= 32'b1000;
            a0_increment <= 8'h00;
            a0_round_inc <= 32'b0;
            z0_bypass_z0_pattern_main <= 32'b1111;
          end
        23: begin //4.250x
            phase_length_init <= 3'd4;
            pattern_length_main <= 6'd16;
            phase_length_post <= 3'd2;
            a0_last_init <= 8'h80;
            z0_last_init <= 1'b1;
            load_pattern_main <= 32'b10001000100001000;
            a0_increment <= 8'h00;
            a0_round_inc <= 32'b0;
            z0_bypass_z0_pattern_main <= 32'b11111111111110111;
          end
        24: begin //4.500x
            phase_length_init <= 3'd4;
            pattern_length_main <= 6'd8;
            phase_length_post <= 3'd3;
            a0_last_init <= 8'h80;
            z0_last_init <= 1'b0;
            load_pattern_main <= 32'b100010000;
            a0_increment <= 8'h00;
            a0_round_inc <= 32'b0;
            z0_bypass_z0_pattern_main <= 32'b011111111;
          end
        25: begin //4.750x
            phase_length_init <= 3'd5;
            pattern_length_main <= 6'd18;
            phase_length_post <= 3'd3;
            a0_last_init <= 8'h80;
            z0_last_init <= 1'b1;
            load_pattern_main <= 32'b1000010000100001000;
            a0_increment <= 8'h00;
            a0_round_inc <= 32'b0;
            z0_bypass_z0_pattern_main <= 32'b1111111111111110111;
          end
        26: begin //5.000x
            phase_length_init <= 3'd5;
            pattern_length_main <= 6'd4;
            phase_length_post <= 3'd3;
            a0_last_init <= 8'h80;
            z0_last_init <= 1'b1;
            load_pattern_main <= 32'b10000;
            a0_increment <= 8'h00;
            a0_round_inc <= 32'b0;
            z0_bypass_z0_pattern_main <= 32'b11111;
          end
        27: begin //5.250x
            phase_length_init <= 3'd5;
            pattern_length_main <= 6'd20;
            phase_length_post <= 3'd3;
            a0_last_init <= 8'h80;
            z0_last_init <= 1'b1;
            load_pattern_main <= 32'b100001000010000010000;
            a0_increment <= 8'h00;
            a0_round_inc <= 32'b0;
            z0_bypass_z0_pattern_main <= 32'b111111111111111101111;
          end
        28: begin //5.500x
            phase_length_init <= 3'd5;
            pattern_length_main <= 6'd10;
            phase_length_post <= 3'd4;
            a0_last_init <= 8'h80;
            z0_last_init <= 1'b0;
            load_pattern_main <= 32'b10000100000;
            a0_increment <= 8'h00;
            a0_round_inc <= 32'b0;
            z0_bypass_z0_pattern_main <= 32'b01111111111;
          end
        29: begin //5.750x
            phase_length_init <= 3'd6;
            pattern_length_main <= 6'd22;
            phase_length_post <= 3'd4;
            a0_last_init <= 8'h80;
            z0_last_init <= 1'b1;
            load_pattern_main <= 32'b10000010000010000010000;
            a0_increment <= 8'h00;
            a0_round_inc <= 32'b0;
            z0_bypass_z0_pattern_main <= 32'b11111111111111111101111;
          end
        30: begin //6.000x
            phase_length_init <= 3'd6;
            pattern_length_main <= 6'd5;
            phase_length_post <= 3'd4;
            a0_last_init <= 8'h80;
            z0_last_init <= 1'b1;
            load_pattern_main <= 32'b100000;
            a0_increment <= 8'h00;
            a0_round_inc <= 32'b0;
            z0_bypass_z0_pattern_main <= 32'b111111;
          end
        default: begin //1.000x
            phase_length_init <= 3'd1;
            pattern_length_main <= 6'd0;
            phase_length_post <= 3'd0;
            a0_last_init <= 8'h80;
            z0_last_init <= 1'b1;
            load_pattern_main <= 32'b1;
            a0_increment <= 8'h00;
            a0_round_inc <= 32'b0;
            z0_bypass_z0_pattern_main <= 32'b1;
          end
      endcase
    end else begin
//      case (scale_factor_local)
      case (scale_factor_func(scale_factor,half_scale))
        1: begin //1.125x
            phase_length_init <= 3'd1;
            pattern_length_main <= 6'd8;
            phase_length_post <= 3'd0;
            a0_last_init <= 8'hD5;
            z0_last_init <= 1'b0;
            load_pattern_main <= 32'b101111111;
            a0_increment <= 8'hE3;
            a0_round_inc <= 32'b010101101;
            z0_bypass_z0_pattern_main <= 32'b000000000;
          end
        2: begin //1.250x
            phase_length_init <= 3'd1;
            pattern_length_main <= 6'd4;
            phase_length_post <= 3'd0;
            a0_last_init <= 8'hB3;
            z0_last_init <= 1'b0;
            load_pattern_main <= 32'b10111;
            a0_increment <= 8'hCC;
            a0_round_inc <= 32'b10111;
            z0_bypass_z0_pattern_main <= 32'b00000;
          end
        3: begin //1.375x
            phase_length_init <= 3'd1;
            pattern_length_main <= 6'd10;
            phase_length_post <= 3'd0;
            a0_last_init <= 8'h97;
            z0_last_init <= 1'b0;
            load_pattern_main <= 32'b10111011011;
            a0_increment <= 8'hBA;
            a0_round_inc <= 32'b00001000010;
            z0_bypass_z0_pattern_main <= 32'b00000000000;
          end
        4: begin //1.500x
            phase_length_init <= 3'd1;
            pattern_length_main <= 6'd2;
            phase_length_post <= 3'd0;
            a0_last_init <= 8'h80;
            z0_last_init <= 1'b0;
            load_pattern_main <= 32'b101;
            a0_increment <= 8'hAA;
            a0_round_inc <= 32'b101;
            z0_bypass_z0_pattern_main <= 32'b000;
          end
        5: begin //1.625x
            phase_length_init <= 3'd1;
            pattern_length_main <= 6'd12;
            phase_length_post <= 3'd0;
            a0_last_init <= 8'h6C;
            z0_last_init <= 1'b0;
            load_pattern_main <= 32'b1011010110101;
            a0_increment <= 8'h9D;
            a0_round_inc <= 32'b0101010110101;
            z0_bypass_z0_pattern_main <= 32'b0000000000000;
          end
        6: begin //1.750x
            phase_length_init <= 3'd1;
            pattern_length_main <= 6'd6;
            phase_length_post <= 3'd0;
            a0_last_init <= 8'h5B;
            z0_last_init <= 1'b0;
            load_pattern_main <= 32'b1010110;
            a0_increment <= 8'h92;
            a0_round_inc <= 32'b0001001;
            z0_bypass_z0_pattern_main <= 32'b0000000;
          end
        7: begin //1.875x
            phase_length_init <= 3'd1;
            pattern_length_main <= 6'd14;
            phase_length_post <= 3'd0;
            a0_last_init <= 8'h4D;
            z0_last_init <= 1'b0;
            load_pattern_main <= 32'b101010101101010;
            a0_increment <= 8'h88;
            a0_round_inc <= 32'b101010101101010;
            z0_bypass_z0_pattern_main <= 32'b000000000000000;
          end
        8: begin //2.000x
            phase_length_init <= 3'd1;
            pattern_length_main <= 6'd1;
            phase_length_post <= 3'd0;
            a0_last_init <= 8'h40;
            z0_last_init <= 1'b0;
            load_pattern_main <= 32'b10;
            a0_increment <= 8'h80;
            a0_round_inc <= 32'b00;
            z0_bypass_z0_pattern_main <= 32'b00;
          end
        9: begin //2.125x
            phase_length_init <= 3'd1;
            pattern_length_main <= 6'd16;
            phase_length_post <= 3'd0;
            a0_last_init <= 8'h35;
            z0_last_init <= 1'b0;
            load_pattern_main <= 32'b10101010100101010;
            a0_increment <= 8'h78;
            a0_round_inc <= 32'b10101010100101010;
            z0_bypass_z0_pattern_main <= 32'b00000000000000000;
          end
        10: begin //2.250x
            phase_length_init <= 3'd1;
            pattern_length_main <= 6'd8;
            phase_length_post <= 3'd0;
            a0_last_init <= 8'h2B;
            z0_last_init <= 1'b0;
            load_pattern_main <= 32'b101010010;
            a0_increment <= 8'h71;
            a0_round_inc <= 32'b111011110;
            z0_bypass_z0_pattern_main <= 32'b000000000;
          end
        11: begin //2.375x
            phase_length_init <= 3'd1;
            pattern_length_main <= 6'd18;
            phase_length_post <= 3'd0;
            a0_last_init <= 8'h22;
            z0_last_init <= 1'b0;
            load_pattern_main <= 32'b1010010101001010100;
            a0_increment <= 8'h6B;
            a0_round_inc <= 32'b1110111101111011110;
            z0_bypass_z0_pattern_main <= 32'b0000000000000000000;
          end
        12: begin //2.500x
            phase_length_init <= 3'd1;
            pattern_length_main <= 6'd4;
            phase_length_post <= 3'd0;
            a0_last_init <= 8'h1A;
            z0_last_init <= 1'b0;
            load_pattern_main <= 32'b10100;
            a0_increment <= 8'h66;
            a0_round_inc <= 32'b10100;
            z0_bypass_z0_pattern_main <= 32'b00000;
          end
        13: begin //2.625x
            phase_length_init <= 3'd1;
            pattern_length_main <= 6'd20;
            phase_length_post <= 3'd0;
            a0_last_init <= 8'h12;
            z0_last_init <= 1'b0;
            load_pattern_main <= 32'b101001001010010100100;
            a0_increment <= 8'h61;
            a0_round_inc <= 32'b010101010101101010101;
            z0_bypass_z0_pattern_main <= 32'b000000000000000000000;
          end
        14: begin //2.750x
            phase_length_init <= 3'd1;
            pattern_length_main <= 6'd10;
            phase_length_post <= 3'd0;
            a0_last_init <= 8'hC;
            z0_last_init <= 1'b0;
            load_pattern_main <= 32'b10100100100;
            a0_increment <= 8'h5D;
            a0_round_inc <= 32'b01000000000;
            z0_bypass_z0_pattern_main <= 32'b00000000000;
          end
        15: begin //2.875x
            phase_length_init <= 3'd1;
            pattern_length_main <= 6'd22;
            phase_length_post <= 3'd0;
            a0_last_init <= 8'h6;
            z0_last_init <= 1'b0;
            load_pattern_main <= 32'b10100100100100100100100;
            a0_increment <= 8'h59;
            a0_round_inc <= 32'b01000000000000000000000;
            z0_bypass_z0_pattern_main <= 32'b00000000000000000000000;
          end
        16: begin //3.000x
            phase_length_init <= 3'd2;
            pattern_length_main <= 6'd2;
            phase_length_post <= 3'd0;
            a0_last_init <= 8'h55;
            z0_last_init <= 1'b0;
            load_pattern_main <= 32'b100;
            a0_increment <= 8'h55;
            a0_round_inc <= 32'b001;
            z0_bypass_z0_pattern_main <= 32'b010;
          end
        17: begin //3.125x
            phase_length_init <= 3'd2;
            pattern_length_main <= 6'd24;
            phase_length_post <= 3'd1;
            a0_last_init <= 8'h4D;
            z0_last_init <= 1'b0;
            load_pattern_main <= 32'b1000100100100100100100100;
            a0_increment <= 8'h51;
            a0_round_inc <= 32'b1111111101111111111110111;
            z0_bypass_z0_pattern_main <= 32'b0000000000000000000000000;
          end
        18: begin //3.250x
            phase_length_init <= 3'd2;
            pattern_length_main <= 6'd12;
            phase_length_post <= 3'd1;
            a0_last_init <= 8'h45;
            z0_last_init <= 1'b0;
            load_pattern_main <= 32'b1000100100100;
            a0_increment <= 8'h4E;
            a0_round_inc <= 32'b1101110111101;
            z0_bypass_z0_pattern_main <= 32'b0000000000000;
          end
        19: begin //3.375x
            phase_length_init <= 3'd2;
            pattern_length_main <= 6'd26;
            phase_length_post <= 3'd1;
            a0_last_init <= 8'h3E;
            z0_last_init <= 1'b0;
            load_pattern_main <= 32'b100010010010001001000100100;
            a0_increment <= 8'h4B;
            a0_round_inc <= 32'b111110111111011111101111110;
            z0_bypass_z0_pattern_main <= 32'b000000000000000000000000000;
          end
        20: begin //3.500x
            phase_length_init <= 3'd2;
            pattern_length_main <= 6'd6;
            phase_length_post <= 3'd1;
            a0_last_init <= 8'h37;
            z0_last_init <= 1'b0;
            load_pattern_main <= 32'b1000100;
            a0_increment <= 8'h49;
            a0_round_inc <= 32'b0010000;
            z0_bypass_z0_pattern_main <= 32'b0000000;
          end
        21: begin //3.750x
            phase_length_init <= 3'd2;
            pattern_length_main <= 6'd14;
            phase_length_post <= 3'd1;
            a0_last_init <= 8'h2B;
            z0_last_init <= 1'b0;
            load_pattern_main <= 32'b100010001001000;
            a0_increment <= 8'h44;
            a0_round_inc <= 32'b100010001001000;
            z0_bypass_z0_pattern_main <= 32'b000000000000000;
          end
        22: begin //4.000x
            phase_length_init <= 3'd2;
            pattern_length_main <= 6'd3;
            phase_length_post <= 3'd1;
            a0_last_init <= 8'h20;
            z0_last_init <= 1'b0;
            load_pattern_main <= 32'b1000;
            a0_increment <= 8'h40;
            a0_round_inc <= 32'b0000;
            z0_bypass_z0_pattern_main <= 32'b0000;
          end
        23: begin //4.250x
            phase_length_init <= 3'd2;
            pattern_length_main <= 6'd16;
            phase_length_post <= 3'd1;
            a0_last_init <= 8'h17;
            z0_last_init <= 1'b0;
            load_pattern_main <= 32'b10001000100001000;
            a0_increment <= 8'h3C;
            a0_round_inc <= 32'b10001000100001000;
            z0_bypass_z0_pattern_main <= 32'b00000000000000000;
          end
        24: begin //4.500x
            phase_length_init <= 3'd2;
            pattern_length_main <= 6'd8;
            phase_length_post <= 3'd1;
            a0_last_init <= 8'hE;
            z0_last_init <= 1'b0;
            load_pattern_main <= 32'b100010000;
            a0_increment <= 8'h38;
            a0_round_inc <= 32'b110111111;
            z0_bypass_z0_pattern_main <= 32'b000000000;
          end
        25: begin //4.750x
            phase_length_init <= 3'd2;
            pattern_length_main <= 6'd18;
            phase_length_post <= 3'd1;
            a0_last_init <= 8'h7;
            z0_last_init <= 1'b0;
            load_pattern_main <= 32'b1000100001000010000;
            a0_increment <= 8'h35;
            a0_round_inc <= 32'b1111111011111111011;
            z0_bypass_z0_pattern_main <= 32'b0000000000000000000;
          end
        26: begin //5.000x
            phase_length_init <= 3'd3;
            pattern_length_main <= 6'd4;
            phase_length_post <= 3'd1;
            a0_last_init <= 8'h33;
            z0_last_init <= 1'b0;
            load_pattern_main <= 32'b10000;
            a0_increment <= 8'h33;
            a0_round_inc <= 32'b00010;
            z0_bypass_z0_pattern_main <= 32'b01000;
          end
        27: begin //5.250x
            phase_length_init <= 3'd3;
            pattern_length_main <= 6'd20;
            phase_length_post <= 3'd2;
            a0_last_init <= 8'h2B;
            z0_last_init <= 1'b0;
            load_pattern_main <= 32'b100000100001000010000;
            a0_increment <= 8'h30;
            a0_round_inc <= 32'b111011101110111101110;
            z0_bypass_z0_pattern_main <= 32'b000000000000000000000;
          end
        28: begin //5.500x
            phase_length_init <= 3'd3;
            pattern_length_main <= 6'd10;
            phase_length_post <= 3'd2;
            a0_last_init <= 8'h23;
            z0_last_init <= 1'b0;
            load_pattern_main <= 32'b10000010000;
            a0_increment <= 8'h2E;
            a0_round_inc <= 32'b10101010110;
            z0_bypass_z0_pattern_main <= 32'b00000000000;
          end
        29: begin //5.750x
            phase_length_init <= 3'd3;
            pattern_length_main <= 6'd22;
            phase_length_post <= 3'd2;
            a0_last_init <= 8'h1C;
            z0_last_init <= 1'b0;
            load_pattern_main <= 32'b10000010000010000100000;
            a0_increment <= 8'h2C;
            a0_round_inc <= 32'b10101010101010110101010;
            z0_bypass_z0_pattern_main <= 32'b00000000000000000000000;
          end
        30: begin //6.000x
            phase_length_init <= 3'd3;
            pattern_length_main <= 6'd5;
            phase_length_post <= 3'd2;
            a0_last_init <= 8'h15;
            z0_last_init <= 1'b0;
            load_pattern_main <= 32'b100000;
            a0_increment <= 8'h2A;
            a0_round_inc <= 32'b011011;
            z0_bypass_z0_pattern_main <= 32'b000000;
          end
        default: begin //1.000x
            phase_length_init <= 3'd1;
            pattern_length_main <= 6'd0;
            phase_length_post <= 3'd0;
            a0_last_init <= 8'h80;
            z0_last_init <= 1'b1;
            load_pattern_main <= 32'b1;
            a0_increment <= 8'h00;
            a0_round_inc <= 32'b0;
            z0_bypass_z0_pattern_main <= 32'b1;
          end
      endcase
    end
  end
endtask
