function [sumdata] = csvwrite(results, file, varargin)
% Write a structarray to a CSV file.
%
% Usage:
%
%    oj.csvwrite(results, filename, ...)
%
% Options:
%   
%    - 'f_precision': Floating point precision. Default: '%.8g'
%
%    - 's_precision': String precision. Default: '%s'
%
%    - 'delimiter'  : Delimiter. Default: ','
% 
% SEE ALSO
%   oj.csvread

% check fields for special properties
[f_precision varargin] = getpropval(varargin, 'f_precision', '%.8g');
[s_precision varargin] = getpropval(varargin, 's_precision', '%s');
[delimiter varargin] = getpropval(varargin, 'delimiter', ',');

% If no fields specified, use all of them.
if isempty(varargin)
  fields = fieldnames(results)';
else
  fields = varargin;
end

% Get the actual data for writing
data = oj_get(results, 'mixed', fields{:});

sumdata = {};

% Split any data into a full cell array
for i = 1:numel(fields)
  
  % Determine number of columns
  ncol = []; writedata = [];  
  if isnumeric(data{1,i}) || islogical(data{1,i})    % Numeric: use num2cell to get cell array
      ncol = cols(data{1,i});
      writedata = num2cell(vertcat(data{:,i}));
  elseif ischar(data{1,i})    % String: get cell array
    ncol = 1;
    writedata = data(:,i);
  else
    error('Cannot write non-char or non-numeric data to xls file.');
  end

  % Get the titles
  titles = fields(i);
  if ncol > 1
    for j = 1:ncol
      titles{j} = sprintf('%s_%d', fields{i}, j);
    end
  end
  
  sumdata = horzcat(sumdata, vertcat(titles, writedata)); 
end


f = fopen(file, 'w+');
% write out the cell array
for i = 1:rows(sumdata)
  for j = 1:cols(sumdata)
    
    if isempty(sumdata{i,j})
      % Don't print anything
    elseif isnumeric(sumdata{i,j}) || islogical(sumdata{i,j})
      fprintf(f, f_precision, sumdata{i,j});
    else
      fprintf(f, s_precision, sumdata{i,j});
    end
    fprintf(f, delimiter);
    
  end
  fprintf(f, '\n');
  progress(i, rows(sumdata));
end
fclose(f);

fprintf('Wrote %d x %d structarray to CSV file %s.\n', rows(sumdata)-2, ...
        cols(sumdata), file);