function view3D( timeMIP, res,tMIP_thresh )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

    fig = figure(4);
    set(fig,'Units','normalized')
    set(fig,'position',[0.5 0.1 0.25 0.25])
    clf;
    timeMIP18 = max(timeMIP(:))*tMIP_thresh;
    hpatch = patch(isosurface(timeMIP,timeMIP18));

    colormap('jet');
    reducepatch(hpatch,0.6);
    set(hpatch,'FaceColor','red','EdgeColor', 'none');
    set(gca, 'ZDir', 'reverse')
    set(gca,'color','black')
    % Make it all look good
    camlight headlight;
    lighting gouraud
    alpha(0.8)
    set(fig,'color','black');
    view([0 1 0]);
    % zoom(1.0);
    daspect([1 1 1])
    xlim([1 res]);
    ylim([1 res]);
    zlim([1 res]);


end

