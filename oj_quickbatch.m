function [] = oj_quickbatch(funcname, varargin)
% Easily makes a batch of jobs with unique parameters.

[exhaustive varargin] = getpropval(varargin, 'exhaustive', true);
[autosubmit varargin] = getpropval(varargin, 'autosubmit', false);
[write_args varargin] = getpropval(varargin, 'write_args', {});
[submit_args varargin] = getpropval(varargin, 'submit_args', {});
[batchname varargin] = getpropval(varargin, 'batchname', [funcname '_batch']);
[overwrite varargin] = getpropval(varargin, 'overwrite', true);
[fixed_args varargin] = getpropval(varargin, 'fixed_args', {});
jobnum = 1;

if exist(batchname, 'dir')    
    if overwrite
        dispf('Batch ''%s'' already exists. Removing and overwriting...', batchname);
        unixf('rm -rf %s', batchname);
    else
        dispf('Batch ''%s'' already exists. Incrementing jobnum...', ...
              batchname);
        jobnum = numel(dir(fullfile(batchname,'jobs'))) - 1;
        dispf('Starting at job %d.', jobnum);
    end
end

if exhaustive
  recursive_write(funcname, batchname, {}, varargin{1}, varargin{2:end});  
else
  error('Not implemented yet.');
end

if autosubmit
  oj_submit(batchname, submit_args{:});
end

%%%%%%%%%%%%%%%%%%%%%
function [] = recursive_write(funcname, batchname, argStack, varRange, varargin)

  n = numel(argStack);
    
  if isstr(varRange)
    argStack{end+1} = varRange;
    
    if numel(varargin)==0
      oj_write( batchname, funcname, 'myfunc_args', {argStack{:} fixed_args{:}}, ...
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
          %        oj_write( batchname, funcname, 'myfunc_args', ...
          %        argStack, write_args{:});
      
        oj_write( batchname, funcname, 'myfunc_args', {argStack{:} fixed_args{:}}, ...
                  write_args{:}, 'jobname', sprintf('%s%.4d', batchname, jobnum));
        jobnum = jobnum+1;

      else        
        recursive_write(funcname, batchname, argStack, varargin{1}, varargin{2:end});
      end
      
    end
  end

end  
end  
    



