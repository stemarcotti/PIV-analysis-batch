function [f_percent, average_f_percent] = streamlines_sinks(directory, file)

% load streamline end points
stream = load (fullfile (directory, file));
stream = stream.stream_end_pts;

% get number of frames of the movie
nt = length(stream);

% percentage of streamlines at sinks
f_percent = zeros(nt,3);
for k = 1:nt
    
    % find max 3 sinks by sorting frequency field
    stream_f = stream(k).f(:);
    [stream_f_sorted, ~] = sort(stream_f, 'descend');
    
    if length(stream_f) >= 3
        
        % highest frequency of streamlines at an end point
        f1 = stream_f_sorted(1,1);
        f2 = stream_f_sorted(2,1);
        f3 = stream_f_sorted(3,1);
        
        % sum of all streamlines at all end points
        f_sum = sum(stream(k).f(:));
        
        f_percent(k,1) = f1/f_sum * 100;
        f_percent(k,2) = f2/f_sum * 100;
        f_percent(k,3) = f3/f_sum * 100;
        
    elseif length(stream_f) == 2
        
        % highest frequency of streamlines at an end point
        f1 = stream_f_sorted(1,1);
        f2 = stream_f_sorted(2,1);
        
        % sum of all streamlines at all end points
        f_sum = sum(stream(k).f(:));
        
        f_percent(k,1) = f1/f_sum * 100;
        f_percent(k,2) = f2/f_sum * 100;
        
    elseif length(stream_f) == 1
        
        % highest frequency of streamlines at an end point
        f1 = stream_f_sorted(1,1);
        
        % sum of all streamlines at all end points
        f_sum = sum(stream(k).f(:));
        
        f_percent(k,1) = f1/f_sum * 100;
       
    end
    
    clear f1 f2 f3
    clear stream_f
    
end

average_f_percent = nanmean(f_percent);

end