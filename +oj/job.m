function job(jobsdir, jobname)

currdir = pwd;

argsfile = sprintf('%s/args/%s.mat', jobsdir, jobname);
savefile = sprintf('%s/save/%s.mat', jobsdir, jobname);

passed_args = loadvar(argsfile);

config = oj.config(jobsdir);

if ~isempty(config.hook_pre)
    config.hook_pre(config, config.hook_pre_args{:});
end

myfunc = str2func(config.myfunc);
row = myfunc(passed_args{:});

if ~isempty(config.hook_post)
    row = config.hook_post(config, row, config.hook_post_args{:});
end

cd(currdir);
savemkdir(savefile, row);
system(sprintf('touch %s/completed/%s', jobsdir,jobname));

