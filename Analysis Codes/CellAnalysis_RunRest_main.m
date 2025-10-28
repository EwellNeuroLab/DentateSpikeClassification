%% main script to analyze and visualize cell recruitment (Fig 3)

% load data
rootdir = "H:\Data_to_publish\"; % changed this fo
ewell = load(strcat(rootdir,"CellTable_Ewell.mat"));
swil = load(strcat(rootdir, "CellTable_SWIL.mat");


z_thresh = 2.58;
IsActive_ewell =ewell.CellTable.Activation_RUN_z > z_thresh;
IsActive_swil = swil.CellTable.Activation_RUN_z > z_thresh;

CellTable = [ewell.CellTable; swil.CellTable];

pooled_QW = cat(1, ewell.DS_PETH, swil.pooled_rest);
pooled_RUN = cat(1, ewell.DS_PETH_run, swil.pooled_run);

%% Plot cell modulation maps for the 3 DS types in QW and RUN respectively
plotWin = 50;
lims = [-2 4];
figure
tiledlayout(2,3)

for i = 1:3
    nexttile;
    PlotHeatMaps(pooled_QW(:,:,i), plotWin, lims)
end

for i = 1:3
    nexttile;
    PlotHeatMaps(pooled_RUN(:,:,i), plotWin, lims)
end

%% 3d plot of recruitment & pie charts
figure
tiledlayout(1,3)
nexttile;
plot3(CellTable.Activation_QW_z(:,1), CellTable.Activation_QW_z(:,2), CellTable.Activation_QW_z(:,3), 'ko', MarkerFaceColor= 'k', MarkerSize=2)
box off
axis square
xlabel("DS_1 peak rate (z)")
ylabel("DS_2 peak rate (z)")
zlabel("DS_3 peak rate (z)")
xlim([-1 10])
ylim([-1 10])
zlim([-1 10])
grid on
hold on
[X,Y] = meshgrid(-1:10, -1:10);
color_vec = [.25 .25 .25].*3;

F = repmat(z_thresh, length(X), length(Y));
surf(X,Y,F, FaceAlpha=0.5, FaceColor=color_vec ,EdgeColor='none')

F = repmat(z_thresh, length(X), length(Y));
surf(X,F,Y, FaceAlpha=0.5, FaceColor=color_vec,EdgeColor='none')

F = repmat(z_thresh, length(X), length(Y));
surf(F,X,Y, FaceAlpha=0.5, FaceColor=color_vec,EdgeColor='none')


boolean_activity = CellTable.Activation_QW_z > z_thresh;
isActive = sum(boolean_activity,2) > 0;
nexttile;
piechart([sum(isActive) sum(~isActive)], {"Actived", "Non-activated"})

onlyDS1 = length(find(boolean_activity(:,1) == 1 & boolean_activity(:,2) == 0 & boolean_activity(:,3) == 0));
onlyDS2 = length(find(boolean_activity(:,1) == 0 & boolean_activity(:,2) == 1 & boolean_activity(:,3) == 0));
onlyDS3 = length(find(boolean_activity(:,1) == 0 & boolean_activity(:,2) == 0 & boolean_activity(:,3) == 1));
DS1DS2 = length(find(boolean_activity(:,1) == 1 & boolean_activity(:,2) == 1 & boolean_activity(:,3) == 0));
DS1DS3 = length(find(boolean_activity(:,1) == 1 & boolean_activity(:,2) == 0 & boolean_activity(:,3) == 1));
DS2DS3 = length(find(boolean_activity(:,1) == 0 & boolean_activity(:,2) == 0 & boolean_activity(:,3) == 1));
all = sum(sum(boolean_activity,2) == 3);

nexttile;
labels = {"DS3", "DS1","DS2",  "DS1&3", "DS2&3", "DS1&2", "DS1&2&3"};
piechart([onlyDS3 onlyDS1 onlyDS2 DS1DS3 DS2DS3 DS1DS2 all], labels)


%% visualize % of cells recruited in RUN/REST
labels = {"Pyramidal Cell" , "Narrow Interneuron"};
figure
tiledlayout(1,2)

for i = 1:2
idx = find(CellTable.CellType == labels{i} );


isActive_QW = isActive;
isActive_RUN = sum((CellTable.Activation_RUN_z > z_thresh)>0, 2);
onlyRest(:,i) = sum(isActive_QW(idx) > 0 & isActive_RUN(idx) == 0);
onlyRun(:,i) = sum(isActive_QW(idx) == 0 & isActive_RUN(idx) >0);
both(:,i) = sum(isActive_QW(idx) >0 & isActive_RUN(idx) >0);
none(:,i) = sum(isActive_QW(idx)== 0 & isActive_RUN(idx) == 0);
nexttile;
piechart([onlyRest(:,i) onlyRun(:,i) both(:,i) none(:,i)], {"rest", "run", "both", "none"})
title(labels(i))
end

%% visualize DStype x Celltype relationship (significant interaction term)
ordered_rest = [];
ordered_run = []; 
celltype_labels = {"Pyramidal Cell" ; "Narrow Interneuron"};

for i = 1:2
    sub_idx = find(CellTable.CellType == celltype_labels{i}); 
    subset_mat = CellTable.Activation_QW_z(sub_idx,:);
    D = pdist(subset_mat, 'euclidean');   % pairwise distances between rows
    Z = linkage(D, 'average');  % hierarchical clustering, 'average' linkage
    order = optimalleaforder(Z, D);   % order rows to minimize distance between neighbors
    ordered_rest = [ordered_rest ; subset_mat(order,:)];
end

figure
tiledlayout(1,2)
nexttile;
imagesc(ordered_rest)
hold on
yline(45.5, 'm--', LineWidth=2)
colorbar
clim([-2 6])
colormap bone
xticks(1:3)
xticklabels({'DS1', 'DS2', 'DS3'})
title("REST")


%% visualize cell type x ds type interaction with violinplots only
PC = find(CellTable.CellType == "Pyramidal Cell");
IN = find(CellTable.CellType == "Narrow Interneuron");
data = [];

for i = 1:3
    group1 = CellTable.Activation_QW_z(PC,i); 
    group2 = [CellTable.Activation_QW_z(IN,i); nan(length(PC)-length(IN),1)];
    data = cat(2,data,[group1, group2]);%; CellTable.Activation_QW_z(PC,2);  CellTable.Activation_QW_z(IN,2);  CellTable.Activation_QW_z(PC,3);  CellTable.Activation_QW_z(IN,3)];
