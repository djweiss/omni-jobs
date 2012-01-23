function [n] = oj_nodecheck(stats)

crashidx = find([stats.crashed] & ~[stats.completed]);
completeidx = find([stats.completed]);

nodes = unique([stats.node]);


for i = 1:count(nodes)
  
  n(i).node = nodes(i);
  n(i).crashed = count([stats(crashidx).node]==nodes(i));
  n(i).completed = count([stats(completeidx).node]==nodes(i));

end

oj_disp(n);