% OMNI-JOBS Toolbox by David Weiss
% Version 2013a 23-04-2013
% 
% A package for writing and reading batch jobs of MATLAB commands. 
% Integrates with the Sun Grid Engine (SGE) for distribution over a
% cluster. See OJ.QUICKBATCH for how to get started.
% 
%   cell2str       - Convert a cell array table to a big string for display.
%   clean          - Delete all files associated with a given batch job.
%   csvread        - Read structarray from a comma-separated value file.
%   csvwrite       - Write a structarray to a CSV file.
%   decode         - Convert a string encoded with oj.encode into human-readable format.
%   disp           - Nicely display a structarray as a data table.
%   encode         - Converts a string with arbitrary characters into a fieldname.
%   encoding       - List of invalid -> valid character maps.
%   fields         - Fetches a list of human-readable fieldnames.
%   get            - Returns a matrix or cell array built from fields of a structarray.
%   group          - Find rows containing unique combinations of field values.
%   groupmeans     - Handy shortcut for computing group means.
%   load           - Loads the results of a batch job.
%   path           - Determines the full path of a given directory.
%   quickbatch     - Quickly makes a batch of jobs with unique parameters.
%   readtext       - Grab the contents of a text file.
%   report         - Print a status report on a batch job directory.
%   reset          - Delete the files associated with a specific set of jobs.
%   set            - Add a new column to a struct array.
%   slave          - Start locally processing a jobsdir one job at a time.
%   sort           - Sort a structarray by arbitrary fieldnames.
%   stats          - Generates a status report on a batch job directory.
%   submit         - Submits any unsubmitted jobs from a batch job directory.
%   write          - Writes out the auxiliary files for a single job.
%   args           - Load arguments from a set of jobs
%   errs           - Print error messages from jobs
%   grep           - Grep through stdout of jobs
%   par_chunk      - Divide a dataset into chunks for parallel processing.
%   par_chunk_data - Call OJ.PAR_CHUNK to directly divide data
%   priority       - Edit SGE priority of running jobs
%   tail           - Run 'tail' on stdout of jobs
