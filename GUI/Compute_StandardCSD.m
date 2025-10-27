%% function to calculate standard csd and apply Gaussian filter to smoothen for each DS event

function [CSD, LFP] = Compute_StandardCSD(lfp, DS_timing, params)

[N_points, N_channels, N_shank] = size(lfp);

N_event  = length(DS_timing);
CSD = nan(N_channels, 2*params.window+1, N_event, N_shank);
LFP = nan(2*params.window+1,N_channels,  N_event, N_shank);

for d = 1:N_event
    start = DS_timing(d)-params.window;
    stop = DS_timing(d)+params.window;



    if start > 0 && stop < length(lfp(:,1,1))+1
        LFP(:,:,d,:) = lfp(start:stop, :, :); % save lfp if DS is not on the edge
    end


    if start < 1
        %start = 1;
        continue;
    end

    if stop > length(lfp(:,1,1))
        %stop = length(lfp(:,1,1));
        continue;
    end

    for shank = 1:N_shank
        for i = start:stop
            CSD(:,i-start+1,d,shank) = -del2(conv(lfp(i,:, shank),params.kern_win,'same'),params.spacing); % save csd
        end
    end

end


end


