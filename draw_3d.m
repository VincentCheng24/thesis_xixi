
function draw_3d(data)
    figure(1);
    x = data(:,1);
    y = data(:,2);
    z = data(:,3);
    c = linspace(0,10,length(x));
    f = scatter3(x, y, z, [], c, 'o', 'filled', 'LineWidth', 1);
    title('Simulation Results')
    xlabel('OEE')
    ylabel('Customer Satisfaction')
    zlabel('Quality Cost')
    colormap cool
end


