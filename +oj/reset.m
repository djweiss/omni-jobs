function [] = reset(jobs, varargin)
% Delete the files associated with a specific set of jobs.
%
% Usage:
%
%   oj.reset(jobs)
%
% Given the output of OJ.STATS, pass one or more jobinfo structs to
% OJ.RESET and OJ.RESET will delete the submission files of only
% those jobs. Useful when you need to restart crashed jobs without
% cleaning the entire directory.
%
% SEE ALSO
%   oj.clean


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

