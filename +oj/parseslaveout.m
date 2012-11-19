function [str] = oj_parseslaveout(stats, varargin)

defaults.killandreset = false;
defaults.killfilter = '';

args = propval(varargin, defaults);

% figure out which job the slave is running

for i = 1:numel(stats)
  
  slavejob = stats(i);
  [status, str] = unixf('egrep "Job ''" %s/stdout/%s', ...
                        slavejob.jobsdir, slavejob.jobname);

  [tmp str] = strtok(str, '''');
  [jobname] = strtok(str, '''');
  
  jobsdir = strtok(slavejob.jobname(13:end), '_');
  
  dispf('slave job %d is running job: %s (%s)', slavejob.jobid, jobname, ...
        estimate(slavejob.run_time));

  if regexp(jobname, args.killfilter)
    dispf('\t--> matches filter ''%s''', args.killfilter);
    
    job = oj_stats(jobsdir, 'filter', jobname, 'progress', false);
    if args.killandreset 

      dispf('\tKilling slave ''%s''...', slavejob.jobname);
      % kill the current job
      kill(slavejob);

      dispf('\tResetting target...');
      % reset its target job
      oj_reset(job);      
    end    
    
  end  
end

%%%%%%%%%%%%%%%%%%%%%%%%% Kill bad jobs
function kill(jobs)

for i = 1:numel(jobs)

  cmd = sprintf(['echo "Killed at" `date` "by oj_parseslaveout." >> ' ...
                 '%s/stderr/%s'], jobs(i).jobsdir, jobs(i).jobname);
  system(cmd);
  system(sprintf('qdel %d', jobs(i).jobid));
  
end