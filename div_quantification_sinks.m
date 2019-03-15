function [div_at_sink, average_div_at_sink] = div_quantification_sinks(directory, file, d, cell_ID, output_name, px_length)

% parameters
dx_um = 2.5;    % [um] has to be the same as streamlines_plot.m
dy_um = 2.5;    % [um] has to be the same as streamlines_plot.m
dx = ceil(dx_um/px_length); % [px]
dy = ceil(dy_um/px_length); % [px]

dilationSize = 4;
erosionSize = 12;
connectivityFill = 4;

% load interpolated filed
flow = load(fullfile(directory, file));
flow = flow.vfilt;

% load streamline end points
stream = load (fullfile (directory, ['flow_streamlines_endpts_', output_name, '.mat']));
stream = stream.stream_end_pts;

% number of frames in the movie
nt = length(imfinfo(fullfile (d, sprintf('cb%d_m.tif', cell_ID))));
div_at_sink = zeros(nt-1,3);

% calculate divergence at sinks
for k = 1:nt-1
    
    % load current and next frame
    currentFrame = double(imread(fullfile(d, sprintf ...
        ('cb%d_m.tif', cell_ID)),k)) / 255;
    
    nextFrame = double(imread(fullfile(d, sprintf ...
        ('cb%d_m.tif', cell_ID)),k+1)) / 255;
    
    % calculate divergence
    u = flow(k).vx;
    v = flow(k).vy;

    div = divergence(u,v);
    
    % find intersection
    cellOutline1 = detectObjectBw(currentFrame, dilationSize, erosionSize, connectivityFill);
    cellOutline2 = detectObjectBw(nextFrame, dilationSize, erosionSize, connectivityFill);
    cellOutline = cellOutline1 .* cellOutline2;
    cellOutline(cellOutline==0)=NaN;
    
    div_mask = div .* cellOutline;
    
    % remove cell body if present
    file_name = [d, '/', sprintf('no_cb%d_m.tif', cell_ID)];
    if exist(file_name, 'file') == 2
        
        no_cb_frame = double(imread(fullfile(file_name),k)) / 255;
        lim = logical(no_cb_frame);
        
        div_mask = div_mask .* lim;   % remove cell body if no_cb exists
        div_mask(lim == 0) = NaN;
    end
    
    % find max 3 sinks coordinates by sorting frequency field
    stream_f = stream(k).f(:);
    [~, stream_f_sorted_index] = sort(stream_f, 'descend');
    
    if length(stream_f) >= 3
        
        s1_x = stream(k).xf(stream_f_sorted_index(1),1);
        s1_y = stream(k).yf(stream_f_sorted_index(1),1);
        s2_x = stream(k).xf(stream_f_sorted_index(2),1);
        s2_y = stream(k).yf(stream_f_sorted_index(2),1);
        s3_x = stream(k).xf(stream_f_sorted_index(3),1);
        s3_y = stream(k).yf(stream_f_sorted_index(3),1);
        
        % calculate div in boxes around sinks
        s1_box_x = round(s1_x-(dx/2));
        s1_box_y = round(s1_y-(dy/2));
        s2_box_x = round(s2_x-(dx/2));
        s2_box_y = round(s2_y-(dy/2));
        s3_box_x = round(s3_x-(dx/2));
        s3_box_y = round(s3_y-(dy/2));
        
        if isnan(s1_box_x)  % verify sink it's not at the cell edge
            s1_div = zeros(dx+1, dy+1) * NaN;
        else
            s1_div = div_mask(s1_box_y:s1_box_y+dy, s1_box_x:s1_box_x+dx);
        end
        
        if isnan(s2_box_x)
            s2_div = zeros(dx+1, dy+1) * NaN;
        else
            s2_div = div_mask(s2_box_y:s2_box_y+dy, s2_box_x:s2_box_x+dx);
        end
        
        if isnan(s3_box_x)
            s3_div = zeros(dx+1, dy+1) * NaN;
        else
            s3_div = div_mask(s3_box_y:s3_box_y+dy, s3_box_x:s3_box_x+dx);
        end
        
        div_at_sink(k,1) = nanmean(s1_div(:));
        div_at_sink(k,2) = nanmean(s2_div(:));
        div_at_sink(k,3) = nanmean(s3_div(:));
        
    elseif length(stream_f) == 2
        
        s1_x = stream(k).xf(stream_f_sorted_index(1),1);
        s1_y = stream(k).yf(stream_f_sorted_index(1),1);
        s2_x = stream(k).xf(stream_f_sorted_index(2),1);
        s2_y = stream(k).yf(stream_f_sorted_index(2),1);
        
        % calculate div in boxes around sinks
        s1_box_x = round(s1_x-(dx/2));
        s1_box_y = round(s1_y-(dy/2));
        s2_box_x = round(s2_x-(dx/2));
        s2_box_y = round(s2_y-(dy/2));
        
        if isnan(s1_box_x)  % verify sink it's not at the cell edge
            s1_div = zeros(dx+1, dy+1) * NaN;
        else
            s1_div = div_mask(s1_box_y:s1_box_y+dy, s1_box_x:s1_box_x+dx);
        end
        
        if isnan(s2_box_x)
            s2_div = zeros(dx+1, dy+1) * NaN;
        else
            s2_div = div_mask(s2_box_y:s2_box_y+dy, s2_box_x:s2_box_x+dx);
        end
        
        div_at_sink(k,1) = nanmean(s1_div(:));
        div_at_sink(k,2) = nanmean(s2_div(:));
        
    elseif length(stream_f) == 1
        
        s1_x = stream(k).xf(stream_f_sorted_index(1),1);
        s1_y = stream(k).yf(stream_f_sorted_index(1),1);
        
        % calculate div in boxes around sinks
        s1_box_x = round(s1_x-(dx/2));
        s1_box_y = round(s1_y-(dy/2));
        
        if isnan(s1_box_x)  % verify sink it's not at the cell edge
            s1_div = zeros(dx+1, dy+1) * NaN;
        else
            s1_div = div_mask(s1_box_y:s1_box_y+dy, s1_box_x:s1_box_x+dx);
        end
        
        div_at_sink(k,1) = nanmean(s1_div(:));
    
    end
    
    clear stream_f
    clear s1_div s2_div s3_div
    clear s1_x s1_y s2_x s2_y s3_x s3_y
    
end

average_div_at_sink = nanmean(div_at_sink);

end