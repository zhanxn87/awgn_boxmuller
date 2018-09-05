//`timescale 1ns/1ps
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
//  Function Description :  test_bench for boxmuller module simulation
//***************************************************************************//
//***************************************************************************//

module tb();

reg       clock;
reg       rst_n;
reg       init;
reg       ce  ;

integer fp_cfg;
integer tt;


initial begin
  clock = 1'b1;
  rst_n = 1'b0;
  init  = 1'b1;
  ce    = 1'b0;
  #1000;
  rst_n = 1'b1;
  #1;
  #1000;
  init = 1'b0;

  #1000;
  ce = 1'b1;

end

always #4 clock = ~clock;

reg [31:0]        seed0;
reg [31:0]        seed1;
reg [31:0]        sim_len;

initial begin
  fp_cfg = $fopen("../matlab/bitMatchFile/cfg_para.txt","r");
  tt = $fscanf(fp_cfg, "%x", seed0);
  tt = $fscanf(fp_cfg, "%x", seed1);
  tt = $fscanf(fp_cfg, "%x", sim_len);
end

wire              x_en        ;
reg               x_mask      ;

boxmuller u_dut
                (
                    //input
                    .clock                   (clock                   ),
                    .rst_n                   (rst_n                   ),
                    .init                    (init                    ),
                    .ce                      (ce && x_mask            ),
                    .seed0                   (seed0                   ),
                    .seed1                   (seed1                   ),
                    //output
                    .x_en                    (x_en                    ),
                    .x0                      (),
                    .x1                      () 
                );

reg [31:0]        x_cnt       ;

wire x_cnt_hit = ce && x_cnt==sim_len-1;

always @(posedge clock or negedge rst_n)
  if(!rst_n)
    x_mask <= #1 1'h1;
  else if(init)
    x_mask <= #1 1'h1;
  else if(x_cnt_hit)
    x_mask <= #1 1'b0;

always @(posedge clock or negedge rst_n)
  if(!rst_n)
    x_cnt <= #1 32'h0;
  else if(init)
    x_cnt <= #1 32'h0;
  else if(ce && x_mask)
    x_cnt <= #1 x_cnt + 32'h1;

reg [13:0]        x_mask_dl   ;

always @(posedge clock or negedge rst_n)
  if(!rst_n)
    x_mask_dl <= #1 14'h0;
  else if(init)
    x_mask_dl <= #1 14'h0;
  else
    x_mask_dl <= #1 {x_mask_dl[12:0], x_mask};

wire sim_end1 = x_cnt_hit;

//check value
integer fp_e;
integer fp_f;
integer fp_g0;
integer fp_g1;
integer fp_x0;
integer fp_x1;
initial
begin
  fp_e  = $fopen("../matlab/bitMatchFile/e.txt","r");
  fp_f  = $fopen("../matlab/bitMatchFile/f.txt","r");
  fp_g0 = $fopen("../matlab/bitMatchFile/g0.txt","r");
  fp_g1 = $fopen("../matlab/bitMatchFile/g1.txt","r");
  fp_x0 = $fopen("../matlab/bitMatchFile/x0.txt","r");
  fp_x1 = $fopen("../matlab/bitMatchFile/x1.txt","r");
end

reg [30:0]      e_rd    ;
reg             e_err   ;

always @(posedge clock or negedge rst_n)
  if(!rst_n)
    e_err <= #1 1'b0;
  else if(u_dut.e_vld)
  begin
    tt = $fscanf(fp_e, "%d", e_rd);
    if(e_rd!==u_dut.e)
      e_err <= #1 1'b1;
  end

reg   [19:0]    f_rd      ;
reg             f_err     ;
always @(posedge clock or negedge rst_n)
  if(!rst_n)
    f_err <= #1 1'b0;
  else if(u_dut.f_vld)
  begin
    tt = $fscanf(fp_f, "%d", f_rd);

    if(f_rd!==u_dut.f)
      f_err <= #1 1'b1;
  end

reg   [15:0]    g0_rd      ;
reg             g0_err     ;
always @(posedge clock or negedge rst_n)
  if(!rst_n)
    g0_err <= #1 1'b0;
  else if(u_dut.g_vld)
  begin
    tt = $fscanf(fp_g0, "%d", g0_rd);

    if(g0_rd!==u_dut.ga)
      g0_err <= #1 1'b1;
  end

reg   [15:0]    g1_rd      ;
reg             g1_err     ;
always @(posedge clock or negedge rst_n)
  if(!rst_n)
    g1_err <= #1 1'b0;
  else if(u_dut.g_vld)
  begin
    tt = $fscanf(fp_g1, "%d", g1_rd);

    if(g1_rd!==u_dut.gb)
      g1_err <= #1 1'b1;
  end

reg   [17:0]    x0_rd      ;
reg             x0_err     ;
always @(posedge clock or negedge rst_n)
  if(!rst_n)
    x0_err <= #1 1'b0;
  else if(u_dut.x_vld)
  begin
    tt = $fscanf(fp_x0, "%d", x0_rd);

    if(x0_rd!==u_dut.x0)
      x0_err <= #1 1'b1;
  end

reg   [17:0]    x1_rd      ;
reg             x1_err     ;
always @(posedge clock or negedge rst_n)
  if(!rst_n)
    x1_err <= #1 1'b0;
  else if(u_dut.x_vld)
  begin
    tt = $fscanf(fp_x1, "%d", x1_rd);

    if(x1_rd!==u_dut.x1)
      x1_err <= #1 1'b1;
  end

always begin
  #1000000 $display("the simulation time is %t", $time);
end

time t1;
time t2;

initial begin
  t1=$time;
  wait (sim_end1 || e_err || f_err || g0_err || g1_err || x0_err || x1_err)
  repeat(10000)@(posedge clock);

  if(e_err || f_err || g0_err || g1_err || x0_err || x1_err)
    $display("simulation bitMatch ERROR");

  tt = $fscanf(fp_x0, "%d", x0_rd);
  if(tt!=-1)
    $display("file not end ERROR");

  t2=$time;
  $display("run time = %d",t2-t1);
  $stop();

end


endmodule
