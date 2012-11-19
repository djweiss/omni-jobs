function oj_bargrp(data, fx, fy, varargin)

[grp grpnames groups] = oj_group(data, fx);

x = oj_get(groups, fx);

for i = 1:numel(grpnames)

  y(i) = mean(oj_get(data(grp==i), fy));
  e(i) = ste(oj_get(data(grp==i), fy));  
end


barerr(x, y, e, varargin{:});
