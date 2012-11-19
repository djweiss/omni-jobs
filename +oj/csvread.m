function [ r ] = csvread(file, varargin)
% Read structarray from a comma-separated value file.
%
% Usage:
%
%    r = csvread(file, ...)
%
% Options:
%
%   - 'delimiter'  : Default: ','
%
%   - 'zero_blanks': How to interpret blank values; if true, puts
%   zeros instead of empty. Default: true
%
%   - 'src'        : Append the filename as an extra field to the
%   loaded data. Default: true
% 
% SEE ALSO
%   oj.csvwrite

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
    fields{end+1} = oj.encode(strtrim(strclean(token)));
    
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
