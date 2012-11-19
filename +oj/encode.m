function [ f ] = encode( str )
% Converts a string with arbitrary characters into a fieldname.
% 
% SEE ALSO
%   oj.decode, oj.encoding

f = str;
try
    s.(str) = 0;
    return;
catch
end

encoding = oj.encoding();

for i = 1:2:numel(encoding)
  f = strrep(f, encoding{i}, encoding{i+1});
end

f = ['z_' f];



