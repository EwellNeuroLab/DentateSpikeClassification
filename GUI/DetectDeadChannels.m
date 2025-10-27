% function to detect dead channel based on similarity to neighbors
function [IsDeadChannel, ConnectivityMatrix] = DetectDeadChannels(LFPmat, N_neighbors, SimilarityThreshold)

[~, N_channels, N_shank] = size(LFPmat);

ConnectivityMatrix = nan(N_channels,N_neighbors*2+1);
IsDeadChannel = nan(N_channels,N_shank);
for shank = 1:N_shank
    disp(strcat("Detecting on shank ", num2str(shank)))
for i=1:N_channels
    for j = -N_neighbors:N_neighbors
        jj = i+j;
        if jj > 0 && jj < N_channels+1
            r = corrcoef(LFPmat(:,i,shank ), LFPmat(:,jj,shank ));
            ConnectivityMatrix(i,j+N_neighbors+1,shank ) = r(2,1);
           
        end
    end
end

    LogicalSimilarity = ConnectivityMatrix(:,:,shank) > SimilarityThreshold;

    for c = 1:N_channels

        SimilarityScore = sum(LogicalSimilarity(c,:))-1;

        if c <= N_neighbors ||c > N_channels-N_neighbors
            if SimilarityScore < N_neighbors-1
               IsDeadChannel(c,shank) = 1;
            else
               IsDeadChannel(c,shank) = 0;
            end

        else 
            if SimilarityScore < N_neighbors
               IsDeadChannel(c,shank) = 1;
            else
               IsDeadChannel(c,shank) = 0;
            end

        end
    end

end
end
