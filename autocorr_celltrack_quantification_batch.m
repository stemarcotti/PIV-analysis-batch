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
    
    % load cell track
    track = load(fullfile(directory, file));
    track = track.path; % [um]
    track = track(nt_index,:);  % remove intermediate frames if PIV was not run on all frames
    
    % calculate autocorrelation
    track_diff = [diff(track(:,1)) diff(track(:,2))];       % distance between subsequent frames [um] (vect components)
    autocorr_celltrack = autocorr_quantification(track_diff);
    
%     % save [autocorr_celltrack]
%     save(fullfile(directory, ...
%         ['autocorr_celltrack_', output_name, '.mat']), ...
%         'autocorr_celltrack');
    
    autocorr_celltrack_all(file_list).autocorr = autocorr_celltrack;
    
    % clear output variables
    clear parameters track
    clear track_diff autocorr_celltrack
    
end

% save(fullfile(parent_d, ...
%         'ctrl_autocorr_celltrack.mat'), ...
%         'autocorr_celltrack_all');

%% calculate average decay across all files %%

% find length longest track
len = zeros(file_list,1);
for ii = 1:file_list
    len(ii,1) = length(autocorr_celltrack_all(ii).autocorr);
end
max_len = max(len);

% initialise matrix
out = zeros(max_len, file_list);

% pull data from structure to matrix
for k = 1:file_list
    temp = autocorr_celltrack_all(k).autocorr;
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
        'wound_autocorr_celltrack_weighted_avg.mat'), ...
        'weighted_avg');
    
% %% use spline fitting instead of walking average %%
% 
% % this should account for the different frame intervals
% figure
% 
% frame_int = [7; 5; 7; 5];    % [s]
% 
% for k = 1:file_list
%     
%     x = 1:frame_int(k,1):max_len*frame_int(k,1);
%     [xData, yData] = prepareCurveData(x,out(:,k));
%     
%     % Set up fittype and options.
%     ft = fittype('smoothingspline');
%     
%     % Fit model to data.
%     [fitresult, gof] = fit(xData, yData, ft);
%     
%     out_fit(:,k) = fitresult(1:5:max_len*5);
%     plot(x, out(:,k), 'k.');
%     hold on
%     plot(1:5:max_len*5, out_fit(:,k))
%     hold on
%     
%     waitforbuttonpress
%     
%     clear x
% end
% 
% mask = isnan(out);
% out_fit(mask == 1) = NaN;
% 
% x_avg = 1:5:max_len*5;  % [s]
% fit_avg = nanmean(out_fit,2);
% 
% save(fullfile(parent_d, ...
%         'wound_autocorr_celltrack_fit_avg.mat'), ...
%         'fit_avg', 'x_avg');