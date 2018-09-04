function y = taus_URNG_m(seed, len)

  s0 = uint32(seed);
  s1 = uint32(seed);
  s2 = uint32(seed);
  
  y = uint32(zeros(1,len));

  for ii=1:len
    %b0 = (((s0 << 13) ^ s0) >> 19);
    b0 = bitshift(bitxor(bitshift(s0,13),s0),-19);
    %s0_next = (((s0 & 0xFFFFFFFE) << 12) ^ b0);
    s0_next = bitxor(bitshift(bitand(s0,hex2dec('FFFFFFFE')),12), b0);
    
    %b1 = (((s1 << 2) ^ s1) >> 25);
    %s1_next = (((s1 & 0xFFFFFFF8) << 4) ^ b1);
    b1 = bitshift(bitxor(bitshift(s1,2),s1),-25);
    s1_next = bitxor(bitshift(bitand(s1,hex2dec('FFFFFFF8')),4),b1);
    
    %b2 = (((s2 << 3) ^ s2) >> 11);
    %s2_next = (((s2 & 0xFFFFFFF0) << 17) ^ b2);
    b2 = bitshift(bitxor(bitshift(s2,3),s2),-11);
    s2_next = bitxor(bitshift(bitand(s2,hex2dec('FFFFFFF0')),17),b2);

    %u0[i] = (unsigned int)(s0 ^ s1 ^ s2);
    y(ii) = uint32(bitand(bitxor(bitxor(s0,s1), s2),hex2dec('FFFFFFFF')));

    s0 = s0_next;
    s1 = s1_next;
    s2 = s2_next;
  end
  