
task setVideoVTimings;

  input [`VID_CFG_W-1:0] video_config;
  output VSYNC_active;
  output [11:0] VSYNCLEN;
  output [11:0] VSTART;
  output [11:0] VACTIVE;
  output [11:0] VSTOP;
  output [11:0] VTOTAL;
  
  begin
    case (video_config)
      `USE_VGAp60: begin  // VGA (640x480), 4:3
          VSYNC_active <= `VSYNC_active_VGA;
          VSYNCLEN <= `VSYNCLEN_VGA;
          VSTART <= `VSYNCLEN_VGA + `VBACKPORCH_VGA;
          VACTIVE <= `VACTIVE_VGA;
          VSTOP <= `VSYNCLEN_VGA + `VBACKPORCH_VGA + `VACTIVE_VGA;
          VTOTAL <= `VTOTAL_VGA;
        end
      `USE_720p60: begin  // 720p-60, 16:9
          VSYNC_active <= `VSYNC_active_720p60;
          VSYNCLEN <= `VSYNCLEN_720p60;
          VSTART <= `VSYNCLEN_720p60 + `VBACKPORCH_720p60;
          VACTIVE <= `VACTIVE_720p60;
          VSTOP <= `VSYNCLEN_720p60 + `VBACKPORCH_720p60 + `VACTIVE_720p60;
          VTOTAL <= `VTOTAL_720p60;
        end
      `USE_960p60: begin  // 960p-60, 4:3
          VSYNC_active <= `VSYNC_active_960p60;
          VSYNCLEN <= `VSYNCLEN_960p60;
          VSTART <= `VSYNCLEN_960p60 + `VBACKPORCH_960p60;
          VACTIVE <= `VACTIVE_960p60;
          VSTOP <= `VSYNCLEN_960p60 + `VBACKPORCH_960p60 + `VACTIVE_960p60;
          VTOTAL <= `VTOTAL_960p60;
        end
      `USE_1080p60: begin // 1080p-60, 16:9
          VSYNC_active <= `VSYNC_active_1080p60;
          VSYNCLEN <= `VSYNCLEN_1080p60;
          VSTART <= `VSYNCLEN_1080p60 + `VBACKPORCH_1080p60;
          VACTIVE <= `VACTIVE_1080p60;
          VSTOP <= `VSYNCLEN_1080p60 + `VBACKPORCH_1080p60 + `VACTIVE_1080p60;
          VTOTAL <= `VTOTAL_1080p60;
        end
      `USE_1200p60: begin // 1200p-60, 4:3
          VSYNC_active <= `VSYNC_active_1200p60;
          VSYNCLEN <= `VSYNCLEN_1200p60;
          VSTART <= `VSYNCLEN_1200p60 + `VBACKPORCH_1200p60;
          VACTIVE <= `VACTIVE_1200p60;
          VSTOP <= `VSYNCLEN_1200p60 + `VBACKPORCH_1200p60 + `VACTIVE_1200p60;
          VTOTAL <= `VTOTAL_1200p60;
        end
      `USE_720p50: begin // 720p-50, 16:9
          VSYNC_active <= `VSYNC_active_720p50;
          VSYNCLEN <= `VSYNCLEN_720p50;
          VSTART <= `VSYNCLEN_720p50 + `VBACKPORCH_720p50;
          VACTIVE <= `VACTIVE_720p50;
          VSTOP <= `VSYNCLEN_720p50 + `VBACKPORCH_720p50 + `VACTIVE_720p50;
          VTOTAL <= `VTOTAL_720p50;
        end
      `USE_960p50: begin // 960p-50, 4:3
          VSYNC_active <= `VSYNC_active_960p50;
          VSYNCLEN <= `VSYNCLEN_960p50;
          VSTART <= `VSYNCLEN_960p50 + `VBACKPORCH_960p50;
          VACTIVE <= `VACTIVE_960p50;
          VSTOP <= `VSYNCLEN_960p50 + `VBACKPORCH_960p50 + `VACTIVE_960p50;
          VTOTAL <= `VTOTAL_960p50;
        end
      `USE_1080p50: begin // 1080p-50, 16:9
          VSYNC_active <= `VSYNC_active_1080p50;
          VSYNCLEN <= `VSYNCLEN_1080p50;
          VSTART <= `VSYNCLEN_1080p50 + `VBACKPORCH_1080p50;
          VACTIVE <= `VACTIVE_1080p50;
          VSTOP <= `VSYNCLEN_1080p50 + `VBACKPORCH_1080p50 + `VACTIVE_1080p50;
          VTOTAL <= `VTOTAL_1080p50;
        end
      `USE_1200p50: begin // 1200p-50, 4:3
          VSYNC_active <= `VSYNC_active_1200p50;
          VSYNCLEN <= `VSYNCLEN_1200p50;
          VSTART <= `VSYNCLEN_1200p50 + `VBACKPORCH_1200p50;
          VACTIVE <= `VACTIVE_1200p50;
          VSTOP <= `VSYNCLEN_1200p50 + `VBACKPORCH_1200p50 + `VACTIVE_1200p50;
          VTOTAL <= `VTOTAL_1200p50;
        end
      default: begin
          if (video_config[`VID_CFG_50HZ_BIT]) begin // 576p-50, 4:3 / 16:9
            VSYNC_active <= `VSYNC_active_576p50;
            VSYNCLEN <= `VSYNCLEN_576p50;
            VSTART <= `VSYNCLEN_576p50 + `VBACKPORCH_576p50;
            VACTIVE <= `VACTIVE_576p50;
            VSTOP <= `VSYNCLEN_576p50 + `VBACKPORCH_576p50 + `VACTIVE_576p50;
            VTOTAL <= `VTOTAL_576p50;
          end else begin // 480p-60, 4:3 / 16:9
            VSYNC_active <= `VSYNC_active_480p60;
            VSYNCLEN <= `VSYNCLEN_480p60;
            VSTART <= `VSYNCLEN_480p60 + `VBACKPORCH_480p60;
            VACTIVE <= `VACTIVE_480p60;
            VSTOP <= `VSYNCLEN_480p60 + `VBACKPORCH_480p60 + `VACTIVE_480p60;
            VTOTAL <= `VTOTAL_480p60;
          end
        end
    endcase
  end

