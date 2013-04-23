function errs(s)

for i = 1:numel(s)
    if s(i).crashed
        fprintf('*** %s ***:\n', s(i).jobname);
        unixf('cat %s/stderr/%s', s(i).jobsdir, s(i).jobname);
    end
end