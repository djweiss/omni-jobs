function [ best_results ] = oj_best_params(results, sortcolumn, sortmode, varargin)
% Grab the best parameters for each subject.

% results - a "structarray" formatted result from opusjobs
% sortcolumn - the name of the column to sort by 
% sortmode - either 'ascend' or 'descend'

if nargin == 3
  error('No fields provided to group by.');
end

% sort by the field we want to sort by 
results = oj_sort(results, sortcolumn, sortmode);
% note: oj_sort can take multiple columns w/ different modes

% group by subject # and preprocessing
[grpidx, grpnames] = oj_group(results, varargin{:});

% grpnames is a cell array of names for each parameter group, i.e.
% something like 'subjnum: 302, pre: dssm4'

for i = 1:numel(grpnames)

  % grab the i'th group's data
  grpdata = results(grpidx==i);
  
  % take only the "best", according to our sort
  best_results(i) = grpdata(1);
  
end

%best_results = oj_sort(best_results, sortcolumn, sortmode);
