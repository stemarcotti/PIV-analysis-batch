%% load parent folder %%

warning off

uiwait(msgbox('Load parent folder'));
parent_d = uigetdir('');

matlab_folder = cd;
cd(parent_d)
listing = dir('**/piv_field_interpolated*.mat');
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
    
    [flow_speed, flow_speed_average] = flow_quantification(directory, file, d, cell_ID);
    
    % save [flow_speed]: mean flow velocity for each frame [um/min]
    save(fullfile(directory, ...
        ['flow_speed_', output_name, '.mat']), ...
        'flow_speed');
    
    % save [flow_speed_average]: mean flow velocity averaged for all frames [um/min]
    save(fullfile(directory, ...
        ['flow_speed_average_', output_name, '.mat']), ...
        'flow_speed_average');
    
    % clear output variables
    clear flow_speed flow_speed_average

end

clear