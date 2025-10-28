% function to get % of cells recruited in individual events, and % of
% events recruiting neurons

function [NeuronsActive, DSRecruit, SpikeCount] = GetDS_NeuronPercentage(peth_types_qw_count, center, minCell, ds_win)

[N_mice, ~] = size(peth_types_qw_count);
N_cell = zeros(N_mice,1);
NeuronsActive = cell(N_mice,3);
DSRecruit = cell(N_mice,1);
SpikeCount = cell(N_mice,1);

for i = 1:N_mice % loop on mice
    [~, ~, cellCount] = size(peth_types_qw_count{i,1});
    if cellCount < minCell
        continue;
    end
    SpikeCount{i}  = zeros(cellCount,3); 
    % if mouse does not have enough cells, exclude
    for j= 1:3 % loop on ds type
        current_peth = peth_types_qw_count{i,j};
        [N_ds, ~, N_cell(i)] = size(current_peth);
        
        sub_peth= current_peth(:,center-ds_win:center+ds_win, :);
        summed_activity = squeeze(sum(sub_peth,2)) > 0; % for each cell and ds

        % get % of neurons are active during each event (%)
        NeuronsActive{i,j} = sum(summed_activity,2)./N_cell(i);

        % get % of DS that recruit each neuron 
        DSRecruit{i}(:,j) = sum(summed_activity,1)./N_ds;
        
        % get spike/ DS window
        SpikeCount{i}(:,j) = squeeze(sum(sub_peth,[1 2]))./N_ds;
    end
end

end