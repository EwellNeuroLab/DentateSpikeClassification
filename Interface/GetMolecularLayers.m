% function to cluster DSs in PC space

function [Estimation, clust_idx] = GetMolecularLayers(csd, idx, detection_channel)

[N_channel, dpoints, ~] = size(csd);
PeakTime = round(dpoints/2); % get data point of ds peak
mean_CSD = cell(2,1);
%% Step 3. Average csd for the two clusters and detect sinks between GCL and top of the shank (upper blade)

for i =1:2
    mean_CSD{i} = mean(csd(:,:,idx==i),3);
end

 ML = zeros(2,1);

for i = 1:2
 
    
 [TF, P] = islocalmin(mean_CSD{i}(detection_channel:N_channel-1,PeakTime)); 
 loc= find(TF ==1);
 pks = P(loc);

 loc(pks < 0.001) = [];
 pks(pks < 0.001) = [];
if length(loc) > 1
    [~,midx] = max(pks);
    ML(i) = loc(midx);
else
    ML(i) = loc;
end
end
%[~,ML(1)] = min(mean_CSD{1}(detection_channel:N_channel-1,PeakTime)); % get biggest sink from hilus to top of shank - exclude top channel to avoid artefacts
%[~,ML(2)] = min(mean_CSD{2}(detection_channel:N_channel-1,PeakTime));

Estimation.mean_CSD = cell(2,1);
%decide which one is the MML/OML
if ML(1) > ML(2)
    Estimation.OML = ML(1);
    Estimation.MML= ML(2);
    clust_idx = idx; % assignment does not need to be changed
    Estimation.mean_CSD = mean_CSD;
elseif ML(2) > ML(1)
    Estimation.OML = ML(2);
    Estimation.MML= ML(1);
    clust_idx(idx==1) = 2;% swap idx values
    clust_idx(idx==2) = 1;
    Estimation.mean_CSD{2} = mean_CSD{1};
    Estimation.mean_CSD{1} = mean_CSD{2};
else
    disp("Peaks detected at the same location!")
    Estimation.OML = ML(1);
    Estimation.MML = ML(2);
    clust_idx = idx;
    Estimation.mean_CSD = mean_CSD;
end

Estimation.OML = Estimation.OML+detection_channel-1;
Estimation.MML = Estimation.MML+detection_channel-1;



end