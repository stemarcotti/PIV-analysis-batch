%% load parent folder %%

warning off

uiwait(msgbox('Load parent folder'));
parent_d = uigetdir('');

matlab_folder = cd;
cd(parent_d)
listing = dir('**/cell_track_*.mat');
cd(matlab_folder)

%% select interval for walking average

length_interval = 60; % [s]

%% open one file at a time and perform analysis %%

n_files = length(listing);
PI = zeros(n_files,1);

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
    
    % max number of frames for persistence analysis
    rec_speed = parameters.recording_speed;     % [s]
    nt_interval = round(length_interval/rec_speed);   % [frames]
    
    % calculate persistence index
    persistence_index = persistence_quantification_walkingaverage(directory, file, nt_interval);
    
    % save [persistence_index]
    save(fullfile(directory, ...
        ['persistence_index_walking_', output_name, '.mat']), ...
        'persistence_index');

    PI(file_list, 1) = persistence_index;
    
    % clear output variables
    clear persistence_index
    
    % save [persistence_index]
    save(fullfile(parent_d, 'wound_persistence_index_walking.mat'), ...
        'PI');
    
end
