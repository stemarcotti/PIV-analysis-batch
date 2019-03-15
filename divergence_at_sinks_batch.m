%% load parent folder %%

warning off

uiwait(msgbox('Load parent folder'));
parent_d = uigetdir('');

matlab_folder = cd;
cd(parent_d)
listing = dir('**/piv_field_interpolated*.mat');
cd(matlab_folder)

% ask the user for px length
prompt = {'Pixel length [um]'};
title = 'Parameters';
dims = [1 35]; % set input box size
user_answer = inputdlg(prompt,title,dims); % get user answer
px_length = str2double(user_answer{1,1});

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
    
    [div_at_sink, average_div_at_sink] = div_quantification_sinks(directory, file, d, cell_ID, output_name, px_length);
    
    % save divergence at sinks
    save(fullfile(directory, ...
        ['divergence_sinks_', output_name, '.mat']), ...
        'div_at_sink');
    
    save(fullfile(directory, ...
        ['divergence_sinks_average_', output_name, '.mat']), ...
        'average_div_at_sink');
    
    % clear output variables
    clear div_at_sink average_div_at_sink
    
end

clear