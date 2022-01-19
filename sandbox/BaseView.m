classdef BaseView < matlab.apps.AppBase
    %{
        This class creates the initial figure.
        Any other views are built into a single ParentGrid property and
        then assigned to the UIFigure.
    %}
    
    % base figure properties
    properties (Access = public)
        UIFigure        matlab.ui.Figure;
        
    end
    
    % base grid properties
    properties (Access = private)
        ParentGrid      matlab.ui.container.GridLayout;
    end
    
    % file menu bar properties
    properties (Access = private)
        FileMenu            matlab.ui.container.Menu;
        LoadDataMenuButton  matlab.ui.container.Menu;
        ExitMenuButton      matlab.ui.container.Menu;
    end
    
    % analysis menu bar properties
    properties (Access = private)
        AnalysisMenu                            matlab.ui.container.Menu;
        ViewFullVasculatureMenuButton           matlab.ui.container.Menu;
        BackgroundPhaseCorrectionMenuButton     matlab.ui.container.Menu;
        DrawROIMenuButton                       matlab.ui.container.Menu;
        ViewParametricMapMenuButton             matlab.ui.container.Menu;
        FeatureExtractionMenuButton             matlab.ui.container.Menu;
        VesselSelectionMenuButton               matlab.ui.container.Menu;
        SegmentVesselsMenuButton                matlab.ui.container.Menu;
        Vessel3dMenuButton                      matlab.ui.container.Menu;
        ParameterPlotMenuButton                 matlab.ui.container.Menu;
    end
    
    % data source menu bar properties
    properties (Access = private)
        DataSourceMenu                      matlab.ui.container.Menu;
        ConnectToDbMenuButton               matlab.ui.container.Menu;
        TestDbConnectionMenuButton          matlab.ui.container.Menu;
        SetDataOutputPathMenuButton         matlab.ui.container.Menu;
        SetDataOutputParametersMenuButton   matlab.ui.container.Menu;
    end

    % app creation
    methods (Access = public)
        
        function app = BaseView(controller)
            app.createBaseFigure(controller);
            app.registerApp(app.UIFigure);
            
            if nargout == 0
                clear app
            end
        end
        
    end
    
    % create base figure and objects
    methods (Access = private)
        
        % create figure
        function createBaseFigure(app, controller)
            app.createFigure(controller);
            
            % file menu
            app.createFileMenu();
            app.createLoadDataMenuButton(controller);
            app.createExitMenuButton(controller);
            
            % analysis menu
            app.createAnalysisMenu();
            app.createViewFullVasculatureMenuButton(controller);
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
        
        function createFigure(app, controller)
            % todo: add title, size, position
            app.UIFigure = uifigure();
            app.UIFigure.CloseRequestFcn = app.createCallbackFcn(@controller.UIFigureCloseRequest, true);
            app.UIFigure.WindowKeyPressFcn = app.createCallbackFcn(@controller.UIWindowKeyPressFcn, true);
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
        
        function createViewFullVasculatureMenuButton(app, controller)
            app.ViewFullVasculatureMenuButton = uimenu(app.AnalysisMenu);
            app.ViewFullVasculatureMenuButton.Text = 'View Full Vasculature';
            app.ViewFullVasculatureMenuButton.MenuSelectedFcn = createCallbackFcn(app, @controller.viewFullVasculatureMenuButtonCallback, true);
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

    % enable buttons methods
    methods (Access = public)
        
        function enableLoadDataMenuButton(app)
            app.LoadDataMenuButton.Enable = 'on';
        end
        
        function enableExitMenuButton(app)
            app.ExitMenuButton.Enable = 'on';
        end
        
        function enableShowFullVasculatureMenuButton(app)
            app.ShowFullVasculatureMenuButton.Enable = 'on';
        end
        
        function enableBackgroundPhaseCorrectionMenuButton(app)
            app.BackgroundPhaseCorrectionMenuButton.Enable = 'on';
        end
        
        function enableDrawROIMenuButton(app)
            app.DrawROIMenuButton.Enable = 'on';
        end
        
        function enableViewParametricMapMenuButton(app)
            app.ViewParametricMapMenuButton.Enable = 'on';
        end
        
        function enableFeatureExtractionMenuButton(app)
            app.FeatureExtractionMenuButton.Enable = 'on';
        end
        
        function enableVesselSelectionMenuButton(app)
            app.VesselSelectionMenuButton.Enable = 'on';
        end
        
        function enableSegmentVesselsMenuButton(app)
            app.SegmentVesselsMenuButton.Enable = 'on';
        end
        
        function enableVessel3dMenuButton(app)
            app.Vessel3dMenuButton.Enable = 'on';
        end
        
        function enableParameterPlotMenuButton(app)
            app.ParameterPlotMenuButton.Enable = 'on';
        end
        
        function enableConnectToDbMenuButton(app)
            app.ConnectToDbMenuButton.Enable = 'on';
        end
        
        function enableTestDbConnectionMenuButton(app)
            app.TestDbConnectionMenuButton.Enable = 'on';
        end
        
        function enableSetDataOutputPathMenuButton(app)
            app.SetDataOutputPathMenuButton.Enable = 'on';
        end
        
        function enableSetDataOutputParametersMenuButton(app)
            app.SetDataOutputParametersMenuButton.Enable = 'on';
        end

    end
    
    % disable buttons methods
    methods (Access = public)
        
        function disableLoadDataMenuButton(app)
            app.LoadDataMenuButton.Enable = 'off';
        end
        
        function disableExitMenuButton(app)
            app.ExitMenuButton.Enable = 'on';
        end
        
        function disableShowFullVasculatureMenuButton(app)
            app.ShowFullVasculatureMenuButton.Enable = 'on';
        end
        
        function disableBackgroundPhaseCorrectionMenuButton(app)
            app.BackgroundPhaseCorrectionMenuButton.Enable = 'on';
        end
        
        function disableDrawROIMenuButton(app)
            app.DrawROIMenuButton.Enable = 'on';
        end
        
        function disableViewParametricMapMenuButton(app)
            app.ViewParametricMapMenuButton.Enable = 'on';
        end
        
        function disableFeatureExtractionMenuButton(app)
            app.FeatureExtractionMenuButton.Enable = 'on';
        end
        
        function disableVesselSelectionMenuButton(app)
            app.VesselSelectionMenuButton.Enable = 'on';
        end
        
        function disableSegmentVesselsMenuButton(app)
            app.SegmentVesselsMenuButton.Enable = 'on';
        end
        
        function disableVessel3dMenuButton(app)
            app.Vessel3dMenuButton.Enable = 'on';
        end
        
        function disableParameterPlotMenuButton(app)
            app.ParameterPlotMenuButton.Enable = 'on';
        end
        
        function disableConnectToDbMenuButton(app)
            app.ConnectToDbMenuButton.Enable = 'on';
        end
        
        function disableTestDbConnectionMenuButton(app)
            app.TestDbConnectionMenuButton.Enable = 'on';
        end
        
        function disableSetDataOutputPathMenuButton(app)
            app.SetDataOutputPathMenuButton.Enable = 'on';
        end
        
        function disableSetDataOutputParametersMenuButton(app)
            app.SetDataOutputParametersMenuButton.Enable = 'on';
        end
        
    end
    
end