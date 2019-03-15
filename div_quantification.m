function [diverg, diverg_average] = div_quantification(directory, file, d, cell_ID)
% function [diverg, diverg_average, diverg_all] = div_quantification(directory, file, d, cell_ID)

dilationSize = 4;
erosionSize = 12;
connectivityFill = 4;

% load interpolated field
flow = load (fullfile(directory, file));
flow = flow.vfilt;

nt = length(flow);

% initialise output vector
diverg = zeros(nt-1, 1);
% diverg_all = [];

for jj = 1:nt-1
    
    % load current and next frame
    currentFrame = double(imread(fullfile(d, sprintf ...
        ('cb%d_m.tif', cell_ID)),jj)) / 255;
    
    nextFrame = double(imread(fullfile(d, sprintf ...
        ('cb%d_m.tif', cell_ID)),jj+1)) / 255;
    
    % calculate divergence
    u = flow(jj).vx;
    v = flow(jj).vy;
    
    div = divergence(u,v);
    
    % find intersection
    cellOutline1 = detectObjectBw(currentFrame, dilationSize, erosionSize, connectivityFill);
    cellOutline2 = detectObjectBw(nextFrame, dilationSize, erosionSize, connectivityFill);
    cellOutline = cellOutline1 .* cellOutline2;
    cellOutline(cellOutline==0) = NaN;
    
    div_mask = div .* cellOutline;
    
    % remove cell body if present
    file_name = [d, '/', sprintf('no_cb%d_m.tif', cell_ID)];
    if exist(file_name, 'file') == 2
        
        no_cb_frame = double(imread(fullfile(file_name),jj)) / 255;
        lim = logical(no_cb_frame);
        
        div_mask = div_mask .* lim;   % remove cell body if no_cb exists
        div_mask(lim == 0) = NaN;
    end
    
%     % save all divergence vectors [A.U.]
%     diverg_all_temp = div_mask(:);
%     diverg_all_temp = diverg_all_temp(~isnan(diverg_all_temp)); % remove NaNs
%     diverg_all = [diverg_all; diverg_all_temp];
    
    % save mean divergence [A.U.]
    diverg(jj,1) = nanmean(div_mask, 'all');
    
%     clear diverg_all_temp
end

% average across all frames [A.U.]
diverg_average = mean(diverg);

end