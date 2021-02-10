function [area_vol, diam_vol, flowPerHeartCycle_vol, maxVel_vol, PI_vol, RI_vol, flowPulsatile_vol] = paramMap_params(...
    branchTextList, branchList, res, timeMIP, v,branchMat, nframes, fov)

% tic
global r timeMIPcrossection segment1 vTimeFrameave TestData

d = 3;
Tangent_V = zeros(0,3);

for n = 1:max(branchList(:,4));
    branchActual = branchList(branchList(:,4)==n,:);
    dir_temp = zeros(size(branchActual,1),3);
    for i = 1:size(branchActual,1)
    % extract normal to cross-section
    if i < d+1
        dir = (branchActual(i+d,1:3) - branchActual(i,1:3));
    elseif i >= size(branchActual,1)-d
        dir = (branchActual(i,1:3) - branchActual(i-d,1:3));
    else
        dir = (branchActual(i+d,1:3) - branchActual(i-d,1:3));
    end
    dir_temp(i,:) = dir/norm(dir);
    end
    Tangent_V = [Tangent_V;dir_temp];
end

% This will find a normalized vector perpendicular to the tangent vector
[~,idx_max] = max(abs(Tangent_V),[],2);
idx_max(idx_max==2) = 1;
max_pts = sub2ind(size(Tangent_V),[1:size(Tangent_V,1)]',idx_max);
temp = zeros(size(Tangent_V));
temp(max_pts) = 1;
[~,idx_shift] = max(abs(circshift(temp,1,2)),[],2);
shift_pts = sub2ind(size(Tangent_V),[1:size(Tangent_V,1)]',idx_shift);
V2 = zeros(size(Tangent_V));
V2(max_pts) = Tangent_V(shift_pts);
V2(shift_pts) = -Tangent_V(max_pts);
N = repmat(sqrt(sum(abs(V2).^2,2)),[1 3]);
V2 = V2./N;
%Third vector that is normalized
V3 = cross(Tangent_V,V2);
% toc

% Get the full tangent plane for all the points
r = 6; %Size of plane to select from non interpolated data is r*2+1
InterpVals = 4; % Chose the interpolation between points
Side = r*InterpVals; % Creates the correct number of points for interpolation
Mid = zeros(length(branchList),1);

% tic
% Find x Values on line
temp = repmat(V2(:,1)./InterpVals,[1 Side]);
Test = cumsum(temp,2);
Test2 = -fliplr(Test);
x_val = [Test2 Mid Test];
x_val = bsxfun(@plus,x_val,branchList(:,1));
x_val = reshape(x_val,[numel(x_val) 1]);

% Find y Values on line
temp = repmat(V2(:,2)./InterpVals,[1 Side]);
Test = cumsum(temp,2);
Test2 = -fliplr(Test);
y_val = [Test2 Mid Test];
y_val = bsxfun(@plus,y_val,branchList(:,2));
y_val = reshape(y_val,[numel(y_val) 1]);

% Find z values on the line
temp = repmat(V2(:,3)./InterpVals,[1 Side]);
Test = cumsum(temp,2);
Test2 = -fliplr(Test);
z_val = [Test2 Mid Test];
z_val = bsxfun(@plus,z_val,branchList(:,3));
z_val = reshape(z_val,[numel(z_val) 1]);

% indx_all = sub2ind([res,res,res],floor(x_val),floor(y_val),floor(z_val));
% indx_all = reshape(indx_all,[length(branchList),(Side.*2+1)]);

% At this point the x,y,z values have created a tanget line in 
% the perpedicular plane to the normal vector for all centerline points.

% Find x Values on plane
Mid = zeros(length(branchList)*(Side*2+1),1);
temp = repmat(V3(:,1)./InterpVals,[(Side*2+1) Side]);
Test = cumsum(temp,2);
Test2 = -fliplr(Test);
x_full = [Test2 Mid Test];
x_full = bsxfun(@plus,x_full,x_val);
x_full = reshape(x_full,[length(branchList)*(Side.*2+1).^2,1]);

% Find x Values on plane
temp = repmat(V3(:,2)./InterpVals,[(Side*2+1) Side]);
Test = cumsum(temp,2);
Test2 = -fliplr(Test);
y_full = [Test2 Mid Test];
y_full = bsxfun(@plus,y_full,y_val);
y_full = reshape(y_full,[length(branchList)*(Side.*2+1).^2,1]);

% Find x Values on plane
temp = repmat(V3(:,3)./InterpVals,[(Side*2+1) Side]);
Test = cumsum(temp,2);
Test2 = -fliplr(Test);
z_full = [Test2 Mid Test];
z_full = bsxfun(@plus,z_full,z_val);
z_full = reshape(z_full,[length(branchList)*(Side.*2+1).^2,1]);

x_full = single(x_full);
y_full = single(y_full);
z_full = single(z_full);

x_full = reshape(x_full,[length(branchList),(Side.*2+1).^2]);
y_full = reshape(y_full,[length(branchList),(Side.*2+1).^2]);
z_full = reshape(z_full,[length(branchList),(Side.*2+1).^2]);

% indx_all = sub2ind([res,res,res],floor(x_full),floor(y_full),floor(z_full));
% indx_all = reshape(indx_all,[length(branchList),(Side.*2+1).^2]);

% toc

% tic
x = 1:res;
y = 1:res;
z = 1:res;
vtimeave = mean(v,5); 

% Might use to speed up interpolation time if needed for large matrix sizes.
% SE = ones(10,10,10);
% CD_bin_new = imdilate(CD_bin,SE);

% Get the interpolated velocity data from 3 directions and apply
% multiplication of tangent vector
v1 = interp3(y,x,z,vtimeave(:,:,:,1),y_full(:),x_full(:),z_full(:),'cubic',0);
v2 = interp3(y,x,z,vtimeave(:,:,:,2),y_full(:),x_full(:),z_full(:),'cubic',0);
v3 = interp3(y,x,z,vtimeave(:,:,:,3),y_full(:),x_full(:),z_full(:),'cubic',0);
v1 = reshape(v1,[length(branchList),(Side.*2+1).^2]);
v2 = reshape(v2,[length(branchList),(Side.*2+1).^2]);
v3 = reshape(v3,[length(branchList),(Side.*2+1).^2]);
temp = zeros([size(v1),3]); % used to hold velocity data information
temp(:,:,1) = bsxfun(@times,v1,Tangent_V(:,1));
temp(:,:,2) = bsxfun(@times,v2,Tangent_V(:,2));
temp(:,:,3) = bsxfun(@times,v3,Tangent_V(:,3));
vTimeFrameave = (temp(:,:,1).^2+temp(:,:,2).^2+temp(:,:,3).^2).^(0.5); %Velocity planes for all points

%Interpolation for the complex difference data
CD_int = interp3(y,x,z,timeMIP,y_full(:),x_full(:),z_full(:),'cubic',0);
timeMIPcrossection = reshape(CD_int,[length(branchList),(Side.*2+1).^2]);

clear v1 v2 v3 temp CD_int vtimeave

SE = strel('square', 4);
% warning('off','all')

%Get the centerline point locations
indexes = sub2ind(size(timeMIP), branchList(:,1), branchList(:,2), branchList(:,3));
area_val = zeros(size(Tangent_V,1),1);
segment1 = zeros([length(branchList),(Side.*2+1).^2]);

for n = 1:size(Tangent_V,1)
   clust = horzcat(timeMIPcrossection(n,:)',vTimeFrameave(n,:)');
    [idx,ctrs] = kmeans(clust,2);
    segment2 = zeros([Side.*2+1,Side.*2+1]);
    segment2(idx==2) = 1;
        if segment2(round(numel(segment2(:,1))/2),round(numel(segment2(1,:))/2)) == 0
        segment2 = -1*segment2+1;
        end
    segment2 = imerode(segment2,SE);
    segment2 = regiongrowing(segment2,round(length(segment2)/2),round(length(segment2)/2));
    segment2 = imdilate(segment2, SE);
    
    % area
    area_val(n) = sum(segment2(:))*((fov/res)/InterpVals)^2;
    segment2 = reshape(segment2,[1,(Side.*2+1).^2]);
    segment1(n,:) = segment2;
          
end

% diameter (based on area measurement, assumes circular area)
     diam_val = 2*sqrt(area_val./pi);  

            % calculate flow, diameter and whatever
            maxVelFrame = zeros(1,nframes);
            
     flowPulsatile = zeros(size(diam_val,1),nframes);
     maxVelFrame = zeros(size(diam_val,1),nframes);
     % initialize pulsatile volume 
     flowPulsatile_vol = zeros(res^3,nframes);
     
for j = 1:nframes
                
                v1 = interp3(y,x,z,v(:,:,:,1,j),y_full(:),x_full(:),z_full(:),'cubic',0);
                v2 = interp3(y,x,z,v(:,:,:,2,j),y_full(:),x_full(:),z_full(:),'cubic',0);
                v3 = interp3(y,x,z,v(:,:,:,3,j),y_full(:),x_full(:),z_full(:),'cubic',0);
                v1 = reshape(v1,[length(branchList),(Side.*2+1).^2]);
                v2 = reshape(v2,[length(branchList),(Side.*2+1).^2]);
                v3 = reshape(v3,[length(branchList),(Side.*2+1).^2]);
                v1 = bsxfun(@times,v1,Tangent_V(:,1));
                v2 = bsxfun(@times,v2,Tangent_V(:,2));
                v3 = bsxfun(@times,v3,Tangent_V(:,3));
                
                % Apply rotations to velocity components in velocity cross
                % section before computing parameters
                vTimeFrame = segment1.*(0.1*(v1 + v2 + v3));
                vTimeFramerowMean = sum(vTimeFrame,2) ./ sum(vTimeFrame~=0,2);
                flowPulsatile(:,j) = vTimeFramerowMean.*area_val;
                maxVelFrame(:,j) = max(vTimeFrame,[],2);              % max velocity, in cm/s
                flowPulsatile_vol(indexes,j) = flowPulsatile(:,j);
end

PI_val = abs(max(flowPulsatile,[],2)-min(flowPulsatile,[],2))./mean(flowPulsatile,2);
% resistance index, note that this calculation assumes
% end-diastole is at the end of the time-resolved wavefor
RI_val = abs(max(flowPulsatile,[],2) - flowPulsatile(:,nframes))./max(flowPulsatile,[],2);

% need to initialize 3D volumes for each of these parameters
area_vol = zeros(size(timeMIP));
area_vol(indexes) = area_val;
diam_vol = zeros(size(timeMIP));
diam_vol(indexes) = diam_val;
flowPerHeartCycle_vol = zeros(size(timeMIP));
maxVel_vol = zeros(size(timeMIP));
maxVel_vol(indexes) = max(maxVelFrame,[],2);
PI_vol = zeros(size(timeMIP));
RI_vol = zeros(size(timeMIP));
PI_vol(indexes) = PI_val;
RI_vol(indexes) = RI_val;
% total flow
flowPerHeartCycle_vol(indexes) = sum(flowPulsatile,2)./(nframes);


% 
% toc

% 
% 
% r = 6;                          % extracted cross sections will be 2r+1 squares
% 
% disp('Calculating flow parameters for all vessels ')
% SE = strel('square', 4);        % this will be used for erosion and dilation later
% % begin looping over all branches within volume
% for k = 1:length(branchTextList)
%     % extracted orthogonal cross sections will be based on i+d and i-d
%     d = 3;                      
%     % find indices from branchList, build x,y,z locations in branch
%     indices = find(branchList(:,4) == k);
%     branchActual = zeros(numel(indices),3);
%     branchActual(:,1) = branchList(indices,1);
%     branchActual(:,2) = branchList(indices,2);
%     branchActual(:,3) = branchList(indices,3);
%     indexes = find(branchMat == k);         % same as doing sub2ind on x,y,z
%     % return zeros if branch is less that 2*d in length
%     if size(branchActual(:,1)) < 2*d
%         flowPerHeartCycle_vol(indexes) = 0;
%         area_vol(indexes) = 0;
%         diam_vol(indexes) = 0;
%         maxVel_vol(indexes) = 0;
%         PI_vol(indexes) = 0;
%     else
%         % now loop over branch to find parameters
%         for i = 1:size(branchActual,1)
%             % extract normal to cross-section
%             if i < d+1
%                 dir = (branchActual(i+d,1:3) - branchActual(i,1:3));
%             elseif i >= size(branchActual,1)-d
%                 dir = (branchActual(i,1:3) - branchActual(i-d,1:3));
%             else
%                 dir = (branchActual(i+d,1:3) - branchActual(i-d,1:3));
%             end
%             dir = dir/norm(dir);
%             
%             if dir(2) == 0 && dir(1) == 0
%                 angle1 = 0;
%             else
%                 angle1 = atan(dir(2)/dir(1))*180/pi;                    % x-y angle in degrees
%             end
%             if dir(3) == 0 && dir(2) == 0
%                 angle2 = 0;
%             else
%                 angle2 = atan(dir(3)/sqrt(dir(2)^2+dir(1)^2))*180/pi;   % y-z angle in degrees
%             end
%             
%             if dir(1) < 0
%                 angle1 = angle1 + 180;                                  % compensate for phase-wraps
%             end
%             
%             % velocity subsets
%             vSubset = double(v(branchActual(i,1)-r:branchActual(i,1)+r, branchActual(i,2)-r:branchActual(i,2)+r, ...
%                 branchActual(i,3)-r:branchActual(i,3)+r, :, :));
%             
%             % rotate subsets
%             B = imrotate(vSubset, -angle1, 'bilinear', 'crop');
%             D = permute(B, [1 3 2 4 5]);
%             F = imrotate(D, (90-angle2), 'bilinear', 'crop');
%             H = ipermute(F, [1 3 2 4 5]);
%             
%             vCrossection = zeros(2*r+1, 2*r+1, 1, 3, nframes);
%             vCrossection(:,:,1,1,:) = H(:,:,r+1,1,:);
%             vCrossection(:,:,1,2,:) = H(:,:,r+1,2,:);
%             vCrossection(:,:,1,3,:) = H(:,:,r+1,3,:);
%             
%             % Extract temporal mean of sum-squared velocity cross section,
%             % i.e. the temporal mean of the speed image
%             vTimeFrame = interp2(0.1*((dir(1)*mean(vCrossection(:,:,1,1,:),5)).^2+ (dir(2)*mean(vCrossection(:,:,1,2,:),5)).^2+...
%                 (dir(3)*mean(vCrossection(:,:,1,3,:),5)).^2).^(0.5),2);
%             
%             % Do the same extraction and rotation for timeMIP
%             timeMIPsubset = timeMIP(branchActual(i,1)-r:branchActual(i,1)+r, ...
%                 branchActual(i,2)-r:branchActual(i,2)+r, branchActual(i,3)-r:branchActual(i,3)+r);
%             H = imrotate(timeMIPsubset, -angle1, 'bilinear', 'crop');
%             I = permute(H, [1 3 2]);
%             J = imrotate(I, (90-angle2), 'bilinear', 'crop');
%             K = ipermute(J, [1 3 2]);
%             timeMIPcrossection = K(:,:,r+1);
%             timeMIPcrossection = interp2(timeMIPcrossection,2);
%             timeMIPcrossection(round(length(timeMIPcrossection)/2)-1:round(length(timeMIPcrossection)/2)+1,...
%                 round(length(timeMIPcrossection)/2)-1:round(length(timeMIPcrossection)/2)+1) = max(timeMIPcrossection(:));
%             
%             % kmeans clustering
%             vVect = (reshape(vTimeFrame,numel(vTimeFrame(1,:))^2,1));
%             timeMIPvect = (reshape(timeMIPcrossection,numel(timeMIPcrossection(1,:))^2,1));
%             
%             clust = horzcat(timeMIPvect,vVect);
%             [idx,ctrs] = kmeans(clust,2);
%             segment2 = zeros(size(timeMIPcrossection));
%             segment2(idx==2) = 1;
%             if segment2(round(numel(segment2(:,1))/2),round(numel(segment2(1,:))/2)) == 0
%                 segment2 = -1*segment2+1;
%             end
%             segment2 = imerode(segment2,SE);
%             segment2 = regiongrowing(segment2,round(length(segment2)/2),round(length(segment2)/2));
%             segment2 = imdilate(segment2, SE);
%             
%             % Perform some area check by 1) making sure values aren't too
%             % large and by comparing to previous value within the branch
%             if i ==1
%                 segment_previous = segment2;
%             end
%             if i > 1 && (sum(segment2(:)) > 500) || (sum(segment2(:)) > sum(segment_previous(:))*3 || ...
%                     sum(segment2(:)) < 0.10*sum(segment_previous(:)))
%                 segment2 = segment_previous;
%             end
%             segment_previous = segment2;
%             
%             % plotting, change to 1 to view how the k-means is working 
%             if 0 
%                 disp(i)
%                 figure(4); clf;
%                 
%                 subplot(2,2,3);
%                 plot(clust(idx==1,1),clust(idx==1,2),'r.','MarkerSize',12)
%                 hold on
%                 plot(clust(idx==2,1),clust(idx==2,2),'b.','MarkerSize',12)
%                 plot(ctrs(:,1),ctrs(:,2),'kx',...
%                     'MarkerSize',12,'LineWidth',2)
%                 plot(ctrs(:,1),ctrs(:,2),'ko',...
%                     'MarkerSize',12,'LineWidth',2)
%                 legend('Cluster 1','Cluster 2','Centroids',...
%                     'Location','NW')
%                 title('k-means clustering')
%                 
%                 subplot(2,2,1);
%                 imagesc(timeMIPcrossection);colormap gray;
%                 title('2X interpolated time MIP')
%                 
%                 subplot(2,2,2);
%                 imagesc(vTimeFrame);colormap gray;
%                 title('2X interpolated magnitude velocity')
% 
%                 subplot(2,2,4);
%                 imagesc(segment2); colormap gray;
%                 title('vessel mask')
%                 pause
%             end
%             
%             % calculate flow, diameter and whatever
%             maxVelFrame = zeros(1,nframes);
%             % area
%             area_vol(indexes(i)) = sum(segment2(:))*(fov/res)^2 * (2*r+1)^2/(8*r+1)^2;
%             % diameter (based on area measurement, assumes circular area)
%             diam_vol(indexes(i)) = 2*sqrt(area_vol(indexes(i))/pi) ;
%             
%             for j = 1:nframes
%                 % Apply rotations to velocity components in velocity cross
%                 % section before computing parameters
%                 vTimeFrame = segment2.*interp2(0.1*(dir(1)*vCrossection(:,:,1,1,j) + dir(2)*vCrossection(:,:,1,2,j) + ...
%                     dir(3)*vCrossection(:,:,1,3,j)),2);
%                 ind = find(vTimeFrame);
%                 flowPulsatile(j) = mean(vTimeFrame(ind))*area_vol(indexes(i));
%                 maxVelFrame(j) = max(max(vTimeFrame));              % max velocity, in cm/s
%             end
%             
%             % pulsatile flow waveform volume
%             flowPulsatile_vol(indexes(i),:) = flowPulsatile(:);
%             % total flow
%             flowPerHeartCycle_vol(indexes(i)) = sum(flowPulsatile)'/(nframes);
%             % maximum velocity pixel within the cross section, through time
%             maxVel_vol(indexes(i)) = max(maxVelFrame);
%             % pulsatility index
%             PI_vol(indexes(i)) = abs(max(flowPulsatile)-min(flowPulsatile))/mean(flowPulsatile);
%             % resistance index, note that this calculation assumes
%             % end-diastole is at the end of the time-resolved waveform
%             RI_vol(indexes(i)) = abs(max(flowPulsatile) - flowPulsatile(end))/max(flowPulsatile);
%        
%         end
%     end
% end

disp('Done!')