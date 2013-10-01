function gitdiff(jobsdir, funccheck)

config = oj.config(jobsdir);

if ~isequal(config.hook_config, @oj.hook_gitcommit)
    error('%s does not have git hooks', jobsdir);
end

wd = cd(config.hook_config_args{1});


if nargin<2
    file_only = true;
    filename = eval('which(config.myfunc)');
else
    file_only = ~isempty(funccheck);
    if file_only
        filename = which(func2str(funccheck));
    end        
end

tempfile = tempname;
if file_only
    unixf('git diff %s -- %s > %s', config.git_myfunc_hash, filename, tempfile);
else
    unixf('git diff --stat %s -- > %s', config.git_hash, tempfile);
end
[s,r] = unixf('cat %s', tempfile);
disp(r);
delete(tempfile);

cd(wd);
    

