function [ results ] = oj_set(results, fieldname, data, varargin)
% Add a new column to an OPUSJOBS results set.

[rep varargin] = getpropval(varargin, 'rep', false);

fieldname = oj_encode(fieldname);

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


  
  
  
