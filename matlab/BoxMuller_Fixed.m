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
%    -D. U. Lee, J. D. Villasenor, W. Luk, and P. H. W. Leong, "hardware
%     Gaussian noise generator using the box-muller method and its error
%     analysis", IEEE Transactions on Computers, vol. 55, no. 6, pp. 659??71,
%     June 2006.
%
%    Author: zhanxn, zhanxn@gmail.com
%    Date  : 2018/08/18
%
%***************************************************************************//
%***************************************************************************//

function BoxMuller_Fixed(seed)
% finxed point model for RTL bit-Match golden

len  = 1e6;
write_file = 0;

if nargin==0
    seed = 8628673799;
end

rand('state',seed);
randn('state',seed);

seed0 = uint32(randi(2^32-1,1,1));
seed1 = uint32(randi(2^32-1,1,1));

dlmwrite('./bitMatchFile/cfg_para.txt',dec2hex([seed0 seed1 len]),'precision','%u','delimiter','');

[Ce, Cf1, Cf2, Cg] = chebv_approx;

%% URNG u0 and u1
a = taus_URNG(seed0,seed0,seed0,len);
b = taus_URNG(seed1,seed1,seed1,len);
% a = taus_URNG_m(seed0,len);
% b = taus_URNG_m(seed1,len);
% a = uint32(rand(1,len)*2^32);
% b = uint32(rand(1,len)*2^32);

u0 = bitshift(uint64(a),16) + uint64(bitshift(b,-16)); %48bit
u1 = bitand(b,uint32(hex2dec('FFFF'))); %16bit

%Box-Mueller Transform float point for golden
w0=sqrt(-2*log(double(u0)/2^48)).*sin(double(u1)/2^16*pi*2); %~N(0,1)
w1=sqrt(-2*log(double(u0)/2^48)).*cos(double(u1)/2^16*pi*2); %~N(0,1)

clear a b

%% calc e = -2ln(u0)
%%------------- Evaluate e = -2ln(u0) ------------
% Range Reduction
exp_e = LeadingZeroDetect(u0, 48) + 1; %6bit
x_e = bitshift(u0, exp_e);

p = 48;
k = 8;
m = p - k;
rnd = 16;
xm_e = bitand(bitshift(x_e,-m),2^k-1);
xl_e = floor(double(bitand(x_e, hex2dec('FFFFFFFFFF')))/2^rnd)/2^(m-rnd);%double(x_e)/2^48;%

% Approximate ln(x_e) where x_e = [1,2)
% Degree-(n-1) piecewise polynomial - 2^k_e segments
% x_e is [1,2) --> x_e = 1 + xm_e + xl_e * 2^-k_e
% Degree-1
%y_e = C1_e(xm_e_index)*xl_e + C0_e(xm_e_index);
%Degree-2 piecewise polynomial
% y_e = ((C2_e[xm_e]*xl_e)+C1_e[xm_e])*xl_e+C0_e[xm_e]; %FB_ye = 27
% y_e = (round((Ce(3,xm_e+1).*xl_e)*2^30)/2^30+Ce(2,xm_e+1)).*xl_e+Ce(1,xm_e+1); %FB_ye = 27
yt1 = floor(Ce(3,xm_e+1).*xl_e*2^30)/2^30;
yt2 = yt1 + Ce(2,xm_e+1);
yt3 = floor(yt2.*xl_e*2^30)/2^30;
y_e = yt3 + Ce(1,xm_e+1); %(0,30,30)
% y_e = round(y_e*2^27)/2^27;%FB_ye=27

% Range Reconstruction
ln2 = log(2);%e = 2.7183
ln2 = round(ln2*2^30)/2^30;
ec = exp_e*ln2;
% ec = round(ec*2^27)/2^27; %(0,33,27)
e  = floor(2*(ec+y_e)*2^24)/2^24; %(0,31,24)

e_fix = uint64(round(e*2^24)); %IB=7, FB=24
e_fix(e_fix>2^31-1) = 2^31-1; %(0,31,24)

