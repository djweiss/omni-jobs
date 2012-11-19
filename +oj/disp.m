function [] = disp(results, varargin)
% Nicely display a structarray as a data table.
%
% Usage:
%
%   oj.disp(results, ...)
% 
% Options: See oj.cell2str for description of options.
% 
% SEE ALSO
%   oj.load, oj.cell2str

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

 
% check fields for special properties
[maxwidth varargin] = getpropval(varargin, 'maxwidth', 20);
[precision varargin] = getpropval(varargin, 'precision', '%-7.5g');

% first row: header row
if isempty(varargin)
  fields = fieldnames(results)'; % Decode field names
  for j = 1:numel(fields)
      if ~isfield(results, fields{j})
          fields{j} = oj.encode(fields{j});
      else
          fields{j} = oj.decode(fields{j});
      end
  end
else
  fields = varargin;
end

displaydat = oj.get(results, 'mixed', fields{:});
if numel(fields) == 0
  error('Programmer''s error. Should not be possible to specify no fields.');
end

displaydat = horzcat(cell(rows(displaydat),1), displaydat);
for j = 1:rows(displaydat)
    displaydat{j,1} = j;
end
fields = horzcat({'#'},fields);

for i = 1:numel(fields)
  minwidths(i) = numel(fields{i});
end

[str, colwidth] = oj.cell2str(displaydat, 'minwidth', minwidths, ...
                           'maxwidth', maxwidth, 'precision', precision);

title = ' ';
for i = 1:numel(fields)
  strf = sprintf('%%-%d.%ds ', colwidth(i), colwidth(i)); 
  title = [title sprintf(strf, fields{i})];
end
title = [title; repmat('-', 1, cols(title))];

disp(title);
disp(str);

