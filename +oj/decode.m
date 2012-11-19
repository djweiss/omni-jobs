function [ f ] = oj_decode( str )

f = str;

if (length(str) < 2)
    return; %error('string was not encoded');
end
if str(1:2) ~= 'z_'
    return; %error('string was not encoded');
end

f = str(3:end);
encoding = oj_encoding();

for i = 1:2:numel(encoding)
  f = strrep(f, encoding{i+1}, encoding{i});
end





