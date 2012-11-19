function [] = oj_reset(jobs, varargin)


if nargin == 1
  for i = 1:numel(jobs)
    
    dispf('Resetting job %s...', jobs(i).jobname);
    
    % Clear everything related to a job but the shell script wrapper
    dirs = {'completed', 'save', 'started', 'submitted', 'stderr', ...
            'stdout'};
    
    for j = 1:numel(dirs)
      unixf('rm -vf %s/%s/%s*', jobs(i).jobsdir, dirs{j}, jobs(i).jobname);
    end
    
  end
else
  jobsdir = jobs;
  jobname = varargin{1};
  unixf('find %s -iname %s | egrep -v jobs\\|shell | xargs rm -v', jobsdir, jobname);
end

