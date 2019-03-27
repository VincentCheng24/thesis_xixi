data = load('data.mat');
result = data.data;
result(:,3) = -result(:,3);
result(:, 4:6)= normalize(result, 1, 'range');
result = sortrows(result, 6, 'descend');