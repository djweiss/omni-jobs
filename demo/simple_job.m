function [result] = simple_job(n, m, lambda, seed)
% Simple demo script that tests ridge regression on some random data.

% Set random number generator for repeatability
rng(seed);

% Generate a random linear model
X = randn(n,m);
wtruth = randn(m,1);
y = X*wtruth + randn(n,1)*0.1;

% Do some simple prediction using linear regression
what = pinv(X'*X + eye(m)*lambda)*X'*y;
yhat = X*what;

% Return result as a structure
result = bundle(m, n, lambda, seed, ...
    what, wtruth, sqrt(mean([yhat-y].^2)), 'y_rmse', ...
    sqrt(mean([wtruth-what].^2)), 'w_rmse');

return;

%% Running a batch using omni-jobs

% Run a decent sized grid to explore parameter settings
oj.quickbatch('simple_job', 1000, [50 100], [0.1 1 10], 1:5);
oj.submit('simple_job_batch');

%% Check the status of the jobs
s = oj.report('simple_job_batch');

% example: checking if any jobs crashed
fprintf('%d jobs crashed.\n', sum([s.crashed]));

% find, reset, and re-submit any crashed jobs
idx = find([s.crashed]);
oj.reset(idx);
oj.submit('simple_job_batch');

%% Pro tip: use CFileFinder to autocomplete directory names
f = CFileFinder;
f.simple_job_batch

%% Load results and display the results table
r = oj.load(f.simple_job_batch);
result = [r.result];
oj.disp(result);

%% Group by lambda to see effect
mns = oj.groupmeans(result, {'lambda','m'},{'y_rmse','w_rmse'});
oj.disp(mns);

% Note we can group ourselves as follows:
[grp groups] = oj.group(result, 'lambda', 'm');

%% Save results to CSV and read it back again
oj.csvwrite(mns, 'tmp.csv');
a = oj.csvread('tmp.csv');

