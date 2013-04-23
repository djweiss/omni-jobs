function [results] = load(jobsdir, varargin)
% Loads the results of a batch job.
%
% Usage:
%  
%   results = oj.load(jobsdir, ...)
%
% For a given batch job directory, loads all results files from any
% completed jobs. Each result file will contain a struct or array of
% structs (which we call 'rows'). OJ.LOAD loads the input and output
% of all jobs and returns a structarray RESULTS.
%
% Options:
%
%   - 'filter' : Only load filenames that match the
%   filter. Default: '*.mat'
%
%   - 'loadargs': Whether or not to load input arguments as well as
%   the output. Default: true
%
%   - 'rmfields': A list of fields to remove from the output.
%
%   - 'proc': An optional post-processing function handle.
%
% SEE ALSO
%   oj.write, oj.quickbatch

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


defaults.format = 'structarray';
defaults.loadargs = true;
defaults.filter = '*.mat';
defaults.idxrange = [];
defaults.rmfields = '';
defaults.proc = '';

args = propval(varargin, defaults);
args = validate(args);

% save the current working directory
savepwd = pwd;

[~,jobsdirname] = fileparts(jobsdir);

% check whether or not there is a 'save' subdirectory, or the user
% has specified the save directory itself
if exist(sprintf('%s/save', jobsdir))
  jobsdir = sprintf('%s/save', jobsdir);
end


try 
  cd(jobsdir);
  results = [];

  count = 0;

  files = dir(args.filter);
  if ~isempty(args.idxrange)
      files = files(args.idxrange);
  end
    
  count = numel(files);
  rows = cell(numel(files),1);
  
  fprintf('[%s] Loading and concatenating %d rows: ', jobsdirname, count);
  % now count up the number of rows we actually need, and
  % concatenate
  t0 = CTimeleft(numel(rows));  
  n = 0;
  failed = 0;
  
  for i = 1:numel(rows);
    t0.timeleft();

    try
        tmp = load(files(i).name, 'row');    
        row.result = tmp.row;
        
        if ~isempty(args.proc)
            row.result = args.proc(row.result);
        end 
        if args.loadargs
            [path, jobname, ext] = fileparts(files(i).name);
            load(fullfile('..','args',[jobname '.mat']));
            for j = 1:numel(passed_args)
                row.(sprintf('arg%.2d',j)) = passed_args{j};
            end
        end

    catch
      e = lasterror;
      warning(['[%s] ERROR: Unable to load results from file ''%s''.\n\tMessage: ' ...
               '%s.'], jobsdirname, files(i).name, e.message);
      failed = failed + 1;
    end
    
      
    % Clear unwanted fields
    if ~isempty(args.rmfields)
      row.result = oj.rm(row.result, args.rmfields);
    end
    
    if ~isempty(row)
      % allocate enough space for 'results' in one fell swoop
      if isempty(results)
        results = row(1);
        results = repmat(results, count, 1);
      end
    
      results((n+1):(n+numel(row))) = row;
      n = n + numel(row);    
    else
      fprintf('Skipping empty row file ''%s''\n', files(i).name);
    end
    
  end  

    % convert structarray into a struct
  if strcmp(args.format, 'struct') || strcmp(args.format, 'dataset')
    results = structarray2struct(results);    
    if strcmp(args.format, 'dataset')
      results = struct2dataset(results);
    end    
  end
  
  if failed > 0, fprintf('[%s] %d rows successfully loaded.\n', jobsdirname, size(results,1)); end
  if failed > 0, dispf('[%s] %d files failed to load.', jobsdirname, failed); end
  
catch
  cd(savepwd); % make sure you end up in the same directory
  rethrow(lasterror);
end

cd(savepwd);

function [results] = structarray2struct(s)

results = [];

fields = fieldnames(s);
for i = 1:numel(fields)
    
  val = s(1).(fields{i});
    
  if isnumeric(val) || isstruct(val)
    
    if size(val,1) > 1 && size(val,2) == 1
      results.(fields{i}) = horzcat(s.(fields{i}));
    elseif size(val,1) == 1 && size(val,2) >= 1
      results.(fields{i}) = vertcat(s.(fields{i}));
    else
      results.(fields{i}) = {s.(fields{i})};
    end
  else
    results.(fields{i}) = {s.(fields{i})};
  end 
  
end

function [d] = struct2matrix(s)

% extract only single valued numeric data
d = [];
fields = fieldnames(s);
for i = 1:numel(fields)
  
  val = s.(fields{i});
  
  if (isnumeric(val)) && (numel(val) == 1)
    d(end+1)= val;
  end
 
end

function [d] = struct2dataset(s)

d = dataset();
% the only thing I know of is to wrap strings in cell arrays
fields = fieldnames(s);
for i = 1:numel(fields)
  d.(fields{i}) = s.(fields{i});
end

%%%%%%%%%%% validate input arguments
function [args] = validate(args) 

if (~strcmp(args.format, 'dataset')) && ...
      (~strcmp(args.format, 'structarray')) && ...
      (~strcmp(args.format, 'struct'))
  %        (~strcmp(args.format, 'matrix'))
    error('Format ''%s'' is not a format specifier.', args.format);
end

% check to make sure that there is a .mat extension in filter
i = strfind(args.filter, '.mat');
if (i ~= numel(args.filter)-3)
  warning(['Filter does not end in ''.mat''. Improper files may be ' ...
           'loaded.']);
end

  
