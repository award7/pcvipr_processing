classdef makeITPlane < handle
    %{ 
    Creates a nice plane associated with the cursor point
    Show the tangent planes that are used in the calculations for the
    flow,area,PI,etc.

    Created by: Carson Hoffman
    Date: 03/21/2017
    University of Wisconsin Madison

    Updated to OOP: Aaron Ward
    Date: 11/24/2020
    University of Wisconsin-Madison 
    %}
    
    properties (Access = private, Transient)
        % Decides the side lengths is matched to current calc value
        side_length = 6;
        
        % double side_length
        side_count = 12;
        
        % this can be used to interpolate inbetween points in the plane
        InterpVals = 1;
    end
    
    properties
        plane_x;
        plane_y;
        plane_z;
    end
    
    methods

        function self = makeITPlane(branchList)
            tangent_vector = self.getTangentVectors(branchList);
            [line_vector, plane_vector] = self.normalizedVector(tangent_vector);
            
            x_line = self.lineVals(branchList, line_vector, 'x');
            y_line = self.lineVals(branchList, line_vector, 'y');
            z_line = self.lineVals(branchList, line_vector, 'z');
            
            % At this point the x,y,z values have created a tanget line in 
            % the perpedicular plane to the normal vector for all centerline points.

            x_plane = self.planeVals(branchList, plane_vector, x_line, 'x');
            y_plane = self.planeVals(branchList, plane_vector, y_line, 'y');
            z_plane = self.planeVals(branchList, plane_vector, z_line, 'z');

            self.planeVisualization(x_plane, 'x');
            self.planeVisualization(y_plane, 'y');
            self.planeVisualization(z_plane, 'z');
        end

    end
    
    methods(Access = private)
        
        function val = lineVals(self, branchList, line_vector, axis)
            % Find x, y, z Values on line
            
            switch axis
                case 'x'
                    idx = 1;
                case 'y'
                    idx = 2;
                case 'z'
                    idx = 3;
            end
            
            mid = zeros(length(branchList), 1);
            temp = repmat(line_vector(:, idx)./self.InterpVals,[1 self.side_length]);
            Test = cumsum(temp, 2);
            Test2 = -fliplr(Test);
            val = [Test2 mid Test];
            val = bsxfun(@plus, val, branchList(:, idx));
            val = reshape(val, [numel(val) 1]);
        end

        function val = planeVals(self, branchList, plane_vector, line_val, axis)
            switch axis
                case 'x'
                    idx = 1;
                case 'y'
                    idx = 2;
                case 'z'
                    idx = 3;
            end
            
            % Find Values on plane
            mid = zeros(length(branchList)*(self.side_length*2+1),1);
            temp = repmat(plane_vector(:, idx)./self.InterpVals,[(self.side_length*2+1) self.side_length]);
            Test = cumsum(temp,2);
            Test2 = -fliplr(Test);
            
            val = [Test2 mid Test];
            val = bsxfun(@plus, val, line_val);
            val = reshape(val, [length(branchList)*(self.side_length .*2 + 1) .^2, 1]);
            
            val = single(val);
            val = reshape(val, [length(branchList), (self.side_length .*2 + 1) .^2]);
        end

        function planeVisualization(self, plane_val, axis)
            % For all plane visualization
            
            % move to a setProperty fcn?
            end_val = size(plane_val, 2);
            
            plane = [plane_val(:, 1), ...
                plane_val(:, self.side_count), ...
                plane_val(:, end_val), ...
                plane_val(:, end_val - self.side_count)];
            
            switch axis
                case 'x'
                    % idx = 1;
                    self.plane_x = plane;
                case 'y'
                    % idx = 2;
                    self.plane_y = plane;
                case 'z'
                    % idx = 3;
                    self.plane_z = plane;
            end
        end

    end
    
    methods(Static, Access = private)
        
        function tangent_vector = getTangentVectors(branchList)
            % Initialize tangent vector list
            tangent_vector = zeros(0,3);
            
            % Shift to be used for the tangent vector
            d = 4;
            
            % Get the tangent Vectors at all points
            for k = 1:max(branchList(:, 4))
                branchActual = branchList(branchList(:, 4)==k, :);
                dir_temp = zeros(size(branchActual, 1), 3);
                for m = 1:size(branchActual, 1)
                    % extract normal to cross-section
                    if m < d + 1
                        direction = (branchActual(m + d, 1:3) - branchActual(m, 1:3));
                    elseif m >= size(branchActual, 1) - d
                        direction = (branchActual(m, 1:3) - branchActual(m - d, 1:3));
                    else
                        direction = (branchActual(m + d, 1:3) - branchActual(m - d, 1:3));
                    end
                    dir_temp(m, :) = direction/norm(direction);
                end
                tangent_vector = [tangent_vector; dir_temp];
            end
        end
        
        function [line_vector, plane_vector] = normalizedVector(tangent_vector)
            % This will find a normalized vector perpendicular to the tangent vector
            sz = size(tangent_vector);
            row = [1:size(tangent_vector, 1)]';
            
            [~, idx_max] = max(abs(tangent_vector), [], 2);
            idx_max(idx_max==2) = 1;
            max_pts = sub2ind(sz, row, idx_max);
            
            temp = zeros(size(tangent_vector));
            temp(max_pts) = 1;
            
            [~, idx_shift] = max(abs(circshift(temp, 1, 2)), [], 2);
            shift_pts = sub2ind(sz, row, idx_shift);
            
            line_vector = zeros(size(tangent_vector));
            line_vector(max_pts) = tangent_vector(shift_pts);
            line_vector(shift_pts) = -tangent_vector(max_pts); % Vector that is used to create the perpendicular line
            N = repmat(sqrt(sum(abs(line_vector).^2, 2)), [1 3]);
            
            line_vector = line_vector./N;
            plane_vector = cross(tangent_vector, line_vector); % Vector that is used to create the perdendicular plane
        end
        
    end

end
