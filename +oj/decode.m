function [ f ] = decode( str )
% Convert a string encoded with oj.encode into human-readable format.
% 
% SEE ALSO
%   oj.encode, oj.encoding

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





