classdef VesselSelectionController < handle

    % initialization methods
    methods (Access = ?BaseController, Static)

        function [x_slice, y_slice, z_slice] = initializeSlices(args)
            arguments
                args.MAGr;
            end
            
            x_slice = floor(size(args.MAGr, 1)/2);
            y_slice = floor(size(args.MAGr, 2)/2);
            z_slice = floor(size(args.MAGr, 3)/2);
        end
        
        function [x_max, y_max, z_max] = initializeSliceMax(args)
            arguments
                args.MAGr;
            end
            
            x_max = size(args.MAGr, 1);
            y_max = size(args.MAGr, 2);
            z_max = size(args.MAGr, 3);
        end
        
        function data = initializeMAGrgb(args)
            arguments
                args.MAG;
                args.MAGmax;
                args.Segment;
                args.Map;
            end
            
            data = im2uint8(args.MAG/args.MAGmax);
            data(find(args.Segment)) = args.map;
            data = data(end:-1:1,:,end:-1:1);
            data = data(:,:,end:-1:1);
        end
        
    end
    
    % image creation
    methods (Access = ?BaseController, Static)

        function data = initializeSagittalData(args)
            arguments
                args.XMax;
                args.AbsLowerBound;
                args.MAGr;
                args.MAGg;
                args.MAGb;
            end
            
            data = zeros(320,320,3,args.XMax, 'uint8');
            
            % returns a 320x320x3 array
            for slice = args.AbsLowerBound:args.XMax
                data(:,:,:,slice) = permute(cat(1, args.MAGr(slice,:,:), ...
                                                   args.MAGg(slice,:,:), ...
                                                   args.MAGb(slice,:,:)), ...
                                                   [3 2 1]);
            end
        end
        
        function data = initializeCoronalData(args)
            arguments
                args.YMax;
                args.AbsLowerBound;
                args.MAGr;
                args.MAGg;
                args.MAGb;
            end
            
            data = zeros(320,320,3,args.YMax, 'uint8');
            
            % returns a 320x320x3 array
            for slice = args.AbsLowerBound:args.YMax
                data(:,:,:,slice) = permute(cat(2, args.MAGr(:,slice,:), ...
                                                   args.MAGg(:,slice,:), ...
                                                   args.MAGb(:,slice,:)), ...
                                                   [3 1 2]);
            end
        end
        
        function data = initializeAxialData(args)
            arguments
                args.ZMax;
                args.AbsLowerBound;
                args.MAGr;
                args.MAGg;
                args.MAGb;
            end
            
            data = zeros(320,320,3,args.ZMax, 'uint8');
            
            % returns a 320x320x3 array
            for slice = args.AbsLowerBound:args.ZMax
                data(:,:,:,slice) = cat(3, args.MAGr(:,:,slice), ...
                                           args.MAGg(:,:,slice), ...
                                           args.MAGb(:,:,slice));
            end
        end
        
        function img = updateSagittalImage(args)
            arguments
                args.SagittalData;
                args.XSlice;
            end
            % TODO: can probably make the text locations a constant
            
            img = args.SagittalData(:,:,:,args.XSlice);
			img = insertText(img, [sz/2 0], 'S', 'BoxColor', 'black', 'BoxOpacity', 1, 'TextColor', 'white', 'AnchorPoint', 'CenterTop');
            img = insertText(img, [sz/2 sz], 'I', 'BoxColor', 'black', 'BoxOpacity', 1, 'TextColor', 'white', 'AnchorPoint', 'CenterBottom');
            img = insertText(img, [5 sz/2], 'L', 'BoxColor', 'black', 'BoxOpacity', 1, 'TextColor', 'white', 'AnchorPoint', 'CenterTop');
            img = insertText(img, [sz-5 sz/2], 'R', 'BoxColor', 'black', 'BoxOpacity', 1, 'TextColor', 'white', 'AnchorPoint', 'CenterTop');
        end
        
        function img = updateCoronalImage(args)
            arguments
                args.CoronalData;
                args.YSlice;
            end
            
            img = args.CoronalData(:,:,:,args.YSlice);
			sz = size(img, 1);
            img = insertText(img, [sz/2 0], 'S', 'BoxColor', 'black', 'BoxOpacity', 1, 'TextColor', 'white', 'AnchorPoint', 'CenterTop');
            img = insertText(img, [sz/2 sz], 'I', 'BoxColor', 'black', 'BoxOpacity', 1, 'TextColor', 'white', 'AnchorPoint', 'CenterBottom');
            img = insertText(img, [5 sz/2], 'A', 'BoxColor', 'black', 'BoxOpacity', 1, 'TextColor', 'white', 'AnchorPoint', 'CenterTop');
            img = insertText(img, [sz-5 sz/2], 'P', 'BoxColor', 'black', 'BoxOpacity', 1, 'TextColor', 'white', 'AnchorPoint', 'CenterTop');
        end
        
        function img = updateAxialData(args)
            arguments
                args.AxialData;
                args.ZSlice;
            end
            
            img = args.AxialData(:,:,:,args.ZSlice);
            sz = size(img, 1);
            img = insertText(img, [sz/2 0], 'A', 'BoxColor', 'black', 'BoxOpacity', 1, 'TextColor', 'white', 'AnchorPoint', 'CenterTop');
            img = insertText(img, [sz/2 sz], 'P', 'BoxColor', 'black', 'BoxOpacity', 1, 'TextColor', 'white', 'AnchorPoint', 'CenterBottom');
            img = insertText(img, [5 sz/2], 'L', 'BoxColor', 'black', 'BoxOpacity', 1, 'TextColor', 'white', 'AnchorPoint', 'CenterTop');
            img = insertText(img, [sz-5 sz/2], 'R', 'BoxColor', 'black', 'BoxOpacity', 1, 'TextColor', 'white', 'AnchorPoint', 'CenterTop');
        end
        
    end
    
    % crosshairs
    methods (Access = public, Static)
        
        % create crosshairs
        function crosshairs = createCrosshairs(args)
            arguments
                args.Axes;
                args.Image;
            end
            
            x_pos = size(args.Image.CData, 1)/2;
            y_pos = size(args.Image.CData, 2)/2;
            crosshairs = drawcrosshair('Parent', args.Axes, 'Position', [x_pos y_pos], 'LineWidth', 1, 'Color', 'g');
        end
        
        % create crosshair listeners
        function createCrosshairsListener(args)
            arguments
                args.Crosshairs;
            end
            
            addlistener(args.SagittalCrosshairs, 'MovingROI', @(src,data)VesselSelectionController.moveCrosshairs(src, data));
        end

    end
    
    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, CenterlineToolApp)
            app.CenterlineToolApp = CenterlineToolApp;
            app.mag_rgb(app.CenterlineToolApp.VIPR.MAG, app.CenterlineToolApp.VIPR.Segment);
            app.init_slices();
            app.init_mx();
            app.update_coordinate_labels();
            
