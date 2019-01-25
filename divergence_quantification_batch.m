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
    
    % calculate divergence (call div_quantification function)
    [diverg, diverg_average] = div_quantification(directory, file, d, cell_ID);
    
    % save [diverg]: mean divergence for each frame [A.U.]
    save(fullfile(directory, ...
        ['divergence_', output_name, '.mat']), ...
        'diverg');
    
    % save [diverg_average]: mean divergence averaged for all frames [A.U.]
    save(fullfile(directory, ...
        ['divergence_average_', output_name, '.mat']), ...
        'diverg_average');
    
    % clear output variables
    clear diverg diverg_average
    
end

clear