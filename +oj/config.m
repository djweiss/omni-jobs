function opts = config(jobsdir, varargin)

defaults.hook_pre = [];
defaults.hook_pre_args = {};
defaults.hook_post = [];
defaults.hook_post_args = {};
defaults.hook_config = [];
defaults.hook_config_args = {};
defaults.jobsdir = jobsdir;

if ~exist(jobsdir, 'dir')
    error('directory ''%s'' does not exist', jobsdir);
end

global OJ_DEFAULT_CONFIG;
if ~isempty(OJ_DEFAULT_CONFIG)
    defaults = mergestructs(OJ_DEFAULT_CONFIG, defaults);
end
    
configfile = sprintf('%s/config.mat', jobsdir);

if nargin == 1 && nargout > 0
    if exist(configfile, 'file')
        opts = loadvar(configfile);
    else
        opts = [];
    end
    return;
elseif nargout == 0
    if exist(configfile, 'file')
        opts = loadvar(configfile);
        reply = input(sprintf('Batch ''%s'' already configured. Overwrite? (y/n)', jobsdir), 's');
        if ~strcmp(reply, 'y')
            return;
        end
    else
        opts = defaults;
    end
    opts = mergestructs(struct(varargin{:}), opts);
    if ~isempty(opts.hook_config)
        opts = opts.hook_config(opts, opts.hook_config_args{:});
    end
    savemkdir(configfile, opts);
else
    error('invalid usage of config command');
end

if ~isfield(opts, 'myfunc')
    error('config must include pointer to function handle');
end

    
