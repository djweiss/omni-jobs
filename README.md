omni-jobs Toolbox for MATLAB
============

*Last Updated: 11/19/2012*

Setup Instructions
------------

- Clone the latest source from the github.
- Initialize the `matlab-utils`
   (https://github.com/djweiss/matlab-utils) submodule using the
   command: ``` git submodule init ```
- Add the `omni-jobs` AND `omni-jobs/matlab-utils` to your MATLAB
   path.

Super quick introduction
------------

**Distributing jobs across a cluster**

Say you have a function, `process_img_block`, that reads in a block of
images from file, processes them, and saves them to disk. (This is
fairly common in something like computer vision). You want to
parallelize this computation. (*Note that the helper function
`oj.par_chunk` is useful for dividing data in this fashion.*)

Super easy to do with omni-jobs!

Suppose your function takes three arguments, (1) the name of the
dataset, (2) the block id to process, and (3) the total number of
blocks. (Last two corresponding to the final two inputs to
`oj.par_chunk`.)  Then to distribute `ntasks` jobs across the cluster,
we do the following:

```matlab
	oj.quickbatch('process_img', 'voc2010', 1:ntasks, ntasks);
	oj.submit('process_img_batch');
```

Note that `oj.quickbatch` automatically creates one job per unique
combination of arguments, with arguments passed to your function in
the order that they're given. 

To check on the status of the submitted batch, we can use the command
`oj.report('process_img_batch')`. The output of this command is a
structarray containing information about each job in the batch; we can
pass elements of this array to `oj.reset` if, e.g. some jobs have
crashed and we wish to reset their status so they can be
restarted. Note that `omni-jobs` expects each call to `process_img` to
return a struct; if nothing is returned, an error will occur.

**Running jobs using slaves**

If you want to distribute jobs manually, instead of using SGE, you can
use the `oj.slave` command to start a process that will pick up the
next unprocessed job in a directory, run it, and save the returned
results to file. You can then start as many slave processes as you
want by running more instances of MATLAB.

**Collating output automatically**

A lot of the toolbox's functionality deals with the output of a batch
job. Assuming each job returns a struct or structarray, you can access
the output as follows:

```matlab
r = oj.load('process_img_batch');
results = [r.result];
oj.disp(results);
```

This will display the contents of the `results` struct array, which is
the concatenated result of all structs returned from calls to
`process_img`. Note that `r` also has fields `arg01`, `arg02`, etc.,
which correspond to the inputs to each call to the function.

For more advanced functionality, take a look at `oj.group`, which is a
very powerful tool for collating data. This is useful for example if
each job consists of running a model under various parameters or
settings, returning a struct with experimental results, and you want
to quickly group results and analyze by certain variables.

**Under the hood**

`omni-jobs` uses structarrays to handle all data within MATLAB, and a
simple directory structure to maintain information about all jobs in a
batch. Each stage of processing is represented by a file named after
the job, put in a directory corresponding to that stage (e.g.,
`submit`, `start`, `completed`, `save`, etc.).

Demo
------------

- Coming soon: a more complete demo on the full functionality of the
  toolbox.






