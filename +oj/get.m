function [ data ] = oj_get(results, varargin)
% Returns a matrix or cell array built from fields of a structarray.
%
% [DATA] = OJ_GET(RESULTS, FIELD1, FIELD2, ...)
% 
% For a given structarray RESULTS (either loaded using OJ_LOAD or from
% another source), OJ_GET will concatenate fields of the RESULTS data
% table and return them; the format of DATA depends on the datatype
% of FIELD1. 
%
% If FIELD1 is numeric, the DATA will be a matrix and OJ_GET will
% halt if any other fields are not numeric. Similarly, if FIELD1 is
% a structure, all other fields must be structures as well; if
% FIELD1 is a string or a cell array, then the data will be
% returned as a cell array and mixed data types are fine.
% 
% Alternatively, mixed data types can always be specified by adding
% the keyword 'mixed' instead of the first field name:
%
% [DATA] = OJ_GET(RESULTS, 'mixed', FIELD1, FIELD2, ...)
%
% NOTE: OJ_GET tries to be smart about preserving "rows" of the
% structarray. If each "row" contains a row vector, these will be
% concatenated vertically; if each "row" contains a column
% vector, these will be concated horizontally and then transposed to
% form rows.
%
% Although it is convenient to think of fields as "columns" of a
% data table, the output of OJ_GET will contain as many columns as
% each field contains collectively.

datatype = [];
data = [];

% Check for mixed datatypes
mixed = false;
if strcmp(varargin{1}, 'mixed')
  mixed = true;
  varargin = varargin(2:end);
end

for i = 1:numel(varargin)

  field = varargin{i};
  if ~isstr(field)
    error('Field specifier %d is not a string, so cannot parse.', i);
  end

  if ~isfield(results(1), field)
      field = oj_encode(field);
  end
  
  val = results(1).(field);

  if isempty(datatype)
    if mixed == true datatype = 'cell';
    elseif isnumeric(val) && (all(size(val)>1)) datatype = 'cell';
    elseif isnumeric(val) || islogical(val) datatype = 'numeric'; 
    elseif isstruct(val) datatype = 'struct';
    else datatype = 'cell';       
    end
  end

  % check for unintentionally mixed datatypes
  checkdatatype(val, datatype, field, mixed);

  if strcmp(datatype, 'numeric')
          
    if size(val,1) > 1 && size(val,2) == 1
      % transpose so that rows still preserve rows
      col = horzcat(results.(field))';      
    elseif size(val,1) == 1 && size(val,2) >= 1
      col = vertcat(results.(field));
    else
      error('Cannot concatenate square matrices.');
    end
  elseif strcmp(datatype, 'struct')
    col = vertcat(results.(field));
  else    
    col = {results.(field)}';
  end 

  % horizontally concatenate this column into table
  if isnumeric(val) || isstruct(val)
    data = [data col];
  else
    if isempty(data)
      data = col;
    else      
      data = horzcat(data, col);
    end    
  end
  
end

if numel(data) == 1 && iscell(data)
    data = data{1};
end

function checkdatatype(val, datatype, field, mixed)

if ~mixed
  
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
  
  
end


  
  
  
