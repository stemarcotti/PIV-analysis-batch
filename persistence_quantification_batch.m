%% load parent folder %%

warning off

uiwait(msgbox('Load parent folder'));
parent_d = uigetdir('');

matlab_folder = cd;
cd(parent_d)
listing = dir('**/cell_track_*.mat');
cd(matlab_folder)

%% cap the analysis at the length of the shortest movie [s]

length_shortest = 180; % [s]

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
    
    % max number of frames for persistence analysis
    rec_speed = parameters.recording_speed;     % [s]
    nt_capped = round(length_shortest/rec_speed);   % [frames]
    
    % calculate persistence index
    persistence_index = persistence_quantification(directory, file, nt_capped);
    
    % save [persistence_index]
    save(fullfile(directory, ...
        ['persistence_index_capped_', output_name, '.mat']), ...
        'persistence_index');

    % clear output variables
    clear persistence_index
    
end

clear