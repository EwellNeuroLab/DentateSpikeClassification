%% function to fix dead channels by interpolating between them

function LFPmat = FixDeadChannels(LFPmat, IsDeadChannel)

[~,N_channel,N_shank] = size(LFPmat);
for shank = 1:N_shank
i=1;
ConnectedChannels = find(IsDeadChannel(:,shank) == 0);
while i <= N_channel

    if IsDeadChannel(i,shank) == 1
        WorkingChsBefore= ConnectedChannels(ConnectedChannels < i);
        WorkingChsAfter =  ConnectedChannels(ConnectedChannels > i);
    
        if isempty(WorkingChsBefore) || isempty(WorkingChsAfter) % skip dead channels on the edge
            i = i+1;
            continue; 
        end
    
        InterpolationStart = WorkingChsBefore(end); % use the closest channel before the dead one
        
        InterpolationEnd = WorkingChsAfter(1); % use the closest channel after the dead one       
        gap= InterpolationEnd-InterpolationStart;
        InterpSteps = linspace(0,1, gap+1)';
        
        replacementLFP = (1-InterpSteps) * LFPmat(:,InterpolationStart, shank)' + InterpSteps * LFPmat(:,InterpolationEnd, shank)';
    
        LFPmat(:,InterpolationStart+1:InterpolationEnd-1,shank) = transpose(replacementLFP(2:end-1,:));
        i = InterpolationEnd +1;
    else
        i = i+1;
    end

end

end