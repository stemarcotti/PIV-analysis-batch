%% load parent folder %%

warning off

uiwait(msgbox('Load parent folder'));
parent_d = uigetdir('');

matlab_folder = cd;
cd(parent_d)
listing = dir('**/cb*_m.tif');
cd(matlab_folder)

% ask the user for an ouput stamp
prompt = {'Pixel length [um]'};
title = 'Parameters';
dims = [1 35]; % set input box size
user_answer = inputdlg(prompt,title,dims); % get user answer
mu2px = str2double(user_answer{1,1});

%% open one file at a time and perform analysis %%

n_files = length(listing);

for file_list = 1:n_files
    
    % file and directory name
    file = listing(file_list).name;
    directory = listing(file_list).folder;
    
    % output name and cell ID
    slash_indeces = strfind(directory,'/');
    output_name = directory(slash_indeces(end)+1:end);
    cell_ID = str2double(output_name(1:2));
    
    % load
    track = load(fullfile([directory '/data'], ['cell_track_', output_name, '.mat']));
    track = track.path;     % [um]
    track_diff = [diff(track(:,1)) diff(track(:,2))];
    
    nt = size(track_diff,1);
    
    % make unit vector track_diff
    track_diff_unit = zeros(nt,2);
    for k = 1:nt
        track_diff_unit(k,:) = track_diff(k,:)./norm(track_diff(k,:));
    end
    
    coord_max_grad = load(fullfile([directory '/data'], ['coord_max_gradient_', output_name, '.mat']));
    coord_max_grad = coord_max_grad.coord_max_grad;
    
    % make unit vector
    track_px = track ./ mu2px;
    track_px(end,:) = [];
    
    centroid_to_max_grad = [coord_max_grad(:,1)-track_px(:,1) coord_max_grad(:,2)-track_px(:,2)];
    unit_max_grad = zeros(nt,2);
    for k = 1:nt
        unit_max_grad(k,:) = centroid_to_max_grad(k,:) ./ norm(centroid_to_max_grad(k,:));
    end
    
    costheta_max_grad = zeros(nt,1);
    for k = 1:nt
        costheta_max_grad(k,1) = dot(unit_max_grad(k,:), track_diff(k,:)) ./...
            (norm(unit_max_grad(k,:)) * norm(track_diff(k,:)));
    end
  
    save(fullfile(directory, 'data', ...
        ['costheta_max_gradient_', output_name,'.mat']), ...
        'costheta_max_grad');
    
end

clear; clc