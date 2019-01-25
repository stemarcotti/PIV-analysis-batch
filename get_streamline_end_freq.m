function [x, y, f] = get_streamline_end_freq(S, M, N, dx, dy)
% Compute frequency of strealine end points within bounding boxes. 
% 
% Inputs:
%   S  = cell array containing strealines data as computed by stream2. 
%   M  = field size (in y-direction).
%   N  = field size (in x-direction). 
%   dx = bounding box side (in x-direction).
%   dy = bounding box side (in y-direction).
%
% Outputs:
%   x  = vector with the x-coordinate of the centre of each bounding box.
%   y  = vector with the y-coordinate of the centre of each bounding box. 
%   f  = frequency count for number of streamline end points for each
%        bounding box.
%
% Created by A. Luchici, luchici.andrei@gmail.com, 07/12/2015.

% Extract position where each streamline ends.
stream_ends = zeros(length(S), 2);
for i = 1:length(S)
    stream_tmp = S{i};
    stream_ends(i, :) = stream_tmp(end, :);
end

% Define upper-left corner of each bounding box.
box_x0 = 1:dx:N;
box_y0 = 1:dy:M;

% Initialize output.
f = zeros(length(box_x0) * length(box_y0), 1);
x = zeros(length(box_x0) * length(box_y0), 1);
y = zeros(length(box_x0) * length(box_y0), 1);

% Find number of streamlines ending in each bounding bo x.
k = 1;
for i = 1:length(box_y0)
    for j = 1:length(box_x0)
        % Find the diference between x-coordinate of current bounding box
        % and x-coordinate of streamline endpoints.
        diffx = abs(stream_ends(:, 1) - (box_x0(j) + dx/2));
        
        % Find the diference between y-coordinate of current bounding box
        % and y-coordinate of streamline endpoints.
        diffy = abs(stream_ends(:, 2) - (box_y0(i) + dy/2));
        
        % Find how many streamline endpoints fall within the current
        % bounding box.
        f(k,1) = length(find(diffx <= dx/2 & diffy <= dy/2));
        
        % Record coordinate of the centre of the current bounding box. This
        % will be used to display streamline frequency.
        x(k,1) = box_x0(j) + dx/2;
        y(k,1) = box_y0(i) + dy/2;
        
        % Update bounding box counter
        k = k + 1;
    end
end