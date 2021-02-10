classdef ParameterPlotApp < matlab.apps.AppBase

    properties (Access = private)
        UIFigure                matlab.ui.Figure;
        ParentGridLayout        matlab.ui.container.GridLayout;
        ChildGridLayout1        matlab.ui.container.GridLayout;
        ChildGridLayout2        matlab.ui.container.GridLayout;
        ChildGridLayout3        matlab.ui.container.GridLayout;
        AreaAxes                matlab.ui.control.UIAxes;
        DiameterAxes            matlab.ui.control.UIAxes;
        MeanVelocityAxes        matlab.ui.control.UIAxes;
        MaxVelocityAxes         matlab.ui.control.UIAxes;
        FlowPerBeatAxes         matlab.ui.control.UIAxes;
        WallShearStressAxes     matlab.ui.control.UIAxes;
        PulsatilityIndexAxes    matlab.ui.control.UIAxes;
        TimeResolvedAxes        matlab.ui.control.UIAxes;
        DataTable               matlab.ui.control.Table;
        LowerVoxelLabel         matlab.ui.control.Label;
        WindowLabel             matlab.ui.control.Label;
        SaveDataStartLabel      matlab.ui.control.Label;
        SaveDataEndLabel        matlab.ui.control.Label;
        LowerVoxelSpinner       matlab.ui.control.Spinner;
        WindowSpinner           matlab.ui.control.Spinner;
        SaveDataStartSpinner    matlab.ui.control.Spinner;
        SaveDataEndSpinner      matlab.ui.control.Spinner;
        SaveButton              matlab.ui.control.Button;
        CancelButton            matlab.ui.control.Button;
        Legend;
        VIPR;
        Linker                  AppLinker;
    end
    
    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = ParameterPlotApp(varargin)

            % Create UIFigure and components
            app.createComponents()

            % Register the app with App Designer
            app.registerApp(app.UIFigure)
            
            app.Linker = varargin{1};
            
            % Execute the startup function
            % app.runStartupFcn(@(app)startupFcn(app, varargin{:}))
            
            if nargout == 0
                clear app
            end
        end
        
        function delete(app)
            delete(app.UIFigure);
        end
        
    end
    
    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)
            app.createFigure();
            app.createGridParent();
            app.createGridChild1();
            app.createGridChild2();
            app.createGridChild3();
            app.createAxesArea();
            app.createAxesDiameter();
            app.createAxesMeanVelocity();
            app.createAxesMaxVelocity();
            app.createAxesFlowPerBeat();
            app.createAxesPulsatilityIndex();
            app.createAxesWallShearStress();
            app.createAxesTimeResolved();
            app.createTableData();
            app.createLabelLowerVoxel();
            app.createLabelWindow();
            app.createLabelSaveDataStart();
            app.createLabelSaveDataEnd();
            app.createSpinnerLowerVoxel();
            app.createSpinnerWindow();
            app.createSpinnerSaveDataStart();
            app.createSpinnerSaveDataEnd();
            app.createButtonCancel();
            app.createButtonSave();

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
        
        function createFigure(app)
            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Name = 'Parameter Plots';
            app.UIFigure.WindowState = 'maximized';
        end

        function createGridParent(app)
            app.ParentGridLayout = uigridlayout(app.UIFigure);
            app.ParentGridLayout.ColumnWidth = {'1x'};
            app.ParentGridLayout.RowHeight = {'5x', '1x'};
        end
        
        function createGridChild1(app)
            app.ChildGridLayout1 = uigridlayout(app.ParentGridLayout);
            app.ChildGridLayout1.RowHeight = {'1x', '1x', '1x', '1x'};
            app.ChildGridLayout1.Layout.Row = 1;
            app.ChildGridLayout1.Layout.Column = 1;
        end
             
        function createGridChild2(app)
            app.ChildGridLayout2 = uigridlayout(app.ParentGridLayout);
            app.ChildGridLayout2.RowHeight = {'1x'};
            app.ChildGridLayout2.Layout.Row = 2;
            app.ChildGridLayout2.Layout.Column = 1;
        end
        
        function createGridChild3(app)
            app.ChildGridLayout3 = uigridlayout(app.ChildGridLayout2);
            app.ChildGridLayout3.ColumnWidth = {'1x', '1x', '1x', '1x'};
            app.ChildGridLayout3.RowHeight = {'1x', '1x', '1x'};
            app.ChildGridLayout3.Layout.Row = 1;
            app.ChildGridLayout3.Layout.Column = 2;
        end
        
        function createAxesArea(app)
            app.AreaAxes = uiaxes(app.ChildGridLayout1);
            title(app.AreaAxes, 'Area')
            xlabel(app.AreaAxes, 'Centerline Point')
            ylabel(app.AreaAxes, 'cm^2')
            app.AreaAxes.Layout.Row = 1;
            app.AreaAxes.Layout.Column = 1;
        end
        
        function createAxesDiameter(app)
            app.DiameterAxes = uiaxes(app.ChildGridLayout1);
            title(app.DiameterAxes, 'Diameter')
            xlabel(app.DiameterAxes, 'Centerline Point')
            ylabel(app.DiameterAxes, 'cm')
            app.DiameterAxes.Layout.Row = 2;
            app.DiameterAxes.Layout.Column = 1;
        end
        
        function createAxesMeanVelocity(app)
            app.MeanVelocityAxes = uiaxes(app.ChildGridLayout1);
            title(app.MeanVelocityAxes, 'Mean Velocity')
            xlabel(app.MeanVelocityAxes, 'Centerline Point')
            ylabel(app.MeanVelocityAxes, 'cm/s')
            app.MeanVelocityAxes.Layout.Row = 3;
            app.MeanVelocityAxes.Layout.Column = 1;
        end
        
        function createAxesMaxVelocity(app)
            app.MaxVelocityAxes = uiaxes(app.ChildGridLayout1);
            title(app.MaxVelocityAxes, 'Max Velocity')
            xlabel(app.MaxVelocityAxes, 'Centerline Point')
            ylabel(app.MaxVelocityAxes, 'cm/s')
            app.MaxVelocityAxes.Layout.Row = 4;
            app.MaxVelocityAxes.Layout.Column = 1;
        end
        
        function createAxesFlowPerBeat(app)
            app.FlowPerBeatAxes = uiaxes(app.ChildGridLayout1);
            title(app.FlowPerBeatAxes, 'Flow per Beat')
            xlabel(app.FlowPerBeatAxes, 'Centerline Point')
            ylabel(app.FlowPerBeatAxes, 'mL')
            app.FlowPerBeatAxes.Layout.Row = 1;
            app.FlowPerBeatAxes.Layout.Column = 2;
        end
        
        function createAxesPulsatilityIndex(app)
            app.PulsatilityIndexAxes = uiaxes(app.ChildGridLayout1);
            title(app.PulsatilityIndexAxes, 'Pulsatility Index')
            xlabel(app.PulsatilityIndexAxes, 'Centerline Point')
            ylabel(app.PulsatilityIndexAxes, 'a.u.')
            app.PulsatilityIndexAxes.Layout.Row = 2;
            app.PulsatilityIndexAxes.Layout.Column = 2;
        end
        
        function createAxesWallShearStress(app)
            app.WallShearStressAxes = uiaxes(app.ChildGridLayout1);
            title(app.WallShearStressAxes, 'Wall Shear Stress')
            xlabel(app.WallShearStressAxes, 'Centerline Point')
            ylabel(app.WallShearStressAxes, 'Y')
            app.WallShearStressAxes.Layout.Row = 3;
            app.WallShearStressAxes.Layout.Column = 2;
        end
        
        function createAxesTimeResolved(app)
            app.TimeResolvedAxes = uiaxes(app.ChildGridLayout1);
            title(app.TimeResolvedAxes, 'Time Resolved Flow')
            xlabel(app.TimeResolvedAxes, 'Centerline Point')
            ylabel(app.TimeResolvedAxes, 'Flow (mL/s)')
            app.TimeResolvedAxes.Layout.Row = 4;
            app.TimeResolvedAxes.Layout.Column = 2;    
        end
        
        function createTableData(app)
            app.DataTable = uitable(app.ChildGridLayout2);
            app.DataTable.ColumnName = {'Parameter'; 'Mean'; 'SD'};
            % TODO: change to rows instead of RowName if RowName does not
            % appear for visaulization
            app.DataTable.RowName = {'Area', 'Diameter', 'Mean Velocity', 'Max Velocity', ...
                                        'FlowPerBeat', 'P.I.', 'WSS', 'Flow'};
            app.DataTable.Layout.Row = 1;
            app.DataTable.Layout.Column = 1;
        end
        
        function createLabelLowerVoxel(app)
            app.LowerVoxelLabel = uilabel(app.ChildGridLayout3);
            app.LowerVoxelLabel.HorizontalAlignment = 'right';
            app.LowerVoxelLabel.Layout.Row = 1;
            app.LowerVoxelLabel.Layout.Column = 3;
            app.LowerVoxelLabel.Text = 'Lower Voxel';
        end
        
        function createLabelWindow(app)
            app.WindowLabel = uilabel(app.ChildGridLayout3);
            app.WindowLabel.HorizontalAlignment = 'right';
            app.WindowLabel.Layout.Row = 2;
            app.WindowLabel.Layout.Column = 3;
            app.WindowLabel.Text = 'Window';
        end
        
        function createLabelSaveDataStart(app)
            app.SaveDataStartLabel = uilabel(app.ChildGridLayout3);
            app.SaveDataStartLabel.HorizontalAlignment = 'right';
            app.SaveDataStartLabel.Layout.Row = 1;
            app.SaveDataStartLabel.Layout.Column = 1;
            app.SaveDataStartLabel.Text = 'Save Voxel: Start';
        end
        
        function createLabelSaveDataEnd(app)
            app.SaveDataEndLabel = uilabel(app.ChildGridLayout3);
            app.SaveDataEndLabel.HorizontalAlignment = 'right';
            app.SaveDataEndLabel.Layout.Row = 2;
            app.SaveDataEndLabel.Layout.Column = 1;
            app.SaveDataEndLabel.Text = 'Save Voxel: End';
        end
        
        function createSpinnerLowerVoxel(app)
            app.LowerVoxelSpinner = uispinner(app.ChildGridLayout3);
            app.LowerVoxelSpinner.Layout.Row = 1;
            app.LowerVoxelSpinner.Layout.Column = 4;
            app.LowerVoxelSpinner.Limits = [1 100];
            app.LowerVoxelSpinner.Step = 1;
            app.LowerVoxelSpinner.Value = 1;
            app.LowerVoxelSpinner.ValueChangedFcn = app.createCallbackFcn(@lowerVoxelSpinnerValueChanged, true);
        end
        
        function createSpinnerWindow(app)
            app.WindowSpinner = uispinner(app.ChildGridLayout3);
            app.WindowSpinner.Layout.Row = 2;
            app.WindowSpinner.Layout.Column = 4;
            app.WindowSpinner.Limits = [1 100];
            app.WindowSpinner.Step = 1;
            app.WindowSpinner.Value = 5;
            app.WindowSpinner.ValueChangedFcn = app.createCallbackFcn(@lowerVoxelSpinnerValueChanged, true);
        end
        
        function createSpinnerSaveDataStart(app)
            app.SaveDataStartSpinner = uispinner(app.ChildGridLayout3);
            app.SaveDataStartSpinner.Layout.Row = 1;
            app.SaveDataStartSpinner.Layout.Column = 2;
        end
        
        function createSpinnerSaveDataEnd(app)
            app.SaveDataEndSpinner = uispinner(app.ChildGridLayout3);
            app.SaveDataEndSpinner.Layout.Row = 2;
            app.SaveDataEndSpinner.Layout.Column = 2;
        end
        
        function createButtonCancel(app)
            app.CancelButton = uibutton(app.ChildGridLayout3, 'push');
            app.CancelButton.Layout.Row = 3;
            app.CancelButton.Layout.Column = 3;
            app.CancelButton.Text = 'Cancel';
        end
        
        function createButtonSave(app)
            app.SaveButton = uibutton(app.ChildGridLayout3, 'push');
            app.SaveButton.Layout.Row = 3;
            app.SaveButton.Layout.Column = 4;
            app.SaveButton.Text = 'Save Data';
        end
        
    end
    
    % initialization methods
    methods (Access = private)
        
        function setAxesLimits(app)
            allAxes = [app.AreaAxes, ...
                        app.DiameterAxes, ... 
                        app.MeanVelocityAxes, ...
                        app.MaxVelocityAxes, ...
                        app.FlowPerBeatAxes, ...
                        app.WallShearStressAxes, ...
                        app.PulsatilityIndexAxes];
            
            vessels = fieldnames(app.CenterlineToolApp.VIPR.Vessel);
            parameters = fieldnames(app.CenterlineToolApp.VIPR.Vessel.(vessels{1}));
            upperLimitX = numel(app.CenterlineToolApp.VIPR.Vessel.(vessels{1}).Area);
            
            notForPlots = {'BranchNumber', 'BranchActual', 'TimeMIPVessel', 'XCoordinate', 'YCoordinate', 'ZCoordinate'};
            for k = 1:numel(allAxes)
                if ~any(ismember(notForPlots, parameters{k}))
                    % allAxes(k).XLabel.String = xLabel;
                    allAxes(k).XLim = [1 upperLimitX];
                    
                    yData = app.CenterlineToolApp.VIPR.Vessel.(vessels{1}).(parameters{k});
                    
                    % y-limit 10% < min y-value
                    minY = min(yData) * 0.90;

                    % y-limit 10% > max y-value
                    maxY = max(yData) * 1.10; 
                    
                    allAxes(k).YLim = [minY maxY];
                end
            end
            
            resolution = app.CenterlineToolApp.VIPR.Resolution;
            noFrames = app.CenterlineToolApp.VIPR.NoFrames;
            x = resolution/1000 * linspace(1, noFrames, noFrames);
            app.TimeResolvedAxes.XTick = x;
            app.TimeResolvedAxes.XTickLabelRotation = 45;
        end
        
        function setSpinnerSaveData(app)
            % TODO: add CurrentVessel prop
            upperLimit = app.CurrentVessel;
            app.SaveDataEndSpinner.Value = upperLimit;
            app.SaveDataEndSpinner.Limits = [1 upperLimit];
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
%             app.WallShearStressAxes.XLim = [1 max_x_value];
%             y_data = foo;
%             [min_y_value, max_y_value] = min_max_y(y_data);
%             app.WallShearStressAxes.YLim = [min_y_value max_y_value];
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
            app.tb6 = axtoolbar(app.WallShearStressAxes, {'rotate', 'pan', 'zoomin', 'zoomout', 'export'});
            app.tb7 = axtoolbar(app.pulsatilityAxes, {'rotate', 'pan', 'zoomin', 'zoomout', 'export'});
            app.tb8 = axtoolbar(app.TimeResolvedAxes, {'rotate', 'pan', 'zoomin', 'zoomout', 'export'});
            
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
        function plotTimeAverageData(app)
            xData = linspace(1, length(app.CurrentVessel.Area), length(app.CurrentVessel.Area));
            
            allAxes = [app.AreaAxes, ...
                        app.DiameterAxes, ... 
                        app.MeanVelocityAxes, ...
                        app.MaxVelocityAxes, ...
                        app.FlowPerBeatAxes, ...
                        app.WallShearStressAxes, ...
                        app.PulsatilityIndexAxes];
                    
            parameters = {'Area', ...
                            'Diameter', ...
                            'MaxVelocity', ...
                            'MeanVelocity', ...
                            'FlowPerHeartCycle', ...
                            'WallShearStress', ...
                            'PulsatilityIndex', ...
                            'FlowPulsatile'};
            
            for k = 1:numel(allAxes)
                yData = app.CurrentVessel.(parameters{k});
                plot(xData, yData, 'Parent', app.(allAxes{k}));
            end
            %{
            % area plot
            y_data = app.current_vessel.area;
            plot(xData, y_data, 'Parent', app.areaAxes);

            % diameter plot
            y_data = app.current_vessel.diam;
            plot(xData, y_data, 'Parent', app.diameterAxes);
            
            % mean velocity plot
            y_data = app.current_vessel.meanVel;
            plot(xData, y_data, 'Parent', app.meanVelAxes);

            % max velocity plot
            y_data = app.current_vessel.maxVel;
            plot(xData, y_data, 'Parent', app.maxVelAxes);

            % flow per heartbeat plot
            y_data = app.current_vessel.flowPerHeartCycle;
            plot(xData, y_data, 'Parent', app.flowPerBeatAxes);

            % wss plot
            y_data = app.current_vessel.wss_simple_avg;
            plot(xData, y_data, 'Parent', app.WallShearStressAxes);

            % PI plot
            y_data = app.current_vessel.PI;
            plot(xData, y_data, 'Parent', app.pulsatilityAxes);
            %}
        end

        % pulsatile flow (i.e. time resolved) plot
        function plotTimeResolvedData(app) 
            cla(app.TimeResolvedAxes);
            
            lowerBound = app.LowerVoxelSpinner.Value;
            window = app.WindowSpinner.Value;
            resolution = app.CenterlineToolApp.VIPR.Resolution;
            noFrames = app.CenterlineToolApp.VIPR.NoFrames;
            
            xData = resolution/1000*linspace(1, noFrames, noFrames);
            yData = app.CurrentVessel.FlowPulsatile(lowerBound:lowerBound + window - 1, :);
            plot(xData, smoothdata(yData), 'Parent', app.TimeResolvedAxes);
            
            app.updateLegend();
        end
        
    end
    
    % window shading
    methods (Access = private)
        
        function addWindowShading(app)
            lowerBound = app.LowerVoxelSpinner.Value;
            window = app.WindowSpinner.Value;
            xData = [lowerBound lowerBound+window lowerBound+window lowerBound];            
            color = [0.3010 0.7450 0.9330]; % light blue
            alpha = 0.2;
            edgeColor = 'None';
            allAxes = [app.AreaAxes, ...
                        app.DiameterAxes, ... 
                        app.MeanVelocityAxes, ...
                        app.MaxVelocityAxes, ...
                        app.FlowPerBeatAxes, ...
                        app.WallShearStressAxes, ...
                        app.PulsatilityIndexAxes];
            for k = 1:numel(allAxes)
                windowPatch = patch(app.(allAxes(k)));
                windowPatch.XData = xData;
                yLimit = max(app.(allAxes(k)).YLim);
                windowPatch.YData = [0 0 yLimit yLimit];
                windowPatch.FaceColor = color;
                windowPatch.FaceAlpha = alpha;
                windowPatch.EdgeColor = edgeColor;
            end
            
            %{
            % area plot
            
            % diameter plot
            app.patch2 = windowPatch(app.diameterAxes);
            app.patch2.XData = xData;
            yLimit = max(app.diameterAxes.YLim);
            app.patch2.YData = get_y_data(yLimit);
            app.patch2.FaceColor = color;
            app.patch2.FaceAlpha = alpha;
            app.patch2.EdgeColor = edgeColor;
            
            % mean velocity
            app.patch3 = windowPatch(app.meanVelAxes);
            app.patch3.XData = xData;
            yLimit = max(app.meanVelAxes.YLim);
            app.patch3.YData = get_y_data(yLimit);
            app.patch3.FaceColor = color;
            app.patch3.FaceAlpha = alpha;
            app.patch3.EdgeColor = edgeColor;
            
            % max velocity
            app.patch4 = windowPatch(app.maxVelAxes);
            app.patch4.XData = xData;
            yLimit = max(app.maxVelAxes.YLim);
            app.patch4.YData = get_y_data(yLimit);
            app.patch4.FaceColor = color;
            app.patch4.FaceAlpha = alpha;
            app.patch4.EdgeColor = edgeColor;
            
            % flow/beat
            app.patch5 = windowPatch(app.flowPerBeatAxes);
            app.patch5.XData = xData;
            yLimit = max(app.flowPerBeatAxes.YLim);
            app.patch5.YData = get_y_data(yLimit);
            app.patch5.FaceColor = color;
            app.patch5.FaceAlpha = alpha;
            app.patch5.EdgeColor = edgeColor;
            
            % wss
            app.patch6 = windowPatch(app.WallShearStressAxes);
            app.patch6.XData = xData;
            yLimit = max(app.WallShearStressAxes.YLim);
            app.patch6.YData = get_y_data(yLimit);
            app.patch6.FaceColor = color;
            app.patch6.FaceAlpha = alpha;
            app.patch6.EdgeColor = edgeColor;
            
            % PI
            app.patch7 = windowPatch(app.pulsatilityAxes);
            app.patch7.XData = xData;
            yLimit = max(app.pulsatilityAxes.YLim);
            app.patch7.YData = get_y_data(yLimit);
            app.patch7.FaceColor = color;
            app.patch7.FaceAlpha = alpha;
            app.patch7.EdgeColor = edgeColor;
            
            function y_data = get_y_data(y_limit)
                y_data = [0 0 y_limit y_limit];
            end
            %}
        end
        
        function deleteWindowShading(app)
            allAxes = [app.AreaAxes, ...
                        app.DiameterAxes, ... 
                        app.MeanVelocityAxes, ...
                        app.MaxVelocityAxes, ...
                        app.FlowPerBeatAxes, ...
                        app.WallShearStressAxes, ...
                        app.PulsatilityIndexAxes];
            for k = 1:numel(allAxes)
                delete(findobj(allAxes(k), 'Type', 'Patch'));
            end
        end
        
    end
    
    % update misc
    methods (Access = private)
        
        function updateLegend(app)
            if app.WindowSpinner.Value <= 5 && strcmp(app.LegendSwitch.Value, 'On')
                lowerBound = app.LowerVoxelSpinner.Value;
                window = app.WindowSpinner.Value;
                voxelNumbers = [lowerBound:lowerBound + window - 1];
                app.Legend = legend(app.TimeResolvedAxes);
                app.Legend.String = append('Voxel ', string(voxelNumbers));
                app.Legend.Units = 'Normalized';
                % TODO: ensure legend is appropriately positioned
                app.Legend.Position = [0.875 0.4 0.1 0.2];
            else
                delete(app.Legend);
            end
        end
        
        function updateDataTable(app)           
            % TODO: calculate mean and SD for each parameter
            % add to table
            
            %{
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
            %}
        end
        
        function updateSpinnerValue(app)
            lower_bound = app.LowerVoxelSpinner.Value;
            window = app.WindowSpinner.Value;
            
            upper_limit = app.upper_bound - window;
            app.LowerVoxelSpinner.Limits = [1 upper_limit];
            
            if lower_bound + window > app.upper_bound
                lower_bound = app.upper_bound - window;
            end
            
            app.deleteWindowShading();
            if lower_bound + window <= app.upper_bound
                app.addWindowShading();
            end

            app.plotTimeResolvedData();
            app.updateVariance();
        end
        
    end

    % Linker components
    methods (Access = public)
        
        function updateLowerVoxelComponents(app, value)
            app.LowerVoxelSpinner.Value = value;
