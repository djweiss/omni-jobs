function [ sa, idx ] = sort(sa, varargin)
% Sort a structarray by arbitrary fieldnames.
%
% Usage:
% 
%   [results idx] = oj.sort(results, field1, field2, ...)
%   [results idx] = oj.sort(results, field1, 'ascend', ...)
% 
% Allows sorting by mixed data types. After each field, optionally
% specify sort direction.
%
% SEE ALSO
%   oj.group, oj.disp

% parse field names
if nargin==1
  error('You must supply at least one field to sort by!');
end

fields = {};
sortmodes = {};

for i = 1:numel(varargin)
  
  val = varargin{i};
  
  if strcmp(val, 'ascend') || strcmp(val, 'descend')
    sortmodes{end+1} = val;
  else
    fields{end+1} = val;
  end  

end

if numel(sortmodes) == 0
  sortmodes = {'ascend'};
end

if numel(sortmodes) == 1
  sortmodes = repmat(sortmodes, numel(fields), 1);
end

if numel(sortmodes) ~= numel(fields)
  error(['Must have either 1 or matching number of sort mode ' ...
         'specifiers.']);
end


sortingdata = oj_get(sa, fields{:});

sortingcol = [];

for i = 1:size(sortingdata, 2)
  if strcmp(sortmodes{i}, 'ascend')
    sortingcol(i) = i;
  else
    sortingcol(i) = -i;
  end  
end

% get sorting indexes
[sortingdata idx] = sortrows(sortingdata, sortingcol);

% sort the data!
sa = sa(idx);
  


