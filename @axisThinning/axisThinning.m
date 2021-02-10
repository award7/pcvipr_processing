classdef axisThinning
    %{
    Parallel medial axis thinning of a 3D binary volume

    Adapted from
    Ta-Chih Lee, Rangasami L. Kashyap and Chong-Nam Chu
    "Building skeleton models via 3-D medial surface/axis thinning algorithms."
    Computer Vision, Graphics, and Image Processing, 56(6):462–478, 1994.

    Inspired by the ITK implementation by Hanno Homann
    http://hdl.handle.net/1926/1292
    and the Fiji/ImageJ plugin by Ignacio Arganda-Carreras
    http://fiji.sc/wiki/index.php/Skeletonize3D


    Philip Kollmannsberger 9/2013
    philipk@gmx.net

    Updated: Carson Hoffman 3/22/2016
    cahoffman@wisc.edu

    Updated: Aaron Ward 10/21/2020
    award7@wisc.edu
    %}
    
    methods(Static)
        
        function Y = skeleton3D(varargin)
            disp('Computing medial axis...');
            min_args = 1;
            max_args = 2;
            narginchk(min_args, max_args);
            
            img = varargin{1};
            if nargin > 1
                spare = varargin{2};
            end
            
            % pad volume with zeros to avoid edge effects
            Y = padarray(img, [1 1 1]);
            if(nargin > 1)
                spare = padarray(varargin{2}, [1 1 1]);
            end

            skel_ind = find(Y(:) == 1);

            % number of foreground voxels
            l_orig = length(find(Y(:)));

            % fill lookup table
            eulerLUT = axisThinning.FillEulerLUT;
            
            % width height depth
            width = size(Y, 1);
            height = size(Y, 2);
            depth = size(Y, 3);
            ind_dir = [1 -1 width -width width*height -width*height];
            unchangedBorders = 0;

            % loop until no change for all six border types
            while(unchangedBorders < 6)
                % loop over all 6 directions
                for currentBorder = 1:6 
                    noChange = true;

                    % get candidate voxels
                    cands = axisThinning.getCandidates(Y, currentBorder, skel_ind, ind_dir);

                    % if excluded voxels were passed, remove them from candidates
                    if(nargin > 1)
                        cands = cands.*~spare;
                    end

                    % make sure all candidates are indeed foreground voxels
                    cands = intersect(cands, skel_ind);

                    if(~isempty(cands))
                        % get subscript indices of candidates
                        [x, y, z] = ind2sub([width height depth], cands);

                        % get 26-neighbourhood of candidates in volume
                        nhood = logical(axisThinning.pk_get_nh(Y, cands));

                        % remove all endpoints (exactly one nb) from list
                        di = find(sum(nhood, 2) == 2);
                        [nhood, cands, x, y, z] = axisThinning.removePoints(nhood, cands, di, x, y, z);

                        % remove all non-Euler-invariant points from list
                        di = find(~axisThinning.p_EulerInv(nhood, eulerLUT'));
                        [nhood, cands, x, y, z] = axisThinning.removePoints(nhood, cands, di, x, y, z);

                        % remove all non-simple points from list
                        di = find(~axisThinning.p_is_simple(nhood));
                        [nhood, cands, x, y, z] = axisThinning.removePoints(nhood, cands, di, x, y, z);

                        % if any candidates left:
                        if(~isempty(x))
                            % divide into 8 independent subvolumes
                            ilst = axisThinning.octantSplit(x, y, z);

                            % do parallel re-checking for all points in each subvolume
                           [Y, noChange] = axisThinning.parallelRecheck(Y, ilst, x, y, z, width, height, depth);
                        end
                    end

                    if(noChange)
                        unchangedBorders = unchangedBorders + 1;
                    else   
                        completed = round(100*(l_orig-length(find(Y(:))))/l_orig);
                        fprintf('removed %3d%% of voxels\n', completed);
                    end
                end
            end

            % get rid of padded zeros
            Y = Y(2:end-1, 2:end-1, 2:end-1);
            disp('Finished thinning operation');
        end

        function cands = getCandidates(Y, currentBorder, skel_ind, ind_dir)
            switch currentBorder
                case 1
                    cands = skel_ind + ind_dir(1,4);
                    cands = skel_ind(~logical(Y(cands)));
                case 2
                    cands = skel_ind + ind_dir(1,3);
                    cands = skel_ind(~logical(Y(cands)));
                case 3
                    cands = skel_ind + ind_dir(1,1);
                    cands = skel_ind(~logical(Y(cands)));
                case 4
                    cands = skel_ind + ind_dir(1,2);
                    cands = skel_ind(~logical(Y(cands)));
                case 5
                    cands = skel_ind + ind_dir(1,5);
                    cands = skel_ind(~logical(Y(cands)));
                case 6
                    cands = skel_ind + ind_dir(1,6);
                    cands = skel_ind(~logical(Y(cands)));
            end
        end
        
        function nhood = pk_get_nh(Y, cands)
            width = size(Y, 1);
            height = size(Y,2);
            depth = size(Y, 3);

            [x, y, z] = ind2sub([width height depth], cands);

            nhood = false(length(cands), 27);

            for xx=1:3
                for yy=1:3
                    for zz=1:3
                        w = sub2ind([3 3 3], xx, yy, zz);
                        idx = sub2ind([width height depth], x+xx-2, y+yy-2, z+zz-2);
                        nhood(:, w) = Y(idx);
                    end
                end
            end
        end

        function [Y, noChange] = parallelRecheck(Y, ilst, x, y, z, width, height, depth)
            idx = [];
            for i = 1:8
                if(~isempty(ilst(i).l))
                    idx = ilst(i).l;
                    li = sub2ind([width height depth], x(idx), y(idx), z(idx));

                    % remove points
                    Y(li) = 0; 
                    nh = logical(axisThinning.pk_get_nh(Y, li));
                    di_rc = find(~axisThinning.p_is_simple(nh));

                    if(~isempty(di_rc))
                        % if topology changed: revert
                        Y(li(di_rc)) = 1;
                    else
                        % at least one voxel removed
                        noChange = false; 
                    end
                end
            end
        end

        function LUT = FillEulerLUT()
            idx = [129];
            mat = repmat(-7, size(idx));
            combined_neg7 = horzcat(idx', mat');

            idx = [9, 33, 65, 137, 161, 193];
            mat = repmat(-3, size(idx));
            combined_neg3 = horzcat(idx', mat');

            idx = [3, 5, 11, 13, 17, 23, 31, 35, 43, 49, 55, 63, 69, 77, 81, 87, 95, 113, 119, 127, 131, 133, 139, 141, 145, 151, 159, 163, 171, 177, 183, 191, 197, 205, 209, 215, 223, 241, 247, 255];
            mat = repmat(-1, size(idx));
            combined_neg1 = horzcat(idx', mat');

            idx = 2:2:254;
            mat = zeros(size(idx));
            combined_0 = horzcat(idx', mat');

            idx = [1, 7, 15, 19, 21, 27, 29, 39, 41, 47, 51, 53, 59, 61, 71, 73, 79, 83, 85, 91, 93, 97, 103, 111, 115, 117, 123, 125, 135, 143, 147, 149, 155, 157, 167, 169, 175, 179, 181, 187, 189, 199, 201, 207, 211, 213, 219, 221, 225, 231, 239, 243, 245, 251, 253];
            mat = ones(size(idx));
            combined_pos1 = horzcat(idx', mat');

            idx = [25, 37, 45, 57, 67, 75, 89, 99, 101, 107, 109, 121, 153, 165, 173, 185, 195, 203, 217, 227, 229, 235, 237, 249];
            mat = repmat(3, size(idx));
            combined_pos3 = horzcat(idx', mat');

            idx = [105, 233];
            mat = repmat(5, size(idx));
            combined_pos5 = horzcat(idx', mat');

            mat = vertcat(combined_neg7, combined_neg3, combined_neg1, combined_0, combined_pos1, combined_pos3, combined_pos5);
            mat = sortrows(mat);
            idx = mat(1:end, 1);
            LUT(idx) = mat(1:end, 2);
        end

        function [nhood, cands, x, y, z] = removePoints(nhood, cands, di, x, y, z)
            nhood(di, :) = [];
            cands(di) = [];
            x(di) = [];
            y(di) = [];
            z(di) = [];
        end

        function ilst = octantSplit(x, y, z)
            x1 = find(mod(x, 2));
            x2 = find(~mod(x, 2));
            y1 = find(mod(y, 2));
            y2 = find(~mod(y, 2));
            z1 = find(mod(z, 2));
            z2 = find(~mod(z, 2));

            ilst(1).l = intersect(x1, intersect(y1, z1));
            ilst(2).l = intersect(x2, intersect(y1, z1));
            ilst(3).l = intersect(x1, intersect(y2, z1));
            ilst(4).l = intersect(x2, intersect(y2, z1));
            ilst(5).l = intersect(x1, intersect(y1, z2));
            ilst(6).l = intersect(x2, intersect(y1, z2));
            ilst(7).l = intersect(x1, intersect(y2, z2));
            ilst(8).l = intersect(x2, intersect(y2, z2));
        end

        function p = p_is_simple(N) 
            % copy neighbors for labeling
            n_p = size(N, 1);
            p = ones(1, n_p);

            cube = zeros(26, n_p);
            cube(1:13, :) = N(:, 1:13)';
            cube(14:26, :) = N(:, 15:27)';

            label = 2*ones(1, n_p);

            % for all points in the neighborhood
            for i = 1:26

                idx_1 = find(cube(i, :) == 1);
                idx_2 = find(p);
                idx = intersect(idx_1, idx_2);

                % start recursion with any octant that contains the point i
                if(~isempty(idx))
                    switch(i)
                        case {1, 2, 4, 5, 10, 11, 13}
                            octant = 1;
                        case {3, 6, 12, 14}
                            octant = 2;
                        case {7, 8, 15, 16}
                            octant = 3;
                        case {9, 17}
                            octant = 4;
                        case {18, 19, 21, 22}
                            octant = 5;
                        case {20, 23}
                            octant = 6;
                        case {24, 25}
                            octant = 7;
                        case 26
                            octant = 8;
                    end

                    cube(:, idx) = axisThinning.p_oct_label(octant, label, cube(:, idx));
                    label(idx) = label(idx) + 1;
                    del_idx = find(label >= 4);

                    if(~isempty(del_idx))
                        p(del_idx) = 0;
                    end
                end
            end
        end

        function cube = p_oct_label(octant, label, cube)
            % check if there are points in the octant with value 1
            if(octant == 1)

                % set points in this octant to current label
                % and recurseive labeling of adjacent octants
                idx_1 = find(cube(1, :) == 1);
                if(~isempty(idx_1))
                    cube(1, idx_1) = label(idx_1);
                end

                idx_2 = find(cube(2, :) == 1);
                if(~isempty(idx_2))
                    cube(2, idx_2) = label(idx_2);
                    cube(:, idx_2) = axisThinning.p_oct_label(2, label(idx_2), cube(:, idx_2));
                end

                idx_4 = find(cube(4, :) == 1);
                if(~isempty(idx_4))
                    cube(4, idx_4) = label(idx_4);
                    cube(:, idx_4) = axisThinning.p_oct_label(3, label(idx_4), cube(:, idx_4));
                end

                idx_5 = find(cube(5, :) == 1);
                if(~isempty(idx_5))
                    cube(5, idx_5) = label(idx_5);
                    cube(:, idx_5) = axisThinning.p_oct_label(2, label(idx_5), cube(:, idx_5));
                    cube(:, idx_5) = axisThinning.p_oct_label(3, label(idx_5), cube(:, idx_5));
                    cube(:, idx_5) = axisThinning.p_oct_label(4, label(idx_5), cube(:, idx_5));
                end

                idx_10 = find(cube(10, :) == 1);
                if(~isempty(idx_10))
                    cube(10, idx_10) = label(idx_10);
                    cube(:, idx_10) = axisThinning.p_oct_label(5, label(idx_10), cube(:, idx_10));
                end

                idx_11 = find(cube(11, :) == 1);
                if(~isempty(idx_11))
                    cube(11, idx_11) = label(idx_11);
                    cube(:, idx_11) = axisThinning.p_oct_label(2, label(idx_11), cube(:, idx_11));
                    cube(:, idx_11) = axisThinning.p_oct_label(5, label(idx_11), cube(:, idx_11));
                    cube(:, idx_11) = axisThinning.p_oct_label(6, label(idx_11), cube(:, idx_11));
                end

                idx_13 = find(cube(13, :) == 1);
                if(~isempty(idx_13))
                    cube(13, idx_13) = label(idx_13);
                    cube(:, idx_13) = axisThinning.p_oct_label(3, label(idx_13), cube(:, idx_13));
                    cube(:, idx_13) = axisThinning.p_oct_label(5, label(idx_13), cube(:, idx_13));
                    cube(:, idx_13) = axisThinning.p_oct_label(7, label(idx_13), cube(:, idx_13));
                end

            end

            if(octant == 2)
                idx_2 = find(cube(2, :) == 1);
                if(~isempty(idx_2))
                    cube(2, idx_2) = label(idx_2);
                    cube(:, idx_2) = axisThinning.p_oct_label(1, label(idx_2), cube(:, idx_2));
                end

                idx_5 = find(cube(5, :) == 1);
                if(~isempty(idx_5))
                    cube(5, idx_5) = label(idx_5);
                    cube(:, idx_5) = axisThinning.p_oct_label(1, label(idx_5), cube(:, idx_5));
                    cube(:, idx_5) = axisThinning.p_oct_label(3, label(idx_5), cube(:, idx_5));
                    cube(:, idx_5) = axisThinning.p_oct_label(4, label(idx_5), cube(:, idx_5));
                end

                idx_11 = find(cube(11, :) == 1);
                if(~isempty(idx_11))
                    cube(11, idx_11) = label(idx_11);
                    cube(:, idx_11) = axisThinning.p_oct_label(1, label(idx_11), cube(:, idx_11));
                    cube(:, idx_11) = axisThinning.p_oct_label(5, label(idx_11), cube(:, idx_11));
                    cube(:, idx_11) = axisThinning.p_oct_label(6, label(idx_11), cube(:, idx_11));
                end

                idx_3 = find(cube(3, :) == 1);
                if(~isempty(idx_3))
                    cube(3, idx_3) = label(idx_3);
                end

                idx_6 = find(cube(6, :) == 1);
                if(~isempty(idx_6))
                    cube(6, idx_6) = label(idx_6);
                    cube(:, idx_6) = axisThinning.p_oct_label(4, label(idx_6), cube(:, idx_6));
                end

                idx_12 = find(cube(12, :) == 1);
                if(~isempty(idx_12))
                    cube(12, idx_12) = label(idx_12);
                    cube(:, idx_12) = axisThinning.p_oct_label(6, label(idx_12), cube(:, idx_12));
                end

                idx_14 = find(cube(14, :) == 1);
                if(~isempty(idx_14))
                    cube(14, idx_14) = label(idx_14);
                    cube(:, idx_14) = axisThinning.p_oct_label(4, label(idx_14), cube(:, idx_14));
                    cube(:, idx_14) = axisThinning.p_oct_label(6, label(idx_14), cube(:, idx_14));
                    cube(:, idx_14) = axisThinning.p_oct_label(8, label(idx_14), cube(:, idx_14));
                end

            end

            if(octant == 3)
                idx_4 = find(cube(4, :) == 1);
                if(~isempty(idx_4))
                    cube(4, idx_4) = label(idx_4);
                    cube(:, idx_4) = axisThinning.p_oct_label(1, label(idx_4), cube(:, idx_4));
                end

                idx_5 = find(cube(5, :) == 1);
                if(~isempty(idx_5))
                    cube(5, idx_5) = label(idx_5);
                    cube(:, idx_5) = axisThinning.p_oct_label(1, label(idx_5), cube(:, idx_5));
                    cube(:, idx_5) = axisThinning.p_oct_label(2, label(idx_5), cube(:, idx_5));
                    cube(:, idx_5) = axisThinning.p_oct_label(4, label(idx_5), cube(:, idx_5));
                end

                idx_13 = find(cube(13, :) == 1);
                if(~isempty(idx_13))
                    cube(13, idx_13) = label(idx_13);
                    cube(:, idx_13) = axisThinning.p_oct_label(1, label(idx_13), cube(:, idx_13));
                    cube(:, idx_13) = axisThinning.p_oct_label(5, label(idx_13), cube(:, idx_13));
                    cube(:, idx_13) = axisThinning.p_oct_label(7, label(idx_13), cube(:, idx_13));
                end

                idx_7 = find(cube(7, :) == 1);
                if(~isempty(idx_7))
                    cube(7, idx_7) = label(idx_7);
                end

                idx_8 = find(cube(8, :) == 1);
                if(~isempty(idx_8))
                    cube(8, idx_8) = label(idx_8);
                    cube(:, idx_8) = axisThinning.p_oct_label(4, label(idx_8), cube(:, idx_8));
                end

                idx_15 = find(cube(15, :) == 1);
                if(~isempty(idx_15))
                    cube(15, idx_15) = label(idx_15);
                    cube(:, idx_15) = axisThinning.p_oct_label(7, label(idx_15), cube(:, idx_15));
                end

                idx_16 = find(cube(16, :) == 1);
                if(~isempty(idx_13))
                    cube(16, idx_16) = label(idx_16);
                    cube(:, idx_16) = axisThinning.p_oct_label(4, label(idx_16), cube(:, idx_16));
                    cube(:, idx_16) = axisThinning.p_oct_label(7, label(idx_16), cube(:, idx_16));
                    cube(:, idx_16) = axisThinning.p_oct_label(8, label(idx_16), cube(:, idx_16));
                end

            end

            if(octant == 4)
                idx_5 = find(cube(5, :) == 1);
                if(~isempty(idx_5))
                    cube(5, idx_5) = label(idx_5);
                    cube(:, idx_5) = axisThinning.p_oct_label(1, label(idx_5), cube(:, idx_5));
                    cube(:, idx_5) = axisThinning.p_oct_label(2, label(idx_5), cube(:, idx_5));
                    cube(:, idx_5) = axisThinning.p_oct_label(3, label(idx_5), cube(:, idx_5));
                end

                idx_6 = find(cube(6, :) == 1);
                if(~isempty(idx_6))
                    cube(6,idx_6) = label(idx_6);
                    cube(:, idx_6) = axisThinning.p_oct_label(2, label(idx_6), cube(:, idx_6));
                end

                idx_14 = find(cube(14, :) == 1);
                if(~isempty(idx_14))
                    cube(14, idx_14) = label(idx_14);
                    cube(:, idx_14) = axisThinning.p_oct_label(2, label(idx_14), cube(:, idx_14));
                    cube(:, idx_14) = axisThinning.p_oct_label(6, label(idx_14), cube(:, idx_14));
                    cube(:, idx_14) = axisThinning.p_oct_label(8, label(idx_14), cube(:, idx_14));
                end

                idx_8 = find(cube(8, :) == 1);
                if(~isempty(idx_8))
                    cube(8, idx_8) = label(idx_8);
                    cube(:, idx_8) = axisThinning.p_oct_label(3, label(idx_8), cube(:, idx_8));
                end

                idx_16 = find(cube(16, :) == 1);
                if(~isempty(idx_16))
                    cube(16, idx_16) = label(idx_16);
                    cube(:, idx_16) = axisThinning.p_oct_label(3, label(idx_16), cube(:, idx_16));
                    cube(:, idx_16) = axisThinning.p_oct_label(7, label(idx_16), cube(:, idx_16));
                    cube(:, idx_16) = axisThinning.p_oct_label(8, label(idx_16), cube(:, idx_16));
                end

                idx_9 = find(cube(9, :) == 1);
                if(~isempty(idx_9))
                    cube(9, idx_9) = label(idx_9);
                end

                idx_17 = find(cube(17, :) == 1);
                if(~isempty(idx_17))
                    cube(17, idx_17) = label(idx_17);
                    cube(:, idx_17) = axisThinning.p_oct_label(8, label(idx_17), cube(:, idx_17));
                end

            end

            if(octant == 5)
                idx_10 = find(cube(10, :) == 1);
                if(~isempty(idx_10))
                    cube(10, idx_10) = label(idx_10);
                    cube(:, idx_10) = axisThinning.p_oct_label(1, label(idx_10), cube(:, idx_10));
                end

                idx_11 = find(cube(11, :) == 1);
                if(~isempty(idx_11))
                    cube(11, idx_11) = label(idx_11);
                    cube(:, idx_11) = axisThinning.p_oct_label(1, label(idx_11), cube(:, idx_11));
                    cube(:, idx_11) = axisThinning.p_oct_label(2, label(idx_11), cube(:, idx_11));
                    cube(:, idx_11) = axisThinning.p_oct_label(6, label(idx_11), cube(:, idx_11));
                end

                idx_13 = find(cube(13, :) == 1);
                if(~isempty(idx_13))
                    cube(13, idx_13) = label(idx_13);
                    cube(:, idx_13) = axisThinning.p_oct_label(1, label(idx_13), cube(:, idx_13));
                    cube(:, idx_13) = axisThinning.p_oct_label(3, label(idx_13), cube(:, idx_13));
                    cube(:, idx_13) = axisThinning.p_oct_label(7, label(idx_13), cube(:, idx_13));
                end

                idx_18 = find(cube(18, :) == 1);
                if(~isempty(idx_18))
                    cube(18, idx_18) = label(idx_18);
                end

                idx_19 = find(cube(19, :) == 1);
                if(~isempty(idx_19))
                    cube(19, idx_19) = label(idx_19);
                    cube(:, idx_19) = axisThinning.p_oct_label(6, label(idx_19), cube(:, idx_19));
                end

                idx_21 = find(cube(21, :) == 1);
                if(~isempty(idx_21))
                    cube(21, idx_21) = label(idx_21);
                    cube(:, idx_21) = axisThinning.p_oct_label(7, label(idx_21), cube(:, idx_21));
                end

                idx_22 = find(cube(22, :) == 1);
                if(~isempty(idx_22))
                    cube(22, idx_22) = label(idx_22);
                    cube(:, idx_22) = axisThinning.p_oct_label(6, label(idx_22), cube(:, idx_22));
                    cube(:, idx_22) = axisThinning.p_oct_label(7, label(idx_22), cube(:, idx_22));
                    cube(:, idx_22) = axisThinning.p_oct_label(8, label(idx_22), cube(:, idx_22));
                end

            end

            if(octant == 6)
                idx_11 = find(cube(11, :) == 1);
                if(~isempty(idx_11))
                    cube(11, idx_11) = label(idx_11);
                    cube(:, idx_11) = axisThinning.p_oct_label(1, label(idx_11), cube(:, idx_11));
                    cube(:, idx_11) = axisThinning.p_oct_label(2, label(idx_11), cube(:, idx_11));
                    cube(:, idx_11) = axisThinning.p_oct_label(5, label(idx_11), cube(:, idx_11));
                end

                idx_12 = find(cube(12, :) == 1);
                if(~isempty(idx_12))
                    cube(12, idx_12) = label(idx_12);
                    cube(:, idx_12) = axisThinning.p_oct_label(2, label(idx_12), cube(:, idx_12));
                end

                idx_14 = find(cube(14, :) == 1);
                if(~isempty(idx_14))
                    cube(14, idx_14) = label(idx_14);
                    cube(:, idx_14) = axisThinning.p_oct_label(2, label(idx_14), cube(:, idx_14));
                    cube(:, idx_14) = axisThinning.p_oct_label(4, label(idx_14), cube(:, idx_14));
                    cube(:, idx_14) = axisThinning.p_oct_label(8, label(idx_14), cube(:, idx_14));
                end

                idx_19 = find(cube(19, :) == 1);
                if(~isempty(idx_19))
                    cube(19, idx_19) = label(idx_19);
                    cube(:, idx_19) = axisThinning.p_oct_label(5, label(idx_19), cube(:, idx_19));
                end

                idx_22 = find(cube(22, :) == 1);
                if(~isempty(idx_22))
                    cube(22, idx_22) = label(idx_22);
                    cube(:, idx_22) = axisThinning.p_oct_label(5, label(idx_22), cube(:, idx_22));
                    cube(:, idx_22) = axisThinning.p_oct_label(7, label(idx_22), cube(:, idx_22));
                    cube(:, idx_22) = axisThinning.p_oct_label(8, label(idx_22), cube(:, idx_22));
                end

                idx_20 = find(cube(20, :) == 1);
                if(~isempty(idx_20))
                    cube(20, idx_20) = label(idx_20);
                end

                idx_23 = find(cube(23, :) == 1);
                if(~isempty(idx_23))
                    cube(23, idx_23) = label(idx_23);
                    cube(:, idx_23) = axisThinning.p_oct_label(8, label(idx_23), cube(:, idx_23));
                end

            end

            if(octant == 7)
                idx_13 = find(cube(13, :) == 1);
                if(~isempty(idx_13))
                    cube(13, idx_13) = label(idx_13);
                    cube(:, idx_13) = axisThinning.p_oct_label(1, label(idx_13), cube(:, idx_13));
                    cube(:, idx_13) = axisThinning.p_oct_label(3, label(idx_13), cube(:, idx_13));
                    cube(:, idx_13) = axisThinning.p_oct_label(5, label(idx_13), cube(:, idx_13));
                end

                idx_15 = find(cube(15, :) == 1);
                if(~isempty(idx_15))
                    cube(15, idx_15) = label(idx_15);
                    cube(:, idx_15) = axisThinning.p_oct_label(3, label(idx_15), cube(:, idx_15));
                end

                idx_16 = find(cube(16, :) == 1);
                if(~isempty(idx_16))
                    cube(16, idx_16) = label(idx_16);
                    cube(:, idx_16) = axisThinning.p_oct_label(3, label(idx_16), cube(:, idx_16));
                    cube(:, idx_16) = axisThinning.p_oct_label(4, label(idx_16), cube(:, idx_16));
                    cube(:, idx_16) = axisThinning.p_oct_label(8, label(idx_16), cube(:, idx_16));
                end

                idx_21 = find(cube(21, :) == 1);
                if(~isempty(idx_21))
                    cube(21, idx_21) = label(idx_21);
                    cube(:, idx_21) = axisThinning.p_oct_label(5, label(idx_21), cube(:, idx_21));
                end

                idx_22 = find(cube(22, :) == 1);
                if(~isempty(idx_22))
                    cube(22, idx_22) = label(idx_22);
                    cube(:, idx_22) = axisThinning.p_oct_label(5, label(idx_22), cube(:, idx_22));
                    cube(:, idx_22) = axisThinning.p_oct_label(6, label(idx_22), cube(:, idx_22));
                    cube(:, idx_22) = axisThinning.p_oct_label(8, label(idx_22), cube(:, idx_22));
                end

                idx_24 = find(cube(24, :) == 1);
                if(~isempty(idx_24))
                    cube(24, idx_24) = label(idx_24);
                end

                idx_25 = find(cube(25, :) == 1);
                if(~isempty(idx_25))
                    cube(25, idx_25) = label(idx_25);
                    cube(:, idx_25) = axisThinning.p_oct_label(8, label(idx_25), cube(:, idx_25));
                end
            end

            if(octant == 8)

                idx_14 = find(cube(14, :) == 1);
                if(~isempty(idx_14))
                    cube(14, idx_14) = label(idx_14);
                    cube(:, idx_14) = axisThinning.p_oct_label(2, label(idx_14), cube(:, idx_14));
                    cube(:, idx_14) = axisThinning.p_oct_label(4, label(idx_14), cube(:, idx_14));
                    cube(:, idx_14) = axisThinning.p_oct_label(6, label(idx_14), cube(:, idx_14));
                end

                idx_16 = find(cube(16, :) == 1);
                if(~isempty(idx_16))
                    cube(16, idx_16) = label(idx_16);
                    cube(:, idx_16) = axisThinning.p_oct_label(3, label(idx_16), cube(:, idx_16));
                    cube(:, idx_16) = axisThinning.p_oct_label(4, label(idx_16), cube(:, idx_16));
                    cube(:, idx_16) = axisThinning.p_oct_label(7, label(idx_16), cube(:, idx_16));
                end

                idx_17 = find(cube(17, :) == 1);
                if(~isempty(idx_17))
                    cube(17, idx_17) = label(idx_17);
                    cube(:, idx_17) = axisThinning.p_oct_label(4, label(idx_17), cube(:, idx_17));
                end

                idx_22 = find(cube(22, :) == 1);
                if(~isempty(idx_22))
                    cube(22, idx_22) = label(idx_22);
                    cube(:, idx_22) = axisThinning.p_oct_label(5, label(idx_22), cube(:, idx_22));
                    cube(:, idx_22) = axisThinning.p_oct_label(6, label(idx_22), cube(:, idx_22));
                    cube(:, idx_22) = axisThinning.p_oct_label(7, label(idx_22), cube(:, idx_22));
                end

                idx_17 = find(cube(17, :) == 1);
                if(~isempty(idx_17))
                    cube(17, idx_17) = label(idx_17);
                    cube(:, idx_17) = axisThinning.p_oct_label(4, label(idx_17), cube(:, idx_17));
                end

                idx_23 = find(cube(23, :) == 1);
                if(~isempty(idx_23))
                    cube(23, idx_23) = label(idx_23);
                    cube(:, idx_23) = axisThinning.p_oct_label(6, label(idx_23), cube(:, idx_23));
                end

                idx_25 = find(cube(25, :) == 1);
                if(~isempty(idx_25))
                    cube(25, idx_25) = label(idx_25);
                    cube(:, idx_25) = axisThinning.p_oct_label(7, label(idx_25), cube(:, idx_25));
                end

                idx_26 = find(cube(26, :) == 1);
                if(~isempty(idx_26))
                    cube(26, idx_26) = label(idx_26);
                end
            end
        end

        function EulerInv =  p_EulerInv(nhood, LUT)
            % Calculate Euler characteristic for each octant and sum up
            eulerChar = zeros(size(nhood, 1), 1);
            n = ones(size(nhood, 1), 1);
            bits = [128, 64, 32, 16, 8, 4, 2];
            octant.SWU = [25, 26, 16, 17, 22, 23, 13];
            octant.SEU = [27, 24, 18, 15, 26, 23, 17];
            octant.NWU = [19, 22, 10, 13, 20, 23, 11];
            octant.NEU = [21, 24, 20, 23, 12, 15, 11];
            octant.SWB = [7, 16, 8, 17, 4, 13, 5];
            octant.SEB = [9, 8, 18, 17, 6, 5, 15];
            octant.NWB = [1, 10, 4, 13, 2, 11, 5];
            octant.NEB = [3, 2, 12, 11, 6, 5, 15];

            fns = fieldnames(octant);
            for k = 1:numel(fns)
                element = octant.(fns{k});
                for m = 1:numel(bits)
                    bit = bits(m);
                    n(nhood(:, element(m)) == 1) = bitor(n(nhood(:, element(m)) == 1), bit);
                end
                eulerChar = eulerChar + LUT(n);
            end

            EulerInv(eulerChar == 0) = true;
        end
 
    end        
    
end
