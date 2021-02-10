classdef SelectVessel < handle
    
    properties (Access = public)
        branchNum;
        branchActual;
        timeMIPvessel;
        vessel_struct = struct;
    end
    
    properties (Access = public, Transient)
        x_slice;
        y_slice;
        z_slice; 
    end
    
    properties (Access = public)
        centerline_app;
        MAGrgb_obj;
        sagittal_figure;
        coronal_figure;
        axial_figure;
        sagittal_img;
        coronal_img;
        axial_img;
        mn = 1;
        mx1;
        mx2;
        mx3;
        sagittal_xhairs;
        coronal_xhairs;
        axial_xhairs;
        x;
        y;
        z;
    end
    
    % constructor
    methods
        
        function self = SelectVessel(centerline_app)
            self.centerline_app = centerline_app;
             self.MAGrgb_obj = MAGrgb(centerline_app.vipr_obj.MAG, centerline_app.vipr_obj.segment);
             self.init_slices();
             self.init_mx();
%             self.create_sagittal_figure();
%             self.create_coronal_figure();
%             self.create_axial_figure();
%             self.create_sagittal_crosshair_listener();
%             self.create_coronoal_crosshair_listener();
%             self.create_axial_crosshair_listener();
%             self.create_sagittal_wheel_listener();
%             self.create_coronal_wheel_listener();
%             self.create_axial_wheel_listener();
%             self.create_coronal_key_press_listener();
%             self.create_sagittal_key_press_listener();
%             self.create_axial_key_press_listener();
        end

    end
    
    % methods for creating images
    methods (Access = public)
        
        function init_slices(self)
            self.x_slice = floor(size(self.MAGrgb_obj.MAG_r, 1)/2);
            self.y_slice = floor(size(self.MAGrgb_obj.MAG_r, 2)/2);
            self.z_slice = floor(size(self.MAGrgb_obj.MAG_r, 3)/2);    
        end
        
        function init_mx(self)
            self.mx1 = size(self.MAGrgb_obj.MAG_r, 1);
            self.mx2 = size(self.MAGrgb_obj.MAG_r, 2);
            self.mx3 = size(self.MAGrgb_obj.MAG_r, 3);
        end
        
        function create_sagittal_figure(self)
            self.sagittal_figure = figure('Name', 'Sagittal', 'NumberTitle', 'Off');
            clf(self.sagittal_figure);
            datacursormode(self.sagittal_figure, 'off'); 
            rotate3d(self.sagittal_figure, 'off');
            zoom(self.sagittal_figure, 'off');
            
            img = self.create_sagittal_image();
            self.sagittal_img = imshow(img, 'parent', gca);
            set(gca, 'Units', 'normalized', 'position', [0 0 1 1]);
            self.sagittal_figure.Units = 'Normalized';
            self.sagittal_figure.OuterPosition = [0.0000 0.0000 (1/3) 1.0000];
            
            % add positional markers
            % self.create_positional_markers_sagittal();
            
            % add crosshairs
            x_pos = size(self.sagittal_img.CData, 1)/2;
            y_pos = size(self.sagittal_img.CData, 2)/2;
            self.sagittal_xhairs = drawcrosshair('Parent', gca, 'Position', [x_pos y_pos], 'LineWidth', 1, 'Color', 'g');
        end
        
        function create_coronal_figure(self)
            self.coronal_figure = figure('Name', 'Coronal', 'NumberTitle', 'Off');
            clf(self.coronal_figure);
            datacursormode(self.coronal_figure, 'off'); 
            rotate3d(self.coronal_figure, 'off');
            zoom(self.coronal_figure, 'off');
            img = self.create_coronal_image();
            self.coronal_img = imshow(img, 'parent', gca);
            set(gca, 'Units', 'normalized', 'position', [0 0 1 1]);
            self.coronal_figure.Units = 'Normalized';
            self.coronal_figure.OuterPosition = [(1/3) 0.0000 (1/3) 1.0000];
            
            % add positional markers
            % self.create_positional_markers_coronal();
            
            % add crosshairs
            x_pos = size(self.coronal_img.CData, 1)/2;
            y_pos = size(self.coronal_img.CData, 2)/2;
            self.coronal_xhairs = drawcrosshair('Parent', gca, 'Position', [x_pos y_pos], 'LineWidth', 1, 'Color', 'g');
        end
        
        function create_axial_figure(self)
            self.axial_figure = figure('Name', 'Axial', 'NumberTitle', 'Off');
            clf(self.axial_figure);
            datacursormode(self.axial_figure, 'off'); 
            rotate3d(self.axial_figure, 'off');
            zoom(self.axial_figure, 'off');
            img = self.create_axial_image();
            self.axial_img = imshow(img, 'parent', gca);
            set(gca, 'Units', 'normalized', 'position', [0 0 1 1]);
            self.axial_figure.Units = 'Normalized';
            self.axial_figure.OuterPosition = [(2/3) 0.0000 (1/3) 1.0000];
            
            % add positional markers
            % self.create_positional_markers_axial();
            
            % add crosshairs
            x_pos = size(self.axial_img.CData, 1)/2;
            y_pos = size(self.axial_img.CData, 2)/2;
            self.axial_xhairs = drawcrosshair('Parent', gca, 'Position', [x_pos y_pos], 'LineWidth', 1, 'Color', 'g');
        end
       
        function img = create_sagittal_image(self)
            img = permute(cat(1, self.MAGrgb_obj.MAG_r(self.x_slice,:,:), ...
                                                       self.MAGrgb_obj.MAG_g(self.x_slice,:,:), ...
                                                       self.MAGrgb_obj.MAG_b(self.x_slice,:,:)), ...
                                                       [3 2 1]);
        end

        function img = create_coronal_image(self)
            img = permute(cat(2, self.MAGrgb_obj.MAG_r(:,self.y_slice,:), ...
                                                      self.MAGrgb_obj.MAG_g(:,self.y_slice,:), ...
                                                      self.MAGrgb_obj.MAG_b(:,self.y_slice,:)), ...
                                                      [3 1 2]);
        end
        
        function img = create_axial_image(self)
           img = cat(3, self.MAGrgb_obj.MAG_r(:,:,self.z_slice), ...
                                              self.MAGrgb_obj.MAG_g(:,:,self.z_slice), ...
                                              self.MAGrgb_obj.MAG_b(:,:,self.z_slice));
        end
        
    end
    
    % general callbacks
    methods (Access = protected)
        
        function update_sagittal_image(self)
            if self.x_slice > self.mx1
                self.x_slice = self.mx1;
            elseif self.x_slice < self.mn
                self.x_slice = self.mn;
            else
                img = self.create_sagittal_image();
                set(self.sagittal_img, 'CData', img);
            end
        end
        
        function update_coronoal_image(self)
            if self.y_slice > self.mx2
                self.y_slice = self.mx2;
            elseif self.y_slice < self.mn
                self.y_slice = self.mn;
            else
                img = self.create_coronal_image();
                set(self.coronal_img, 'CData', img);
            end
        end
        
        function update_axial_image(self)
            if self.z_slice > self.mx3
                self.z_slice = self.mx3;
            elseif self.z_slice < self.mn
                self.z_slice = self.mn;
            else
                img = self.create_axial_image();
                set(self.axial_img, 'CData', img);
            end
        end
        
        function update_positional_markers_sagittal(self)
            set(self.sagittal_marker_left, 'YData', [self.z_slice self.z_slice]);
            set(self.sagittal_marker_right, 'YData', [self.z_slice self.z_slice]);
            set(self.sagittal_marker_top, 'XData', [self.y_slice self.y_slice]);
            set(self.sagittal_marker_bottom, 'XData', [self.y_slice self.y_slice]);
        end
        
        function update_positional_markers_coronal(self)
            set(self.coronal_marker_left, 'YData', [self.z_slice self.z_slice]);
            set(self.coronal_marker_right, 'YData', [self.z_slice self.z_slice]);
            set(self.coronal_marker_top, 'XData', [self.x_slice self.x_slice]);
            set(self.coronal_marker_bottom, 'XData', [self.x_slice self.x_slice]);
        end
        
        function update_positional_markers_axial(self)
            set(self.axial_marker_left, 'YData', [self.x_slice self.x_slice]);
            set(self.axial_marker_right,'YData',[self.x_slice self.x_slice]);
            set(self.axial_marker_top,'XData',[self.y_slice self.y_slice]);
            set(self.axial_marker_bottom,'XData',[self.y_slice self.y_slice]);
        end
        
        function update_crosshairs_sagittal(self)
            self.sagittal_xhairs.Position = [self.y_slice self.z_slice];
        end
        
        function update_crosshairs_coronal(self)
            self.coronal_xhairs.Position = [self.x_slice self.z_slice];
        end
        
        function update_crosshairs_axial(self)
            self.axial_xhairs.Position = [self.y_slice self.x_slice];
        end
 
        function set_xyz(self)
            %{
            original code said x and y were switched (i.e. x = Position(2))
            and x = res - Position(2)
            TODO: ensure the x and y are the same as the old method
            %}
