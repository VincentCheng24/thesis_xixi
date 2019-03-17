kt = xlsread('kpi_tech.xlsx', 'C16:P27');
coefficient = xlsread('tech_tech.xlsx','A14:L25');
target_oee = 8


%case 4
    chosen = nchoosek(1:12,4);
    answer_4 = zeros(1,6);
    flag=1;
    for i=1:nchoosek(12,4)
        permutation4 = perms(chosen(i,:));
        for j=1:factorial(4)
            permutation=permutation4(j,:);
            
            if coefficient(permutation(1),permutation(2)) < 0 ...
                    || coefficient(permutation(1),permutation(3)) < 0 ...
                    || coefficient(permutation(1),permutation(4)) < 0 ...
                    || coefficient(permutation(2),permutation(3)) < 0 ...
                    || coefficient(permutation(2),permutation(4)) < 0 ...
                    || coefficient(permutation(3),permutation(4)) < 0
                continue
            end
            
            interaction = coefficient(permutation(1),permutation(2)) ...
                * coefficient(permutation(1),permutation(3)) ...
                * coefficient(permutation(1),permutation(4)) ...
                * coefficient(permutation(2),permutation(3)) ...
                * coefficient(permutation(2),permutation(4)) ...
                * coefficient(permutation(3),permutation(4));
            oee = interaction ...
                * kt(permutation(1),1) * kt(permutation(1),8) / kt(permutation(1),2) ...
                * kt(permutation(2),1) * kt(permutation(2),8) / kt(permutation(2),2) ...
                * kt(permutation(3),1) * kt(permutation(3),8) / kt(permutation(3),2) ...
                * kt(permutation(4),1) * kt(permutation(4),8) / kt(permutation(4),2);
%             customersatisfication
%             quality_cost

            if oee > target_oee
%              customersatisfication
%              quality_cost
               answer_4(flag,1:4) = permutation;
               answer_4(flag,6) = oee;
%               a_sort4 = sortrows(answer4,-5)  
%                answer(flag,6) = cost;
%                answer(flag,7) = time;        
               flag=flag+1;       
            end
        end
     end
    delete = ~any(answer_4,2);
    answer_4(delete,:)=[];
    
    
%case5

    chosen = nchoosek(1:12,5);
    answer_5 = zeros(1,6);
    flag=1;
    for i=1:nchoosek(12,5)
        permutation4 = perms(chosen(i,:));
        for j=1:factorial(5)
            permutation=permutation4(j,:);
            
            if coefficient(permutation(1),permutation(2)) < 0 ...
                    || coefficient(permutation(1),permutation(3)) < 0 ...
                    || coefficient(permutation(1),permutation(4)) < 0 ...
                    || coefficient(permutation(1),permutation(5)) < 0 ...
                    || coefficient(permutation(2),permutation(3)) < 0 ...
                    || coefficient(permutation(2),permutation(4)) < 0 ...
                    || coefficient(permutation(2),permutation(5)) < 0 ...
                    || coefficient(permutation(3),permutation(4)) < 0 ...
                    || coefficient(permutation(3),permutation(5)) < 0 ...
                    || coefficient(permutation(4),permutation(5)) < 0 
                continue
            end
            
            interaction = coefficient(permutation(1),permutation(2)) ...
                * coefficient(permutation(1),permutation(3)) ...
                * coefficient(permutation(1),permutation(4)) ...
                * coefficient(permutation(1),permutation(5)) ...
                * coefficient(permutation(2),permutation(3)) ...
                * coefficient(permutation(2),permutation(4)) ...
                * coefficient(permutation(2),permutation(5)) ...
                * coefficient(permutation(3),permutation(4)) ...
                * coefficient(permutation(3),permutation(5)) ...
                * coefficient(permutation(4),permutation(5));
            
            oee = interaction ...
                * kt(permutation(1),1) * kt(permutation(1),8) / kt(permutation(1),2) ...
                * kt(permutation(2),1) * kt(permutation(2),8) / kt(permutation(2),2) ...
                * kt(permutation(3),1) * kt(permutation(3),8) / kt(permutation(3),2) ...
                * kt(permutation(4),1) * kt(permutation(4),8) / kt(permutation(4),2) ...
                * kt(permutation(5),1) * kt(permutation(5),8) / kt(permutation(5),2);
%             customersatisfication
%             quality_cost

            if oee > target_oee
%              customersatisfication
%              quality_cost
               answer_5(flag,1:5) = permutation;
               answer_5(flag,6) = oee;
%               a_sort5 = sortrows(answer_5,-6)  
%                answer(flag,6) = cost;
%                answer(flag,7) = time;        
               flag=flag+1;       
            end
        end
     end
    delete = ~any(answer_5,2);
    answer_5(delete,:)=[];
   
result = vertcat(answer_4,answer_5)
a_result  = sortrows(result,-6)