function submit(jobsdir, varargin)
% Submits any unsubmitted jobs from a batch job directory.
%
% Usage:
% 
%   oj.submit(jobsdir, ...)
%
% For the jobs directory JOBSDIR, looks at all job files and
% submits any that haven't yet been submitted. Please note the
% optional argument MATLAB_STARTDIR; it's important that this is
% set properly for your environment.
% 
% Options:
%
%   - 'matlab_exec' : A string containing the shell command used by
%   the submission script to start Matlab. (Default: 'matlab
%   -nodisplay -nojvm -singleCompThread')
%
%   - 'matlab_startdir' : The directory in which the matlab invoking
%   command should be called. This is the directory that contains your
%   startup.m file. If set to 'auto', OJ.SUBMIT will try to figure out
%   this path automatically. (Default: 'auto')
%
%   - 'sleep' : The number of seconds to sleep in between job
%   submissions, to avoid a blocked queue of long jobs so that even
%   long jobs will finish at regular intervals. (Default: 0 seconds.)
%
%   - 'maxsleep' : The maximum number of jobs to space, so that jobs
%   can be submitted rapidly after all available slots are taken
%   (Default: 0).
% 
%   - 'filter' : A shell search string (e.g., '1*'), so that only
%   jobs matching this string will be submitted. (Default: '*')
%
%   - 'dryrun' : If true, OJ.SUBMIT will output which jobs would be
%   submitted submitted rather than actually submitting
%   them. (Default: false)
%
%   - 'q': Specify a list of queue's to submit to. Default: '' (all
%   queues).
%
%   - 'qsubargs': A list of options to pass to QSUB. Default: ''
%   (none).
%
% SEE ALSO
%   oj.write, oj.quickbatch, oj.load

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


defaults.matlab_exec = 'matlab -nodisplay -singleCompThread';
defaults.matlab_startdir = 'auto';
defaults.sleep = 0; % delay of submission between jobs
defaults.maxsleep = 0; % stop sleeping after submitting this # of jobs
defaults.filter = '*';
defaults.dryrun = false;
defaults.avoid = []; % node's to avoid
defaults.q = ''; 
defaults.qsubargs = ''; %'-p -100';
args = propval(varargin, defaults);

if ~isempty(args.q)
    args.qsubargs = sprintf('%s -q %s', args.qsubargs, args.q);
end

[args] = validate(args);

% Get a list of .opusjob files to run
files = dir(sprintf('%s/jobs/%s', jobsdir, args.filter));
files = files([files.bytes] > 0);

numsubs = 0;
for i = 1:numel(files)

  % Check if the job has already been submitted
  t = dir(sprintf('%s/submitted/%s', jobsdir, files(i).name));
  if ~isempty(t)
    fprintf('Job ''%s'' has already been submitted. Skipping...\n', ...
            files(i).name);
    continue;
  end
    
  if args.dryrun
    fprintf('DRY RUN: would submit job ''%s''.\n', files(i).name);
  else
    % make a shellscript for this file and submit it
    make_shellscript(files(i).name);
    submit(files(i).name);    
  end
    
  numsubs = numsubs + 1;
  
  % stagger if desired
  if args.sleep > 0 && numsubs < args.maxsleep
    fprintf('Sleeping %d seconds...\n', args.sleep);
    pause(args.sleep); %[s,o] = system(sprintf('sleep %d', args.sleep));
  end

end

fprintf('Submitted %d jobs from directory ''%s''.\n', numsubs, ...
        jobsdir);

%%%%%%%%%%%%%%%%%%%%%% Fully Nested Helpers

function [args] = validate(args)

if strcmp(args.matlab_startdir, 'auto')
  
  startdir = which('startup');
  if ~isempty(startdir)
    args.matlab_startdir = fileparts(startdir);
  else
    error(['Cannot determine the starting directory automatically. ' ...
           'Make sure that ''startup.m'' is on your path.']);
  end
  
end
args.matlab_startdir = oj.path(args.matlab_startdir);
jobsdir = oj.path(jobsdir);

end

% creates a shellscript for a given opusjob
function [scriptname] = make_shellscript(jobname)

% create name for script using the same prefix as opusjob file
scriptname = sprintf('%s/shell/%s', jobsdir, jobname);

fid = fopen(scriptname, 'w');
if (fid == -1)
  error('Unable to open script ''%s'' for writing.', scriptname);
end

try
    
  fprintf(fid, '#!/bin/bash\n');
  %fprintf(fid, 'unset DISPLAY\n');
  fprintf(fid, 'cd %s\n', args.matlab_startdir);
  fprintf(fid, 'echo $JOB_ID >> %s/started/%s\n', jobsdir, jobname);
  fprintf(fid, 'echo $HOSTNAME >> %s/started/%s\n', jobsdir, jobname);
  fprintf(fid, 'echo `date` >> %s/started/%s\n', jobsdir, jobname);
  fprintf(fid, '%s < %s/jobs/%s \n', args.matlab_exec, jobsdir, ...
          jobname);  
  fclose(fid);
catch
  
  fclose('all');
  rethrow(lasterror);
end   
  
end

% submits a single script
function submit(jobname)

errfile = [jobsdir '/stderr/' jobname];
outfile = [jobsdir '/stdout/' jobname];

filename = [jobsdir '/shell/' jobname];

qargs = sprintf('%s -V -e %s -o %s', args.qsubargs, errfile, outfile);
cmdstr = sprintf('qsub %s %s', qargs, filename); %, filename);

%fprintf('executing command: %s\n', cmdstr);
[status, result] = unix(cmdstr);

if status == 1
  dispf('Cannot submit job ''%s'': %s', jobname,  result);
else

  jobid = sscanf(result, 'Your job %d');
  fprintf('Success (job %d): %s', jobid, result);

  % Figure out job id  
  unixf('echo %d > %s/submitted/%s', jobid, jobsdir, jobname);
end

end

end
