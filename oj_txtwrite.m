function [] = oj_txtwrite(results, file, varargin)
% Write an opusjobs table to a .txt file.

defaults.fields = fieldnames(results)';
defaults.filemode = 'w+';
defaults.txt_title = sprintf('Exported from Matlab using %s(%s) - %s', ...
                             mfilename, inputname(1), datestr(now));

[args unused] = propval(varargin, defaults);
                               
fields = args.fields;

displaydat = oj_get(results, 'mixed', fields{:});
if numel(fields) == 0
  error('Programmer''s error. Should not be possible to specify no fields.');
end

for i = 1:numel(fields)
  minwidths(i) = numel(fields{i});
end

[str, colwidth] = cell2str(displaydat, unused{:});

title = ' ';
for i = 1:numel(fields)
  strf = sprintf('%%-%d.%ds ', colwidth(i), colwidth(i)); 
  title = [title sprintf(strf, fields{i})];
end
title = [title; repmat('-', 1, cols(title))];

f = fopen(file, args.filemode);

  % Print out a clear separator
  fprintf(f, '%s\n', repmat('=', 1, length(args.txt_title)+2));
  fprintf(f, '%s ||\n', args.txt_title);
  fprintf(f, '%s\n', repmat('=', 1, length(args.txt_title)+2));
  
  out = title;
  out = horzcat(out, repmat('\n', rows(out),1));
  
  fprintf(f,out');

  out = str;
  out = horzcat(out, repmat('\n', rows(out),1));
  fprintf(f,out');
  
fclose(f);

fprintf('Wrote %d lines of structarray to text file %s.\n', ...
        numel(results), file);
