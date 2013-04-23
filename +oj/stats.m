function [jobs] = stats(jobsdir, varargin)
% Generates a status report on a batch job directory.
%
% Usage:
%
%   jobs = oj.stats(jobsdir, ...)
%
% OJ.STATS determines the status of currently running jobs, belonging
% to a particular jobsdir. It does this by checking for submit files,
% started files, lock files, stdout and stderr files, etc. etc. and
% attempting to determining the state of each job.
%
% The output of OJ.STATS is useful; it can be passed to either
% OJ.REPORT for display or to OJ.RESET to reset the status of
% individually failed jobs.
%
% Options:
%
%   - 'load_output' : Whether or not to load the STDOUT of each job
%   into memory for inspection. Default: true
%
%   - 'load_errors': Whether or not to load the STDERR of each job
%   into memory for inspection. Default: true
%
% SEE ALSO
%   oj.reset, oj.report, oj.submit, oj.quickbatch

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


jobsdir = oj.path(jobsdir);

defaults.load_output = false;
defaults.load_errors = true;

defaults.progress = true;
defaults.check_qstat = true;
defaults.filter = '*';

args = propval(varargin, defaults);
savepwd = pwd;

  cd(jobsdir);
   
  % Get a listing of all of the jobs.
  jobfiles = dir(sprintf('%s/jobs/%s', jobsdir, args.filter));
  jobfiles = jobfiles([jobfiles.bytes] > 0);
  
  % Allocate space for all of the job structures, with default values
  jobs = repmat(init,numel(jobfiles), 1);

  if args.progress
      fprintf('Reading job info: ');
      t0 = CTimeleft(numel(jobs), true);
  end
  for i = 1:numel(jobfiles)

    % Get the name of the job
    jobs(i).jobname = jobfiles(i).name;
    jobs(i).jobsdir = jobsdir;

    % Check to see if the job has been submitted
    if exist(['submitted/' jobs(i).jobname], 'file')
      jobs(i).submitted = true;
    end   
      
    % Check to see if the job has started
    f = dir(['started/' jobs(i).jobname]);
    if ~isempty(f)
      
      % Read the job id, node #, etc. from the start file
      startinfo = readtext(['started/' f.name]);
      
      jobs(i).started = true;
      jobs(i).start_time = f.date;

      if rows(startinfo) > 1
          if ~args.check_qstat
              jobs(i).jobid = str2num(startinfo{1});
          else
              jobs(i).jobid = -1;
          end
          jobs(i).host = startinfo{2};
      else
        jobs(i).jobid = -1;
        jobs(i).host = -1;
      end
      
    end        
    
    % Check to see if job has completed
    f = dir(['completed/' jobs(i).jobname]);
    if ~isempty(f)      
      jobs(i).completed = true;
      jobs(i).finish_time = f.date;      
      jobs(i).run_time = etime(datevec(jobs(i).finish_time),...
                               datevec(jobs(i).start_time));    
    end
    
    % Check to see if job has crashed
    f = dir(['stderr/' jobs(i).jobname]);
    if ~isempty(f)
      if f.bytes > 0        
        jobs(i).crashed = true;
        jobs(i).finish_time = f.date;        
        jobs(i).run_time = etime(datevec(jobs(i).finish_time),...
                                 datevec(jobs(i).start_time));

        if args.load_errors
          jobs(i).errormsg = readtext(['stderr/' jobs(i).jobname]);
        end        
      end            
    end

    % Check for output from the job
    f = dir(['stdout/' jobs(i).jobname]);
    if ~isempty(f)

      jobs(i).output_bytes = f.bytes;
      jobs(i).last_modified = f.date;
      
      jobs(i).hang_time = etime(datevec(now), ...
                               datevec(jobs(i).last_modified));
      
      if args.load_output
        jobs(i).output = readtext(['stdout/' jobs(i).jobname]);
      end
    end
              
    % Check if this job should be considered "running"
    if jobs(i).started && ~jobs(i).completed && ~jobs(i).crashed
      jobs(i).run_time = etime(datevec(now), ...
                               datevec(jobs(i).start_time));
      jobs(i).running = true;
    end

    if args.progress
      t0.timeleft();
    end
    
  end

  % Check against qstat if desired
  if args.check_qstat

      [~,str] = unix('qsf');
      str = split(str, '\n');
      for i = 1:numel(jobs)
          idx = find(strncmp(jobs(i).jobname, str, numel(jobs(i).jobname)));
          if isempty(idx) && ~jobs(i).completed && ~jobs(i).crashed
              jobs(i).mia = true;
          elseif ~isempty(idx)
              s = split(str{idx});
              jobs(i).jobid = str2num(s{2}); 
          end
          if isempty(jobs(i).jobid)
              jobs(i).jobid = -1;
          end
      end
      
  end
%           
%       %%
%       
%     idx = find([jobs.running]);
%     for i = idx
% 
%       % Check for the existence of this job id #
%       [status,result] = system(sprintf('qstat -s r | grep %d', jobs(i).jobid));
% 
%       if status == 1 % job not found: it disappeared!
%         jobs(i).mia = true;
%       end
%     end    
% 
%     idx = find([jobs.submitted] & ~[jobs.started]);
%     if ~isempty(idx)
% 
%       % Check for the existence of waiting jobs
%       cmd = sprintf('qstat -s p | grep %s', jobs(1).jobname(1:4));
%       [status,result] = system(cmd);
% 
%       % No waiting jobs anymore -- these must be broken!
%       if isempty(result)
%         jobs(idx) = oj.set(jobs(idx), 'mia', repmat(true, count(idx), 1));
%       end
%       
%     end    
%   end
  
  % Return to original working directory
  cd(savepwd);


function [s] = init()

s.submitted = false;
s.started = false;
s.running = false;
s.crashed = false;
s.completed = false;
s.mia = false;

s.jobname = 'n/a';

s.start_time = 'n/a';
s.last_modified = 'n/a';
s.finish_time = 'n/a';
s.run_time = 'n/a';

s.output_bytes = -1;
s.output = 'n/a';
s.errormsg = 'n/a';

s.jobid = -1;
s.host = -1;

s.hang_time = -1;
s.jobsdir = 'n/a';

%%%%%%%%%%%%%%
function [str ] = readtext(filename)

fid = fopen(filename);
if fid == -1
  error('Unable to open file ''%s'' for reading.\n', filename);
end

str = textscan(fid, '%s', 'Delimiter', '\n', 'BufSize', 65536);
fclose(fid);
str = str{:};
      
%str = strvcat(str{:});
      
