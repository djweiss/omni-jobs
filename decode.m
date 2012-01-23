function [ f ] = decode( str )

if (length(str) < 2)
  error('string was not encoded');
end
if str(1:2) ~= 'z_'
  error('string was not encoded');
end

f = str(3:end);
encoding = encode_strings();

for i = 1:2:numel(encoding)
  f = strrep(f, encoding{i+1}, encoding{i});
end