%             self.x = self.centerline_app.vipr_obj.res - self.y_slice;
%             self.y = self.x_slice;
%             self.z = self.z_slice;

            self.x = self.centerline_app.vipr_obj.res - self.x_slice;
            self.y = self.y_slice;
            self.z = self.z_slice;

        end
        
        function add_to_struct(self, vessel_list, idx)
            vessel = string(vessel_list{idx});
            self.vessel_struct.(vessel).x = self.x;
            self.vessel_struct.(vessel).y = self.y;
            self.vessel_struct.(vessel).z = self.z;
            self.vessel_struct.(vessel).branchNum = self.branchNum;
            self.vessel_struct.(vessel).branchActual = self.branchActual;
            self.vessel_struct.(vessel).timeMIPvessel = self.timeMIPvessel;
            self.vessel_struct.(vessel).labels = self.labels;
        end
                        
        function end_vessel_selection(self)
           delete(self.sagittal_figure);
           delete(self.coronal_figure);
           delete(self.axial_figure);
           self.centerline_app.end_vessel_selection(self.vessel_struct);
        end
        
    end
    
    % static methods
    methods (Static)
        
        function [idx, tf, vessel_list] = create_vessel_dropdown()
            vessel_list = {'left_ica', 'right_ica', ...
                           'left_mca', 'right_mca', ...
                           'left_aca', 'right_aca', ...
                           'left_va', 'right_va', ...
                           'basilar_a', ...
                           'left_pca', 'right_pca', ...
                           'superior_sagittal_s', ...
                           'straight_s', ...
                           'transverse_s', ...
                           'non_dominant_transverse_s'};
            name = 'Vessel Selection';
            prompt = {'Select a vessel.', 'Only one vessel can be selected at a time.', ''};
            [idx, tf] = listdlg('PromptString', prompt, ...
                                'SelectionMode', 'single', ...
                                'InitialValue', 1, ...
                                'Name', name, ...
                                'OKString', 'Select Vessel', ...
                                'ListString', vessel_list);
        end
        
    end
    
    % methods for segmenting vessel
    methods (Access = private)
        
        function get_branch_points(self)
            % finds closest point in branchMat then uses that value for vessel selection
            points = regionprops(self.centerline_app.branchMat>0, 'PixelList');
            points = struct2cell(points);
            points = cell2mat(points');

            distance = sqrt(sum((bsxfun(@minus, points, [self.y, self.x, self.z])).^2, 2));
            val = find(distance == min(distance));
            points = points(val(1),:);
            self.branchNum = self.centerline_app.branchMat(points(2), points(1), points(3));
        end
        
        function [indices, indexes] = get_indices(self)
            indices = 0;
            indexes = 0;
            
            for i = 1:length(self.branchNum)
                indices = vertcat(indices, find(self.centerline_app.branchList(:, 4) == self.branchNum));
                indexes = vertcat(indexes, find(self.centerline_app.branchMat == self.branchNum));
            end
            
            indices(1) = []; 
            indexes(1) = [];
        end

        function get_branch(self, indices)
            self.branchActual = zeros(numel(indices),3);
            self.branchActual(:,1) = self.centerline_app.branchList(indices,1);
            self.branchActual(:,2) = self.centerline_app.branchList(indices,2);
            self.branchActual(:,3) = self.centerline_app.branchList(indices,3);
        end
        
        function self = branch_dilate(self, indexes)
            % Image dilate and multiply by mask to extract entire vessel length
            branchMat2 = zeros(self.centerline_app.vipr_obj.res, self.centerline_app.vipr_obj.res, self.centerline_app.vipr_obj.res);
            branchMat2(indexes) = 1;
            I1 = imdilate(branchMat2, ones(7, 7, 7));
            self.timeMIPvessel = I1.*self.centerline_app.vipr_obj.segment;
            self.timeMIPvessel(self.timeMIPvessel~=0) = 1;
        end
        
        function self = add_voxel_labels(self)
            for i = 1:numel(self.branchActual(:,1))
                num = num + 1;
                if mod(num-2,5) == 0
                    stringval = {num2str(num-2)};
                    self.labels = text(self.branchActual(i,2), self.branchActual(i,1), self.branchActual(i,3), stringval);
                end
            end
            self.labels.Color = 'b';
        end
    
    end
    
    % methods for checking vessel
    methods (Access = private)
        
        function check_for_vessel(self)
            if self.branchNum ~= 0
                disp('Vessel found!');
            else
                error('Vessel not found!');
            end
        end
        
        function return_code = branchLength(self)
            if size(self.branchActual(:,1)) < 3
                warning('Vessel is too short to calculate flow');
                while 1
                    str = input('Do you want to inlcude this vessel? [Y/N]');
                    if strcmpi(str, 'y')
                        return_code = 0;
                        break;
                    elseif strcmpi(str, 'n')
                        return_code = 1;
                        break;
                    end
                end
            else
                return_code = 0;
            end
        end
 
    end
    
    % create listeners
    methods (Access = public)
        
        function create_crosshair_listener(self, xhair_handle)
            addlistener(xhair_handle, 'MovingROI', @(src, data)self.move_crosshairs2(src, data));
        end
        
        function create_sagittal_crosshair_listener(self)
            addlistener(self.sagittal_xhairs, 'MovingROI', @(src,data)self.move_crosshairs(src, data));
        end
        
        function create_coronoal_crosshair_listener(self)
            addlistener(self.coronal_xhairs, 'MovingROI', @(src,data)self.move_crosshairs(src, data));
        end
        
        function create_axial_crosshair_listener(self)
            addlistener(self.axial_xhairs, 'MovingROI', @(src,data)self.move_crosshairs(src, data));
        end

        function create_sagittal_wheel_listener(self)
            set(self.sagittal_figure, 'WindowScrollWheelFcn', @self.wheel)
        end
        
        function create_coronal_wheel_listener(self)
            set(self.coronal_figure, 'WindowScrollWheelFcn', @self.wheel)
        end
        
        function create_axial_wheel_listener(self)
            set(self.axial_figure, 'WindowScrollWheelFcn', @self.wheel)
        end
        
        function create_sagittal_key_press_listener(self)
            set(self.sagittal_figure, 'KeyPressFcn', @self.key);
        end
  
        function create_coronal_key_press_listener(self)
            set(self.coronal_figure, 'KeyPressFcn', @self.key);
        end
        
        function create_axial_key_press_listener(self)
            set(self.axial_figure, 'KeyPressFcn', @self.key);
        end
        
    end
    
    % listener callbacks
    methods(Access = private)
        
        function move_crosshairs2(self, src, data)
           if src.Parent.Tag == "Sagittal"
               pos = ceil(data.CurrentPosition);
               self.y_slice = pos(1);
               self.z_slice = pos(2);
               
               
               
           end
        end
        
        function move_crosshairs(self, src, data)
            if src.Parent.Parent.Name == "Sagittal"
                % x movement on the image = y movement for the orientation
                % y movement on the image = z movement for the orientation
                pos = ceil(data.CurrentPosition);
                self.y_slice = pos(1);
                self.z_slice = pos(2);
                
                self.update_crosshairs_coronal();
                self.update_crosshairs_axial();
                
                self.update_coronoal_image();
                self.update_axial_image();
                
            elseif src.Parent.Parent.Name == "Coronal"
                % x movement on the image = x movement for the orientation
                % y movement on the image = z movement for the orientation
                pos = ceil(data.CurrentPosition);
                self.x_slice = round(pos(1));
                self.z_slice = round(pos(2));
                
                self.update_crosshairs_sagittal();
                self.update_crosshairs_axial();
                
                self.update_sagittal_image();
                self.update_axial_image();
                
            elseif src.Parent.Parent.Name == "Axial"
                % x movement on the image = y movement for the orientation
                % y movement on the image = x movement for the orientation
                pos = ceil(data.CurrentPosition);
                self.y_slice = round(pos(1));
                self.x_slice = round(pos(2));
                
                self.update_crosshairs_coronal();
                self.update_crosshairs_sagittal();
                
                self.update_coronoal_image();
                self.update_sagittal_image();
            end
        end
        
        function wheel(self, ~, evnt)
            %{
            scrolling down -> scrollCount > 0 -> move in negative direction on axis
            scrolling up -> scrollCount < 0 -> move in positive direction on axis
            %}
            cur = get(gcf, 'Name');
            switch cur
                case 'Sagittal'
                    if evnt.VerticalScrollCount > 0
                        self.x_slice = self.x_slice + 1;
                    else
                        self.x_slice = self.x_slice - 1;
                    end
                    self.update_sagittal_image();
                    self.update_crosshairs_coronal();
                    self.update_crosshairs_axial();
                    
                case 'Coronal'
                    if evnt.VerticalScrollCount > 0
                        self.y_slice = self.y_slice + 1;
                    else
                        self.y_slice = self.y_slice - 1;
                    end
                    self.update_coronoal_image();
                    self.update_crosshairs_sagittal();
                    self.update_crosshairs_axial();
                
                case 'Axial'
                    if evnt.VerticalScrollCount > 0
                        self.z_slice = self.z_slice + 1;
                    else
                        self.z_slice = self.z_slice - 1;
                    end
                    self.update_axial_image();
                    self.update_crosshairs_sagittal();
                    self.update_crosshairs_coronal();
                otherwise
                    % do nothing
            end
        end
        
        function key(self, ~, event)
            key = event.Key;
            if(strcmp(key, 'return'))
                [idx, tf, vessel_list] = self.create_vessel_dropdown();
                if tf ~= 0
                    self.set_xyz();
                    self.get_branch_points();
                    self.check_for_vessel();
                    [indices, indexes] = get_indices(self);
                    self.get_branch(indices);
                    return_code = self.branchLength();
                    if return_code ~= 0
                        self.branchNum = [];
                        self.branchActual = [];
                        return;
                    end
                    vessel = string(vessel_list{idx});
                    fprintf('Segmenting %s...\n', vessel);
                    self.branch_dilate(indexes);
                    % self.add_voxel_labels();
                    self.add_to_struct(vessel_list, idx);
                    fprintf('Done segmenting %s!\n', vessel);
                end
            elseif(strcmp(key, 'escape'))
                self.end_vessel_selection();
            end
        end
        
    end
    
end
