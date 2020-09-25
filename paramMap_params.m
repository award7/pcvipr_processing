function [area_vol, diam_vol, flowPerHeartCycle_vol, maxVel_vol, PI_vol, RI_vol, flowPulsatile_vol] = paramMap_params(...
    branchTextList, branchList, res, timeMIP, v,branchMat, nframes, fov)
global r
% need to initialize 3D volumes for each of these parameters
area_vol = zeros(size(timeMIP));
diam_vol = zeros(size(timeMIP));
flowPerHeartCycle_vol = zeros(size(timeMIP));
maxVel_vol = zeros(size(timeMIP));
PI_vol = zeros(size(timeMIP));
RI_vol = zeros(size(timeMIP));
% initialize pulsatile volume 
flowPulsatile_vol = zeros(res^3,nframes);


r = 6;                          % extracted cross sections will be 2r+1 squares

disp('Calculating flow parameters for all vessels ')
SE = strel('square', 4);        % this will be used for erosion and dilation later
% begin looping over all branches within volume
for k = 1:length(branchTextList)
    % extracted orthogonal cross sections will be based on i+d and i-d
    d = 3;                      
    % find indices from branchList, build x,y,z locations in branch
    indices = find(branchList(:,4) == k);
    branchActual = zeros(numel(indices),3);
    branchActual(:,1) = branchList(indices,1);
    branchActual(:,2) = branchList(indices,2);
    branchActual(:,3) = branchList(indices,3);
    indexes = find(branchMat == k);         % same as doing sub2ind on x,y,z
    % return zeros if branch is less that 2*d in length
    if size(branchActual(:,1)) < 2*d
        flowPerHeartCycle_vol(indexes) = 0;
        area_vol(indexes) = 0;
        diam_vol(indexes) = 0;
        maxVel_vol(indexes) = 0;
        PI_vol(indexes) = 0;
    else
        % now loop over branch to find parameters
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
            % large and by comparing to previous value within the branch
            if i ==1
                segment_previous = segment2;
            end
            if i > 1 && (sum(segment2(:)) > 500) || (sum(segment2(:)) > sum(segment_previous(:))*3 || ...
                    sum(segment2(:)) < 0.10*sum(segment_previous(:)))
                segment2 = segment_previous;
            end
            segment_previous = segment2;
            
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
                title('k-means clustering')
                
                subplot(2,2,1);
                imagesc(timeMIPcrossection);colormap gray;
                title('2X interpolated time MIP')
                
                subplot(2,2,2);
                imagesc(vTimeFrame);colormap gray;
                title('2X interpolated magnitude velocity')

                subplot(2,2,4);
                imagesc(segment2); colormap gray;
                title('vessel mask')
                pause
            end
            
            % calculate flow, diameter and whatever
            maxVelFrame = zeros(1,nframes);
            % area
            area_vol(indexes(i)) = sum(segment2(:))*(fov/res)^2 * (2*r+1)^2/(8*r+1)^2;
            % diameter (based on area measurement, assumes circular area)
            diam_vol(indexes(i)) = 2*sqrt(area_vol(indexes(i))/pi) ;
            
            for j = 1:nframes
                % Apply rotations to velocity components in velocity cross
                % section before computing parameters
                vTimeFrame = segment2.*interp2(0.1*(dir(1)*vCrossection(:,:,1,1,j) + dir(2)*vCrossection(:,:,1,2,j) + ...
                    dir(3)*vCrossection(:,:,1,3,j)),2);
                ind = find(vTimeFrame);
                flowPulsatile(j) = mean(vTimeFrame(ind))*area_vol(indexes(i));
                maxVelFrame(j) = max(max(vTimeFrame));              % max velocity, in cm/s
            end
            
            % pulsatile flow waveform volume
            flowPulsatile_vol(indexes(i),:) = flowPulsatile(:);
            % total flow
            flowPerHeartCycle_vol(indexes(i)) = sum(flowPulsatile)'/(nframes);
            % maximum velocity pixel within the cross section, through time
            maxVel_vol(indexes(i)) = max(maxVelFrame);
            % pulsatility index
            PI_vol(indexes(i)) = abs(max(flowPulsatile)-min(flowPulsatile))/mean(flowPulsatile);
            % resistance index, note that this calculation assumes
            % end-diastole is at the end of the time-resolved waveform
            RI_vol(indexes(i)) = abs(max(flowPulsatile) - flowPulsatile(end))/max(flowPulsatile);
       
        end
    end
end

disp('Done!')