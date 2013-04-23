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

% ======================================================================
% Copyright (c) 2012 David Weiss
% 
% Permission is hereby granted, free of charge, to any person obtaining
% a copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to
% permit persons to whom the Software is furnished to do so, subject to
% the following conditions:
% 
% The above copyright notice and this permission notice shall be
% included in all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
% EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
% NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
% LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
% OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
% WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
% ======================================================================

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


sortingdata = oj.get(sa, fields{:});

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
  


