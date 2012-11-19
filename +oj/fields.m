function [fields] = oj_fields(r)

fields = fieldnames(r);
for i = 1:numel(fields)
    fields{i} = oj_decode(fields{i});
end
