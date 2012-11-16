function [g] = oj_groupmeans(data, fx, fys, varargin)

[grp grpnames groups] = oj_group(data, fx{:});

%x = oj_get(groups, fx);
for j = 1:numel(fys)

    clear y yvar ystd n
    fy = fys{j};
    for i = 1:numel(grpnames)
        y(i,:) = mean(oj_get(data(grp==i), fy));
        yvar(i,:) = var(oj_get(data(grp==i), fy));
        ystd(i,:) = std(oj_get(data(grp==i), fy))/sqrt(sum(grp==i));
        n(i) = sum(grp==i);
    end
    
    %g = repmat(struct(),numel(grpnames), 1);
    %g = oj_set(g, fx, x');
    groups = oj_set(groups, [fy ' (Mean)'], y);
   % groups = oj_set(groups, [fy ' (Var)'], yvar');
    groups = oj_set(groups, [fy ' (Ste)'], ystd);
end
groups = oj_set(groups, 'n', n);

g = groups;