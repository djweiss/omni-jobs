function [log] = oj_overlord(jobsdirs, varargin)
% Watches over jobs, resubmitting any that fail.

defaults.clear_log = false;
defaults.check_interval = 2;
defaults.log_everything = true;
defaults.restart_errors = false;
defaults.max_checks = 1e9;

[args unused] = propval(varargin, defaults);

if isstr(jobsdirs)
  jobsdirs = {jobsdirs};
end

for i = 1:numel(jobsdirs)
  jobsdirs{i} = oj_path(jobsdirs{i});
  log{i} = {};
end

fprintf('****************************\n');
fprintf('Starting overlord process for:\n');
for i = 1:numel(jobsdirs)
  fprintf('%s\n', jobsdirs{i});
end
fprintf('****************************\n');
fprintf('Check interval: %g minutes.\n', args.check_interval)

fprintf('Beginning overlord loop...\n');
if args.restart_errors == true
  fprintf('Restart errors: TRUE\n');
else
  fprintf('Restart errors: FALSE\n');
end


hasduty = true;

checknum = 1;

starttime = clock;
while (hasduty == true) && (checknum < args.max_checks)
  
  elapsed = etime(clock, starttime);
  if (elapsed >= args.check_interval*60)
        
    starttime = clock;
    fprintf('%g seconds elapsed. Beginning check #%d...\n', elapsed, ...
            checknum);


    try
      
    for i = 1:numel(jobsdirs)


      % Get job statistics + show summary
      stats = oj_stats(jobsdirs{i});
      oj_report(stats);   
      
      % Resubmit if necessary
      oj_resubmit(stats, 'restart_crashed', args.restart_errors, ...
                  unused{:});
      
      
      % Either store everything, or don't
      if args.log_everything
        log{i}{checknum} = stats;
      else
        log{i} = stats;
      end      
        
    end
    
    finished = zeros(numel(log) ,1);
    
    % see if we are still on duty
    for i = 1:numel(log)
      
      if args.log_everything
        stats = log{i}{end};
      else
        stats = log{i};
      end
           
      numcomplete = sum([stats.completed]);
      numerror = sum([stats.crashed]);
      numjobs = numel(stats);
      
      if args.restart_errors
        
        if numcomplete == numjobs
          fprintf('All jobs for ''%s'' have completed.\n', ...
                  jobsdirs{i});
          finished(i) = 1;
        end        
      else        
        if (numcomplete + numerror) == numjobs
          fprintf('All jobs for ''%s'' have completed or crashed.\n', ...
                jobsdirs{i});
          finished(i) = 1;
        end        
      end

      if all(finished)
        hasduty = false;
      end      
      
    end
    
    catch    
            
      e = lasterror;
      fprintf('Check failed. Hopefully the next will succeed.\n');
      fprintf('Error: %s\n', e.message);
      for n = 1:numel(e.stack)
        fprintf('name ''%s'' line %d\n', ...
                e.stack(n).name, e.stack(n).line);
      end      
      
    end
    
    checknum = checknum + 1;
    % done checking
  end  

end

fprintf('All checks are complete! Retiring from active service.\n')
