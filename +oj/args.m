function r = args(s)

for i = 1:numel(s)
    r(i) = load(sprintf('%s/args/%s.mat', s(i).jobsdir,s(i).jobname));
end