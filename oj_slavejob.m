function [row] = oj_slavejob(jobsdir, n, varargin)

dispf('**STARTING SLAVE %d**', n);
log = oj_slave(jobsdir, varargin{:});

row.success = true;