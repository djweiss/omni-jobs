function [ln] = eta(cur,total,starttime,interval, fval)
% Display an estimate of time remaining in a calculation.
%
% function [timeleft] = eta(cur,total,starttime, interval)
%
% Usage:
%
% t0 = clock;
% eta(cur,total,t0,0.05);

% License:
%=====================================================================
%
% This is part of the Princeton MVPA toolbox, released under
% the GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.
% 
% The Princeton MVPA toolbox is available free and
% unsupported to those who might find it useful. We do not
% take any responsibility whatsoever for any problems that
% you have related to the use of the MVPA toolbox.
%
% ======================================================================

ln = -1;

if nargin<4
  interval=0.01;
end

if starttime == 0;
  starttime = clock;
end


if interval>0
  interval = ceil(total*interval);

%  dispf('cur: %g, total: %g, interval: %g, mod: %g', ...
%        cur, total, interval, mod(cur,interval));
  
  if cur == 1, fprintf(''); 
      
  elseif mod(cur,interval) == 0
    % Get the elapsed time
    elapsed = etime(clock, starttime);
    avgtime = elapsed./cur;

    timeleft = (total-cur)*avgtime;
    
    timesofarstr  = sec2timestr(elapsed);
    timeleftstr = sec2timestr(timeleft);
    
    if (avgtime < 1)
        rate_estimate = sprintf('%.2f iter/s', 1./avgtime);
    else
        rate_estimate = sprintf('%.2f s/iter',  avgtime);
    end

    
    status_string = sprintf('%03d/%03d - %03.1f%% - %s|%s - %s',cur,total,cur./total * 100, ...
        timesofarstr,timeleftstr, rate_estimate);

    if nargin==5
        status_string = [status_string ' f: ' num2str(fval)];
    end
    fprintf('\r\t%s', status_string);
    
    %%.f%% - %s remaining', (cur/total)*100, ...
    %        estimate(timeleft));
  
    ln = numel(status_string);
  end

  
end
if cur == total
  elapsed = etime(clock, starttime);
  fprintf(' ** Completed in %s.\n', estimate(elapsed));
end




