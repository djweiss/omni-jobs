function [row] = oj_metabatch_slave(batchname, job_nos)
%%
for i =1:numel(job_nos)
    jobname = [batchname sprintf('%04d', job_nos(i))];

    files{i} = fullfile(pwd, batchname, 'jobs', jobname);
    if ~exist(files{i}, 'file')
        error('file ''%s'' does not exist', files{i});
    end
    cmds{i} = oj_readtext(files{i});
end
batchdir = fullfile(pwd, batchname);

% Mark jobs as submitted
cd(batchdir);
for i = 1:numel(files)
    jobname = [batchname sprintf('%04d', job_nos(i))];
    system(sprintf('touch submitted/%s', jobname));
end

% Start the jobs
for j = 1:numel(cmds)
    cd(batchdir);
    clear cmdi cmd
    cmd = cmds{j};
    for i = 1:(rows(cmd)-1)
        cmdi{i} = [strtrim(cmd(i,:)) ' '];
    end
    
    jobname = [batchname sprintf('%04d', job_nos(j))];
    
    % Set up a dummy ''started'' file
    system(sprintf('echo -1 >> started/%s', jobname));
    system(sprintf('echo `hostname` >> started/%s', jobname));
    system(sprintf('echo `date` >> started/%s', jobname));    
    
    cmd = [cmdi{:}];
    dispf('running job %d: ''%s''\n', job_nos(j), cmd);
    
    eval(cmd);
end


    