clear exp_e x_e xm_e xl_e y_e ec yy d

%% --------------- Evaluate f = sqrt (e) -----------
% Range Reduction
Offset = 5;
exp_f = Offset-LeadingZeroDetect(e_fix, 31); % Note: Offset=IBe-2;
x_f = bitshift(e_fix, -exp_f);
f_idx = find(mod(exp_f,2)==1);
f_idx2 = setdiff((1:len), f_idx);

x_f(f_idx) = bitshift(x_f(f_idx),-1);
exp_f(f_idx) = exp_f(f_idx) + 1;

p = 31;
k = 6;
m = 24-6;
xm_f(f_idx) = bitand(bitshift(x_f(f_idx),-m),2^k-1);
xl_f(f_idx) = double(bitand(x_f(f_idx), hex2dec('3FFFF')))/2^m;%double(x_e)/2^48;%
xm_f(f_idx2) = bitand(bitshift(x_f(f_idx2),-m-1),2^k-1);
xl_f(f_idx2) = double(bitshift(bitand(x_f(f_idx2), hex2dec('7FFFF')),-1))/2^m;%double(x_e)/2^48;%

% Approximate sqrt (x_f) where x_f = [1,4)
% x_f is [1,2) --> x_f = 1 + xm_f + xl_f * 2^-k_f
% or
% x_f is [2,4) --> x_f = 2 + 2*xm_f + xl_f * 2^(-k_f+1)
% Degree-(n-1) piecewise polynomial - 2^k_f segments
% example is Degree-1
%(1,21,19)*
y_f(f_idx)  = floor(Cf1(2,xm_f(f_idx )+1).*xl_f(f_idx )*2^23)/2^23 + Cf1(1,xm_f(f_idx )+1);
y_f(f_idx2) = floor(Cf2(2,xm_f(f_idx2)+1).*xl_f(f_idx2)*2^23)/2^23 + Cf2(1,xm_f(f_idx2)+1);
% Range Reconstruction
% exp_f' = if(exp_f[0], exp_f+1>>1, exp>>1);
f = y_f .* 2.^(exp_f/2);
f = floor(f*2^16)/2^16; %(0,20,16)

disp(['e / f error max(compared to float):' num2str(max(abs(-2*log(double(u0)/2^48)-e))) ' ' num2str(max(abs(f-sqrt(e))))]);

clear e_fix exp_f x_f f_idx f_idx2 xm_f xl_f y_f
%% ------------ Evaluate g0=sin(2*pi*u1) -----------
% %------------ g1=cos(2*pi*u1) ------------
% Range Reduction
MSB = 14;
quadrant = bitshift(u1,-14);
x_g_a = bitand(u1,hex2dec('3FFF'));
x_g_b = (2^14-1)-x_g_a;

p = 14;
k = 7;
m = p - k;
xm_g_a = bitand(bitshift(x_g_a,-m),2^k-1);
xl_g_a = double(bitand(x_g_a, hex2dec('7F')))/2^m;
xm_g_b = bitand(bitshift(x_g_b,-m),2^k-1);
xl_g_b = double(bitand(x_g_b, hex2dec('7F')))/2^m;
% Approximate cos(x_g_a*pi/2) and cos(x_g_b*pi/2)
% where x_g_a, x_g_b = [0,1-2^-(MSB-1)]
% Degree-(n-1) piecewise polynomial - 2^k_g segments
% x_g is [0,1) --> x_g = xm_g + xl_g * 2^-k_g
% example is Degree-2
y_g_a = -floor((-Cg(2,xm_g_a+1).*xl_g_a)*2^18)/2^18 + Cg(1,xm_g_a+1); %(0,18,18)
y_g_b = -floor((-Cg(2,xm_g_b+1).*xl_g_b)*2^18)/2^18 + Cg(1,xm_g_b+1);

y_g_a = floor(y_g_a*2^15)/2^15; %(0,15,15)
y_g_b = floor(y_g_b*2^15)/2^15;

