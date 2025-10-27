%% function to run PCA on CSD @ DS peak 

function PCA = PCA_on_CSD(csd,chs) 
    
%% Step 1. Run PCA on CSD on
PCA = struct;
[~, dpoints, ~] = size(csd);
PeakTime = round(dpoints/2); % get data point of ds peak
PCA.in = squeeze(csd(chs, PeakTime, :)); % csd @ DS peak on selected channels (not restricted to DS channels)
[PCA.coeff,PCA.score,PCA.latent,PCA.tsquared,PCA.explained, PCA.mu] = pca(PCA.in'); % run PCA
PCA.coords = PCA.in'*PCA.coeff; % transform csd into PCA space - use the first two dimensions for clustering

%% Step 2. Run k-means in the PCA space (look for two clusters)
PCA.idx = kmeans(PCA.coords, 2);



end
