function [] = oj_resubmit(jobs, varargin)
% Resubmits crashed or failed jobs from an OPUSJOBS batch.
%
% OJ_RESUBMIT(STATS, ...)
%
% OJ_RESUBMIT will use the reporting information in a given OPUSJOBS
% STATS structure (see OJ_REPORT, OJ_STATS) to determine which jobs
% have crashed, hung, froze, or simply disappeared, and restart
% those jobs in the batch queue. 
%
% Because OJ_RESUBMIT depends on the STATS structure being up to
% date, you should only run this right after checking on the status
% of a given batch with OJ_REPORT, like so:
%
%  >> stats = oj_report('mybatchdir');
%  >> oj_resubmit(stats);
% 
% And then, you will only want to use OJ_RESUBMIT if any of the jobs have
% run into problems and MONITOR_PEERS was set to false when you
% originally wrote the jobs to file.
%
% NOTE: OJ_RESUBMIT tries to be smart about preventing duplicate
% submission of jobs; whenever OJ_RESUBMIT is examining a STATS
% file, it locks the corresponding OPUSJOBS directory and refuses
% to allow any simultaneous OJ_RESUBMIT processes to proceed. This
% prevents each script from resubmiting its peers if multiple jobs
% finish at the same time.
%
% OPTIONAL ARGUMENTS:
%
% KILL_TIME - The maximum time (in hours) any job is allowed to run
%   before it is forcibly killed. (Default: 10 hours)
%
% HANG_TIME - The maximum time (in minutes) that any job is allowed to
%   run without producing any output to stdout indicating that it is
%   still alive before it is restarted automatically. (Default: 15
%   minutes)
%
% RESTART_CRASHED - Whether or not jobs that are marked as
%   'crashed' (i.e., they have produced output to stderr) are
%   restarted automatically. (Default: false)
% 
% RESTART_MIA - Whether or not jobs that have disappeared from
%   qstat but haven't yet completed ('Missing In Action') should be
%   restarted automatically. (Default: true)

defaults.kill_time = 10;
defaults.hang_time = 15; 
defaults.restart_crashed = true;
defaults.restart_mia = true;

defaults.callback = '';

args = propval(varargin, defaults);

jobsdir = jobs(1).jobsdir;

% Check for the existence of <jobsdir>/lock (lock if not exist, halt if exist)
if exist([jobsdir '/lock'], 'file')
  fprintf('Someone else has locked directory. Aborting...\n');
else  
  % lock this for our use
  system(['touch ' jobsdir '/lock']);

  % Check whether or not everything has already completed.
  if sum([jobs.completed]) == numel(jobs) && ... 
        sum([jobs.running]) == 0
    
    fprintf(['All jobs have been completed. Checking for ' ...
             'callback...\n']);

    % Start a finishing command if desired
    if ~isempty(args.callback)
      fprintf('Starting command ''%s''...\n', args.callback);
      try
        eval(args.callback)    
      catch
        fprintf('Error caught.\n');
      end      
    else
      fprintf('No callback found. Exiting...\n');
    end

    % Free the lock
    system(['rm ' jobsdir '/lock']);

    return;
  end

  badjobs = [];
  
  % Restart MIA jobs 
  if args.restart_mia
    idx = find([jobs.mia]);
    fprintf('Found %d MIA jobs. Restarting...\n', numel(idx));
    restart(jobs(idx), 'mia');
    
    badjobs = [badjobs idx]; 
    % Don't consider these jobs any more
    jobs = jobs(exclude(idx, numel(jobs)));
  end

  % Obviously, only resubmit jobs that have already been started
jobs = jobs(find([jobs.started]));

% Look for hanging jobs
idx = find([jobs.running] & ([jobs.hang_time]/60 > args.hang_time));
fprintf('Found %d hung jobs. Resubmitting...\n', numel(idx));
restart(jobs(idx), 'hung');

% Don't consider these jobs any more
jobs = jobs(exclude(idx, numel(jobs)));
badjobs = [badjobs idx];

% Look for jobs that need to be killed, who are out of control
idx = find([jobs.running] & [jobs.run_time]/3600 > args.kill_time);
fprintf('Found %d jobs running too long. Killing...\n', numel(idx));
kill(jobs(idx));

badjobs = [badjobs idx];
% Don't consider these jobs any more
jobs = jobs(exclude(idx, numel(jobs)));


% Restart crashed jobs
if args.restart_crashed
  idx = find([jobs.crashed] & ~[jobs.completed]);
  fprintf('Found %d crashed jobs. Restarting...\n', numel(idx));
  restart(jobs(idx), 'err');
  badjobs = [badjobs idx];

  % Don't consider these jobs any more
  jobs = jobs(exclude(idx, numel(jobs)));
end

fprintf('Resubmitted, killed, or restarted %d jobs.\n', numel(badjobs));

% Free the lock
system(['rm ' jobsdir '/lock']);

end

%%%%%%%%%%%%%%%%%%%%%%%%% Kill bad jobs
function kill(jobs)

for i = 1:numel(jobs)

  cmd = sprintf(['echo "Killed at" `date` "by oj_resubmit." >> ' ...
                 '%s/stderr/%s'], jobs(i).jobsdir, jobs(i).jobname);
  system(cmd);
  system(sprintf('qdel %d', jobs(i).jobid));
    
  writelog(jobs(i), 'kill');
end

%%%%%%%%%%%%%%%%%%%%%%%%% Restart corrupted jobs
function restart(jobs, reason)

for i = 1:numel(jobs)

  if jobs(i).jobid > 0
    % Delete a running copy
    system(sprintf('qdel %d', jobs(i).jobid));
  end
    
  % Clear everything related to a job but the shell script wrapper
  system(sprintf('rm -f %s/started/%s', jobs(i).jobsdir, jobs(i).jobname));
  system(sprintf('rm -f %s/completed/%s', jobs(i).jobsdir, jobs(i).jobname));
  system(sprintf('rm -f %s/stderr/%s', jobs(i).jobsdir, jobs(i).jobname));
  system(sprintf('rm -f %s/stdout/%s', jobs(i).jobsdir, jobs(i).jobname));

  errfile = [jobs(i).jobsdir '/stderr/' jobs(i).jobname];
  outfile = [jobs(i).jobsdir '/stdout/' jobs(i).jobname];

  filename = [jobs(i).jobsdir '/shell/' jobs(i).jobname];

  qargs = sprintf('-V -e %s -o %s', errfile, outfile);
  cmdstr = sprintf('qsub %s %s', qargs, filename);
  system(cmdstr);

  writelog(jobs(i), reason);
end


%%%%%%%%%%%%%%%%%%%%%%%%% Log restart to file
function writelog(job, reason)
  
logfile = sprintf('%s/restartlog.mat', job.jobsdir);
if exist(logfile, 'file') 
  load(logfile, 'restartlog');
else
  restartlog = [];
end

restartlog(end+1).job = job;
restartlog(end).reason = reason;
restartlog(end).name = job.jobname;
restartlog(end).node = job.node;
restartlog(end).time = datestr(clock);

save(logfile, 'restartlog');
