function result_4 = clc_results(kt, cof, const, target_oee, target_ctm, target_qua, time_const, invest_const)
    chosens = int8(nchoosek(1:12,4));
    result_4 = (zeros(1,8));
    flag=1;
    for i=1:nchoosek(12,4)
        
        chosen = chosens(i,:);
        
        % time constraint
        time_cost = sum(const(chosen));
        if time_cost > time_const
            disp(chosen)
            disp(' is skipped');
            continue
        end
        
        % investment constraint
        invest_cost = sum(const(chosen));
        if invest_cost > invest_const
            continue
        end
        
        permutation4 = perms(chosen);
        
        for j=1:factorial(4)
            pmt=permutation4(j,:);
            
            cof_mat = [cof(pmt(1),pmt(2)), ...
                    cof(pmt(1),pmt(3)) ...
                    cof(pmt(1),pmt(4)) ...
                    cof(pmt(2),pmt(3)) ...
                    cof(pmt(2),pmt(4)) ...
                    cof(pmt(3),pmt(4)) ];
            
   
            if ~ all(cof_mat(:) > 0)
                continue
            end


            oee =    (4-0) * (kt(pmt(1),1) * kt(pmt(1),8) / kt(pmt(1),2)) ...
                   + (4-1) * (kt(pmt(2),1) * kt(pmt(2),8) / kt(pmt(2),2)) *  cof(pmt(1),pmt(2))...
                   + (4-2) * (kt(pmt(3),1) * kt(pmt(3),8) / kt(pmt(3),2)) *  cof(pmt(2),pmt(3))...
                   + (4-3) * (kt(pmt(4),1) * kt(pmt(4),8) / kt(pmt(4),2)) *  cof(pmt(3),pmt(4));

            ctm_sa  =   ((4-0) * (kt(pmt(1),1) * kt(pmt(1),9))  ...
                       + (4-1) * (kt(pmt(2),1) * kt(pmt(2),9)) * cof(pmt(1),pmt(2))...
                       + (4-2) * (kt(pmt(3),1) * kt(pmt(3),9)) * cof(pmt(2),pmt(3))...
                       + (4-3) * (kt(pmt(4),1) * kt(pmt(4),9)) * cof(pmt(3),pmt(4))) * (-1);

           qly_cost =   ((4-0) * kt(pmt(1),7) *  ...
                       + (4-1) * kt(pmt(2),7) * cof(pmt(1),pmt(2)) ...
                       + (4-2) * kt(pmt(3),7) * cof(pmt(2),pmt(3)) ...
                       + (4-3) * kt(pmt(4),7) * cof(pmt(3),pmt(4))) * (-250);


            if oee > target_oee && ctm_sa > target_ctm && qly_cost < target_qua
  
               result_4(flag,1:4) = pmt;
               result_4(flag,6) = oee;
               result_4(flag,7) = ctm_sa;
               result_4(flag,8) = qly_cost;
%                a_sort4 = sortrows(answer_4,-6)  
%               answer(flag,6) = cost;
%               answer(flag,7) = time;            
               flag=flag+1;       
            end
        end
     end
end