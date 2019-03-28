function draw_3d(data)
    figure(1);
    x = data(:,1);
    y = data(:,2);
    z = data(:,3);
    c = linspace(1,10,length(x));
    f = scatter3(x, y, z, [], c, 'o', 'filled', 'LineWidth', 1);
    title('xxxx results')
    xlabel('oee')
    ylabel('ctm_sa')
    zlabel('qly_cost')
    colormap default
end
