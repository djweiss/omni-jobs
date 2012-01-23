function [ f ] = encode( str )

f = str;
encoding = encode_strings();

for i = 1:2:numel(encoding)
  f = strrep(f, encoding{i}, encoding{i+1});
end

f = ['z_' f];



