%Loading and analysis in CL tool
[directory, nframes, res, fov, timeres, v, MAG, timeMIP, vMean] = loadpcvipr();
timeMIP2 = ones(size(timeMIP));
timeMIP_crop = timeMIP.*timeMIP2;
vMean_crop = zeros(size(vMean));
vMean_crop(:,:,:,1) = timeMIP2.*vMean(:,:,:,1);
vMean_crop(:,:,:,2) = timeMIP2.*vMean(:,:,:,2);
vMean_crop(:,:,:,3) = timeMIP2.*vMean(:,:,:,3);
normed_MIP = timeMIP_crop(:)./max(timeMIP_crop(:));
[muhat,sigmahat] = normfit(normed_MIP);
segment = zeros(size(timeMIP_crop));
segment(normed_MIP>muhat+4.5*sigmahat) = 1;
segment = bwareaopen(segment,round(sum(segment(:)).*0.005),6); %The value at the end of the commnad in the minimum area of each segment to keep
segment = imfill(segment,'holes'); % Fill in holes created by slow flow on the inside of vessels
segment = single(segment);
sortingCriteria = 3;
spurLength = 8;
% vascularTreeReconstr
% 1. 'coarse'. Uses a PCthreshDev of 0.25 and a box filter to remove noise
%   in the reconstructed vascular tree. Misses some vessels.
% 2. 'fine' Uses a PCthreshDev of 0.3 and no filter. Noisier than 'coarse',
%   but finds small vessels more easily.
vascularTreeReconstr = 'coarse';
[CL,branchMat, branchList, branchTextList] = feature_extraction( ...
sortingCriteria, spurLength, vMean, segment);

[area_vol, diam_vol, flowPerHeartCycle_vol, maxVel_vol, PI_vol, RI_vol, flowPulsatile_vol] = paramMap_params_new(branchTextList, branchList, res, timeMIP, v,branchMat, nframes, fov);
[Planes] = makeITPlane(branchList);



%%
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

%%
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

CD_mask = interp3(y,x,z,segment,y_full(:),x_full(:),z_full(:),'cubic',0);
MASKcrossection = reshape(CD_mask>.5,[length(branchList),(Side.*2+1).^2]);

temp = MASKcrossection.*timeMIPcrossection;
G1CD = sum(temp,2)./sum(MASKcrossection,2);
temp = MASKcrossection.*vTimeFrameave;
G1V = sum(temp,2)./sum(MASKcrossection,2);

temp = ~MASKcrossection.*timeMIPcrossection;
G2CD = sum(temp,2)./sum(~MASKcrossection,2);
temp = ~MASKcrossection.*vTimeFrameave;
G2V = sum(temp,2)./sum(~MASKcrossection,2);

clear v1 v2 v3 temp CD_int vtimeave CD_mask

SE = strel('square', 4);
% warning('off','all')

%Get the centerline point locations
indexes = sub2ind(size(timeMIP), branchList(:,1), branchList(:,2), branchList(:,3));
area_val = zeros(size(Tangent_V,1),1);
segment3 = zeros([length(branchList),(Side.*2+1).^2]);

tic
for n = 1:size(Tangent_V,1)
   C = [G1CD(n),G1V(n);G2CD(n),G2V(n)];
   clust = horzcat(timeMIPcrossection(n,:)',vTimeFrameave(n,:)');
   [idx,ctrs] = kmeans(clust,2,'Start',C);
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
    segment3(n,:) = segment2;       
end
toc

Diff = abs(segment1-segment3);

for h = 1:size(segment1,1);

%View the images
Mask = reshape(MASKcrossection(h,:),[(Side.*2+1),(Side.*2+1)]);
COMdif = reshape(Diff(h,:),[(Side.*2+1),(Side.*2+1)]);
VelM = reshape(vTimeFrameave(h,:),[(Side.*2+1),(Side.*2+1)]);
imshow(COMdif,[]);
end


figure;
imshow(Mask,[]);
figure;
imshow(COMdif,[]);
figure;
imshow(VelM,[]);




%%


