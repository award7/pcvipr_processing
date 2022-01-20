classdef BaseView < matlab.apps.AppBase
    %{
        This class creates the initial figure.
        Any other views are built into a single ParentGrid property and
        then assigned to the UIFigure.
    
        Future functionality:
            *add a 'Checkpoint' option to save current analysis?
    
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
        LoadDataMenuButton                  matlab.ui.container.Menu;
        DataSourceMenu                      matlab.ui.container.Menu;
        ConnectToDbMenuButton               matlab.ui.container.Menu;
        OpenDatabaseExplorerMenuButton      matlab.ui.container.Menu;
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
            app.createLoadDataMenuButton(controller);
            app.createConnectToDbMenuButton(controller);
            app.createTestDbConnectionMenuButton(controller);
            app.createOpenDatabaseExplorerMenuButton(controller);
            app.createSetDataOutputParametersMenuButton(controller);
            app.createSetDataOutputPathMenuButton(controller);
            
            % make figure visible after object creation
            app.UIFigure.Visible = 'on';
        end
        
        function createFigure(app, controller)
            % todo: add title, size, position
            app.UIFigure = uifigure('Name', 'PC VIPR Processing', ...
                                    'Units', 'Normalized', ...
                                    'Position', [1/4 1/4 1/2 1/2], ...
                                    'Visible', 'off', ...
                                    'Icon', 'vipr.png');
            app.UIFigure.CloseRequestFcn = app.createCallbackFcn(@controller.UIFigureCloseRequest, true);
            app.UIFigure.WindowKeyPressFcn = app.createCallbackFcn(@controller.UIWindowKeyPressFcn, true);
        end
        
        % file menu
        function createFileMenu(app)
            app.FileMenu = uimenu(app.UIFigure);
            app.FileMenu.Text = '&File';
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
        
        function createLoadDataMenuButton(app, controller)
            app.LoadDataMenuButton = uimenu(app.DataSourceMenu);
            app.LoadDataMenuButton.Text = '&Load Data';
            app.LoadDataMenuButton.MenuSelectedFcn = createCallbackFcn(app, @controller.loadDataMenuButtonCallback, true);
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
        
        function createOpenDatabaseExplorerMenuButton(app, controller)
            args.Text = 'Open Database Explorer';
            args.MenuSelectedFcn = createCallbackFcn(app, @controller.openDatabaseExplorerMenuButtonCallback, true);
            
            args_array = namedargs2cell(args);
            app.OpenDatabaseExplorerMenuButton = uimenu(app.DataSourceMenu, args_array{:});
        end
        
        function createSetDataOutputParametersMenuButton(app, controller)
            app.SetDataOutputParametersMenuButton = uimenu(app.DataSourceMenu);
            app.SetDataOutputParametersMenuButton.Text = 'Set Data Output Parameters';
            app.SetDataOutputParametersMenuButton.Separator = 'on';
            app.SetDataOutputParametersMenuButton.MenuSelectedFcn = createCallbackFcn(app, @controller.setDataOutputParametersMenuCallback, true);
        end
        
        function createSetDataOutputPathMenuButton(app, controller)
            app.SetDataOutputPathMenuButton = uimenu(app.DataSourceMenu);
            app.SetDataOutputPathMenuButton.Text = 'Set Data Output Path';
            app.SetDataOutputPathMenuButton.MenuSelectedFcn = createCallbackFcn(app, @controller.setDataOutputPathMenuButtonCallback, true);
        end

    end

    % change button state methods
    methods (Access = public)
        
        function setButtonState(app, button, state)
            arguments
                app;
                button {mustBeTextScalar};
                state {mustBeUnderlyingType(state, 'ButtonState')};
            end
            
            app.(button).Enable = char(state);
        end
        
    end 
    
end