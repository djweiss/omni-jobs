function [ f ] = oj_encode( str )

f = str;
try
    s.(str) = 0;
    return;
catch
end

encoding = oj_encoding();

for i = 1:2:numel(encoding)
  f = strrep(f, encoding{i}, encoding{i+1});
end

f = ['z_' f];



