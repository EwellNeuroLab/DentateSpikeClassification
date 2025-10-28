%% Gergely Tarcsay, 2025. Supplementary figure 3.
% script to analyze cell recruitment during DSs
% 1. # of neurons recruited in each DS event
% 2. % of DSs when cell is recruited

% evaluating mouse-wise and total count
rootdir = "H:\Data_to_publish\"; % changed this 
ewell = load(strcat(rootdir,"CellTable_Ewell.mat"));
swil = load(strcat(rootdir, "CellTable_SWIL.mat");



%% percentage of neurons recruited in each DS event
center= 201;
minCell = 10;
ds_win = 10;

[NeuronsActive_qw1, DSRecruit_qw1, SpikeCount_qw1] = GetDS_NeuronPercentage(ewell.peth_types_qw_count, center, minCell,ds_win);
[NeuronsActive_qw2, DSRecruit_qw2, SpikeCount_qw2] = GetDS_NeuronPercentage(swil.peth_types_qw_count, center, minCell, ds_win);

[NeuronsActive_run1, DSRecruit_run1, SpikeCount_run1] = GetDS_NeuronPercentage(ewell.peth_types_run_count, center, minCell,ds_win);
[NeuronsActive_run2, DSRecruit_run2, SpikeCount_run2] = GetDS_NeuronPercentage(swil.peth_types_run_count, center, minCell, ds_win);

%% pool data
NeuronsActive_pooled_qw = cell(3,1);
NeuronsActive_pooled_run = cell(3,1);

 for i = 1:3
     NeuronsActive_pooled_qw{i} = cat(1,NeuronsActive_qw1{:,i});
     NeuronsActive_pooled_qw{i} = cat(1,NeuronsActive_qw2{:,i});

     NeuronsActive_pooled_run{i} = cat(1,NeuronsActive_run1{:,i});
     NeuronsActive_pooled_run{i} = cat(1,NeuronsActive_run2{:,i});
 end
 
DSRecruit_pooled_qw = [vertcat(DSRecruit_qw1{:}); vertcat(DSRecruit_qw2{:})];
DSRecruit_pooled_run= [vertcat(DSRecruit_run1{:}); vertcat(DSRecruit_run2{:})];

SpikeCount_pooled_qw = [cat(1,SpikeCount_qw1{:}); cat(1,SpikeCount_qw2{:})];
SpikeCount_pooled_run = [cat(1,SpikeCount_run1{:}); cat(1,SpikeCount_run2{:})];

%% plot results



figure
tiledlayout(1,3)

for j = 1:3
    nexttile;
    boxplot([SpikeCount_pooled_qw(:,j) SpikeCount_pooled_run(:,j)])


ylabel("Spike/DS window")
box off
xticklabels({"QW", "RUN"})
title(strcat("DS ", num2str(j)))

end





figure

tiledlayout(2,2)

nexttile;
data = [NeuronsActive_pooled_qw{1}; NeuronsActive_pooled_qw{2}; NeuronsActive_pooled_qw{3}];
group = [ ...
    repmat({'DS1'}, numel(NeuronsActive_pooled_qw{1}), 1); ...
    repmat({'DS2'}, numel(NeuronsActive_pooled_qw{2}), 1); ...
    repmat({'DS3'}, numel(NeuronsActive_pooled_qw{3}), 1)];

boxplot(data,group)
ylim([0 1])
ylabel("% of recruited neurons")
box off
axis square
title("QW")

nexttile;
data = [NeuronsActive_pooled_run{1}; NeuronsActive_pooled_run{2}; NeuronsActive_pooled_run{3}];
group = [ ...
    repmat({'DS1'}, numel(NeuronsActive_pooled_run{1}), 1); ...
    repmat({'DS2'}, numel(NeuronsActive_pooled_run{2}), 1); ...
    repmat({'DS3'}, numel(NeuronsActive_pooled_run{3}), 1)];

boxplot(data,group)
ylim([0 1])
ylabel("% of recruited neurons")
box off
axis square
title("RUN")

nexttile;
boxplot(DSRecruit_pooled_qw)
ylim([0 1])
ylabel("% of DS")
box off
axis square
title("QW")

nexttile;
boxplot(DSRecruit_pooled_run)
ylim([0 1])
ylabel("% of DS")
box off
axis square
title("RUN")


%% do stats - % of neurons recruited - ranksum since it's taken on DS
[p_qw_ds(1), ~, stats_qw_ds{1}]  =ranksum(NeuronsActive_pooled_qw{1},NeuronsActive_pooled_qw{2});
[p_qw_ds(2), ~, stats_qw_ds{2}]  =ranksum(NeuronsActive_pooled_qw{1},NeuronsActive_pooled_qw{3});
[p_qw_ds(3), ~, stats_qw_ds{3}]  =ranksum(NeuronsActive_pooled_qw{2},NeuronsActive_pooled_qw{3});
p_qw_ds = p_qw_ds .*3;

[p_run_ds(1), ~, stats_run_ds{1}]  =ranksum(NeuronsActive_pooled_run{1},NeuronsActive_pooled_run{2});
[p_run_ds(2), ~, stats_run_ds{2}]  =ranksum(NeuronsActive_pooled_run{1},NeuronsActive_pooled_run{3});
[p_run_ds(3), ~, stats_run_ds{3}]  =ranksum(NeuronsActive_pooled_run{2},NeuronsActive_pooled_run{3});
p_run_ds = p_run_ds .*3;

%% % of DS when cell active - kruskal-wallis as it's taken on cells &
% non-normal
[p_qw, tbl_qw, stats_qw] = friedman(DSRecruit_pooled_qw, 1, 'off');
c_qw = multcompare(stats_qw, 'CriticalValueType','bonferroni');

[p_run, tbl_run, stats_run] = friedman(DSRecruit_pooled_run, 1, 'off');
c_run = multcompare(stats_run, 'CriticalValueType','bonferroni');

