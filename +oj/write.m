function [] = write(jobsdir, myfunc, varargin)
% Writes out the auxiliary files for a single job.
% 
% Usage:
%
%   oj.write(jobsdir, myfunc, 'myfunc_args', args, ...) 
%
% Creates the necessary files in the omnijob directory JOBSDIR to run
% a single instance of the command MYFUNC. The arguments to MYFUNC are
% given by the option 'myfunc_args'. Note that you should not be
% calling this directly; typically, you should use OJ.QUICKBATCH to
% create batch jobs.
%
% MYFUNC needs to return only a single output, which is a struct or
% column array of structs.
% 
% Options:
%
%   - 'myfunc_args' - A cell array of arguments to the passed function
%   MYFUNC. If MYFUNC_ARGS is not set, then unused propvals passed to
%   OJ.WRITE will be passed to MYFUNC. In this case, MYFUNC would need
%   to use PROPVAL to parse its arguments.
%
%   - 'jobname' : Specifies the name that will identify the job to
%   OMNIJOBS. If unspecified, an error will occur.
%
%   - 'scriptdir' : The location that the script should start
%   in. (Default: current directory)
%
% SEE ALSO
%   oj.quickbatch, oj.submit

defaults.scriptdir = pwd;
defaults.myfunc_args = {};
defaults.jobname = [];
defaults.maxlen = 30;

% Retrieve the function handle
if isstr(myfunc)
    myfunc = str2func(myfunc);
end

[args unused] = propval(varargin, defaults);
args = validate(args, unused, myfunc, jobsdir);

jobsdir = oj.path(jobsdir);

% Check for anonymous functions (not supported)
funcinfo = functions(myfunc);
if strcmp(funcinfo.type, 'anonymous')
  error(['Sorry; anonymous functions are not supported by ' ...
         'omnijobs.']);
end

% Write out the file:
argsfile = sprintf('%s/args/%s.mat',jobsdir, args.jobname);
jobsfile = sprintf('%s/jobs/%s', jobsdir, args.jobname);
savefile = sprintf('%s/save/%s.mat', jobsdir, args.jobname);

fid = fopen(jobsfile, 'w'); % open file for writing
if (fid == -1)
  error('Unable to open oj file ''%s'' for writing.', jobsfile);
end

try
  % cd to script working directory
  fprintf(fid, 'cd(''%s'');\n', args.scriptdir);

  fprintf(fid, 'dbstop if error;\n');
  fprintf(fid, 'warning off all;\n');
  fprintf(fid, 'try\n');
  
  fprintf(fid, '\tload(''%s'');\n', argsfile);
  
  % run the user specified function
  cmdstr = ['\trow = ', func2str(myfunc), '(passed_args{:});\n'];
  
  % pass in either the my_func args cell or unused (only one is allowed)
  passed_args = {args.myfunc_args{:} unused{:}};
  save(argsfile, 'passed_args');
  
%   for i = 1:numel(passed_args)

%     % build up each argument (either string or numeric)
%     if isstr(passed_args{i})
%       passed_args{i} = ['''', passed_args{i}, ''''];
%     elseif isnumeric(passed_args{i})
%       passed_args{i} = mat2str(passed_args{i});
%     else
%       error('Cannot pass argument %d of type ''%s''', i, ...
%             class(passed_args{i}));
%     end
    
%     cmdstr = [cmdstr, passed_args{i}, ','];
%   end
  
%   % chop off the last comma and put closing parenthesis
%   cmdstr = [cmdstr(1:(end-1)) ');\n'];
  
  fprintf(fid, cmdstr);

  % finally save output 
  fprintf(fid, '\tsave(''%s'', ''row'');\n', savefile);
  fprintf(fid, '\tsystem(''touch %s/completed/%s'');\n', jobsdir,args.jobname);

  % Return to the script working directory
  fprintf(fid, '\tcd(''%s'');\n', args.scriptdir);
  % if args.monitor_peers
  %   fprintf(fid, ['\toj.resubmit(oj.report(''%s''), ' ...
  %                 '''kill_time'', %g, ''hang_time'', %g, ' ...
  %                 '''callback'', ''%s'', ''restart_crashed'', %g, ' ...
  %                 '''restart_mia'', %g);\n'], ...
  %           jobsdir, args.kill_time, args.hang_time, args.callback, ...
  %           args.restart_crashed, args.restart_mia);    
  % end  

  fprintf(fid, 'catch\n');
  fprintf(fid, '\trethrow(lasterror);\n');
  fprintf(fid, 'end;\n');
  fprintf(fid, 'dbstack;\n');


  fprintf(fid, 'exit;\n', savefile);
  
  % close up the file
  fclose(fid);
  
catch
  
  fclose('all'); % make sure all files are closed
  rethrow(lasterror);
end

% give user output
fprintf('Successfully wrote job ''%s''.\n', jobsfile);

% ------------------------------------------------------------------------
% validate
% ------------------------------------------------------------------------
function [args] = validate(args, unused, myfunc, jobsdir)

% cannot pass in unused and myfunc_args
if ~isempty(unused) & ~isempty(args.myfunc_args)
  error(['Cannot pass extra propvals and a ''myfunc_args'' cell array ' ...
         'at the same time']);
end

if ~iscell(args.myfunc_args)
  error('''myfunc_args'' must be a cell array.');
end

args.savedir = [ jobsdir '/save' ];

% build the default jobname if none specified
if isempty(args.jobname)

  args.jobname = func2str(myfunc);
  
  jobname_args = {args.myfunc_args{:} unused{:}};
  
  for i = 1:numel(jobname_args)
    
    val = jobname_args{i};
  
    % stick on any numeric or string arguments that were passed
    if isnumeric(val) && numel(val) == 1
      args.jobname = [args.jobname, '_' num2str(jobname_args{i})];
    elseif isstr(val)
      val = escapestr(val);
      args.jobname = [args.jobname, '_' val(1:min([args.maxlen,numel(val)]))];
    else 
        LetterStore = char(97:122); % string containing all allowable letters (in this case lower case only)
        Idx = randperm(length(LetterStore));
        String = LetterStore(Idx(1:5));
        
        args.jobname = [args.jobname, '_' String];
    end
    
  end
  
  args.jobname = [args.jobname '_' date];
end

% create directories if they don't exist

safemkdir([jobsdir '/save']);
safemkdir([jobsdir '/shell']);
safemkdir([jobsdir '/stderr']);
safemkdir([jobsdir '/stdout']);
safemkdir([jobsdir '/jobs']);
safemkdir([jobsdir '/args']);
safemkdir([jobsdir '/started']);
safemkdir([jobsdir '/completed']);
safemkdir([jobsdir '/submitted']);

if ~exist(jobsdir)
  if ~mkdir(jobsdir)
    error('Unable to create directory ''%s''.', jobsdir);
  end
end

if ~exist(args.savedir)
  if ~mkdir(args.savedir)
    error('Unable to create directory ''%s''.', args.savedir);
  end
end

% get full pathnames
args.scriptdir = oj.path(args.scriptdir);
jobsdir = oj.path(jobsdir);
args.savedir = oj.path(args.savedir);

% ------------------------------------------------------------------------
% safemkdir
% ------------------------------------------------------------------------
function safemkdir(dirname)

if ~exist(dirname, 'dir')
  mkdir(dirname)
end

% ------------------------------------------------------------------------
% escapestr
% ------------------------------------------------------------------------
function [str] =  escapestr(str)

str = strrep(str, '*', 's');
str = strrep(str, ' ', '_');

