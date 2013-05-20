function [stats] = report(stats, varargin)
% Print a status report on a batch job directory.
%
% Usage:
%  
%   stats = oj_report(jobsdir, ...)
%   oj_report(stats, ...)
%
% Given the name of a directory, calls OJ.STATS to compute
% statistics of running jobs and displays the output in an
% easy-to-parse format. 
%
% ** IMPORTANT ** This function is pretty old and out-of-date. It
% tends to think jobs have crashed even when they are still running
% if anything is output to stderr. 
%
% Options: See options of OJ.STATS.
%
% SEE ALSO
%   oj.stats, oj.quickbatch

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


defaults.usetotal = false;
defaults.detailed = false;
defaults.onlyerror = false;
defaults.onlyrunning = false;
defaults.showresubmit = false;

[args unused] = propval(varargin, defaults);



if ~isstruct(stats)    
  if isstr(stats)
      [~,jobsdirname] = fileparts(stats);
      fprintf('[%s] ', jobsdirname);
      stats = oj.stats(stats, unused{:});
  else
      error(['Input must be a string (JOBSDIR) or a structarray ' ...
          '(STATS).']);
  end    
end

[~,jobsdirname] = fileparts(stats(1).jobsdir);
if any([stats.mia])
    statusline = ':-\';
elseif any([stats.crashed])
    statusline = ':-(';
else
    statusline = ':-)';
end

if sum([stats.running]) > 0
    statusline = [statusline ' Running'];
elseif all([stats.completed])
    statusline = [statusline ' Finished'];
elseif ~all([stats.submitted])
    statusline = [statusline ' Not Submitted'];
else
    statusline = [statusline ' Incomplete'];
end

fprintf('[%s] %s: %d/%d/%d/%d/%d/%d submitted/started/completed/missing/crashed/running\n', ...
       jobsdirname, statusline, sum([stats.submitted]), sum([stats.started]), sum([stats.completed]), ...
    sum([stats.mia]), sum([stats.crashed]), sum([stats.running]));

if args.usetotal
  fprintf('There are %d jobs total.\n', numel(stats));
end

% Output estimated time to completion:

start_time = datenum(clock);
for i = 1:numel(stats)
    if stats(i).started, start_time = min(start_time, datenum(stats(i).start_time)); end
end
finish_time = start_time; 
for i = 1:numel(stats)
    if stats(i).started & ~isequal(stats(i).last_modified,'n/a'), finish_time = max(finish_time, datenum(stats(i).last_modified)); end
end
wall_time = etime(datevec(finish_time), datevec(start_time));

if all([stats.completed]) 
    fprintf('[%s] Started: %s, Completed: %s, Elapsed: %s', jobsdirname, datestr(start_time), datestr(finish_time), sec2timestr(wall_time));
else
    fprintf('[%s] Started: %s, Last updated: %s, Elapsed: %s',jobsdirname, datestr(start_time), datestr(finish_time), sec2timestr(wall_time));
end

if (count([stats.completed]) > 0)
    
    % number of jobs remaining
    if args.usetotal
        totaljobs = numel(stats);
    else
        totaljobs = count([stats.submitted]);
    end
    
    % average running time of completed jobs:
    idx = find([stats.completed]);
    avgtime = mean([stats(idx).run_time]);
    
    inqueue = totaljobs-sum([stats.crashed])-sum([stats.completed])-sum([stats.running]);
    nslots = sum([stats.running]);
    
    itersleft = ceil(inqueue/nslots);
    
    iterstimeleft = avgtime*itersleft;
    runningtimeleft = (avgtime*sum([stats.running]) - sum([stats([stats.running]).run_time]))./sum([stats.running]);
    
    if sum([stats.running])>0
        fprintf('\n[%s] ETA in approximately %s (%s avg time x %d batch starts = %s + %s batch remaining)\n', ...
            jobsdirname, sec2timestr(iterstimeleft+runningtimeleft), sec2timestr(avgtime), itersleft, ...
            sec2timestr(iterstimeleft), sec2timestr(runningtimeleft));
    else
        fprintf(', Avg time: %s\n', sec2timestr(avgtime));
    end
    
else
    fprintf('\n');
end


% % compute estimated time remaining:
% totaltime = avgtime * remainingjobs;
%
% % adjust for current runtime
% idx = find([stats.running]);
% totaltime = totaltime - sum([stats(idx).run_time]);
% 
% if totaltime > 0
%     
%     fprintf('\nApproximately %s computation time remaining.\n', ...
%         sec2timestr(totaltime));
%     
%     fprintf('(%d jobs remaining x %s time/job = %s total.)\n', ...
%         remainingjobs, sec2timestr(avgtime), sec2timestr(remainingjobs*avgtime));
%     
%     fprintf('(%d running jobs accumulated %s so far.)\n', ...
%         count(idx), sec2timestr(sum([stats(idx).run_time])));
%     
%     eta = sec2timestr(totaltime./count(idx));
%     %   eta = totaltime/count(idx)/3600;
%     %   if (eta < 1)
%     %     eta = sprintf('%g minutes', eta*60);
%     %   else
%     %     eta = sprintf('%g hours', eta);
%     %  end
%     
%     fprintf('ETA: %s. (Assuming %d batch nodes available.)\n', ...
%         eta, count(idx));
%     
% elseif count([stats.running]) == 0
%     
%     fprintf('\nAll jobs in queue processed. (Avg runtime: %g minutes.)\n', ...
%         avgtime/60);
%     
% elseif totaltime < 0
%     
%     fprintf('\nQueue completion is %g minutes overdue.\n', ...
%         -totaltime/60);
%     fprintf('(Average runtime: %g minutes.)\n', avgtime/60);
%     
% else
%     fprintf('\nAvg runtime: %g minutes.\n', avgtime/60);
% end

%end

function printjob( stats )

if stats.complete == 1
  status = 'COMPLETE';
elseif stats.error == 1
  status = 'ERROR';
elseif stats.started == 1

  if stats.hangtime > 15/60 
    status = 'RUNNING - MAYBE HANGING';
  elseif stats.hangtime > 1
    status = 'HANGING';
  else
    status = 'RUNNING';
  end
  
else
  status = 'WAITING';
end 

fprintf('Job name:%s\n', stats.jobname);
fprintf('Job status: %s\n', status);

if stats.submitted == 1  
  fprintf('Submitted:\tYes');
  
  if stats.started == 0
    fprintf('\n');
    fprintf('Started:\tNo\n');
  else
    fprintf('\tStart Time:\t%s\tElapsed:\t%g hours\n', stats.starttime, ...
          stats.elapsed);
    fprintf('Started:\tYes\tLast Modified:\t%s\tHangtime:\t%g hours\n', ...
            stats.lastmodified, stats.hangtime);
    
    if stats.error == 1
      fprintf('Error State:\tYes\tError Message:\n\n');
      display(stats.errormsg);
      fprintf('\n');
      
    else
      fprintf('Error State:\tNo\n');
    end    
    
    if stats.complete == 1
      fprintf('Completed:\tYes\tFinished:\t%s\tRuntime:\t%g hours\n', ...
              stats.finished, stats.runtime);
    else
      fprintf('Completed:\tNo\n');
    end
  end
  
else 
  fprintf('Submitted:\tNo\n');
end

fprintf('\n');
  
  
    
  








