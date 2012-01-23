% OPUSJOBS Toolbox Documentation
%
% 
% Suppose we have a simple function:
%
%  function [row] = compute(N, seed)
%    A = rand(N);
%    row.sums = sum(mod(A,seed));
%  
% We can write a set of jobs to explore different parameters as follows:
%
% for n = 100:100:1000
%   for i = 1:5
%     oj_write('explore', 'compute', 'myfunc_args', {N,i});
%     oj_write('explore', 'compute', 'myfunc_args', {N,i});

