
### Repository Management

After cloning the repository, you will find several folders.
Here is a description of what to find where.
Please note that not every subfolder is neccessarily outlined.

| Folder | Subfolder  | Description |
|-------:|:----------:|:------------|
| **doc** | | Documentation related files (e.g. certain pictures) |
| **ip** | | IP cores used by the hardware design |
| **nios** | <br>**ip**<br>**software**| NIOS II core design<br>IP cores used for the NIOS II system design<br>Default path to the NIOS II software project |
| **quartus** | | Relevant project and revision files for the hardware design |
| **rtl** | | Verilog hardware description files |
| **scripts** | | Location of all scripts and other things I used throughout the development to generate certain sources |
| **sdc** | | SDC (Standard Design Constraints or Synopsys Design Constraints) files |
| **sw** | | Software sources for the NIOS II soft core |
| **tasks** | | Out-sourced verilog tasks and functions used in verilog hardware design |
| **vh** | | Verilog header files |


### Setup Toolchain

The following instruction does not explain how to use the certain tools and/or to manage your personal design flow.
It is meant as a first instruction how to setup the N64Adv2 development.
For serious development I recommend using the 10M25SAE144 FPGA as it offers more resources for debugging cores then the 10M16SAE144.


#### Software Requirements

- Quartus Prime Lite by intelFPGA (currently version 21.1) with Max10 FPGA device support
- NIOS II EDS
  - Windows requires Ubuntu 18.04 LTS on Windows Subsystem for Linux (WSL)
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
  - altclkctrl: Click on _Generate HDL..._, on _Generate_ and _Close_ in the pop-up windows and then on _Finish_
  - chip\_id: Click on _Finish_ (Core is then generated automatically)
  - fir\_2ch\_audio: Click on _Finish_ (Core is then generated automatically)
  - system\_pll: Click on _Finish_ (Core is then generated automatically)  

These cores just need to be generated the first time you want to build the project.
You are allowed to switch between revisions without re-generating the cores again.
In contrast, the NIOS II system design needs to be generated if the revision changes (i.e. not only the first time).
- Open the system\_n64adv2 IP
- Click on _Generate HDL..._, on _Generate_ and _Close_ in the pop-up windows and then on _Finish_

Of course, a change in any IP design needs you to re-generate the core, too.
Once the IP cores are ready, you can _Compile Design_ (e.g. using the shortcut Ctrl. + L).
If everything went correct the design should compile just fine (Warnings are ok).


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
- Back in the Nios II Appication window, a BSP location should be filled now.
  Setup the rest as follows:
  - Project name: controller\_app
  - Check at Use default location
  - Click on _Finish_ creates you the application project

Now you should have **two projects** in your Project Explorer.


##### BSP Settings

The first time you start with the softcore development, you'll need to adjust sime BSP settings.
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
    - _Add..._ region name _onchip\_flash\_0\_data_ with size 16384 and offset 0
    - _Add..._ region name _onchip\_flash\_0\_cfg_ with size 16384 and offset 16384
  - Under _Link Section Name_
    - _Add..._ section name _.ufm\_data\_rom_ with memory region _onchip\_flash\_0\_data_
- Once everything is set, you can click on _Generate_ and _Exit_ the BSP Editor_

The Linker Script should look like that!
Note that the created section name has a leading dot!

![](./doc/img/bsp_linker.jpg)

Once they are settled, there is only need to _Generate BSP_ (Right-click on controller\_bsp project -> _Nios II_ -> _Generate BSP_) if the BSP timestamp is outdated.

##### Software Setting

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
  - Choose _Nios II Application Prpoerties_
  - Change _Debug level:_ to _Off_
  - Change _Optimization level:_ to _Size_

![](./doc/img/app_config.jpg)

From this point on you should be able to build the application project.
With the shortcut _Ctrl + F9_ (or just _F9_) you can create initialization files with the _mem\_init\_generate_ target.

By default, certain constants are placed in the user flash memeory.
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
  - _Name:_ Nios II Debug_
  - Click on _OK_ 
  - Set _Nios II Debug_ as active and close the _Manage Configurations..._ window
- In the _C/C++ Build_ properties window select the new configuration (should be marked with _\[Active\]_
- Add `DEBUG=y` to the _Build command_ (full line is e.g. `wsl make DEBUG=y`)

Now, everytime you opt for  _Nios II Debug_ configuration (Right-click -> _Build Configurations_ -> _Set Active_ -> ...) constants which are meant to be placed in the UFM will be stored in the BRAM memory.
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