%             % create images
%             img_ = app.create_sagittal_image();
%             app.SagittalImage = imshow(img_, 'Parent', app.SagittalAxes);
% 
%             img_ = app.create_coronal_image();
%             app.CoronalImage = imshow(img_, 'Parent', app.CoronalAxes);
%             
%             img_ = app.create_axial_image();
%             app.AxialImage = imshow(img_, 'Parent', app.AxialAxes);

%             % 'locks' the image to prevent accidental moving
%             disableDefaultInteractivity(app.SagittalAxes);
%             disableDefaultInteractivity(app.CoronalAxes);
%             disableDefaultInteractivity(app.AxialAxes);
%             
%             % create xhairs
%             app.create_sagittal_crosshairs();
%             app.create_coronal_crosshairs();
%             app.create_axial_crosshairs();
%             
%             % create xhairs listeners
%             app.create_sagittal_crosshair_listener();
%             app.create_coronoal_crosshair_listener();
%             app.create_axial_crosshair_listener();
            
%             % assign context menus to images
%             app.SagittalImage.ContextMenu = app.ContextMenu;
%             app.CoronalImage.ContextMenu = app.ContextMenu;
%             app.AxialImage.ContextMenu = app.ContextMenu;
%             
            % load data, if present
            app.load_();
        end

        % Button pushed function: DoneButton
        function done_button_pushed(app, event)
            app.remove_from_struct();
            app.save_();
            app.uifigure_close_request();
        end

        % Button pushed function: CancelButton
        function cancel_button_pushed(app, event)
            app.uifigure_close_request();
        end

        % Cell selection callback: VesselTable
        function vessel_table_cell_selection(app, event)
            indices = event.Indices;
            app.VesselTable.ActiveIndices = indices;
            if indices(2) == 1
                 vesselTable = app.VesselTable.Data;
                 idx = indices(1);
                 app.XSlice = vesselTable.X(idx);
                 app.YSlice = vesselTable.Y(idx);
                 app.ZSlice = vesselTable.Z(idx);
                 app.update_sagittal_image();
                 app.update_coronoal_image();
                 app.update_axial_image();
                 app.update_crosshairs_sagittal();
                 app.update_crosshairs_coronal();
                 app.update_crosshairs_axial();
                 app.update_coordinate_labels();
            end
        end

        % Menu option selection callback: ContextMenu
        function context_menu_option_selected(app, event, varargin)
            if nargin < 3
                vessel = event.Source.Text;
            elseif nargin >= 3
                vessel = varargin{1};
            end 
            fprintf('Segmenting %s...\n', vessel);
            app.set_xyz();
            segmentObj = SegmentVessel(app.CenterlineToolApp.VIPR);
            try
                [branchNumber, branchActual, timeMIPVessel] = segmentObj.main(app.XCoordinate, app.YCoordinate, app.ZCoordinate);
            catch ME
                switch ME.identifier
                    case "SegmentVessel:CheckVessel:Invalid"
                        msg = strcat(ME.message, ": ", vessel);
                        disp(msg);
                        return;
                    case "SegmentVessel:BranchLength:Short"
                        msg = strcat(ME.message, ": ", vessel);
                        disp(msg);
                        return;
                    otherwise
                        rethrow(ME);
                end
            end
            app.add_to_struct(vessel, branchNumber, branchActual, timeMIPVessel);
            vesselTable = app.VesselTable.Data;
            newData = {vessel, app.XCoordinate, app.YCoordinate, app.ZCoordinate};
            % overwrite previous entry, if exists
            if any(ismember(vesselTable.Vessel, vessel))
                vesselTable(ismember(vesselTable.Vessel, vessel), :) = newData;
            else
                vesselTable = [vesselTable; newData];
            end
            app.VesselTable.Data = vesselTable;
            fprintf('Done segmenting %s!\n', vessel);
        end
        
        % Toolbar selection callback
        function toolbar_value_changed(app, event)
            tb = event.Source.Parent.Tag;
            limits = [0 app.CenterlineToolApp.VIPR.Resolution];
            if strcmp(tb, "sagittal_tb")
                app.SagittalAxes.XLim = limits;
                app.SagittalAxes.YLim = limits;
            elseif strcmp(tb, "coronal_tb")
                app.CoronalAxes.XLim = limits;
                app.CoronalAxes.YLim = limits;
            elseif strcmp(tb, "axial_tb")
                app.AxialAxes.XLim = limits;
                app.AxialAxes.YLim = limits;
            end
        end

        % Window key press function: UIFigure
        function uifigure_window_key_press(app, event)
            key = event.Key;
            switch char(event.Modifier)
                case 'control'
                    if strcmpi(event.Key, 'w')
                        app.uifigure_close_request();
                    elseif strcmpi(event.Key, 'space')
                        currentState = app.dcm_obj.Enable;
                        switch currentState
                            case 'on'
                                app.dcm_obj.Enable = 'off';
                            case 'off'
                                app.dcm_obj.Enable = 'on';
                        end
                    end
                case ''
                    if(strcmp(key, 'return'))
                        % app.SelectButtonPushed();
                    elseif(strcmpi(key, 'space'))
                        % make xhairs interactive if the window had lost focuse
                        % a bug with app designer and this is a workaround
                        app.SagittalCrosshairs.Selected = 1;
                        app.CoronalCrosshairs.Selected = 1;
                        app.AxialCrosshairs.Selected = 1;
                    elseif(strcmpi(key, 'escape'))
                        app.UIFigure.WindowState = 'normal';
                    end
            end
            
            switch key
                case 'delete'
                    vesselTable = app.VesselTable.Data;
                    row = app.VesselTable.ActiveIndices(1);
                    vesselTable(row, :) = [];
                    app.VesselTable.Data = vesselTable;
            end
        end

        % Window scroll wheel function: UIFigure
        function uifigure_window_scroll_wheel(app, event)
            verticalScrollAmount = event.VerticalScrollAmount;
            verticalScrollCount = event.VerticalScrollCount;
            %{
            TODO: include scroll fcn to move the xhairs in a more granular
            manner. Need to figure out how to ensure the callback is linked
            to the proper axes where the cursor is hovering (i.e. make the
            fcn only work when the cursor is over an image)
            %}
        end

        % Close request function: UIFigure
        function uifigure_close_request(app, event)
            delete(app);
        end
        
    end
    
    % update callbacks
    methods (Access = private)
        
        function update_sagittal_image(app)
            if app.XSlice > app.XSliceMax
                app.XSlice = app.XSliceMax;
            elseif app.XSlice < app.AbsLowerBound
                app.XSlice = app.AbsLowerBound;
            else
                img = app.updateSagittalImage();
                set(app.SagittalImage, 'CData', img);
            end
        end
        
        function update_coronoal_image(app)
            if app.YSlice > app.YSliceMax
                app.YSlice = app.YSliceMax;
            elseif app.YSlice < app.AbsLowerBound
                app.YSlice = app.AbsLowerBound;
            else
                img = app.updateCoronalImage();
                set(app.CoronalImage, 'CData', img);
            end
        end
        
        function update_axial_image(app)
            if app.ZSlice > app.ZSliceMax
                app.ZSlice = app.ZSliceMax;
            elseif app.ZSlice < app.AbsLowerBound
                app.ZSlice = app.AbsLowerBound;
            else
                img = app.updateAxialImage();
                set(app.AxialImage, 'CData', img);
            end
        end
                
        function update_crosshairs_sagittal(app)
            app.SagittalCrosshairs.Position = [app.YSlice app.ZSlice];
        end
        
        function update_crosshairs_coronal(app)
            app.CoronalCrosshairs.Position = [app.XSlice app.ZSlice];
        end
        
        function update_crosshairs_axial(app)
            app.AxialCrosshairs.Position = [app.YSlice app.XSlice];
        end
    
        function update_table(app)
            vesselTable = app.VesselTable.Data;
            vessel = app.ListBox.Value;
            app.set_xyz();
            newData = {vessel, app.XCoordinate, app.YCoordinate, app.ZCoordinate};
            idx = vesselTable.Vessel == string(vessel);
            vesselTable(idx, :) = [];
            vesselTable = [vesselTable; newData];
            app.VesselTable.Data = vesselTable;
        end
        
        function update_coordinate_labels(app)
            app.XLabel.Text = ['X: ' num2str(app.XSlice)];
            app.YLabel.Text = ['Y: ' num2str(app.YSlice)];
            app.ZLabel.Text = ['Z: ' num2str(app.ZSlice)];
        end
 
    end
    
    % listener callbacks
    methods (Access = private)
        
        function move_crosshairs(app, src, data)
            if src.Parent.Tag == "SagittalAxes"
                % XCoordinate movement on the image = YCoordinate movement for the orientation
                % YCoordinate movement on the image = ZCoordinate movement for the orientation
                pos = ceil(data.CurrentPosition);
                app.YSlice = pos(1);
                app.ZSlice = pos(2);
                
                app.update_crosshairs_coronal();
                app.update_crosshairs_axial();
                
                app.update_coronoal_image();
                app.update_axial_image();
                
            elseif src.Parent.Tag == "CoronalAxes"
                % XCoordinate movement on the image = XCoordinate movement for the orientation
                % YCoordinate movement on the image = ZCoordinate movement for the orientation
                pos = ceil(data.CurrentPosition);
                app.XSlice = round(pos(1));
                app.ZSlice = round(pos(2));
                
                app.update_crosshairs_sagittal();
                app.update_crosshairs_axial();
                
                app.update_sagittal_image();
                app.update_axial_image();
                
            elseif src.Parent.Tag == "AxialAxes"
                % XCoordinate movement on the image = YCoordinate movement for the orientation
                % YCoordinate movement on the image = XCoordinate movement for the orientation
                pos = ceil(data.CurrentPosition);
                app.YSlice = round(pos(1));
                app.XSlice = round(pos(2));
                
                app.update_crosshairs_coronal();
                app.update_crosshairs_sagittal();
                
                app.update_coronoal_image();
                app.update_sagittal_image();
            end
            app.update_coordinate_labels();
        end
        
        function wheel(app, ~, evnt)
            %{
            scrolling down -> scrollCount > 0 -> move in negative direction on axis
            scrolling up -> scrollCount < 0 -> move in positive direction on axis
            %}
            cur = get(gcf, 'Name');
            switch cur
                case 'Sagittal'
                    if evnt.VerticalScrollCount > 0
                        app.XSlice = app.XSlice + 1;
                    else
                        app.XSlice = app.XSlice - 1;
                    end
                    app.update_sagittal_image();
                    app.update_crosshairs_coronal();
                    app.update_crosshairs_axial();
                    
                case 'Coronal'
                    if evnt.VerticalScrollCount > 0
                        app.YSlice = app.YSlice + 1;
                    else
                        app.YSlice = app.YSlice - 1;
                    end
                    app.update_coronoal_image();
                    app.update_crosshairs_sagittal();
                    app.update_crosshairs_axial();
                
                case 'Axial'
                    if evnt.VerticalScrollCount > 0
                        app.ZSlice = app.ZSlice + 1;
                    else
                        app.ZSlice = app.ZSlice - 1;
                    end
                    app.update_axial_image();
                    app.update_crosshairs_sagittal();
                    app.update_crosshairs_coronal();
                otherwise
                    % do nothing
            end
        end
        
    end
    
    % general functions
    methods (Access = private)
    
        function set_xyz(app)
            %{
            original code said XCoordinate and YCoordinate were switched (i.e. XCoordinate = Position(2))
            and XCoordinate = res - Position(2)
            TODO: ensure the XCoordinate and YCoordinate are the same as the old method
            %}
