function [ r ] = oj_csvread(file, varargin)

[delimiter varargin] = getpropval(varargin, 'delimiter', ',');
[zero_blanks varargin] = getpropval(varargin, 'zero_blanks', true);
[src varargin] = getpropval(varargin, 'src', true);

fid = fopen(file, 'r');
if fid < 0
    error('Unable to open file: %s', file);
end

% Get field names from header of file
    fields = {};
    headtxt = fgetl(fid);
    
    [token, rem] = strtok(headtxt, delimiter);
    
    while ~isempty(token)
        fields{end+1} = oj_encode(strtrim(strclean(token)));
        
        [token, rem] = strtok(rem, delimiter);
    end


nfields = numel(fields);

% Load the data from the file
count = 1;
dataline = fgetl(fid);
while ischar(dataline)

    skip = false;
    for j = 1:nfields
        [token, dataline] = strtok(dataline, delimiter);

        token = strtrim(strclean(token));
        if isempty(token) && zero_blanks
            r(count).(fields{j}) = 0;
        elseif isempty(token)
            skip = true;
        elseif isnan(str2double(token))
            r(count).(fields{j}) = token;
        else
            r(count).(fields{j}) = str2double(token);
        end
    end
    
    if src
        r(count).src = file;
    end

    dataline = fgetl(fid);
    if (~skip)       
        count = count + 1;
    else
        skip = false;
        r(count) = [];
    end
end

fclose(fid);