end
% Create violin plot
figure
violinplot(data)
hold on
for i = 1:6
    plot([i-0.2 i+0.2], [median(data(:,i),'omitnan'), median(data(:,i),'omitnan')], 'k-' )
end
xlabel('Group'); ylabel('Value');

%% visualize cell type x ds type interaction in RUN
data_run = [];

for i = 1:3
    group1 = CellTable.Activation_RUN_z(PC,i); 
    group2 = [CellTable.Activation_RUN_z(IN,i); nan(length(PC)-length(IN),1)];
    data_run = cat(2,data_run,[group1, group2]);%; CellTable.Activation_QW_z(PC,2);  CellTable.Activation_QW_z(IN,2);  CellTable.Activation_QW_z(PC,3);  CellTable.Activation_QW_z(IN,3)];
end
% Create violin plot
figure
violinplot(data_run)
hold on
for i = 1:6
    plot([i-0.2 i+0.2], [median(data_run(:,i),'omitnan'), median(data_run(:,i),'omitnan')], 'k-' )
end
xlabel('Group'); ylabel('Value');
ylim([-4 12])

%% visualize cell type x state for each DS type
figure
tiledlayout(1,3)

for i = 1:3
    nexttile;
    group1 = CellTable.Activation_QW_z(PC,i);
    group2 = CellTable.Activation_RUN_z(PC,i);
    group3 = [CellTable.Activation_QW_z(IN,i) ; nan(length(PC)-length(IN),1)];
    group4 = [CellTable.Activation_RUN_z(IN,i) ; nan(length(PC)-length(IN),1)];

    data_sub = [group1, group2, group3, group4];
    violinplot(data_sub)
    hold on
    for j = 1:4
        plot([j-0.2 j+0.2], [median(data_sub(:,j),'omitnan'), median(data_sub(:,j),'omitnan')], 'k-' )
    end

    xticklabels({"PC QW", "PC RUN", "IN QW", "IN RUN"})
    title(strcat("DS ", num2str(i)))

