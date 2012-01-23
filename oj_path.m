function [path] = oj_path(dirname)
% Determines the full path of a given directory.
%
% [PATH] = OJ_PATH(DIRNAME)

% This is kind of a hack, but I don't know how to do it
% otherwise. Without this, you run into all kinds of problems with
% relative paths, etc. etc.

savepwd = pwd;
cd(dirname);
path = pwd;
cd(savepwd);
