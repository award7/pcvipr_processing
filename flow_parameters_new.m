% The function calculates flow, diameter and maximum velocity along vessels
% in cross sections with normal in the vessel direction.
%
% INPUT
% 1. METHOD. Value ranging from 1 to 4 and is
%   1. MIP thresholded at 18 %
%   2. PC (phase coherence) thresholded at THRESH
%   3. PC-HT (phase coherence with Hough Transform (circular cross section
%   adaptation)) thresholded at THRESH
%   4. PCA (principal component analysis) on temporal data thresholded at
%   THRESH
%
%   methods 1. and 2. works on a global BW image while methods 3. and 4.
%   works localy in the cross section.
% 2. BRANCHACTUAL. the branch to investigate in list form, sorted from
% start to end of vessel
% 3. TIMEMIP. timeMIP array
% 4. V. velocity array
% 5. PC. phase coherence array
% 6. BWofChoise. for methods 1. and 2., input needs to correspond to either
% BWmip18 or BWpc
% 7. R. cross section radial size
% 8. D. distance backward and frontward from reference point in direction
% estimation.
% 9. THRESH. threshold value. input used only for methods 3. and 4.
%
% OUTPUT
% 1. FLOWPERHEARTCYCLE. flow per heart cycle along vessel's centerline
% 2. FLOWPULSATILE. flow over herat cycle along vessel's centerline
% 3. DIAM. diameter of vessel along vessel's centerline
% 4. MAXVEL. maximum velocity along vessel's centerline
%
% Author:   Erik Spaak
% Updated:  Eric Schrauben, University of Wisconsin - Madison, 05/2015

%
function [area, diam, flowPerHeartCycle, flowPulsatile, ...
    maxVel,wss_simple, wss_simple_avg,meanVel,PI] = ...
    flow_parameters(branchActual, v, timeMIP, r,nframes)

global res fov
d = 4;  % number of points to use for cross section extraction
% extracted orthogonal cross sections will be based on i+d and i-d

% return and leave warning messege if branch is too short
if size(branchActual(:,1)) < 3
    warning('Vessel is too short to calculate flow. Returning flowPerHeartCycle = diam = maxVel = 0')
    flowPerHeartCycle = 0;
    flowPulsatile = 0;
    diam = 0;
    maxVel = 0;
    return
end

disp('Calculating flow parameters for vessel ')
SE = strel('square', 4);

for i = 1:size(branchActual,1)
    % extract normal to cross-section
    if i < d+1
        dir = (branchActual(i+d,1:3) - branchActual(i,1:3));
    elseif i >= size(branchActual,1)-d
        dir = (branchActual(i,1:3) - branchActual(i-d,1:3));
    else
        dir = (branchActual(i+d,1:3) - branchActual(i-d,1:3));
    end
    dir = dir/norm(dir);
    
    if dir(2) == 0 && dir(1) == 0
        angle1 = 0;
    else
        angle1 = atan(dir(2)/dir(1))*180/pi;                    % x-y angle in degrees
    end
    if dir(3) == 0 && dir(2) == 0
        angle2 = 0;
    else
        angle2 = atan(dir(3)/sqrt(dir(2)^2+dir(1)^2))*180/pi;   % y-z angle in degrees
    end
    
    if dir(1) < 0
        angle1 = angle1 + 180;                                  % compensate for phase-wraps
    end
    
    % velocity subsets
    vSubset = double(v(branchActual(i,1)-r:branchActual(i,1)+r, branchActual(i,2)-r:branchActual(i,2)+r, ...
        branchActual(i,3)-r:branchActual(i,3)+r, :, :));
    
    % rotate subsets
    B = imrotate(vSubset, -angle1, 'bilinear', 'crop');
    D = permute(B, [1 3 2 4 5]);
    F = imrotate(D, (90-angle2), 'bilinear', 'crop');
    H = ipermute(F, [1 3 2 4 5]);
    
    vCrossection = zeros(2*r+1, 2*r+1, 1, 3, nframes);
    vCrossection(:,:,1,1,:) = H(:,:,r+1,1,:);
    vCrossection(:,:,1,2,:) = H(:,:,r+1,2,:);
    vCrossection(:,:,1,3,:) = H(:,:,r+1,3,:);
    
    % Extract temporal mean of sum-squared velocity cross section,
    % i.e. the temporal mean of the speed image
    vTimeFrame = interp2(0.1*((dir(1)*mean(vCrossection(:,:,1,1,:),5)).^2+ (dir(2)*mean(vCrossection(:,:,1,2,:),5)).^2+...
        (dir(3)*mean(vCrossection(:,:,1,3,:),5)).^2).^(0.5),2);
    
    % Do the same extraction and rotation for timeMIP
    timeMIPsubset = timeMIP(branchActual(i,1)-r:branchActual(i,1)+r, ...
        branchActual(i,2)-r:branchActual(i,2)+r, branchActual(i,3)-r:branchActual(i,3)+r);
    H = imrotate(timeMIPsubset, -angle1, 'bilinear', 'crop');
    I = permute(H, [1 3 2]);
    J = imrotate(I, (90-angle2), 'bilinear', 'crop');
    K = ipermute(J, [1 3 2]);
    timeMIPcrossection = K(:,:,r+1);
    timeMIPcrossection = interp2(timeMIPcrossection,2);
    timeMIPcrossection(round(length(timeMIPcrossection)/2)-1:round(length(timeMIPcrossection)/2)+1,...
        round(length(timeMIPcrossection)/2)-1:round(length(timeMIPcrossection)/2)+1) = max(timeMIPcrossection(:));
    
    % kmeans clustering
    vVect = (reshape(vTimeFrame,numel(vTimeFrame(1,:))^2,1));
    timeMIPvect = (reshape(timeMIPcrossection,numel(timeMIPcrossection(1,:))^2,1));
    
    clust = horzcat(timeMIPvect,vVect);
    [idx,ctrs] = kmeans(clust,2);
    segment2 = zeros(size(timeMIPcrossection));
    segment2(idx==2) = 1;
    if segment2(round(numel(segment2(:,1))/2),round(numel(segment2(1,:))/2)) == 0
        segment2 = -1*segment2+1;
    end
    segment2 = imerode(segment2,SE);
    segment2 = regiongrowing(segment2,round(length(segment2)/2),round(length(segment2)/2));
    segment2 = imdilate(segment2, SE);
    
    % Perform some area check by 1) making sure values aren't too
    % large and 2) by comparing to previous value within the branch
