N64 Advanced version 2
---

### Table of Contents

- [User Information](https://github.com/borti4938/n64adv2_fw#user-information)
  - [OSD Menu](https://github.com/borti4938/n64adv2_fw#osd-menu)
  - [Default Configuration](https://github.com/borti4938/n64adv2_fw#default-configuration)
  - [Work with the Debug-Info Page](https://github.com/borti4938/n64adv2_fw#work-with-the-debug-info-page)
  - [Firmware Update](https://github.com/borti4938/n64adv2_fw#firmware-update)
- [Developer Information](https://github.com/borti4938/n64adv2_fw#developer-information)
  - [Repository Management](https://github.com/borti4938/n64adv2_fw#repository-management)
  - [Setup Toolchain](https://github.com/borti4938/n64adv2_fw#setup-toolchain)
  - [Build Firmware](https://github.com/borti4938/n64adv2_fw#build-firmware)


## User Information

### OSD Menu 

#### Overview and Navigation 

The on screen display (OSD) menu can be opened at any point where a game is reading the controller by pressing **D-ri + L + R + C-ri**. (D = D-Pad)

![](./doc/img/menu_open.jpg)

The menu always open in the top level, where you have following options available:

- **\[Resolution\]**  
  Change resolution of the digital output signal
- **\[Scaler\]**  
  Scaler settings
- **\[Scanlines\]**  
  Scanlines settings (not available in 240p/288p mode)
- **\[VI-Processing\]**  
  Some video interface processing stuff other than resolution and scaling
- **\[Audio-Processing\]**  
  Some audio interface processing stuff
- **\[Miscellaneous\]**  
  In-game routines settings, reset behavior, and so on
- **\[Save/Load/Fallback\]**  
  Save your current settings, load from settings or defaults
- **\[Debug-Info\]**  
  Displays some (useful) debugging information
- **About...**  
  Some information on the project
- **Acknowledgment...**  
  Acknowledgement
- **License...**  
  License text

You navigate through the menu using the **D-Pad**, the **control stick** or the **C buttons**.
With up/down you go up and down, respectively, and with left/right you can change settings.
With **A** (or right) and **B** you can enter and leave a submenu.
Pressing B in the top menu closes the OSD.
Alternatively, you can use **D-le + L + R + C-le** to close the menu at any point.
If you feel to just undisplay the OSD for a brief moment to check your last settings change, just hold **L + Z**.
Note that the N64Adv2 does not actively read the controller.
As mentioned, the game must read it.

![](./doc/img/main-menu.jpg)

The following tables describe the different settings available.
The tables also show some default values.
An empty default value means that this value is not affected by loading defaults.

#### Resolution

Any change on the configuration in this menu needs you to confirm the new setting if applied to current input mode.
If you do not do so within a few seconds, the setting will switch back to the previous one.
Configuration changes on non-native input mode (i.e. NTSC while running a PAL game and vice versa) are directly applied without confirmation.
Only change something here if you are sure what you are doing.

| Entry | Default | Description |
|:------|:--------|:------------|
| **Input mode** \[1\] | | Mode where the following settings are applied, NTSC or PAL |
| **New settings - Output resolution** | \[2\] | Changes output resolution \[3,4\] |
| **New settings - Use VGA-flag** | Off | Reduces width from 720 pixel to 640 pixel in 480p and 576p output resolution |
| **New settings - Direct mode version** \[5\]| DV1 (MiSTer) | Switches between direct mode as used on MiSTer (_DV1 (MiSTer)_) and used by PixelFX (_FX-Direct_)<br>DV1 is supported by Retrotink4k, OSSC Pro and Morph, FX-Direct only by Morph. |
| **New settings - Frame-locked mode** | Off | Varies the pixel clock such that vertical sync matches the N64 generated vertical clock.<br>Vsync in this mode is slightly off spec. To my experience, NTSC runs fine on most TVs other than PAL.<br>Always on on direct mode |
| **New settings - Force 50Hz/60Hz** | Off (N64 Auto) | Forces 50Hz or 60Hz vertical output frequency. This may introduce additional shudder when running PAL in 60Hz and NTSC in 50Hz.<br>This option becomes inaccessible in frame locked mode.<br>Always on Auto on direct mode |
| **New settings - Test and apply** | | Apply current changes \[6\] |
| **Current settings** | _not available_ | Menu entries are not modifiable. They are showing the actual settings | 

\[1\] You are allowed to quickly change the _Input mode_ on this screen by pressing **L** or **R** on the controller.  
\[2\] Default depends on boot procedure (see section [Default Configuration](https://github.com/borti4938/n64adv2_fw_beta_releases#default-configuration))  
\[3\] Available resolutions are: **Direct** (240p/480i / 288p/576i as per game in _DV1_, and 720p in _FX-Direct_), **480p/576p** (4:3), **720p** (16:9), **960p** (4:3), **1080p (16:9)**, **1200p** (4:3), and **1440p** (4:3 and 16:9)  
\[4\] Note that the 1440p modes will only be available if you unlock it over the _Miscellaneous_ menu or if it is already configured. 1440p (16:9) uses pixel repetition at the HDMI transmitter. So 1440p (4:3) should be preferred if this works in the particular setup.  
\[5\] Only appears if target output resolution is set to _Direct_.  
\[6\] Function test actual setting. Apply by confirming with _A_, undo with _B_ or waiting a short while.

#### Scaler

| Entry | Default | Description |
|:------|:--------|:------------|
| **Vertical interpolation** | Integer | Sets the vertical interpolation type. Selection of<br>- **Integer**/**Integer (soft)** simple 0-order hold interpolation \[7\]<br>- **Integer+Bi-linear** bi-linear scaling with pre-integer scaling<br>- **Bi-linear** bi-linear scaling |
| **Horizontal interpolation** | Integer | Sets the horizontal interpolation type. Selection of<br>- **Integer**/**Integer (soft)** simple 0-order hold interpolation \[7\]<br>- **Integer+Bi-linear** bi-linear scaling with pre-integer scaling<br>- **Bi-linear** bi-linear scaling |
| **Scaling - Settings for** \[8\] | _Current_ | Selects on which scaling mode (NTSC/PAL to different output resolutions) the following settings shall be applied. |
| **Scaling - Link v/h factors** | 4:3 | Links vertical and horizontal to **10:9**, **4:3**, **CRT**, **16:9** or keep it **open**. \ |
| **Scaling - V/h scaling steps** | 0.25x | Changes between **0.25x** steps and **pixelwise** |
| **Scaling - Vertical scale value** | _see notes_| Sets the number of desired output lines |
| **Scaling - Horizontal scale value** | _see notes_ | Set the number of desired output pixel per line |
| **Use PAL in 240p box** | Auto | Uses 240 lines as input reference instead of 288 lines. User can decide whether setting is being estimated (_Auto_) or fix lines to either 240 (_On_) or 288 (_Off_). |
| **Shift N64 input image - Input Mode** \[9\] | _Current_ | Switches between NTSC/PAL input |
| **Shift N64 input image - Vertical shift**| 0 | Shifts the input by a certain number of lines before the buffer |
| **Shift N64 input image - Horizontal shift** | 0 | Shifts the input by a certain number of pixels before the buffer |

\[7\] Integer (soft) interpolation: If an output pixel is _exactly_ between two inputs, the output is the mean between both inputs to reduce uneven pixel and shimmering a bit. Scaling for 240p/288p is always integer scaling no matter what is set as _Interpolation type_.  
\[8\] You are allowed to quickly change the _Scaling - Settings for_ on this screen by pressing **L** or **R** on the controller as long as your curser is somewhere around the _Scaling_ related options.  
\[9\] You are allowed to quickly change the _Shift N64 input image - Input Mode_ on this screen by pressing **L** or **R** on the controller as long as your curser is somewhere around the _Shift N64 input image_ related options.

#### Scanlines Config

| Entry | Default | Description |
|:------|:--------|:------------|
| **Input mode** \[10\] | _Current_ | Switches between NTSC/PAL progressive/interlaced input |
| **Calculation Mode** | Luma based | Determines whether all calculations regarding thickness (adaptive) and strength (bloom effect) are **Luma based** or **per color based** |
| **Horizontal scanlines** \[11\] | Off | Enables horizontal scanlines for the particular input mode. |
| **Horizontal - Thickness** | Thin | Switches between **Thin**, **Normal**, **Thick** or **Adaptive** scanlines.<br>Depending on the scaling factor there might be a minor to huge difference. Just play around and see what suits best for you. |
| **Horizontal - Profile** | Hanning | Set up the transition area between scanline and no-scanline. A smooth transition ensures somehow feels equally distributed over the screen even for non-integer scales.<br>From smooth to non-smooth select from **Hanning**, **Gaussian** and **Rectangular**. |
| **Horizontal - Strength** \[12\] | 6% | Selects the scanline strength with I = **s** x I_{in}, with **s** being the actual setting and I the pixel intensity. |
| **Horizontal - Bloom effect** \[12\] | 0% | Makes scanline strength pixel-intensity dependent<br>- 0% means that the scanlines are drawn as calculated<br>- 100% means that the scanlines strength is reduced down to 0 for maximum pixel intensity<br>- above or below 100% means that the scanlines strength is reduced to 0 before maximum pixel intensity or never completely reduced to 0, respectively |
| **Vertical scanlines** \[11\] | Off | Enables vertical scanlines for the particular input mode. |
| **Vertical - Link to horizontal** | Off | Links the vertical scanlines settings to the horizontal settings.<br>Following settings will be a copy of the horizontal scanlines settings. |
| **Vertical - Thickness** | Thin | Switches between **Thin**, **Normal**, **Thick** or **Adaptive** scanlines.<br>Depending on the scaling factor there might be a minor to huge difference. Just play around and see what suits best for you. |
| **Vertical - Profile** | Hanning | Set up the transition area between scanline and no-scanline. A smooth transition ensures somehow feels equally distributed over the screen even for non-integer scales.<br>From smooth to non-smooth select from **Hanning**, **Gaussian** and **Rectangular**. |
| **Vertical - Strength** \[12\] | 6% | Selects the scanline strength with I = **s** x I_{in}, with **s** being the actual setting and I the pixel intensity. |
| **Vertical - Bloom effect** \[12\] | 0% | Makes scanline strength pixel-intensity dependent<br>- 0% means that the scanlines are drawn as calculated<br>- 100% means that the scanlines strength is reduced down to 0 for maximum pixel intensity<br>- above or below 100% means that the scanlines strength is reduced to 0 before maximum pixel intensity or never completely reduced to 0, respectively |

\[10\] _Input mode_ can be changed using **L** or **R** button on the controller.  
\[11\] Even though scanline drawing is interconnected with the scaler, best results will be achieved for full integer scaling factors. Another rule is, the larger the scaling factor the better the look. Also keep in mind that scanlines are not drawn if output resolution is not at least twice the input.  
\[12\] A script for simulating the scanline behavior is available under [scrips/scanline\_sim.m](./scrips/scanline_sim.m)

#### VI-Processing

| Entry | Default | Description |
|:------|:--------|:------------|
| **De-Interlacing mode** | Bob | Selects between **Frame Drop**, **Bob** or **Weave** deinterlacing for 480i/576i video input<br>- Frame drop removes every even field from the input<br>- Bob deinterlacing handles input as 240p/288p<br>- Weave deinterlacing updates even and odd lines as an even or odd frame is drawn at the input |
| **Gamma value** | 1.00 | Applies some gamma boost.<br>Gamma curve on output is defined as I = I_{in}^**\gamma**, where I is the intensity. |
| **Color space - Format** | RGB | Choose between **RGB**, **YCbCr (ITU601/SD)** or **YCbCr (ITU709/HD)** color space |
| **Color space - Limited range** | Off | Sets color space to use just a limited range (not full 8bit (0 to 255)) leaving some headroom<br>- RGB values in a range of 16 to 235<br>YCbCr values between 16 and 235 (Y) or between 16 and 239 (Cb/Cr) |
| **LowRes.-DeBlur** | Off | Enables low resolution deblur. \[13\] |
| **LowRes.-DeBlur - Power cycle default** | Off | Sets the power cycle default. |
| **16bit mode** | Off | Selects between \[14\]<br>- **On** = reduces the color depth of the input from 21bit down to 16bit<br>- **Off** use the whole 21bit color depth of the N64 input video interface |
| **16bit mode - Power cycle default** | Off | Sets the power cycle default. |

\[13\] _LowRes.-DeBlur_ applies only for progressive inputs (i.e. 240p/288p content). This improves the overall image quality if the games runs in 320x240 / 320x288. However it decreases image quality if the game uses 640 horizontal pixel.  
\[14\] 21bit -> 7bit each color as provided by N64. 16bit -> 5bit for red and blue and 6bit for green.

#### Audio-Processing

| Entry | Default | Description |
|:------|:--------|:------------|
| **Filter Options - Bypass filter** | Off | Bypasses the reconstruction audio filter. Only use this option if you are facing any issues with the fillter enabled. |
| **Output Settings - Mute audio** | Off | Mutes output audio |
| **Output Settings - Swap L/R** | Off | Swaps left and right audio channel |
| **Audio settings - Output gain** | 0dB | Amplifies the audio signal after the audio filter. Saturation may appear. |
| **S/PDIF support - Enabled** | Off | Enables the S/PDIF audio output. |

#### Miscellaneous

| Entry | Default | Description |
|:------|:--------|:------------|
| **Controller routines - Reset** | On | Enables _reset via controller_<br>- Button combination: **Start + Z + R + A + B** |
| **Controller routines - VI-DeBlur** | Off | Allows switching _low. res. deblur_ (see description above) **on** and **off** via controller<br>- Button combination **On**: **Start + Z + R + C-ri**<br>- Button combination **Off**: **Start + Z + R + C-le** |
| **Controller routines - 16bit mode** | Off | Allows switching _16bit mode_ (see description above) **on** and **off** via controller<br>- Button combination **On**: **Start + Z + R + C-down**<br>- Button combination **Off**: **Start + Z + R + C-up** |
| **Reset masking** | VI + Audio | User can opt to not reset video interface pipeline (**VI pipeline**) and/or **Audio** processing if the console is being reset |
| **Menu variations - Swap R/G-LED** | Off | Swap use of LED D1 and D2 (usually D1 is NOK / red and D2 is OK / green). Useful if D1 and D2 have opposite color on hardware. |
| **Menu variations - Debug menu** | Open at no vi-input | If no video input is being detected at the N64 video interface input, the N64Adv2 opens the _Debug-Info_ screen.<br> This behavior can be switched off if setting is at _Do nothing_. |
| **Unlock lucky 1440p** \[15\] | _Off_ | Unlocks 1440p resolution in the _resolution_ configuration screen |

\[15\] 1440p resolution runs over the maximum frequency specified for the FPGA and for the video transmitter IC. Therefore, it is intended that a) the setting is not in the resolution menu and b) 1440p must be unlocked! 

#### Save/Load/Fallback

| Entry | Default | Description |
|:------|:--------|:------------|
| **Save/Load - Autosave** | | Saves your current configuration every time you close the menu if enabled |
| **Save/Load - Save configuration** | | Saves your current configuration |
| **Save/Load - Load configuration** | | Loads your last saved configuration |
| **Copy - Direction** | NTSC->PAL | Determines which config is copied _from_->_to_ |
| **Copy - Copy config now** | | Copies the actual config. \[16\] | 
| **Fallback config - Resolution** | 1080p | Determines the fallback defaults (_Direct_, _480p_ or _1080p_) | 
| **Fallback config - Trigger** | Rst. button | Determines the fallback trigger (_Rst. button_, _Controller L_ or _Rst.b. or Ctrl.L_) \[17\] | 
| **Fallback config - Open menu on fb.** | On | Determines whether menu is opened on fallback or not |

\[16\] A copy from _NTSC->PAL_ also sets **Use PAL in 240p box** option to _Auto_. 240p/288p configurations stay unaffected.  
\[17\] On _Controller L_ you need to keep pressed button L on controller 1 until the game reads the controller inputs the first time.  

Note that all unsaved configuration entries in the menu are shown in yellow color.
As soon as the configuration is saved, every entry should appear in white or grey if unavailable.

#### Debug-Info

| Entry | Description |
|:------|:------------|
| **PPU state value** \[17\] | A value provided by the picture processing unit of the FPGA as feedback |
| **PPU state - VI mode** | Input resolution generated by the N64 |
| **PPU state - Frame-Lock** | Shows whether frame locked mode is enabled or not.<br>In frame locked mode it will provide the actual number of scanlines pre-buffered for the output |
| **Pin check value** \[17\] | A value representing some installation check results |
| **Pin check - CLKs** | Shows if the different systems clocks are alive.<br>- PLL: clocks generated by N64Adv2-onboard SI5358 plus clock source for the PLL (27MHz or N64 (49MHz))<br>- Sys.: System clock<br>- Aud.: Audio processing clock<br>- N64: video clock from N64 mainboard |
| **Pin check - VI** | Shows pin check results for video interface<br>- Sync: Data sync signal<br>- Data: data lines D6 down to D0 (left to right) |
| **Pin check - Audio** | Shows pin check results for audio interface<br>- ALRC: audio left/right clock<br>- ASD: audio serial data<br>- ASC: audio serial clock |
| **Re-sync VI pipeline**| Resets the video pipeline and resyncs input (i.e. video from N64) and output video<br>Might be useful in _frame locked mode_ if number of buffered scanlines does not stay constant, i.e. increase or decrease constantly |
| **Lock menu (ctrl. test)**| Locks menu inputs for testing your controller.<br>Value of the controller test \[15\] is shown in the bottom line. |

\[17\] Section [Work with the Debug-Info Page](https://github.com/borti4938/n64adv2_fw#work-with-the-debug-info-page) shows how to interpret those values

### Default Configuration

#### Boot up procedure / Fallback mode

At each power cycle, the N64Adv2 tries to load a valid configuration from its user flash memory (UFM).
In the case that this does not fail, the video processing line is setup as configured.

In the case that there is no valid configuration found, the FPGA setup certain defaults.
This might be the case if the configuration is corrupted or simply not present (e.g. very first boot or after a firmware upgrade over JTAG) or if the configuration signature is incompatible to the current firmware.
The use can vary between three different defaults: _1080p_ or _480p/576p_ (no VGA) by leaving the reset button untouched or pressed during the power cycle.

Even with a valid configuration in the UFM, it is possible to default the settings.
By holding the reset button down during a power cycle, the N64Adv2 falls back to a certain default configuration.
The defaults available for the fallback are _1080p_, _480p/576p_, and _Direct_.
This can be set up in the _Save/Load/Fw.Update_ menu.

#### Defaults

Defaulted configuration are marked above with there default value.
If no default value is provided, than the value is unaffected when loading defaults.
However, if the N64Adv2 boots with an invalid configuration in the UFM, those configurations will be set to their very first value in the list.

### Work with the Debug-Info Page

![](./doc/img/debug-info.jpg)

#### PPU state value

Shown is a hexadecimal value where each bit or bit group represents a certain feedback information provided by the FPGA.
This value contains 29 bits of following meaning:

- \[28\]: Input controller detected (1 = yes, 0 = no)
- \[27\]: HDMI clock ok (1 = yes, 0 = no)
- \[26\]: Video input detected (1 = yes, 0 = no)
- \[25\]: version of PAL leap pattern (NTSC formats do not use a leap pattern)
- \[24\]: PAL mode lines (1 = 240p, 0 = 288p)
- \[23\]: PAL/NTSC mode detected at video input (1 = PAL, 0 = NTSC)
- \[22\]: progressive/interlaced mode detected at video input (1 = interlaced, 0 = progressive)
- \[21:20\]: Refresh rate at video output (00: Auto (same as input), 01 = 60Hz, 10 = 50Hz)
- \[19\]: Use VGA instead of standard 480p (1 = yes, 0 = no) / Direct mode (0 = DV1, 1 = FX-Direct)
- \[18:16\]: Output resolution  
  - 000: Direct
  - 001: 480p/576p (4:3)
  - 010: 720p (16:9)
  - 011: 960p (4:3)
  - 100: 1080p (16:9)
  - 101: 1200p (4:3)
  - 110: 1440p (4:3)
  - 111: 1440p (16:9)
- \[15:7\]: Number of scanlines buffered in frame locked mode
- \[6\]: Frame locked mode (1 = enabled, 0 = disabled)
- \[5\]: VI-DeBlur mode (1 = enabled, 0 = disabled)
- \[4\]: 16bit color mode (1 = enabled, 0 = disabled)
- \[3:0\]: Actual gamma table

Please note that some of the values feel a bit redundant to actual configuration you made.
However, everything you can see here is the actual configuration applied by the video processing core.
In ideal case, these values should match your configuration.

For bit 28 - if no controller is being detected and you have a controller plugged in,...

- Ctrl. not detected: Check U1 (FPGA) pin 120, X1 pin 2, flex cable U1, R1, connection to PIF-NUS pin 16, and connection to RCP-NUS pin 9

#### Pin state value

This is an actual 16bit value shown as hexadecimal representing the different pin checking.
This value is completely shown with green _hearts_ or red _xs_.
A green _heart_ stands for ok, whereas a red _x_ obviously is not ok.
However, there are some bits which can be marked with a red _x_ in certain situations, e.g. if no audio is produced, the audio pin tests will fail.
The picture at the beginning of this section also shows some _xs_ although the installation is completely fine.

Here are some points to check if you have some red values.
If not otherwise mentioned, chips and component designators are on N64Adv2 main board.

- PLL: Check U1 (FPGA) pin 28 and 29 and/or check SI5358 (U4) and area around this chip (e.g. Y41), possibly also U1 (FPGA) pin 17 in frame lock mode and R14
- Sys: You should not be able the menu if this marked with a red _x_... Check U5, U7 and U1 (FPGA) pin 27
- Aud.: Check U6, U7 and U1 (FPGA) pin 26
- N64: U1 (FPGA) pin 130, X1 pin 9, flex cable RN3, and connection to RCP-NUS pin 11
- Sync: Check U1 (FPGA) pin 131, X1 pin 11, flex cable RN3, and connection to RCP-NUS pin 14
- Data: from left to right
  - D6: Check U1 (FPGA) pin 132, X1 pin 13, flex cable RN2, and connection to RCP-NUS pin 15
  - D5: Check U1 (FPGA) pin 134, X1 pin 14, flex cable RN2, and connection to RCP-NUS pin 18
  - D4: Check U1 (FPGA) pin 135, X1 pin 15, flex cable RN2, and connection to RCP-NUS pin 19
  - D3: Check U1 (FPGA) pin 140, X1 pin 16, flex cable RN2, and connection to RCP-NUS pin 20
  - D2: Check U1 (FPGA) pin 141, X1 pin 17, flex cable RN1, and connection to RCP-NUS pin 23
  - D1: Check U1 (FPGA) pin 127, X1 pin 18, flex cable RN1, and connection to RCP-NUS pin 24
  - D0: Check U1 (FPGA) pin 124, X1 pin 19, flex cable RN1, and connection to RCP-NUS pin 25
- ALRC: Check U1 (FPGA) pin 123, X1 pin 7, flex cable RN4, and connection to RCP-NUS pin 9
- ASD: Check U1 (FPGA) pin 122, X1 pin 6, flex cable RN4, and connection to RCP-NUS pin 7
- ASC: Check U1 (FPGA) pin 121, X1 pin 4, flex cable RN4, and connection to RCP-NUS pin 6

Pin tests are reset by laving this menu or by executing the _Re-sync VI pipeline_ function.

#### Re-sync VI pipeline

Resets the video pipeline and resyncs input (i.e. video from N64) and output video.
This might be useful in _frame locked mode_ if number of buffered scanlines does not stay constant, i.e. increase or decrease constantly.

Running this function also resets the pin tests.

#### Lock menu (ctrl. test)

This locks menu for any inputs other than directional pad right.
If locked, you can freely test your controller for any inputs.
The 32 bits in the hexadecimal value shown at the bottom, are the following:

- \[31:24\] 8bit value for y axis of the joystick
- \[23:16\] 8bit value for x axis of the joystick
- \[15:12\] C-button right, left, down, and up
- \[11:10\] L and R button
- \[9:8\] _unused_
- \[7:4\] D-pad right, left, down, and up
- \[3\] Start button
- \[2\] Z button
- \[1\] B button
- \[0\] A button

Again, if you locked the menu, use D-pad right to unlock the screen.

### Firmware Update

#### Via JTAG

In order to update, you need to have:

- an Altera USB Blaster (or clone) for flashing the firmware
  - external connected to the 10pin JTAG header on the N64Adv2 board, or
  - with the on board add on solution \[1\]
- _Quartus Prime Programmer_ software installed on your computer  
(Programmer software is offered as stand-alone application; so you don't need to have the whole Quartus Prime suite installed.)

\[1\] Using the [FPGA Programmer2 SMD-Module](https://shop.trenz-electronic.de/de/TEI0005-02-FPGA-USB-Programmer2-SMD-Modul-VPE1?c=26) needs you to have [separate drivers](https://shop.trenz-electronic.de/de/Download/?path=Trenz_Electronic/Software/Drivers/Arrow_USB_Programmer) installed.

The update procedure is as follows:
- Download the latest firmware from the [Github Repository Release Page](https://github.com/borti4938/n64adv2_fw/releases)
- Start the _Quartus Prime Programmer_ software
- Select the programmer adapter under _Hardware Setup..._ if not automatically selected
- Add the programming file with _Add File..._  
  - Programming file ends with _\*.pof_.
  - Programming file is named after the FPGA - either _n64adv2\_**10m16sae144**_ or _n64adv2\_**10m25sae144**dev_
- Check _Program / Configure_ and _Verify_ for the whole device (_CFM0_ and _UFM_ should be checked)
- Click on _Start_ and wait patiently  
Please note that the **console must be turned on** in order to provide a reference target voltage for the programming device.

Please note that with this update procedure, your configuration becomes invalid.
However, you can try the workaround described below, which is not extensively tested.
The following picture summarizes the procedure.

![](./doc/img/jtag_update.jpg)

#### JTAG - Configuration Workaround

This workaround works if and only if the configuration signature of the running firmware matches the firmware you want to flash.
If this is not the case, you do not have to continue.
The workaround is as follows:
- Power the N64 with a game running
- Go into _\[Save/Load/Fallback\]_ menu
- On you computer:
  - Follow the steps above with just a minor difference
  - Make sure that also **Enable real-time ISP to allow background programming when available** is checked
  - Flash the firmware, which takes a bit longer than without the _real-time ISP_ option
  - Wait for the programming procedure to be finished and **do not touch the controller** meanwhile  
  Pleas note that the menu text on the right hand side may doing some quirk
- Once the programmer finished his work, save the configuration by pressing two times **D-ri**
- power cycle the N64


## Developer Information

### Repository Management

After cloning the repository, you will find several folders.
Here is a description of what to find where.
Please note that subfolders are not necessarily outlined.

| Folder | Description |
|:-------|:------------|
| **doc** | Documentation related files (e.g. certain pictures) |
| **ip** | IP cores used by the hardware design |
| **lib** | Verilog header files and task files (out-sourced Verilog tasks and functions used in Verilog hardware design) |
| **nios** | Basis NIOS II core design<br>also includes IP cores used for the NIOS II system design<br>Default path to the NIOS II software project |
| **quartus** | Relevant project and revision files for the hardware design |
| **rtl** | Verilog hardware description files |
| **scripts** | Location of all scripts and other things I used throughout the development to generate certain sources |
| **sdc** | SDC (Standard Design Constraints or Synopsys Design Constraints) files |
| **sw** | Software sources for the NIOS II soft core |


### Setup Toolchain

The following instruction does not explain how to use the certain tools and/or to manage your personal design flow.
It is meant as a first instruction how to setup the N64Adv2 development.
For serious development I recommend using the 10M25SAE144 FPGA as it offers more resources for debugging cores than the 10M16SAE144.


#### Software Requirements

- Quartus Prime Lite by intelFPGA (currently version 21.1) with Max10 FPGA device support
- NIOS II EDS
  - Windows requires Ubuntu 18.04 LTS on Windows Subsystem for Linux (WSL) in version 1 (WSL 2 is not compatible)
  - Description here uses Eclipse IDE as suggested by intelFPGA, however, other IDEs are possible, too
  - Both requires manual installation beside of Quartus Prime toolchain
  - see also _path\_to\_quartus\_installation_/nios2eds/bin/README


#### Hardware Description

If not already done, clone the GIT source.
Open the [project file](./quartus/n64adv2.qpf) with Quartus Prime Lite.
Afterwards select the revision you like to work with; a quick switch is located in the middle of the control/symbol bar.
The revision is named after the FPGA you'd like to use / build the firmware for.

The first time you use the sources you need to generate certain IP-cores.
- Switch the _Project Navigator_ to _IP Components_
- Open following IP core and
  - chip\_id: Click on _Finish_ (Core is then generated automatically)
- Other IP cores do not need to be generated.
- The IP cores based on QSYS (Platform Designer) are optional to build as this is done dynamically during synthesis.  
  However, pre-building them reduces compilation time a lot and is recommended during development.

Once the IP cores are ready, you can _Compile Design_ (e.g. using the shortcut Ctrl. + L).
If everything went correct the design should compile just fine (Warnings are ok).

#### Pre-Building QSYS-IPs (Optional)

In order to pre-build the QSYS-IPs
- Open the _Platform Designer_ (Tools -> Platform Designer)
- Open one after the other (File -> Open... / Ctrl. + O):
  - ./ip/altclkctrl.qsys
  - ./ip/fir\_2ch\_audio.qsys
  - ./nios2/system\_n64adv2.qsys
- and for each:
  - click on _Generate HDL..._, on _Generate_ and _Close_ in the pop-up windows  
  - and then on _Finish_ after the last IP

The cores "altclkctrl.qsys" and "fir\_2ch\_audio.qsys" just need to be generated the first time you want to build the project.
You are allowed to switch between revisions without re-generating the cores again.
In contrast, the NIOS II system design needs to be re-generated if the revision changes (i.e. not only the first time).
Of course, a change in any IP design needs you to re-generate the core, too.

In order to now use the pre-builds, you have to open ./quartus/n64adv2\_10m16sae144.qsf and/or ./quartus/n64adv2\_10m25sae144dev.qsf, respectively.
In each file change the lines
~~~~
#qsys-ip
#set_global_assignment -name QIP_FILE ../ip/altclkctrl/synthesis/altclkctrl.qip
#set_global_assignment -name QIP_FILE ../nios/system_n64adv2/synthesis/system_n64adv2.qip
#set_global_assignment -name QIP_FILE ../ip/fir_2ch_audio/synthesis/fir_2ch_audio.qip

set_global_assignment -name QSYS_FILE ../ip/altclkctrl.qsys
set_global_assignment -name QSYS_FILE ../ip/fir_2ch_audio.qsys
set_global_assignment -name QSYS_FILE ../nios/system_n64adv2.qsys
~~~~
to
~~~~
#qsys-ip
set_global_assignment -name QIP_FILE ../ip/altclkctrl/synthesis/altclkctrl.qip
set_global_assignment -name QIP_FILE ../nios/system_n64adv2/synthesis/system_n64adv2.qip
set_global_assignment -name QIP_FILE ../ip/fir_2ch_audio/synthesis/fir_2ch_audio.qip

#set_global_assignment -name QSYS_FILE ../ip/altclkctrl.qsys
#set_global_assignment -name QSYS_FILE ../ip/fir_2ch_audio.qsys
#set_global_assignment -name QSYS_FILE ../nios/system_n64adv2.qsys
~~~~
By the time this guide was written these lines were found around 260.
Now you are using the pre-builded QSYS-IPs during synthesis.
This speeds up compalition time a lot.


#### Software Core

In Quartus Prime you have a shortcut to the NIOS II EDS.
Launch Eclipse via the menu: _Tools_ -> _NIOS II Software Build Tools for Eclipse_.
If Eclipse does not start, go back to [Software Requirements](https://github.com/borti4938/n64adv2_fw#software-requirements) and follow the "NIOS II EDS" instructions.

Upon launching Eclipse you can select a workspace.
I suggest using _path\_to\_local\_git\_repo_/nios/software/.
You should be welcomed with an empty _Project Explorer_.
Follow the given instructions:

- Right-click in the _Project Explorer_ and choose _New_ -> _Nios II Application_
- In the pop-up window, you'll find a _Create..._ button which you can click on.
  This creates you a board supported package (BSP) project.
- For the Nios II BSP, setup the project as follows:
  - Project name: controller\_bsp
  - SOPC Information File name: _path\_to\_local\_git\_repo_/nios/system_n64adv2.sopcinfo  
    (must be an absolute path)
  - Check at Use default location
  - Click on _Finish_ creates you the BSP project
- Back in the Nios II Application window, a BSP location should be filled now.
  Setup the rest as follows:
  - Project name: controller\_app
  - Check at Use default location
  - Click on _Finish_ creates you the application project

Now you should have **two projects** in your Project Explorer.


##### BSP Settings

The first time you start with the softcore development, you'll need to adjust some BSP settings.
- Right-click on controller\_bsp project -> _Nios II_ -> _BSP Editor_
- Modify following settings in the _Main_ tab:
  - Select _Common_ and
    - Check _enable\_small\_c\_library_
    - Check _enable\_reduced\_device\_drivers_
    - Set _bsp\_cflags\_optimization_ to -Os
  - Select _Advanced_ and
    - Uncheck _enable\_exit_
    - Uncheck _enable\_clean\_exit_
    - Uncheck _enable\_c\_plus\_plus_
    - Check _enable\_lightweight\_device\_driver\_api_
    - Uncheck _enable\_sopc\_sysid\_check_
- Switch to _Linker Script_ Tab:
  - Under _Link Memory Regions_
    - _Remove..._ region _onchip\_flash\_0\_data_
    - _Add..._ region name `onchip_flash_0_data` with size `16384` and offset `0` on memory device `onchip_flash_0_data`
    - _Add..._ region name `onchip_flash_0_cfg` with size `16384` and offset `16384` on memory device `onchip_flash_0_data`
  - Under _Link Section Name_
    - _Add..._ section name `.ufm_data_rom` with memory region `onchip_flash_0_data_`
- Once everything is set, you can click on _Generate_ and _Exit_ the BSP Editor_

The Linker Script should look like that!
Note that the created section name has a leading dot!

![](./doc/img/bsp_linker.jpg)

If everything is correct, there is only a need to _Generate BSP_ (Right-click on controller\_bsp project -> _Nios II_ -> _Generate BSP_) if the BSP timestamp is outdated.
The software build will let you know about that with an error.

##### Software Settings

First, we add the software sources to the project.
The you have to set the build properties.

- Import sources:
  - Right-click on the project and select _Import..._
  - Select _General_ -> _File System_ and click on button _Next >_
  - Insert _path\_to\_local\_git\_repo_/sw to _From directory_
  - Check _sw_
  - Under _Advanced_ check _Create links in workspace_
  - Click on _Finish_
- A folder named _sw_ should appear in the project folder
- Add source files to Nios II build
  - Mark all files in sw folder (usually you only need to add the c-files)
  - Right-click and select _Add to Nios II build_
- Setup application properties
  - Right-click on project folder and select _Properties_
  - Choose _Nios II Application Properties_
  - Change _Debug level:_ to _Off_
  - Change _Optimization level:_ to _Size_

![](./doc/img/app_config.jpg)

From this point on you should be able to build the application project.
With the shortcut _Ctrl + F9_ (or just _F9_) you can create initialization files with the _mem\_init\_generate_ target.

If the build fails with an error in elf2dat line 2 under Windows (_cannot find /bin/sh_pl.sh_), you have to create an environment variable with following properties.
- name: `WSLENV`
- value: `SOPC_KIT_NIOS2/p`
After logging out and logging in into your account, the build should work.

By default, certain constants are placed in the user flash memory.
However, during development this is not always wanted and somehow annoying during development.
The following steps initiates the linker to place those constants in the BRAM memory, which consumes a bit more BRAM resources.

Open the Makefile and include the following lines between line no. 32 (`ALT_CFLAGS :=`) and no. 33 (`ALT_CXXFLAGS :=`):

````
ifeq ($(DEBUG),y)
ALT_CFLAGS += -DDEBUG
endif
````
Save the Makefile.
This step has only be made one time.

Afterwards you can create a _Debug build_ as follows
- Right-click on project folder and select _Properties_
- Select _C/C++ Build_
- Click on _Manage Configurations..._ and in the pop-up window on _New..._
  - _Name:_ Nios II Debug
  - Click on _OK_ 
  - Set _Nios II Debug_ as active and close the _Manage Configurations..._ window
- In the _C/C++ Build_ properties window select the new configuration (should be marked with _\[Active\]_
- Add `DEBUG=y` to the _Build command_ (full line is e.g. `wsl make DEBUG=y`)

Now, every time you opt for  _Nios II Debug_ configuration (Right-click -> _Build Configurations_ -> _Set Active_ -> ...) constants which are meant to be placed in the UFM will be stored in the BRAM memory.
Optionally you can also modify the _mem\_init\_generate_ target to use `DEBUG=y`.

### Build Firmware

Following steps are needed:
- Nios II App (if application or Nios II system has been changed)
  - Build the BSP
  - Clean controller\_app and build the app with _mem\_init\_generate_
- Hardware Design (all)
  - Run _Compile Design_ task
- Hardware Design (sw-update only)
  - Select _processing_ -> _Update Memory Initialization File_
  - Run _Assembler_ task
- Build _POF_:
  - Open _File_ -> _Convert Programming File_
  - _Open Conversion Setup Data..._
  - Select _path\_to\_local\_git\_repo_/quartus/n64adv2_10m16sae144.cof or _path\_to\_local\_git\_repo_/quartus/n64adv2_10m25sae144dev.cof depending on your targeting FPGA
  - Click on _Create_ button and _Close_  
    (you may have to confirm that you want to overwrite the old file)
