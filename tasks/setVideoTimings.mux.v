
task setVideoHTimings;

  input [`VID_CFG_W-1:0] video_config_i;
  output HSYNC_active;
  output [11:0] HSYNCLEN;
  output [11:0] HSTART;
  output [11:0] HACTIVE;
  output [11:0] HSTOP;
  output [11:0] HTOTAL;
  
  begin
    HSYNC_active = video_config_i == `USE_VGAp60  ? `HSYNC_active_VGA     :
                   video_config_i == `USE_720p60  ? `HSYNC_active_720p60  :
                   video_config_i == `USE_960p60  ? `HSYNC_active_960p60  :
                   video_config_i == `USE_1080p60 ? `HSYNC_active_1080p60 :
                   video_config_i == `USE_1200p60 ? `HSYNC_active_1200p60 :
                   video_config_i == `USE_576p50  ? `HSYNC_active_576p50  :
                   video_config_i == `USE_720p50  ? `HSYNC_active_720p50  :
                   video_config_i == `USE_960p50  ? `HSYNC_active_960p50  :
                   video_config_i == `USE_1080p50 ? `HSYNC_active_1080p50 :
                   video_config_i == `USE_1200p50 ? `HSYNC_active_1200p50 :
                                                    `HSYNC_active_480p60;
    
    HSYNCLEN = video_config_i == `USE_VGAp60  ? `HSYNCLEN_VGA     :
               video_config_i == `USE_720p60  ? `HSYNCLEN_720p60  :
               video_config_i == `USE_960p60  ? `HSYNCLEN_960p60  :
               video_config_i == `USE_1080p60 ? `HSYNCLEN_1080p60 :
               video_config_i == `USE_1200p60 ? `HSYNCLEN_1200p60 :
               video_config_i == `USE_576p50  ? `HSYNCLEN_576p50  :
               video_config_i == `USE_720p50  ? `HSYNCLEN_720p50  :
               video_config_i == `USE_960p50  ? `HSYNCLEN_960p50  :
               video_config_i == `USE_1080p50 ? `HSYNCLEN_1080p50 :
               video_config_i == `USE_1200p50 ? `HSYNCLEN_1200p50 :
                                                `HSYNCLEN_480p60;
    
    HSTART = video_config_i == `USE_VGAp60  ? `HSYNCLEN_VGA     + `HBACKPORCH_VGA     :
             video_config_i == `USE_720p60  ? `HSYNCLEN_720p60  + `HBACKPORCH_720p60  :
             video_config_i == `USE_960p60  ? `HSYNCLEN_960p60  + `HBACKPORCH_960p60  :
             video_config_i == `USE_1080p60 ? `HSYNCLEN_1080p60 + `HBACKPORCH_1080p60 :
             video_config_i == `USE_1200p60 ? `HSYNCLEN_1200p60 + `HBACKPORCH_1200p60 :
             video_config_i == `USE_576p50  ? `HSYNCLEN_576p50  + `HBACKPORCH_576p50  :
             video_config_i == `USE_720p50  ? `HSYNCLEN_720p50  + `HBACKPORCH_720p50  :
             video_config_i == `USE_960p50  ? `HSYNCLEN_960p50  + `HBACKPORCH_960p50  :
             video_config_i == `USE_1080p50 ? `HSYNCLEN_1080p50 + `HBACKPORCH_1080p50 :
             video_config_i == `USE_1200p50 ? `HSYNCLEN_1200p50 + `HBACKPORCH_1200p50 :
                                              `HSYNCLEN_480p60  + `HBACKPORCH_480p60;
    
    HACTIVE = video_config_i == `USE_VGAp60  ? `HACTIVE_VGA     :
              video_config_i == `USE_720p60  ? `HACTIVE_720p60  :
              video_config_i == `USE_960p60  ? `HACTIVE_960p60  :
              video_config_i == `USE_1080p60 ? `HACTIVE_1080p60 :
              video_config_i == `USE_1200p60 ? `HACTIVE_1200p60 :
              video_config_i == `USE_576p50  ? `HACTIVE_576p50  :
              video_config_i == `USE_720p50  ? `HACTIVE_720p50  :
              video_config_i == `USE_960p50  ? `HACTIVE_960p50  :
              video_config_i == `USE_1080p50 ? `HACTIVE_1080p50 :
              video_config_i == `USE_1200p50 ? `HACTIVE_1200p50 :
                                               `HACTIVE_480p60;
    
    HSTOP = video_config_i == `USE_VGAp60  ? `HSYNCLEN_VGA     + `HBACKPORCH_VGA     + `HACTIVE_VGA     :
            video_config_i == `USE_720p60  ? `HSYNCLEN_720p60  + `HBACKPORCH_720p60  + `HACTIVE_720p60  :
            video_config_i == `USE_960p60  ? `HSYNCLEN_960p60  + `HBACKPORCH_960p60  + `HACTIVE_960p60  :
            video_config_i == `USE_1080p60 ? `HSYNCLEN_1080p60 + `HBACKPORCH_1080p60 + `HACTIVE_1080p60 :
            video_config_i == `USE_1200p60 ? `HSYNCLEN_1200p60 + `HBACKPORCH_1200p60 + `HACTIVE_1200p60 :
            video_config_i == `USE_576p50  ? `HSYNCLEN_576p50  + `HBACKPORCH_576p50  + `HACTIVE_576p50  :
            video_config_i == `USE_720p50  ? `HSYNCLEN_720p50  + `HBACKPORCH_720p50  + `HACTIVE_720p50  :
            video_config_i == `USE_960p50  ? `HSYNCLEN_960p50  + `HBACKPORCH_960p50  + `HACTIVE_960p50  :
            video_config_i == `USE_1080p50 ? `HSYNCLEN_1080p50 + `HBACKPORCH_1080p50 + `HACTIVE_1080p50 :
            video_config_i == `USE_1200p50 ? `HSYNCLEN_1200p50 + `HBACKPORCH_1200p50 + `HACTIVE_1200p50 :
                                             `HSYNCLEN_480p60  + `HBACKPORCH_480p60  + `HACTIVE_480p60;
    
    HTOTAL = video_config_i == `USE_VGAp60  ? `HTOTAL_VGA     :
             video_config_i == `USE_720p60  ? `HTOTAL_720p60  :
             video_config_i == `USE_960p60  ? `HTOTAL_960p60  :
             video_config_i == `USE_1080p60 ? `HTOTAL_1080p60 :
             video_config_i == `USE_1200p60 ? `HTOTAL_1200p60 :
             video_config_i == `USE_576p50  ? `HTOTAL_576p50  :
             video_config_i == `USE_720p50  ? `HTOTAL_720p50  :
             video_config_i == `USE_960p50  ? `HTOTAL_960p50  :
             video_config_i == `USE_1080p50 ? `HTOTAL_1080p50 :
             video_config_i == `USE_1200p50 ? `HTOTAL_1080p50 :
                                              `HTOTAL_480p60;
  end

endtask


task setVideoVTimings;

  input [`VID_CFG_W-1:0] video_config_i;
  output VSYNC_active;
  output [11:0] VSYNCLEN;
  output [11:0] VSTART;
  output [11:0] VACTIVE;
  output [11:0] VSTOP;
  output [11:0] VTOTAL;
  
  begin
    VSYNC_active = video_config_i == `USE_VGAp60  ? `VSYNC_active_VGA     :
                   video_config_i == `USE_720p60  ? `VSYNC_active_720p60  :
                   video_config_i == `USE_960p60  ? `VSYNC_active_960p60  :
                   video_config_i == `USE_1080p60 ? `VSYNC_active_1080p60 :
                   video_config_i == `USE_1200p60 ? `VSYNC_active_1200p60 :
                   video_config_i == `USE_576p50  ? `VSYNC_active_576p50  :
                   video_config_i == `USE_720p50  ? `VSYNC_active_720p50  :
                   video_config_i == `USE_960p50  ? `VSYNC_active_960p50  :
                   video_config_i == `USE_1080p50 ? `VSYNC_active_1080p50 :
                   video_config_i == `USE_1200p50 ? `VSYNC_active_1200p50 :
                                                    `VSYNC_active_480p60;
    
    VSYNCLEN = video_config_i == `USE_VGAp60  ? `VSYNCLEN_VGA     :
               video_config_i == `USE_720p60  ? `VSYNCLEN_720p60  :
               video_config_i == `USE_960p60  ? `VSYNCLEN_960p60  :
               video_config_i == `USE_1080p60 ? `VSYNCLEN_1080p60 :
               video_config_i == `USE_1200p60 ? `VSYNCLEN_1200p60 :
               video_config_i == `USE_576p50  ? `VSYNCLEN_576p50  :
               video_config_i == `USE_720p50  ? `VSYNCLEN_720p50  :
               video_config_i == `USE_960p50  ? `VSYNCLEN_960p50  :
               video_config_i == `USE_1080p50 ? `VSYNCLEN_1080p50 :
               video_config_i == `USE_1200p50 ? `VSYNCLEN_1200p50 :
                                                `VSYNCLEN_480p60;
    
    VSTART = video_config_i == `USE_VGAp60  ? `VSYNCLEN_VGA     + `VBACKPORCH_VGA     :
             video_config_i == `USE_720p60  ? `VSYNCLEN_720p60  + `VBACKPORCH_720p60  :
             video_config_i == `USE_960p60  ? `VSYNCLEN_960p60  + `VBACKPORCH_960p60  :
             video_config_i == `USE_1080p60 ? `VSYNCLEN_1080p60 + `VBACKPORCH_1080p60 :
             video_config_i == `USE_1200p60 ? `VSYNCLEN_1200p60 + `VBACKPORCH_1200p60 :
             video_config_i == `USE_576p50  ? `VSYNCLEN_576p50  + `VBACKPORCH_576p50  :
             video_config_i == `USE_720p50  ? `VSYNCLEN_720p50  + `VBACKPORCH_720p50  :
             video_config_i == `USE_960p50  ? `VSYNCLEN_960p50  + `VBACKPORCH_960p50  :
             video_config_i == `USE_1080p50 ? `VSYNCLEN_1080p50 + `VBACKPORCH_1080p50 :
             video_config_i == `USE_1200p50 ? `VSYNCLEN_1200p50 + `VBACKPORCH_1200p50 :
                                              `VSYNCLEN_480p60  + `VBACKPORCH_480p60;
    
    VACTIVE = video_config_i == `USE_VGAp60  ? `VACTIVE_VGA     :
              video_config_i == `USE_720p60  ? `VACTIVE_720p60  :
              video_config_i == `USE_960p60  ? `VACTIVE_960p60  :
              video_config_i == `USE_1080p60 ? `VACTIVE_1080p60 :
              video_config_i == `USE_1200p60 ? `VACTIVE_1200p60 :
              video_config_i == `USE_576p50  ? `VACTIVE_576p50  :
              video_config_i == `USE_720p50  ? `VACTIVE_720p50  :
              video_config_i == `USE_960p50  ? `VACTIVE_960p50  :
              video_config_i == `USE_1080p50 ? `VACTIVE_1080p50 :
              video_config_i == `USE_1200p50 ? `VACTIVE_1200p50 :
                                               `VACTIVE_480p60;
    
    VSTOP = video_config_i == `USE_VGAp60  ? `VSYNCLEN_VGA     + `VBACKPORCH_VGA     + `VACTIVE_VGA     :
            video_config_i == `USE_720p60  ? `VSYNCLEN_720p60  + `VBACKPORCH_720p60  + `VACTIVE_720p60  :
            video_config_i == `USE_960p60  ? `VSYNCLEN_960p60  + `VBACKPORCH_960p60  + `VACTIVE_960p60  :
            video_config_i == `USE_1080p60 ? `VSYNCLEN_1080p60 + `VBACKPORCH_1080p60 + `VACTIVE_1080p60 :
            video_config_i == `USE_1200p60 ? `VSYNCLEN_1200p60 + `VBACKPORCH_1200p60 + `VACTIVE_1200p60 :
            video_config_i == `USE_576p50  ? `VSYNCLEN_576p50  + `VBACKPORCH_576p50  + `VACTIVE_576p50  :
            video_config_i == `USE_720p50  ? `VSYNCLEN_720p50  + `VBACKPORCH_720p50  + `VACTIVE_720p50  :
            video_config_i == `USE_960p50  ? `VSYNCLEN_960p50  + `VBACKPORCH_960p50  + `VACTIVE_960p50  :
            video_config_i == `USE_1080p50 ? `VSYNCLEN_1080p50 + `VBACKPORCH_1080p50 + `VACTIVE_1080p50 :
            video_config_i == `USE_1200p50 ? `VSYNCLEN_1200p50 + `VBACKPORCH_1200p50 + `VACTIVE_1200p50 :
                                             `VSYNCLEN_480p60  + `VBACKPORCH_480p60  + `VACTIVE_480p60;
    
    VTOTAL = video_config_i == `USE_VGAp60  ? `VTOTAL_VGA     :
             video_config_i == `USE_720p60  ? `VTOTAL_720p60  :
             video_config_i == `USE_960p60  ? `VTOTAL_960p60  :
             video_config_i == `USE_1080p60 ? `VTOTAL_1080p60 :
             video_config_i == `USE_1200p60 ? `VTOTAL_1200p60 :
             video_config_i == `USE_576p50  ? `VTOTAL_576p50  :
             video_config_i == `USE_720p50  ? `VTOTAL_720p50  :
             video_config_i == `USE_960p50  ? `VTOTAL_960p50  :
             video_config_i == `USE_1080p50 ? `VTOTAL_1080p50 :
             video_config_i == `USE_1200p50 ? `VTOTAL_1080p50 :
                                              `VTOTAL_480p60;
  end

endtask