%     if i ==1
%         segment_previous = segment2;
%     end
%     if i > 1 && (sum(segment2(:)) > 500) || (sum(segment2(:)) > sum(segment_previous(:))*3 || ...
%             sum(segment2(:)) < 0.10*sum(segment_previous(:)))
%         segment2 = segment_previous;
%     end
%     segment_previous = segment2;
    
    % plotting, change to 1 to view how the k-means is working
    if 0
        disp(i)
        figure(4); clf;
        subplot(2,2,3);
        plot(clust(idx==1,1),clust(idx==1,2),'r.','MarkerSize',12)
        hold on
        plot(clust(idx==2,1),clust(idx==2,2),'b.','MarkerSize',12)
        plot(ctrs(:,1),ctrs(:,2),'kx',...
            'MarkerSize',12,'LineWidth',2)
        plot(ctrs(:,1),ctrs(:,2),'ko',...
            'MarkerSize',12,'LineWidth',2)
        legend('Cluster 1','Cluster 2','Centroids',...
            'Location','NW')
        title('k-means clustering'); hold off;
        
        subplot(2,2,1);
        imagesc(timeMIPcrossection);colormap gray;
        title('2X interpolated time MIP'); 
        
        subplot(2,2,2);
        imagesc(vTimeFrame);colormap gray;
        title('2X interpolated velocity magnitude')
%         c = colorbar;
%         set(get(c,'xlabel'),'String', 'Velocity (m/s)');

        subplot(2,2,4);
        imagesc(segment2); colormap gray;
        title('vessel mask');
        pause
    end
    
    % calculate flow, diameter and whatever
    N = 1;  % just to make diameter calculation work
    maxVelFrame = zeros(1,nframes);
    viscosity = .0045;      % in kg/(m s^)
    area(i) = sum(segment2(:))*(fov/res)^2 * (2*r+1)^2/(8*r+1)^2;                  % in cm^2
    diam(i) = 2*sqrt(area(i)/pi);
    for j = 1:nframes
        
        vTimeFrame = segment2.*interp2(0.1*(dir(1)*vCrossection(:,:,1,1,j) + dir(2)*vCrossection(:,:,1,2,j) + ...
            dir(3)*vCrossection(:,:,1,3,j)),2);
        
        ind = find(vTimeFrame);
        flowPulsatile(i, j) = mean(vTimeFrame(ind))*area(i);
        meanVelFrame(j) = mean(vTimeFrame(ind));
        
        maxVelFrame(j) = max(max(vTimeFrame));              % max velocity, in cm/s
        
        % Simple WSS calculation based on the max velocity here and the diam.
        % Assumes parabolic flow profile
        wss_simple (i,j) = viscosity*maxVelFrame(j) * 0.01 * sqrt(2*pi*maxVelFrame(j)*0.01/(flowPulsatile(i,j)*1e-6));          % parabolic assumption, in Pa
        
    end
    
    maxVel(i) = max(maxVelFrame);
    meanVel(i) = mean(meanVelFrame);
    wss_simple_avg(i) = real(sum(wss_simple(i,:))/nframes);
    PI(i) = (max(flowPulsatile(i,:))-min(flowPulsatile(i,:)))/mean(flowPulsatile(i,:));
    
end
% calculate flow in ml/s. go from mm^2 to cm^2 with the factor 1e-2, and
% from mm/s to cm/s with the factor 1e-1
flowPerHeartCycle = sum(flowPulsatile, 2)'/(nframes);
disp('Done!')
