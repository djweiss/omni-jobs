function [success s] = waitfor(jobsdir, delay)

if nargin<2
    delay = 60;
end

while true
    s = oj.report(jobsdir);
    if all([s.completed])
        success = true;
        return;
    end
    if any([s.crashed])
        success = false;
        return;
    end
    pause(delay);
end
        