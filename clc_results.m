function [result, time_costs, invest_costs] = clc_results(K, kt, cof, const, location_factor, target_oee, target_ctm, target_qua, time_const, invest_const, robust)
    
    % k techs + 3 kpi + sum
    result = (zeros(1,K+4));
    time_costs = zeros(1, 1);
    invest_costs = zeros(1, 1);
    flag=1;
%   sigma value
    s = 0.02;
         
    
    for k = 1: K
        chosens = int8(nchoosek(1:12,k));
        
        for i=1:nchoosek(12,k)

            chosen = chosens(i,:);

            % time constraint
            time_cost = sum(const(chosen, 1)) * location_factor;
            if time_cost > time_const
                disp(chosen)
                disp(' is skipped');
                continue
            end

            % investment constraint
            invest_cost = sum(const(chosen, 2));
            if invest_cost > invest_const
                continue
            end

            permutation = perms(chosen);

            for m=1:factorial(k)
                pmt=permutation(m,:);

                cof_mat = [];
                for p = 1:k
                    for q = p+1:k
                        cof_mat = [cof_mat, cof(pmt(p),pmt(q))];
                    end
                end

                if ~ all(cof_mat(:) > 0)
                    continue
                end

                if robust
                    oee = normrnd(kt(pmt(1),1),s) * normrnd(kt(pmt(1),8),s) / normrnd(kt(pmt(1),2),s);
                    ctm_sa = normrnd(kt(pmt(1),1),s) * normrnd(kt(pmt(1),9),s);
                    qly_cost = normrnd(kt(pmt(1),7),s);
                else
                    oee = kt(pmt(1),1) * kt(pmt(1),8) / kt(pmt(1),2);
                    ctm_sa = kt(pmt(1),1) * kt(pmt(1),9);
                    qly_cost = kt(pmt(1),7);
                end
                


                if k > 2
                    for j = 2:k
                        
                        if robust
                            tmp_oee = (normrnd(kt(pmt(j),1),s) * normrnd(kt(pmt(j),8),s) / normrnd(kt(pmt(j),2),s)) * cof(pmt(j-1),pmt(j));
                            tmp_ctm_sa = normrnd(kt(pmt(j),1),s) * normrnd(kt(pmt(j),9),s) * cof(pmt(j-1),pmt(j));
                            tmp_qly_cost = normrnd(kt(pmt(j),7),s) * cof(pmt(j-1),pmt(j));
                        else
                            tmp_oee = (kt(pmt(j),1) * kt(pmt(j),8) / kt(pmt(j),2)) * cof(pmt(j-1),pmt(j));
                            tmp_ctm_sa = kt(pmt(j),1) * kt(pmt(j),9) * cof(pmt(j-1),pmt(j));
                            tmp_qly_cost = kt(pmt(j),7) * cof(pmt(j-1),pmt(j));
                        end                      

                        oee = oee + tmp_oee;
                        ctm_sa = ctm_sa + tmp_ctm_sa;
                        qly_cost = qly_cost + tmp_qly_cost;
                    end
                end
                ctm_sa = -ctm_sa;
                qly_cost = qly_cost * (-250);


                if oee > target_oee && ctm_sa > target_ctm && qly_cost > target_qua

                   result(flag,1:k) = pmt;
                   result(flag,K+1) = k;
                   result(flag,K+2) = oee;
                   result(flag,K+3) = ctm_sa;
                   result(flag,K+4) = qly_cost;
                   
                   time_costs(flag, 1) = time_cost;
                   invest_costs(flag, 1) = invest_cost;
                   
                   flag=flag+1;       
                end
            end
        end
    end
end