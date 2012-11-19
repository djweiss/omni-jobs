function [ subj ] = oj_searchlight(subj, results, srccol, varargin)
% Computes a statmap from the searchlight results structarray.
% 
% map = rfrl_load_searchlight(subj, results, shifts, ...)
%
% Optional arguments:
%
% MASKNAME - The name of the mask to use as the basis for the map. 
%
% MISSINGVAL - Value to put in missing values.

defaults.patstem = srccol;
defaults.srcidx = [];
defaults.srcnames = {};
defaults.missingval = 0;
defaults.maskname = 'wholebrain';

args = propval(varargin, defaults);

% for each voxel, we can compute the following metrics:
nVox = get_objfield(subj, 'mask', args.maskname, 'nvox');

if numel(results) ~= nVox
  warning('Warning: %d/%d voxels found.', numel(results), nVox);
end

% Get the voxel indices
vidx = oj_get(results, 'vidx');

data = oj_get(results, srccol);

if isempty(args.srcidx)

  patname = args.patstem;  
  map = repmat(args.missingval, nVox, 1);    
  map(vidx) = data;

  subj = initset_object(subj, 'pattern', patname, map, ...
                        'masked_by', args.maskname);
    
else
  for i = 1:numel(args.srcidx)
    
    patname = sprintf('%s_%s', args.patstem, args.srcnames{i});
    map = repmat(args.missingval, nVox, 1);
    
    map(vidx) = data(:,args.srcidx(i));

    subj = initset_object(subj, 'pattern', patname, map, ...
                          'masked_by', args.maskname, ...
                          'group_name', args.patstem);
  end
end