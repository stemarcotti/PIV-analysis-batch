function autocorr = autocorr_quantification(vec)

% smooth
vec = [smooth(vec(:,1),5) smooth(vec(:,2),5)];
N = length(vec);

% initialise
autocorr = 0;
lag = 0;
d = zeros(N, 1);

% slide vector to calculate auto-correlation
for n = 1:N
    for k = 1:N - lag
        A = [vec(k,1) vec(k,2)];
        B = [vec(k + lag,1) vec(k + lag,2)];
        cosvec = dot(A,B)./(norm(A).*norm(B));
        % sum cosine values
        d(n,1) = d(n,1) + cosvec;
    end
    lag = lag + 1;
    autocorr(1:length(d),1) = d(:,1) / N;
end

end