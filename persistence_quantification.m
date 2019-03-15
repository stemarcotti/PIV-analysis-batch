function persistence_index = persistence_quantification(directory, file, nt)

% load cell track
track = load(fullfile(directory, file));
track = track.path; % [um]

% find start to end distance
Ax = track(1,1);
Ay = track(1,2);
Bx = track(nt,1);
By = track(nt,2);
AtoB_distance = sqrt((Ax-Bx).^2 + (Ay-By).^2); % [um]

% find track length
track_length = 0;
for jj = 1:nt-1
    
    x1 = track(jj,1);
    y1 = track(jj,2);
    x2 = track(jj+1,1);
    y2 = track(jj+1,2);
    
    segment_length = sqrt((x1-x2).^2 + (y1-y2).^2); % [um]
    track_length = track_length + segment_length; % [um]
end

% calculate persistence index
persistence_index = AtoB_distance / track_length;

end