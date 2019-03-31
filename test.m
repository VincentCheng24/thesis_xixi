% data = load('data.mat');
% result = data.data;
% result(:,3) = -result(:,3);
% result(:, 4:6)= normalize(result, 1, 'range');
% result = sortrows(result, 6, 'descend');

a = [1, 2, 3, 4];
str = sprintf('%d', a(1))
for i = 2:size(a, 2)
str = strcat(str, '->', sprintf('%d', a(i)))
end