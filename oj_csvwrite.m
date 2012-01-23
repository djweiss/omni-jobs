function [sumdata] = oj_csvwrite(results, file, varargin)
% Writes a structarray to a CSV file.

% check fields for special properties
[f_precision varargin] = getpropval(varargin, 'fprecision', '%.8g');
[s_precision varargin] = getpropval(varargin, 's_precision', '%s');
[delimiter varargin] = getpropval(varargin, 'delimiter', ',');
[csv_title varargin] = getpropval(varargin, 'csv_title', ...
                                   sprintf('Exported from Matlab using %s(%s) - %s', ...
                                           mfilename, inputname(1), datestr(now)));

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

if ~isempty(csv_title)
  toptitle = cell(1, cols(sumdata));
  toptitle{1} = csv_title;  
  sumdata = vertcat(toptitle, sumdata);
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