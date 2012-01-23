function [str, colwidth] = cell2str(x, varargin)
% Converts a cell array table to a string.

defaults.precision = '%-7.4g';
defaults.maxwidth = 20;
defaults.minwidth = repmat(5, 1, numel(x)); 
args = propval(varargin, defaults);

n = rows(x);
m = cols(x);

% Build up the output columnwise, assuming all elements in a column
% are the same

str = [];

for i = 1:m
  
  if isstr(x{1,i})
    col = strvcat(x{:,i});
  elseif isstruct(x{1,i})
    col = repmat('[struct]', n, 1);
  elseif isnumeric(x{1,i})
    col = num2str(vertcat(x{:,i}), args.precision);
  elseif islogical(x{1,i})
    col = num2str(vertcat(x{:,i}), '%d ');
  end

  if rows(col) ~= n
    error('Cannot convert empty values.');
  end
  
  colwidth(i) = cols(col);
  if colwidth(i) > args.maxwidth
    col = col(:,1:args.maxwidth);
    col(:, end-2:end) = '.';    
    colwidth(i) = args.maxwidth;
  elseif colwidth(i) < args.minwidth(i)
    padding = repmat(' ', n, args.minwidth(i) - colwidth(i));
    col = [col padding];
    colwidth(i) = args.minwidth(i);
  end    
  
  str = [str repmat(' ', n, 1) col];

end

