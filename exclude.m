function [new_idx] = exclude(idx, N)

strip = ones(N, 1);
strip(idx) = 0;
new_idx = find(strip);
