function [mat] = oj_nodecheck(stats, restartlog)

% Look for crashed jobs
idx = strmatch('err', oj_get(restartlog, 'reason'));
idx = vertcat(idx, strmatch('hung', oj_get(restartlog, 'reason')));

crashednode = oj_get(restartlog(idx), 'node');

idx = find([stats.completed]);

goodnode = oj_get(stats, 'node');


for i = 1:64

  cb = count(crashednode==i);
  cg = count(goodnode==i);
  if cb > 0
    dispf('Node %d: %g - %d/%d', i, cb/(cb+cg), cb, cb+cg);    
  end
  
  if cb+cg>0
    ratio = cb/(cb+cg);
  else
    ratio = 0;
  end
  
  mat(i, :) = [i ratio cb cb+cg];
end


