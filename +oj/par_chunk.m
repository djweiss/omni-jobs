function [chunk] = par_chunk(nelem, taskid, ntasks)
% Divide a dataset into chunks for parallel processing.
%
% Usage:
%
%   chunk = oj.par_chunk(nelem, taskid, ntasks)
%
% NELEM is the number of elements to divide, TASKID is the specific
% task #, and NTASKS is the total # of tasks you want. Then CHUNK is
% the indicies of the elements to process in this specific chunk.

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


if nargin == 2
    ntasks = taskid;
    chunk = {};
    for i = 1:ntasks
        chunk{i} = oj.par_chunk(nelem, i, ntasks);
    end
    return;
end

% Divide evenly into folds
chunk = repmat(1:ntasks, 1, ceil(nelem/ntasks));
chunk = chunk(1:nelem);
chunk = find(chunk==taskid);

