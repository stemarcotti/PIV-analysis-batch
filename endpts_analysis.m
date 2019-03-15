function stream_end_pts = endpts_analysis(directory, file, d, cell_ID, output_name, px_length)

% input names
im_file = sprintf('cb%d_m.tif', cell_ID);
im_file_nocb = sprintf('no_cb%d_m.tif', cell_ID);
field = load(fullfile (directory, file));

% load files
names = fieldnames(field);
field = field.(names{1});
nt = length(field); % get number of frames in .tif file

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
        % load nocb frame
        im_nocb = im2double(imread(fullfile(d, im_file_nocb), k));
        % define start points for streamlines
        imbw_nocb = logical(im_nocb);
        erode_nocb = imerode(imbw_nocb, strel('disk', 12));
        edge_line_nocb = edge(erode_nocb, 'Canny'); % get cell edge line
        [y, x] = find(edge_line_nocb); % find starting points for every streamline
        % eliminate cell body data from vector field
        field(k).vx = field(k).vx .* logical(im_nocb);
        field(k).vy = field(k).vy .* logical(im_nocb);
    else
        % define start points for streamlines
        imbw = logical(im);
        erode_cell = imerode(imbw, strel('disk', 12));
        edge_line = edge(erode_cell, 'Canny'); % get cell edge line
        [y, x] = find(edge_line);
    end
    
    % define meshgrid 
    [x_str, y_str] = meshgrid(1:1:size(im,2), 1:1:size(im,1));
    
    % compute streamlines (quantitative)
    stream_data = stream2(x_str, y_str, field(k).vx, field(k).vy, x, y);
    
    % compute frequency of end points
    m = size(im,1);
    n = size(im,2);
    [sx, sy, sf] = get_streamline_end_freq(stream_data, m, n, dx, dy);
    s_coord = [sx, sy, sf];
    
    % remove rows with null frequency
    condition = s_coord(:,3)==0;
    s_coord(condition,:) = [];
    
    % remove coordinates outside image
    idx = [];
    for ii = 1:size(s_coord,1)
        if im(ceil(s_coord(ii,2)), ceil(s_coord(ii,1))) == 0
            idx = [idx, ii];
        end
    end
    s_coord(idx,:) = [];

    % save endpts in structure
    stream_end_pts(k).xf = s_coord(:,1);
    stream_end_pts(k).yf = s_coord(:,2);
    stream_end_pts(k).f = s_coord(:,3);
    
    % create scatter plot with frequency of end points
    imshow(im, [])
    hold on
    scatter(s_coord(:,1), s_coord(:,2), s_coord(:,3), 'm', 'fill');
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