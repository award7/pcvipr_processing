classdef calculateParameters < handle
    %{
    The function calculates flow, calculate_diameter and maximum Velocity along vessels
    in cross sections with normal in the vessel direction.

    INPUT
    1. branchActual: the branch to investigate in list form, sorted from
        start to end of vessel
        *vessel_struct field from centerline_tool.mlapp dervied from
        SelectVessel class
    2. TimeMIP: TimeMIP array
        *loadVIPR class property
    3. v: Velocity array
        *loadVIPR class property
    4. NoFrames: number of reconstructed frames
        *loadVIPR class property 

    Author:   Erik Spaak
    Updated:  Eric Schrauben, University of Wisconsin - Madison, 05/2015
    Updated for OOP: Aaron Ward, 11/05/2020
    %}
    
    properties (Access = public)
        Area;
        Diameter;
        MeanVelocity;
        MaxVelocity;
        FlowPerHeartCycle;
        WallShearStress;
        PulsatilityIndex;
        FlowPulsatile;
    end
    
    properties (Access = private, Transient)
        % distance backward and frontward from reference point in direction estimation
        % number of points to use for cross section extraction
        % extracted orthogonal cross sections will be based on k+d and k-d
        d = 4;
        
        % cross section radial size
        r = 6;
        SE = strel('square', 4);
        
        % in kg/(m s^)
        Viscosity = 0.0045;
        
        % just to make calculate_diameter calculation work
        N = 1;
    end
    
    methods
        % constructor
        function self = calculateParameters()
        end
        
        function s = main(self, VIPR, branchActual, varargin)
            branchSize = size(branchActual, 1);
            if branchSize < 9
                self.d = 3;
            end
            
            for k = 1:branchSize
                direction = self.extract_normal2cross(k, branchActual);
                angle1 = self.xy_angle(direction);
                angle2 = self.yz_angle(direction);
                vSubset = self.velocity_subsets(k, VIPR.Velocity, branchActual);
                vCrossection = self.rotate_subsets(vSubset, angle1, angle2, VIPR.NoFrames);
                vTimeFrame = self.temporal_means(direction, vCrossection);
                timeMIPCrossSection = self.rotate_mip(k, branchActual, VIPR.TimeMIP, angle1, angle2);
                [clust, ctrs, idx] = self.cluster(vTimeFrame, timeMIPCrossSection);
                segment = self.dilate_segment(timeMIPCrossSection, idx);

                if nargin > 3
                    try
                        % viewKmeansClusters = varargin{1};
                        self.view_kmeans(k, clust, ctrs, timeMIPCrossSection, segment, vTimeFrame);
                    catch ME
                        switch ME.identifier
                            case 'MATLAB:badsubscript'
                                viewKmeansClusters = [];
                        end
                    end
                end
              
                self.calculate_area(k, segment, VIPR.FOV, VIPR.Resolution);
                self.calculate_diameter(k);
                maxVelFrame = zeros(1, VIPR.NoFrames);
                for j = 1:VIPR.NoFrames
                    vTimeFrame = segment.* interp2(0.1* (...
                        direction(1)* vCrossection(:,:,1,1,j)+ ...
                        direction(2)* vCrossection(:,:,1,2,j)+ ...
                        direction(3)* vCrossection(:,:,1,3,j)), 2);
                    ind = find(vTimeFrame);
                    self.calculate_flow_pulsatile(k, j, vTimeFrame, ind);
                    maxVelFrame(j) = max(max(vTimeFrame));
                    meanVelFrame(j) = mean(vTimeFrame(ind));
                    wssFrame(k, j) = self.calculate_wss_per_frame(k, j, maxVelFrame);
                end
                self.calculate_max_velocity(k, maxVelFrame);
                self.calculate_mean_velocity(k, meanVelFrame);
                self.calculate_wss_simple_avg(k, wssFrame, VIPR.NoFrames);
                self.calculate_pulsatility_index(k);
            end
            self.calculate_flow_per_heart_cycle(VIPR.NoFrames);
            s = self.get_as_struct();
        end
        
        function s = get_as_struct(self)
            s.Area = self.Area;
            s.Diameter = self.Diameter;
            s.MeanVelocity = self.MeanVelocity;
            s.MaxVelocity = self.MaxVelocity;
            s.FlowPerHeartCycle = self.FlowPerHeartCycle;
            s.WallShearStress = self.WallShearStress;
            s.PulsatilityIndex = self.PulsatilityIndex;
            s.FlowPulsatile = self.FlowPulsatile;
        end
        
        function direction = extract_normal2cross(self, k, branchActual)
            % extract normal to cross-section
            if k < self.d + 1
                direction = branchActual(k + self.d, 1:3) - branchActual(k, 1:3);
            elseif k >= size(branchActual, 1) - self.d
                direction = branchActual(k, 1:3)- branchActual(k - self.d, 1:3);
            else
                direction = branchActual(k + self.d, 1:3) - branchActual(k - self.d, 1:3);
            end
            direction = direction / norm(direction);
        end
        
        function vSubset = velocity_subsets(self, k, v, branchActual)
            vSubset = double(v(...
                branchActual(k,1)-self.r:branchActual(k,1)+self.r, ...
                branchActual(k,2)-self.r:branchActual(k,2)+self.r, ...
                branchActual(k,3)-self.r:branchActual(k,3)+self.r, :, :));
        end
        
        function vCrossection = rotate_subsets(self, vSubset, angle1, angle2, NoFrames)
            % rotate subsets
            B = imrotate(vSubset, -angle1, 'bilinear', 'crop');
            D = permute(B, [1 3 2 4 5]);

            F = imrotate(D, (90-angle2), 'bilinear', 'crop');
            H = ipermute(F, [1 3 2 4 5]);

            vCrossection = zeros(2*self.r+1, 2*self.r+1, 1, 3, NoFrames);
            vCrossection(:,:,1,1,:) = H(:,:,self.r+1,1,:);
            vCrossection(:,:,1,2,:) = H(:,:,self.r+1,2,:);
            vCrossection(:,:,1,3,:) = H(:,:,self.r+1,3,:);
        end

        function timeMIPCrossSection = rotate_mip(self, k, branchActual, timeMIP, angle1, angle2)
            % Do the same extraction and rotation for TimeMIP
            timeMIPSubset = timeMIP(...
                branchActual(k,1)-self.r : branchActual(k,1)+self.r, ...
                branchActual(k,2)-self.r : branchActual(k,2)+self.r, ...
                branchActual(k,3)-self.r : branchActual(k,3)+self.r);
            
            H = imrotate(timeMIPSubset, -angle1, 'bilinear', 'crop');
            I = permute(H, [1 3 2]);
            J = imrotate(I, (90-angle2), 'bilinear', 'crop');
            K = ipermute(J, [1 3 2]);
            
            timeMIPCrossSection = K(:,:,self.r+1);
            timeMIPCrossSection = interp2(timeMIPCrossSection,2);
            timeMIPCrossSection(...
                round(length(timeMIPCrossSection)/2)-1:round(length(timeMIPCrossSection)/2)+1,...
                round(length(timeMIPCrossSection)/2)-1:round(length(timeMIPCrossSection)/2)+1) = max(timeMIPCrossSection(:));
        end
 
        function segment = dilate_segment(self, timeMIPCrossSection, idx)
            segment = zeros(size(timeMIPCrossSection));
            segment(idx==2) = 1;
            if segment(round(numel(segment(:,1))/2), round(numel(segment(1,:))/2)) == 0
                segment = -1*segment+1;
            end
            segment = imerode(segment, self.SE);
            segment = self.region_growing(segment, round(length(segment)/2), round(length(segment)/2));
            segment = imdilate(segment, self.SE);
        end
        
        function calculate_area(self, k, segment, FOV, Resolution)
            % in cm^2
            self.Area(k) = sum(segment(:)) * (FOV/Resolution)^2 * (2*self.r+1)^2 / (8*self.r+1)^2;
        end
        
        function calculate_diameter(self, k)
            self.Diameter(k) = 2*sqrt(self.Area(k)/pi);
        end
        
        function calculate_max_velocity(self, k, maxVelFrame)
            % max Velocity, in cm/s
            self.MaxVelocity(k) = max(maxVelFrame);
        end
        
        function calculate_mean_velocity(self, k, meanVelFrame)
            self.MeanVelocity(k) = mean(meanVelFrame);
        end
        
        function calculate_flow_pulsatile(self, k, j, vTimeFrame, ind)
            self.FlowPulsatile(k, j) = mean(vTimeFrame(ind)) * self.Area(k);
        end
        
        function calculate_wss_simple_avg(self, k, wssFrame, NoFrames)
            self.WallShearStress(k) = real(sum(wssFrame(k,:)) / NoFrames);
        end
        
        function wssFrame = calculate_wss_per_frame(self, k, j, maxVelFrame)
            % Simple WallShearStress calculation based on the max Velocity and the Diameter.
            % Assumes parabolic flow profile
            % in Pa
            wssFrame = self.Viscosity * maxVelFrame(j) * 0.01 * ...
                sqrt(2 * pi * maxVelFrame(j) * 0.01 / (self.FlowPulsatile(k,j) * 1e-6));
        end
        
        function calculate_pulsatility_index(self, k)
            self.PulsatilityIndex(k) = (max(self.FlowPulsatile(k,:)) - min(self.FlowPulsatile(k,:))) / mean(self.FlowPulsatile(k,:));
        end
        
        function calculate_flow_per_heart_cycle(self, NoFrames)
            % calculate flow in ml/s. go from mm^2 to cm^2 with the factor 1e-2, and
            % from mm/s to cm/s with the factor 1e-1
            self.FlowPerHeartCycle = sum(self.FlowPulsatile, 2)' / (NoFrames);
        end
        
    end
      
    methods(Static)

        function angle1 = xy_angle(direction)
            % x-y angle in degrees
            if direction(1) == 0 && direction(2) == 0
                angle1 = 0;
            else
                angle1 = atan(direction(2)/direction(1))*180/pi;  
                if direction(1) < 0
                    % compensate for phase-wraps
                    angle1 = angle1 + 180;
                end
            end
        end
        
        function angle2 = yz_angle(direction)
            % y-z angle in degrees
            if direction(2) == 0 && direction(3) == 0
                angle2 = 0;
            else
                angle2 = atan(direction(3)/sqrt(direction(2)^2+direction(1)^2))*180/pi;   
            end
        end
            
        function vTimeFrame = temporal_means(direction, vCrossection)
            % Extract temporal mean of sum-squared Velocity cross section,
            % i.e. the temporal mean of the speed image
            vTimeFrame = interp2(0.1*(...
                (direction(1)*mean(vCrossection(:,:,1,1,:),5)).^2 +...
                (direction(2)*mean(vCrossection(:,:,1,2,:),5)).^2 +...
                (direction(3)*mean(vCrossection(:,:,1,3,:),5)).^2).^(0.5), 2);
        end
        
        function [clust, ctrs, idx] = cluster(vTimeFrame, timeMIPCrossSection)
            % kmeans clustering
            velcoityVector = (reshape(vTimeFrame,numel(vTimeFrame(1,:))^2,1));
            timeMIPVector = (reshape(timeMIPCrossSection,numel(timeMIPCrossSection(1,:))^2,1));
            clust = horzcat(timeMIPVector, velcoityVector);
            [idx, ctrs] = kmeans(clust, 2);
        end
      
        function J = region_growing(I, x, y, regionMaxDistance)
            %{ 
            This function performs "region growing" in an image from a specified seedpoint (x,y)
            
            J = region_growing(I,x,y,t) 
            
            I : input image 
            J : logical output image of region
            x,y : the position of the seedpoint (if not given uses function getpts)
            t : maximum intensity distance (defaults to 0.2)
            
            The region is iteratively grown by comparing all unallocated neighbouring pixels to the region. 
            The difference between a pixel's intensity value and the region's mean, 
            is used as a measure of similarity. The pixel with the smallest difference 
            measured this way is allocated to the respective region. 
            This process stops when the intensity difference between region mean and
            new pixel become larger than a certain treshold (t)
            
            Example:
            
            I = im2double(imread('medtest.png'));
            x=198; y=359;
            J = region_growing(I,x,y,0.2); 
            figure, imshow(I+J);
            
            Author: D. Kroon, University of Twente
            %}

            if(exist('regionMaxDistance', 'var')==0)
                regionMaxDistance = 0.2;
            end
            
            if(exist('y', 'var')==0)
                figure;
                imshow(I,[]); 
                [y,x] = getpts; 
                y = round(y(1)); 
                x = round(x(1)); 
            end

            % Output 
            J = zeros(size(I)); 
            
            % Dimensions of input image
            Isizes = size(I); 

            % The mean of the segmented region
            regionMean = I(x,y); 
            
            % Number of pixels in region
            regionSize = 1; 

            % Free memory to store neighbours of the (segmented) region
            negFree = 10000; 
            negPos = 0;
            negList = zeros(negFree, 3); 

            % Distance of the region newest pixel to the regio mean
            pixDist = 0; 

            % Neighbor locations (footprint)
            neigb = [-1 0; 1 0; 0 -1;0 1];

            % Start regiogrowing until distance between regio and posible new pixels become
            % higher than a certain treshold
            while(pixDist < regionMaxDistance && regionSize < numel(I))

                % Add new neighbors pixels
                for j = 1:4
                    % Calculate the neighbour coordinate
                    xn = x + neigb(j, 1);
                    yn = y + neigb(j, 2);

                    % Check if neighbour is inside or outside the image
                    ins = (xn >= 1) && (yn >= 1) && (xn <= Isizes(1)) && (yn <= Isizes(2));

                    % Add neighbor if inside and not already part of the segmented Area
                    if(ins && (J(xn, yn)==0)) 
                            negPos = negPos + 1;
                            negList(negPos, :) = [xn yn I(xn, yn)]; 
                            J(xn, yn) = 1;
                    end
                end

                % Add a new block of free memory
                if(negPos+10 > negFree)
                    negFree = negFree + 10000; 
                    negList((negPos + 1):negFree, :) = 0; 
                end

                % Add pixel with intensity nearest to the mean of the region, to the region
                dist = abs(negList(1:negPos, 3) - regionMean);
                [pixDist, index] = min(dist);
                J(x,y) = 2;
                regionSize = regionSize+1;

                % Calculate the new mean of the region
                regionMean = (regionMean * regionSize + negList(index, 3)) / (regionSize + 1);

                % Save the x and y coordinates of the pixel (for the neighbour add proccess)
                x = negList(index, 1);
                y = negList(index, 2);

                % Remove the pixel from the neighbour (check) list
                negList(index, :) = negList(negPos, :);
                negPos = negPos - 1;
            end

            % Return the segmented Area as logical matrix
            J = J > 1;
        end
        
        function view_kmeans(k, clust, ctrs, timeMIPCrossSection, segment, vTimeFrame)
            disp(k)
            figure(4); 
            clf;
            subplot(2,2,3);
            plot(clust(idx==1, 1), clust(idx==1, 2), 'r.', 'MarkerSize', 12)
            hold on
            
            plot(clust(idx==2, 1), clust(idx==2, 2), 'b.', 'MarkerSize', 12)
            plot(ctrs(:, 1),ctrs(:, 2), 'kx', 'MarkerSize', 12, 'LineWidth', 2)
            plot(ctrs(:, 1), ctrs(:, 2), 'ko', 'MarkerSize', 12, 'LineWidth', 2)
            legend('Cluster 1', 'Cluster 2', 'Centroids', 'Location', 'NW')
            title('k-means clustering'); 
            hold off;

            subplot(2,2,1);
            imagesc(timeMIPCrossSection);
            colormap gray;
            title('2X interpolated time MIP'); 

            subplot(2,2,2);
            imagesc(vTimeFrame);
            colormap gray;
            title('2X interpolated Velocity magnitude')
            % c = colorbar;
            % set(get(c,'xlabel'),'String', 'Velocity (m/s)');

            subplot(2,2,4);
            imagesc(segment); 
            colormap gray;
            title('vessel mask');
            pause
        end     
  
    end
    
end
