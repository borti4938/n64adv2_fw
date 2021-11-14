

module scanline_emu (
  VCLK_i,
  nVRST_i,

  HSYNC_i,
  VSYNC_i,
  DE_i,
  vdata_i,

  drawSL_i,
  sl_settings_i,
  
  HSYNC_o,
  VSYNC_o,
  DE_o,
  vdata_o

);

`include "../../vh/n64adv_vparams.vh"

input VCLK_i;
input nVRST_i;

input HSYNC_i;
input VSYNC_i;
input DE_i;
input [`VDATA_O_CO_SLICE] vdata_i;

input [2:0] drawSL_i;
input [16:0] sl_settings_i;

output reg HSYNC_o;
output reg VSYNC_o;
output reg DE_o;
output reg [`VDATA_O_CO_SLICE] vdata_o;

// misc (params and unpacking inputs)

localparam proc_stages = 8;
localparam Y_width     = color_width_o+1;
localparam SLHyb_width = 8; // do not change this localparam!

wire [4:0]  SLHyb_depth = sl_settings_i[16:12];
wire [7:0]       SL_str = sl_settings_i[11: 4];
wire [1:0] SL_thickness = sl_settings_i[ 3: 2];
wire              SL_id = sl_settings_i[ 1];
wire              SL_en = sl_settings_i[ 0];

wire drawSL_en = SL_thickness == 2'b10 ? |drawSL_i :
                 SL_thickness == 2'b01 ? |{drawSL_i[1:0]} :
                                         drawSL_i[{1'b0,SL_id}];

integer int_idx;


// wires

wire [Y_width+4:0] Y_ref_pre_full_w;
wire [Y_width+SLHyb_width-1:0] Y_ref_full_w;
wire [color_width_o+SLHyb_width-1:0] R_sl_full_w, G_sl_full_w, B_sl_full_w;


// regs

reg [proc_stages-2:0] HSYNC_l, VSYNC_l, DE_l  /* synthesis ramstyle = "logic" */;
reg [color_width_o-1:0] R_l [0:proc_stages-2] /* synthesis ramstyle = "logic" */;
reg [color_width_o-1:0] G_l [0:proc_stages-2] /* synthesis ramstyle = "logic" */;
reg [color_width_o-1:0] B_l [0:proc_stages-2] /* synthesis ramstyle = "logic" */;

reg [color_width_o:0] RpB_l;
reg [Y_width-1:0] Y_l;

reg [Y_width-1:0] Y_ref_pre_l;
reg [Y_width-1:0] Y_ref_l;

reg [SLHyb_width-1:0] SLHyb_rval_l, SLHyb_str_l;

reg [color_width_o-1:0] R_sl_l, G_sl_l ,B_sl_l;


assign Y_ref_pre_full_w = Y_l * (* multstyle = "dsp" *) SLHyb_depth;
assign Y_ref_full_w = Y_ref_pre_l * (* multstyle = "dsp" *) SL_str;
assign R_sl_full_w = R_l[5] * (* multstyle = "dsp" *) SLHyb_str_l;
assign G_sl_full_w = G_l[5] * (* multstyle = "dsp" *) SLHyb_str_l;
assign B_sl_full_w = B_l[5] * (* multstyle = "dsp" *) SLHyb_str_l;


always @(posedge VCLK_i or negedge nVRST_i)
  if (!nVRST_i) begin
    HSYNC_l <= {(proc_stages-1){1'b0}};
    VSYNC_l <= {(proc_stages-1){1'b0}};
    DE_l <= {(proc_stages-1){1'b0}};
    for (int_idx = 0; int_idx < proc_stages-1; int_idx = int_idx + 1) begin
      R_l[int_idx] <= {color_width_o{1'b0}};
      G_l[int_idx] <= {color_width_o{1'b0}};
      B_l[int_idx] <= {color_width_o{1'b0}};
    end
    
    RpB_l <= {(color_width_o+1){1'b0}};
    Y_l = {Y_width{1'b0}};
    
    Y_ref_pre_l <= {Y_width{1'b0}};
    Y_ref_l <= {Y_width{1'b0}};
    
    SLHyb_rval_l <= {SLHyb_width{1'b0}};
    SLHyb_str_l <= {SLHyb_width{1'b0}};
    
    R_sl_l <= {color_width_o{1'b0}};
    G_sl_l <= {color_width_o{1'b0}};
    B_sl_l <= {color_width_o{1'b0}};
    
    HSYNC_o <= 1'b0;
    VSYNC_o <= 1'b0;
    DE_o <= 1'b0;
    vdata_o <= {3*color_width_o{1'b0}};
  end else begin
    HSYNC_l <= {HSYNC_l[proc_stages-3:0],HSYNC_i};
    VSYNC_l <= {VSYNC_l[proc_stages-3:0],VSYNC_i};
    DE_l <= {DE_l[proc_stages-3:0],DE_i};
    for (int_idx = 1; int_idx < proc_stages-1; int_idx = int_idx + 1) begin
      R_l[int_idx] <= R_l[int_idx-1];
      G_l[int_idx] <= G_l[int_idx-1];
      B_l[int_idx] <= B_l[int_idx-1];
    end
    R_l[0] <= vdata_i[`VDATA_O_RE_SLICE];
    G_l[0] <= vdata_i[`VDATA_O_GR_SLICE];
    B_l[0] <= vdata_i[`VDATA_O_BL_SLICE];
    
    // approximate luma (2 proc. stages)
    RpB_l <= {1'b0,vdata_i[`VDATA_O_RE_SLICE]} + {1'b0,vdata_i[`VDATA_O_BL_SLICE]}; // stage [0]
    Y_l <= {1'b0,G_l[0]} + {1'b0,RpB_l[color_width_o:1]};                           // stage [1]

    // hybrid strength reference (2 proc. stages)
    Y_ref_pre_l <= Y_ref_pre_full_w[Y_width+4:5];                   // stage [2]
    Y_ref_l     <= Y_ref_full_w[Y_width+SLHyb_width-1:SLHyb_width]; // stage [3]

    // adaptation of sl_str. (2 proc. stages)
    SLHyb_rval_l <= {1'b0,SL_str} < Y_ref_l ? 8'h0 : SL_str - Y_ref_l[7:0]; // stage [4]
    SLHyb_str_l  <= 8'hff - SLHyb_rval_l;                                   // stage [5]
    
    // calculate SL (1 proc. stage)
//    R_sl_l <= R_sl_full_w[color_width_o+SLHyb_width-2:SLHyb_width-1]; // stage [6]
//    G_sl_l <= G_sl_full_w[color_width_o+SLHyb_width-2:SLHyb_width-1]; // stage [6]
//    B_sl_l <= B_sl_full_w[color_width_o+SLHyb_width-2:SLHyb_width-1]; // stage [6]
    R_sl_l <= R_sl_full_w[color_width_o+SLHyb_width-1:SLHyb_width]; // stage [6]
    G_sl_l <= G_sl_full_w[color_width_o+SLHyb_width-1:SLHyb_width]; // stage [6]
    B_sl_l <= B_sl_full_w[color_width_o+SLHyb_width-1:SLHyb_width]; // stage [6]
    
    // decide for output (1 proc. stage)
    HSYNC_o <= HSYNC_l[proc_stages-2];
    VSYNC_o <= VSYNC_l[proc_stages-2];
    DE_o <= DE_l[proc_stages-2];
    
    if (DE_o && SL_en && drawSL_en)
      vdata_o <= {R_sl_l,G_sl_l,B_sl_l};
    else
      vdata_o <= {R_l[proc_stages-2],G_l[proc_stages-2],B_l[proc_stages-2]};
  end


endmodule
