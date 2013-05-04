function hook_gitassert(config, srcdir)

prevdir = cd(srcdir);

git_hash = githash('.');
git_myfunc_hash = githash(which(config.myfunc));

assert(isequal(git_myfunc_hash, config.git_myfunc_hash));

filename = tempname;
unixf('git diff --stat %s > %s', which(config.myfunc), filename);
[~,diffcontents] = unixf('cat %s', filename);
delete(filename);
if ~isempty(diffcontents)
    error('critical file ''%s'' has changed since last commit!!', which(config.myfunc));
end

if ~isequal(git_hash, config.git_hash)
    fprintf('[git check] global git hash has changed (%s -> %s)\n', config.git_hash, git_hash);
end
fprintf('[git check] changes since batch creation:\n');
filename = tempname;
unixf('git diff %s --stat > %s', config.git_hash, filename);
unixf('cat %s', filename);
delete(filename);


cd(prevdir);
