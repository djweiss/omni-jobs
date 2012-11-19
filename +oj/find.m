function [idx] = oj_find(r, matchfunc, varargin)
% IDX = OJ_FIND(R, MATCHFUNC, VARARGIN)

n = nargin(matchfunc);
if numel(varargin) ~= n
    error(['comparison function has %d arguments but you only provided ' ...
           '%d'], n, numel(varargin));
end

idx = zeros(numel(r), 1);

for j = 1:numel(r)
    data = oj_get(r(j), 'mixed', varargin{:});
    if (iscell(data)) idx(j) = matchfunc(data{:});
    else idx(j) = matchfunc(data);
    end
end

idx = find(idx);
