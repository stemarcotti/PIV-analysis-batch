function [cell_area, cell_area_average] = area_quantification(directory, file, d, cell_ID, mu2px)

% load interpolated field
flow = load (fullfile(directory, file));
flow = flow.vfilt;

nt = length(flow);

% initialise output vector
cell_area = zeros(nt, 1);

for jj = 1:nt
    
    % load current and next frame
    currentFrame = double(imread(fullfile(d, sprintf ...
        ('cb%d_m.tif', cell_ID)),jj)) / 255;
    
    nonzero_px = find(currentFrame ~= currentFrame(1,1));
    area_px = mu2px.^2;
    cell_area(jj,1) = size(nonzero_px,1) * area_px; % [um2]
    
end

% average across all frames [um/min]
cell_area_average = mean(cell_area);

end