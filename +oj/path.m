function [path] = path(dirname)
% Determines the full path of a given directory.
%
% Usage:
%
%   path = oj.path(dir)

% Note: This is kind of a hack, but I don't know how to do it
% otherwise. Without this, you run into all kinds of problems with
% relative paths, etc. etc.

savepwd = pwd;
cd(dirname);
path = pwd;
cd(savepwd);
