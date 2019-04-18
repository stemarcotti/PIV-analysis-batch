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
    mu2px = parameters.mu2px;
    nt_index = 1:parameters.frame_rate:parameters.max_frame;
    nt_index = nt_index(1:end-1); % remove last frame as primary sink works on frame comparison
    
    % load cell track
    track = load(fullfile(directory, file));
    track = track.path; % [um]
    track = track(nt_index,:);  % remove intermediate frames if PIV was not run on all frames
    
    % load primary sink coordinates
    coord_primary_sink = load(fullfile(directory, ['primary_sink_coordinates_' output_name '.mat']));
    coord_primary_sink = coord_primary_sink.s;
    coord_primary_sink = coord_primary_sink(nt_index,:);
    coord_primary_sink = coord_primary_sink .* mu2px; % [um]
    
    % define vector from cell track to primary sink
    centroid_to_primary = [(coord_primary_sink(:,1)-track(:,1))...
        (coord_primary_sink(:,2)-track(:,2))];
    
    % calculate autocorrelation
    autocorr_primarysink = autocorr_quantification(centroid_to_primary);
    
%     % save [autocorr_primarysink]
%     save(fullfile(directory, ...
%         ['autocorr_primarysink_', output_name, '.mat']), ...
%         'autocorr_primarysink');
    
    autocorr_primarysink_all(file_list).autocorr = autocorr_primarysink;
    
    % clear output variables
    clear parameters track
    clear centroid_to_primary autocorr_primarysink
    
end

% save(fullfile(parent_d, ...
%     'ctrl_autocorr_primarysink.mat'), ...
%     'autocorr_primarysink_all');

%% calculate average decay across all files %%

% find length longest track
len = zeros(file_list,1);
for ii = 1:file_list
    len(ii,1) = length(autocorr_primarysink_all(ii).autocorr);
end
max_len = max(len);

% initialise matrix
out = zeros(max_len, file_list);

% pull data from structure to matrix
for k = 1:file_list
    temp = autocorr_primarysink_all(k).autocorr;
    l = length(temp);
    temp(end+1:max_len+1-temp, 1) = NaN;
    out(:,k) = temp;
end

% calculate weighted average
weights = zeros(max_len, file_list);
for ii = 1:file_list
    for jj = 1:length(out(~isnan(out(:,ii))))
        weights(jj,ii) = out(jj, ii)*length(out(~isnan(out(:,ii))));
    end
end
numerator = sum(weights,2);
denominator = sum(len);
weighted_avg = numerator / denominator;

save(fullfile(parent_d, ...
    'wound_autocorr_primarysink_weighted_avg.mat'), ...
    'weighted_avg');

%% use spline fitting instead of walking average %%

% this should account for the different frame intervals
figure

% frame_int = [5; 5; 5; 5; 5; 5; 9; 8; 8];    % [s]
frame_int = [7; 5; 7; 5];    % [s]

for k = 1:file_list
    
    x = 1:frame_int(k,1):max_len*frame_int(k,1);
    [xData, yData] = prepareCurveData(x,out(:,k));
    
    % Set up fittype and options.
    ft = fittype('smoothingspline');
    
    % Fit model to data.
    [fitresult, gof] = fit(xData, yData, ft);
    
    out_fit(:,k) = fitresult(1:5:max_len*5);
    plot(x, out(:,k), 'k.');
    hold on
    plot(1:5:max_len*5, out_fit(:,k))
    hold on
    
    waitforbuttonpress
    
    clear x
end

mask = isnan(out);
out_fit(mask == 1) = NaN;

x_avg = 1:5:max_len*5;  % [s]
fit_avg = nanmean(out_fit,2);

save(fullfile(parent_d, ...
    'wound_autocorr_primarysink_fit_avg.mat'), ...
        'fit_avg', 'x_avg');