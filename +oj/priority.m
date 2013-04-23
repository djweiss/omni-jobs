function priority(s, p)

for i = 1:numel(s)
    if s(i).jobid > 0
        unixf('qalter -p %d %d', p, s(i).jobid);
    end
end