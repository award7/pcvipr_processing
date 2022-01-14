classdef Vessel3DApp < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = private)
        UIFigure                matlab.ui.Figure;
        ParentGridLayout        matlab.ui.container.GridLayout;
        ChildGridLayout1        matlab.ui.container.GridLayout;
        ChildGridLayout2        matlab.ui.container.GridLayout;
        ChildGridLayout3        matlab.ui.container.GridLayout;
        VasculatureAxes         matlab.ui.control.UIAxes;
        VesselDropDown          matlab.ui.control.DropDown;
        IsolateButton           matlab.ui.control.StateButton;
        LowerVoxelLabel         matlab.ui.control.Label;
        WindowLabel             matlab.ui.control.Label;
        LowerVoxelSlider        matlab.ui.control.Slider;
        WindowSlider            matlab.ui.control.Slider;
        LowerVoxelSpinner       matlab.ui.control.Spinner;
        WindowSpinner           matlab.ui.control.Spinner;
        VasculatureAxesTB;
        FullVasculaturePatch;
        ITPlane;
        VIPR;
        Linker;
    end
    
    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Vessel3DApp(varargin)
            
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
            app.createParentGrid();
            app.createChildGrid1();
            app.createChildGrid2();
            app.createChildGrid3();
            app.createVasculatureAxes();
            app.createVasculatureAxes_tb();
            app.createVesselDropdown();
            app.createIsolateButton();
            app.createLowerVoxelLabel();
            app.createWindowLabel();
            app.createLowerVoxelSlider();
            app.createWindowSlider();
            app.createLowerVoxelSpinner();
            app.createWindowSpinner();

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
        
        function createFigure(app)
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Name = 'Vessel 3D';
            app.UIFigure.WindowState = 'maximized';
            app.UIFigure.CloseRequestFcn = app.createCallbackFcn(@uiFigureCloseRequest, true);
            app.UIFigure.WindowKeyPressFcn = app.createCallbackFcn(@uiWindowKeyPressFcn, true);
        end
        
        function createParentGrid(app)
            app.ParentGridLayout = uigridlayout(app.UIFigure);
            app.ParentGridLayout.ColumnWidth = {'1x'};
            app.ParentGridLayout.RowHeight = {'5x', '1x'};
        end
        
        function createChildGrid1(app)
            app.ChildGridLayout1 = uigridlayout(app.ParentGridLayout);
            app.ChildGridLayout1.Layout.Row = 2;
            app.ChildGridLayout1.Layout.Column = 1;
        end
        
        function createChildGrid2(app)
            app.ChildGridLayout2 = uigridlayout(app.ChildGridLayout1);
            app.ChildGridLayout2.ColumnWidth = {'1x', '3x', '1x'};
            app.ChildGridLayout2.RowHeight = {'1x'};
            app.ChildGridLayout2.Layout.Row = 1;
            app.ChildGridLayout2.Layout.Column = 2;
        end
        
        function createChildGrid3(app)
            app.ChildGridLayout3 = uigridlayout(app.ChildGridLayout1);
            app.ChildGridLayout3.ColumnWidth = {'1x', '3x', '1x'};
            app.ChildGridLayout3.RowHeight = {'1x'};
            app.ChildGridLayout3.Layout.Row = 2;
            app.ChildGridLayout3.Layout.Column = 2;
        end
        
        function createVasculatureAxes(app)
            app.VasculatureAxes = uiaxes(app.ParentGridLayout);
            title(app.VasculatureAxes, '')
            xlabel(app.VasculatureAxes, '')
            ylabel(app.VasculatureAxes, '')
            app.VasculatureAxes.Layout.Row = 1;
            app.VasculatureAxes.Layout.Column = 1;
            app.VasculatureAxes.PlotBoxAspectRatio = [1.6 1 1];
            app.VasculatureAxes.XTick = [];
            app.VasculatureAxes.YTick = [];
            app.VasculatureAxes.ZTick = [];
            app.VasculatureAxes.XAxis.Visible = 'off';
            app.VasculatureAxes.YAxis.Visible = 'off';
            app.VasculatureAxes.ZAxis.Visible = 'off';
            app.VasculatureAxes.Color = app.UIFigure.Color;
            app.VasculatureAxes.DataAspectRatio = [1 1 1];
            app.VasculatureAxes.ZDir = 'reverse';
            axis(app.VasculatureAxes, 'vis3d');
        end
        
        function createVasculatureAxes_tb(app)
            app.VasculatureAxesTB = axtoolbar(app.VasculatureAxes, {'zoomin', 'zoomout', 'export', 'rotate'});
            restoreViewButtotn = axtoolbarbtn(app.VasculatureAxesTB, 'push');
            restoreViewButtotn.Tag = 'restoreview';
            restoreViewButtotn.Icon = 'restoreview';
            restoreViewButtotn.ButtonPushedFcn = app.createCallbackFcn(@toolbarValueChanged, true);
        end
        
        function createVesselDropdown(app)
            app.VesselDropDown = uidropdown(app.ChildGridLayout1);
            app.VesselDropDown.Layout.Row = 1;
            app.VesselDropDown.Layout.Column = 1;
            app.VesselDropDown.ValueChangedFcn = app.createCallbackFcn(@vesselDropdownValueChanged, true);
        end
        
        function createIsolateButton(app)
            app.IsolateButton = uibutton(app.ChildGridLayout1, 'state');
            app.IsolateButton.Text = 'Isolate Vessel';
            app.IsolateButton.Layout.Row = 2;
            app.IsolateButton.Layout.Column = 1;
            app.IsolateButton.Value = false;
            app.IsolateButton.ValueChangedFcn = app.createCallbackFcn(@isolateButtonValueChanged, true);
        end
        
        function createLowerVoxelLabel(app)
            app.LowerVoxelLabel = uilabel(app.ChildGridLayout2);
            app.LowerVoxelLabel.Layout.Row = 1;
            app.LowerVoxelLabel.Layout.Column = 1;
            app.LowerVoxelLabel.Text = 'Lower Voxel';
        end
        
        function createWindowLabel(app)
            app.WindowLabel = uilabel(app.ChildGridLayout3);
            app.WindowLabel.Layout.Row = 1;
            app.WindowLabel.Layout.Column = 1;
            app.WindowLabel.Text = 'Window';
        end
        
        function createLowerVoxelSlider(app)
            app.LowerVoxelSlider = uislider(app.ChildGridLayout2);
            app.LowerVoxelSlider.MajorTicks = [];
            app.LowerVoxelSlider.MinorTicks = [];
            app.LowerVoxelSlider.Layout.Row = 1;
            app.LowerVoxelSlider.Layout.Column = 2;
            app.LowerVoxelSlider.Limits = [1 100];
            app.LowerVoxelSlider.Value = 1;
            app.LowerVoxelSlider.ValueChangedFcn = app.createCallbackFcn(@lowerVoxelValueChanged, true);
            app.LowerVoxelSlider.ValueChangingFcn = app.createCallbackFcn(@lowerVoxelValueChanged, true);
        end
        
        function createWindowSlider(app)
            app.WindowSlider = uislider(app.ChildGridLayout3);
            app.WindowSlider.MajorTicks = [];
            app.WindowSlider.MinorTicks = [];
            app.WindowSlider.Layout.Row = 1;
            app.WindowSlider.Layout.Column = 2;
            app.WindowSlider.Limits = [1 100];
            app.WindowSlider.Value = 5;
            app.WindowSlider.ValueChangedFcn = app.createCallbackFcn(@windowValueChanged, true);
            app.WindowSlider.ValueChangingFcn = app.createCallbackFcn(@windowValueChanged, true);
        end
        
        function createLowerVoxelSpinner(app)
            app.LowerVoxelSpinner = uispinner(app.ChildGridLayout2);
            app.LowerVoxelSpinner.Layout.Row = 1;
            app.LowerVoxelSpinner.Layout.Column = 3;
            app.LowerVoxelSpinner.Limits = [1 100];
            app.LowerVoxelSpinner.Step = 1;
            app.LowerVoxelSpinner.Value = 1;
            app.LowerVoxelSpinner.ValueChangedFcn = app.createCallbackFcn(@lowerVoxelValueChanged, true);
        end
        
        function createWindowSpinner(app)
            app.WindowSpinner = uispinner(app.ChildGridLayout3);
            app.WindowSpinner.Layout.Row = 1;
            app.WindowSpinner.Layout.Column = 3;
            app.WindowSpinner.Limits = [1 100];
            app.WindowSpinner.Step = 1;
            app.WindowSpinner.Value = 5;
            app.WindowSpinner.ValueChangedFcn = app.createCallbackFcn(@windowValueChanged, true);
        end
         
    end

    % Linker components
    methods (Access = public)
       
        function updateLowerVoxelComponents(app, value)
            app.LowerVoxelSpinner.Value = value;
            app.LowerVoxelSlider.Value = value;
            app.deletePlane();
            app.addPlane();
        end
        
        function updateWindowComponents(app, windowValue, upperLimit)
            app.WindowSpinner.Value = windowValue;
            app.LowerVoxelSpinner.Limits(2) = upperLimit;
            app.LowerVoxelSlider.Limits(2) = upperLimit;
            app.deletePlane();
            app.addPlane();
        end
        
    end
        
    % general methods
    methods (Access = private)
        
        function populateDropdown(app)
            names = fieldnames(app.VIPR.Vessel);
            app.VesselDropDown.Items = names;
            app.VesselDropDown.Value = names{1};
        end
        
        function viewSegmentedVasculature(app)
            mxStart = 1;
            myStart = 1;
            mzStart = 1;
            mxStop = app.VIPR.Resolution;
            myStop = app.VIPR.Resolution;
            mzStop = app.VIPR.Resolution;
            app.VasculatureAxes.XLim = [mxStart mxStop];
            app.VasculatureAxes.YLim = [myStart myStop];
            app.VasculatureAxes.ZLim = [mzStart mzStop];
            view(app.VasculatureAxes, [-0.5 0 0]);
        end
        
        function plotFullVasculature(app)
            app.FullVasculaturePatch = patch(app.VasculatureAxes, isosurface(app.VIPR.Segment, 0.5));
            app.FullVasculaturePatch.FaceColor = 'k';
            app.FullVasculaturePatch.EdgeColor = 'none';
            app.FullVasculaturePatch.FaceAlpha = 0.1;
        end
        
        function plotSegmentedVessel(app)
            vessel = app.VesselDropDown.Value;
            fprintf('Visualizing segmented %s in 3D...\n', string(vessel));
            delete(findobj(app.VasculatureAxes, 'Type', 'Patch', '-regexp', 'Tag', 'vessel'));
            delete(findobj(app.VasculatureAxes, 'Type', 'Text'));

            VesselPatch = patch(app.VasculatureAxes, isosurface(app.VIPR.Vessel.(vessel).TimeMIPVessel, 0.25));
            VesselPatch.FaceColor = 'r';
            VesselPatch.EdgeColor = 'none';
            VesselPatch.FaceAlpha = 0.4;
            VesselPatch.Tag = 'vessel';
        end
        
        function addVoxelLabels(app)
            vessel = app.VesselDropDown.Value;
            num = 0;
            hold(app.VasculatureAxes, 'On');
            for k = 1:numel(app.VIPR.Vessel.(vessel).BranchActual(:,1))
                num = num + 1;
                if mod(num-2, 5) == 0
                    stringval = {num2str(num-2)};
                    x = app.VIPR.Vessel.(vessel).BranchActual(k,2);
                    y = app.VIPR.Vessel.(vessel).BranchActual(k,1);
                    z = app.VIPR.Vessel.(vessel).BranchActual(k,3);
                    txt = text(app.VasculatureAxes, x, y, z, stringval);
                    txt.Color = 'b';
                end
            end
            hold(app.VasculatureAxes, 'Off');
        end
        
        function deletePlane(app)
            delete(findobj(app.VasculatureAxes, 'Type', 'Patch', '-regexp', 'Tag', 'plane.*?'));
        end
        
        function addPlane(app)
            vessel = app.VesselDropDown.Value;
            window = app.WindowSpinner.Value;
            voxelNo = app.LowerVoxelSpinner.Value;
            
            % need to offset this; don't know why but was in older code
            offset = 1;
            for windowSlice = 0:window-1
                coordinates = app.VIPR.Vessel.(vessel).BranchActual(voxelNo + offset + windowSlice, :);
                coordinates = floor(coordinates);
                x = coordinates(1);
                y = coordinates(2); 
                z = coordinates(3);
                
                branchList = app.VIPR.BranchList;
                findX = find(branchList(:, 1) == x);
                findY = find(branchList(findX, 2) == y);
                findZ = find(branchList(findX(findY), 3) == z);
                idx = findX(findY(findZ));
                
                hold(app.VasculatureAxes, 'on');
                % x & y are switched for some reason
                plane = fill3(app.VasculatureAxes, ...
                                    app.ITPlane.plane_y(idx, :)', ...
                                    app.ITPlane.plane_x(idx, :)', ...
                                    app.ITPlane.plane_z(idx, :)', ...
                                    [0 0 0]);
                plane.EdgeColor = [0 0 0];
                plane.FaceAlpha = 0.3;
                plane.PickableParts = 'none';
                planeNo = ['plane' num2str(windowSlice)];
                plane.Tag = planeNo;
                hold(app.VasculatureAxes, 'off'); 
            end
        end
        
    end

    % Component callbacks
    methods (Access = private)
        
        % Code that executes after component creation
        function startupFcn(app, varargin)
            app.Linker = varargin{1};
            app.VIPR = varargin{2};
            
            app.ITPlane = makeITPlane(app.VIPR.BranchList);
            app.populateDropdown();
            app.plotFullVasculature();
            app.vesselDropdownValueChanged();
        end
        
        % Value changed function: LowerVoxelSpinner
        function lowerVoxelValueChanged(app, event)
            windowValue = app.WindowSpinner.Value;
            windowLimit = app.WindowSpinner.Limits(2);
            app.Linker.voxelChanged(event, windowValue, windowLimit);
        end
        
        % Value changed function: WindowSpinner
        function windowValueChanged(app, event)
            windowLimit = app.WindowSpinner.Limits(2);
            app.Linker.windowChanged(event, windowLimit);
        end

        % Value changed function: IsolateVesselSegmentSwitch
        function isolateButtonValueChanged(app, ~)
            value = app.IsolateButton.Value;
            switch value
                case 1
                    app.FullVasculaturePatch.Visible = 'Off';
                case 0
                    app.FullVasculaturePatch.Visible = 'On';
            end
        end

        % Value changed function: VesselDropDown
        function vesselDropdownValueChanged(app, ~)
            app.plotSegmentedVessel();
            app.LowerVoxelSpinner.Value = 1;
            app.LowerVoxelSlider.Value = 1;
            vessel = app.VesselDropDown.Value;
            if length(app.VIPR.Vessel.(vessel).BranchActual) < 5
                app.WindowSpinner.Value = length(app.VIPR.Vessel.(vessel).BranchActual);
                app.WindowSlider.Value = length(app.VIPR.Vessel.(vessel).BranchActual);
            else
                app.WindowSpinner.Value = 5;
                app.WindowSlider.Value = 5;
            end
            app.addVoxelLabels();
            app.deletePlane();
            app.addPlane();
            app.viewSegmentedVasculature();
            
            % change spinner limits
            upperLimitWindow = length(app.VIPR.Vessel.(vessel).BranchActual) - 2;
            app.WindowSpinner.Limits = [1 upperLimitWindow];
            app.WindowSlider.Limits = [1 upperLimitWindow];
            % app.ParameterPlotApp.update_spinner_limits();
        end

        % Toolbar selection callback
        function toolbarValueChanged(app, event)
            btn = event.Source.Tag;
            if strcmpi(btn, 'restoreview')
                app.viewSegmentedVasculature();
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
        
        % Close request function: vessel3D
        function uiFigureCloseRequest(app, ~)
            app.Linker.closeRequest();
        end
                
    end

end