function [config] = hook_gitcommit(config, srcdir, varargin)

prevdir = cd(srcdir);
for i = 1:numel(varargin)
    unix(sprintf('git add %s', varargin{i}));
end

[config.git_commit config.git_commit_log] = ...
    unixf('git commit -a -m ''commit by oj.hook_gitcommit for batch ''%s''''', config.jobsdir);
config.git_hash = githash('.');
config.git_myfunc_hash = githash(which(config.myfunc));

cd(prevdir);