end

%% plot cell recruitment during running for freely moving and head-fixed respectively
figure

for i  = 1:3
    nexttile;
    group1 = [CellTable.Activation_RUN_z(1:119,i); nan(24,1)];
    group2 = CellTable.Activation_RUN_z(120:end,i);
    data_cohorts = [group1, group2];
    [p_cohort(i), ~,stat_cohort{i}] =  ranksum(CellTable.Activation_RUN_z(1:119,i), CellTable.Activation_RUN_z(120:end,i));
    violinplot(data_cohorts)
    hold on
    for j = 1:2
        plot([j-0.2 j+0.2], [median(data_cohorts(:,j),'omitnan'), median(data_cohorts(:,j),'omitnan')], 'k-' )
    end
    ylim([-4 10])
    title(strcat("DS ", num2str(i)))
end
p_cohort = p_cohort.*3;



%% linear-mixed effect model on celltype, dstype, state
% build T first: 4 cell types, 3 DS types, 2 behavioral states
FR = [];
CellType = [];
DStype = [];
State = [];
CellID = [];

for i = 1:3
    FR = [FR; CellTable.Activation_QW_z(:,i)];
    CellType = [CellType; CellTable.CellType];
    DStype = [DStype; ones(length(CellTable.CellType),1)*i];
    State = [State; ones(length(CellTable.CellType),1)];
    CellID = [CellID; transpose(1:length(CellTable.CellType))];
end


for i = 1:3
    FR = [FR; CellTable.Activation_RUN_z(:,i)];
    CellType = [CellType; CellTable.CellType];
    DStype = [DStype; ones(length(CellTable.CellType),1)*i];
    State = [State; ones(length(CellTable.CellType),1)+1];
    CellID = [CellID; transpose(1:length(CellTable.CellType))];
end

CellType = categorical(CellType);
DStype = categorical(DStype, 1:3, {'DS1','DS2','DS3'});
State = categorical(State, 1:2, {'QW','RUN'});

T = table(FR, CellType, DStype, State, CellID, ...
    'VariableNames', {'FiringRate','CellType','DStype','State','CellID'});

%% Linear mixed-effects model for each cell tpye
lme = fitlme(T, 'FiringRate ~ CellType*DStype*State + (1|CellID)' );


% values reported in the paper  can be found in lme.Coefficients

% View ANOVA results
anova_tbl = anova(lme);


% use simplified model excluding brain state - dont use this because
% compare gives significant difference
lme_reduced = fitlme(T, 'FiringRate ~ CellType*DStype + State + (1|CellID)' );
compare(lme,lme_reduced);


%% build contrast vector for each comparison - focusing on cell type x ds type as that had significant interaction term
N_comp = 24;
comparison = cell(N_comp,1);
C = zeros(N_comp, numel(lme.CoefficientNames));
p = nan(N_comp,1);
F = nan(N_comp,1);
df1 = nan(N_comp,1);
df2 = nan(N_comp,1);

% Comparison 1. DS2 vs DS1 in INs. Note: baseline in lme is IN-DS1-QW
% DS2 - DS1 = Intercept + beta_DS2 - Intercept = beta_DS2
n= 1;
comparison{n}= 'DS2 vs DS1 (INs)';
C(n,strcmp(lme.CoefficientNames,'DStype_DS2')) = 1;
[p(n),F(n),df1(n),df2(n)] = coefTest(lme,  C(n,:));

% Comparison 2. DS3 vs DS1 in INs.
% DS3-DS1 = beta_DS3
n= 2;
comparison{n}= 'DS3 vs DS1 (INs)';
C(n,strcmp(lme.CoefficientNames,'DStype_DS3')) = 1;
[p(n),F(n),df1(n),df2(n)]  = coefTest(lme, C(n,:));

% Comparison 3. DS2 vs DS3 in INs. Negative value appears when two
% non-baseline conditions are compared
% DS3-DS2 = beta_DS3 - beta_DS2
n = 3;
comparison{n} = 'DS2 vs DS3 (INs)';
C(n,strcmp(lme.CoefficientNames,'DStype_DS3')) = 1;
C(n,strcmp(lme.CoefficientNames,'DStype_DS2')) = -1;
[p(n),F(n),df1(n),df2(n)]  = coefTest(lme, C(n,:));

