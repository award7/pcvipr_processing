classdef featureExtraction < handle
    %{
     The function produces a centerline representation by labeling skeleton
     points as either,
     1. end points = 1
     2. middle/branch points = 2
     3. junction points = 3
    
     The function initially labels all points according to the list above, and
     then remove spurs shorter than a specified length.
    
     The labels are stored both in matrix form (res*res*res), and in list
     form, List(x,y,z,label).
    
     The function then proceeds iteratively with a new labeling, followed by
     removal of additional spurs until no change longer occur in the skeleton.
    
     INPUT
     1. Y is centerline in binary form
     2. vMean.
     3. spurLenght is the length of spurs to be removed
     4. sortingCriteria is criteria for branch sorting
    
     OUTPUT
     1. CL is centerline with spurs removed and points classified
     2. self.branchMat is branch indices & labels in matrix form
     3. self.branchList is branch indices & labels in list form
     4. self.branchTextList is accompaning text (number labels)
     5. self.junctionMat is junction indices & labels in matrix form
     6. self.junctionList is junction indices & labels in list form
    
    
    Calculate phase coherence and extract centerline for the vascular tree
    specify sortingCriteria as either
        = 2 to get all branches connected to each other sorting (few branches)
        = 3 to get branch by branch sorting (many branches)

    vascularTreeReconstr
        1. 'coarse'. Uses a PCthreshDev of 0.25 and a box filter to remove noise
            in the reconstructed vascular tree. Misses some vessels.
        2. 'fine' Uses a PCthreshDev of 0.3 and no filter. Noisier than 'coarse',
            but finds small vessels more easily. 

    Author: Erik Spaak
    Revised: Aaron Ward 11/21/2020
    %}
    
    properties(GetAccess = public, SetAccess = protected)
       CL;
       branchMat;
       branchList;
       branchTextList;
       junctionMat;
       junctionList;
    end
    
    properties(Access = public)
       sortingCriteria = 3;
       spurLength = 8;
    end
    
    methods
        
        function self = featureExtraction(segment, vMean, res)
            % perform medial axis thinning
            % Y = skeleton3D(segment);
            Y = Skeleton3D(segment);
            % dilate & erode to "delete" big junctions
            Y = self.dilate(Y);
            Y = self.erode(Y);
            Y = self.thinning(Y);
            self.CL = 2*Y;

            self.centerline(res);
            self.sortBranchList(vMean);
        end
        
    end
    
    methods(Access = protected)
        function centerline(self, res)
            modified = 1;
            Niter = 0;
            
            % do until convergence
            while modified > 0 && Niter < 20
                Niter = Niter + 1;
        
                % deletion of branches
                % do after first iteration
                if Niter > 1
                    modified = 0;
                    modified = self.deleteBranches(modified);
                    % disp(['Number of deleted branches: ' num2str(modified-1)])
                end
                % disp(['CL-summa ' num2str(sum(sum(sum(CL))))])
        
                % classify skeleton points
                self.classifySkeletonPoints(res); 
        
                % label junctions
                [mat, list, ~] = self.labelSkeleton('junctions', res);
                self.junctionMat = mat;
                self.junctionList = list;
                
                % label branches
                [mat, list, textList] = self.labelSkeleton('branches', res);
                self.branchMat = mat;
                self.branchList = list;
                self.branchTextList = textList;
            end
        end
        
        function modified = deleteBranches(self, modified)
            uniqueBranchLabels = unique(self.branchList(:, 4));
            for i = 1:length(uniqueBranchLabels)
                currentBranchLabel = uniqueBranchLabels(i);
                currentBranchIndices = find(self.branchList(:,4) == currentBranchLabel);
                currentBranchLength = length(currentBranchIndices);
                connectedToJunctions = 0;
                for j = currentBranchIndices'
                    x0 = self.branchList(j,1);
                    y0 = self.branchList(j,2); 
                    z0 = self.branchList(j,3);
                    connectedToJunctions = [connectedToJunctions; unique(self.junctionMat(x0-1:x0+1, y0-1:y0+1, z0-1:z0+1))];
                end
                connectedToJunctions = unique(connectedToJunctions);
                
                % delete branch if too short and not between two differently labeled junction points
                if (currentBranchLength) < self.spurLength && (length(connectedToJunctions) < 3)
                    for j = currentBranchIndices'
                        self.CL(self.branchList(j,1), self.branchList(j,2), self.branchList(j,3)) = 0;
                    end
                    modified = modified + 1;
                end
            end
        end
        
        function classifySkeletonPoints(self, res)
            self.CL = 2*logical(self.CL);
            CLindices = find(self.CL);
    
            for i = 1:length(CLindices)
                [x0, y0, z0] = ind2sub([res res res], CLindices(i));
    
                % 26-neighborhood sum
                neighSum = sum(sum(sum(logical(self.CL(x0-1:x0+1, y0-1:y0+1, z0-1:z0+1)))));
    
                % mark junction points
                if neighSum > 3
                    self.CL(CLindices(i)) = self.sortingCriteria;
                end
            end
        end
        
        function [mat, list, textList] = labelSkeleton(self, labelWhat, res)
            if strcmp(labelWhat, 'junctions')
                indices = find(self.CL == 3);
            elseif strcmp(labelWhat, 'branches')
                indices = find(self.CL == 2);
            end
            
            % list points
            [x0, y0, z0] = ind2sub([res res res], indices);
            
            % label matrix
            mat = zeros(res,res,res);
            
            % label vector
            if strcmp(labelWhat, 'junctions')
                list = [x0 y0 z0 zeros(length(x0), 1)]; 
            elseif strcmp(labelWhat, 'branches')
                list = [x0 y0 z0 zeros(length(x0), 2)]; 
            end
            
            textList = zeros(0, 4);
            
            label = 0;
            for i = 1:length(x0)
                if list(i, 4) == 0
                    label = label + 1;
                    mat(x0(i), y0(i), z0(i)) = label;
                    list(i, 4) = label;
                    
                    % create a textlist
                    textList = [textList; x0(i) y0(i) z0(i) label]; 
                    investigatePointsList = [x0(i) y0(i) z0(i)];
                    
                    % while still collecting points under this label
                    labeled = 1;
                    while labeled > 0
                        labeled = 0;
                        newInvestigativePointsList = [];
                        for j = 1:length(investigatePointsList(:, 1))
                            x1 = investigatePointsList(j, 1);
                            y1 = investigatePointsList(j, 2);
                            z1 = investigatePointsList(j, 3);
        
                            % collect 26-neighborhoods
                            label26 = mat(x1-1:x1+1, y1-1:y1+1, z1-1:z1+1);
                            antiLabel26 = logical((logical(label26) - 1));
                            CL26 = self.CL(x1-1:x1+1, y1-1:y1+1, z1-1:z1+1);
        
                            % find neighboring middle points not labeled
                            neigh = find(CL26.*antiLabel26 == 3);   
                            [x2, y2, z2] = ind2sub([3 3 3], neigh);
        
                            x3 = x1 + x2 - 2;
                            y3 = y1 + y2 - 2;
                            z3 = z1 + z2 - 2;
        
                            for k = 1:length(x3)
                                mat(x3(k), y3(k), z3(k)) = label;
                                a = find(list(:, 1) == x3(k));
                                b = find(list(:, 2) == y3(k));
                                c = find(list(:, 3) == z3(k));
                                d = intersect(a, b);
                                e = intersect(c, d);
                                list(e, 4) = label;
                                
                                if strcmp(labelWhat, 'branches')
                                    % sorting
                                    aa = find(list(:, 1) == x1);
                                    bb = find(list(:, 2) == y1);
                                    cc = find(list(:, 3) == z1);
                                    dd = intersect(aa, bb);
                                    ee = intersect(cc, dd);
                                    
                                    if list(ee, 5) == 0 && k == 1
                                        list(e, 5) = 1;
                                    elseif list(ee, 5) == 0 && k == 2
                                        list(e, 5) = -1;  
                                    elseif list(ee, 5) > 0
                                        list(e, 5) = list(ee, 5) + 1;
                                    elseif list(ee, 5) < 0
                                        list(e, 5) = list(ee, 5) - 1;
                                    end
                                end
                                
                                % count how many points collected under current label
                                labeled = labeled + 1;  
                            end
                            newInvestigativePointsList = [newInvestigativePointsList; x3 y3 z3];
                        end
                        investigatePointsList = newInvestigativePointsList;
                    end
                end
            end
        end

        function sortBranchList(self, vMean)
            % sort the self.branchList so that
            % 1. all the same labels are connected along the rows
            % 2. low -> high row index is in the same direction as the flow
            labels = unique(self.branchList(:, 4));
            branchListSorted = zeros(0, 5);
            beginSegment = 8;
        
            for i = 1:length(labels)
                % find branch
                branchActual = self.branchList(self.branchList(:, 4) == labels(i), :);
                branchActual = sortrows(branchActual, 5);
                v0x = 0; 
                v0y = 0; 
                v0z = 0;
                % check if a -> b is in the direction of the flow...
                if size(branchActual, 1) < beginSegment
                    for j = 1:size(branchActual, 1)
                        v0x = v0x + vMean(branchActual(j, 1), branchActual(j, 2), branchActual(j, 3), 1);
                        v0y = v0y + vMean(branchActual(j, 1), branchActual(j, 2), branchActual(j, 3), 2);
                        v0z = v0z + vMean(branchActual(j, 1), branchActual(j, 2), branchActual(j, 3), 3);
                    end
                    isReverse = dot(double(branchActual(end, 1:3) - branchActual(1, 1:3)), double([v0x v0y v0z]));
                else
                    % size(branchActual, 1)
                    for j = 1:beginSegment 
                        v0x = v0x + vMean(branchActual(j, 1), branchActual(j, 2), branchActual(j, 3), 1);
                        v0y = v0y + vMean(branchActual(j, 1), branchActual(j, 2), branchActual(j, 3), 2);
                        v0z = v0z + vMean(branchActual(j, 1), branchActual(j, 2), branchActual(j, 3), 3);
                    end
                    isReverse = dot(double(branchActual(beginSegment, 1:3) - branchActual(1, 1:3)), double([v0x v0y v0z]));
                end
        
                % ...if not, reverse
                if isReverse < 0
                    branchActual = flipud(branchActual);
                end
                branchListSorted = [branchListSorted; branchActual];
            end
            
            self.branchList = branchListSorted;
            
            for n = 1:max(self.branchList(:, 4))
                branchActual = self.branchList(self.branchList(:, 4) == n, :);
                % Could be Spurlength
                if size(branchActual, 1) < 9 
                    self.branchList(self.branchList(:, 4) == n, :) = [];
                end
            end
        end
        
    end
    
    methods(Access = private, Static)
        
        function Y = dilate(Y)
            se = ones(3,3,3);
            Y = imdilate(Y, se);
        end
        
        function Y = erode(Y)
           se = ones(3,3,3);
           Y = imerode(Y, se); 
        end
        
        function Y = thinning(binary)
            %{
             This function executes the thinning algorithm described in Palagyi paper.
             It produces a topology conserving skeleton of an object.
            
             INPUT:
             binary array which should be thinned
            
             OUTPUT:
             binary array with the thinned result
            
             Author: Erik Spaak
            %}
            
            % disp('Performing centerline extraction...');
            Y = binary;
            
            U = featureExtraction.directionMatrix(5);
            D = featureExtraction.directionMatrix(22);
            N = featureExtraction.directionMatrix(13);
            S = featureExtraction.directionMatrix(14);
            E = featureExtraction.directionMatrix(11);
            W = featureExtraction.directionMatrix(16);
            
            % "modified" is accumulating number of deleted points
            modified = 1;
            while(modified > 0)
                % disp(['Current number of Black points: ' num2str(sum(sum(sum(Y))))])
            
                % number of deleted pixels
                modified = 0;
                
                [Y, modifiedIncr] = featureExtraction.thinningSubiter(Y, U);
                modified = modified + modifiedIncr;
                % disp(['Remove ' num2str(modifiedIncr)]);
                
                [Y, modifiedIncr] = featureExtraction.thinningSubiter(Y, D);
                modified = modified + modifiedIncr;
                % disp(['Remove ' num2str(modifiedIncr)]);
        
                [Y, modifiedIncr] = featureExtraction.thinningSubiter(Y, N);
                modified = modified + modifiedIncr;
                % disp(['Remove ' num2str(modifiedIncr)]);
        
                [Y, modifiedIncr] = featureExtraction.thinningSubiter(Y, S);
                modified = modified + modifiedIncr;
                % disp(['Remove ' num2str(modifiedIncr)]);
        
                [Y, modifiedIncr] = featureExtraction.thinningSubiter(Y, E);
                modified = modified + modifiedIncr;
                % disp(['Remove ' num2str(modifiedIncr)]);
        
                [Y, modifiedIncr] = featureExtraction.thinningSubiter(Y, W);
                modified = modified + modifiedIncr;
                % disp(['Remove ' num2str(modifiedIncr)]);
            end
        
             disp('Completed centerline extraction');
        end
        
        function [Y, modified] = thinningSubiter(Y, direction)
            %{
             points are removed if they remain simple and non-endpoints
            
             A black point {p} is a simple point if its deletion does not alter the
             topology of the image. If and only if all conditions hold:
             1. p is not alone in (3x3x3 neigh.)
             2. all black points are 26-connected 
             3. p is a border point
             4. all white points are 6-connectd in N18
            %}  
                
            dim = size(Y);
        
            % define S6 and S26
            [S6, S26] = featureExtraction.connectivityN18();
            
            % create empty list
            % Border points will be inserted here
            list = [0 0 0];
            elementsInList = 0;
        
            % make all edges 0
            Y = featureExtraction.edge0(Y, dim);

            [Y, list] = featureExtraction.phase1(Y, list, elementsInList, dim, direction, S6, S26);
            [Y, modified] = featureExtraction.phase2(Y, list, S6, S26);
        end

        function [Y, list] = phase1(Y, list, elementsInList, dim, direction, S6, S26)
            % PHASE 1: list simple points
            % loop over all points
            Yindices = find(Y);
            for i = 1:length(Yindices)
                
                % find point p
                [Np6, Np26, x0, y0, z0] = featureExtraction.makeNp('phase1', Y, Yindices(i), dim);
        
                % if border point (condition 3)
                if sum(direction.*Np26) == 0  
                    % if not end point (condition 1)
                    if sum(Np26) > 1 
        
                        % is simple if
                        % 1. condition 2 true
                        % 2. condition 4 true
        
                        % condition 2
                        % label all the black points in N26: L = 1,2, ..., Nblackpoints
                        condition2satisfied = featureExtraction.bwPoints(Np26, S26);    
        
                        % condition 4
                        % label all the white points in Np6: 1,2, ..., Nwhitepoints
                        condition4satisfied = featureExtraction.bwPoints(Np6, S6);    
        
                        % if simple
                        % condition2satisfied = 1;
                        % condition4satisfied = 1;
        
                        if condition2satisfied && condition4satisfied
                            elementsInList = elementsInList + 1;
                            list(elementsInList, :) = [x0 y0 z0];
                        end
                    end
                end
            end
        end
        
        function [Y, modified] = phase2(Y, list, S6, S26)
            %{
             PHASE 2:
             re-cheking procedure : each point in the list is removed if it remains
             simple and non-end-point in the actual (modified) image.
             disp(['In list ' num2str(size(list,1))])
            %}
            modified = 0;
            
            % while there are points in the list
            if sum(sum(list)) ~= 0   
                % loop over all points IN LIST
                for i = 1:size(list, 1)   
                    [Np6, Np26, x0, y0, z0] = featureExtraction.makeNp('phase2', Y, list, []);
        
                    % border point check not needed
        
                    % if not end point
                    if sum(Np26) > 1 
        
                        % is simple if
                        % 1. condition 2 true
                        % 2. condition 4 true
        
                        % condition 2
                        % label all the black points in N26: L = 1,2, ..., Nblackpoints
                        condition2satisfied = featureExtraction.bwPoints(Np26, S26);

                        % condition 4
                        % label all the white points in Np6: 1,2, ..., Nwhitepoints
                        condition4satisfied = featureExtraction.bwPoints(Np6, S6);
                    
                        if condition2satisfied && condition4satisfied
                            Y(x0, y0, z0) = 0;
                            modified = modified + 1;
                        end
                    end
                end
            end
        end 
        
        function conditionSatisfied = bwPoints(np, s)
            % 1 by default; is changed to 0 in loop below if not true  
            conditionSatisfied = 1;
            label = 0;
            l = zeros(1,26);
            for m = 1:26
                if np(m) == 1
                    label = label + 1;
                     l(m) = label;          
                end
    
            end
    
            labelsum1 = sum(l);
            labelsum2 = 0;
            while labelsum1 ~= labelsum2
                labelsum1 = sum(l);
                for m = find(l == label)
                    for j = s{m}
                        if np(j) == 1
                            l(j) = label;
                        end
                    end
                end
                labelsum2 = sum(l);
            end
    
            for m = 1:26
                if (np(m) == 1) && (l(m) ~= label)
                    conditionSatisfied = 0;
                end
            end     
        end
     
        function [Np6, Np26, x0, y0, z0] = makeNp(phase, Y, arr, dim)
            switch phase
                case 'phase1'
                    [x0, y0, z0] = ind2sub(dim, arr);
                case 'phase2'
                    x0 = arr(:, 1);
                    y0 = arr(:, 2);
                    z0 = arr(:, 3);
            end
            
            % collect neighborhood
            Np26 = Y(x0-1:x0+1, y0-1:y0+1, z0-1:z0+1);    
            
            % reshape neighborhood
            Np26 = reshape(Np26, 1, 27);    
            
            % remove midpoint
            Np26(14) = [];
    
            % Np6 is the face-part of Np26
            Np6 = (-1)*ones(1,26);  
            
            for element = [5 11 13 14 16 22]
                Np6(element) = Np26(element);
            end
        end
        
        function [S6, S26] = connectivityN18()
            % forward and backward 6-connectivity in N18
            % S6{1} = [];
            S6{2} = [5 11];
            % S6{3} = 2;
            S6{4} = [5 13];
            S6{5} = [2 4 6 8];
            S6{6} = [5 14];
            % S6{7} = 4;
            S6{8} = [5 16];
            % S6{9} = [6 8];
            S6{10} = [11 13];
            S6{11} = [2 10 12 19];
            S6{12} = [11 14];
            S6{13} = [4 10 15 21];
            S6{14} = [6 12 17 23];
            S6{15} = [13 16];
            S6{16} = [8 15 17 25];
            S6{17} = [14 16];
            % S6{18} = 10;
            S6{19} = [11 22];
            % S6{20} = [12 19];
            S6{21} = [13 22];
            S6{22} = [19 21 23 25];
            S6{23} = [14 22];
            % S6{24} = [15 21];
            S6{25} = [16 22];
            % S6{26} = [17 23 25];
        
            % forward and backward 26-connectivity in N26
            S26{1}  = [1 2 4 5 10 11 13];
            S26{2}  = [1 3 4 5 6 10 11 12 13 14];
            S26{3}  = [2 5 6 11 12 14];
            S26{4}  = [1 2 5 7 8 10 11 13 15 16];
            S26{5}  = [1 2 3 4 6 7 8 9 10 11 12 13 14 15 16 17];
            S26{6}  = [2 3 5 8 9 11 12 14 16 17];
            S26{7}  = [4 5 8 13 15 16];
            S26{8}  = [4 5 6 7 9 13 14 15 16 17];
            S26{9}  = [5 6 8 14 16 17];
            S26{10} = [1 2 4 5 11 13 18 19 21 22];
            S26{11} = [1 2 3 4 5 6 10 12 13 14 18 19 20 21 22 23];
            S26{12} = [2 3 5 6 11 14 19 20 22 23];
            S26{13} = [1 2 4 5 7 8 10 11 15 16 18 19 21 22 24 25];
            S26{14} = [2 3 5 6 8 9 11 12 16 17 19 20 22 23 25 26];
            S26{15} = [4 5 7 8 13 16 21 22 24 25];
            S26{16} = [4 5 6 7 8 9 13 14 15 17 21 22 23 24 25 26];
            S26{17} = [5 6 8 9 14 16 22 23 25 26];
            S26{18} = [10 11 13 19 21 22];
            S26{19} = [10 11 12 13 14 18 20 21 22 23];
            S26{20} = [11 12 14 19 22 23];
            S26{21} = [10 11 13 15 16 18 19 22 24 25];
            S26{22} = [10 11 12 13 14 15 16 17 18 19 20 21 23 24 25 26];
            S26{23} = [11 12 14 16 17 19 20 22 25 26];
            S26{24} = [13 15 16 21 22 25];
            S26{25} = [13 14 15 16 17 21 22 23 24 26];
            S26{26} = [14 16 17 22 23 25];
        end
        
        function Y = edge0(Y, dim)
            Y(1,:,:) = 0; 
            Y(dim(1),:,:) = 0; 
            Y(:,1,:) = 0; 
            Y(:,dim(2),:) = 0; 
            Y(:,:,1) = 0; 
            Y(:,:,dim(3)) = 0;
        end
   
        function mat = directionMatrix(idx)
            mat = zeros([1, 26]);
            mat(idx) = 1;
        end

        function Np18 = makeNp18(Np26)
            % unused!
            % Np18 is Np26 with corners "removed"
            Np18 = Np26;    
            Np18(1) = -1; 
            Np18(3) = -1; 
            Np18(7) = -1; 
            Np18(9) = -1; 
            Np18(18) = -1; 
            Np18(20) = -1; 
            Np18(24) = -1; 
            Np18(26) = -1;
        end
        
    end
    
end

