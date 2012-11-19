function [fields] = fields(r)
% Returns a list of (possibly encoded) fieldnames.
%
% SEE ALSO
%   OJ.ENCODE, OJ.DECODE

fields = fieldnames(r);
for i = 1:numel(fields)
    fields{i} = oj_decode(fields{i});
end
