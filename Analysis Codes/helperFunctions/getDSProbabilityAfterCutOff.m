function DSs = getDSProbabilityAfterCutOff(cont, d, type)

N_mice = length(cont);
DSs = zeros(N_mice,3);

if type ~= "rate"
    for m=  1:N_mice
        for i = 1:3
            DSs(m,i) = length(find(cont{m}.DStype==i))/length(cont{m}.DStype);
        end
    end
else
    for m=  1:N_mice
        for i = 1:3
            DSs(m,i) = length(find(cont{m}.DStype==i))/d{m}.recordingDur;
        end
    end

end