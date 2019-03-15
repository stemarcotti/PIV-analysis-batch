%% load parent folder %%

warning off

uiwait(msgbox('Load parent folder'));
parent_d = uigetdir('');

matlab_folder = cd;
cd(parent_d)
listing = dir('**/flow_streamlines_endpts*.mat');
cd(matlab_folder)

%% cap the analysis at the length of the shortest movie [s] (PERSISTENCE)

length_shortest = 180; % [s]

%% %%
n_files = length(listing);
n_sinks_average = zeros(n_files,1);

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
    
    % load streamlines
    s = load(fullfile(directory, file));
    s = s.stream_end_pts;
    
    n_sinks = zeros(nt_capped-1,1);
    for jj = 1:nt_capped-1
        n_sinks(jj,1) = size(s(jj).xf,1);
    end
    
    n_sinks_average(file_list,1) = round(mean(n_sinks));
    
end