% Comparison 4. DS1 vs DS2 in PCs. Since PCs are not the baselin group,
% interaction terms need to be included
% DS2-DS1 = Intercept + PC+DS2 + PC:DS2 - Intercept + PC = beta_DS2 +
% beta_PC:DS2 (the term of PC cancels each other)
n = 4;
comparison{n} = 'DS1 vs DS2 (PCs)';
C(n,strcmp(lme.CoefficientNames,'DStype_DS2')) = 1;
C(n,strcmp(lme.CoefficientNames,'CellType_Pyramidal Cell:DStype_DS2')) = 1;
[p(n),F(n),df1(n),df2(n)]  = coefTest(lme, C(n,:));

% Comparison 5. DS1 vs DS3 in PCs.
%DS3-DS1 = beta_DS2+beta_PC:DS3
n = 5;
comparison{n} = 'DS1 vs DS3 (PCs)';
C(n,strcmp(lme.CoefficientNames,'DStype_DS3')) = 1;
C(n,strcmp(lme.CoefficientNames,'CellType_Pyramidal Cell:DStype_DS3')) = 1;
[p(n),F(n),df1(n),df2(n)]  = coefTest(lme, C(n,:));


% Comparison 6. DS2 vs DS3 in PCs
% DS3-DS2 = Intercept+PC+DS3+PC:DS3 -(Intercept+PC+DS2+PC:DS2) =
%  = DS3+PC:DS3 - DS2 - PC:DS2
n = 6;
comparison{n} = 'DS2 vs DS3 (PCs)';
C(n,strcmp(lme.CoefficientNames,'DStype_DS3')) = 1;
C(n,strcmp(lme.CoefficientNames,'CellType_Pyramidal Cell:DStype_DS3')) = 1;
C(n,strcmp(lme.CoefficientNames,'DStype_DS2')) = -1;
C(n,strcmp(lme.CoefficientNames,'CellType_Pyramidal Cell:DStype_DS2')) = -1;
[p(n),F(n),df1(n),df2(n)]  = coefTest(lme, C(n,:));

% Comparison 7. PC vs IN in DS1.
% PC1-IN1 = Intercept + PC - Intercept = PC
n = 7;
comparison{n} = 'IN vs PC (DS1)';
C(n,strcmp(lme.CoefficientNames,'CellType_Pyramidal Cell')) = 1;
[p(n),F(n),df1(n),df2(n)]  = coefTest(lme, C(n,:));


% Comparison 8. PC vs IN in DS2
% PC2IN2 = Intercept + PC + DS2 + PC:DS2 - (Intercept+ DS2) = 
% = PC+PC:DS2 
n = 8;
comparison{n} = 'IN vs PC (DS2)';
C(n,strcmp(lme.CoefficientNames,'CellType_Pyramidal Cell')) = 1;
C(n,strcmp(lme.CoefficientNames,'CellType_Pyramidal Cell:DStype_DS2')) = 1;
[p(n),F(n),df1(n),df2(n)]  = coefTest(lme, C(n,:));


% Comparison 9. PC vs IN in DS3
% PC3-IN3 = PC+PC:DS3
n = 9;
comparison{n} = 'IN vs PC (DS3)';
C(n,strcmp(lme.CoefficientNames,'CellType_Pyramidal Cell')) = 1;
C(n,strcmp(lme.CoefficientNames,'CellType_Pyramidal Cell:DStype_DS3')) = 1;
[p(n),F(n),df1(n),df2(n)]  = coefTest(lme, C(n,:));


% Comparison 10. QW vs RUN in INs in DS1
% RUN_IN - QW_IN = Intercept - (RUN + Intercept) =  RUN
n = 10;
comparison{n} = 'QW vs RUN (IN DS1)';
C(n,strcmp(lme.CoefficientNames,'State_RUN')) = 1;
[p(n),F(n),df1(n),df2(n)]  = coefTest(lme, C(n,:));

