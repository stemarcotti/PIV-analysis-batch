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
    
    stream = load (fullfile ([directory '/data'], ['flow_streamlines_endpts_', output_name, '.mat']));
    stream = stream.stream_end_pts;
    
    % find coordinates primary sink
    s = zeros(nt, 2);
    for k = 1:nt
        
        stream_temp(:,1) = stream(k).xf;
        stream_temp(:,2) = stream(k).yf;
        stream_temp(:,3) = stream(k).f;
        
        idx = find(stream_temp(:,3) == max(stream_temp(:,3)));
        
        s(k,1) = stream_temp(idx,1);
        s(k,2) = stream_temp(idx,2);
        
        clear stream_temp idx
        
    end
    save([directory '/data/primary_sink_coordinates_' output_name '.mat'], 's')
    
    % make unit vector
    track_px = track ./ mu2px;
    track_px(end,:) = [];
    
    centroid_to_primary_sink = [s(:,1)-track_px(:,1) s(:,2)-track_px(:,2)];
    s_unit = zeros(nt,2);
    for k = 1:nt
        s_unit(k,:) = centroid_to_primary_sink(k,:) ./ norm(centroid_to_primary_sink(k,:));
    end
    save([directory '/data/unit_vector_primary_sink_' output_name '.mat'], 's_unit')
    
    % rotate to direction of motion and save theta_s
    theta_s = zeros(nt,1);
    primary_sink_rotated = zeros(nt,2);
    
    for k = 1:nt
        
        % track diff unit vector
        x_t = track_diff_unit(k,1);
        y_t = track_diff_unit(k,2);
        % primary sink unit vector
        x_s = s_unit(k,1);
        y_s = s_unit(k,2);
        
        % calculate rotation angle
        theta = atan2d(y_t, x_t);
        % track diff unit vector rotated to horizontal
        x1_t = x_t*cosd(-theta) - y_t*sind(-theta);
        y1_t = x_t*sind(-theta) + y_t*cosd(-theta);
        % all ext unit vector rotated to horizontal
        x1_s = x_s*cosd(-theta) - y_s*sind(-theta);
        y1_s = x_s*sind(-theta) + y_s*cosd(-theta);
        theta_s(k,1) = atan2d(y1_s, x1_s);  % [degrees]
        primary_sink_rotated(k,:) = [x1_s y1_s];
    end
    save([directory '/data/resultant_primary_sink_rotated_' output_name '.mat'], 'primary_sink_rotated')
    save([directory '/data/theta_primary_sink_to_direction_motion_' output_name '.mat'], 'theta_s')
    
end

clear; clc