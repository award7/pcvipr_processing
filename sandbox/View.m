classdef View < matlab.apps.AppBase
    
    % figure properties
    properties (Access = public)
        UIFigure                                matlab.ui.Figure;
        ParentGrid                              matlab.ui.container.GridLayout;
        Label;
    end
    
    % file menu bar properties
    properties (Access = public)
        FileMenu;
        
        LoadDataMenuButton;
        ExitMenuButton;
    end
    
    % analysis menu bar properties
    properties (Access = public)
        AnalysisMenu;
        
        ShowFullVasculatureMenuButton;
        BackgroundPhaseCorrectionMenuButton;
        DrawROIMenuButton;
        ViewParametricMapMenuButton;
        FeatureExtractionMenuButton;
        VesselSelectionMenuButton;
        SegmentVesselsMenuButton;
        Vessel3dMenuButton;
        ParameterPlotMenuButton;
    end
    
    % data source menu bar properties
    properties (Access = public)
        DataSourceMenu;
        
        ConnectToDbMenuButton;
        TestDbConnectionMenuButton;
        SetDataOutputPathMenuButton;
        SetDataOutputParametersMenuButton;
    end
    
    % app creation
    methods (Access = public)
        
        function app = View(controller)
            app.createBaseFigure(controller);
            app.createView('main', controller);
            
            app.registerApp(app.UIFigure);
            
            if nargout == 0
                clear app
            end
        end
