// Testbench for Micron SDR SDRAM Verilog models

`timescale 1ns / 1ps

module test;

reg         [15 : 0] dq;                            // SDRAM I/O
reg         [12 : 0] addr;                          // SDRAM Address
reg          [1 : 0] ba;                            // Bank Address
reg                  clk;                           // Clock
reg                  cke;                           // Synchronous Clock Enable
reg                  cs_n;                          // CS#
reg                  ras_n;                         // RAS#
reg                  cas_n;                         // CAS#
reg                  we_n;                          // WE#
reg          [1 : 0] dqm;                           // I/O Mask

wire        [15 : 0] DQ = dq;

parameter            hi_z = 16'bz;                  // Hi-Z

parameter            tCK = 7;                       // Clock Period

mt48lc16m16a2 sdram0 (DQ, addr, ba, clk, cke, cs_n, ras_n, cas_n, we_n, dqm);

initial begin
    clk = 1'b0;
    cke = 1'b0;
    cs_n = 1'b1;
    dq  = hi_z;
end

always #3.5 clk = ~clk;

/*
always @ (posedge clk) begin
    $strobe("at time %t clk=%b cke=%b CS#=%b RAS#=%b CAS#=%b WE#=%b dqm=%b addr=%b ba=%b DQ=%d",
            $time, clk, cke, cs_n, ras_n, cas_n, we_n, dqm, addr, ba, DQ);
end
*/

task active;
    input  [1 : 0] bank;
    input [12 : 0] row;
    input [15 : 0] dq_in;
    begin
        cke   = 1;
        cs_n  = 0;
        ras_n = 0;
        cas_n = 1;
        we_n  = 1;
        dqm   = 0;
        ba    = bank;
        addr  = row;
        dq    = dq_in;
    end
endtask

task auto_refresh;
    begin
        cke   = 1;
        cs_n  = 0;
        ras_n = 0;
        cas_n = 0;
        we_n  = 1;
        dqm   = 0;
        //ba    = 0;
        //addr  = 0;
        dq    = hi_z;
    end
endtask

task burst_term;
    input [15 : 0] dq_in;
    begin
        cke   = 1;
        cs_n  = 0;
        ras_n = 1;
        cas_n = 1;
        we_n  = 0;
        dqm   = 0;
        //ba    = 0;
        //addr  = 0;
        dq    = dq_in;
    end
endtask

task load_mode_reg;
    input [12 : 0] op_code;
    begin
        cke   = 1;
        cs_n  = 0;
        ras_n = 0;
        cas_n = 0;
        we_n  = 0;
        dqm   = 0;
        ba    = 0;
        addr  = op_code [12 :  0];
        dq    = hi_z;
    end
endtask

task nop;
    input  [1 : 0] dqm_in;
    input [15 : 0] dq_in;
    begin
        cke   = 1;
        cs_n  = 0;
        ras_n = 1;
        cas_n = 1;
        we_n  = 1;
        dqm   = dqm_in;
        //ba    = 0;
        //addr  = 0;
        dq    = dq_in;
    end
endtask

task precharge_bank_0;
    input  [1 : 0] dqm_in;
    input [15 : 0] dq_in;
    begin
        cke   = 1;
        cs_n  = 0;
        ras_n = 0;
        cas_n = 1;
        we_n  = 0;
        dqm   = dqm_in;
        ba    = 0;
        addr  = 0;
        dq    = dq_in;
    end
endtask

task precharge_bank_1;
    input  [1 : 0] dqm_in;
    input [15 : 0] dq_in;
    begin
        cke   = 1;
        cs_n  = 0;
        ras_n = 0;
        cas_n = 1;
        we_n  = 0;
        dqm   = dqm_in;
        ba    = 1;
        addr  = 0;
        dq    = dq_in;
    end
endtask

task precharge_bank_2;
    input  [1 : 0] dqm_in;
    input [15 : 0] dq_in;
    begin
        cke   = 1;
        cs_n  = 0;
        ras_n = 0;
        cas_n = 1;
        we_n  = 0;
        dqm   = dqm_in;
        ba    = 2;
        addr  = 0;
        dq    = dq_in;
    end
endtask

task precharge_bank_3;
    input  [1 : 0] dqm_in;
    input [15 : 0] dq_in;
    begin
        cke   = 1;
        cs_n  = 0;
        ras_n = 0;
        cas_n = 1;
        we_n  = 0;
        dqm   = dqm_in;
        ba    = 3;
        addr  = 0;
        dq    = dq_in;
    end
endtask

task precharge_all_bank;
    input  [1 : 0] dqm_in;
    input [15 : 0] dq_in;
    begin
        cke   = 1;
        cs_n  = 0;
        ras_n = 0;
        cas_n = 1;
        we_n  = 0;
        dqm   = dqm_in;
        ba    = 0;
        addr  = 1024;            // A10 = 1
        dq    = dq_in;
    end
endtask

task read;
    input  [1 : 0] bank;
    input [12 : 0] column;
    input [15 : 0] dq_in;
    input  [1 : 0] dqm_in;
    begin
        cke   = 1;
        cs_n  = 0;
        ras_n = 1;
        cas_n = 0;
        we_n  = 1;
        dqm   = dqm_in;
        ba    = bank;
        addr  = column;
        dq    = dq_in;
    end
endtask

task write;
    input  [1 : 0] bank;
    input [12 : 0] column;
    input [15 : 0] dq_in;
    input  [1 : 0] dqm_in;
    begin
        cke   = 1;
        cs_n  = 0;
        ras_n = 1;
        cas_n = 0;
        we_n  = 0;
        dqm   = dqm_in;
        ba    = bank;
        addr  = column;
        dq    = dq_in;
    end
endtask

initial begin
    begin
        // Initialize
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; precharge_all_bank(0, hi_z);      // Precharge ALL Bank
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; auto_refresh;                     // Auto Refresh
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; auto_refresh;                     // Auto Refresh
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; load_mode_reg (50);               // Load Mode: Lat = 3, BL = 4, Seq
        #tCK; nop    (0, hi_z);                 // Nop

        // Write with auto precharge to bank 0 (non-interrupt)
        #tCK; active (0, 0, hi_z);              // Active: Bank = 0, Row = 0
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; write  (0, 1024, 100, 0);         // Write : Bank = 0, Col = 0, Dqm = 0, Auto Precharge
        #tCK; nop    (0, 101);                  // Nop
        #tCK; nop    (0, 102);                  // Nop
        #tCK; nop    (0, 103);                  // Nop
        #tCK; nop    (0, hi_z);                 // Nop

        // Write with auto precharge to bank 1 (non-interrupt)
        #tCK; active (1, 0, hi_z);              // Active: Bank = 1, Row = 0
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; write  (1, 1024, 200, 0);         // Write : Bank = 1, Col = 0, Dqm = 0, Auto precharge
        #tCK; nop    (0, 201);                  // Nop
        #tCK; nop    (0, 202);                  // Nop
        #tCK; nop    (0, 203);                  // Nop
        #tCK; nop    (0, hi_z);                 // Nop

        // Write with auto precharge to bank 2 (non-interrupt)
        #tCK; active (2, 0, hi_z);              // Active: Bank = 2, Row = 0
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; write  (2, 1024, 300, 0);         // Write : Bank = 2, Col = 0, Dqm = 0, Auto Precharge
        #tCK; nop    (0, 301);                  // Nop
        #tCK; nop    (0, 302);                  // Nop
        #tCK; nop    (0, 303);                  // Nop
        #tCK; nop    (0, hi_z);                 // Nop

        // Write with auto precharge to bank 3 (non-interrupt)
        #tCK; active (3, 0, hi_z);              // Active: Bank = 3, Row = 0
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; write  (3, 1024, 400, 0);         // Write : Bank = 3, Col = 0, Dqm = 0, Auto precharge
        #tCK; nop    (0, 401);                  // Nop
        #tCK; nop    (0, 402);                  // Nop
        #tCK; nop    (0, 403);                  // Nop
        #tCK; nop    (0, hi_z);                 // Nop

        // Read with auto precharge to bank 0 (non-interrupt)
        #tCK; active (0, 0, hi_z);              // Active: Bank = 0, Row = 0
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; read   (0, 1024, hi_z, 0);        // Read  : Bank = 0, Col = 0, Dqm = 0, Auto precharge
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop

        // Read with auto precharge to bank 1 (non-interrupt)
        #tCK; active (1, 0, hi_z);              // Active: Bank = 1, Row = 0
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; read   (1, 1024, hi_z, 0);        // Read  : Bank = 1, Col = 0, Dqm = 0, Auto precharge
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop

        // Read with auto precharge to bank 2 (non-interrupt)
        #tCK; active (2, 0, hi_z);              // Active: Bank = 2, Row = 0
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; read   (2, 1024, hi_z, 0);        // Read  : Bank = 2, Col = 0, Dqm = 0, Auto precharge
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop

        // Read with auto precharge to bank 3 (non-interrupt)
        #tCK; active (3, 0, hi_z);              // Active: Bank = 3, Row = 0
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; read   (3, 1024, hi_z, 0);        // Read  : Bank = 3, Col = 0, Dqm = 0, Auto precharge
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop

        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK; nop    (0, hi_z);                 // Nop
        #tCK;
    end
$stop;
$finish;
end

endmodule


