function [m ste] = oj_mean(sa, varargin)
if nargin==1
    fields = fieldnames(sa);
else
    fields = varargin;
end

for i = 1:numel(fields)
  
  f = fields{i};
  
  d = oj_get(sa, f);
  if ~iscell(d)
    m.(f) = mean(d);
    ste.(f) = std(d)./sqrt(length(d));
  end
end
