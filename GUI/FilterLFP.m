%% function to bandpass filter lfp on all provided channel
function filtered_lfp = FilterLFP(lfp, bp,ds)

[samp, ch] = size(lfp);
filtered_lfp = zeros(samp,ch);
for i = 1:ch
    filtered_lfp(:,i) = bandpass(lfp(:,i), bp,ds);
end

end
