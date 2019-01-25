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
    
    % calculate turnover (call turn_quantification function)
    [turnover, turnover_average] = turn_quantification(directory, file, d, cell_ID);
    
    % save [turnover]: mean turnover for each frame [A.U.]
    save(fullfile(directory, ...
        ['turnover_', output_name, '.mat']), ...
        'turnover');
    
    % save [turnover_average]: mean turnover averaged for all frames [A.U.]
    save(fullfile(directory, ...
        ['turnover_average_', output_name, '.mat']), ...
        'turnover_average');
    
    % clear output variables
    clear turnover turnover_average
    
end

clear