classdef CenterlineToolApp < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = private, Hidden)
        UIFigure                            matlab.ui.Figure
        ParentGridLayout                    matlab.ui.container.GridLayout
        ChildGridLayout1                    matlab.ui.container.GridLayout
        ChildGridLayout2                    matlab.ui.container.GridLayout
        ChildGridLayout3                    matlab.ui.container.GridLayout
        ChildGridLayout4                    matlab.ui.container.GridLayout
        Vasculature3DAxes                   matlab.ui.control.UIAxes
        DrawROIButton                       matlab.ui.control.Button
        ViewParametricMapButton             matlab.ui.control.Button
        FeatureExtractionButton             matlab.ui.control.Button
        VesselSelectionButton               matlab.ui.control.Button
        BackgroundPhaseCorrectionButton     matlab.ui.control.Button
        LoadDataButton                      matlab.ui.control.Button
        DataDirectoryLabel                  matlab.ui.control.Label
        DBConnectionButton                  matlab.ui.control.Button
        DatabaseLabel                       matlab.ui.control.Label
        SegmentVesselsButton                matlab.ui.control.Button
        LoadSavedDataButton                 matlab.ui.control.Button
        Vasculature3DAxesTB
        DataFileOutputButton                matlab.ui.control.Button;
        DataFileOutputLabel                 matlab.ui.control.Label;
    end
    
    % private properties (i.e. those that are contained in this GUI)
    properties (Access = private)
        % child GUIs
        PhaseCorrectionApp;
        VesselSelectionApp;
        Vessel3DApp;
        % ParameterPlotApp;
    end
    
    % main data structure that will contain all necessary data for
    % processing stream
    properties(Access = public)
        VIPR = struct;
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = CenterlineToolApp

            % Create UIFigure and components
            app.createComponents()

            % Register the app with App Designer
            app.registerApp(app.UIFigure)

            % Execute the startup function
            app.runStartupFcn(@startupFcn)

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

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)
            app.createFigure();
            app.createParentGrid();
            app.createChildGrid1();
            app.createChildGrid2();
            app.createChildGrid3();
            app.createChildGrid4();
            app.createVasculature3dAxes();
            app.createVasculature3dAxesToolbar();
            app.createLoadDataButton();
            app.createDatabaseConnectionButton();
            app.createBackgroundPhaseCorrectionButton();
            app.createDrawROIButton();
            app.createViewParametricMapButton();
            app.createFeatureExtractionButton();
            app.createVesselSelectionButton();
            app.createSegmentVesselButton();
            app.createDataDirectoryLabel();
            app.createDatabaseLabel();
            app.createDataFileOutputButton();
            app.createDataFileOutputLabel();
            
            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
            
        function createFigure(app)
            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Name = 'Centerline Tool (main)';
            app.UIFigure.WindowState = 'maximized';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @uiFigureCloseRequest, true);
            app.UIFigure.WindowKeyPressFcn = createCallbackFcn(app, @uiWindowKeyPressFcn, true);
        end

        function createParentGrid(app)
            app.ParentGridLayout = uigridlayout(app.UIFigure);
            app.ParentGridLayout.ColumnWidth = {'1x'};
            app.ParentGridLayout.RowHeight = {'1x', '5x', '1x'};
        end

        function createChildGrid1(app)
            % top row container to house 'load data' and 'db connection'
            % buttons and labels
            % children = ChildGridLayout3 and ChildGridLayout4
            app.ChildGridLayout1 = uigridlayout(app.ParentGridLayout);
            app.ChildGridLayout1.Layout.Row = 1;
            app.ChildGridLayout1.Layout.Column = 1;
            app.ChildGridLayout1.ColumnWidth = {'1x'};
            app.ChildGridLayout1.RowHeight = {'1x', '1x'};
        end

        function createChildGrid2(app)
            % bottom row container to house other buttons
            % children = none
            app.ChildGridLayout2 = uigridlayout(app.ParentGridLayout);
            app.ChildGridLayout2.Layout.Row = 3;
            app.ChildGridLayout2.Layout.Column = 1;
            app.ChildGridLayout2.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x'};
            app.ChildGridLayout2.RowHeight = {'1x'};
        end
        
        function createChildGrid3(app)
            % top row container within ChildGridLayout1 to house buttons
            app.ChildGridLayout3 = uigridlayout(app.ChildGridLayout1);
            app.ChildGridLayout3.Layout.Row = 1;
            app.ChildGridLayout3.Layout.Column = 1;
            app.ChildGridLayout3.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x'};
            app.ChildGridLayout3.RowHeight = {'2x'};
        end
        
        function createChildGrid4(app)
            % bottom row container within ChildGridLayout1 to house labels
            app.ChildGridLayout4 = uigridlayout(app.ChildGridLayout1);
            app.ChildGridLayout4.Layout.Row = 2;
            app.ChildGridLayout4.Layout.Column = 1;
            app.ChildGridLayout4.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x'};
            app.ChildGridLayout4.RowHeight = {'1x'};
        end

        function createVasculature3dAxes(app)
            app.Vasculature3DAxes = uiaxes(app.ParentGridLayout);
            app.Vasculature3DAxes.Layout.Row = 2;
            app.Vasculature3DAxes.Layout.Column = 1;
            title(app.Vasculature3DAxes, '')
            xlabel(app.Vasculature3DAxes, '')
            ylabel(app.Vasculature3DAxes, '')
            app.Vasculature3DAxes.ZDir = 'reverse';
            app.Vasculature3DAxes.Color = 'black';
            colormap(app.Vasculature3DAxes, 'gray');
            alpha(app.Vasculature3DAxes, 0.9);
            axis(app.Vasculature3DAxes, 'vis3d');
            axis(app.Vasculature3DAxes, 'off');
            app.Vasculature3DAxes.XTick = [];
            app.Vasculature3DAxes.YTick = [];
            camlight(app.Vasculature3DAxes, 'headlight');
            lighting(app.Vasculature3DAxes, 'gouraud');
        end

        function createVasculature3dAxesToolbar(app)
            app.Vasculature3DAxesTB = axtoolbar(app.Vasculature3DAxes, {'zoomin', 'zoomout', 'export', 'rotate'});
            restoreViewBtn = axtoolbarbtn(app.Vasculature3DAxesTB, 'push');
            restoreViewBtn.Tag = 'restoreview';
            restoreViewBtn.Icon = 'restoreview';
            restoreViewBtn.ButtonPushedFcn = app.createCallbackFcn(@toolbarValueChanged, true);
        end

        function createBackgroundPhaseCorrectionButton(app)
            app.BackgroundPhaseCorrectionButton = uibutton(app.ChildGridLayout2, 'push');
            app.BackgroundPhaseCorrectionButton.Layout.Row = 1;
            app.BackgroundPhaseCorrectionButton.Layout.Column = 1;
            app.BackgroundPhaseCorrectionButton.Text = 'Background Phase Correction';
            app.BackgroundPhaseCorrectionButton.FontWeight = 'bold';
            app.BackgroundPhaseCorrectionButton.ButtonPushedFcn = createCallbackFcn(app, @backgroundPhaseCorrectionButtonPushed, true);
        end

        function createDrawROIButton(app)
            app.DrawROIButton = uibutton(app.ChildGridLayout2, 'push');
            app.DrawROIButton.Layout.Row = 1;
            app.DrawROIButton.Layout.Column = 2;
            app.DrawROIButton.Text = 'Draw ROI';
            app.DrawROIButton.FontWeight = 'bold';
            app.DrawROIButton.ButtonPushedFcn = createCallbackFcn(app, @drawROIButtonPushed, true);
        end

        function createViewParametricMapButton(app)
            app.ViewParametricMapButton = uibutton(app.ChildGridLayout2, 'push');
            app.ViewParametricMapButton.Layout.Row = 1;
            app.ViewParametricMapButton.Layout.Column = 3;
            app.ViewParametricMapButton.Text = 'View Parametric Map';
            app.ViewParametricMapButton.FontWeight = 'bold';
            app.ViewParametricMapButton.ButtonPushedFcn = createCallbackFcn(app, @viewParametricMapButtonPushed, true);
        end

        function createFeatureExtractionButton(app)
            app.FeatureExtractionButton = uibutton(app.ChildGridLayout2, 'push');
            app.FeatureExtractionButton.Layout.Row = 1;
            app.FeatureExtractionButton.Layout.Column = 4;
            app.FeatureExtractionButton.Text = 'Feature Extraction';
            app.FeatureExtractionButton.FontWeight = 'bold';
            app.FeatureExtractionButton.ButtonPushedFcn = createCallbackFcn(app, @featureExtractionButtonPushed, true);
        end

        function createVesselSelectionButton(app)
            app.VesselSelectionButton = uibutton(app.ChildGridLayout2, 'push');
            app.VesselSelectionButton.Layout.Row = 1;
            app.VesselSelectionButton.Layout.Column = 5;
            app.VesselSelectionButton.Text = 'Vessel Selection';
            app.VesselSelectionButton.FontWeight = 'bold';
            app.VesselSelectionButton.ButtonPushedFcn = createCallbackFcn(app, @vesselSelectionButtonPushed, true);
        end

        function createSegmentVesselButton(app)
            app.SegmentVesselsButton = uibutton(app.ChildGridLayout2, 'push');
            app.SegmentVesselsButton.Layout.Row = 1;
            app.SegmentVesselsButton.Layout.Column = 6;
            app.SegmentVesselsButton.Text = 'Segment Vessels';
            app.SegmentVesselsButton.FontWeight = 'bold';
            app.SegmentVesselsButton.ButtonPushedFcn = createCallbackFcn(app, @segmentVesselButtonPushed, true);
        end

        function createLoadDataButton(app)
            app.LoadDataButton = uibutton(app.ChildGridLayout3, 'push');
            app.LoadDataButton.Layout.Row = 1;
            app.LoadDataButton.Layout.Column = 1;
            app.LoadDataButton.Text = 'Load Data';
            app.LoadDataButton.FontSize = 12;
            app.LoadDataButton.FontWeight = 'bold';
            app.LoadDataButton.ButtonPushedFcn = createCallbackFcn(app, @loadDataButtonPushed, true);
        end

        function createDataDirectoryLabel(app)
            app.DataDirectoryLabel = uilabel(app.ChildGridLayout4);
            app.DataDirectoryLabel.Layout.Row = 1;
            app.DataDirectoryLabel.Layout.Column = 1;
            app.DataDirectoryLabel.Text = 'Data Directory';
            app.DataDirectoryLabel.HorizontalAlignment = 'left';
        end
        
        function createDatabaseConnectionButton(app)
            app.DBConnectionButton = uibutton(app.ChildGridLayout3, 'push');
            app.DBConnectionButton.Layout.Row = 1;
            app.DBConnectionButton.Layout.Column = 6;
            app.DBConnectionButton.Text = 'DB Connection';
            app.DBConnectionButton.FontSize = 12;
            app.DBConnectionButton.FontWeight = 'bold';
            app.DBConnectionButton.ButtonPushedFcn = createCallbackFcn(app, @databaseConnectionButtonPushed, true);
        end
        
        function createDatabaseLabel(app)
            app.DatabaseLabel = uilabel(app.ChildGridLayout4);
            app.DatabaseLabel.Layout.Row = 1;
            app.DatabaseLabel.Layout.Column = 6;
            app.DatabaseLabel.Text = 'Database';
            app.DatabaseLabel.HorizontalAlignment = 'right';
        end
        
        function createDataFileOutputButton(app)
            app.DataFileOutputButton = uibutton(app.ChildGridLayout3, 'push');
            app.DataFileOutputButton.Layout.Row = 1;
            app.DataFileOutputButton.Layout.Column = 5;
            app.DataFileOutputButton.Text = 'File Output Path';
            app.DataFileOutputButton.FontSize = 12;
            app.DataFileOutputButton.FontWeight = 'bold';
            app.DataFileOutputButton.ButtonPushedFcn = createCallbackFcn(app, @dataFileOutputButtonPushed, true);
        end

        function createDataFileOutputLabel(app)
            app.DataFileOutputLabel = uilabel(app.ChildGridLayout4);
            app.DataFileOutputLabel.Layout.Row = 1;
            app.DataFileOutputLabel.Layout.Column = 5;
            app.DataFileOutputLabel.Text = '[path]';
            app.DataFileOutputLabel.HorizontalAlignment = 'right';
        end
        

    end

    % Callbacks that handle component events
    methods (Access = private)
        %{
            these functions (sans startupFcn) can take 'event' as an input
            argument
        %}
        
        % Code that executes after component creation
        function startupFcn(app)
            clc;
            app.VIPR.DataDirectory = "";
            app.VIPR.DataFileOutputDirectory = "";
            disp('Ready!');
        end

        % Button pushed function: LoadDataButton
        function loadDataButtonPushed(app, ~)
            % FLOW: load data --> perform bg PC --> perform feature
            % extraction --> open vessel selection
            dlg = uiprogressdlg(app.UIFigure);
            dlg.Title = 'Loading VIPR Data';
            dlg.Message = 'Loading...';
            dlg.Value = 0;
            dlg.ShowPercentage = 'on';
            dlg.Cancelable = 'on';
            try
                % workaround as the VIPR struct get overwritten here
                % to 'preserve' the DataFileOutputDirectory, save it
                % locally and then assign it back to the struct
                data_file_output_directory = app.VIPR.DataFileOutputDirectory;
                app.VIPR = LoadVIPR().loadVIPR(dlg, app.VIPR.DataDirectory);
                app.VIPR.DataFileOutputDirectory = data_file_output_directory;
            catch ME
                if strcmp(ME.identifier, 'LoadVIPR:getDataDirectory:cancel')
                    return;
                else
                    rethrow(ME);
                end
            end
            cla(app.Vasculature3DAxes);
            app.DataDirectoryLabel.Text = app.VIPR.DataDirectory;
            if strcmp(app.VIPR.DataFileOutputDirectory, "")
                subdir = "analysis";
                directory = fullfile(app.VIPR.DataDirectory, subdir);
                app.VIPR.DataFileOutputDirectory = directory;
            end
            app.DataFileOutputLabel.Text = app.VIPR.DataFileOutputDirectory;
            app.backgroundPhaseCorrectionButtonPushed();
            app.featureExtractionButtonPushed();
            app.vesselSelectionButtonPushed(app.VIPR);
        end

        % Button pushed function: DBConnectionButton
        function databaseConnectionButtonPushed(app, ~)
            % TODO: add menu to change/select datasource
            % to use: setup datasource with proper authentication, change
            % datasource and other database object parameters to reflect
            ds = "schrage_lab_db";
            conn = database(ds, '', '');
            if isempty(conn.Message)
                app.VIPR.Conn = conn;
                app.DatabaseLabel.Text = strcat("Connected: ", conn.DataSource);
            end
        end
        
        % Button pushed function: DataFileOutputButton
        function dataFileOutputButtonPushed(app, ~)
            % start search in DataFileOutputDirectory if defined; otherwise
            % start in the pwd
            if strcmp(app.VIPR.DataFileOutputDirectory, "")
                directory = uigetdir(app.VIPR.DataFileOutputDirectory);
            else
                directory = uigetdir();
            end
            
            % if uigetdir was not canceled
            if directory ~= 0
                subdir = "analysis";
                directory = fullfile(directory, subdir);
                % need to get the return args to suppress the warning that
                % the dir already exists
                [~, msg, msgID] = mkdir(directory);
                if ~strcmp(msgID, 'MATLAB:MKDIR:DirectoryExists')
                    error(msg);
                end
                app.VIPR.DataFileOutputDirectory = directory;
                app.DataFileOutputLabel.Text = directory;
            end
        end

        % Button pushed function: BackgroundPhaseCorrectionButton
        function backgroundPhaseCorrectionButtonPushed(app, ~)
            % TODO: wrap in a try...catch to ensure the buttons are re-enabled
            % if an error occurs
            names = fieldnames(app.VIPR);
            if ~isempty(names)
                disp('Performing background phase correction...');
                % app.changeButtonState('off');
                try
                    app.PhaseCorrectionApp = BackgroundPhaseCorrectionApp(app);
                    waitfor(app.PhaseCorrectionApp);
                    app.makeAngiogram();
                    app.viewAngiogram();
                catch ME
                    delete(app.PhaseCorrectionApp);
                    rethrow(ME);
                end
                % app.changeButtonState('on');
            end   
        end

        % Button pushed function: DrawROIButton
        function drawROIButtonPushed(app, event)
            warning('This function is not yet programmed');
        end

        % Button pushed function: ViewParametricMapButton
        function viewParametricMapButtonPushed(app, event)
            warning('This function is not yet programmed');
        end

        % Button pushed function: FeatureExtractionButton
        function featureExtractionButtonPushed(app, ~)
            names = fieldnames(app.VIPR);
            if ~isempty(names)
                % app.changeButtonState('off');
                sortingCriteria = 3;
                spurLength = 8;
                [~, branchMat, branchList, ~] = feature_extraction(sortingCriteria, spurLength, app.VIPR.VelocityMean, app.VIPR.Segment, app.VIPR.Resolution);
                app.VIPR.BranchMat = branchMat;
                app.VIPR.BranchList = branchList;
                % app.changeButtonState('on');
            else
                warning('Feature extraction already performed');
            end
        end

        % Button pushed function: VesselSelectionButton
        function vesselSelectionButtonPushed(app, ~)
