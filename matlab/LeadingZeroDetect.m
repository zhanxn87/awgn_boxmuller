function lz_cnt = LeadingZeroDetect(x, bitW)

lz_cnt = bitW - ceil(log2(double(x)+1));
lz_cnt(x==0) = bitW;