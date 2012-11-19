function [] = oj_closertf(file)

try
  f = fopen(file, 'a+');

  fprintf(f, '\n\n}\n');
  
catch
  error('Unable to poen file ''%s''', file);
end

fclose(f);
