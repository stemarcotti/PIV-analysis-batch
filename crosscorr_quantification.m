function [corr1, corr2, lagstore] = crosscorr_quantification(vec1, vec2)

% smooth
vec1 = [smooth(vec1(:,1),3) smooth(vec1(:,2),3)];
vec2 = [smooth(vec2(:,1),3) smooth(vec2(:,2),3)];
N = length(vec1);

% initialise
d1 = zeros(N, 1);
d2 = zeros(N, 1);
lagstore = zeros(N, 1);
lag = 0;
corr1 = 0;
corr2 = 0;

% slide vector to calculate auto-correlation
for n = 1:N
    for k = 1:N - lag
        A1 = vec1(k,:);
        B1 = vec2(k+lag,:);
        
        A2 = vec1(k+lag,:);
        B2 = vec2(k,:);

        cosvec1 = dot(A1,B1)./(norm(A1).*norm(B1));
        cosvec2 = dot(A2,B2)./(norm(A2).*norm(B2));
        % sum cosine values
        d1(n,1) = d1(n,1) + cosvec1;
        d2(n,1) = d2(n,1) + cosvec2;
    end
    lagstore(n,1) = lag;
    lag = lag + 1;
    corr1(1:length(d1),1) = d1(:,1) / N;
    corr2(1:length(d2),1) = d2(:,1) / N;
end

end
