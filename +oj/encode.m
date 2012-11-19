function [ f ] = encode( str )
% Encodes a string with arbitrary characters into a fieldname.
% 
% SEE ALSO
%   OJ.FIELDS, OJ.DECODE, OJ.ENCODING

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



