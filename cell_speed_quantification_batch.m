%% load parent folder %%

warning off

uiwait(msgbox('Load parent folder'));
parent_d = uigetdir('');

matlab_folder = cd;
cd(parent_d)
listing = dir('**/cell_track_*.mat');
cd(matlab_folder)

%% open one file at a time and perform analysis %%

n_files = length(listing);

for file_list = 1:n_files
    
    % file and directory name
    file = listing(file_list).name;
    directory = listing(file_list).folder;
    
    % output name
    slash_indeces = strfind(directory,'/');
    output_name = directory(slash_indeces(end-1)+1:slash_indeces(end)-1);
    d = directory(1:slash_indeces(end));
    
    % parameters
    file_parameters = [d 'parameters/piv_parameters_' output_name '.mat'];
    parameters = load(file_parameters);
    parameters = parameters.params;
    time_int = parameters.recording_speed * parameters.frame_rate; % [s]
    nt_index = 1:parameters.frame_rate:parameters.max_frame;
    
    time_int_min = time_int/60; % [min]
    
    % calculate cell track speed
    [cell_speed, cell_speed_average] = cell_speed_quantification(directory, file, nt_index, time_int_min);
    
    % save [cell_speed] [um/min]
    save(fullfile(directory, ...
        ['cell_speed_', output_name, '.mat']), ...
        'cell_speed');
    
    % save [cell_speed_average] [um/min]
    save(fullfile(directory, ...
        ['cell_speed_average_', output_name, '.mat']), ...
        'cell_speed_average');

    % clear output variables
    clear cell_speed cell_speed_average
    
end

clear