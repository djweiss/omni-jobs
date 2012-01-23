function remaining = timeleft(total, interval)
% Display an estimate of time remaining in a calculation.
%
% Usage:
%
%     for j = 1:numCalcs
%           timeleft(numCalcs, ...)
%     end 
%     timeleft; <-- clears manually (optional, useful for debugging)
%
%
% Extra parameters:
%
%    interval - update interval

persistent startTime done charsToDelete;

remaining = -1;

% manual termination
if nargin==0
    if ~isempty(startTime)
        fprintf('\n'); %cleared: %s \n', timesofarstr);
    end
    clear startTime done charsToDelete;
    return
end

% first invokation
if isempty(startTime);
  startTime = clock;
  done = 1;
else
  done = done + 1;
end

% default update interval: every iteration
if nargin < 2
    interval = 1;
end

% non-integral interval is pct: convert to integral
if interval < 0
    interval = ceil(total*interval);
end

if done == 1 || mod(done,interval)==0 || done == total
    
    % compute statistics
    elapsed = etime(clock, startTime);
    avgtime = elapsed./done;
    remaining = (total-done)*avgtime;

    if avgtime < 1
        ratestr = sprintf('- %.2f iter/s', 1./avgtime);
    else
        ratestr = sprintf('- %.2f s/iter', avgtime);
    end

    if done == 1
        remaining = -1;
        ratestr = [];
    end
    
    timesofarstr  = sec2timestr(elapsed);
    timeleftstr = sec2timestr(remaining);
    
    status_string = sprintf('%03d/%03d - %03d%%%% - %s|%s %s',done,total,...
        floor(done/total*100),timesofarstr,timeleftstr, ratestr);

    delstr = [];
    if ~isempty(charsToDelete)
        delstr = repmat('\b',1,charsToDelete-1);
    end
    
    if nargout == 0
        fprintf([delstr status_string]);
    end
    charsToDelete = numel(status_string);
end

if done == total 
    clear startTime done charsToDelete;
    if nargout == 0
        fprintf('\n');
    end
end



