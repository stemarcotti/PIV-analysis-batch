%% load parent folder %%

warning off

uiwait(msgbox('Load parent folder'));
parent_d = uigetdir('');

matlab_folder = cd;
cd(parent_d)
listing = dir('**/cell_track*.mat');
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
    d = directory(1:slash_indeces(end));
    
    % parameters
    file_parameters = [d 'parameters/piv_parameters_' output_name '.mat'];
    parameters = load(file_parameters);
    parameters = parameters.params;
    nt_index = 1:parameters.frame_rate:parameters.max_frame;
    nt_index = nt_index(1:end-1); % remove last frame as largest ext works on frame comparison (blobs)
    mu2px = parameters.mu2px;
    
    % load cell track
    track = load(fullfile(directory, file));
    track = track.path; % [um]
    track = track(nt_index,:);  % remove intermediate frames if PIV was not run on all frames
    track_diff = [diff(track(:,1)) diff(track(:,2))];
    
%     % load largest extension coordinates
%     coord_largest_ext = load(fullfile(directory, ['coord_largest_ext_vectors_' output_name '.mat']));
%     coord_largest_ext = coord_largest_ext.coord_largest_ext;
%     coord_largest_ext = coord_largest_ext(nt_index,:);
%     coord_largest_ext = coord_largest_ext .* mu2px; % [um]
%     
%     % define vector from cell track to largest ext
%     centroid_to_largest = [(coord_largest_ext(:,1)-track(:,1))...
%         (coord_largest_ext(:,2)-track(:,2))];
    
    % load primary sink coordinates
    coord_primary_sink = load(fullfile(directory, ['primary_sink_coordinates_' output_name '.mat']));
    coord_primary_sink = coord_primary_sink.s;
    coord_primary_sink = coord_primary_sink(nt_index,:);
    coord_primary_sink = coord_primary_sink .* mu2px; % [um]
    
    % define vector from cell track to primary sink
    centroid_to_primary = [(coord_primary_sink(:,1)-track(:,1))...
        (coord_primary_sink(:,2)-track(:,2))];
  
    % calculate autocorrelation
    [corr1, corr2, lagstore] = crosscorr_quantification(track_diff, centroid_to_primary);
    crosscorr_cell_primarysink_all(file_list).crosscorr1 = corr1;
    crosscorr_cell_primarysink_all(file_list).crosscorr2 = corr2;
    crosscorr_cell_primarysink_all(file_list).lag = lagstore;
    
    % clear output variables
    clear parameters track
    clear centroid_to_primary 
    
end

%% calculate average decay across all files %%

% find length longest track
len = zeros(file_list,1);
for ii = 1:file_list
    len(ii,1) = length(crosscorr_cell_primarysink_all(ii).crosscorr1);
end
max_len = max(len);

% initialise matrix
out_crosscorr1 = zeros(max_len, file_list);
out_crosscorr2 = zeros(max_len, file_list);
out_lag = zeros(max_len, file_list);

% pull data from structure to matrix
for k = 1:file_list
    temp1 = crosscorr_cell_primarysink_all(k).crosscorr1;
    temp2 = crosscorr_cell_primarysink_all(k).crosscorr2;
    temp3 = crosscorr_cell_primarysink_all(k).lag;
    temp1(end+1:max_len, 1) = NaN;
    temp2(end+1:max_len, 1) = NaN;
    temp3(end+1:max_len, 1) = NaN;
    out_crosscorr1(:,k) = temp1;
    out_crosscorr2(:,k) = temp2;
    out_lag(:,k) = temp3;
end

% calculate weighted average
weights1 = zeros(max_len, file_list);
weights2 = zeros(max_len, file_list);
for ii = 1:file_list
    for jj = 1:length(out_crosscorr1(~isnan(out_crosscorr1(:,ii))))
        weights1(jj,ii) = out_crosscorr1(jj, ii)*length(out_crosscorr1(~isnan(out_crosscorr1(:,ii))));
        weights2(jj,ii) = out_crosscorr2(jj, ii)*length(out_crosscorr2(~isnan(out_crosscorr2(:,ii))));
    end
end

numerator1 = sum(weights1,2);
numerator2 = sum(weights2,2);
denominator = sum(len);


weighted_avg = numerator1 / denominator;
weighted_avg2 = numerator2 / denominator;
weighted_avg2 = flipud(weighted_avg2);
weighted_avg2 = weighted_avg2(1:end-1);

crosscorr_cell_primarysink_weighted = [weighted_avg2; weighted_avg];

%% %%
rightlag = 0:max_len-1;
rightlag = rightlag';

leftlag = flipud(rightlag)*-1;
leftlag = leftlag(1:end-1);

lags = [leftlag; rightlag];

save(fullfile(parent_d, ...
    'RPE_crosscorr_cell_primarysink_weighted_avg.mat'), ...
    'lags', 'crosscorr_cell_primarysink_weighted');