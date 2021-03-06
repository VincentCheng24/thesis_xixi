kt = xlsread('kpi_tech.xlsx', 'C16:P27');
cof = xlsread('tech_tech.xlsx','A14:L25');
lf = xlsread('lf_smau','C3:N9');
const = xlsread('constraints.xlsx', 'E2:F13');
tech_time_costs = const(:,1);
tech_invest_costs = const(:,2);


target_oee = 0.5;
target_ctm = 0.5;
target_qua = 0;
time_const = 1000;
invest_const = 50000;


for i = 1:12
    continue
end
    
%case 4
  
    chosens = int8(nchoosek(1:12,4));
    answer_4 = (zeros(1,8));
    flag=1;
    for i=1:nchoosek(12,4)
        
        chosen = chosens(i,:);
        
        % time constraint
        time_cost = sum(tech_time_costs(chosen));
        if time_cost > time_const
            disp(chosen)
            disp(' is skipped');
            continue
        end
        
        % investment constraint
        invest_cost = sum(tech_invest_costs(chosen));
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


            oee =    (kt(pmt(1),1) * kt(pmt(1),8) / kt(pmt(1),2)) ...
                   + (kt(pmt(2),1) * kt(pmt(2),8) / kt(pmt(2),2)) *  cof(pmt(1),pmt(2))...
                   + (kt(pmt(3),1) * kt(pmt(3),8) / kt(pmt(3),2)) *  cof(pmt(2),pmt(3))...
                   + (kt(pmt(4),1) * kt(pmt(4),8) / kt(pmt(4),2)) *  cof(pmt(3),pmt(4));

            ctm_sa  =   (kt(pmt(1),1) * kt(pmt(1),9)  ...
                       + kt(pmt(2),1) * kt(pmt(2),9) * cof(pmt(1),pmt(2))...
                       + kt(pmt(3),1) * kt(pmt(3),9) * cof(pmt(2),pmt(3))...
                       + kt(pmt(4),1) * kt(pmt(4),9) * cof(pmt(3),pmt(4))) * (-1);

           qly_cost =   (kt(pmt(1),7) *  ...
                       + kt(pmt(2),7) * cof(pmt(1),pmt(2)) ...
                       + kt(pmt(3),7) * cof(pmt(2),pmt(3)) ...
                       + kt(pmt(4),7) * cof(pmt(3),pmt(4))) * (-250);


            if oee > target_oee && ctm_sa > target_ctm && qly_cost < target_qua
  
               answer_4(flag,1:4) = pmt;
               answer_4(flag,6) = oee;
               answer_4(flag,7) = ctm_sa;
               answer_4(flag,8) = qly_cost;
%                a_sort4 = sortrows(answer_4,-6)  
%               answer(flag,6) = cost;
%               answer(flag,7) = time;            
               flag=flag+1;       
            end
        end
     end

    
    
%case5
% 
    chosen = nchoosek(1:12,5);
    answer_5 = zeros(1,8);
    flag=1;
    for i=1:nchoosek(12,5)
        permutation5 = perms(chosen(i,:));
        for j=1:factorial(5)
            pmt=permutation5(j,:);
            
             cof_mat = [cof(pmt(1),pmt(2)), ...
                    cof(pmt(1),pmt(3)) ...
                    cof(pmt(1),pmt(4)) ...
                    cof(pmt(1),pmt(5)) ...
                    cof(pmt(2),pmt(3)) ...
                    cof(pmt(2),pmt(4)) ...
                    cof(pmt(3),pmt(4)) ...
                    cof(pmt(3),pmt(5)) ...
                    cof(pmt(4),pmt(5)) ];
                
   
            if all(cof_mat(:) > 0)
                continue
            end

            
        oee =    kt(pmt(1),1) * kt(pmt(1),8) / kt(pmt(1),2) ...
               + (kt(pmt(2),1) * kt(pmt(2),8) / kt(pmt(2),2)) *  cof(pmt(1),pmt(2))...
               + (kt(pmt(3),1) * kt(pmt(3),8) / kt(pmt(3),2)) *  cof(pmt(2),pmt(3))...
               + (kt(pmt(4),1) * kt(pmt(4),8) / kt(pmt(4),2)) *  cof(pmt(3),pmt(4))...
               + (kt(pmt(5),1) * kt(pmt(5),8) / kt(pmt(5),2)) *  cof(pmt(4),pmt(5));

        ctm_sa  =  ((kt(pmt(1),1) * kt(pmt(1),9))  ...
                   + (kt(pmt(2),1) * kt(pmt(2),9)) * cof(pmt(1),pmt(2))...
                   + (kt(pmt(3),1) * kt(pmt(3),9)) * cof(pmt(2),pmt(3))...
                   + (kt(pmt(4),1) * kt(pmt(4),9)) * cof(pmt(3),pmt(4))...
                   + (kt(pmt(5),1) * kt(pmt(5),9)) * cof(pmt(4),pmt(5))) * (-1);
               
        qly_cost =  (kt(pmt(1),7) *  ...
                   + kt(pmt(2),7) * cof(pmt(1),pmt(2)) ...
                   + kt(pmt(3),7) * cof(pmt(2),pmt(3)) ...
                   + kt(pmt(4),7) * cof(pmt(3),pmt(4)) ...
                   + kt(pmt(5),7) * cof(pmt(4),pmt(5))) * (-250);
       
               if oee > target_oee && ctm_sa > target_ctm && qly_cost < target_qua
  
                   answer_5(flag,1:5) = pmt;
                   answer_5(flag,6) = oee;
                   answer_5(flag,7) = ctm_sa;
                   answer_5(flag,8) = qly_cost;
%                  a_sort5 = sortrows(answer_5,-6) 
% %                answer(flag,6) = cost;
% %                answer(flag,7) = time;        
                   flag=flag+1;       
              end
        end
     end
%     delete = ~any(answer_5,2);
%     answer_5(delete,:)=[];

result = vertcat(answer_4,answer_5);
a_result  = sortrows(result,-6);

