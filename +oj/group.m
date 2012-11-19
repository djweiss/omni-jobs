function [grpidx, groups, groupnames] = group(sa, varargin)
% Groups a structarray according to unique combinations of values.
%
% Usage:
% 

groups = [];
stringcols = [];
strings = {}; % stores string values for unique string columns

% note: varargin must be valid fieldnames
pmat = oj_get(sa, 'mixed', varargin{:});

if iscell(pmat)
  
  numpmat = zeros(size(pmat));
  
  % take unique of each column individually
  for i = 1:cols(pmat)
    col = pmat(:,i);
    
    numcol = nan(numel(col), 1);
    if isstr(col{1})      

      stringcols(end+1) = i;
      [ustr, ~, numcol] = unique(col);
      
%       col = strvcat(col);
%       for j = 1:numel(ustr)
%         idx = strmatch(ustr{j}, strvcat(col));          
%         numcol(idx) = j;
%       end
      
      strings{i} = {ustr};
      
    elseif isnumeric(col{1}) || islogical(col{1})
      numcol = cell2mat(col);
    else
      error('Cannot handle grouping by structure.');
    end
    
    numpmat(:,i) = numcol;    
  end    
  
elseif isnumeric(pmat)
  numpmat = pmat;  
else
  error('Cannot handle grouping by structure.');
end

% find unique parameters now

groups = unique(numpmat, 'rows');
grpidx = nan(numel(sa), 1);
for i = 1:rows(groups)
  
    idx = find(all(bsxfun(@eq, groups(i,:), numpmat), 2));

    groupsize(i)=  numel(idx);
  %grpmat = repmat(groups(i,:), rows(numpmat), 1);
  %idx = find(all(grpmat == numpmat, 2));

  grpidx(idx) = i;  
end

if (numel(grpidx) > numel(sa));
  error('something bad happened!');
end

groupsa = struct();

% TODO: this should return structarray!!
for j = 1:rows(groups)
  groupsa(j).grp = j;
  groupsa(j).n = groupsize(j);
  for i = 1:cols(groups)
    if any(i==stringcols) % is a string
      s = strings{i}{1};
      groupsa(j).(oj_encode(varargin{i})) = s{groups(j,i)};
    else
      groupsa(j).(oj_encode(varargin{i})) = groups(j,i);
    end  
  end

end

% now, convert back to cell if necessary
if iscell(pmat)
  groups = num2cell(groups);
  
  for i = stringcols    
    for j = 1:rows(groups)
      s = strings{i}{1};            
      groups{j,i} = s{groups{j,i}};
      
    end        
  end
end

% write group names
for i = 1:rows(groups)

  groupnames{i} = '';
  for j = 1:numel(varargin)    
    
    if isnumeric(varargin{j})
      varargin{j} = num2str(varargin{j})
    end
    if isnumeric(groups)
      groupnames{i} = sprintf('%s, %s: %g', groupnames{i}, varargin{j}, ...
                            groups(i,j));
    else
      if isnumeric(groups{i,j})
        val = num2str(groups{i,j});
      else
        val = num2str(groups{i,j});
      end      
      
      groupnames{i} = sprintf('%s, %s: %s', groupnames{i}, varargin{j}, ...
                              val);      
      
    end
    
  end
  
  groupnames{i} = strclean(groupnames{i}(2:end));
  
end

groups = groupsa;