%***************************************************************************//
%***************************************************************************//
%  Copyright (c) 2018 zhanxn87
%  All rights reserved.
%
%  Permission is hereby granted, free of charge, to any person obtaining a 
%  copy of this software and associated documentation files (the "Software"),
%  to deal in the Software without restriction, including without limitation
%  the rights to use, copy, modify, merge, publish, distribute, sublicense, 
%  and/or sell copies of the Software, and to permit persons to whom the 
%  Software is furnished to do so, subject to the following conditions:
%
%  -The above copyright notice and this permission notice shall be included in
%  all copies or substantial portions of the Software.
%
%  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
%  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
%  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
%  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
%  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
%  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
%  DEALINGS IN THE SOFTWARE.
%---------------------------------------------------------------------------//
%---------------------------------------------------------------------------//
%
%    Author: zhanxn, zhanxn@gmail.com
%    Date  : 2018/08/18
%
%***************************************************************************//
%***************************************************************************//

function write_crom(c, rom_name)
% Auto-generate ROM contents of Chebshev approximation for BoxMuller Gen

[m,n] = size(c);

c = abs(c);

A_W = ceil(log2(n));
DW = zeros(1,m);
for ii=1:m
    DW(ii) = ceil(log2(max((c(ii,:)))));
end
D_W = sum(DW);

fp_idx = fopen(['./verilog_gen/' rom_name '.v'],'w');

fprintf(fp_idx,['module ' rom_name ' (clock, addr, rdata);\n\n']);
fprintf(fp_idx,'input              clock    ;\n');
fprintf(fp_idx,['input  [' num2str(A_W-1) ':0]       addr     ;\n']);
fprintf(fp_idx,['output [' num2str(D_W-1) ':0]      rdata    ;\n\n']);
fprintf(fp_idx,['reg    [' num2str(D_W-1) ':0]      rdata    ;\n\n']);
fprintf(fp_idx,'always @(posedge clock)\n');
fprintf(fp_idx,'  case(addr)\n');

for ii=1:n
    fprintf(fp_idx,['    ' num2str(A_W) '''d' num2str(ii-1) ': ' 'rdata <= #1 {']);
    for jj=1:m-1
        fprintf(fp_idx,[num2str(DW(jj)) '''d' num2str(c(jj,ii)) ', ']);
    end
    fprintf(fp_idx,[num2str(DW(m)) '''d' num2str(c(m,ii)) '};\n'] );
end
fprintf(fp_idx,['    default: rdata <= #1 ' num2str(D_W) '''d0;\n']);
fprintf(fp_idx,'  endcase\n\n');
fprintf(fp_idx,'endmodule\n\n');