% Comparison 11. QW vs RUN in PCs in DS1
% RUN_PC - QW_PC = (Intercept + CellType_PC + State_RUN + PC:RUN) -
% (Intercept+CellType_PC) = State_RUN + PC:RUN
n = 11;
comparison{n} = 'QW vs RUN (PC DS1)'; 
C(n,strcmp(lme.CoefficientNames,'State_RUN')) = 1;
C(n,strcmp(lme.CoefficientNames,'CellType_Pyramidal Cell:State_RUN')) = 1;
[p(n),F(n),df1(n),df2(n)]  = coefTest(lme, C(n,:));

% Comparison 12. QW vs RUN in INs for DS2
% RUN_IN - QW_IN = (Intercept + DS2 + RUN + RUN:DS2)  - (Intercept + DS2)
% = RUN + RUN:DS2
n = 12;
comparison{n} = 'QW vs RUN (IN DS2)';
C(n,strcmp(lme.CoefficientNames,'State_RUN')) = 1;
C(n,strcmp(lme.CoefficientNames,'DStype_DS2:State_RUN')) = 1;
[p(n),F(n),df1(n),df2(n)]  = coefTest(lme, C(n,:));

% Comparison 13. QW vs RUN in PCs for DS2
% RUN_PC - QW_PC = (Intercept + PC + DS2 + RUN + PC:RUN + RUN:DS2+ PC:DS2:RUN)
% - (Intercept + PC + DS2 + PC:DS2) = RUN + PC:RUN + RUN:DS2 + PC:DS2:RUN
% 
n = 13;
comparison{n} = 'QW vs RUN (PC DS2)';
C(n,strcmp(lme.CoefficientNames,'State_RUN')) = 1;
C(n,strcmp(lme.CoefficientNames,'CellType_Pyramidal Cell:State_RUN')) = 1;
C(n,strcmp(lme.CoefficientNames,'DStype_DS2:State_RUN')) = 1;
C(n,strcmp(lme.CoefficientNames,'CellType_Pyramidal Cell:DStype_DS2:State_RUN')) = 1;
[p(n),F(n),df1(n),df2(n)]  = coefTest(lme, C(n,:));

% Comparison 14. QW vs RUN in INs for DS2
% RUN_IN - QW_IN = (Intercept + DS3 + RUN + RUN:DS3)  - (Intercept + DS3)
% = RUN + RUN:DS3
n = 14;
comparison{n} = 'QW vs RUN (IN DS3)';
C(n,strcmp(lme.CoefficientNames,'State_RUN')) = 1;
C(n,strcmp(lme.CoefficientNames,'DStype_DS3:State_RUN')) = 1;
[p(n),F(n),df1(n),df2(n)]  = coefTest(lme, C(n,:));


% Comparison 15. QW vs RUN in PCs for DS3
% RUN_PC - QW_PC = (Intercept + PC + DS3 + RUN + PC:RUN + RUN:DS3+ PC:DS3:RUN)
% - (Intercept + PC + DS3 + PC:DS3) = RUN + PC:RUN + RUN:DS3 + PC:DS3:RUN
% 
n = 15;
comparison{n} = 'QW vs RUN (PC DS3)';
C(n,strcmp(lme.CoefficientNames,'State_RUN')) = 1;
C(n,strcmp(lme.CoefficientNames,'CellType_Pyramidal Cell:State_RUN')) = 1;
C(n,strcmp(lme.CoefficientNames,'DStype_DS3:State_RUN')) = 1;
C(n,strcmp(lme.CoefficientNames,'CellType_Pyramidal Cell:DStype_DS3:State_RUN')) = 1;
[p(n),F(n),df1(n),df2(n)]  = coefTest(lme, C(n,:));



% Comparison 16. DS2 vs DS1 for INs (DS1 is baseline)
% DS2_IN-DS1_IN = (Intercept + RUN + DS2 + DS2:RUN) - (Intercept + RUN) =
% = DS2 + DS2:RUN
n = 16;
comparison{n} = 'DS 2 vs DS1 (IN RUN)';
C(n,strcmp(lme.CoefficientNames,'DStype_DS2')) = 1;
C(n,strcmp(lme.CoefficientNames,'DStype_DS2:State_RUN')) = 1;
[p(n),F(n),df1(n),df2(n)]  = coefTest(lme, C(n,:));

