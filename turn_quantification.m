function [turnover, turnover_average] = turn_quantification(directory, file, d, cell_ID)

dilationSize = 4;
erosionSize = 12;
connectivityFill = 4;
dt = 5;
dx = 5;
dy = 5;

% load interpolated field
flow = load (fullfile(directory, file));
flow = flow.vfilt;

nt = length(flow);

% initialise output vector
turnover = zeros(nt-1, 1);

for jj = 1:nt-1
    
    % load current and next frame
    currentFrame = double(imread(fullfile(d, sprintf ...
        ('cb%d_m.tif', cell_ID)),jj)) / 255;
    
    nextFrame = double(imread(fullfile(d, sprintf ...
        ('cb%d_m.tif', cell_ID)),jj+1)) / 255;
    
    % compute d(intensity)/d(t)
    didt = (nextFrame - currentFrame) / dt;
    
    % find didx, didy, dudx, dvdy
    u = flow(jj).vx;
    v = flow(jj).vy;
    
    dudx = zeros(size(u));
    dvdy = zeros(size(v));
    didx = zeros(size(currentFrame));
    didy = zeros(size(currentFrame));
    
    for i = dy+1:dy:size(currentFrame, 1)-dy
        for j = dx+1:dx:size(currentFrame, 2)-dx
            dudx(i, j) = (u(i, j+dx) - u(i, j-dx)) / 2 * dx;
            dvdy(i, j) = (v(i+dy, j) - v(i-dy, j)) / 2 * dy;
            didx(i, j) = (currentFrame(i, j+dx) - currentFrame(i, j-dx)) / 2 * dx;
            didy(i, j) = (currentFrame(i+dy, j) - currentFrame(i-dy, j)) / 2 * dy;
        end
    end
    
    % compute net turnover
    net_turnover = didt + currentFrame .* (dudx + dvdy) + u .* didx + v .* didy;
        
    % interpolate net turnover to cover the full outline
    if dx ~= 1 || dy ~= 1
        [X0, Y0] = meshgrid(dx+1:dx:size(currentFrame,2)-dx, dy+1:dy:size(currentFrame, 1)-dy);
        [X, Y] = meshgrid(1:size(currentFrame,2), 1:size(currentFrame,2));
        net_turnover = net_turnover(dy+1:dy:size(currentFrame, 1)-dy, ...
            dx+1:dx:size(currentFrame, 2)-dx);
        interpolatedTurnover = interp2(X0, Y0, net_turnover, X, Y, 'cubic');
        
    end
    
    % find intersection
    cellOutline1 = detectObjectBw(currentFrame, dilationSize, erosionSize, connectivityFill);
    cellOutline2 = detectObjectBw(nextFrame, dilationSize, erosionSize, connectivityFill);
    cellOutline = cellOutline1 .* cellOutline2;
    cellOutline(cellOutline==0)=NaN;
    
    turnover_mask = interpolatedTurnover .* cellOutline;
    
    % remove cell body if present
    file_name = [d, '/', sprintf('no_cb%d_m.tif', cell_ID)];
    if exist(file_name, 'file') == 2
        
        no_cb_frame = double(imread(fullfile(file_name),jj)) / 255;
        lim = logical(no_cb_frame);
        
        turnover_mask = turnover_mask .* lim;   % remove cell body if no_cb exists
        turnover_mask(lim == 0) = NaN;
    end
    
    % save mean flow velocity [um/min]
    turnover(jj,1) = nanmean(turnover_mask, 'all');
    
end

% average across all frames [um/min]
turnover_average = mean(turnover);

end