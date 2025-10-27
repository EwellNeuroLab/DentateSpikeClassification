function Classify_res = DS_Classification(params, csd)

%% Step 1. Get CSD on OML MML (based on PCA)
[~, dpoints, N_ds] = size(csd);
PeakTime = round(dpoints/2);


%% Step 2. Classify DSs based on csd, then use DS1 and DS2 to get OML and MML  

% calculate CSD on the putative OML/MML channels
OML_csd = squeeze(csd(params.OML, PeakTime,:));
MML_csd = squeeze(csd(params.MML, PeakTime,:));

%classify DSs - default
Classify_res.DStype = repmat(4,N_ds,1);
Classify_res.integral = zeros(N_ds, 2);
switch params.method
   
    case "Default"

        Classify_res.DStype(OML_csd < 0 & MML_csd > 0) = 1;
        Classify_res.DStype(OML_csd > 0 & MML_csd < 0) = 2;
        Classify_res.DStype(OML_csd < 0 & MML_csd < 0) = 3;

    case "Integral"
        for i = 1:N_ds
            Classify_res.integral(i,1) = trapz(csd(params.OML, PeakTime-params.integralWin:PeakTime+params.integralWin,i));
            Classify_res.integral(i,2) = trapz(csd(params.MML, PeakTime-params.integralWin:PeakTime+params.integralWin,i));
        end

        Classify_res.DStype(Classify_res.integral(:,1) < -params.integralThresh & Classify_res.integral(:,2) > params.integralThresh) = 1;
        Classify_res.DStype(Classify_res.integral(:,2) < -params.integralThresh & Classify_res.integral(:,1) > params.integralThresh) = 2;
        Classify_res.DStype(Classify_res.integral(:,1) < -params.integralThresh & Classify_res.integral(:,2) < -params.integralThresh)= 3; 

end

%calculate mean csd for all types
Classify_res.mean_csd = cell(4,1);
for i  =1:4
    Classify_res.mean_csd{i} = mean(csd(:,:,Classify_res.DStype==i),3);
end

end