%             app.deleteWindowShading();
%             app.addWindowShading();
        end
        
        function updateWindowComponents(app, windowValue, upperLimit)
            app.WindowSpinner.Value = windowValue;
            app.LowerVoxelSpinner.Limits(2) = upperLimit;
%             app.deleteWindowShading();
%             app.addWindowShading();
        end
        
    end
    
    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, CenterlineToolApp)
            app.CenterlineToolApp = CenterlineToolApp;
            
            % set initial values
            names = fieldnames(app.CenterlineToolApp.VIPR.vessel);
            app.currentVessel = app.CenterlineToolApp.VIPR.vessel.(names{1});
            
            app.createSpinnerWindow();
            app.createSpinnerLowerVoxel();
            
            % plot
            app.plotTimeAverageData();
            app.plotTimeResolvedData();
            app.addWindowShading();
            
            % tidy up/misc
            app.SaveButton.Text = ['Save ' names{1}];
            % app.RecommendedDonotusethesevoxelsLabel.Text = ['(Recommended) Do not use these voxels: [', num2str(app.handles.values.removed_voxels), ']'];
            
        end

        % Value changed function: LowerVoxelSpinner
        function lowerVoxelSpinnerValueChanged(app, event)
            windowValue = app.WindowSpinner.Value;
            windowLimit = app.WindowSpinner.Limits(2);
            app.Linker.voxelChanged(event, windowValue, windowLimit);
        end
        
        % Value changed function: WindowSpinner
        function windowSpinnerValueChanged(app, event)
            windowLimit = app.WindowSpinner.Limits(2);
            app.Linker.windowChanged(event, windowLimit);
        end

        % Button pushed function: SaveButton
        function saveButtonPushed(app, ~)
            app.save_data();
            app.save_plots();
            app.save_vessel();
        end

        % Value changed function: LegendSwitch
        function legendSwitchValueChanged(app, ~)
            value = app.LegendSwitch.Value;
            switch value
                case 'Off'
                    % delete legend if it exists
                    try
                        delete(app.Legend);
                    catch
                    end
                otherwise
                    % add legend if window is small
                    % a large legend increases rendering time & decreases
                    % performance
                    updateLegend(app);
            end
        end

        % Close request function: parameter_plot_fig
        function uiFigureCloseRequest(app, ~)
            app.Linker.closeRequest();
        end
        
    end

end