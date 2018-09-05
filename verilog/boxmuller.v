//***************************************************************************//
//***************************************************************************//
//  Copyright (c) zhanxn87
//  All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a 
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense, 
//  and/or sell copies of the Software, and to permit persons to whom the 
//  Software is furnished to do so, subject to the following conditions:
//
//  -The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
//  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
//  DEALINGS IN THE SOFTWARE.
//---------------------------------------------------------------------------//
//---------------------------------------------------------------------------//
//  Design Name          :  boxmuller
//  Create by            :  zhanxn
//  Email                :  zhanxn@gmail.com
//  Create Date          :  Wed Aug 22 18:22:38 CST 2018
//  Function Description :  
//    A Gaussion Signal Generator based on Box-Muller Algorithm, which can be
//    used on FPGA accurate to one unit in the last place up to 8.15 sigma.
//
//    The Box-Muller Algorithm fixed point model mainly refers to the paper:
//    -D. U. Lee, J. D. Villasenor, W. Luk, and P. H. W. Leong, "hardware
//     Gaussian noise generator using the box-muller method and its error
//     analysis", IEEE Transactions on Computers, vol.55, no.6, pp.659.71,
//     June 2006.
//
//    input ports:
//      clock : single clock synchronization design, 
//      rst_n : negtive valid reset signal from outside control
//      init  : initial control signal to init the TAUS URNG status
//      ce    : clock enable signal
//      seed0 : 32 bit random seed input
//      seed1 : 32 bit random seed input
//
//    output ports:
//      x_en  : output noise valid signal
//      x0    : output signal sqrt(-2ln(u0))*sin(2pi*u1)
//      x1    : output signal sqrt(-2ln(u0))*cos(2pi*u1)
//  
//    Fmax    : 330MHz on Xilinx Virtex Ultra-Scale FPGA
//    Latency : 16 cycles from ce to x_en output
//
//  
//***************************************************************************//
//***************************************************************************//
module boxmuller
                (
                    //input
                    clock                   ,
                    rst_n                   ,
                    init                    ,
                    ce                      ,
                    seed0                   ,
                    seed1                   ,
                    //output
                    x_en                    ,
                    x0                      ,
                    x1                       
                );

//===========================================================================//
//parameters define
//===========================================================================//
parameter DW = 8;


//===========================================================================//
//input/output ports define
//===========================================================================//
input                   clock               ;
input                   rst_n               ;
input                   init                ;
input                   ce                  ;
input  [31:0]           seed0               ;
input  [31:0]           seed1               ;

//output
output                  x_en                ;
output [17:0]           x0                  ;
output [17:0]           x1                  ;

//===========================================================================//
//Main Codes begin
//===========================================================================//

//signals define
wire [31:0]             a                   ; //32 bit URNG number
wire [31:0]             b                   ; //32 bit URNG number

wire [47:0] u0 = {a, b[31:16]};
wire [15:0] u1 = b[15:0];

reg  [15:0]             ce_dl               ;

always @(posedge clock or negedge rst_n)
  if(!rst_n)
    ce_dl <= #1 16'h0;
  else if(init)
    ce_dl <= #1 16'h0;
  else
    ce_dl <= #1 {ce_dl[14:0], ce};

wire x_en = ce_dl[15];

//------------------e=-2ln(u0)---------------
reg  [5 :0]             exp_e               ;
reg  [7 :0]             xm_e                ;
reg  [23:0]             xl_e                ;

reg  [5 :0]             exp_e_r             ;
reg  [7 :0]             xm_e_r              ;
reg  [23:0]             xl_e_r              ;

always @(posedge clock or negedge rst_n)
  if(!rst_n)
  begin
    exp_e_r <= #1 6'h0;
    xm_e_r  <= #1 8'h0;
    xl_e_r  <= #1 24'h0;
  end
  else
  begin
    exp_e_r <= #1 exp_e;
    xm_e_r  <= #1 xm_e;
    xl_e_r  <= #1 xl_e;
  end

