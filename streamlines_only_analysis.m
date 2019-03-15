function streamlines_only_analysis(directory, file, d, cell_ID, output_name)

% input names
im_file = sprintf('cb%d_m.tif', cell_ID);
im_file_nocb = sprintf('no_cb%d_m.tif', cell_ID);
field = load(fullfile (directory, file));

% load files
names = fieldnames(field);
field = field.(names{1});
nt = length(field); % get number of frames in .tif file

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
    imshow(im, []);
    hold on
    slc = streamslice(x_str, y_str, field(k).vx, field(k).vy, 2, 'method', 'cubic');
    set(slc, 'Color', 'g', 'LineStyle', '-');
    
    % white image background
    set(gcf, 'InvertHardCopy', 'off');
    set(gcf, 'Color', [1 1 1]);
    
    % save streamline image to file
    im_stream = getframe(gcf);
    im_stream_out = im_stream.cdata;
    
    hold off
    
    imwrite(im_stream_out, fullfile(d, 'images', ...
        ['streamlines_', output_name,'.tif']), ...
        'writemode', 'append');

end
close all

end