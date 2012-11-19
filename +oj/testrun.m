function [log] = oj_testrun(jobsdir, varargin)

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

    %system(sprintf('echo node-1.cluster.private >> started/%s', jobname));

    jobsdirpwd = pwd;
      
    % Remove the 'oj_resubmit' command from the job
    jobcmd = oj_readtext(sprintf('jobs/%s', jobname));
    
    jobcmd = stripline(jobcmd, 'oj_resubmit');
    jobcmd = stripline(jobcmd, 'exit');
    jobcmd = stripline(jobcmd, 'dbstack');
    
    cmdstr = [];
    for i = 1:rows(jobcmd)
        cmdstr = strcat(cmdstr, jobcmd(i,:), ';');
    end
    
    argsfile = sprintf('%s/args/%s.mat',jobsdir, jobname);
    load(argsfile, 'passed_args');
    
    dispf('running command: ''%s''', cmdstr);

    eval(cmdstr);

    runjobs = runjobs + 1;

    cd(jobsdirpwd);
  
  else
      fprintf('Job already started or submitting, ignoring...\n');
  end

end %end job loops
cd(savepwd);


function [cmd] = stripline(cmd, str)

line = strmatch(str, cmd);
cmd = cmd(exclude(line, rows(cmd)), :);
