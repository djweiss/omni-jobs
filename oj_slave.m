function [log] = oj_slave(jobsdir, varargin)

defaults.filter = '*';
defaults.logout = false;
defaults.force = false;
defaults.stopat = Inf;
args = propval(varargin, defaults);

jobsdir = oj_path(jobsdir);

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
      
      % Remove the 'oj_resubmit' command from the job
      jobcmd = oj_readtext(sprintf('jobs/%s', jobname));
      
      jobcmd = stripline(jobcmd, 'oj_resubmit');
      jobcmd = stripline(jobcmd, 'exit');
      jobcmd = stripline(jobcmd, 'dbstack');
     
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


function [cmd] = stripline(cmd, str)

line = strmatch(str, cmd);
cmd = cmd(exclude(line, rows(cmd)), :);
