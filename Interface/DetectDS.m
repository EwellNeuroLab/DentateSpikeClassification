%% function to detect DS on every channel, then discard the ones with low number of events and pick the biggest amplitude from the rest of the channels

function DS_struct = DetectDS(bp_LFP, params)
        [~, N_channels] = size(bp_LFP);
        
        if params.channel == -1
            peak_amp = zeros(N_channels,1);
            N_ds = zeros(N_channels,1);
            for i = 2:N_channels-1 % disregard edges
   
                DS_lfp0 = bp_LFP(:, i);
                threshold = mean(DS_lfp0)+params.N*std(DS_lfp0);
                [amp, ~, ~, ~] = findpeaks(DS_lfp0,"MinPeakHeight", threshold, "MinPeakWidth",params.min_width, "MaxPeakWidth", params.max_width);

                amp(amp> params.max_amp) = []; % remove too large events
                peak_amp(i) = mean(amp);
                N_ds(i) = length(amp);
            end
    
            %get rid of channels with low number of DSs
            peak_amp(N_ds < median(N_ds)) = 0;
            [~, DS_struct.channel] = max(peak_amp);

        else
                DS_struct.channel= params.channel;

        end
        DS_lfp = bp_LFP(:, DS_struct.channel);
        threshold = mean(DS_lfp)+params.N*std(DS_lfp);
        [DS_struct.amp, DS_struct.time, DS_struct.width, DS_struct.prom] = findpeaks(DS_lfp,"MinPeakHeight", threshold, "MinPeakWidth",params.min_width, "MaxPeakWidth", params.max_width);


        %remove too large events
        remove_idx = find(DS_struct.amp>params.max_amp);
        DS_struct.amp(remove_idx) = [];
        DS_struct.time(remove_idx)= [];
        DS_struct.width(remove_idx)= [];
        DS_struct.prom(remove_idx)= [];

        % remove events in the first and last 0.5 s (messes up averaging)
        remove_idx = find( DS_struct.time < 0.5*params.fs );

        DS_struct.amp(remove_idx) = [];
        DS_struct.time(remove_idx)= [];
        DS_struct.width(remove_idx)= [];
        DS_struct.prom(remove_idx)= [];

        remove_idx = find( DS_struct.time > length(DS_lfp)-0.5*params.fs );
        DS_struct.amp(remove_idx) = [];
        DS_struct.time(remove_idx)= [];
        DS_struct.width(remove_idx)= [];
        DS_struct.prom(remove_idx)= [];


         %% detect on reference channel if it was provided & remove events that are in a coincidence with putative DSs
        if params.ref > 0
            ref_lfp = bp_LFP(:,params.ref);
            [ref_amp, ref_time] = findpeaks(ref_lfp,"MinPeakHeight", threshold, "MinPeakWidth",params.min_width, "MaxPeakWidth", params.max_width);

            remove_idx = [];
            for d = 1:length(DS_struct.amp)
                if min(abs(DS_struct.time(d)-ref_time)) < params.fs*0.02 % peak within 10 ms
                    remove_idx = [remove_idx, d];
                end
            end
            DS_struct.amp(remove_idx) = [];
            DS_struct.time(remove_idx)= [];
            DS_struct.width(remove_idx)= [];
            DS_struct.prom(remove_idx)= [];

        end
            

        end

