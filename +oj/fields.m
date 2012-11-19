function [fields] = fields(r)
% Fetches a list of human-readable fieldnames.
%
% SEE ALSO
%   oj.encode, oj.decode

fields = fieldnames(r);
for i = 1:numel(fields)
    fields{i} = oj_decode(fields{i});
end
