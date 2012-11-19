function [str] = readtext(filename, varargin)
% Grab the contents of a text file.

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