always @(*)
  casez(u0)
    48'b1???_????_????_????_????_????_????_????_????_????_????_???? : begin exp_e = 6'd1 ; xm_e = u0[46:39]; xl_e=u0[38:15]; end
    48'b01??_????_????_????_????_????_????_????_????_????_????_???? : begin exp_e = 6'd2 ; xm_e = u0[45:38]; xl_e=u0[37:14]; end
    48'b001?_????_????_????_????_????_????_????_????_????_????_???? : begin exp_e = 6'd3 ; xm_e = u0[44:37]; xl_e=u0[36:13]; end
    48'b0001_????_????_????_????_????_????_????_????_????_????_???? : begin exp_e = 6'd4 ; xm_e = u0[43:36]; xl_e=u0[35:12]; end
    48'b0000_1???_????_????_????_????_????_????_????_????_????_???? : begin exp_e = 6'd5 ; xm_e = u0[42:35]; xl_e=u0[34:11]; end
    48'b0000_01??_????_????_????_????_????_????_????_????_????_???? : begin exp_e = 6'd6 ; xm_e = u0[41:34]; xl_e=u0[33:10]; end
    48'b0000_001?_????_????_????_????_????_????_????_????_????_???? : begin exp_e = 6'd7 ; xm_e = u0[40:33]; xl_e=u0[32: 9]; end
    48'b0000_0001_????_????_????_????_????_????_????_????_????_???? : begin exp_e = 6'd8 ; xm_e = u0[39:32]; xl_e=u0[31: 8]; end
    48'b0000_0000_1???_????_????_????_????_????_????_????_????_???? : begin exp_e = 6'd9 ; xm_e = u0[38:31]; xl_e=u0[30: 7]; end
    48'b0000_0000_01??_????_????_????_????_????_????_????_????_???? : begin exp_e = 6'd10; xm_e = u0[37:30]; xl_e=u0[29: 6]; end
    48'b0000_0000_001?_????_????_????_????_????_????_????_????_???? : begin exp_e = 6'd11; xm_e = u0[36:29]; xl_e=u0[28: 5]; end
    48'b0000_0000_0001_????_????_????_????_????_????_????_????_???? : begin exp_e = 6'd12; xm_e = u0[35:28]; xl_e=u0[27: 4]; end
    48'b0000_0000_0000_1???_????_????_????_????_????_????_????_???? : begin exp_e = 6'd13; xm_e = u0[34:27]; xl_e=u0[26: 3]; end
    48'b0000_0000_0000_01??_????_????_????_????_????_????_????_???? : begin exp_e = 6'd14; xm_e = u0[33:26]; xl_e=u0[25: 2]; end
    48'b0000_0000_0000_001?_????_????_????_????_????_????_????_???? : begin exp_e = 6'd15; xm_e = u0[32:25]; xl_e=u0[24: 1]; end
    48'b0000_0000_0000_0001_????_????_????_????_????_????_????_???? : begin exp_e = 6'd16; xm_e = u0[31:24]; xl_e=u0[23: 0]; end
    48'b0000_0000_0000_0000_1???_????_????_????_????_????_????_???? : begin exp_e = 6'd17; xm_e = u0[30:23]; xl_e={u0[22: 0], 1'h0 }; end
    48'b0000_0000_0000_0000_01??_????_????_????_????_????_????_???? : begin exp_e = 6'd18; xm_e = u0[29:22]; xl_e={u0[21: 0], 2'h0 }; end
    48'b0000_0000_0000_0000_001?_????_????_????_????_????_????_???? : begin exp_e = 6'd19; xm_e = u0[28:21]; xl_e={u0[20: 0], 3'h0 }; end
    48'b0000_0000_0000_0000_0001_????_????_????_????_????_????_???? : begin exp_e = 6'd20; xm_e = u0[27:20]; xl_e={u0[19: 0], 4'h0 }; end
    48'b0000_0000_0000_0000_0000_1???_????_????_????_????_????_???? : begin exp_e = 6'd21; xm_e = u0[26:19]; xl_e={u0[18: 0], 5'h0 }; end
    48'b0000_0000_0000_0000_0000_01??_????_????_????_????_????_???? : begin exp_e = 6'd22; xm_e = u0[25:18]; xl_e={u0[17: 0], 6'h0 }; end
    48'b0000_0000_0000_0000_0000_001?_????_????_????_????_????_???? : begin exp_e = 6'd23; xm_e = u0[24:17]; xl_e={u0[16: 0], 7'h0 }; end
    48'b0000_0000_0000_0000_0000_0001_????_????_????_????_????_???? : begin exp_e = 6'd24; xm_e = u0[23:16]; xl_e={u0[15: 0], 8'h0 }; end
    48'b0000_0000_0000_0000_0000_0000_1???_????_????_????_????_???? : begin exp_e = 6'd25; xm_e = u0[22:15]; xl_e={u0[14: 0], 9'h0 }; end
    48'b0000_0000_0000_0000_0000_0000_01??_????_????_????_????_???? : begin exp_e = 6'd26; xm_e = u0[21:14]; xl_e={u0[13: 0], 10'h0}; end
    48'b0000_0000_0000_0000_0000_0000_001?_????_????_????_????_???? : begin exp_e = 6'd27; xm_e = u0[20:13]; xl_e={u0[12: 0], 11'h0}; end
    48'b0000_0000_0000_0000_0000_0000_0001_????_????_????_????_???? : begin exp_e = 6'd28; xm_e = u0[19:12]; xl_e={u0[11: 0], 12'h0}; end
    48'b0000_0000_0000_0000_0000_0000_0000_1???_????_????_????_???? : begin exp_e = 6'd29; xm_e = u0[18:11]; xl_e={u0[10: 0], 13'h0}; end
    48'b0000_0000_0000_0000_0000_0000_0000_01??_????_????_????_???? : begin exp_e = 6'd30; xm_e = u0[17:10]; xl_e={u0[9 : 0], 14'h0}; end
    48'b0000_0000_0000_0000_0000_0000_0000_001?_????_????_????_???? : begin exp_e = 6'd31; xm_e = u0[16: 9]; xl_e={u0[8 : 0], 15'h0}; end
    48'b0000_0000_0000_0000_0000_0000_0000_0001_????_????_????_???? : begin exp_e = 6'd32; xm_e = u0[15: 8]; xl_e={u0[7 : 0], 16'h0}; end
    48'b0000_0000_0000_0000_0000_0000_0000_0000_1???_????_????_???? : begin exp_e = 6'd33; xm_e = u0[14: 7]; xl_e={u0[6 : 0], 17'h0}; end
    48'b0000_0000_0000_0000_0000_0000_0000_0000_01??_????_????_???? : begin exp_e = 6'd34; xm_e = u0[13: 6]; xl_e={u0[5 : 0], 18'h0}; end
    48'b0000_0000_0000_0000_0000_0000_0000_0000_001?_????_????_???? : begin exp_e = 6'd35; xm_e = u0[12: 5]; xl_e={u0[4 : 0], 19'h0}; end
    48'b0000_0000_0000_0000_0000_0000_0000_0000_0001_????_????_???? : begin exp_e = 6'd36; xm_e = u0[11: 4]; xl_e={u0[3 : 0], 20'h0}; end
    48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_1???_????_???? : begin exp_e = 6'd37; xm_e = u0[10: 3]; xl_e={u0[2 : 0], 21'h0}; end
    48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_01??_????_???? : begin exp_e = 6'd38; xm_e = u0[9 : 2]; xl_e={u0[1 : 0], 22'h0}; end
    48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_001?_????_???? : begin exp_e = 6'd39; xm_e = u0[8 : 1]; xl_e={u0[0 : 0], 23'h0}; end
    48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0001_????_???? : begin exp_e = 6'd40; xm_e = u0[7 : 0];        xl_e=24'h0; end
    48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1???_???? : begin exp_e = 6'd41; xm_e ={u0[6:  0], 1'h0}; xl_e=24'h0; end
    48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_01??_???? : begin exp_e = 6'd42; xm_e ={u0[5 : 0], 2'h0}; xl_e=24'h0; end
    48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_001?_???? : begin exp_e = 6'd43; xm_e ={u0[4 : 0], 3'h0}; xl_e=24'h0; end
    48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001_???? : begin exp_e = 6'd44; xm_e ={u0[3 : 0], 4'h0}; xl_e=24'h0; end
    48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1??? : begin exp_e = 6'd45; xm_e ={u0[2:  0], 5'h0}; xl_e=24'h0; end
    48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_01?? : begin exp_e = 6'd46; xm_e ={u0[1 : 0], 6'h0}; xl_e=24'h0; end
    48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_001? : begin exp_e = 6'd47; xm_e ={u0[0 : 0], 7'h0}; xl_e=24'h0; end
    48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001 : begin exp_e = 6'd48; xm_e =8'h0; xl_e=24'h0; end
    default                                                         : begin exp_e = 6'd49; xm_e =8'h0; xl_e=24'h0; end
  endcase

wire [7:0]              ce_addr                 ;
wire [64:0]             ce_rdata                ;
wire [29:0]             ce_0                    ;
wire [21:0]             ce_1                    ;
wire [12:0]             ce_2                    ;

assign ce_addr = xm_e_r;
assign ce_0 = ce_rdata[64:35];
assign ce_1 = ce_rdata[34:13];
assign ce_2 = ce_rdata[12:0];

reg  [12:0]             ce_2_r1                 ;
reg  [21:0]             ce_1_r1                 ;
reg  [21:0]             ce_1_r2                 ;
reg  [29:0]             ce_0_r1                 ;
reg  [29:0]             ce_0_r2                 ;
reg  [29:0]             ce_0_r3                 ;
reg  [29:0]             ce_0_r4                 ;
reg  [23:0]             xl_e_r2                 ;
reg  [23:0]             xl_e_r3                 ;
reg  [23:0]             xl_e_r4                 ;
reg  [23:0]             xl_e_r5                 ;

always @(posedge clock)
  begin
    ce_0_r1 <= #1 ce_0;
    ce_0_r2 <= #1 ce_0_r1;
    ce_0_r3 <= #1 ce_0_r2;
    ce_0_r4 <= #1 ce_0_r3;
    ce_1_r1 <= #1 ce_1;
    ce_1_r2 <= #1 ce_1_r1;
    ce_2_r1 <= #1 ce_2;
  end

always @(posedge clock)
  begin
    xl_e_r2 <= #1 xl_e_r;
    xl_e_r3 <= #1 xl_e_r2;
    xl_e_r4 <= #1 xl_e_r3;
    xl_e_r5 <= #1 xl_e_r4;
  end

reg [36:0]              ye_t1             ;

always @(posedge clock)
  ye_t1 <= #1 ce_2_r1 * xl_e_r3;

reg signed [22:0]       ye_t2             ;
reg signed [46:0]       ye_t3             ;

always @(posedge clock)
  ye_t2 <= #1 {10'h0,ye_t1[36:24]} - {1'b0,ce_1_r2};

always @(posedge clock)
  ye_t3 <= #1 ye_t2 * $signed({1'b0,xl_e_r5});

reg signed [30:0]       ye_t4             ;

always @(posedge clock)
  ye_t4 <= #1 {{8{ye_t3[46]}},ye_t3[46:24]} - {1'b0,ce_0_r4};

reg  [5 :0]             exp_e_r2                ;
reg  [5 :0]             exp_e_r3                ;
reg  [5 :0]             exp_e_r4                ;
reg  [5 :0]             exp_e_r5                ;

always @(posedge clock)
  begin
    exp_e_r2 <= #1 exp_e_r;
    exp_e_r3 <= #1 exp_e_r2;
    exp_e_r4 <= #1 exp_e_r3;
    exp_e_r5 <= #1 exp_e_r4;
  end

wire [29:0] ln2 = 31'd744261118; //(0,30,30)

reg  [35:0]             ec                      ;
reg  [35:0]             ec_r1                   ;

always @(posedge clock)
  ec <= #1 exp_e_r5 * ln2;

always @(posedge clock)
  ec_r1 <= #1 ec;

reg  signed [36:0]      yee                     ;

always @(posedge clock)
  yee <= #1 {1'b0,ec_r1} + {{6{ye_t4[30]}},ye_t4};

wire [30:0] e = yee[35:5];

//------------------f=sqrt(e)---------------
reg  [4 :0]             exp_f                   ;
reg  [5 :0]             xm_f                    ;
reg  [17:0]             xl_f                    ;

reg  [4 :0]             exp_f_r                 ;
reg  [5 :0]             xm_f_r                  ;
reg  [17:0]             xl_f_r                  ;

always @(posedge clock or negedge rst_n)
  if(!rst_n)
  begin
    exp_f_r <= #1 5'h0;
    xm_f_r  <= #1 6'h0;
    xl_f_r  <= #1 24'h0;
  end
  else
  begin
    exp_f_r <= #1 exp_f;
    xm_f_r  <= #1 xm_f;
    xl_f_r  <= #1 xl_f;
  end

always @(*)
  casez(e)
    31'b1??_????_????_????_????_????_????_???? : begin exp_f = 5'd0 ; xm_f = e[29:24]; xl_f= e[23:6]; end
    31'b01?_????_????_????_????_????_????_???? : begin exp_f = 5'd1 ; xm_f = e[28:23]; xl_f= e[22:5]; end
    31'b001_????_????_????_????_????_????_???? : begin exp_f = 5'd2 ; xm_f = e[27:22]; xl_f= e[21:4]; end
    31'b000_1???_????_????_????_????_????_???? : begin exp_f = 5'd3 ; xm_f = e[26:21]; xl_f= e[20:3]; end
    31'b000_01??_????_????_????_????_????_???? : begin exp_f = 5'd4 ; xm_f = e[25:20]; xl_f= e[19:2]; end
    31'b000_001?_????_????_????_????_????_???? : begin exp_f = 5'd5 ; xm_f = e[24:19]; xl_f= e[18:1]; end //point position
    31'b000_0001_????_????_????_????_????_???? : begin exp_f = 5'd6 ; xm_f = e[23:18]; xl_f= e[17:0]; end
    31'b000_0000_1???_????_????_????_????_???? : begin exp_f = 5'd7 ; xm_f = e[22:17]; xl_f={e[16:0], 1'h0}; end
    31'b000_0000_01??_????_????_????_????_???? : begin exp_f = 5'd8 ; xm_f = e[21:16]; xl_f={e[15:0], 2'h0}; end
    31'b000_0000_001?_????_????_????_????_???? : begin exp_f = 5'd9 ; xm_f = e[20:15]; xl_f={e[14:0], 3'h0}; end
    31'b000_0000_0001_????_????_????_????_???? : begin exp_f = 5'd10; xm_f = e[19:14]; xl_f={e[13:0], 4'h0}; end
    31'b000_0000_0000_1???_????_????_????_???? : begin exp_f = 5'd11; xm_f = e[18:13]; xl_f={e[12:0], 5'h0}; end
    31'b000_0000_0000_01??_????_????_????_???? : begin exp_f = 5'd12; xm_f = e[17:12]; xl_f={e[11:0], 6'h0}; end
    31'b000_0000_0000_001?_????_????_????_???? : begin exp_f = 5'd13; xm_f = e[16:11]; xl_f={e[10:0], 7'h0}; end
    31'b000_0000_0000_0001_????_????_????_???? : begin exp_f = 5'd14; xm_f = e[15:10]; xl_f={e[9 :0], 8'h0}; end
    31'b000_0000_0000_0000_1???_????_????_???? : begin exp_f = 5'd15; xm_f = e[14: 9]; xl_f={e[8 :0], 9'h0}; end
    31'b000_0000_0000_0000_01??_????_????_???? : begin exp_f = 5'd16; xm_f = e[13: 8]; xl_f={e[7 :0],10'h0}; end
    31'b000_0000_0000_0000_001?_????_????_???? : begin exp_f = 5'd17; xm_f = e[12: 7]; xl_f={e[6 :0],11'h0}; end
    31'b000_0000_0000_0000_0001_????_????_???? : begin exp_f = 5'd18; xm_f = e[11: 6]; xl_f={e[5 :0],12'h0}; end
    31'b000_0000_0000_0000_0000_1???_????_???? : begin exp_f = 5'd19; xm_f = e[10: 5]; xl_f={e[4 :0],13'h0}; end
    31'b000_0000_0000_0000_0000_01??_????_???? : begin exp_f = 5'd20; xm_f = e[9 : 4]; xl_f={e[3 :0],14'h0}; end
    31'b000_0000_0000_0000_0000_001?_????_???? : begin exp_f = 5'd21; xm_f = e[8 : 3]; xl_f={e[2 :0],15'h0}; end
    31'b000_0000_0000_0000_0000_0001_????_???? : begin exp_f = 5'd22; xm_f = e[7 : 2]; xl_f={e[1 :0],16'h0}; end
    31'b000_0000_0000_0000_0000_0000_1???_???? : begin exp_f = 5'd23; xm_f = e[6 : 1]; xl_f={e[0 :0],17'h0}; end
    31'b000_0000_0000_0000_0000_0000_01??_???? : begin exp_f = 5'd24; xm_f = e[5 : 0];        xl_f=18'h0; end
    31'b000_0000_0000_0000_0000_0000_001?_???? : begin exp_f = 5'd25; xm_f = {e[4 : 0],1'h0}; xl_f=18'h0; end
    31'b000_0000_0000_0000_0000_0000_0001_???? : begin exp_f = 5'd26; xm_f = {e[3 : 0],2'h0}; xl_f=18'h0; end
    31'b000_0000_0000_0000_0000_0000_0000_1??? : begin exp_f = 5'd27; xm_f = {e[2 : 0],3'h0}; xl_f=18'h0; end
    31'b000_0000_0000_0000_0000_0000_0000_01?? : begin exp_f = 5'd28; xm_f = {e[1 : 0],4'h0}; xl_f=18'h0; end
    31'b000_0000_0000_0000_0000_0000_0000_001? : begin exp_f = 5'd29; xm_f = {e[0 : 0],5'h0}; xl_f=18'h0; end
    31'b000_0000_0000_0000_0000_0000_0000_0001 : begin exp_f = 5'd30; xm_f = 6'h0;            xl_f=18'h0; end
    default                                    : begin exp_f = 5'd31; xm_f = 6'h0;            xl_f=18'h0; end
  endcase

wire [6:0]              cf_addr                 ;
wire [32:0]             cf_rdata                ;
wire [19:0]             cf_0                    ;
wire [12:0]             cf_1                    ;

assign cf_addr = {exp_f_r[0],xm_f_r};
assign cf_0 = cf_rdata[32:13];
assign cf_1 = cf_rdata[12:0];

reg  [19:0]             cf_0_r1                 ;
reg  [19:0]             cf_0_r2                 ;
reg  [12:0]             cf_1_r1                 ;
reg  [17:0]             xl_f_r2                 ;
reg  [17:0]             xl_f_r3                 ;

always @(posedge clock)
  begin
    cf_0_r1 <= #1 cf_0;
    cf_0_r2 <= #1 cf_0_r1;
    cf_1_r1 <= #1 cf_1;
  end

always @(posedge clock)
  begin
    xl_f_r2 <= #1 xl_f_r;
    xl_f_r3 <= #1 xl_f_r2;
  end

reg  [30:0]             yf_t1             ;
reg  [24:0]             yf_t2             ;

always @(posedge clock)
  yf_t1 <= #1 cf_1_r1 * xl_f_r3; //(0,31,37)

always @(posedge clock)
  yf_t2 <= #1 {8'h0,yf_t1[30:14]} + {1'b0,cf_0_r2,4'h0};

reg  [4 :0]             exp_f_r2                ;
reg  [4 :0]             exp_f_r3                ;
reg  [5 :0]             exp_f_r4                ;
reg  [5 :0]             exp_f_r5                ;

always @(posedge clock)
  begin
    exp_f_r2 <= #1 exp_f_r;
    exp_f_r3 <= #1 exp_f_r2;
    exp_f_r4 <= #1 exp_f_r3 + 5'd1;
    exp_f_r5 <= #1 exp_f_r4;
  end

//f (0,20,16)
reg  [19:0]             yff                     ;

always @(*)
  case(exp_f_r5[5:1])
    5'd0 : yff = yf_t2[23:4];
    5'd1 : yff = yf_t2[24:5];
    5'd2 : yff = {1'h0 ,yf_t2[24: 6]};
    5'd3 : yff = {2'h0 ,yf_t2[24: 7]};
    5'd4 : yff = {3'h0 ,yf_t2[24: 8]};
    5'd5 : yff = {4'h0 ,yf_t2[24: 9]};
    5'd6 : yff = {5'h0 ,yf_t2[24:10]};
    5'd7 : yff = {6'h0 ,yf_t2[24:11]};
    5'd8 : yff = {7'h0 ,yf_t2[24:12]};
    5'd9 : yff = {8'h0 ,yf_t2[24:13]};
    5'd10: yff = {9'h0 ,yf_t2[24:14]};
    5'd11: yff = {10'h0,yf_t2[24:15]};
    5'd12: yff = {11'h0,yf_t2[24:16]};
    5'd13: yff = {12'h0,yf_t2[24:17]};
    5'd14: yff = {13'h0,yf_t2[24:18]};
    5'd15: yff = {14'h0,yf_t2[24:19]};
    default:yff = {15'h0,yf_t2[24:20]};
  endcase

reg  [19:0]             f                       ;

always @(posedge clock)
  f <= #1 yff;

//------------------g0=sin(u0*pi/2)---------------
//------------------g1=cos(u0*pi/2)---------------

reg  [13:0]             x_g_a                   ;
reg  [13:0]             x_g_b                   ;

always @(posedge clock)
  x_g_a <= #1 u1[13:0];

always @(posedge clock)
  x_g_b <= #1 ~u1[13:0];

reg  [7:0]              xm_g_a                  ;
reg  [7:0]              xl_g_a                  ;
reg  [7:0]              xm_g_b                  ;
reg  [7:0]              xl_g_b                  ;

always @(posedge clock)
  begin
    xm_g_a <= #1 x_g_a[13:7];
    xl_g_a <= #1 x_g_a[ 6:0];
    xm_g_b <= #1 x_g_b[13:7];
    xl_g_b <= #1 x_g_b[ 6:0];
  end

wire [6:0]              cga_addr                ;
wire [30:0]             cga_rdata               ;
wire [18:0]             cga_0                   ;
wire [11:0]             cga_1                   ;

assign cga_addr = xm_g_a;
assign cga_0 = cga_rdata[30:12];
assign cga_1 = cga_rdata[11:0];


reg  [18:0]             cga_0_r                 ;
reg  [18:0]             cga_0_r2                ;
reg  [11:0]             cga_1_r                 ;
reg  [ 6:0]             xl_ga_r                 ;
reg  [ 6:0]             xl_ga_r2                ;

always @(posedge clock)
  begin
    cga_0_r  <= #1 cga_0;
    cga_0_r2 <= #1 cga_0_r;
    cga_1_r  <= #1 cga_1;
  end

always @(posedge clock)
  begin
    xl_ga_r  <= #1 xl_g_a;
    xl_ga_r2 <= #1 xl_ga_r;
  end

reg [18:0]              ga_t1                   ;

always @(posedge clock)
  ga_t1 <= #1 cga_1_r * xl_ga_r2;

wire [18:0] ga_t2_w = cga_0_r2 - {7'h0,ga_t1[18:7]}; //(0,0,18)

wire [14:0]             ga_t2_sat         ;

unsigned_sat #(16,15) u_sat_ga(ga_t2_w[18:3], ga_t2_sat);

reg  signed [15:0]      ga_t2             ;

always @(posedge clock)
  ga_t2 <= #1 {1'b0,ga_t2_sat};


wire [6:0]              cgb_addr                ;
wire [30:0]             cgb_rdata               ;
wire [18:0]             cgb_0                   ;
wire [11:0]             cgb_1                   ;

assign cgb_addr = xm_g_b;
assign cgb_0 = cgb_rdata[30:12];
assign cgb_1 = cgb_rdata[11:0];


reg  [18:0]             cgb_0_r                 ;
reg  [18:0]             cgb_0_r2                ;
reg  [11:0]             cgb_1_r                 ;
reg  [ 6:0]             xl_gb_r                 ;
reg  [ 6:0]             xl_gb_r2                ;

always @(posedge clock)
  begin
    cgb_0_r  <= #1 cgb_0;
    cgb_0_r2 <= #1 cgb_0_r;
    cgb_1_r  <= #1 cgb_1;
  end

always @(posedge clock)
  begin
    xl_gb_r  <= #1 xl_g_b;
    xl_gb_r2 <= #1 xl_gb_r;
  end

reg [18:0]              gb_t1                   ;

always @(posedge clock)
  gb_t1 <= #1 cgb_1_r * xl_gb_r2;

wire [18:0] gb_t2_w = cgb_0_r2 - {7'h0,gb_t1[18:7]}; //(0,0,18)

wire [14:0]             gb_t2_sat         ;

unsigned_sat #(16,15) u_sat_gb(gb_t2_w[18:3], gb_t2_sat);

reg  signed [15:0]      gb_t2             ;

always @(posedge clock)
  gb_t2 <= #1 {1'b0,gb_t2_sat};

reg  [1:0]              quad_sel          ;
reg  [1:0]              quad_sel_d1       ;
reg  [1:0]              quad_sel_d2       ;
reg  [1:0]              quad_sel_d3       ;
reg  [1:0]              quad_sel_d4       ;
reg  [1:0]              quad_sel_d5       ;

always @(posedge clock)
  begin
    quad_sel    <= #1 u1[15:14];
    quad_sel_d1 <= #1 quad_sel;
    quad_sel_d2 <= #1 quad_sel_d1;
    quad_sel_d3 <= #1 quad_sel_d2;
    quad_sel_d4 <= #1 quad_sel_d3;
    quad_sel_d5 <= #1 quad_sel_d4;
  end

reg signed [15:0]       ga                ;
reg signed [15:0]       gb                ;

always @(posedge clock)
  case(quad_sel_d5)
    2'b00 : ga <= #1  gb_t2;
    2'b01 : ga <= #1  ga_t2;
    2'b10 : ga <= #1 -gb_t2;
    2'b11 : ga <= #1 -ga_t2;
  endcase

always @(posedge clock)
  case(quad_sel_d5)
    2'b00 : gb <= #1  ga_t2;
    2'b01 : gb <= #1 -gb_t2;
    2'b10 : gb <= #1 -ga_t2;
    2'b11 : gb <= #1  gb_t2;
  endcase

reg  signed [15:0]             ga_d1             ;
reg  signed [15:0]             ga_d2             ;
reg  signed [15:0]             ga_d3             ;
reg  signed [15:0]             ga_d4             ;
reg  signed [15:0]             ga_d5             ;
reg  signed [15:0]             ga_d6             ;
reg  signed [15:0]             ga_d7             ;

reg  signed [15:0]             gb_d1             ;
reg  signed [15:0]             gb_d2             ;
reg  signed [15:0]             gb_d3             ;
reg  signed [15:0]             gb_d4             ;
reg  signed [15:0]             gb_d5             ;
reg  signed [15:0]             gb_d6             ;
reg  signed [15:0]             gb_d7             ;

always @(posedge clock)
  begin
    ga_d1 <= #1 ga;
    ga_d2 <= #1 ga_d1;
    ga_d3 <= #1 ga_d2;
    ga_d4 <= #1 ga_d3;
    ga_d5 <= #1 ga_d4;
    ga_d6 <= #1 ga_d5;
    ga_d7 <= #1 ga_d6;
    gb_d1 <= #1 gb;
    gb_d2 <= #1 gb_d1;
    gb_d3 <= #1 gb_d2;
    gb_d4 <= #1 gb_d3;
    gb_d5 <= #1 gb_d4;
    gb_d6 <= #1 gb_d5;
    gb_d7 <= #1 gb_d6;
  end

reg  signed [35:0]            x0_t1               ;
reg  signed [35:0]            x1_t1               ;

always @(posedge clock)
  x0_t1 <= #1 ga_d7 * $signed({1'b0,f});

always @(posedge clock)
  x1_t1 <= #1 gb_d7 * $signed({1'b0,f});

wire signed [17:0]            x0_rnd              ; //= x0_t1[35:18];
wire signed [17:0]            x1_rnd              ; //= x1_t1[35:18];

signed_round #(19,18) u_rndx0 (x0_t1[35:17], x0_rnd);
signed_round #(19,18) u_rndx1 (x1_t1[35:17], x1_rnd);

reg  signed [17:0]            x0                  ;
reg  signed [17:0]            x1                  ;

always @(posedge clock or negedge rst_n)
  if(!rst_n)
  begin
    x0 <= #1 18'h0;
    x1 <= #1 18'h0;
  end
  else if(init || !ce_dl[14])
  begin
    x0 <= #1 18'h0;
    x1 <= #1 18'h0;
  end
  else
  begin
    x0 <= #1 x0_rnd;
    x1 <= #1 x1_rnd;
  end

taus_urng u_taus_a
                (
                    //input
                    .clock                (clock                ),
                    .rst_n                (rst_n                ),
                    .init                 (init                 ), //init to initial state
                    .ce                   (ce                   ),
                    .seed0                (seed0                ),
                    .seed1                (seed0                ),
                    .seed2                (seed0                ),

                    //output
                    .u0                   (a                    ) 
                );

taus_urng u_taus_b
                (
                    //input
                    .clock                (clock                ),
                    .rst_n                (rst_n                ),
                    .init                 (init                 ), //init to initial state
                    .ce                   (ce                   ),
                    .seed0                (seed1                ),
                    .seed1                (seed1                ),
                    .seed2                (seed1                ),

                    //output
                    .u0                   (b                    ) 
                );

bm_ce_rom u_ce_rom
                (
                    .clock                (clock                ), 
                    .addr                 (ce_addr              ),
                    .rdata                (ce_rdata             )
                );

bm_cf_rom u_cf_rom
                (
                    .clock                (clock                ), 
                    .addr                 (cf_addr              ),
                    .rdata                (cf_rdata             )
                );

bm_cg_rom u_cga_rom
                (
                    .clock                (clock                ), 
                    .addr                 (cga_addr             ),
                    .rdata                (cga_rdata            )
                );

bm_cg_rom u_cgb_rom
                (
                    .clock                (clock                ), 
                    .addr                 (cgb_addr             ),
                    .rdata                (cgb_rdata            )
                );


//synopsys translate_off
wire e_vld = ce_dl[7];
wire f_vld = ce_dl[13];
wire g_vld = ce_dl[6];
wire x_vld = ce_dl[15];

//synopsys translate_on

endmodule

//***************************************************************************//
//***************************************************************************//
//Revision History:
// $Log$ 
//***************************************************************************//
//***************************************************************************//
