% data = load('data.mat');
% result = data.data;
% result(:,3) = -result(:,3);
% result(:, 4:6)= normalize(result, 1, 'range');
% result = sortrows(result, 6, 'descend');

% a = [1, 2, 3, 4];
% str = sprintf('%d', a(1))
% for i = 2:size(a, 2)
% str = strcat(str, '->', sprintf('%d', a(i)))
% end

load('data.mat')
sum = data(:,4);
th = data(:,1:3);
result_norm = normalize(th, 1, 'range');



mymap = ones(size(sum, 1), 3) ./ 2;

rows = linspace(0, 1, size(sum, 1))';
mymap(:, 1) = rows;
mymap(:, 3) = rows;

draw_3d(result_norm)

% mymap = [rows, rows, rows];

% 这里可以改颜色，地址在 https://de.mathworks.com/help/matlab/ref/colormap.html
colormap(mymap)

disp('well')


