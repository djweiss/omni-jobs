function Chunk = get_par_chunk(N, TaskID, nTasks)

    if nargin == 1
        [TaskID, ~, ~, nTasks] = get_task_id();
    end
    
    % A more even distribution of tasks
    Chunk = repmat(1:nTasks, 1, ceil(N/nTasks));
    Chunk = Chunk(1:N);
    Chunk = find(Chunk==TaskID);

end