function persistence_index = persistence_quantification_walkingaverage(directory, file, nt)

% load cell track
track = load(fullfile(directory, file));
track = track.path; % [um]

persistence_index_temp = zeros(size(track,1)-nt,1);
for kk = 1:size(track,1)-nt
    
    % find start to end distance in this interval
    Ax = track(kk,1);
    Ay = track(kk,2);
    Bx = track(kk+nt-1,1);
    By = track(kk+nt-1,2);
    AtoB_distance = sqrt((Ax-Bx).^2 + (Ay-By).^2); % [um]
    
    % find track length
    track_length = 0;
    for jj = kk:kk+nt-2
        
        x1 = track(jj,1);
        y1 = track(jj,2);
        x2 = track(jj+1,1);
        y2 = track(jj+1,2);
        
        segment_length = sqrt((x1-x2).^2 + (y1-y2).^2); % [um]
        track_length = track_length + segment_length; % [um]
    end
    
    % calculate persistence index
    persistence_index_temp(kk,1) = AtoB_distance / track_length;
    
end

persistence_index = nanmean(persistence_index_temp);

end