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
        CurrentVessel;
    end
    
    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = ParameterPlotApp(varargin)

            % Create UIFigure and components
            app.createComponents()

            % Register the app with App Designer
            app.registerApp(app.UIFigure)

            % Execute the startup function
            app.runStartupFcn(@(app)startupFcn(app, varargin{:}))
            
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
            app.createLegend();

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
        
        function createFigure(app)
            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Name = 'Parameter Plots';
            app.UIFigure.WindowState = 'maximized';
            app.UIFigure.CloseRequestFcn = app.createCallbackFcn(@uiFigureCloseRequest, true);
            app.UIFigure.WindowKeyPressFcn = app.createCallbackFcn(@uiWindowKeyPressFcn, true);
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
            app.DataTable.ColumnName = {'Parameter'; 'Mean'; 'CoV'};
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
            app.WindowSpinner.ValueChangedFcn = app.createCallbackFcn(@windowSpinnerValueChanged, true);
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
        
        function createLegend(app)
            app.Legend = legend(app.TimeResolvedAxes);
            app.Legend.AutoUpdate = 'on';
            app.Legend.Location = 'northeast';
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
            
            vessels = fieldnames(app.VIPR.Vessel);
            parameters = fieldnames(app.VIPR.Vessel.(vessels{1}));
            upperLimitX = numel(app.VIPR.Vessel.(vessels{1}).Area);
            
            notForPlots = {'BranchNumber', 'BranchActual', 'TimeMIPVessel', 'XCoordinate', 'YCoordinate', 'ZCoordinate'};
            for k = 1:numel(allAxes)
                if ~any(ismember(notForPlots, parameters{k}))
                    % allAxes(k).XLabel.String = xLabel;
                    allAxes(k).XLim = [1 upperLimitX];
                    
                    yData = app.VIPR.Vessel.(vessels{1}).(parameters{k});
                    
                    % y-limit 10% < min y-value
                    minY = min(yData) * 0.90;

                    % y-limit 10% > max y-value
                    maxY = max(yData) * 1.10; 
                    
                    allAxes(k).YLim = [minY maxY];
                end
            end
            
            resolution = app.VIPR.Resolution;
            noFrames = app.VIPR.NoFrames;
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
                            'MeanVelocity', ...
                            'MaxVelocity', ...
                            'FlowPerHeartCycle', ...
                            'WallShearStress', ...
                            'PulsatilityIndex'};
            
            for k = 1:numel(allAxes)
                yData = app.CurrentVessel.(parameters{k});
                plot(xData, yData, 'Parent', allAxes(k));
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
            resolution = app.VIPR.Resolution;
            noFrames = app.VIPR.NoFrames;
            
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
                windowPatch = patch(allAxes(k));
                windowPatch.XData = xData;
                yLimit = max(allAxes(k).YLim);
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
            window = app.WindowSpinner.Value;
            if window > 5
                app.Legend.Visible = 'off';
            else
                app.Legend.Visible = 'on';
%                 lowerBound = app.LowerVoxelSpinner.Value;
%                 voxelNumbers = [lowerBound:lowerBound + window - 1];
%                 app.Legend.String = append('Voxel ', string(voxelNumbers));
            end
        end
        
        function updateDataTable(app)       
            parameters = {'Area', ...
                            'Diameter', ...
                            'MeanVelocity', ...
                            'MaxVelocity', ...
                            'FlowPerHeartCycle', ...
                            'WallShearStress', ...
                            'PulsatilityIndex', ...
                            'FlowPulsatile'};
            
            window = app.WindowSpinner.Value;
            lower_voxel = app.LowerVoxelSpinner.Value;
            range = [lower_voxel:lower_voxel + window - 1];
            
            data = cell(numel(parameters), 3);
            for k = 1:numel(parameters)
                param_mean = mean(app.CurrentVessel.(parameters{k})(range));
                param_sd = std(app.CurrentVessel.(parameters{k})(range));
                param_cov = (param_sd / param_mean) * 100;
                
                data{k, 1} = parameters{k};
                data{k, 2} = param_mean;
                data{k, 3} = param_cov;
            end
            app.DataTable.Data = data;
        end
        
    end

    % Linker components
    methods (Access = public)
        
        function updateLowerVoxelComponents(app, value)
            app.LowerVoxelSpinner.Value = value;
            app.deleteWindowShading();
            app.addWindowShading();
            app.plotTimeResolvedData();
            app.updateDataTable();
        end
        
        function updateWindowComponents(app, windowValue, upperLimit)
            app.WindowSpinner.Value = windowValue;
            app.LowerVoxelSpinner.Limits(2) = upperLimit;
            app.deleteWindowShading();
            app.addWindowShading();
            app.plotTimeResolvedData();
            app.updateDataTable();
        end
        
    end
    
    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, varargin)
            app.Linker = varargin{1};
            app.VIPR = varargin{2};
            
            % set initial values
            names = fieldnames(app.VIPR.Vessel);
            app.CurrentVessel = app.VIPR.Vessel.(names{1});
            
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
        
        % Window key pressed function
        function uiWindowKeyPressFcn(app, event)
            switch char(event.Modifier)
                case 'control'
                    if strcmpi(event.Key, 'w')
                        app.uiFigureCloseRequest();
                    end
            end
        end
        
        % Close request function: ParameterPlot
        function uiFigureCloseRequest(app, ~)
            app.Linker.closeRequest();
        end
        
    end

end