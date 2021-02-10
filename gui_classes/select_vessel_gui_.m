classdef select_vessel_gui_ < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure      matlab.ui.Figure
        DoneButton    matlab.ui.control.Button
        CancelButton  matlab.ui.control.Button
        VesselTable   matlab.ui.control.Table
        SagittalAxes  matlab.ui.control.UIAxes
        CoronalAxes   matlab.ui.control.UIAxes
        AxialAxes     matlab.ui.control.UIAxes
        SelectButton  matlab.ui.control.Button
        ListBox       matlab.ui.control.ListBox
        XLabel        matlab.ui.control.Label
        YLabel        matlab.ui.control.Label
        ZLabel        matlab.ui.control.Label
    end

    properties (Access = private)
        centerline_app;
        MAGrgb_obj;
        segment_obj;
        branchNum;
        branchActual;
        timeMIPvessel;
        sagittal_img;
        coronal_img;
        axial_img;
        sagittal_xhairs;
        coronal_xhairs;
        axial_xhairs;
        mn = 1;
        mx1;
        mx2;
        mx3;
        x;
        y;
        z;
        x_slice;
        y_slice;
        z_slice;
        restoreviewbtn;
        sagittal_axes_tb;
        coronal_axes_tb;
        axial_axes_tb;
    end
    
    % initialization methods
    methods (Access = private)
        
        function init_axis_toolbar(app)
            % create toolbars
            app.sagittal_axes_tb = axtoolbar(app.SagittalAxes, {'zoomin', 'zoomout', 'export'});
            app.coronal_axes_tb = axtoolbar(app.CoronalAxes, {'zoomin', 'zoomout', 'export'});
            app.axial_axes_tb = axtoolbar(app.AxialAxes, {'zoomin', 'zoomout', 'export'});
            
            % add tags
            app.sagittal_axes_tb.Tag = 'sagittal_tb';
            app.coronal_axes_tb.Tag = 'coronal_tb';
            app.axial_axes_tb.Tag = 'axial_tb';
            
            % add push button
            sagittal_btn = axtoolbarbtn(app.sagittal_axes_tb, 'push');
            coronal_btn = axtoolbarbtn(app.coronal_axes_tb, 'push');
            axial_btn = axtoolbarbtn(app.axial_axes_tb, 'push');
            
            % change button icon
            sagittal_btn.Icon = 'restoreview';
            coronal_btn.Icon = 'restoreview';
            axial_btn.Icon = 'restoreview';
            
            % create callback for buttons
            sagittal_btn.ButtonPushedFcn = createCallbackFcn(app, @tbValueChanged, true);
            coronal_btn.ButtonPushedFcn = createCallbackFcn(app, @tbValueChanged, true);
            axial_btn.ButtonPushedFcn = createCallbackFcn(app, @tbValueChanged, true);
        end
        
        function init_axis_xlim(app)
            res = app.centerline_app.vipr_obj.res;
            app.SagittalAxes.XLim = [0 res];
            app.CoronalAxes.XLim = [0 res];
            app.AxialAxes.XLim = [0 res];
        end
        
        function init_axis_ylim(app)
            res = app.centerline_app.vipr_obj.res;
            app.SagittalAxes.YLim = [0 res];
            app.CoronalAxes.YLim = [0 res];
            app.AxialAxes.YLim = [0 res];
        end
        
        function init_slices(app)
            app.x_slice = floor(size(app.MAGrgb_obj.MAG_r, 1)/2);
            app.y_slice = floor(size(app.MAGrgb_obj.MAG_r, 2)/2);
            app.z_slice = floor(size(app.MAGrgb_obj.MAG_r, 3)/2);    
        end
        
        function init_mx(app)
            app.mx1 = size(app.MAGrgb_obj.MAG_r, 1);
            app.mx2 = size(app.MAGrgb_obj.MAG_r, 2);
            app.mx3 = size(app.MAGrgb_obj.MAG_r, 3);
        end

        function init_vessel_list(app)
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
           app.ListBox.Items = vessel_list;
        end
        
        function init_table(app)
            sz = [0 4];
            names = app.VesselTable.ColumnName;
            types = {'string', 'double', 'double', 'double'};
            t = table('Size', sz, 'VariableTypes', types, 'VariableNames', names);
            app.VesselTable.Data = t;
        end
        
        function init_load_previous_data(app)
            t = app.VesselTable.Data;
            names = fieldnames(app.centerline_app.vipr_obj.vessel);            
            for k = 1:numel(names)
                x = app.centerline_app.vipr_obj.vessel.(names{k}).x;
                y = app.centerline_app.vipr_obj.vessel.(names{k}).y;
                z = app.centerline_app.vipr_obj.vessel.(names{k}).z;
                data = {names{k}, x, y, z};
                t = [t; data];
            end
            app.VesselTable.Data = t;
        end
        
    end
    
    % create figures
    methods (Access = private)
       
        function img = create_sagittal_image(app)
            img = permute(cat(1, app.MAGrgb_obj.MAG_r(app.x_slice,:,:), ...
                                                       app.MAGrgb_obj.MAG_g(app.x_slice,:,:), ...
                                                       app.MAGrgb_obj.MAG_b(app.x_slice,:,:)), ...
                                                       [3 2 1]);
        end

        function img = create_coronal_image(app)
            img = permute(cat(2, app.MAGrgb_obj.MAG_r(:,app.y_slice,:), ...
                                                      app.MAGrgb_obj.MAG_g(:,app.y_slice,:), ...
                                                      app.MAGrgb_obj.MAG_b(:,app.y_slice,:)), ...
                                                      [3 1 2]);
        end
        
        function img = create_axial_image(app)
            img = cat(3, app.MAGrgb_obj.MAG_r(:,:,app.z_slice), ...
                                              app.MAGrgb_obj.MAG_g(:,:,app.z_slice), ...
                                              app.MAGrgb_obj.MAG_b(:,:,app.z_slice));
        end
        
        function create_sagittal_xhairs(app)
            x_pos = size(app.sagittal_img.CData, 1)/2;
            y_pos = size(app.sagittal_img.CData, 2)/2;
            app.sagittal_xhairs = drawcrosshair('Parent', app.SagittalAxes, 'Position', [x_pos y_pos], 'LineWidth', 1, 'Color', 'g');
        end
        
        function create_coronal_xhairs(app)
            x_pos = size(app.coronal_img.CData, 1)/2;
            y_pos = size(app.coronal_img.CData, 2)/2;
            app.coronal_xhairs = drawcrosshair('Parent', app.CoronalAxes, 'Position', [x_pos y_pos], 'LineWidth', 1, 'Color', 'g');
        end
        
        function create_axial_xhairs(app)
            x_pos = size(app.axial_img.CData, 1)/2;
            y_pos = size(app.axial_img.CData, 2)/2;
            app.axial_xhairs = drawcrosshair('Parent', app.AxialAxes, 'Position', [x_pos y_pos], 'LineWidth', 1, 'Color', 'g');
        end

    end
    
    % create listeners
    methods (Access = private)
        
        function create_sagittal_crosshair_listener(app)
            addlistener(app.sagittal_xhairs, 'MovingROI', @(src,data)app.move_crosshairs(src, data));
        end
        
        function create_coronoal_crosshair_listener(app)
            addlistener(app.coronal_xhairs, 'MovingROI', @(src,data)app.move_crosshairs(src, data));
        end
        
        function create_axial_crosshair_listener(app)
            addlistener(app.axial_xhairs, 'MovingROI', @(src,data)app.move_crosshairs(src, data));
        end

    end
    
    % update callbacks
    methods (Access = private)
        
        function update_sagittal_image(app)
            if app.x_slice > app.mx1
                app.x_slice = app.mx1;
            elseif app.x_slice < app.mn
                app.x_slice = app.mn;
            else
                img = app.create_sagittal_image();
                set(app.sagittal_img, 'CData', img);
            end
        end
        
        function update_coronoal_image(app)
            if app.y_slice > app.mx2
                app.y_slice = app.mx2;
            elseif app.y_slice < app.mn
                app.y_slice = app.mn;
            else
                img = app.create_coronal_image();
                set(app.coronal_img, 'CData', img);
            end
        end
        
        function update_axial_image(app)
            if app.z_slice > app.mx3
                app.z_slice = app.mx3;
            elseif app.z_slice < app.mn
                app.z_slice = app.mn;
            else
                img = app.create_axial_image();
                set(app.axial_img, 'CData', img);
            end
        end
                
        function update_crosshairs_sagittal(app)
            app.sagittal_xhairs.Position = [app.y_slice app.z_slice];
        end
        
        function update_crosshairs_coronal(app)
            app.coronal_xhairs.Position = [app.x_slice app.z_slice];
        end
        
        function update_crosshairs_axial(app)
            app.axial_xhairs.Position = [app.y_slice app.x_slice];
        end
    
    end
    
    % general callbacks
    methods (Access = private)
    
        function set_xyz(app)
            %{
            original code said x and y were switched (i.e. x = Position(2))
            and x = res - Position(2)
            TODO: ensure the x and y are the same as the old method
            %}
            % app.x = app.centerline_app.vipr_obj.res - app.y_slice;
            % app.y = app.x_slice;
            % app.z = app.z_slice;

            app.x = app.centerline_app.vipr_obj.res - app.x_slice;
            app.y = app.y_slice;
            app.z = app.z_slice;
        end
        
        function update_table(app)
            t = app.VesselTable.Data;
            vessel = app.ListBox.Value;
            app.set_xyz();
            new_data = {vessel, app.x, app.y, app.z};
            idx = t.Vessel == string(vessel);
            t(idx, :) = [];
            t = [t; new_data];
            app.VesselTable.Data = t;
        end
        
        function update_coordinate_labels(app)
            app.XLabel.Text = ['X: ' num2str(app.x_slice)];
            app.YLabel.Text = ['Y: ' num2str(app.y_slice)];
            app.ZLabel.Text = ['Z: ' num2str(app.z_slice)];
        end
        
        function segment_vessel(app, vessel)
            app.segment_obj = SelectVessel2(app.centerline_app.vipr_obj);
            app.set_xyz();
            app.segment_obj.get_branch_points(app.x, app.y, app.z);
            app.segment_obj.check_for_vessel();
            fprintf('Segmenting %s...\n', vessel);
            app.segment_obj.get_indices();
            app.segment_obj.get_branch();
            app.segment_obj.branchLength();
            app.segment_obj.branch_dilate();
            fprintf('Done segmenting %s!\n', vessel);
        end
        
        function add_to_struct(app, vessel)
            app.centerline_app.vipr_obj.vessel.(vessel).x = app.x;
            app.centerline_app.vipr_obj.vessel.(vessel).y = app.y;
            app.centerline_app.vipr_obj.vessel.(vessel).z = app.z;
            app.centerline_app.vipr_obj.vessel.(vessel).branchNum = app.segment_obj.branchNum;
            app.centerline_app.vipr_obj.vessel.(vessel).branchActual = app.segment_obj.branchActual;
            app.centerline_app.vipr_obj.vessel.(vessel).timeMIPvessel = app.segment_obj.timeMIPvessel;
        end

        function tbValueChanged(app, event)
            tb = event.Source.Parent.Tag;
            limits = [0 app.centerline_app.vipr_obj.res];
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
        
    end
    
    % listener callbacks
    methods (Access = private)
        
        function move_crosshairs(app, src, data)
            if src.Parent.Tag == "SagittalAxes"
                % x movement on the image = y movement for the orientation
                % y movement on the image = z movement for the orientation
                pos = ceil(data.CurrentPosition);
                app.y_slice = pos(1);
                app.z_slice = pos(2);
                
                app.update_crosshairs_coronal();
                app.update_crosshairs_axial();
                
                app.update_coronoal_image();
                app.update_axial_image();
                
            elseif src.Parent.Tag == "CoronalAxes"
                % x movement on the image = x movement for the orientation
                % y movement on the image = z movement for the orientation
                pos = ceil(data.CurrentPosition);
                app.x_slice = round(pos(1));
                app.z_slice = round(pos(2));
                
                app.update_crosshairs_sagittal();
                app.update_crosshairs_axial();
                
                app.update_sagittal_image();
                app.update_axial_image();
                
            elseif src.Parent.Tag == "AxialAxes"
                % x movement on the image = y movement for the orientation
                % y movement on the image = x movement for the orientation
                pos = ceil(data.CurrentPosition);
                app.y_slice = round(pos(1));
                app.x_slice = round(pos(2));
                
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
                        app.x_slice = app.x_slice + 1;
                    else
                        app.x_slice = app.x_slice - 1;
                    end
                    app.update_sagittal_image();
                    app.update_crosshairs_coronal();
                    app.update_crosshairs_axial();
                    
                case 'Coronal'
                    if evnt.VerticalScrollCount > 0
                        app.y_slice = app.y_slice + 1;
                    else
                        app.y_slice = app.y_slice - 1;
                    end
                    app.update_coronoal_image();
                    app.update_crosshairs_sagittal();
                    app.update_crosshairs_axial();
                
                case 'Axial'
                    if evnt.VerticalScrollCount > 0
                        app.z_slice = app.z_slice + 1;
                    else
                        app.z_slice = app.z_slice - 1;
                    end
                    app.update_axial_image();
                    app.update_crosshairs_sagittal();
                    app.update_crosshairs_coronal();
                otherwise
                    % do nothing
            end
        end
        
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, centerline_app)
            app.centerline_app = centerline_app;
            app.MAGrgb_obj = MAGrgb(app.centerline_app.vipr_obj.MAG, app.centerline_app.vipr_obj.segment);
            app.init_slices();
            app.init_mx();
            app.init_vessel_list();
            app.init_table();
            
            %% create images
            img = app.create_sagittal_image();
            app.sagittal_img = imshow(img, 'Parent', app.SagittalAxes);

            img = app.create_coronal_image();
            app.coronal_img = imshow(img, 'Parent', app.CoronalAxes);
            
            img = app.create_axial_image();
            app.axial_img = imshow(img, 'Parent', app.AxialAxes);

            %% 'locks' the image to prevent accidental moving
            disableDefaultInteractivity(app.SagittalAxes);
            disableDefaultInteractivity(app.CoronalAxes);
            disableDefaultInteractivity(app.AxialAxes);
            
            %% create xhairs
            app.create_sagittal_xhairs();
            app.create_coronal_xhairs();
            app.create_axial_xhairs();
            
            %% create xhairs listeners
            app.create_sagittal_crosshair_listener();
            app.create_coronoal_crosshair_listener();
            app.create_axial_crosshair_listener();
            
            %% tidy axes
            app.init_axis_xlim();
            app.init_axis_ylim();
            app.init_axis_toolbar();
            
            %% if vessel selection already occurred, reload the data
            if isfield(app.centerline_app.vipr_obj, 'vessel')
                app.init_load_previous_data();
            end
        end

        % Button pushed function: SelectButton
        function SelectButtonPushed(app, event)
            vessel = string(app.ListBox.Value);
            if ~strcmp(vessel, "")
                app.segment_vessel(vessel);
                app.update_table();
                app.add_to_struct(vessel);
            else
                fprintf(2, "Please select a vessel from the list\n");
            end
        end

        % Button pushed function: DoneButton
        function DoneButtonPushed(app, event)
            app.UIFigureCloseRequest();
        end

        % Button pushed function: CancelButton
        function CancelButtonPushed(app, event)
            app.UIFigureCloseRequest();
        end

        % Cell selection callback: VesselTable
        function VesselTableCellSelection(app, event)
            indices = event.Indices;
            if indices(2) == 1
                 t = app.VesselTable.Data;
                 idx = indices(1);
                 app.x_slice = t.X(idx);
                 app.y_slice = t.Y(idx);
                 app.z_slice = t.Z(idx);
                 app.update_sagittal_image();
                 app.update_coronoal_image();
                 app.update_axial_image();
                 app.update_crosshairs_sagittal();
                 app.update_crosshairs_coronal();
                 app.update_crosshairs_axial();
                 app.update_coordinate_labels();
            end
        end

        % Window key press function: UIFigure
        function UIFigureWindowKeyPress(app, event)
            key = event.Key;
            if(strcmp(key, 'return'))
                app.SelectButtonPushed();
            elseif(strcmpi(key, 'space'))
                %% make xhairs interactive if the window had lost focuse
                %% a bug with app designer and this is a workaround
                app.sagittal_xhairs.Selected = 1;
                app.coronal_xhairs.Selected = 1;
                app.axial_xhairs.Selected = 1;
            end
        end

        % Window scroll wheel function: UIFigure
        function UIFigureWindowScrollWheel(app, event)
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
        function UIFigureCloseRequest(app, event)
            delete(app);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1048 519];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);
            app.UIFigure.WindowScrollWheelFcn = createCallbackFcn(app, @UIFigureWindowScrollWheel, true);
            app.UIFigure.WindowKeyPressFcn = createCallbackFcn(app, @UIFigureWindowKeyPress, true);

            % Create DoneButton
            app.DoneButton = uibutton(app.UIFigure, 'push');
            app.DoneButton.ButtonPushedFcn = createCallbackFcn(app, @DoneButtonPushed, true);
            app.DoneButton.FontWeight = 'bold';
            app.DoneButton.Position = [814 18 100 30];
            app.DoneButton.Text = 'Done';

            % Create CancelButton
            app.CancelButton = uibutton(app.UIFigure, 'push');
            app.CancelButton.ButtonPushedFcn = createCallbackFcn(app, @CancelButtonPushed, true);
            app.CancelButton.FontWeight = 'bold';
            app.CancelButton.Position = [935 18 100 30];
            app.CancelButton.Text = 'Cancel';

            % Create VesselTable
            app.VesselTable = uitable(app.UIFigure);
            app.VesselTable.ColumnName = {'Vessel'; 'X'; 'Y'; 'Z'};
            app.VesselTable.RowName = {};
            app.VesselTable.CellSelectionCallback = createCallbackFcn(app, @VesselTableCellSelection, true);
            app.VesselTable.Position = [720 310 315 200];

            % Create SagittalAxes
            app.SagittalAxes = uiaxes(app.UIFigure);
            title(app.SagittalAxes, 'Sagittal')
            xlabel(app.SagittalAxes, '')
            ylabel(app.SagittalAxes, '')
            app.SagittalAxes.XTick = [];
            app.SagittalAxes.YTick = [];
            app.SagittalAxes.Color = [0.149 0.149 0.149];
            app.SagittalAxes.Tag = 'SagittalAxes';
            app.SagittalAxes.Position = [1 266 345 254];

            % Create CoronalAxes
            app.CoronalAxes = uiaxes(app.UIFigure);
            title(app.CoronalAxes, 'Coronal')
            xlabel(app.CoronalAxes, '')
            ylabel(app.CoronalAxes, '')
            app.CoronalAxes.XTick = [];
            app.CoronalAxes.YTick = [];
            app.CoronalAxes.Color = [0.149 0.149 0.149];
            app.CoronalAxes.Tag = 'CoronalAxes';
            app.CoronalAxes.Position = [345 266 345 254];

            % Create AxialAxes
            app.AxialAxes = uiaxes(app.UIFigure);
            title(app.AxialAxes, 'Axial')
            xlabel(app.AxialAxes, '')
            ylabel(app.AxialAxes, '')
            app.AxialAxes.XTick = [];
            app.AxialAxes.YTick = [];
            app.AxialAxes.Color = [0.149 0.149 0.149];
            app.AxialAxes.Tag = 'AxialAxes';
            app.AxialAxes.Position = [1 18 345 254];

            % Create SelectButton
            app.SelectButton = uibutton(app.UIFigure, 'push');
            app.SelectButton.ButtonPushedFcn = createCallbackFcn(app, @SelectButtonPushed, true);
            app.SelectButton.FontWeight = 'bold';
            app.SelectButton.Tooltip = {'Shortcut: press ''Enter'' to select vessel'};
            app.SelectButton.Position = [935 62 100 30];
            app.SelectButton.Text = 'Select';

            % Create ListBox
            app.ListBox = uilistbox(app.UIFigure);
            app.ListBox.Items = {};
            app.ListBox.Tooltip = {'Select vessel from list'};
            app.ListBox.Position = [720 102 315 200];
            app.ListBox.Value = {};

            % Create XLabel
            app.XLabel = uilabel(app.UIFigure);
            app.XLabel.Position = [380 227 46 22];
            app.XLabel.Text = 'X:';

            % Create YLabel
            app.YLabel = uilabel(app.UIFigure);
            app.YLabel.Position = [380 206 46 22];
            app.YLabel.Text = 'Y:';

            % Create ZLabel
            app.ZLabel = uilabel(app.UIFigure);
            app.ZLabel.Position = [380 185 46 22];
            app.ZLabel.Text = 'Z:';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = select_vessel_gui_(varargin)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end