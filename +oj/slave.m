function [log] = slave(jobsdir, varargin)
% Start locally processing a jobsdir one job at a time.
%
% Usage:
%
%   log = oj.slave(jobsdir, ...)
%
% An alternative to using SGE, OJ.SLAVE will start processing the
% jobs in JOBSDIR one at a time.
%
% Options:
%
%   - 'stopat': Stop when this many jobs have been
%   processed. Default: inf.
%
%   - 'filter': Ignore jobs that don't match this filter. 
%   Default: '*'
%  
%   - 'logout': Run silently and write the log to disk. Default: false.
% 
%   - 'force' : Ignore if jobs have already been
%   processed. Default: false.

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


defaults.filter = '*';
defaults.logout = false;
defaults.force = false;
defaults.stopat = Inf;
args = propval(varargin, defaults);

jobsdir = oj.path(jobsdir);

savepwd = pwd;
cd(jobsdir);

jobs = dir(sprintf('jobs/%s', args.filter));
jobs = jobs(~[jobs.isdir]);

runjobs = 1;

for i = 1:numel(jobs)

  if (runjobs > args.stopat)
    dispf('stopat=%d limit reached.', args.stopat);
    break;
  end
  
  jobname = jobs(i).name; 
  fprintf('Inspecting job ''%s''...\n', jobname);
  
  % Check for unsubmitted, unstarted jobs
  if (isempty(dir(sprintf('submitted/%s', jobname))) && ...
    isempty(dir(sprintf('started/%s', jobname)))) || ...
    args.force
      
    fprintf('\tJob ''%s'' has not been submitted or started.\n', jobname);
    fprintf('\tStarting now...\n');

    % Mark this job as submitted so nobody else touches it
    system(sprintf('touch submitted/%s', jobname));

    % Set up a dummy ''started'' file
    system(sprintf('echo -1 >> started/%s', jobname));
    system(sprintf('echo `hostname` >> started/%s', jobname));
    system(sprintf('echo `date` >> started/%s', jobname));    
    %system(sprintf('echo node-1.cluster.private >> started/%s', jobname));

    jobsdirpwd = pwd;
    % Load the job itself    
    try
      
      jobcmd = readtext(sprintf('jobs/%s', jobname));
      
      jobcmd = stripline(jobcmd, 'oj_resubmit');
      jobcmd = stripline(jobcmd, 'exit');
      jobcmd = stripline(jobcmd, 'dbstack');
      jobcmd = stripline(jobcmd, 'dbstop');
     
      cmdstr = [];
      for i = 1:rows(jobcmd)
        cmdstr = strcat(cmdstr, jobcmd(i,:), ';');
      end
      
      dispf('running command: ''%s''', cmdstr);    

      % Run it
      log = 'Output not captured.';
      if args.logout 
          fprintf('\tRunning silently... (output being captured)\n');
          log = evalc(cmdstr);
      else
          eval(cmdstr);
      end

      runjobs = runjobs + 1;
      cd(jobsdirpwd);
      f = fopen(sprintf('stdout/%s', jobname), 'w');

      
      for j = 1:rows(log)
          fprintf(f, '%s\n', log(j,:));
      end    
      fclose(f);
      
    catch
      
      cd(jobsdirpwd);
      e=  lasterror;
      for i = 1:numel(e.stack)
          e.stack(i)
      end
      e = lasterr;
      fprintf('Job ''%s'' failed: %s.\n', jobname, e);
      system(sprintf('echo ''%s'' >> stderr/%s', e, jobname));

    end
    cd(jobsdirpwd);    
  
  else
    fprintf('Job already started or submitting, ignoring...\n');    
  end      
  
end %end job loops
cd(savepwd);

function [str ] = readtext(filename)

fid = fopen(filename);
if fid == -1
  error('Unable to open file ''%s'' for reading.\n', filename);
end

str = textscan(fid, '%s', 'Delimiter', '\n', 'BufSize', 65536);
fclose(fid);
str = str{:};
      
str = strvcat(str{:});

function [cmd] = stripline(cmd, str)

line = strmatch(str, cmd);
cmd = cmd(exclude(line, rows(cmd)), :);
