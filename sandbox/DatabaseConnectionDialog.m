classdef DatabaseConnectionDialog < matlab.apps.AppBase
    % this class creates a modal window for database connection
    % it does not attach to the main figure
    % callbacks are still stored in the controller and data in the model
    
    properties (Access = private)
       UIFigure     matlab.ui.UIFigure;
       ParentGrid
       ListBox
       ConnectButton
       CancelButton
       OpenDatabaseExplorerButton
       RefreshButton
    end
    
    methods (Access = public)
        
        function app = DatabaseConnectionDialog(controller)
            app.createComponents(controller);
            
            app.registerApp(app.UIFigure);
            
            if nargout == 0
                clear app
            end            
        end
        
        function delete(app)
            delete(app);
        end
        
    end
    
    % create figure and components
    methods (Access = private)
        
        function createComponents(app, controller)
            app.createFigure();
        end
        
        function createFigure(app)
            args.Name = 'Connect to Database';
            args.Units = 'Normalized';
            args.Position = [1/3 1/3 1/3 1/3];
            args.WindowStyle = 'modal';
            args.Visible = 'off';
            
            args_array = namedargs2cell(args);
            app.UIFigure = uifigure(args_array{:});
        end
        
        function createParentGrid(app)
        end
        
        function createListBox(app)
        end
        
        function createConnectButton(app)
        end
        
        function createCancelButton(app)
        end
        
        function createOpenDatabaseExplorerButton(app)
        end
        
        function createRefreshButton(app)
        end
        
    end
    
end