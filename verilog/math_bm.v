//***************************************************************************//
//***************************************************************************//
//  Copyright (c) 2018 CurvTech, www.curvtech.com
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
//  Design Name          :  math_bm.v
//  Create by            :  zhanxn
//  Email                :  zhanxn@gmail.com
//  Create Date          :  Tue Sep  4 17:58:03 CST 2018
//  Function Description :  math functions for saturation or round/truncation
//  
//  
//  
//***************************************************************************//
//***************************************************************************//

module signed_round
               (
                    i                   ,
                    o                    
               );

parameter I_W = 16;
parameter O_W = 15;

input  signed [I_W-1:0] i               ;
output signed [O_W-1:0] o               ;

wire sat = (i[I_W-1:I_W-O_W] != {1'b0, {O_W-1{1'b1}}}) && i[I_W-O_W-1];

wire signed [O_W-1:0] o = i[I_W-1:I_W-O_W] + sat;

endmodule

//***************************************************************************//

module unsigned_sat
               (
                    i                   ,
                    o                    
               );

parameter I_W = 16;
parameter O_W = 15;

input  [I_W-1:0]    i                   ;
output [O_W-1:0]    o                   ;

wire sat = |i[I_W-1:O_W];
wire [O_W-1:0] o = {O_W{sat}} | i[O_W-1:0];

endmodule

//***************************************************************************//
//***************************************************************************//
//Revision History:
// $Log$ 
//***************************************************************************//
//***************************************************************************//
