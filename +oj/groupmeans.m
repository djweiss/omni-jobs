function [groups] = groupmeans(data, fx, fys, varargin)
% Handy shortcut for computing group means.
% 
% Usage:
%
%   groups = oj.groupmeans(data, fx, fys)
%
% Given input DATA, calls OJ.GROUP using cell array of fields FX and
% then computes group means and standard errors for each field in
% cell array FYS.
%
% SEE ALSO
%   oj.group

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

[grp groups] = oj.group(data, fx{:});

for j = 1:numel(fys)

    clear y yvar ystd n
    fy = fys{j};
    for i = 1:numel(groups)
        y(i,:) = mean(oj.get(data(grp==i), fy));
        yvar(i,:) = var(oj.get(data(grp==i), fy));
        ystd(i,:) = std(oj.get(data(grp==i), fy))/sqrt(sum(grp==i));
        n(i) = sum(grp==i);
    end
    
    groups = oj.set(groups, [fy ' (Mean)'], y);
    groups = oj.set(groups, [fy ' (Ste)'], ystd);
end
groups = oj.set(groups, 'n', n);

