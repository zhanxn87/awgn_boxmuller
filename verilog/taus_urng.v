//***************************************************************************//
//***************************************************************************//
//  Copyright (c) 2018 zhanxn87
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
//   Design      :   taus_urng.v
//   Author      :   zhanxn
//   Email       :   zhanxn@gmail.com
//   Date        :   Fri Aug 22 17:10:13 CST 2018
//   Description :   Tausworthe URNG, generate Uniform Distribute Random
//                   Number U(0,1).
//
//
//***************************************************************************//
//***************************************************************************//

module taus_urng
               (
                    //input
                    clock               ,
                    rst_n               ,
                    init                , //init to initial state
                    ce                  ,
                    seed0               ,
                    seed1               ,
                    seed2               ,

                    //output
                    u0                   
               );

//========================================
//parameter define
//========================================

//========================================
//input  declare
//========================================
input               clock               ;
input               rst_n               ;
input               init                ;
input               ce                  ;
input [31:0]        seed0               ;
input [31:0]        seed1               ;
input [31:0]        seed2               ;

//========================================
//output declare
//========================================
output [31:0]       u0                  ;

//========================================
//code begin here
//========================================

wire [31:0] b0, b1, b2, s0_next, s1_next, s2_next;
reg  [31:0] s0, s1, s2;

assign b0 = (((s0 << 13) ^ s0) >> 19);
assign s0_next = (((s0 & 32'hFFFFFFFE) << 12) ^ b0);

assign b1 = (((s1 << 2) ^ s1) >> 25);
assign s1_next = (((s1 & 32'hFFFFFFF8) << 4) ^ b1);

assign b2 = (((s2 << 3) ^ s2) >> 11);
assign s2_next = (((s2 & 32'hFFFFFFF0) << 17) ^ b2);

assign u0 = s0 ^ s1 ^ s2;

always @(posedge clock or negedge rst_n)
  if(!rst_n)
  begin
    s0 <= 32'h0;
    s1 <= 32'h0;
    s2 <= 32'h0;
  end
  else if(init)
  begin
    s0 <= seed0;
    s1 <= seed1;
    s2 <= seed2;
  end
  else if(ce)
  begin
    s0 <= s0_next;
    s1 <= s1_next;
    s2 <= s2_next;
  end

// synopsys translate_off
// synopsys translate_on
endmodule
