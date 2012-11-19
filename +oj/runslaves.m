function [] = oj_runslaves(jobsdir, Nrange, stopat)
% Submits N slave processes, which will process jobs individually.

for i = Nrange
  
  jobname = sprintf('%s_slave%.2d', jobsdir, i);
  dispf('Starting slave ''%s''...', jobname);

  unixf('mkdir -p slaveout');
  if nargin==2
    unixf('my_submit.bash slaveout/%s oj_slave \\''%s\\''', jobname, jobsdir);
  else
    unixf(['my_submit.bash slaveout/%s oj_slave \\''%s\\'' \\''stopat\\''' ...
           ' %d'], jobname, jobsdir, stopat);    
  end
  
end