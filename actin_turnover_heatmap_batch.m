%% load parent folder %%

warning off

uiwait(msgbox('Load parent folder'));
parent_d = uigetdir('');

matlab_folder = cd;
cd(parent_d)
listing = dir('**/piv_field_interpolated*.mat');
cd(matlab_folder)

% ask the user for max colorscale
prompt = {'Max disassembly to be displayed in colourmap [A.U.]'};
title = 'Parameters';
dims = [1 35]; % set input box size
user_answer = inputdlg(prompt,title,dims); % get user answer
max_colorscale = str2double(user_answer{1,1});

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
    
    turn_heatmap(directory, file, d, cell_ID, output_name, max_colorscale);
    
end

clear