y_g_a(y_g_a>=1) = (2^15 - 1)/2^15;
y_g_b(y_g_b>=1) = (2^15 - 1)/2^15;

% Range Reconstruction
g0(quadrant==0) =  y_g_b(quadrant==0);
g0(quadrant==1) =  y_g_a(quadrant==1);
g0(quadrant==2) = -y_g_b(quadrant==2);
g0(quadrant==3) = -y_g_a(quadrant==3);
g1(quadrant==0) =  y_g_a(quadrant==0);
g1(quadrant==1) = -y_g_b(quadrant==1);
g1(quadrant==2) = -y_g_a(quadrant==2);
g1(quadrant==3) =  y_g_b(quadrant==3);

disp(['g0/g1 error max(compared to float):' num2str(max(abs(sin(double(u1)/2^14*pi/2)-g0))) ' ' num2str(max(abs(cos(double(u1)/2^14*pi/2)-g1)))]);

clear x_g_a x_g_b xm_g_a xm_g_b xl_g_a xl_g_b y_g_a y_g_b quadrant

% switch(quadrant)
%     case 0 
%         g0 = y_g_b; g1 = y_g_a; % [0, pi/2)
%     case 1
%         g0 = y_g_a; g1 = -y_g_b; % [pi/2, pi)
%     case 2
%         g0 = -y_g_b; g1 = -y_g_a; % [pi, 3*pi/2)
%     case 3
%         g0 = -y_g_a; g1 = y_g_b; % [3*pi/2, 2*pi)
% end

%% --------------- Compute x0 and x1 --------------
x0 = f.*g0; 
x1 = f.*g1;

x0 = myround(x0*2^13)/2^13; %(1,18,13)
x1 = myround(x1*2^13)/2^13;

disp(['x0/x1 error max(compared to float):' num2str(max(abs(w0-x0))) ' ' num2str(max(abs(w1-x1)))]);

disp(['x0/x1 var : ' num2str(var(x0)) ' ' num2str(var(x1))]);
disp(['x0/x1 mean: ' num2str(mean(x0)) ' ' num2str(mean(x1))]);

if write_file==1
    disp('Writing golden data to files......');
    dlmwrite('./bitMatchFile/e.txt',e'*2^24,'precision','%u');
    dlmwrite('./bitMatchFile/f.txt',f'*2^16,'precision','%u');
    dlmwrite('./bitMatchFile/g0.txt',g0'*2^15,'precision','%d');
    dlmwrite('./bitMatchFile/g1.txt',g1'*2^15,'precision','%d');
    dlmwrite('./bitMatchFile/x0.txt',x0'*2^13,'precision','%d');
    dlmwrite('./bitMatchFile/x1.txt',x1'*2^13,'precision','%d');
end

if write_file==0
xx=-8.2:0.001:8.2;
fx = 1/sqrt(2*pi)*exp(-xx.^2/2);

% awgn0 = randn(1,len);

figure;
h1 = histogram(w0);
hold on;
% h2 = histogram(awgn0);
h3 = histogram(x0);
h1.Normalization = 'pdf';
% h2.Normalization = 'pdf';
h3.Normalization = 'pdf';
plot(xx,fx,'-r');
grid on;
title('BoxMuller Fixed Point(1,18,13) Generator PDF')
ylabel('PDF')

% [
% ceil(log2(max(abs( Ce(1,:)*2^30))))
% ceil(log2(max(abs( Ce(2,:)*2^30))))
% ceil(log2(max(abs( Ce(3,:)*2^30))))
% ceil(log2(max(abs(Cf1(1,:)*2^19))))
% ceil(log2(max(abs(Cf1(2,:)*2^19))))
% ceil(log2(max(abs(Cf2(1,:)*2^19))))
% ceil(log2(max(abs(Cf2(2,:)*2^18))))
% ceil(log2(max(abs( Cg(1,:)*2^18))))
% ceil(log2(max(abs( Cg(2,:)*2^18))))]'
end


