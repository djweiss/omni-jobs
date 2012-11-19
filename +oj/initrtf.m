function [] = oj_initrtf(file)

try
  f = fopen(file, 'w+');

  fprintf(f, '{\\rtf1\\ansi\\deff0\n');
  fprintf(f, '{\\fonttbl{\\f0\\fmodern Courier New;}{\\f1\\fswiss Arial;}}\n');
  fprintf(f, '{\\colortbl;\\red0\\green0\\blue0;\\red255\\green255\\blue0;\\red255\\green128\\blue128;}\n');
  fprintf(f, '\\deflang1033\\plain\\fs16\n');
  
catch
  error('Unable to poen file ''%s''', file);
end

fclose(f);