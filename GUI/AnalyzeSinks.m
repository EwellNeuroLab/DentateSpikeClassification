%% function to analyze sink contribution


function Contribution_res  = AnalyzeSinks(layers, CSD, cut_off, Init_DStype, Normalize)

            [~, N_t, ~] = size(CSD);
            if N_t >2
                oml_csd = squeeze(CSD(layers(1), round(N_t/2),:));
                mml_csd = squeeze(CSD(layers(2), round(N_t/2),:));
            elseif N_t == 2
                oml_csd = CSD(:,1);
                mml_csd = CSD(:,2);
            end
            dslm = find(Init_DStype==3);
            Contribution_res.DStype = Init_DStype; % init DStype
            
            
            %get contribution score        
            if Normalize == 1
                oml_contribution_norm = abs(oml_csd(dslm))/mean(oml_csd(Init_DStype==1));
                mml_contribution_norm = abs(mml_csd(dslm))/mean(mml_csd(Init_DStype==2));
                Contribution_res.score=  (oml_contribution_norm-mml_contribution_norm)./(oml_contribution_norm+mml_contribution_norm);
            else
                oml_contribution = abs(oml_csd(dslm));
                mml_contribution = abs(mml_csd(dslm));
                Contribution_res.score = (abs(oml_contribution)-abs(mml_contribution))./(abs(oml_contribution)+abs(mml_contribution));
            end

            Contribution_res.OML = oml_csd;
            Contribution_res.MML = mml_csd;
            % re-sort DSLM based on cut-off
            Contribution_res.cut_off = cut_off;  
            Contribution_res.DStype(dslm(Contribution_res.score > Contribution_res.cut_off)) = 1; %DS1
            Contribution_res.DStype(dslm(Contribution_res.score < -Contribution_res.cut_off)) = 2; %DS2
            Contribution_res.DStype(Contribution_res.DStype == 4) = NaN; % set noise to nan

    
end