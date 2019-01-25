%% load parent folder %%

warning off

uiwait(msgbox('Load parent folder'));
parent_d = uigetdir('');

matlab_folder = cd;
cd(parent_d)
listing = dir('**/flow_streamlines_endpts_*.mat');
cd(matlab_folder)

%% open one file at a time and perform analysis %%

n_files = length(listing);

for file_list = 1:n_files
    
    % file and directory name
    file = listing(file_list).name;
    directory = listing(file_list).folder;
    
    % output name and cell ID
    slash_indeces = strfind(directory,'/');
    output_name = directory(slash_indeces(end-1)+1:slash_indeces(end)-1);
    cell_ID = str2double(output_name(1:2));
    d = directory(1:slash_indeces(end));
    
    [f_percent, average_f_percent] = streamlines_sinks(directory, file);
    
    % save [f_percent]: percentage of streamlines at the primary sink for each frame [-]
    save(fullfile(directory, ...
        ['streamlines_percentage_sinks_', output_name, '.mat']), ...
        'f_percent');
    
    % save [average_f_percent]: percentage of streamlines at the primary sink averaged for all frames [-]
    save(fullfile(directory, ...
        ['streamlines_percentage_sinks_average_', output_name, '.mat']), ...
        'average_f_percent');
    
    % clear output variables
    clear f_percent average_f_percent
    
end

clear