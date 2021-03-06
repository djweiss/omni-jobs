function grep(s, pattern, n, extraargs)
% Grep through stdout of jobs

% ======================================================================
% Copyright (c) 2012 David Weiss
% 
% Permission is hereby granted, free of charge, to any person obtaining
% a copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to
% permit persons to whom the Software is furnished to do so, subject to
% the following conditions:
% 
% The above copyright notice and this permission notice shall be
% included in all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
% EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
% NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
% LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
% OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
% WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
% ======================================================================

if nargin<4
    extraargs = '';
end
if nargin<3
    n = 1;
end
if nargin<2
    pattern = 'iter';
end

for i = 1:numel(s)
    if ~s(i).started
        continue;
    end
    fprintf('[%s] ', s(i).jobname);
    [~,m] = unixf('grep %s %s %s/stdout/%s | tail -n %d', extraargs, pattern, s(i).jobsdir, s(i).jobname, n);
    if sum(m==10)>1
        fprintf(':\n');
    end
    fprintf('%s', m);
    if isempty(m)
        fprintf('\n');
    end
    %disp(s(i).output(end-n:end,1:72));
end