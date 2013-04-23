function [str] = readtext(filename, varargin)
% Grab the contents of a text file.

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


[convert varargin] = getpropval(varargin, 'convert', false);

fid = fopen(filename);
if fid == -1
  error('Unable to open file ''%s'' for reading.\n', filename);
end

str = [];
try  
  str = textscan(fid, '%s', 'Delimiter', '\n');
catch      
  fclose(fid);
  error('Unknown error occured:', rethrow(lasterr));
end
     
     
fclose(fid);
str = str{:};
str = strvcat(str{:});


if (convert)
    x = {};
    full = str;
    for j = 1:rows(full)
        
        c = 1;
        [tok, str] = strtok(full(j,:),',');
        while ~isempty(tok)
            if ~isempty(str2num(tok))
                x{j,c} = str2num(tok);
            else
                x{j,c} = strtrim(tok);
            end
            c = c + 1;
            [tok, str] = strtok(str,',');
        end
    end
    str = x;    
end

