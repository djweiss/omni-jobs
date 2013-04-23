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

% ======================================================================
% Copyright (c) 2012 David Weiss
% 
% Permission is hereby granted, free of charge, to any person obtaining
% a copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to
% permit persons to whom the Software is furnished to do so, subject to
% the following conditions:
% 
% The above copyright notice and this permission notice shall be
% included in all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
% EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
% NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
% LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
% OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
% WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
% ======================================================================


if nargin == 1
  for i = 1:numel(jobs)
    
    dispf('Resetting job %s...', jobs(i).jobname);
    
    % Clear everything related to a job but the shell script wrapper
    dirs = {'completed', 'save', 'started', 'submitted', 'stderr', ...
            'stdout'};
    
    for j = 1:numel(dirs)
      unixf('rm -vf %s/%s/%s*', jobs(i).jobsdir, dirs{j}, jobs(i).jobname);
    end
    
    if jobs(i).jobid > 0
       unixf('qdel %d', jobs(i).jobid); 
    end
    
  end
else
  jobsdir = jobs;
  jobname = varargin{1};
  unixf('find %s -iname %s | egrep -v jobs\\|shell | xargs rm -v', jobsdir, jobname);
end

