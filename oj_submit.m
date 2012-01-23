function oj_submit(jobsdir, varargin)
% Submits any unsubmitted jobs from an OPUSJOBS directory.
%
% OJ_SUBMIT(JOBSDIR, ...)
%
% For the jobs directory JOBSDIR, looks at all job files and
% submits any that haven't yet been submitted. Please note the
% optional argument MATLAB_STARTDIR; it's important that this is
% set properly for your environment.
% 
% OPTIONAL ARGUMENTS:
%
% MATLAB_EXEC - A string containing the shell command used by
%   the submission script to start Matlab. (Default: 'matlab_local')
%
% MATLAB_STARTDIR - The directory in which the matlab invoking
%   command should be called. This is the directory that contains
%   your startup.m file. If set to 'auto', OJ_SUBMIT will try to
%   figure out this path automatically. (Default: 'auto')
%
% SLEEP - The number of seconds to sleep in between job
%   submissions, to avoid a blocked queue of long jobs so that even
%   long jobs will finish at regular intervals. (Default: 0 seconds.)
%
% MAXSLEEP - The maximum number of jobs to space, so that jobs can
%   be submitted rapidly after all available slots are taken
%   (Default: 0).
% 
% FILTER - A shell search string (e.g., 'subj1*'), so that only
%   jobs matching this string will be submitted. (Default: '*')
%
% DRYRUN - If true, OJ_SUBMIT will output which jobs would be submitted
%   submitted rather than actually submitting them. (Default: false)
%
% See also OJ_WRITE, OJ_RESUBMIT, OJ_LOAD, OJ_QUICKBATCH.

defaults.matlab_exec = 'matlab -nodisplay -nojvm';
defaults.matlab_startdir = 'auto';
defaults.sleep = 0; % delay of submission between jobs
defaults.maxsleep = 0; % stop sleeping after submitting this # of jobs
defaults.filter = '*';
defaults.dryrun = false;
defaults.avoid = []; % node's to avoid
defaults.qsubargs = '-q default@alef.seas.upenn.edu,default@bet.seas.upenn.edu,default@gimel.seas.upenn.edu,default@dalet.seas.upenn.edu'; %'-l mem=10G';

args = propval(varargin, defaults);
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
args.matlab_startdir = oj_path(args.matlab_startdir);
jobsdir = oj_path(jobsdir);

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
  fprintf(fid, 'unset DISPLAY\n');

  if ~isempty(args.avoid)
       
    fprintf(fid, 'node=`echo $HOSTNAME | sed ''s/.*node\\([0-9]*\\)\\.cluster.private/\\1/g''`\n');
    fprintf(fid, '\tts=`date`\n');
    fprintf(fid, 'echo "$ts: $node attempting" >> %s/avoidlog\n', jobsdir);
    for a = 1:numel(args.avoid)
      
      fprintf(fid, 'if [[ "$node" == "%.2d" ]]; then\n', args.avoid(a));
      fprintf(fid, '\techo "$ts: $node detected. Resubmitting job $JOB_ID" >> %s/avoidlog\n', jobsdir);
      fprintf(fid, '\tqresub $JOB_ID\n');
      fprintf(fid, '\tsleep 100\n');
      fprintf(fid, '\texit 1\n');
      fprintf(fid, 'fi\n');
      
    end    
  end
    
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
cmdstr = sprintf('qsub %s %s', qargs, filename);

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
