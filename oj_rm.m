function [stripped] = oj_rm(results, field)

for i = 1:numel(results)
  stripped(i) = rmfield(results(i), field);
end
