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
    
    file_parameters = [d 'parameters/piv_parameters_' output_name '.mat'];
    parameters = load(file_parameters);
    parameters = parameters.params;
    mu2px = parameters.mu2px;
    
    % calculate cell area (call area_quantification function)
    [cell_area, cell_area_average] = area_quantification(directory, file, d, cell_ID, mu2px);
    
    % save [cell_area]: cell area for each frame [um2]
    save(fullfile(directory, ...
        ['cell_area_', output_name, '.mat']), ...
        'cell_area');
    
    % save [cell_area_average]: mean cell area averaged for all frames [um2]
    save(fullfile(directory, ...
        ['cell_area_average_', output_name, '.mat']), ...
        'cell_area_average');
    
    % clear output variables
    clear cell_area cell_area_average
    
end

clear