function [ Planes ] = makeITPlane( branchList )
%makeITPlane Creates a nice plane associated with the cursor point
%   Show the tangent planes that are used in the calculations for the
%   flow,area,PI,etc.

% Created by: Carson Hoffman
% Date: 03/21/2017
% University of Wisconsin Madison

% Getting the tangent Vectors at all points
d = 4; % Shift to be used for the tangent vector
Tangent_V = zeros(0,3); % Initialize tangent vector list

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
V2(shift_pts) = -Tangent_V(max_pts); % Vector 1 that is used to created the perdendicular plane
N = repmat(sqrt(sum(abs(V2).^2,2)),[1 3]);
V2 = V2./N;
V3 = cross(Tangent_V,V2);% Vector 2 that is used created the perdendicular plane



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get the full tangent plane for all the points

n  = 12; %Decides the side lengths is matched to current calc value
Side = floor(n/2);
Mid = zeros(length(branchList),1);

InterpVals = 1; % this can be used to interpolate inbetween points in the plane

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

End = size(x_full,2);
Sides = Side*2;

% For all plane visualization. 
planex = [x_full(:,1),x_full(:,Sides),x_full(:,End),x_full(:,End-Sides)];
planey = [y_full(:,1),y_full(:,Sides),y_full(:,End),y_full(:,End-Sides)];
planez = [z_full(:,1),z_full(:,Sides),z_full(:,End),z_full(:,End-Sides)];

Planes = zeros([size(planex),3]);
Planes(:,:,1) = planex;
Planes(:,:,2) = planey;
Planes(:,:,3) = planez;

end

