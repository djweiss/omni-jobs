function [] = oj_rtfwrite(results, file, varargin)
% Write an opusjobs table to a .rtf file.

defaults.init = true;
defaults.close = true;
defaults.newpage = false;
defaults.fields = fieldnames(results)';
defaults.txt_title = sprintf('Exported from Matlab using %s(%s) - %s', ...
                             mfilename, inputname(1), datestr(now));

[args unused] = propval(varargin, defaults);

fields = args.fields;

displaydat = oj_get(results, 'mixed', fields{:});
if numel(fields) == 0
  error('Programmer''s error. Should not be possible to specify no fields.');
end

% Get the string versions of the data
[str, colwidth] = oj_cell2str(displaydat, unused{:});

% Generate the RTF title
title = ' ';
for i = 1:numel(fields)
  strf = sprintf('%%-%d.%ds ', colwidth(i), colwidth(i)); 
  title = [title sprintf(strf, fields{i})];
end


if args.init
  oj_initrtf(file);
end

f = fopen(file, 'a+');

  if args.newpage
    fprintf(f, '{\\pard \\pagebb\n');
    fprintf(f,'{\\pard \\brdrb \\brdrs \\brdrw10 \\brsp10 \\par}{\\pard\\par}\n');
    fprintf(f, '\\par}\n');
  end

  fprintf(f, '{\\pard\n');

  % Print out a clear separator
  fprintf(f, '{\\f1\\b\\fs24\n');
  fprintf(f, '%s}\\line\n', args.txt_title);

  % Write out the title
  out = title; 
  fprintf(f,out');
  fprintf(f,'{\\pard \\brdrb \\brdrs \\brdrw10 \\brsp10 \\par}{\\pard\\par}\n');

  % Write out the data
  out = str;
  out = horzcat(out, repmat('\\line\n', rows(out),1));
  fprintf(f,out');

fprintf(f, '\\par}\n');

fclose(f);

if args.close
  oj_closertf(file);
end


fprintf('Wrote %d lines of structarray to text file %s.\n', ...
        numel(results), file);
