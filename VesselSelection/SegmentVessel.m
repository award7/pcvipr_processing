classdef SegmentVessel < handle
    
    properties (Access = private)
        Indices = 0;
        Indexes = 0; 
        BranchMat;
        BranchList;
        Resolution;
        Segment;
    end
    
    % constructor
    methods (Access = public)
       
        function self = SegmentVessel(VIPR)
            self.BranchMat = VIPR.BranchMat;
            self.BranchList = VIPR.BranchList;
            self.Resolution = VIPR.Resolution;
            self.Segment = VIPR.Segment;
        end
        
        function [branchNumber, branchActual, timeMIPVessel] = main(self, x, y, z)
            branchNumber = self.get_branch_points(x, y, z);
            self.check_for_vessel(branchNumber);
            self.get_indices(branchNumber);
            branchActual = self.get_branch();
            self.branch_length(branchActual);
            timeMIPVessel = self.branch_dilate();
        end
        
    end
    
    % methods for Segmenting vessel
    methods (Access = private)
        
        function branchNumber = get_branch_points(self, x, y, z)
            % need to adjust the x value
            x = self.Resolution - x;
            
            % finds closest point in BranchMat then uses that value for vessel selection
            points = regionprops(self.BranchMat>0, 'PixelList');
            points = struct2cell(points);
            points = cell2mat(points');

            distance = sqrt(sum((bsxfun(@minus, points, [y, x, z])).^2, 2));
            val = find(distance == min(distance));
            points = points(val(1),:);
            branchNumber = self.BranchMat(points(2), points(1), points(3));
        end
        
        function get_indices(self, branchNumber)
            for i = 1:length(branchNumber)
                self.Indices = vertcat(self.Indices, find(self.BranchList(:, 4) == branchNumber));
                self.Indexes = vertcat(self.Indexes, find(self.BranchMat == branchNumber));
            end
            
            self.Indices(1) = []; 
            self.Indexes(1) = [];
        end

        function branchActual = get_branch(self)
            branchActual = zeros(numel(self.Indices), 3);
            branchActual(:, 1) = self.BranchList(self.Indices, 1);
            branchActual(:, 2) = self.BranchList(self.Indices, 2);
            branchActual(:, 3) = self.BranchList(self.Indices, 3);
        end
        
        function timeMIPVessel = branch_dilate(self)
            % Image dilate and multiply by mask to extract entire vessel length
            BranchMat2 = zeros(self.Resolution, self.Resolution, self.Resolution);
            BranchMat2(self.Indexes) = 1;
            I1 = imdilate(BranchMat2, ones(7, 7, 7));
            timeMIPVessel = I1 .* self.Segment;
            timeMIPVessel(timeMIPVessel ~= 0) = 1;
        end
        
    end
    
    % methods for checking vessel
    methods (Static, Access = private)
        
        function check_for_vessel(branchNumber)
            if branchNumber ~= 0
                disp('Vessel found!');
            else
                errid = "SegmentVessel:CheckVessel:Invalid";
                msg = "No vessel found";
                ME = MException(errid, msg);
                throw(ME);
            end
        end
        
        function branch_length(branchActual)
            if size(branchActual(:,1)) < 3
                errid = "SegmentVessel:BranchLength:Short";
                msg = "Vessel is too short to calculate flow";
                ME = MException(errid, msg);
                throw(ME);
            end
        end
 
    end
    
end