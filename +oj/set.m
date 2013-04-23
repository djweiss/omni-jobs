function [ results ] = set(results, fieldname, data, varargin)
% Add a new column to a struct array.
%
% Usage:
%
%   results = oj.set(results, fieldname, data, ...)
%
% Options:
%
% SEE ALSO
%   oj.get, oj.disp

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

[rep varargin] = getpropval(varargin, 'rep', false);

fieldname = oj.encode(fieldname);

if rep
    for i = 1:numel(results)   
        results(i).(fieldname) = data;
    end
elseif numel(data) == numel(results)
  
  if iscell(data)
    for i = 1:numel(results)   
      results(i).(fieldname) = data{i};
    end
    
  else
    for i = 1:numel(results)   
      results(i).(fieldname) = data(i);
    end    
  end
  
elseif rows(data) == numel(results)
    for i = 1:rows(data)
        results(i).(fieldname) = data(i,:);
    end
    
elseif cols(data) == numel(results)
    
    for i = 1:rows(data)
        results(i).(fieldname) = data(:,i);
    end
    
  
elseif ndims(data) > 2
  error('Can only handle 1 and 2 dimensional data types.')

  if iscell(data)
    for i = 1:numel(results)   
      results(i).(fieldname) = data{i, :};
    end
    
  else
    for i = 1:numel(results)   
      results(i).(fieldname) = data(i, :);
    end    
  end
  
elseif numel(data) == 1
    for i = 1:numel(results)
        results(i).(fieldname) = data;
    end
else
    error('undefined case');
end
  
  

function [mixed] = checkdatatype(val, datatype, field)

if strcmp(datatype, 'numeric') && ~isnumeric(val) 
  error(['field ''%s'' is not numeric, but the previous fields ' ...
           'are.'], field);
elseif strcmp(datatype, 'struct') && ~isstruct(val) 
  error(['field ''%s'' is not a struct, but the previous fields ' ...
           'are.'], field);
elseif strcmp(datatype, 'cell')
  
  if (isnumeric(val) || isstruct(val))
    warning(['First field requires datatype ''cell'', so type of field' ...
             ' ''%s'' is being ignored.'], field);
  end
  
end


  
  
  
