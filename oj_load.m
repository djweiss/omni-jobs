function [results] = oj_load(jobsdir, varargin)
% Loads the results of an OPUSJOB batch.
%
% [RESULTS] = OJ_LOAD(JOBSDIR, ...)
%
% For a given OPUSJOBS directory, loads all results files from any
% completed jobs. Each result file will contain a struct or array
% of struct (which we call 'rows'). OJ_LOAD will concatenate each
% of these in a relatively efficient way, and then optionally convert
% the result into different formats.
%
% By default, the format of RESULTS is a structarray, so that the
% other OPUSJOBS commands (e.g., OJ_GET, OJ_SORT, etc.) will
% function properly. Alternatively, if Matlab version is >= 7.4,
% you can return a 'dataset' object, or you can return a single
% struct with matrices/vectors as fields ('struct').
%
% OPTIONAL ARGUMENTS:
%
% FORMAT - A string, either 'dataset', 'structarray', or 'struct',
%   to specify the format of the data that is returned.
%   (Default: 'structarray')
%
% FILTER - A shell format specifier string that will filter the mat
%   files loaded. Note: you must include the filename extension in
%   the filter. (Default: '*.mat')
% 
% See also OJ_WRITE, OJ_SUBMIT, OJ_QUICKBATCH.

defaults.format = 'structarray';
defaults.loadargs = true;
defaults.subfield = true;
defaults.filter = '*.mat';
defaults.rmfields = '';
defaults.proc = '';
defaults.singular = true;

args = propval(varargin, defaults);
args = validate(args);

% save the current working directory
savepwd = pwd;

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

  if ~args.singular
    fprintf('Inspecting results .mat files... (%d found)\n', ...
            numel(files));
    
    rows = cell(numel(files), 1);
    for i = 1:numel(files)
      
      % load the "row" from the saved file, which may be one or more rows
      vars = whos('-file', files(i).name);
      
      rowidx = strmatch('row', {vars.name});
      
      count = count + vars(rowidx).size(2)*vars(rowidx).size(1);          
      progress(i, numel(files));
    end
  
  else
    count = numel(files);
    rows = cell(numel(files),1);
  end
    
  fprintf('Loading and concatenating %d rows...\n', count);
  % now count up the number of rows we actually need, and
  % concatenate
  t0 = clock;  
  n = 0;
  failed = 0;
  timeleft
  for i = 1:numel(rows);
    timeleft(numel(files));

    try
        if args.singular
            tmp = load(files(i).name, 'row');    
            row.result = tmp.row;
        else
            load(files(i).name, 'row');    
        end
        
        if ~isempty(args.proc)
            row = args.proc(row);
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
      warning(['Unable to load results from file ''%s''.\n\tMessage: ' ...
               '%s.'], files(i).name, e.message);
      failed = failed + 1;
    end
    
      
    % Clear unwanted fields
    if ~isempty(args.rmfields)
      row = oj_rm(row, args.rmfields);
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
  
  fprintf('\n%d rows successfully loaded.\n', size(results,1));
  if failed > 0, dispf('%d files failed to load.', failed); end
  
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

  
