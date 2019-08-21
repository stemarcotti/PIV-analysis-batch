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
    
    % load largest extension coordinates
    coord_largest_ext = load(fullfile(directory, ['coord_largest_ext_blob_' output_name '.mat']));
    coord_largest_ext = coord_largest_ext.coord_largest_ext;
    coord_largest_ext = coord_largest_ext(nt_index,:);
    coord_largest_ext = coord_largest_ext .* mu2px; % [um]
    
    % load primary sink coordinates
    coord_primary_sink = load(fullfile(directory, ['primary_sink_coordinates_' output_name '.mat']));
    coord_primary_sink = coord_primary_sink.s;
    coord_primary_sink = coord_primary_sink(nt_index,:);
    coord_primary_sink = coord_primary_sink .* mu2px; % [um]
    
    distance_nucleus_primary = zeros(size(track,1),1);
    distance_nucleus_ext = zeros(size(track,1),1);
    for kk = 1:size(track,1)
        
        x1 = [track(kk,:); coord_primary_sink(kk,:)];
        x2 = [track(kk,:); coord_largest_ext(kk,:)];
        distance_nucleus_primary(kk,1) = pdist(x1,'euclidean');
        distance_nucleus_ext(kk,1) = pdist(x2,'euclidean');
        
    end
    
    % save 
    save(fullfile(directory, ...
        ['distance_nucleus_primary_', output_name, '.mat']), ...
        'distance_nucleus_primary');
    
    save(fullfile(directory, ...
        ['distance_nucleus_ext_', output_name, '.mat']), ...
        'distance_nucleus_ext');
    
    clear distance_nucleus_primary distance_nucleus_ext
    
end

clear