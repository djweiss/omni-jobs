function [ f ] = decode( str )
% Decodes a string encoded with OJ.ENCODE. 
% 
% SEE ALSO
%   OJ.FIELDS, OJ.ENCODE, OJ.ENCODING

f = str;

if (length(str) < 2)
    return; 
end
if str(1:2) ~= 'z_'
    return; 
end

f = str(3:end);
encoding = oj.encoding();

for i = 1:2:numel(encoding)
  f = strrep(f, encoding{i+1}, encoding{i});
end