%             if ~isempty(app.VesselSelectionApp)
%                 return;
%             elseif isobject(app.VesselSelectionApp)
%                 if isvalid(app.VesselSelectionApp)
%                     return;
%                 end
%             end
            
            if isfield(app.VIPR, 'BranchMat') && isfield(app.VIPR, 'BranchList')
                try
                    app.VesselSelectionApp = VesselSelectionApp(app.VIPR); %#ok<ADPROPLC>
                catch ME
                    delete(app.VesselSelectionApp);
                    rethrow(ME);
                end
            else
                error('Feature extraction has not been performed');
            end
        end

        % Button pushed function: SegmentVesselsButton
        function segmentVesselButtonPushed(app, ~)
            if isfield(app.VIPR, 'Vessel')
                if isobject(app.Vessel3DApp)
                    if isvalid(app.Vessel3DApp)
                        delete(app.Vessel3DApp);
                    end
                end
            else
                error("No vessels selected. Perform vessel selection first");
            end
            
            vesselNames = fieldnames(app.VIPR.Vessel);
            calc = calculateParameters();
            for k = 1:numel(vesselNames)
                % check if parameters already exist; if so, skip
                parameterNames = fieldnames(app.VIPR.Vessel.(vesselNames{k}));
                if any(ismember(parameterNames, 'Area'))
                    continue;
                end

                fprintf('Calculating parameters for %s...\n', string(vesselNames{k}));
                branchActual_ = app.VIPR.Vessel.(vesselNames{k}).BranchActual;
                parameters = calc.main(app.VIPR, branchActual_);
                % make anonymous fcn to concat structs
                mergeStructs = @(x,y) cell2struct([struct2cell(x);struct2cell(y)],[fieldnames(x);fieldnames(y)]);
                parameters = mergeStructs(app.VIPR.Vessel.(vesselNames{k}), parameters);
                app.VIPR.Vessel.(vesselNames{k}) = parameters;
                fprintf('Finished calculating parameters for %s...\n', string(vesselNames{k}));
            end
            fprintf('Done calculating parameter for all vessels!\n');
            
            linker = AppLinker(app.VIPR);
        end
        
        % Toolbar selection callback
        function toolbarValueChanged(app, event)
            btn = event.Source.Tag;
            if strcmpi(btn, 'restoreview')
                app.viewAngiogram();
            end
        end
        
        % Window key pressed function
        function uiWindowKeyPressFcn(app, event)
            switch char(event.Modifier)
                case 'control'
                    if strcmpi(event.Key, 'w')
                        app.uiFigureCloseRequest();
                    elseif strcmpi(event.Key, 'e')
                        app.changeButtonState('on');
                    end
            end
        end

        % Close request function: UIFigure
        function uiFigureCloseRequest(app, ~)
            if isobject(app.PhaseCorrectionApp) && isvalid(app.PhaseCorrectionApp)
                delete(app.PhaseCorrectionApp);
            end
            
            if isobject(app.VesselSelectionApp) && isvalid(app.VesselSelectionApp)
                delete(app.VesselSelectionApp);
            end
            
            if isobject(app.Vessel3DApp) && isvalid(app.Vessel3DApp)
                delete(app.Vessel3DApp);
            end
            
            delete(app);
        end
    
    end

    % general functions
    methods (Access = private)
        
        % create local db file to store data
        function makeLocalDb(app, directory)
            dbfile = fullfile(directory, 'vipr.db');
            try
                app.Conn = sqlite(dbfile, 'create');
            catch ME
                if strcmp(ME.identifier, 'database:sqlite:fileExists')
                    app.Conn = sqlite(dbfile, 'connect');
                else
                    rethrow(ME);
                end
            end
        end
        
        function viewAngiogram(app)
            disp('View 3D Vasculature');
            mxStart = 1; 
            myStart = 1; 
            mzStart = 1;
            mxStop = app.VIPR.Resolution; 
            myStop = app.VIPR.Resolution;
            mzStop = app.VIPR.Resolution;
            view(app.Vasculature3DAxes, [-.5 0 0]);
            app.Vasculature3DAxes.DataAspectRatio = [1 1 1];
            app.Vasculature3DAxes.XLim = [myStart myStop];
            app.Vasculature3DAxes.YLim = [mxStart mxStop];
            app.Vasculature3DAxes.ZLim = [mzStart mzStop];
        end
        
        function makeAngiogram(app)
            vasculaturePatch = patch(app.Vasculature3DAxes, isosurface(app.VIPR.Segment, 0.5));
            vasculaturePatch.FaceColor = 'red';
            vasculaturePatch.EdgeColor = 'None';
            reducepatch(vasculaturePatch, 0.6);
            vasculaturePatch.FaceAlpha = 0.4;
        end
        
        function changeButtonState(app, state)
            % state must be "on" or "off"
            options = ["on", "off"];
            if ~ismember(string(state), options)
                ME = MException("CenterlineToolApp:StateButton:InvalidOption", "Invalid option '%s'.\nOption must be 'on' or 'off'", string(state));
                throw(ME)
            end
            app.LoadDataButton.Enable = state;
            app.DBConnectionButton.Enable = state;
            app.BackgroundPhaseCorrectionButton.Enable = state;
            app.DrawROIButton.Enable = state;
            app.ViewParametricMapButton.Enable = state;
            app.FeatureExtractionButton.Enable = state;
            app.VesselSelectionButton.Enable = state;
            app.SegmentVesselsButton.Enable = state;
        end
        
    end

end