% Comparison 17. DS3 vs DS1 for INs (DS1 is baseline)
% DS3_IN-DS1_IN = (Intercept + RUN + DS3 + DS3:RUN) - (Intercept + RUN) =
% = DS3 + DS3:RUN
n = 17;
comparison{n} = 'DS 3 vs DS1 (IN RUN)';
C(n,strcmp(lme.CoefficientNames,'DStype_DS3')) = 1;
C(n,strcmp(lme.CoefficientNames,'DStype_DS3:State_RUN')) = 1;
[p(n),F(n),df1(n),df2(n)]  = coefTest(lme, C(n,:));


% Comparison 18. DS2 vs DS3 for INs (DS1 is baseline)
% DS3_IN-DS2_IN = (Intercept + RUN + DS3 + DS3:RUN) - (Intercept + RUN +DS2 +DS2:RUN) =
% = DS3 + DS3:RUN - DS2 - DS2:RUN
n = 18;
comparison{n} = 'DS 2 vs DS3 (IN RUN)';
C(n,strcmp(lme.CoefficientNames,'DStype_DS3')) = 1;
C(n,strcmp(lme.CoefficientNames,'DStype_DS3:State_RUN')) = 1;
C(n,strcmp(lme.CoefficientNames,'DStype_DS2')) = -1;
C(n,strcmp(lme.CoefficientNames,'DStype_DS2:State_RUN')) = -1;
[p(n),F(n),df1(n),df2(n)]  = coefTest(lme, C(n,:));


% Comparison 19. DS1 vs DS2 for PCs (DS1 is baseline)
% DS2 - DS1 = (Intercept + PC + DS2 + RUN + PC:DS2 + PC:RUN + DS2:RUN +
% DS2:RUN:PC) - (Intercept + RUN + PC + PC:RUN) = DS2+ PC:DS2 + DS2:RUN+ DS2:RUN:PC 
n = 19;
comparison{n} = 'DS 1 vs DS2 (PC RUN)';
C(n,strcmp(lme.CoefficientNames,'DStype_DS2')) = 1;
C(n,strcmp(lme.CoefficientNames,'DStype_DS2:State_RUN')) = 1;
C(n,strcmp(lme.CoefficientNames,'CellType_Pyramidal Cell:DStype_DS2')) = 1;
C(n,strcmp(lme.CoefficientNames,'CellType_Pyramidal Cell:DStype_DS2:State_RUN')) = 1;
[p(n),F(n),df1(n),df2(n)]  = coefTest(lme, C(n,:));

% Comparison 20. DS1 vs DS3 for PCs (DS1 is baseline)
% DS3 - DS1 = (Intercept + PC + DS3 + RUN + PC:DS3 + PC:RUN + DS3:RUN +
% DS3:RUN:PC) - (Intercept + RUN + PC + PC:RUN) = DS3+ PC:DS3 + DS3:RUN+ DS3:RUN:PC 
n = 20;
comparison{n} = 'DS 1 vs DS3(PC RUN)';
C(n,strcmp(lme.CoefficientNames,'DStype_DS3')) = 1;
C(n,strcmp(lme.CoefficientNames,'DStype_DS3:State_RUN')) = 1;
C(n,strcmp(lme.CoefficientNames,'CellType_Pyramidal Cell:DStype_DS3')) = 1;
C(n,strcmp(lme.CoefficientNames,'CellType_Pyramidal Cell:DStype_DS3:State_RUN')) = 1;

[p(n),F(n),df1(n),df2(n)]  = coefTest(lme, C(n,:));



% Comparison 21. DS2 vs DS3 for PCs 
% DS3 - DS2 = (Intercept + PC + DS3 + RUN + PC:DS3 + PC:RUN + DS3:RUN +
% DS3:RUN:PC) - (Intercept + PC + DS2 + RUN + PC:DS2 + PC:RUN + DS2:RUN +
% DS2:RUN:PC) = DS3 + PC:DS3 + DS3:RUN + DS3:RUN:PC - DS2 - PC:DS2 -
% DS2_RUN - DS2:RUN:PC
n = 21;
comparison{n} = 'DS 2 vs DS3(PC RUN)';
C(n,strcmp(lme.CoefficientNames,'DStype_DS3')) = 1;
C(n,strcmp(lme.CoefficientNames,'CellType_Pyramidal Cell:DStype_DS3')) = 1;
C(n,strcmp(lme.CoefficientNames,'DStype_DS3:State_RUN')) = 1;
C(n,strcmp(lme.CoefficientNames,'CellType_Pyramidal Cell:DStype_DS3:State_RUN')) = 1;

