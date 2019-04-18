function bleaching_heatmap(directory, file, d, cell_ID, output_name)

% parameters
dt = 5;
dx = 5;
dy = 5;
dilationSize = 4;
erosionSize = 12;
connectivityFill = 4;

% load data
flow = load(fullfile (directory, file));
flow = flow.vfilt;

coord_bleach_file = [directory '/coord_bleach_' output_name '.csv'];
coord_bleach = readtable(coord_bleach_file);
coord_bleach = table2array(coord_bleach);
coord_bleach = coord_bleach(:,2:end);

stream = load (fullfile (directory, ['flow_streamlines_endpts_erode_wcb_', output_name, '.mat']));
stream = stream.stream_end_pts;

nt = length(flow);

%%
for jj =  1:nt
    
    %% load frames and prepare masks
    current_frame = double(imread(fullfile(d, sprintf ...
        ('cb%d_m.tif', cell_ID)),jj)) / 255;
    
    next_frame = double(imread(fullfile(d, sprintf ...
        ('cb%d_m.tif', cell_ID)),jj+1)) / 255;
    
    cell_outline1 = detectObjectBw(current_frame, dilationSize, erosionSize, connectivityFill);
    cell_outline2 = detectObjectBw(next_frame, dilationSize, erosionSize, connectivityFill);
    
    cell_outline = cell_outline1 .* cell_outline2;
    
    %% calculate turnover
    current_frame_filt = imgaussfilt(current_frame,16);
    next_frame_filt = imgaussfilt(next_frame,16);
    
    didt = (next_frame_filt - current_frame_filt) / dt;

    u = flow(jj).vx;
    v = flow(jj).vy;
    
    dudx = zeros(size(u));
    dvdy = zeros(size(v));
    didx = zeros(size(current_frame));
    didy = zeros(size(current_frame));
    
    for i = dy+1:dy:size(current_frame, 1)-dy
        for j = dx+1:dx:size(current_frame, 2)-dx
            dudx(i, j) = (u(i, j+dx) - u(i, j-dx)) / 2 * dx;
            dvdy(i, j) = (v(i+dy, j) - v(i-dy, j)) / 2 * dy;
            didx(i, j) = (current_frame_filt(i, j+dx) - current_frame_filt(i, j-dx)) / 2 * dx;
            didy(i, j) = (current_frame_filt(i+dy, j) - current_frame_filt(i-dy, j)) / 2 * dy;
        end
    end
    
    turnover = didt + current_frame .* (dudx + dvdy) + u .* didx + v .* didy;
    
    if dx ~= 1 || dy ~= 1
        [X0, Y0] = meshgrid(dx+1:dx:size(current_frame,2)-dx, dy+1:dy:size(current_frame, 1)-dy);
        [X, Y] = meshgrid(1:size(current_frame,2), 1:size(current_frame,2));
        turnover = turnover(dy+1:dy:size(current_frame, 1)-dy, ...
            dx+1:dx:size(current_frame, 2)-dx);
        interpolated_turnover = interp2(X0, Y0, turnover, X, Y, 'cubic');
        
    end
    
    %% calculate divergence
    div = dudx + dvdy;
    
    if dx ~= 1 || dy ~= 1
        [X0, Y0] = meshgrid(dx+1:dx:size(current_frame,2)-dx, dy+1:dy:size(current_frame, 1)-dy);
        [X, Y] = meshgrid(1:size(current_frame,2), 1:size(current_frame,1));
        div = div(dy+1:dy:size(current_frame, 1)-dy, ...
            dx+1:dx:size(current_frame, 2)-dx);
        interpolated_div = interp2(X0, Y0, div, X, Y, 'cubic');
        
    end

    %% compute values for turnover heatmap (normalised)
    disassembly = interpolated_turnover;
    disassembly = disassembly .* cell_outline;              % mask for common cell region
    
    disassembly(disassembly > 0 & cell_outline == 1) = 0;	% set positive values to 0 in the cell region
    disassembly(cell_outline == 0) = NaN;                   % set everything outside the cell region to NaN (it can be turned black for plot)
    disassembly = abs(disassembly);                         % negative to positive vals
    
    disassembly = disassembly /  max(abs(disassembly(:)));	% normalise for max values
    
    %% compute values for divergence heatmap (normalised)
    convergence = interpolated_div;
    convergence = convergence .* cell_outline;               % mask for common cell region
    
    convergence(convergence > 0 & cell_outline == 1) = 0;	% set positive values to 0 in the cell region
    convergence(cell_outline == 0) = NaN;                    % set everything outside the cell region to NaN (it can be turned black for plot)
    convergence = abs(convergence);                         % negative to positive vals
    
    convergence = convergence /  max(abs(convergence(:)));	% normalise for max values
    %% plot 
    
    subplot(1,2,2)
    title('Disassembly')
    h1 = imshow(disassembly,[]);
    colormap('jet');
    
    hold on
    
    % black background
    set(h1, 'AlphaData', ~isnan(disassembly))
    axis on;
    set(gca, 'XColor', 'none', 'yColor', 'none', 'xtick', [], 'ytick', [], 'Color', 'k')
    
    % bleach spot
    if coord_bleach(jj,1) ~= 256 && coord_bleach(jj,2) ~= 256
        if coord_bleach(jj,1) ~= 0 && coord_bleach(jj,2) ~= 0
            plot(coord_bleach(jj,1), coord_bleach(jj,2), 'wo')
        end
    end
    
    % sinks
    clear s_coord
    s_coord(:,1) = stream(jj).xf;
    s_coord(:,2) = stream(jj).yf;
    s_coord(:,3) = stream(jj).f;
    
    scatter(s_coord(:,1), s_coord(:,2), s_coord(:,3)/10, ...
        'w', 'fill', 'markeredgecolor','k');
    hold off
    
    subplot(1,2,1)
    title('Divergence')
    h2 = imshow(convergence,[]);
    colormap('jet');
    
    hold on
    
    % black background
    set(h2, 'AlphaData', ~isnan(disassembly))
    axis on;
    set(gca, 'XColor', 'none', 'yColor', 'none', 'xtick', [], 'ytick', [], 'Color', 'k')
    
    % bleach spot
    if coord_bleach(jj,1) ~= 256 && coord_bleach(jj,2) ~= 256
        if coord_bleach(jj,1) ~= 0 && coord_bleach(jj,2) ~= 0
            plot(coord_bleach(jj,1), coord_bleach(jj,2), 'wo')
        end
    end
    
    % sinks
    scatter(s_coord(:,1), s_coord(:,2), s_coord(:,3)/10, ...
        'w', 'fill', 'markeredgecolor','k');
    hold off
    
    % white image background
    set(gcf, 'InvertHardCopy', 'off');
    set(gcf, 'Color', [1 1 1]);
    
    % get current frame for save
    im_out = getframe(gcf);
    im_out = im_out.cdata;
    
    % save .tif stack
    imwrite(im_out, fullfile([d '/images'], ['bleaching_heatmap_', output_name, '.tif']), ...
        'writemode', 'append');
end
close

end