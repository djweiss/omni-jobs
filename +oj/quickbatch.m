function [] = quickbatch(funcname, varargin)
% Quickly makes a batch of jobs with unique parameters.
%
% Usage:
%
%    oj.quickbatch(funcname, arg1vals, arg2vals, ...)
%
% The most important function in the toolbox, OJ.QUICKBATCH will
% easily write out a batch job to cover all combinations of a given
% set of arguments. See the demo for examples on how to use this
% function.
%
% Options:
%
%   - 'batchname': The name of the directory the batch will be
%   stored in. Default: [funcname '_batch']. 
% 
%   - 'overwrite': Automatically overwrite an existing batch with
%   the same directory name. Default: false
%
%   - 'append': Add more jobs to an existing directory rather than
%   starting from scratch. Default: false
%    
% SEE ALSO
%   oj.write, oj.submit
    
[exhaustive varargin] = getpropval(varargin, 'exhaustive', true);
[autosubmit varargin] = getpropval(varargin, 'autosubmit', false);
[write_args varargin] = getpropval(varargin, 'write_args', {});
[submit_args varargin] = getpropval(varargin, 'submit_args', {});
[batchname varargin] = getpropval(varargin, 'batchname', [funcname '_batch']);
[overwrite varargin] = getpropval(varargin, 'overwrite', false);
[append varargin] = getpropval(varargin, 'append', false);
[fixed_args varargin] = getpropval(varargin, 'fixed_args', {});
jobnum = 1;

if exist(batchname, 'dir')    
    if overwrite
        dispf('Batch ''%s'' already exists. Removing and overwriting...', batchname);
        unixf('rm -rf %s', batchname);
    elseif append
        jobfiles = dir(fullfile(batchname, 'jobs', [batchname '*']));
        njobs = numel(jobfiles);
        jobnum = jobnum + njobs;
        dispf('Appending to existing batch ''%s'' with %d jobs...', batchname, njobs);
    else
        reply = input(sprintf('Batch ''%s'' already exists. Overwrite? (y/n)', batchname), 's');
        if strcmp(reply, 'y')
            overwrite = true;
            unixf('rm -rf %s', batchname);
        else
            dispf('Aborting...');
            return;
        end
    end
end

if exhaustive
  recursive_write(funcname, batchname, {}, varargin{1}, varargin{2:end});  
else
  error('Not implemented yet.');
end

if autosubmit
  oj.submit(batchname, submit_args{:});
end

%%%%%%%%%%%%%%%%%%%%%
function [] = recursive_write(funcname, batchname, argStack, varRange, varargin)

  n = numel(argStack);
    
  if isstr(varRange)
    argStack{end+1} = varRange;
    
    if numel(varargin)==0
      oj.write( batchname, funcname, 'myfunc_args', {argStack{:} fixed_args{:}}, ...
                write_args{:}, 'jobname', sprintf('%s%.4d', batchname, jobnum));
      jobnum = jobnum+1;
    else        
      recursive_write(funcname, batchname, argStack, varargin{1}, varargin{2:end});
    end
  
  else      
  
    for i = 1:numel(varRange)

      if iscell(varRange)
        v = varRange{i};
      else
        v = varRange(i);
      end
      argStack{n+1} = v;
      
      if numel(varargin)==0
          %        oj.write( batchname, funcname, 'myfunc_args', ...
          %        argStack, write_args{:});
      
        oj.write( batchname, funcname, 'myfunc_args', {argStack{:} fixed_args{:}}, ...
                  write_args{:}, 'jobname', sprintf('%s%.4d', batchname, jobnum));
        jobnum = jobnum+1;

      else        
        recursive_write(funcname, batchname, argStack, varargin{1}, varargin{2:end});
      end
      
    end
  end

end  
end  
    



