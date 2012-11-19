function oj_metabatch(batchname, no_blocks)

s = oj_stats(batchname);

todo_idx = find(~[s.submitted] & ~[s.started] & ~[s.completed]);

n = numel(todo_idx);
block_size = floor(n/no_blocks);
dispf('found %d jobs to complete. dividing into %d blocks of size %d...', ...
    n, no_blocks, block_size);

start = 1;
stop = 1+block_size-1;
for i = 1:no_blocks
    idx{i} = start:stop;
    start = stop+1;
    if i == (no_blocks-1)
        stop = n;
    else
        stop = start+block_size-1;
    end
end

oj_quickbatch('oj_metabatch_slave', 'batchname', [batchname '_meta'],  ...
    'autosubmit', false, batchname, idx);
%%

