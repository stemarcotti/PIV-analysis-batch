function stream_end_pts = streamlines_analysis(directory, file, d, cell_ID, output_name, px_length)

% input names
im_file = sprintf('cb%d_m.tif', cell_ID);
im_file_nocb = sprintf('no_cb%d_m.tif', cell_ID);
field = load(fullfile (directory, file));

% load files
names = fieldnames(field);
field = field.(names{1});
nt = length(field); % get number of frames in .tif file

% initialise figures (not visible)
f1 = figure('Visible', 'off'); % streamlines
f2 = figure('Visible', 'off'); % end points

% size of box to calculate streamlines end points
dx_um = 2.5;    % [um]
dy_um = 2.5;    % [um]

dx = ceil(dx_um/px_length); % [px]
dy = ceil(dy_um/px_length); % [px]

% calculate streamlines
for k = 1:nt
    
    % read movies
    im = imread(fullfile(d, im_file), k);
    im = im2double(im);
    
    % if image without cell body is available
    file_name = [d '/' im_file_nocb];
    if exist(file_name, 'file') == 2
        
        im_nocb = im2double(imread(fullfile(d, im_file_nocb), k));
        
        % eliminate cell body data from vector field
        field(k).vx = field(k).vx .* logical(im_nocb);
        field(k).vy = field(k).vy .* logical(im_nocb);
    end
    
    % define meshgrid 
    [x_str, y_str] = meshgrid(1:1:size(im,2), 1:1:size(im,1));
    
    % plot
    f1;
    imshow(im, []); 
    hold on
    slc = streamslice(x_str, y_str, field(k).vx, field(k).vy, 'method', 'cubic');
    set(slc, 'Color', 'g', 'LineStyle', '-');
   
    % save streamline image to file
    im_stream = getframe(gcf);
    im_stream_out = im_stream.cdata;
    
    hold off

    imwrite(im_stream_out, fullfile(d, 'images', ...
        ['streamlines_', output_name,'.tif']), ...
        'writemode', 'append');
    
    % define start points for streamlines
    if exist(file_name, 'file') == 2
        imbw_nocb = logical(im_nocb);
        erode_nocb = imerode(imbw_nocb, strel('disk', 15));
        edge_line_nocb = edge(erode_nocb, 'Canny'); % Get cell edge line
        [y, x] = find(edge_line_nocb); % find starting points for every streamline
    else
        imbw = logical(im);
        erode_cell = imerode(imbw, strel('disk', 15));
        edge_line = edge(erode_cell, 'Canny'); % Get cell edge line
        [y, x] = find(edge_line);
    end
    
    % compute streamlines (quantitative)
    S(k).stream_data = stream2(x_str, y_str, field(k).vx, field(k).vy, x, y);
    
    % compute frequency of end points
    [stream_end_pts(k).xf, stream_end_pts(k).yf, stream_end_pts(k).f] = ...
        get_streamline_end_freq(S(k).stream_data, ...
        size(im,1), size(im,2), dx, dy);
    
    % create scatter plot with frequency of end points
    f2;
    imshow(im, [])
    hold on
    for i = 1:length(stream_end_pts(k).xf)
        if stream_end_pts(k).f(i) > 0
            scatter(stream_end_pts(k).xf(i), stream_end_pts(k).yf(i), ...
                stream_end_pts(k).f(i), 'm', 'fill');
        end
    end
    
    hold off
    
    % save streamline image to file
    im_stream = getframe(gcf);
    im_stream_out = im_stream.cdata;
   
    % save streamline image to file
    imwrite(im_stream_out, fullfile(d, 'images', ...
        ['end_points_', output_name,'.tif']), ...
        'writemode', 'append');
    
end
close all

end