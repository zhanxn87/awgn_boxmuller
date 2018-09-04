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
%    A Gaussion Signal Generator based on Box-Muller Algorithm, which can be
%    used on FPGA accurate to one unit in the last place up to 8.15 sigma.
%
%    The Box-Muller Algorithm fixed point model mainly refers to the paper:
%    -D. U. Lee, J. D. Villasenor, W. Luk, and P. H. W. Leong, “A hardware
%     Gaussian noise generator using the box-muller method and its error
%     analysis,” IEEE Transactions on Computers, vol. 55, no. 6, pp. 659–671,
%     June 2006.
%
%    Author: zhanxn, zhanxn@gmail.com
%    Date  : 2018/08/18
%
%***************************************************************************//
%***************************************************************************//

function [Ce, Cf1, Cf2, Cg] = chebv_approx()
% generate chebshev approximation coefficeints for -ln(2), sqrt(e), cos(x)

%% -ln(x) approximation
k = 8;
n = 3;
ir = 1;
t = cos(((2*(0:n-1)+1)*pi)/(2*n));
intv_num = 2^k;
for intv=1:intv_num
    a = ir+(intv-1)/intv_num;
    b = ir+intv/intv_num;
    
    x_i = (t*(b-a)+(b+a))/2;
    
    f_ln = -log(x_i);

    Cn0(3,intv) = f_ln((1))/((x_i(1)-x_i(2))*(x_i(1)-x_i(3))) ...
                + f_ln((2))/((x_i(2)-x_i(1))*(x_i(2)-x_i(3))) ...
                + f_ln((3))/((x_i(3)-x_i(1))*(x_i(3)-x_i(2)));

    Cn0(2,intv) = f_ln((1))*(-x_i(2)-x_i(3))/((x_i(1)-x_i(2))*(x_i(1)-x_i(3))) ...
                + f_ln((2))*(-x_i(1)-x_i(3))/((x_i(2)-x_i(1))*(x_i(2)-x_i(3))) ...
                + f_ln((3))*(-x_i(2)-x_i(1))/((x_i(3)-x_i(1))*(x_i(3)-x_i(2)));

    Cn0(1,intv) = f_ln((1))*(x_i(2)*x_i(3))/((x_i(1)-x_i(2))*(x_i(1)-x_i(3))) ...
                + f_ln((2))*(x_i(1)*x_i(3))/((x_i(2)-x_i(1))*(x_i(2)-x_i(3))) ...
                + f_ln((3))*(x_i(2)*x_i(1))/((x_i(3)-x_i(1))*(x_i(3)-x_i(2)));
            
    xm = (intv - 1)/intv_num;        
    Ce(3,intv) = (Cn0(3,intv))*2^(-2*k);
    Ce(2,intv) = (Cn0(3,intv)*(2+2*xm)+Cn0(2,intv))*2^(-k);
    Ce(1,intv) =  Cn0(3,intv)*(xm+1)^2+Cn0(2,intv)*(xm+1) + Cn0(1,intv);
end

%% sqrt(e) approximation
% [1,2)
k = 6;
ir = 1;
n = 2;
intv_num = 2^k;
t = cos(((2*(0:n-1)+1)*pi)/(2*n));
for intv=1:intv_num
    a = ir+(intv-1)/intv_num;
    b = ir+intv/intv_num;
    
    x_i = (t*(b-a)+(b+a))/2;
    
    f_sqrt = sqrt(x_i);

    Cn1(2,intv) = f_sqrt(1)/(x_i(1)-x_i(2)) ...
                + f_sqrt(2)/(x_i(2)-x_i(1));

    Cn1(1,intv) = -f_sqrt(1)*x_i(2)/(x_i(1)-x_i(2)) ...
                  -f_sqrt(2)*x_i(1)/(x_i(2)-x_i(1));
            
    xm = (intv - 1)/intv_num;        
    Cf1(2,intv) = Cn1(2,intv)*2^(-k);
    Cf1(1,intv) = Cn1(2,intv)*(xm+1) + Cn1(1,intv);
end

% [2,4)
ir = 2;
for intv=1:intv_num
    a = ir+(intv-1)*2/intv_num;
    b = ir+intv*2/intv_num;
    
    x_i = (t*(b-a)+(b+a))/2;
    
    f_sqrt = sqrt(x_i);

    Cn2(2,intv) = f_sqrt(1)/(x_i(1)-x_i(2)) ...
                + f_sqrt(2)/(x_i(2)-x_i(1));

    Cn2(1,intv) = -f_sqrt(1)*x_i(2)/(x_i(1)-x_i(2)) ...
                  -f_sqrt(2)*x_i(1)/(x_i(2)-x_i(1));
            
    xm = (intv - 1)/intv_num;        
    Cf2(2,intv) = Cn2(2,intv)*2^(-k+1);
    Cf2(1,intv) = Cn2(2,intv)*(xm*2+2) + Cn2(1,intv);
end

%% cos(D*pi/2) [0,1)
n = 2;
ir = 0;
k = 7;
t = cos(((2*(0:n-1)+1)*pi)/(2*n));
intv_num = 2^k;
for intv=1:intv_num
    a = ir+(intv-1)/intv_num;
    b = ir+intv/intv_num;
    
    x_i = (t*(b-a)+(b+a))/2;
    
    f_cos = cos(x_i*pi/2);

    Cn3(2,intv) = f_cos(1)/(x_i(1)-x_i(2)) ...
                + f_cos(2)/(x_i(2)-x_i(1));

    Cn3(1,intv) = -f_cos(1)*x_i(2)/(x_i(1)-x_i(2)) ...
                  -f_cos(2)*x_i(1)/(x_i(2)-x_i(1));
            
    xm = (intv - 1)/intv_num;        
    Cg(2,intv) = Cn3(2,intv)*2^(-k);
    Cg(1,intv) = Cn3(2,intv)*xm + Cn3(1,intv);
end

%% fixed point
Ce       = round(Ce *2^30)/2^30;
Cf1      = round(Cf1*2^19)/2^19;
Cf2      = round(Cf2*2^19)/2^19;
Cg       = round(Cg *2^18)/2^18;

%% write ROM file for verilog
if 0
write_crom(Ce*2^30, 'bm_ce_rom');
write_crom([Cf1, Cf2]*2^19, 'bm_cf_rom');
write_crom(Cg*2^18, 'bm_cg_rom');
end
