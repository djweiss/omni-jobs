function [] = disp(results, varargin)
% Nicely display a structarray as a data table.
%
% Usage:
%
%   oj.disp(results, ...)
% 
% Options: See OJ.CELL2STR for description of options.
% 
% SEE ALSO
%   OJ.LOAD, OJ.CELL2STR
 
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

