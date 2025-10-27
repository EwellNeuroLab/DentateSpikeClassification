%% function to read a single binary file and rearrange rows based on channel map
function LFPmat = LoadEphysData_Single(path,N_channels, N_shank, channel_map)

    disp(strcat("Loading ", path))
    tmp=load(path);
    str = fieldnames(tmp);
    lfp = tmp.(str{1});
    [d1,d2] = size(lfp);

    if d2 > d1
        lfp = transpose(lfp);
    end
    [N_points,~] = size(lfp);
    LFPmat = nan(N_points, N_channels,N_shank);
    for shank = 1:N_shank
        for ch = 1:N_channels
            LFPmat(:,ch,shank) =  lfp(:,channel_map(ch,shank));
        end
    
    end

end