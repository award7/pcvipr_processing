classdef parameter_plot_gui_ < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        parameter_plot_fig         matlab.ui.Figure
        areaAxes                   matlab.ui.control.UIAxes
        diameterAxes               matlab.ui.control.UIAxes
        meanVelAxes                matlab.ui.control.UIAxes
        maxVelAxes                 matlab.ui.control.UIAxes
        flowPerBeatAxes            matlab.ui.control.UIAxes
        wssAxes                    matlab.ui.control.UIAxes
        pulsatilityAxes            matlab.ui.control.UIAxes
        resolvedFlowAxes           matlab.ui.control.UIAxes
        RecommendedDonotusethesevoxelsLabel  matlab.ui.control.Label
        LegendSwitchLabel          matlab.ui.control.Label
        LegendSwitch               matlab.ui.control.Switch
        areaVarianceLabel          matlab.ui.control.Label
        diameterVarianceLabel      matlab.ui.control.Label
        meanVelVarianceLabel       matlab.ui.control.Label
        maxVelVarianceLabel        matlab.ui.control.Label
        flowPerBeatVarianceLabel   matlab.ui.control.Label
        wssVarianceLabel           matlab.ui.control.Label
        pulsatilityVarianceLabel   matlab.ui.control.Label
        resolvedFlowVarianceLabel  matlab.ui.control.Label
        SaveButton                 matlab.ui.control.Button
        WindowLabel                matlab.ui.control.Label
        WindowSpinner              matlab.ui.control.Spinner
        LowerVoxelLabel            matlab.ui.control.Label
        LowerVoxelSpinner          matlab.ui.control.Spinner
        SaveDataStartSpinnerLabel  matlab.ui.control.Label
        SaveDataStartSpinner       matlab.ui.control.Spinner
        SaveDataEndSpinnerLabel    matlab.ui.control.Label
        SaveDataEndSpinner         matlab.ui.control.Spinner
    end

    properties (Access = private)
        centerline_app;
        upper_bound;
        current_vessel;
        
        % shading patch properties
        patch1;
        patch2;
        patch3;
        patch4;
        patch5;
        patch6;
        patch7;
        
        % toolbar
        tb1;
        tb2;
        tb3;
        tb4;
        tb5;
        tb6;
        tb7;
        tb8;
        
        % legend
        lgd;
        
    end

    % initialization methods
    methods (Access = private)
        
        function init_axes(app)
            x_label = 'Centerline Point';
            all_axes = [app.areaAxes, ...
                        app.diameterAxes, ... 
                        app.meanVelAxes, ...
                        app.maxVelAxes, ...
                        app.flowPerBeatAxes, ...
                        app.wssAxes, ...
                        app.pulsatilityAxes];
            
            names = fieldnames(app.centerline_app.vipr_obj.vessel);
            parameters = fieldnames(app.centerline_app.vipr_obj.vessel.(names{1}));
            max_x = numel(app.centerline_app.vipr_obj.vessel.(names{1}).area);
            
            not_for_plots = {'branchNum', 'branchActual', 'timeMIPvessel', 'x', 'y', 'z'};
            for k = 1:numel(all_axes)
                if ~any(ismember(not_for_plots, parameters{k}))
                    all_axes(k).XLabel.String = x_label;
                    all_axes(k).XLim = [1 max_x];
                    
                    [min_y, max_y] = app.min_max_y(app.centerline_app.vipr_obj.vessel.(names{1}).(parameters{k}));
                    all_axes(k).YLim = [min_y max_y];
                end
            end
            
            time_res = app.centerline_app.vipr_obj.time_res;
            nframes = app.centerline_app.vipr_obj.nframes;
            x = time_res/1000 * linspace(1, nframes, nframes);
            app.resolvedFlowAxes.XTick = x;
            app.resolvedFlowAxes.XTickLabelRotation = 45;
        end

        function init_plot_labels(app)
            app.areaAxes.Title.String = 'Area';
            app.areaAxes.YLabel.String = 'cm^2';
            
            app.diameterAxes.Title.String = 'Diameter';
            app.diameterAxes.YLabel.String = 'cm';
            
            app.meanVelAxes.Title.String = 'Mean Velocity';
            app.meanVelAxes.YLabel.String = 'cm/s';
            
            app.maxVelAxes.Title.String = 'Max Velocity';
            app.maxVelAxes.YLabel.String = 'cm/s';
            
            app.flowPerBeatAxes.Title.String = 'Flow per Beat';
            app.flowPerBeatAxes.YLabel.String = 'mL';
            
            app.wssAxes.Title.String = 'Wall Shear Strss';
            app.wssAxes.YLabel.String = 'Pa';
            
            app.pulsatilityAxes.Title.String = 'Pulsatility Index';
            app.pulsatilityAxes.YLabel.String = 'a.u.';

            app.resolvedFlowAxes.Title.String = 'Pulsatile Flow';
            app.resolvedFlowAxes.XLabel.String = 'Cardiac Time (s)';
            app.resolvedFlowAxes.YLabel.String = 'mL/beat';
            
        end

        function init_window_spinner(app)
            app.WindowSpinner.Value = app.WindowSpinner.Value;
            app.WindowSpinner.Limits = [1 app.upper_bound];
        end
        
        function init_lower_voxel_spinner(app)
            app.LowerVoxelSpinner.Value = app.LowerVoxelSpinner.Value;
            app.LowerVoxelSpinner.Limits = [1 app.upper_bound];
        end
        
        function init_save_data_spinner(app)
            app.SaveDataEndSpinner.Value = app.upper_bound;
            app.SaveDataEndSpinner.Limits = [1 app.upper_bound];
        end
       
        %{
        function init_plot_x_limits(app, axis_handle, vessel_obj)
            % voxel count for upper x limit
            max_x_value = numel(vessel_obj);
            

%             app.areaAxes.XLim = [1 max_x_value];
%             y_data = app.handles.values.area; %%%%
%             [min_y_value, max_y_value] = min_max_y(y_data);
%             app.areaAxes.YLim = [min_y_value max_y_value];
%             
%             app.diameterAxes.XLim = [1 max_x_value];
%             y_data = foo;
%             [min_y_value, max_y_value] = min_max_y(y_data);
%             app.diameterAxes.YLim = [min_y_value max_y_value];
%             
%             app.meanVelAxes.XLim = [1 max_x_value];
%             y_data = foo;
%             [min_y_value, max_y_value] = min_max_y(y_data);
%             app.meanVelAxes.YLim = [min_y_value max_y_value];
%             
%             app.maxVelAxes.XLim = [1 max_x_value];
%             y_data = foo;
%             [min_y_value, max_y_value] = min_max_y(y_data);
%             app.maxVelAxes.YLim = [min_y_value max_y_value];
%             
%             app.flowPerBeatAxes.XLim = [1 max_x_value];
%             y_data = foo;
%             [min_y_value, max_y_value] = min_max_y(y_data);
%             app.flowPerBeatAxes.YLim = [min_y_value max_y_value];
%             
%             app.wssAxes.XLim = [1 max_x_value];
%             y_data = foo;
%             [min_y_value, max_y_value] = min_max_y(y_data);
%             app.wssAxes.YLim = [min_y_value max_y_value];
%             
%             app.pulsatilityAxes.XLim = [1 max_x_value];
%             y_data = foo;
%             [min_y_value, max_y_value] = min_max_y(y_data);
%             app.pulsatilityAxes.YLim = [min_y_value max_y_value];
%             
        end

        function init_plot_y_limits(app, axis_handle, vessel_obj)
            app.(axis_handle).YLim = [min_y_value max_y_value];
        end
        %}
         
        %{
        function init_toolbar_icons(app)
            app.tb1 = axtoolbar(app.areaAxes, {'rotate', 'pan', 'zoomin', 'zoomout', 'export'});
            app.tb2 = axtoolbar(app.diameterAxes, {'rotate', 'pan', 'zoomin', 'zoomout', 'export'});
            app.tb3 = axtoolbar(app.meanVelAxes, {'rotate', 'pan', 'zoomin', 'zoomout', 'export'});
            app.tb4 = axtoolbar(app.maxVelAxes, {'rotate', 'pan', 'zoomin', 'zoomout', 'export'});
            app.tb5 = axtoolbar(app.flowPerBeatAxes, {'rotate', 'pan', 'zoomin', 'zoomout', 'export'});
            app.tb6 = axtoolbar(app.wssAxes, {'rotate', 'pan', 'zoomin', 'zoomout', 'export'});
            app.tb7 = axtoolbar(app.pulsatilityAxes, {'rotate', 'pan', 'zoomin', 'zoomout', 'export'});
            app.tb8 = axtoolbar(app.resolvedFlowAxes, {'rotate', 'pan', 'zoomin', 'zoomout', 'export'});
            
            app.tb1.Visible = 'On';
            app.tb2.Visible = 'On';
            app.tb3.Visible = 'On';
            app.tb4.Visible = 'On';
            app.tb5.Visible = 'On';
            app.tb6.Visible = 'On';
            app.tb7.Visible = 'On';
            app.tb8.Visible = 'On';
        end
        %}

    end
    
    % plotting
    methods (Access = private)
        
        % time average plots
        function time_avg_plotter(app)
            % get same vessel from vessel3D GUI
            x = linspace(1, length(app.current_vessel.area), length(app.current_vessel.area));
            
            % area plot
            y_data = app.current_vessel.area;
            plot(x, y_data, 'Parent', app.areaAxes);

            % diameter plot
            y_data = app.current_vessel.diam;
            plot(x, y_data, 'Parent', app.diameterAxes);
            
            % mean velocity plot
            y_data = app.current_vessel.meanVel;
            plot(x, y_data, 'Parent', app.meanVelAxes);

            % max velocity plot
            y_data = app.current_vessel.maxVel;
            plot(x, y_data, 'Parent', app.maxVelAxes);

            % flow per heartbeat plot
            y_data = app.current_vessel.flowPerHeartCycle;
            plot(x, y_data, 'Parent', app.flowPerBeatAxes);

            % wss plot
            y_data = app.current_vessel.wss_simple_avg;
            plot(x, y_data, 'Parent', app.wssAxes);

            % PI plot
            y_data = app.current_vessel.PI;
            plot(x, y_data, 'Parent', app.pulsatilityAxes);
        end

        % pulsatile flow (i.e. time resolved) plot
        function time_resolved_plotter(app) 
            cla(app.resolvedFlowAxes);
            
            lower_bound = app.LowerVoxelSpinner.Value;
            window = app.WindowSpinner.Value;
            time_res = app.centerline_app.vipr_obj.time_res;
            nframes = app.centerline_app.vipr_obj.nframes;
            
            x = time_res/1000*linspace(1, nframes, nframes);
            y_data = app.current_vessel.flow_pulsatile(lower_bound:lower_bound + window - 1, :);
            plot(x, smoothdata(y_data), 'Parent', app.resolvedFlowAxes);
            
            app.update_legend();
        end
        
    end
    
    % window updating
    methods (Access = private)
        
        % add window shading
        function shading(app)
            lower_bound = app.LowerVoxelSpinner.Value;
            window = app.WindowSpinner.Value;
            
            if window == app.upper_bound
                return;
            end
            
            x_data = [lower_bound lower_bound+window lower_bound+window lower_bound];
            
            color = [0.3010 0.7450 0.9330]; % light blue
            alpha = 0.2;
            edge_color = 'None';

            % area plot
            app.patch1 = patch(app.areaAxes);
            app.patch1.XData = x_data;
            y_limit = max(app.areaAxes.YLim);
            app.patch1.YData = get_y_data(y_limit);
            app.patch1.FaceColor = color;
            app.patch1.FaceAlpha = alpha;
            app.patch1.EdgeColor = edge_color;
            
            % diameter plot
            app.patch2 = patch(app.diameterAxes);
            app.patch2.XData = x_data;
            y_limit = max(app.diameterAxes.YLim);
            app.patch2.YData = get_y_data(y_limit);
            app.patch2.FaceColor = color;
            app.patch2.FaceAlpha = alpha;
            app.patch2.EdgeColor = edge_color;
            
            % mean velocity
            app.patch3 = patch(app.meanVelAxes);
            app.patch3.XData = x_data;
            y_limit = max(app.meanVelAxes.YLim);
            app.patch3.YData = get_y_data(y_limit);
            app.patch3.FaceColor = color;
            app.patch3.FaceAlpha = alpha;
            app.patch3.EdgeColor = edge_color;
            
            % max velocity
            app.patch4 = patch(app.maxVelAxes);
            app.patch4.XData = x_data;
            y_limit = max(app.maxVelAxes.YLim);
            app.patch4.YData = get_y_data(y_limit);
            app.patch4.FaceColor = color;
            app.patch4.FaceAlpha = alpha;
            app.patch4.EdgeColor = edge_color;
            
            % flow/beat
            app.patch5 = patch(app.flowPerBeatAxes);
            app.patch5.XData = x_data;
            y_limit = max(app.flowPerBeatAxes.YLim);
            app.patch5.YData = get_y_data(y_limit);
            app.patch5.FaceColor = color;
            app.patch5.FaceAlpha = alpha;
            app.patch5.EdgeColor = edge_color;
            
            % wss
            app.patch6 = patch(app.wssAxes);
            app.patch6.XData = x_data;
            y_limit = max(app.wssAxes.YLim);
            app.patch6.YData = get_y_data(y_limit);
            app.patch6.FaceColor = color;
            app.patch6.FaceAlpha = alpha;
            app.patch6.EdgeColor = edge_color;
            
            % PI
            app.patch7 = patch(app.pulsatilityAxes);
            app.patch7.XData = x_data;
            y_limit = max(app.pulsatilityAxes.YLim);
            app.patch7.YData = get_y_data(y_limit);
            app.patch7.FaceColor = color;
            app.patch7.FaceAlpha = alpha;
            app.patch7.EdgeColor = edge_color;
            
            function y_data = get_y_data(y_limit)
                y_data = [0 0 y_limit y_limit];
            end
            
        end
        
        % delete shading
        function delete_shading(app)
            try
                delete(app.patch1);
                delete(app.patch2);
                delete(app.patch3);
                delete(app.patch4);
                delete(app.patch5);
                delete(app.patch6);
                delete(app.patch7);
            catch
            end
        end
        
    end
    
    % update misc
    methods (Access = private)
        
        function update_legend(app)
            if app.WindowSpinner.Value <= 5 && strcmp(app.LegendSwitch.Value, 'On')
                lower_bound = app.LowerVoxelSpinner.Value;
                window = app.WindowSpinner.Value;
                voxel_numbers = [lower_bound:lower_bound + window - 1];
                app.lgd = legend(app.resolvedFlowAxes);
                app.lgd.String = append('Voxel ', string(voxel_numbers));
                app.lgd.Units = 'Normalized';
                app.lgd.Position = [0.875 0.4 0.1 0.2];
            else
                delete(app.lgd);
            end
        end
        
        function update_variance(app)           
            % area plot
            y_data = app.current_vessel.area';
            window_variance = voxel_window_variance(app, y_data);
            app.areaVarianceLabel.Text = ['Variance: ', num2str(window_variance)];
            
            % diameter plot
            y_data = app.current_vessel.diam';
            window_variance = voxel_window_variance(app, y_data);
            app.diameterVarianceLabel.Text = ['Variance: ', num2str(window_variance)];
            
            % mean velocity plot
            y_data = app.current_vessel.meanVel';
            window_variance = voxel_window_variance(app, y_data);
            app.meanVelVarianceLabel.Text = ['Variance: ', num2str(window_variance)];
            
            % max velocity plot
            y_data = app.current_vessel.maxVel';
            window_variance = voxel_window_variance(app, y_data);
            app.maxVelVarianceLabel.Text = ['Variance: ', num2str(window_variance)];
            
            % flow/beat plot
            y_data = app.current_vessel.flowPerHeartCycle';
            window_variance = voxel_window_variance(app, y_data);
            app.flowPerBeatVarianceLabel.Text = ['Variance: ', num2str(window_variance)];
            
            % wss plot
            y_data = app.current_vessel.wss_simple_avg';
            window_variance = voxel_window_variance(app, y_data);
            app.wssVarianceLabel.Text = ['Variance: ', num2str(window_variance)];
            
            % PI plot
            y_data = app.current_vessel.PI';
            window_variance = voxel_window_variance(app, y_data);
            app.pulsatilityVarianceLabel.Text = ['Variance: ', num2str(window_variance)];
            
            % pulsatile flow plot
            y_data = app.current_vessel.flow_pulsatile;
            window_variance = voxel_window_variance(app, y_data);
            app.resolvedFlowVarianceLabel.Text = ['Variance: ', num2str(window_variance)];

            % mean variance calculation
            function window_variance = voxel_window_variance(app, y_data)
                lower_bound = app.LowerVoxelSpinner.Value;
                window = app.WindowSpinner.Value;
                window_segment = y_data(lower_bound:lower_bound + window - 1,:);
                window_variance = var(window_segment, 0, 1);
                sum_of_variance = sum(window_variance);
                window_variance = mean(sum_of_variance);
            end 
        end
    
    end
    
    % update spinners
    methods (Access = public)
        
        function update_spinner_value(app)
            lower_bound = app.LowerVoxelSpinner.Value;
            window = app.WindowSpinner.Value;
            
            upper_limit = app.upper_bound - window;
            app.LowerVoxelSpinner.Limits = [1 upper_limit];
            
            if lower_bound + window > app.upper_bound
                lower_bound = app.upper_bound - window;
            end
            
            app.delete_shading();
            if lower_bound + window <= app.upper_bound
                app.shading();
            end

            app.time_resolved_plotter();
            app.update_variance();
        end
        
        function update_spinner_limits(app)
            app.upper_bound = length(app.current_vessel.branchActual);
            app.LowerVoxelSpinner.Limits = [1 app.upper_bound];
            app.WindowSpinner.Limits = [1 app.upper_bound]; 
        end
        
    end
    
    % misc
    methods(Static)
        % get min and max y-values for y-axis scaling
        function [min_y, max_y] = min_max_y(y_data)
            % y-limit 10% < min y-value
            min_y = min(y_data) * 0.90;
            
            % y-limit 10% > max y-value
            max_y = max(y_data) * 1.10; 
        end
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function parameter_plot_gui__OpeningFcn(app, centerline_app)
            app.parameter_plot_fig.Name = "Parameter Plot";
            app.centerline_app = centerline_app;
            
            % set initial values
            names = fieldnames(app.centerline_app.vipr_obj.vessel);
            app.current_vessel = app.centerline_app.vipr_obj.vessel.(names{1});
            app.upper_bound = length(app.current_vessel.area);
            app.init_window_spinner();
            app.init_lower_voxel_spinner();
            app.init_save_data_spinner();

            % plot
            app.init_axes();
            app.time_avg_plotter();
            app.time_resolved_plotter();
            app.shading();
            app.init_plot_labels();
            app.update_variance();
            % toolbar_icons(app);
            
            % tidy up/misc
            app.SaveButton.Text = ['Save ' names{1}];
            % app.RecommendedDonotusethesevoxelsLabel.Text = ['(Recommended) Do not use these voxels: [', num2str(app.handles.values.removed_voxels), ']'];
            
        end

        % Value changed function: WindowSpinner
        function WindowSpinnerValueChanged(app, event)
            % make changes in parameter_plot
            value = app.WindowSpinner.Value;
            app.update_spinner_value();
            app.update_spinner_limits();
            
            % make changes in vessel_3d
            app.WindowSpinner.Value = value;
            app.centerline_app.vessel_3D_app.WindowSpinner.Value = value;
            app.centerline_app.vessel_3D_app.add_plane();
        end

        % Value changed function: LowerVoxelSpinner
        function LowerVoxelSpinnerValueChanged(app, event)
            % make changes in parameter_plot
            value = app.LowerVoxelSpinner.Value;
            app.update_spinner_value();
            app.update_spinner_limits();
            
            % make changes in vessel_3d
            app.centerline_app.vessel_3D_app.LowerVoxelSpinner.Value = value;
            app.centerline_app.vessel_3D_app.add_plane();
        end

        % Button pushed function: SaveButton
        function SaveButtonPushed(app, event)
            app.save_data();
            app.save_plots();
            app.save_vessel();
        end

        % Value changed function: LegendSwitch
        function LegendSwitchValueChanged(app, event)
            value = app.LegendSwitch.Value;
            switch value
                case 'Off'
                    % delete legend if it exists
                    try
                        delete(app.lgd);
                    catch
                    end
                otherwise
                    % add legend if window is small
                    % a large legend increases rendering time & decreases
                    % performance
                    update_legend(app);
            end
        end

        % Close request function: parameter_plot_fig
        function parameter_plot_figCloseRequest(app, event)
            delete(app.centerline_app.vessel_3D_app);
            delete(app);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create parameter_plot_fig and hide until all components are created
            app.parameter_plot_fig = uifigure('Visible', 'off');
            app.parameter_plot_fig.Position = [9 9 1098 858];
            app.parameter_plot_fig.Name = 'parameter_plot_gui_';
            app.parameter_plot_fig.CloseRequestFcn = createCallbackFcn(app, @parameter_plot_figCloseRequest, true);

            % Create areaAxes
            app.areaAxes = uiaxes(app.parameter_plot_fig);
            title(app.areaAxes, 'Area')
            xlabel(app.areaAxes, 'Centerline Point')
            ylabel(app.areaAxes, 'cm^2')
            app.areaAxes.PlotBoxAspectRatio = [5.15068493150685 1 1];
            app.areaAxes.FontSize = 11;
            app.areaAxes.XTick = [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1];
            app.areaAxes.NextPlot = 'replace';
            app.areaAxes.Position = [15 611 400 200];

            % Create diameterAxes
            app.diameterAxes = uiaxes(app.parameter_plot_fig);
            title(app.diameterAxes, 'Diameter')
            xlabel(app.diameterAxes, 'Centerline Point')
            ylabel(app.diameterAxes, 'cm')
            app.diameterAxes.PlotBoxAspectRatio = [5.17123287671233 1 1];
            app.diameterAxes.FontSize = 11;
            app.diameterAxes.XTick = [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1];
            app.diameterAxes.NextPlot = 'replace';
            app.diameterAxes.Position = [15 411 400 200];

            % Create meanVelAxes
            app.meanVelAxes = uiaxes(app.parameter_plot_fig);
            title(app.meanVelAxes, 'Mean Velocity')
            xlabel(app.meanVelAxes, 'Centerline Point')
            ylabel(app.meanVelAxes, 'cm/s')
            app.meanVelAxes.PlotBoxAspectRatio = [5.08053691275168 1 1];
            app.meanVelAxes.FontSize = 11;
            app.meanVelAxes.XTick = [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1];
            app.meanVelAxes.NextPlot = 'replace';
            app.meanVelAxes.Position = [15 211 400 200];

            % Create maxVelAxes
            app.maxVelAxes = uiaxes(app.parameter_plot_fig);
            title(app.maxVelAxes, 'Max Velocity')
            xlabel(app.maxVelAxes, 'Centerline Point')
            ylabel(app.maxVelAxes, 'cm/s')
            app.maxVelAxes.PlotBoxAspectRatio = [5.08053691275168 1 1];
            app.maxVelAxes.FontSize = 11;
            app.maxVelAxes.XTick = [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1];
            app.maxVelAxes.NextPlot = 'replace';
            app.maxVelAxes.Position = [15 11 400 200];

            % Create flowPerBeatAxes
            app.flowPerBeatAxes = uiaxes(app.parameter_plot_fig);
            title(app.flowPerBeatAxes, 'Flow per Beat')
            xlabel(app.flowPerBeatAxes, 'Centerline Point')
            ylabel(app.flowPerBeatAxes, 'mL')
            app.flowPerBeatAxes.PlotBoxAspectRatio = [5.08053691275168 1 1];
            app.flowPerBeatAxes.FontSize = 11;
            app.flowPerBeatAxes.XTick = [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1];
            app.flowPerBeatAxes.NextPlot = 'replace';
            app.flowPerBeatAxes.Position = [450 611 400 200];

            % Create wssAxes
            app.wssAxes = uiaxes(app.parameter_plot_fig);
            title(app.wssAxes, 'Wall Shear Stress')
            xlabel(app.wssAxes, 'Centerline Point')
            ylabel(app.wssAxes, 'Pa')
            app.wssAxes.PlotBoxAspectRatio = [5.08053691275168 1 1];
            app.wssAxes.FontSize = 11;
            app.wssAxes.XTick = [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1];
            app.wssAxes.NextPlot = 'replace';
            app.wssAxes.Position = [450 411 400 200];

            % Create pulsatilityAxes
            app.pulsatilityAxes = uiaxes(app.parameter_plot_fig);
            title(app.pulsatilityAxes, 'Pulsatility Index')
            xlabel(app.pulsatilityAxes, 'Centerline Point')
            ylabel(app.pulsatilityAxes, 'a.u.')
            app.pulsatilityAxes.PlotBoxAspectRatio = [5.08053691275168 1 1];
            app.pulsatilityAxes.FontSize = 11;
            app.pulsatilityAxes.XTick = [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1];
            app.pulsatilityAxes.NextPlot = 'replace';
            app.pulsatilityAxes.Position = [450 211 400 200];

            % Create resolvedFlowAxes
            app.resolvedFlowAxes = uiaxes(app.parameter_plot_fig);
            title(app.resolvedFlowAxes, 'Pulsatile Flow')
            xlabel(app.resolvedFlowAxes, 'Frame of Cardiac Cycle')
            ylabel(app.resolvedFlowAxes, 'mL/s')
            app.resolvedFlowAxes.PlotBoxAspectRatio = [5.08053691275168 1 1];
            app.resolvedFlowAxes.FontSize = 11;
            app.resolvedFlowAxes.XTick = [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1];
            app.resolvedFlowAxes.NextPlot = 'replace';
            app.resolvedFlowAxes.Position = [450 11 400 200];

            % Create RecommendedDonotusethesevoxelsLabel
            app.RecommendedDonotusethesevoxelsLabel = uilabel(app.parameter_plot_fig);
            app.RecommendedDonotusethesevoxelsLabel.Position = [52 827 755 22];
            app.RecommendedDonotusethesevoxelsLabel.Text = '(Recommended) Do not use these voxels: [ ]';

            % Create LegendSwitchLabel
            app.LegendSwitchLabel = uilabel(app.parameter_plot_fig);
            app.LegendSwitchLabel.HorizontalAlignment = 'center';
            app.LegendSwitchLabel.Position = [722 151 46 22];
            app.LegendSwitchLabel.Text = 'Legend';

            % Create LegendSwitch
            app.LegendSwitch = uiswitch(app.parameter_plot_fig, 'slider');
            app.LegendSwitch.ValueChangedFcn = createCallbackFcn(app, @LegendSwitchValueChanged, true);
            app.LegendSwitch.Position = [796 157 22 10];
            app.LegendSwitch.Value = 'On';

            % Create areaVarianceLabel
            app.areaVarianceLabel = uilabel(app.parameter_plot_fig);
            app.areaVarianceLabel.Position = [50 751 141 22];
            app.areaVarianceLabel.Text = 'Variance: ';

            % Create diameterVarianceLabel
            app.diameterVarianceLabel = uilabel(app.parameter_plot_fig);
            app.diameterVarianceLabel.Position = [50 551 141 22];
            app.diameterVarianceLabel.Text = 'Variance: ';

            % Create meanVelVarianceLabel
            app.meanVelVarianceLabel = uilabel(app.parameter_plot_fig);
            app.meanVelVarianceLabel.Position = [50 351 141 22];
            app.meanVelVarianceLabel.Text = 'Variance: ';

            % Create maxVelVarianceLabel
            app.maxVelVarianceLabel = uilabel(app.parameter_plot_fig);
            app.maxVelVarianceLabel.Position = [50 151 141 22];
            app.maxVelVarianceLabel.Text = 'Variance: ';

            % Create flowPerBeatVarianceLabel
            app.flowPerBeatVarianceLabel = uilabel(app.parameter_plot_fig);
            app.flowPerBeatVarianceLabel.Position = [485 751 141 22];
            app.flowPerBeatVarianceLabel.Text = 'Variance: ';

            % Create wssVarianceLabel
            app.wssVarianceLabel = uilabel(app.parameter_plot_fig);
            app.wssVarianceLabel.Position = [485 551 141 22];
            app.wssVarianceLabel.Text = 'Variance: ';

            % Create pulsatilityVarianceLabel
            app.pulsatilityVarianceLabel = uilabel(app.parameter_plot_fig);
            app.pulsatilityVarianceLabel.Position = [485 351 141 22];
            app.pulsatilityVarianceLabel.Text = 'Variance: ';

            % Create resolvedFlowVarianceLabel
            app.resolvedFlowVarianceLabel = uilabel(app.parameter_plot_fig);
            app.resolvedFlowVarianceLabel.Position = [485 151 141 22];
            app.resolvedFlowVarianceLabel.Text = 'Variance: ';

            % Create SaveButton
            app.SaveButton = uibutton(app.parameter_plot_fig, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @SaveButtonPushed, true);
            app.SaveButton.FontSize = 14;
            app.SaveButton.FontWeight = 'bold';
            app.SaveButton.Position = [884 160 200 30];
            app.SaveButton.Text = 'Save';

            % Create WindowLabel
            app.WindowLabel = uilabel(app.parameter_plot_fig);
            app.WindowLabel.FontWeight = 'bold';
            app.WindowLabel.Position = [893 714 60 30];
            app.WindowLabel.Text = 'Window';

            % Create WindowSpinner
            app.WindowSpinner = uispinner(app.parameter_plot_fig);
            app.WindowSpinner.Limits = [1 Inf];
            app.WindowSpinner.ValueChangedFcn = createCallbackFcn(app, @WindowSpinnerValueChanged, true);
            app.WindowSpinner.FontWeight = 'bold';
            app.WindowSpinner.Position = [972 714 102 30];
            app.WindowSpinner.Value = 5;

            % Create LowerVoxelLabel
            app.LowerVoxelLabel = uilabel(app.parameter_plot_fig);
            app.LowerVoxelLabel.FontWeight = 'bold';
            app.LowerVoxelLabel.Position = [893 652 80 30];
            app.LowerVoxelLabel.Text = 'Lower Voxel';

            % Create LowerVoxelSpinner
            app.LowerVoxelSpinner = uispinner(app.parameter_plot_fig);
            app.LowerVoxelSpinner.Limits = [1 Inf];
            app.LowerVoxelSpinner.ValueChangedFcn = createCallbackFcn(app, @LowerVoxelSpinnerValueChanged, true);
            app.LowerVoxelSpinner.FontWeight = 'bold';
            app.LowerVoxelSpinner.Position = [974 652 100 30];
            app.LowerVoxelSpinner.Value = 1;

            % Create SaveDataStartSpinnerLabel
            app.SaveDataStartSpinnerLabel = uilabel(app.parameter_plot_fig);
            app.SaveDataStartSpinnerLabel.FontWeight = 'bold';
            app.SaveDataStartSpinnerLabel.Position = [893 581 100 30];
            app.SaveDataStartSpinnerLabel.Text = 'Save Data: Start';

            % Create SaveDataStartSpinner
            app.SaveDataStartSpinner = uispinner(app.parameter_plot_fig);
            app.SaveDataStartSpinner.Limits = [1 Inf];
            app.SaveDataStartSpinner.FontWeight = 'bold';
            app.SaveDataStartSpinner.Position = [992 581 100 30];
            app.SaveDataStartSpinner.Value = 1;

            % Create SaveDataEndSpinnerLabel
            app.SaveDataEndSpinnerLabel = uilabel(app.parameter_plot_fig);
            app.SaveDataEndSpinnerLabel.FontWeight = 'bold';
            app.SaveDataEndSpinnerLabel.Position = [893 522 100 30];
            app.SaveDataEndSpinnerLabel.Text = 'Save Data: End ';

            % Create SaveDataEndSpinner
            app.SaveDataEndSpinner = uispinner(app.parameter_plot_fig);
            app.SaveDataEndSpinner.Limits = [1 Inf];
            app.SaveDataEndSpinner.FontWeight = 'bold';
            app.SaveDataEndSpinner.Position = [992 522 100 30];
            app.SaveDataEndSpinner.Value = 1;

            % Show the figure after all components are created
            app.parameter_plot_fig.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = parameter_plot_gui_(varargin)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.parameter_plot_fig)

            % Execute the startup function
            runStartupFcn(app, @(app)parameter_plot_gui__OpeningFcn(app, varargin{:}))

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.parameter_plot_fig)
        end
    end
end