function [] = oj_supervisor(jobsdir, varargin)

defaults.filter = '*';
args = propval(varargin, defaults);

jobsdir = oj_path(jobsdir);

savepwd = pwd;
cd(jobsdir);
  
jobs = dir(sprintf('%s.opusjob', args.filter));

fprintf('Found %d jobs.\n', numel(jobs));
for i = 1:numel(jobs)
  
  % read the job file
  
  cd(jobsdir);
  
  fprintf('Trying to start job ''%s''...', jobs(i).name);
  
  targetname = sprintf('%s.start', jobs(i).name);
  f = dir(targetname);
  
  if isempty(f) % nobody else has started this yet
    jobcmds = readtext(jobs(i).name);
  
    fprintf('Setting lock and starting...\n');
    system(sprintf('touch %s.start', jobs(i).name));
    bigcmd = strcat(jobcmds{1:(end-1)});
    fprintf('Prepared to evaluate: %s\n', bigcmd);

    try
      eval(bigcmd);
    catch
      e = lasterror;
      display(e.message)
      display(strvcat(e.stack.file));
      display(strvcat(e.stack.name));
      display([e.stack.line]);
    end    
    
    fprintf('Complete!\n');
  else
    fprintf('Somebody else got it first!\n');

  end
  
end

cd(savepwd);

function [str ] = readtext(filename)

      fid = fopen(filename);
      if fid == -1
        error('Cannot open file ''%s''', filename);
      else
        
      str = textscan(fid, '%s', 'Delimiter', '\n');                                
      fclose(fid);
      str = str{:};
      
      end


