function Contribution_res= getContinuuity(d, shank, cut_off, dataType)

N_mice = length(d);
Contribution_res = cell(N_mice,1);

if dataType ~= "Dupret"
    for m = 1:N_mice
        Contribution_res{m}  = AnalyzeSinks(d{m}.DG_layers{shank(m)}, d{m}.CSD{shank(m)}(:,:,:,shank(m)), cut_off, d{m}.Classify_results{shank(m)}.DStype, 0);
    end

else
   for m = 1:N_mice 
       Contribution_res{m}  = AnalyzeSinks(d{m}.DG_layers, [d{m}.OML_csd d{m}.MML_csd], cut_off, d{m}.class_DStype, 0);
   end
end

end