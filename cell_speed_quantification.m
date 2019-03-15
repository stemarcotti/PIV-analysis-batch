function [cell_speed, cell_speed_average] = cell_speed_quantification(directory, file, nt_index, time_int_min)

% load cell track
track = load(fullfile(directory, file));
track = track.path; % [um]
track = track(nt_index,:);  % remove intermediate frames if PIV was not run on all frames

track_diff = [diff(track(:,1)) diff(track(:,2))];       % distance between subsequent frames [um] (vect components)
track_mag = hypot(track_diff(:,1), track_diff(:,2));	% distance between subsequent frames [um] (vect magnitude)
cell_speed = track_mag ./ time_int_min;	% [um/min]

cell_speed_average = mean(cell_speed);	% [um/min]

end