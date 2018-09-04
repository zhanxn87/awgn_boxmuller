function y = myround(x)

y = x;
idx = ((y+0.5)==floor(y+0.5));
y(idx) = floor(y(idx)+0.5);
idx2 = y>=0;
idx3 = y<0;
y(idx2) = floor(y(idx2) + 0.5);
y(idx3) = -1*floor(-y(idx3) + 0.5);