function [data_chunks] = par_chunk_data(data, N)

chunks = oj.par_chunk(numel(data), N);
sz = cellfun(@numel, chunks);
offset = 1;
for i = 1:numel(chunks)
    data_chunks{i} = data(offset:offset+sz(i)-1);
    offset = offset + sz(i);
end