%         
%         function delete(app)
%             delete(app.UIFigure);
%         end
%         
    end
    
    % create different views
    methods (Access = public)
        
        % create the specified view passed by 'view'
        function createView(app, view, controller)
            arguments
                app;
                view {mustBeMember(view, {'main', 'bgpc', 'vessel_select', 'vessel_3d', 'parameter_plot'})};
                controller;
            end
            
            switch view
                case 'main'
                    app.createMainView();
                case 'bgpc'
                    app.createBgpcView();
                case 'vessel_select'
                    app.createVesselSelectView();
                case 'vessel_3d'
                    app.createVessel3dView();
                case 'parameter_plot'
                    app.createParameterPlotView();
            end
            
        end
        
    end
    
    % create base figure and objects
    methods (Access = private)
        
        % create figure
        function createBaseFigure(app, controller)
            app.createFigure();
            
            % file menu
            app.createFileMenu();
            app.createLoadDataMenuButton(controller);
            app.createExitMenuButton(controller);
            
            % analysis menu
            app.createAnalysisMenu();
            app.createBackgroundPhaseCorrectionMenuButton(controller);
            app.createDrawROIMenuButton(controller);
            app.createViewParametricMapMenuButton(controller);
            app.createVesselSelectionMenuButton(controller);
            app.createSegmentVesselsMenuButton(controller);
            app.createVessel3dMenuButton(controller);
            app.createParameterPlotMenuButton(controller);

            % data source menu
            app.createDataSourceMenu();
            app.createConnectToDbMenuButton(controller);
            app.createTestDbConnectionMenuButton(controller);
            app.createSetDataOutputPathMenuButton(controller);
        end
        
        function createFigure(app)
            app.UIFigure = uifigure();
            % todo: add title, size, position
        end
        
        % file menu
        function createFileMenu(app)
            app.FileMenu = uimenu(app.UIFigure);
            app.FileMenu.Text = '&File';
        end
        
        function createLoadDataMenuButton(app, controller)
            app.LoadDataMenuButton = uimenu(app.FileMenu);
            app.LoadDataMenuButton.Text = '&Load Data';
            app.LoadDataMenuButton.MenuSelectedFcn = createCallbackFcn(app, @controller.loadDataMenuButtonCallback, true);
        end
        
        function createExitMenuButton(app, controller)
            app.ExitMenuButton = uimenu(app.FileMenu);
            app.ExitMenuButton.Text = 'Exit';
            app.ExitMenuButton.Separator = 'on';
            app.ExitMenuButton.MenuSelectedFcn = createCallbackFcn(app, @controller.exitMenuButtonCallback, true);
        end
            
        % analysis menu
        function createAnalysisMenu(app)
            app.AnalysisMenu = uimenu(app.UIFigure);
            app.AnalysisMenu.Text = '&Analysis';
        end

        function createBackgroundPhaseCorrectionMenuButton(app, controller)
            app.BackgroundPhaseCorrectionMenuButton = uimenu(app.AnalysisMenu);
            app.BackgroundPhaseCorrectionMenuButton.Text = 'Perform Background Phase Correction';
            app.BackgroundPhaseCorrectionMenuButton.MenuSelectedFcn = createCallbackFcn(app, @controller.backgroundPhaseCorrectionMenuButtonCallback, true);
        end
        
        function createDrawROIMenuButton(app, controller)
            app.DrawROIMenuButton = uimenu(app.AnalysisMenu);
            app.DrawROIMenuButton.Text = 'Draw ROI';
            app.DrawROIMenuButton.MenuSelectedFcn = createCallbackFcn(app, @controller.drawROIMenuButtonCallback, true);
        end
        
        function createViewParametricMapMenuButton(app, controller)
            app.ViewParametricMapMenuButton = uimenu(app.AnalysisMenu);
            app.ViewParametricMapMenuButton.Text = 'View Parametric Map';
            app.ViewParametricMapMenuButton.MenuSelectedFcn = createCallbackFcn(app, @controller.viewParametricMapMenuButtonCallback, true);
        end
        
        function createVesselSelectionMenuButton(app, controller)
            app.VesselSelectionMenuButton = uimenu(app.AnalysisMenu);
            app.VesselSelectionMenuButton.Text = 'Select Vessels';
            app.VesselSelectionMenuButton.MenuSelectedFcn = createCallbackFcn(app, @controller.vesselSelectionMenuButtonCallback, true);
        end
        
        function createSegmentVesselsMenuButton(app, controller)
            app.SegmentVesselsMenuButton = uimenu(app.AnalysisMenu);
            app.SegmentVesselsMenuButton.Text = 'Segment Vessels';
            app.SegmentVesselsMenuButton.MenuSelectedFcn = createCallbackFcn(app, @controller.segmentVesselsMenuButtonCallback, true);
        end
        
        function createVessel3dMenuButton(app, controller)
            app.Vessel3dMenuButton = uimenu(app.AnalysisMenu);
            app.Vessel3dMenuButton.Text = 'View Vessels 3D';
            app.Vessel3dMenuButton.MenuSelectedFcn = createCallbackFcn(app, @controller.vessel3dMenuButtonCallback, true);
        end
        
        function createParameterPlotMenuButton(app, controller)
            app.ParameterPlotMenuButton = uimenu(app.AnalysisMenu);
            app.ParameterPlotMenuButton.Text = 'View Parameter Plot';
            app.ParameterPlotMenuButton.MenuSelectedFcn = createCallbackFcn(app, @controller.parameterPlotMenuButtonCallback, true);
        end
        
        % data source menu
        function createDataSourceMenu(app)
            app.DataSourceMenu = uimenu(app.UIFigure);
            app.DataSourceMenu.Text = '&Data Source';
        end
        
        function createSetDataOutputParametersMenuButton(app, controller)
            app.SetDataOutputParametersMenuButton = uimenu(app.DataSourceMenu);
            app.SetDataOutputParametersMenuButton.Text = 'Set Data Output Parameters';
            app.SetDataOutputParametersMenuButton.MenuSelectedFcn = createCallbackFcn(app, @controller.setDataOutputParametersMenuCallback, true);
        end
        
        function createConnectToDbMenuButton(app, controller)
            app.ConnectToDbMenuButton = uimenu(app.DataSourceMenu);
            app.ConnectToDbMenuButton.Text = 'Connect to &Database';
            app.ConnectToDbMenuButton.Separator = 'on';
            app.ConnectToDbMenuButton.MenuSelectedFcn = createCallbackFcn(app, @controller.connectToDbMenuButtonCallback, true);
        end
        
        function createTestDbConnectionMenuButton(app, controller)
            app.TestDbConnectionMenuButton = uimenu(app.DataSourceMenu);
            app.TestDbConnectionMenuButton.Text = 'Test DB Connection';
            app.TestDbConnectionMenuButton.MenuSelectedFcn = createCallbackFcn(app, @controller.testDbConnectionMenuButtonCallback, true);
        end
        
        function createSetDataOutputPathMenuButton(app, controller)
            app.SetDataOutputPathMenuButton = uimenu(app.DataSourceMenu);
            app.SetDataOutputPathMenuButton.Text = 'Set Data Output Path';
            app.SetDataOutputPathMenuButton.Separator = 'on';
            app.SetDataOutputPathMenuButton.MenuSelectedFcn = createCallbackFcn(app, @controller.setDataOutputPathMenuButtonCallback, true);
        end

        
    end
    
    % main view methods
    methods (Access = private)
        
        function createMainView(app)
            app.createParentGridMain();
            app.createLblMain();
        end
        
        function createParentGridMain(app)
            if isobject(app.ParentGrid)
                if isvalid(app.ParentGrid)
                    app.ParentGrid.delete();
                end
            end
            
            app.ParentGrid = uigridlayout(app.UIFigure);
            app.ParentGrid.ColumnWidth = {'1x'};
            app.ParentGrid.RowHeight = {'1x'};
        end

        function createLblMain(app)
            app.Label = uilabel(app.ParentGrid);
            app.Label.Layout.Column = 1;
            app.Label.Layout.Row = 1;
            app.Label.Text = 'FOO'; 
            app.Label.VerticalAlignment = 'center';
            app.Label.HorizontalAlignment = 'center';
        end

    end
    
    % bgpc view methods
    
    % vessel select view methods
    
    % vessel3D view methods
    
    % parameter plot view methods
    
    % enable buttons methods
    methods (Access = public)
        
        function enableLoadDataMenuButton(app)
        end
        
        function enableExitMenuButton(app)
        end
        
        function enableShowFullVasculatureMenuButton(app)
        end
        
        function enableBackgroundPhaseCorrectionMenuButton(app)
        end
        
        function enableDrawROIMenuButton(app)
        end
        
        function enableViewParametricMapMenuButton(app)
        end
        
        function enableFeatureExtractionMenuButton(app)
        end
        
        function enableVesselSelectionMenuButton(app)
        end
        
        function enableSegmentVesselsMenuButton(app)
        end
        
        function enableVessel3dMenuButton(app)
        end
        
        function enableParameterPlotMenuButton(app)
        end
        
        function enableConnectToDbMenuButton(app)
        end
        
        function enableTestDbConnectionMenuButton(app)
        end
        
        function enableSetDataOutputPathMenuButton(app)
        end
        
        function enableSetDataOutputParametersMenuButton(app)
        end

    end
    
    % disable buttons methods
    methods (Access = public)
        
        function disableLoadDataMenuButton(app)
        end
        
        function disableExitMenuButton(app)
        end
        
        function disableShowFullVasculatureMenuButton(app)
        end
        
        function disableBackgroundPhaseCorrectionMenuButton(app)
        end
        
        function disableDrawROIMenuButton(app)
        end
        
        function disableViewParametricMapMenuButton(app)
        end
        
        function disableFeatureExtractionMenuButton(app)
        end
        
        function disableVesselSelectionMenuButton(app)
        end
        
        function disableSegmentVesselsMenuButton(app)
        end
        
        function disableVessel3dMenuButton(app)
        end
        
        function disableParameterPlotMenuButton(app)
        end
        
        function disableConnectToDbMenuButton(app)
        end
        
        function disableTestDbConnectionMenuButton(app)
        end
        
        function disableSetDataOutputPathMenuButton(app)
        end
        
        function disableSetDataOutputParametersMenuButton(app)
        end
        
    end
end