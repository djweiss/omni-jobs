function grep(s, pattern, n)

if nargin<3
    n = 1;
end
if nargin<2
    pattern = 'iter';
end

for i = 1:numel(s)
    if ~s(i).started
        continue;
    end
    fprintf('[%s] ', s(i).jobname);
    [~,m] = unixf('grep %s %s/stdout/%s | tail -n %d', pattern, s(i).jobsdir, s(i).jobname, n);
    fprintf('%s', m);
    if isempty(m)
        fprintf('\n');
    end
    %disp(s(i).output(end-n:end,1:72));
end