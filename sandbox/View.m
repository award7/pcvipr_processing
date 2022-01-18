classdef View < matlab.apps.AppBase
    
    properties (Access = public)
        UIFigure                                matlab.ui.Figure;
        ParentGrid                              matlab.ui.container.GridLayout;
        Label                                   matlab.ui.control.Label;
        FileMenu;
        LoadDataMenuButton;
        AnalysisMenu;
        BackgroundPhaseCorrectionMenuButton;
        ConnectToDbMenuButton;
        SetDataOutputPathMenuButton;
        ExitMenuButton;
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
            app.createConnectToDbMenuButton(controller);
            app.createSetDataOutputPathMenuButton(controller);
            app.createExitMenuButton(controller);
            
            % analysis menu
            app.createAnalysisMenu();
            app.createBackgroundPhaseCorrectionMenuButton(controller);
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
        
        function createConnectToDbMenuButton(app, controller)
            app.ConnectToDbMenuButton = uimenu(app.FileMenu);
            app.ConnectToDbMenuButton.Text = 'Connect to &Database';
            app.ConnectToDbMenuButton.MenuSelectedFcn = createCallbackFcn(app, @controller.connectToDbMenuButtonCallback, true);
        end
        
        function createSetDataOutputPathMenuButton(app, controller)
            app.SetDataOutputPathMenuButton = uimenu(app.FileMenu);
            app.SetDataOutputPathMenuButton.Text = 'Set Data Output Path';
            app.SetDataOutputPathMenuButton.MenuSelectedFcn = createCallbackFcn(app, @controller.setDataOutputPathMenuButtonCallback, true);
        end
        
        function createExitMenuButton(app, controller)
            app.ExitMenuButton = uimenu(app.FileMenu);
            app.ExitMenuButton.Text = 'Exit';
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
            if isobject(app.Label)
                if isvalid(app.Label)
                    app.Label.delete();
                end
            end
            
            app.Label = uilabel(app.ParentGrid);
            app.Label.Layout.Column = 1;
            app.Label.Layout.Row = 1;
            app.Label.Text = 'FOO'; 
            app.Label.VerticalAlignment = 'center';
            app.Label.HorizontalAlignment = 'center';
        end

    end
       
end