endtask


task setVideoHTimings;

  input [`VID_CFG_W-1:0] video_config;
  output HSYNC_active;
  output [11:0] HSYNCLEN;
  output [11:0] HSTART;
  output [11:0] HACTIVE;
  output [11:0] HSTOP;
  output [11:0] HTOTAL;
  
  begin
    case (video_config)
      `USE_VGAp60: begin  // VGA (640x480), 4:3
          HSYNC_active <= `HSYNC_active_VGA;
          HSYNCLEN <= `HSYNCLEN_VGA;
          HSTART <= `HSYNCLEN_VGA + `HBACKPORCH_VGA;
          HACTIVE <= `HACTIVE_VGA;
          HSTOP <= `HSYNCLEN_VGA + `HBACKPORCH_VGA + `HACTIVE_VGA;
          HTOTAL <= `HTOTAL_VGA;
        end
      `USE_720p60: begin  // 720p-60, 16:9
          HSYNC_active <= `HSYNC_active_720p60;
          HSYNCLEN <= `HSYNCLEN_720p60;
          HSTART <= `HSYNCLEN_720p60 + `HBACKPORCH_720p60;
          HACTIVE <= `HACTIVE_720p60;
          HSTOP <= `HSYNCLEN_720p60 + `HBACKPORCH_720p60 + `HACTIVE_720p60;
          HTOTAL <= `HTOTAL_720p60;
        end
      `USE_960p60: begin  // 960p-60, 4:3
          HSYNC_active <= `HSYNC_active_960p60;
          HSYNCLEN <= `HSYNCLEN_960p60;
          HSTART <= `HSYNCLEN_960p60 + `HBACKPORCH_960p60;
          HACTIVE <= `HACTIVE_960p60;
          HSTOP <= `HSYNCLEN_960p60 + `HBACKPORCH_960p60 + `HACTIVE_960p60;
          HTOTAL <= `HTOTAL_960p60;
        end
      `USE_1080p60: begin // 1080p-60, 16:9
          HSYNC_active <= `HSYNC_active_1080p60;
          HSYNCLEN <= `HSYNCLEN_1080p60;
          HSTART <= `HSYNCLEN_1080p60 + `HBACKPORCH_1080p60;
          HACTIVE <= `HACTIVE_1080p60;
          HSTOP <= `HSYNCLEN_1080p60 + `HBACKPORCH_1080p60 + `HACTIVE_1080p60;
          HTOTAL <= `HTOTAL_1080p60;
        end
      `USE_1200p60: begin // 1200p-60, 4:3
          HSYNC_active <= `HSYNC_active_1200p60;
          HSYNCLEN <= `HSYNCLEN_1200p60;
          HSTART <= `HSYNCLEN_1200p60 + `HBACKPORCH_1200p60;
          HACTIVE <= `HACTIVE_1200p60;
          HSTOP <= `HSYNCLEN_1200p60 + `HBACKPORCH_1200p60 + `HACTIVE_1200p60;
          HTOTAL <= `HTOTAL_1200p60;
        end
      `USE_720p50: begin // 720p-50, 16:9
          HSYNC_active <= `HSYNC_active_720p50;
          HSYNCLEN <= `HSYNCLEN_720p50;
          HSTART <= `HSYNCLEN_720p50 + `HBACKPORCH_720p50;
          HACTIVE <= `HACTIVE_720p50;
          HSTOP <= `HSYNCLEN_720p50 + `HBACKPORCH_720p50 + `HACTIVE_720p50;
          HTOTAL <= `HTOTAL_720p50;
        end
      `USE_960p50: begin // 960p-50, 4:3
          HSYNC_active <= `HSYNC_active_960p50;
          HSYNCLEN <= `HSYNCLEN_960p50;
          HSTART <= `HSYNCLEN_960p50 + `HBACKPORCH_960p50;
          HACTIVE <= `HACTIVE_960p50;
          HSTOP <= `HSYNCLEN_960p50 + `HBACKPORCH_960p50 + `HACTIVE_960p50;
          HTOTAL <= `HTOTAL_960p50;
        end
      `USE_1080p50: begin // 1080p-50, 16:9
          HSYNC_active <= `HSYNC_active_1080p50;
          HSYNCLEN <= `HSYNCLEN_1080p50;
          HSTART <= `HSYNCLEN_1080p50 + `HBACKPORCH_1080p50;
          HACTIVE <= `HACTIVE_1080p50;
          HSTOP <= `HSYNCLEN_1080p50 + `HBACKPORCH_1080p50 + `HACTIVE_1080p50;
          HTOTAL <= `HTOTAL_1080p50;
        end
      `USE_1200p50: begin // 1200p-50, 4:3
          HSYNC_active <= `HSYNC_active_1200p50;
          HSYNCLEN <= `HSYNCLEN_1200p50;
          HSTART <= `HSYNCLEN_1200p50 + `HBACKPORCH_1200p50;
          HACTIVE <= `HACTIVE_1200p50;
          HSTOP <= `HSYNCLEN_1200p50 + `HBACKPORCH_1200p50 + `HACTIVE_1200p50;
          HTOTAL <= `HTOTAL_1200p50;
        end
      default: begin
          if (video_config[`VID_CFG_50HZ_BIT]) begin // 576p-50, 4:3 / 16:9
            HSYNC_active <= `HSYNC_active_576p50;
            HSYNCLEN <= `HSYNCLEN_576p50;
            HSTART <= `HSYNCLEN_576p50 + `HBACKPORCH_576p50;
            HACTIVE <= `HACTIVE_576p50;
            HSTOP <= `HSYNCLEN_576p50 + `HBACKPORCH_576p50 + `HACTIVE_576p50;
            HTOTAL <= `HTOTAL_576p50;
          end else begin // 480p-60, 4:3 / 16:9
            HSYNC_active <= `HSYNC_active_480p60;
            HSYNCLEN <= `HSYNCLEN_480p60;
            HSTART <= `HSYNCLEN_480p60 + `HBACKPORCH_480p60;
            HACTIVE <= `HACTIVE_480p60;
            HSTOP <= `HSYNCLEN_480p60 + `HBACKPORCH_480p60 + `HACTIVE_480p60;
            HTOTAL <= `HTOTAL_480p60;
          end
        end
    endcase
  end

endtask
