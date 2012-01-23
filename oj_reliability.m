function [n] = oj_reliability(restartlog)

nodes.node = -1;
nodes.hung = 0;
nodes.err = 0;
nodes = repmat(nodes, 100, 1);

for i = 1:numel(restartlog)
  
  nid = restartlog(i).node;
  
  nodes(nid).node = nid;
  nodes(nid).(restartlog(i).reason) = ...
      nodes(nid).(restartlog(i).reason) + 1;
  
end

nodes = nodes(oj_get(nodes,'node')>0);

nodes = oj_sort(nodes, 'err', 'descend');
oj_disp(nodes);
