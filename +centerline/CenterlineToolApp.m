classdef CenterlineToolApp < matlab.apps.AppBase % & PropertyValidation

    %{
        The first step in PC VIPR post-processing
        INPUT: None
        OUTPUT: None
    
        the VIPR structure is the main data structure that will contain all necessary data for
        the processing stream
    %}
    
    % Properties that correspond to app components
    properties (Access = private)
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
        Vasculature3DAxesTB;
    end
    
    properties (GetAccess = public, SetAccess = private)
        VIPR            struct;
        SortingCriteria (1,1) double{mustBeInteger} = 3;
        SpurLength      (1,1) double{mustBeInteger} = 8;
    end
    
    % private properties (i.e. those that are contained in this GUI)
    properties (Access = private)
        % child GUIs
        PhaseCorrectionApp  BackgroundPhaseCorrectionApp;
        VesselSelectionApp  VesselSelectionApp;
        Vessel3DApp         Vessel3DApp;
    end
    
    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = CenterlineToolApp()
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
            app.ChildGridLayout3.ColumnWidth = {'1x', '3x', '1x'};
            app.ChildGridLayout3.RowHeight = {'1x'};
        end
        
        function createChildGrid4(app)
            % bottom row container within ChildGridLayout1 to house labels
            app.ChildGridLayout4 = uigridlayout(app.ChildGridLayout1);
            app.ChildGridLayout4.Layout.Row = 2;
            app.ChildGridLayout4.Layout.Column = 1;
            app.ChildGridLayout4.ColumnWidth = {'1x', '1x'};
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

        function createDatabaseConnectionButton(app)
            app.DBConnectionButton = uibutton(app.ChildGridLayout3, 'push');
            app.DBConnectionButton.Layout.Row = 1;
            app.DBConnectionButton.Layout.Column = 3;
            app.DBConnectionButton.Text = 'DB Connection';
            app.DBConnectionButton.FontSize = 12;
            app.DBConnectionButton.FontWeight = 'bold';
            app.DBConnectionButton.ButtonPushedFcn = createCallbackFcn(app, @databaseConnectionButtonPushed, true);
        end

        function createDataDirectoryLabel(app)
            app.DataDirectoryLabel = uilabel(app.ChildGridLayout4);
            app.DataDirectoryLabel.Layout.Row = 1;
            app.DataDirectoryLabel.Layout.Column = 1;
            app.DataDirectoryLabel.Text = 'Data Directory';
            app.DataDirectoryLabel.HorizontalAlignment = 'left';
        end

        function createDatabaseLabel(app)
            app.DatabaseLabel = uilabel(app.ChildGridLayout4);
            app.DatabaseLabel.Layout.Row = 1;
            app.DatabaseLabel.Layout.Column = 2;
            app.DatabaseLabel.Text = 'Database';
            app.DatabaseLabel.HorizontalAlignment = 'right';
        end            

    end

    % general methods, private
    methods (Access = private)
        
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
    
    % general methods, public
    methods (Access = public)
        
        function setPhaseCorrectionParameters(app, velocityMean, angiogram, segment)
            app.VIPR.VelocityMean = velocityMean;
            app.VIPR.TimeMIP = angiogram;
            app.VIPR.Segment = segment;
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
            disp('Ready!');
        end

        % Button pushed function: LoadDataButton
        function loadDataButtonPushed(app, ~)
            try
                dlg = uiprogressdlg(app.UIFigure);
                dlg.Title = 'Loading VIPR Data';
                dlg.Message = 'Loading...';
                dlg.Value = 0;
                dlg.ShowPercentage = 'on';
                dlg.Cancelable = 'on';
                data = LoadVIPR(dlg);
                app.VIPR = data.getStruct();
            catch ME
                if strcmp(ME.identifier, 'LoadVIPR:getDataDirectory:cancel')
                    return;
                else
                    rethrow(ME);
                end
            end

            cla(app.Vasculature3DAxes);
            app.DataDirectoryLabel.Text = app.VIPR.DataDirectory;
        end

        % Button pushed function: DBConnectionButton
        function databaseConnectionButtonPushed(app, ~)
            warning('This function is not yet programmed');
            app.DatabaseLabel.Text = "This.is.where.db.connection.would.be";
        end

        % Button pushed function: BackgroundPhaseCorrectionButton
        function backgroundPhaseCorrectionButtonPushed(app, ~)
            names = fieldnames(app.VIPR);
            if ~isempty(names)
                disp('Performing background phase correction...');
                try
                    app.PhaseCorrectionApp = BackgroundPhaseCorrectionApp(app);
                    waitfor(app.PhaseCorrectionApp);
                    app.makeAngiogram();
                    app.viewAngiogram();
                catch ME
                    delete(app.PhaseCorrectionApp);
                    rethrow(ME);
                end
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
            if ~isfield(app.VIPR, 'BranchMat') && ~isfield(app.VIPR, 'BranchList')
                [~, branchMat, branchList, ~] = feature_extraction(app.SortingCriteria, app.SpurLength, app.VIPR.VelocityMean, app.VIPR.Segment, app.VIPR.Resolution);
                app.VIPR.BranchMat = branchMat;
                app.VIPR.BranchList = branchList;
            else
                warning('Feature extraction already performed');
            end
        end

        % Button pushed function: VesselSelectionButton
        function vesselSelectionButtonPushed(app, ~)
            if ~isempty(app.VesselSelectionApp)
                return;
            elseif isobject(app.VesselSelectionApp)
                if isvalid(app.VesselSelectionApp)
                    return;
                end
            end
            
            if isfield(app.VIPR, 'BranchMat') && isfield(app.VIPR, 'BranchList')
                try
                    app.VesselSelectionApp = VesselSelectionApp(app); %#ok<ADPROPLC>
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
                        return;
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
            
            % TODO: wrap in try/catch to delete GUIs if error
            linker = AppLinker(app.VIPR, @ParameterPlotApp);
            app.Vessel3DApp = Vessel3DApp(app.VIPR, linker);
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
                    end
            end
        end

        % Close request function: UIFigure
        function uiFigureCloseRequest(app, ~)
            if isobject(app.PhaseCorrectionApp)
                if isvalid(app.PhaseCorrectionApp)
                    delete(app.PhaseCorrectionApp);
                end
            end
            
            if isobject(app.VesselSelectionApp) 
                if isvalid(app.VesselSelectionApp)
                    delete(app.VesselSelectionApp);
                end
            end
            
            if isobject(app.Vessel3DApp)
                if isvalid(app.Vessel3DApp)
                    delete(app.Vessel3DApp);
                end
            end
            
            delete(app);
        end
    
    end

end