C(n,strcmp(lme.CoefficientNames,'DStype_DS2')) = -1;
C(n,strcmp(lme.CoefficientNames,'CellType_Pyramidal Cell:DStype_DS2')) = -1;
C(n,strcmp(lme.CoefficientNames,'DStype_DS2:State_RUN')) = -1;
C(n,strcmp(lme.CoefficientNames,'CellType_Pyramidal Cell:DStype_DS2:State_RUN')) = -1;

[p(n),F(n),df1(n),df2(n)]  = coefTest(lme, C(n,:));


% Comparison 22. IN vs PC for DS1 in RUN
% DS1_PC - DS1_IN = (Intercept + PC + RUN + PC:RUN) - (Intercept+RUN) = 
% = PC + PC:RUN
n = 22;
comparison{n} = 'IN vs PC (DS1 RUN)';
C(n,strcmp(lme.CoefficientNames,'CellType_Pyramidal Cell')) = 1;
C(n,strcmp(lme.CoefficientNames,'CellType_Pyramidal Cell:State_RUN')) = 1;

[p(n),F(n),df1(n),df2(n)]  = coefTest(lme, C(n,:));


% Comparison 23. IN vs PC for DS2 in RUN
% DS2_PC - DS2_IN = (Intercept + PC + RUN + PC:RUN + DS2 + PC:DS2 + RUN:DS2 + PC:RUN:DS2) - (Intercept+RUN + DS2 + RUN:DS2) = 
% = PC + PC:RUN + PC:DS2 + PC:RUN:DS2
n = 23;
comparison{n} = 'IN vs PC (DS1 RUN)';
C(n,strcmp(lme.CoefficientNames,'CellType_Pyramidal Cell')) = 1;
C(n,strcmp(lme.CoefficientNames,'CellType_Pyramidal Cell:State_RUN')) = 1;
C(n,strcmp(lme.CoefficientNames,'CellType_Pyramidal Cell:DStype_DS2')) = 1;
C(n,strcmp(lme.CoefficientNames,'CellType_Pyramidal Cell:DStype_DS2:State_RUN')) = 1;

[p(n),F(n),df1(n),df2(n)]  = coefTest(lme, C(n,:));


% Comparison 24. IN vs PC for DS3 in RUN
% DS3_PC - DS3_IN = (Intercept + PC + RUN + PC:RUN + DS3 + PC:DS3 + RUN:DS3 + PC:RUN:DS3) - (Intercept+RUN + DS3 + RUN:DS3) = 
% = PC + PC:RUN + PC:DS3 + PC:RUN:DS3
n = 24;
comparison{n} = 'IN vs PC (DS1 RUN)';
C(n,strcmp(lme.CoefficientNames,'CellType_Pyramidal Cell')) = 1;
C(n,strcmp(lme.CoefficientNames,'CellType_Pyramidal Cell:State_RUN')) = 1;
C(n,strcmp(lme.CoefficientNames,'CellType_Pyramidal Cell:DStype_DS3')) = 1;
C(n,strcmp(lme.CoefficientNames,'CellType_Pyramidal Cell:DStype_DS3:State_RUN')) = 1;

[p(n),F(n),df1(n),df2(n)]  = coefTest(lme, C(n,:));

p_adj = p.*n;




function PlotHeatMaps(sorted_mat, plotWin, lims)

[N_cell,dataL] = size(sorted_mat);
center = round(dataL/2)+1;

imagesc(-plotWin:plotWin, 1:N_cell,sorted_mat(:,center-plotWin:center+plotWin))
clim([lims(1) lims(2)])
cb=colorbar;
title(cb,"Z-score")
colormap bone
hold on
xlabel("Time from DS (ms)")
ylabel("Cell ID")

end