%             app.XCoordinate = app.CenterlineToolApp.VIPR.Resolution - app.YSlice;
%             app.YCoordinate = app.XSlice;
%             app.ZCoordinate = app.ZSlice;

            app.XCoordinate = app.XSlice;
            app.YCoordinate = app.YSlice;
            app.ZCoordinate = app.ZSlice;
        end
        
        function add_to_struct(app, vessel, branchNumber, branchActual, timeMIPVessel)
            vessel = regexprep(vessel, '\W', '');
            % important so that it deletes any previous data associated
            % with the vessel
            app.CenterlineToolApp.VIPR.Vessel.(vessel) = struct;
            app.CenterlineToolApp.VIPR.Vessel.(vessel).XCoordinate = app.XCoordinate;
            app.CenterlineToolApp.VIPR.Vessel.(vessel).YCoordinate = app.YCoordinate;
            app.CenterlineToolApp.VIPR.Vessel.(vessel).ZCoordinate = app.ZCoordinate;
            app.CenterlineToolApp.VIPR.Vessel.(vessel).BranchNumber = branchNumber;
            app.CenterlineToolApp.VIPR.Vessel.(vessel).BranchActual = branchActual;
            app.CenterlineToolApp.VIPR.Vessel.(vessel).TimeMIPVessel = timeMIPVessel;
        end
        
        function remove_from_struct(app)
            % check if any vessels were even selected
            if ~isfield(app.CenterlineToolApp.VIPR, 'Vessel')
                return;
            end
            
            % get vessels in table
            vesselTable = app.VesselTable.Data;
            vesselTableNames = vesselTable.Vessel;
            vesselTableNames = regexprep(vesselTableNames, '\W', '');
            
            % get vessels in struct
            structNames = fieldnames(app.CenterlineToolApp.VIPR.Vessel);
            
            % compare the lists, remove from struct any vessels not in
            % table
            toRemove = setdiff(structNames, vesselTableNames);
            
            for k = 1:numel(toRemove)
                app.CenterlineToolApp.VIPR.Vessel = rmfield(app.CenterlineToolApp.VIPR.Vessel, toRemove{k});
            end
            
        end

    end
    
    % custom save method
    methods (Access = private)
        
        function save_(app)
            %{
            app designer objects cannot utilize 'saveobj' and 'loadoabj'
            properly
            this is a workaround to that to save only necessary data that,
            when combined with the required input arg to the app, will
            restore the previous state
            %}
            disp("Saving vessel selection parameters...");
            directory = fullfile(app.CenterlineToolApp.VIPR.DataDirectory, 'saved_analysis');
            if ~exist(directory, 'dir')
                mkdir(directory);
            end
            fname = 'vessel_coordinates.txt';
            vesselTable = app.VesselTable.Data;
            writetable(vesselTable, fullfile(directory, fname));
        end
        
    end

    % custom load method
    methods (Access = private)
        
        function load_(app)
            %{
            app designer objects cannot utilize 'saveobj' and 'loadoabj'
            properly
            this is a workaround to that to load previously saved data that,
            when combined with the required input arg to the app, will
            restore the previous state
            %}
            directory = fullfile(app.CenterlineToolApp.VIPR.DataDirectory, 'analysis');
            fname = 'vessel_coordinates.txt';
            
            if exist(fullfile(directory, fname), 'file')
                vesselTable = readtable(fullfile(directory, fname));
                if ~isempty(vesselTable)
                    for k = 1:size(vesselTable, 1)
                        vessel = string(vesselTable.Vessel(k,1));
                        app.XSlice = vesselTable.X(k,1);
                        app.YSlice = vesselTable.Y(k,1);
                        app.ZSlice = vesselTable.Z(k,1);
                        app.context_menu_option_selected([], vessel);
                    end
                end
                app.VesselTable.Data = vesselTable;
            end
        end
        
    end
    
end