function [str, colwidth] = cell2str(x, varargin)
% Convert a cell array table to a big string for display.
%
% Usage: 
%
%   [str, colwidth] = oj.cell2str(X, ...)
%
%  The input X should be a 2-D cell array; the elements can be
%  arbitrary. The primary output STR is a string which, when
%  printed, displays all the elements X in a nicely formatted
%  table. The secondary output COLWIDTH is the width of each column
%  in the string table.
%
% Options:
%
%   - 'precision' : fprintf format string to use for numerical
%   outputs, Default: '%-7.5g' (can be cell, one for each column)
%
%   - 'maxwidth'  : maximum width in characters of any column.
%
%   - 'minwidth'  : cell array, minimum width for every field in x.
%
%   - 'highlightf': a postprocessing function handle for output, will
%   "highlight" fields in column i if hightlightf{i} returns true for
%   that input.
%
% SEE ALSO
%   oj.disp
 
n = rows(x);
m = cols(x);

defaults.highlightf = []; % highlighting function
defaults.precision = repmat({'%-7.5g'}, m, 1);
defaults.maxwidth = 20;
defaults.minwidth = repmat(5, 1, numel(x)); 
args = propval(varargin, defaults);

if ~iscell(args.precision)
  args.precision = repmat({args.precision}, m, 1);
end

% Build up the output columnwise, assuming all elements in a column
% are the same

str = [];

for i = 1:m
  
  if isstr(x{1,i})
    col = strvcat(x{:,i});
  elseif isstruct(x{1,i})
    col = repmat('[struct]', n, 1);
  elseif isnumeric(x{1,i})
    
      if (rows(x{1,i}) > 1)
          col = repmat('[#r/m]', n, 1);
      else
          subcols = cols(x{1,i});
          strf = repmat([args.precision{i} ' '], 1, subcols);
          col = num2str(vertcat(x{:,i}), strf);
      end      
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

  % Check for highlighting values in this column
  if iscell(args.highlightf)
    if ~isempty(args.highlightf{i})
      f = arg2funct(args.highlightf{i});
      h = f(vertcat(x{:,i}));
      
      oldcol = cols(col)-1;
      col = horzcat(col, repmat(' ', rows(col), 13));

      for j = 1:rows(col)
        repstr = sprintf('*%s*', h(j), col(j,1:oldcol));
        col(j,:) = repstr(1:cols(col));
      end      
    end    
  end

  str = [str repmat(' ', n, 1) col];

end

