classdef View < centerlineapp.base.view.View
    
    properties (GetAccess = public, SetAccess = private)
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
        restoreViewBtn;
        CLModel;
    end
    
    % Entry point
    methods (Access = public)

        % Construct app
        function app = View(model)
            
            % Create UIFigure and components
            app.createComponents()

            % Register the app with App Designer
            app.registerApp(app.UIFigure)

            % Execute the startup function
            app.runStartupFcn(@(app)startupFcn(app, model));

            if nargout == 0
                clear app
            end
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
%             app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @uiFigureCloseRequest, true);
%             app.UIFigure.WindowKeyPressFcn = createCallbackFcn(app, @uiWindowKeyPressFcn, true);
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
            app.restoreViewBtn = axtoolbarbtn(app.Vasculature3DAxesTB, 'push');
            app.restoreViewBtn.Tag = 'restoreview';
            app.restoreViewBtn.Icon = 'restoreview';
%             app.restoreViewBtn.ButtonPushedFcn = app.createCallbackFcn(@toolbarValueChanged, true);
        end

        function createBackgroundPhaseCorrectionButton(app)
            app.BackgroundPhaseCorrectionButton = uibutton(app.ChildGridLayout2, 'push');
            app.BackgroundPhaseCorrectionButton.Layout.Row = 1;
            app.BackgroundPhaseCorrectionButton.Layout.Column = 1;
            app.BackgroundPhaseCorrectionButton.Text = 'Background Phase Correction';
            app.BackgroundPhaseCorrectionButton.FontWeight = 'bold';
%             app.BackgroundPhaseCorrectionButton.ButtonPushedFcn = createCallbackFcn(app, @backgroundPhaseCorrectionButtonPushed, true);
        end

        function createDrawROIButton(app)
            app.DrawROIButton = uibutton(app.ChildGridLayout2, 'push');
            app.DrawROIButton.Layout.Row = 1;
            app.DrawROIButton.Layout.Column = 2;
            app.DrawROIButton.Text = 'Draw ROI';
            app.DrawROIButton.FontWeight = 'bold';
%             app.DrawROIButton.ButtonPushedFcn = createCallbackFcn(app, @drawROIButtonPushed, true);
        end

        function createViewParametricMapButton(app)
            app.ViewParametricMapButton = uibutton(app.ChildGridLayout2, 'push');
            app.ViewParametricMapButton.Layout.Row = 1;
            app.ViewParametricMapButton.Layout.Column = 3;
            app.ViewParametricMapButton.Text = 'View Parametric Map';
            app.ViewParametricMapButton.FontWeight = 'bold';
%             app.ViewParametricMapButton.ButtonPushedFcn = createCallbackFcn(app, @viewParametricMapButtonPushed, true);
        end

        function createFeatureExtractionButton(app)
            app.FeatureExtractionButton = uibutton(app.ChildGridLayout2, 'push');
            app.FeatureExtractionButton.Layout.Row = 1;
            app.FeatureExtractionButton.Layout.Column = 4;
            app.FeatureExtractionButton.Text = 'Feature Extraction';
            app.FeatureExtractionButton.FontWeight = 'bold';
%             app.FeatureExtractionButton.ButtonPushedFcn = createCallbackFcn(app, @featureExtractionButtonPushed, true);
        end

        function createVesselSelectionButton(app)
            app.VesselSelectionButton = uibutton(app.ChildGridLayout2, 'push');
            app.VesselSelectionButton.Layout.Row = 1;
            app.VesselSelectionButton.Layout.Column = 5;
            app.VesselSelectionButton.Text = 'Vessel Selection';
            app.VesselSelectionButton.FontWeight = 'bold';
%             app.VesselSelectionButton.ButtonPushedFcn = createCallbackFcn(app, @vesselSelectionButtonPushed, true);
        end

        function createSegmentVesselButton(app)
            app.SegmentVesselsButton = uibutton(app.ChildGridLayout2, 'push');
            app.SegmentVesselsButton.Layout.Row = 1;
            app.SegmentVesselsButton.Layout.Column = 6;
            app.SegmentVesselsButton.Text = 'Segment Vessels';
            app.SegmentVesselsButton.FontWeight = 'bold';
%             app.SegmentVesselsButton.ButtonPushedFcn = createCallbackFcn(app, @segmentVesselButtonPushed, true);
        end

        function createLoadDataButton(app)
            app.LoadDataButton = uibutton(app.ChildGridLayout3, 'push');
            app.LoadDataButton.Layout.Row = 1;
            app.LoadDataButton.Layout.Column = 1;
            app.LoadDataButton.Text = 'Load Data';
            app.LoadDataButton.FontSize = 12;
            app.LoadDataButton.FontWeight = 'bold';
%             app.LoadDataButton.ButtonPushedFcn = createCallbackFcn(app, @loadDataButtonPushed, true);
        end

        function createDatabaseConnectionButton(app)
            app.DBConnectionButton = uibutton(app.ChildGridLayout3, 'push');
            app.DBConnectionButton.Layout.Row = 1;
            app.DBConnectionButton.Layout.Column = 3;
            app.DBConnectionButton.Text = 'DB Connection';
            app.DBConnectionButton.FontSize = 12;
            app.DBConnectionButton.FontWeight = 'bold';
%             app.DBConnectionButton.ButtonPushedFcn = createCallbackFcn(app, @databaseConnectionButtonPushed, true);
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

    methods (Access = private)
        
        function startupFcn(app, model)
            app.CLModel = model;
            
            % create listener to update angiogram
            addlistener(app.CLModel, 'Segment', 'PostSet', @app.updateAngio);
            
            clc;
            disp('Ready!');
        end
        
    end
    
    methods (Access = public)
        
        function clearAxes(app)
            cla(app.Vasculature3DAxes);
        end
        
        function updateAngio(app, src, evt)
            app.makeAngiogram();
            app.viewAngiogram();
        end
        
        function viewAngiogram(app)
            % disp('View 3D Vasculature');
            mxStart = 1; 
            myStart = 1; 
            mzStart = 1;
            mxStop = app.CLModel.Res; 
            myStop = app.CLModel.Res;
            mzStop = app.CLModel.Res;
            view(app.Vasculature3DAxes, [-.5 0 0]);
            app.Vasculature3DAxes.DataAspectRatio = [1 1 1];
            app.Vasculature3DAxes.XLim = [myStart myStop];
            app.Vasculature3DAxes.YLim = [mxStart mxStop];
            app.Vasculature3DAxes.ZLim = [mzStart mzStop];
        end
        
        function makeAngiogram(app)
            angio = patch(app.Vasculature3DAxes, isosurface(app.CLModel.Segment, 0.5));
            angio.FaceColor = 'red';
            angio.EdgeColor = 'None';
            reducepatch(angio, 0.6);
            angio.FaceAlpha = 0.4;
        end
        
        function updateDataDirLbl(app, txt)
            app.DataDirectoryLabel.Text = txt;
        end
        
        function updateDBLbl(app, txt)
            app.DatabaseLabel.Text = txt;
        end
    
    end
  
end
