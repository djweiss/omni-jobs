function [ data ] = clean(jobsdir, varargin)
% Cleans the recordkeeping files of a previous submission.
%
% SEE ALSO
%   OJ.RESET, OJ.REPORT, OJ.STATS

system(sprintf('rm -rf %s/submitted/*', jobsdir));
system(sprintf('rm -rf %s/completed/*', jobsdir));
system(sprintf('rm -rf %s/shell/*', jobsdir));
system(sprintf('rm -rf %s/started/*', jobsdir));
system(sprintf('rm -rf %s/stdout/*', jobsdir));
system(sprintf('rm -rf %s/stderr/*', jobsdir));
system(sprintf('rm -rf %s/lock', jobsdir));
system(sprintf('rm -rf %s/restartlog.mat', jobsdir));
system(sprintf('rm -rf %s/avoidlog', jobsdir));
