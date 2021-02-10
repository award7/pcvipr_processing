classdef Vessel3D_gui_ < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        vessel3D                    matlab.ui.Figure
        VesselSegAxes               matlab.ui.control.UIAxes
        LowerVoxelSpinnerLabel      matlab.ui.control.Label
        LowerVoxelSpinner           matlab.ui.control.Spinner
        WindowSpinnerLabel          matlab.ui.control.Label
        WindowSpinner               matlab.ui.control.Spinner
        IsolateVesselSegmentSwitchLabel  matlab.ui.control.Label
        IsolateVesselSegmentSwitch  matlab.ui.control.Switch
        ReorientButton              matlab.ui.control.Button
        VesselDropDownLabel         matlab.ui.control.Label
        VesselDropDown              matlab.ui.control.DropDown
    end

    properties (Access = public)
        centerline_app;
        current_vessel;
    end
    
    properties (Access = private)
        % parameter_plot_app;
        full_vasculature_patch;
        vessel_patch;
        ITPlane;
        plane;
        tb;
    end
    
    methods(Access = public)
    
        function add_plane(app)
            % delete old planes
            delete(findobj(app.VesselSegAxes, 'Type', 'Patch', '-regexp', 'Tag', 'plane.*?'));
            
            window = app.WindowSpinner.Value;
            voxel_number = app.LowerVoxelSpinner.Value;
            
            % need to offset this; don't know why but was in older code
            offset = 2;
            for window_slice = 1:window
                pos = app.current_vessel.branchActual(voxel_number + offset + window_slice - 1, :);
                pos = floor(pos);
                x = pos(1);
                y = pos(2); 
                z = pos(3);
                
                branchList = app.centerline_app.vipr_obj.branchList;
                find_x = find(branchList(:, 1) == x);
                find_y = find(branchList(find_x, 2) == y);
                find_z = find(branchList(find_x(find_y), 3) == z);
                idx = find_x(find_y(find_z));
                
                hold(app.VesselSegAxes, 'on');
                % x & y are switched for some reason
                app.plane = fill3(app.VesselSegAxes, ...
                                    app.ITPlane.plane_y(idx, :)', ...
                                    app.ITPlane.plane_x(idx, :)', ...
                                    app.ITPlane.plane_z(idx, :)', ...
                                    [0 0 0]);
                app.plane.EdgeColor = [0 0 0];
                app.plane.FaceAlpha = 0.3;
                app.plane.PickableParts = 'none';
                plane_num = ['plane' num2str(window_slice)];
                app.plane.Tag = plane_num;
                hold(app.VesselSegAxes, 'off'); 
            end
        end
        
        function update_spinner_limits(app)
            upper_bound = length(app.current_vessel.branchActual);
            app.LowerVoxelSpinner.Limits = [1 upper_bound];
            app.WindowSpinner.Limits = [1 upper_bound];
        end
        
    end
    
    methods (Access = private)    
        
        function init_axes(app)
            m_xstart = 1;
            m_xstop = app.centerline_app.vipr_obj.res;
            m_ystart = 1;
            m_ystop = app.centerline_app.vipr_obj.res;
            m_zstart = 1;
            m_zstop = app.centerline_app.vipr_obj.res;
            
            app.VesselSegAxes.XLim = [m_ystart m_ystop]; % switched
            app.VesselSegAxes.YLim = [m_xstart m_xstop];
            app.VesselSegAxes.ZLim = [m_zstart m_zstop];
            app.VesselSegAxes.ZDir = 'Reverse';
            axis(app.VesselSegAxes, 'vis3d');
            app.VesselSegAxes.Visible = 'Off';
            view(app.VesselSegAxes, [-1 0 0]);
            app.VesselSegAxes.DataAspectRatio = [1 1 1];
            
            % toolbar
            app.tb = axtoolbar(app.VesselSegAxes, {'rotate', 'pan', 'zoomin', 'zoomout', 'export'});
            app.tb.Visible = 'On';
        end
            
        function plot_full_vasculature(app)
            app.full_vasculature_patch = patch(app.VesselSegAxes, isosurface(app.centerline_app.vipr_obj.segment, 0.5));
            app.full_vasculature_patch.FaceColor = 'k';
            app.full_vasculature_patch.EdgeColor = 'none';
            app.full_vasculature_patch.FaceAlpha = 0.1;
        end
            
        function plot_vessel(app)
            disp('Visualizing segmented vessel in 3D...');
            delete(findobj(app.VesselSegAxes, 'Type', 'Patch', '-regexp', 'Tag', 'vessel'));
            delete(findobj(app.VesselSegAxes, 'Type', 'Text'));
            app.ReorientButtonPushed();

            app.vessel_patch = patch(app.VesselSegAxes, isosurface(app.current_vessel.timeMIPvessel, 0.25));
            app.vessel_patch.FaceColor = 'r';
            app.vessel_patch.EdgeColor = 'none';
            app.vessel_patch.FaceAlpha = 0.4;
            app.vessel_patch.Tag = 'vessel';
        end
        
        function add_voxel_labels(app)
            num = 0;
            hold(app.VesselSegAxes, 'On');
            % add voxel labels
            for i = 1:numel(app.current_vessel.branchActual(:,1))
                num = num + 1;
                if mod(num-2, 5) == 0
                    stringval = {num2str(num-2)};
                    x = app.current_vessel.branchActual(i,2);
                    y = app.current_vessel.branchActual(i,1);
                    z = app.current_vessel.branchActual(i,3);
                    t = text(app.VesselSegAxes, x, y, z, stringval);
                    t.Color = 'b';
                end
            end
            hold(app.VesselSegAxes, 'Off');
        end
    
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, centerline_app)
            app.vessel3D.Name = 'Vessel 3D';
            app.centerline_app = centerline_app;
            
            % center the window
            % TODO: Move to one side of screen?
            pixels = get(0, 'ScreenSize');
            x = pixels(3);
            y = pixels(4);
            dimensions = app.vessel3D.Position;
            width = dimensions(3);
            height = dimensions(4);
            app.vessel3D.Position = [((x-width)/2) ((y-height)/2) width height];
            
            names = fieldnames(app.centerline_app.vipr_obj.vessel);
            app.VesselDropDown.Items = names;
            app.VesselDropDown.Value = names(1);
            
            app.init_axes();
            app.plot_full_vasculature();
            app.VesselDropDownValueChanged();
        end

        % Value changed function: WindowSpinner
        function WindowSpinnerValueChanged(app, event)
            % make changes in vessel_3d
            value = app.WindowSpinner.Value;
            app.add_plane();

            % make changes in parameter_plot
            app.centerline_app.parameter_plot_app.WindowSpinner.Value = value;
            app.centerline_app.parameter_plot_app.update_spinner_value();
        end

        % Value changed function: LowerVoxelSpinner
        function LowerVoxelSpinnerValueChanged(app, event)
            % make changes in vessel_3d
            value = app.LowerVoxelSpinner.Value;
            app.add_plane();

            % make changes in parameter_plot
            app.centerline_app.parameter_plot_app.LowerVoxelSpinner.Value = value;
            app.centerline_app.parameter_plot_app.update_spinner_value();
        end

        % Value changed function: IsolateVesselSegmentSwitch
        function IsolateVesselSegmentSwitchValueChanged(app, event)
            value = app.IsolateVesselSegmentSwitch.Value;
            switch value
                case 'On'
                    app.full_vasculature_patch.Visible = 'Off';
                case 'Off'
                    app.full_vasculature_patch.Visible = 'On';
            end
        end

        % Button pushed function: ReorientButton
        function ReorientButtonPushed(app, event)
            view(app.VesselSegAxes, [-1 0 0]);
        end

        % Value changed function: VesselDropDown
        function VesselDropDownValueChanged(app, event)
            value = app.VesselDropDown.Value;
            app.current_vessel = app.centerline_app.vipr_obj.vessel.(value);
            app.plot_vessel();
            app.add_voxel_labels();
            app.ITPlane = makeITPlane(app.centerline_app.vipr_obj.branchList);
            app.add_plane();
            
            % change spinner limits
            app.update_spinner_limits();
            app.centerline_app.parameter_plot_app.update_spinner_limits();
        end

        % Close request function: vessel3D
        function vessel3DCloseRequest(app, event)
            delete(app.parameter_plot_app);
            delete(app);
        end
        
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create vessel3D and hide until all components are created
            app.vessel3D = uifigure('Visible', 'off');
            app.vessel3D.Position = [100 100 1100 800];
            app.vessel3D.Name = 'UI Figure';
            app.vessel3D.CloseRequestFcn = createCallbackFcn(app, @vessel3DCloseRequest, true);

            % Create VesselSegAxes
            app.VesselSegAxes = uiaxes(app.vessel3D);
            title(app.VesselSegAxes, '')
            xlabel(app.VesselSegAxes, '')
            ylabel(app.VesselSegAxes, '')
            app.VesselSegAxes.PlotBoxAspectRatio = [1.6027397260274 1 1];
            app.VesselSegAxes.XTick = [];
            app.VesselSegAxes.YTick = [];
            app.VesselSegAxes.Color = [0 0 0];
            app.VesselSegAxes.Position = [1 102 1100 668];

            % Create LowerVoxelSpinnerLabel
            app.LowerVoxelSpinnerLabel = uilabel(app.vessel3D);
            app.LowerVoxelSpinnerLabel.FontWeight = 'bold';
            app.LowerVoxelSpinnerLabel.Position = [882 38 100 30];
            app.LowerVoxelSpinnerLabel.Text = 'Lower Voxel';

            % Create LowerVoxelSpinner
            app.LowerVoxelSpinner = uispinner(app.vessel3D);
            app.LowerVoxelSpinner.Limits = [1 Inf];
            app.LowerVoxelSpinner.ValueChangedFcn = createCallbackFcn(app, @LowerVoxelSpinnerValueChanged, true);
            app.LowerVoxelSpinner.FontWeight = 'bold';
            app.LowerVoxelSpinner.Position = [968 38 100 30];
            app.LowerVoxelSpinner.Value = 1;

            % Create WindowSpinnerLabel
            app.WindowSpinnerLabel = uilabel(app.vessel3D);
            app.WindowSpinnerLabel.FontWeight = 'bold';
            app.WindowSpinnerLabel.Position = [708 38 51 30];
            app.WindowSpinnerLabel.Text = 'Window';

            % Create WindowSpinner
            app.WindowSpinner = uispinner(app.vessel3D);
            app.WindowSpinner.Limits = [1 Inf];
            app.WindowSpinner.ValueChangedFcn = createCallbackFcn(app, @WindowSpinnerValueChanged, true);
            app.WindowSpinner.FontWeight = 'bold';
            app.WindowSpinner.Position = [758 38 100 30];
            app.WindowSpinner.Value = 5;

            % Create IsolateVesselSegmentSwitchLabel
            app.IsolateVesselSegmentSwitchLabel = uilabel(app.vessel3D);
            app.IsolateVesselSegmentSwitchLabel.HorizontalAlignment = 'center';
            app.IsolateVesselSegmentSwitchLabel.FontWeight = 'bold';
            app.IsolateVesselSegmentSwitchLabel.Position = [42.5 59 138 22];
            app.IsolateVesselSegmentSwitchLabel.Text = 'Isolate Vessel Segment';

            % Create IsolateVesselSegmentSwitch
            app.IsolateVesselSegmentSwitch = uiswitch(app.vessel3D, 'slider');
            app.IsolateVesselSegmentSwitch.ValueChangedFcn = createCallbackFcn(app, @IsolateVesselSegmentSwitchValueChanged, true);
            app.IsolateVesselSegmentSwitch.FontWeight = 'bold';
            app.IsolateVesselSegmentSwitch.Position = [88 27 45 20];

            % Create ReorientButton
            app.ReorientButton = uibutton(app.vessel3D, 'push');
            app.ReorientButton.ButtonPushedFcn = createCallbackFcn(app, @ReorientButtonPushed, true);
            app.ReorientButton.Position = [1002 767 66 32];
            app.ReorientButton.Text = 'Reorient';

            % Create VesselDropDownLabel
            app.VesselDropDownLabel = uilabel(app.vessel3D);
            app.VesselDropDownLabel.HorizontalAlignment = 'right';
            app.VesselDropDownLabel.FontWeight = 'bold';
            app.VesselDropDownLabel.Position = [238 38 43 30];
            app.VesselDropDownLabel.Text = 'Vessel';

            % Create VesselDropDown
            app.VesselDropDown = uidropdown(app.vessel3D);
            app.VesselDropDown.ValueChangedFcn = createCallbackFcn(app, @VesselDropDownValueChanged, true);
            app.VesselDropDown.FontWeight = 'bold';
            app.VesselDropDown.Position = [296 38 218 30];

            % Show the figure after all components are created
            app.vessel3D.Visible = 'on';
        end
        
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Vessel3D_gui_(varargin)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.vessel3D)

            % Execute the startup function
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.vessel3D)
        end
    end
    
end