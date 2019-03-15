function retro_heatmap(directory, file, d, cell_ID, output_name, px_length)

% load interpolated filed
flow = load (fullfile (directory, file));
flow = flow.vfilt;

% load cell path
track = load (fullfile (directory, ['cell_track_', output_name, '.mat']));
track = track.path;

track = track/px_length;    % [px]
track_smooth = [smooth(track(:,1)), smooth(track(:,2))]; % [px] smooth track with moving average to reduce noise

track_diff = [diff(track_smooth(:,1)) diff(track_smooth(:,2))];

% parameters
dilationSize = 4;
erosionSize = 12;
connectivityFill = 4;

% initialise
[m, n] = meshgrid(1:size(flow(1).vx,2),...
    1:size(flow(1).vx,1));

for j = 1:length(flow)
    
    % calculate angle flow field to direction of motion
    cosine = zeros(size(m,1), size(m,2));
    for ii = 1:size(m,1)
        for jj = 1:size(m,2)
            
            A = [track_diff(j,1) track_diff(j,2)];
            B = [flow(j).vx(ii,jj) flow(j).vy(ii,jj)];
            
            cosine(ii,jj) = dot(A,B)./ (norm(A) .*  norm(B));
            
        end
    end
    
    % load images
    currentFrame = double(imread(fullfile(d, sprintf ...
        ('cb%d_m.tif', cell_ID)),j)) / 255;
    
    nextFrame = double(imread(fullfile(d, sprintf ...
        ('cb%d_m.tif', cell_ID)),j+1)) / 255;
    
    file_name = [d '/' sprintf('no_cb%d_m.tif', cell_ID)];
    if exist(file_name, 'file') == 2
        no_cb_frame = double(imread(fullfile(d, sprintf ...
            ('no_cb%d_m.tif', cell_ID)),j)) / 255;
        
        mask_cb = logical(no_cb_frame);
    else
        mask_cb = logical(currentFrame);
    end
    
    cellOutline1 = detectObjectBw(currentFrame, dilationSize, erosionSize, connectivityFill);
    cellOutline2 = detectObjectBw(nextFrame, dilationSize, erosionSize, connectivityFill);
    cellOutline = cellOutline1 .* cellOutline2;
    
    cosine_mask = cosine .* (cellOutline .* mask_cb);
    cosine_mask(cosine_mask==0) = NaN;
    
    % plot heatmap
    h = imshow(cosine_mask, []);
    colormap('jet');
    c = colorbar;
    c.Label.FontSize = 14;
    c.Label.String = 'Cos(theta)';
    hold on

    % black background
    set(h, 'AlphaData', ~isnan(cosine_mask)) % set NaN to transparent
    axis on;
    set(gca, 'XColor', 'none', 'yColor', 'none', 'xtick', [], 'ytick', [], 'Color', 'k') % turn transparent to black
    hold off
    
    % white image background
    set(gcf, 'InvertHardCopy', 'off');
    set(gcf, 'Color', [1 1 1]);

    % get frame for .tif saving
    im_out = getframe(gcf);
    im_out = im_out.cdata;

    % save .tif stack of convergence map
    imwrite(im_out, fullfile([d '/images'], ['retrograde_heatmap_', output_name, '.tif']), ...
        'writemode', 'append');
end
close

end