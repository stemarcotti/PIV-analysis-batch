function [flow_speed_max, flow_speed_max_average] = max_flow_quantification(directory, file, d, cell_ID);

% parameters
dilationSize = 4;
erosionSize = 4;
connectivityFill = 4;

% load interpolated filed
flow = load (fullfile (directory, file));
flow = flow.vfilt;

nt = length(flow);

% initialis output vector
flow_speed_max = zeros(nt-1, 1);

% calculate flow speed
for jj = 1:nt-1
    
    % load current and next frame
    currentFrame = double(imread(fullfile(d, sprintf ...
        ('cb%d_m.tif', cell_ID)),jj)) / 255;
    
    nextFrame = double(imread(fullfile(d, sprintf ...
        ('cb%d_m.tif', cell_ID)),jj+1)) / 255;
    
    % find intersection
    cellOutline1 = detectObjectBw(currentFrame, dilationSize, erosionSize, connectivityFill);
    cellOutline2 = detectObjectBw(nextFrame, dilationSize, erosionSize, connectivityFill);
    cellOutline = cellOutline1 .* cellOutline2;
    
    % calculate field magnitude (velocity: [um/min])
    magnitude = hypot(flow(jj).vx, flow(jj).vy);
    
    % apply mask
    magnitude = magnitude .* cellOutline;
    magnitude(cellOutline == 0) = NaN;  
    
    file_name = [d, '/', sprintf('no_cb%d_m.tif', cell_ID)];
    if exist(file_name, 'file') == 2
        
        no_cb_frame = double(imread(fullfile(file_name),jj)) / 255;
        lim = logical(no_cb_frame);
        
        magnitude = magnitude .* lim;   % remove cell body if no_cb exists
        magnitude(lim == 0) = NaN;  
    end

    % save mean flow velocity [um/min]
    flow_speed_max(jj,1) = nanmax(magnitude(:));
    
end

% average across all frames [um/min]
flow_speed_max_average = mean(flow_speed_max);

end