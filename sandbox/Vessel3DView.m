classdef Vessel3DView < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = private)
        UIFigure                matlab.ui.Figure;
        ParentGrid              matlab.ui.container.GridLayout;
        ChildGrid1              matlab.ui.container.GridLayout;
        ChildGrid2              matlab.ui.container.GridLayout;
        ChildGrid3              matlab.ui.container.GridLayout;
        VasculatureAxes         matlab.ui.control.UIAxes;
        VesselDropDown          matlab.ui.control.DropDown;
        IsolateButton           matlab.ui.control.StateButton;
        LowerVoxelLabel         matlab.ui.control.Label;
        WindowLabel             matlab.ui.control.Label;
        LowerVoxelSlider        matlab.ui.control.Slider;
        WindowSlider            matlab.ui.control.Slider;
        LowerVoxelSpinner       matlab.ui.control.Spinner;
        WindowSpinner           matlab.ui.control.Spinner;
        VasculatureAxesToolbar;
        FullVasculaturePatch;
        ITPlane;
    end
    
    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Vessel3DView(controller)
            app.UIFigure = controller.View.UIFigure;
            app.createComponents(controller);
        end
        
    end
    
    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app, controller)
            app.createParentGrid();
            app.createChildGrid1();
            app.createChildGrid2();
            app.createChildGrid3();
            app.createVasculatureAxes();
            app.createVasculatureAxesToolbar(controller);
            app.createVesselDropdown(controller);
            app.createIsolateButton(controller);
            app.createLowerVoxelLabel();
            app.createWindowLabel();
            app.createLowerVoxelSlider(controller);
            app.createWindowSlider(controller);
            app.createLowerVoxelSpinner(controller);
            app.createWindowSpinner(controller);
        end
        
        function createParentGrid(app)
            app.ParentGrid = uigridlayout(app.UIFigure);
            app.ParentGrid.ColumnWidth = {'1x'};
            app.ParentGrid.RowHeight = {'5x', '1x'};
        end
        
        function createChildGrid1(app)
            app.ChildGrid1 = uigridlayout(app.ParentGrid);
            app.ChildGrid1.Layout.Row = 2;
            app.ChildGrid1.Layout.Column = 1;
        end
        
        function createChildGrid2(app)
            app.ChildGrid2 = uigridlayout(app.ChildGrid1);
            app.ChildGrid2.ColumnWidth = {'1x', '3x', '1x'};
            app.ChildGrid2.RowHeight = {'1x'};
            app.ChildGrid2.Layout.Row = 1;
            app.ChildGrid2.Layout.Column = 2;
        end
        
        function createChildGrid3(app)
            app.ChildGrid3 = uigridlayout(app.ChildGrid1);
            app.ChildGrid3.ColumnWidth = {'1x', '3x', '1x'};
            app.ChildGrid3.RowHeight = {'1x'};
            app.ChildGrid3.Layout.Row = 2;
            app.ChildGrid3.Layout.Column = 2;
        end
        
        function createVasculatureAxes(app)
            app.VasculatureAxes = uiaxes(app.ParentGrid);
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
        
        function createVasculatureAxesToolbar(app, controller)
            app.VasculatureAxesToolbar = axtoolbar(app.VasculatureAxes, {'zoomin', 'zoomout', 'export', 'rotate'});
            restoreViewButtotn = axtoolbarbtn(app.VasculatureAxesToolbar, 'push');
            restoreViewButtotn.Tag = 'restoreview';
            restoreViewButtotn.Icon = 'restoreview';
            restoreViewButtotn.ButtonPushedFcn = app.createCallbackFcn(@controller.vs3dToolbarValueChangedCallback, true);
        end
        
        function createVesselDropdown(app, controller)
            app.VesselDropDown = uidropdown(app.ChildGrid1);
            app.VesselDropDown.Layout.Row = 1;
            app.VesselDropDown.Layout.Column = 1;
            app.VesselDropDown.ValueChangedFcn = app.createCallbackFcn(@controller.vs3dVesselDropdownValueChanged, true);
        end
        
        function createIsolateButton(app, controller)
            app.IsolateButton = uibutton(app.ChildGrid1, 'state');
            app.IsolateButton.Text = 'Isolate Vessel';
            app.IsolateButton.Layout.Row = 2;
            app.IsolateButton.Layout.Column = 1;
            app.IsolateButton.Value = false;
            app.IsolateButton.ValueChangedFcn = app.createCallbackFcn(@controller.vs3dIsolateButtonValueChanged, true);
        end
        
        function createLowerVoxelLabel(app)
            app.LowerVoxelLabel = uilabel(app.ChildGrid2);
            app.LowerVoxelLabel.Layout.Row = 1;
            app.LowerVoxelLabel.Layout.Column = 1;
            app.LowerVoxelLabel.Text = 'Lower Voxel';
        end
        
        function createWindowLabel(app)
            app.WindowLabel = uilabel(app.ChildGrid3);
            app.WindowLabel.Layout.Row = 1;
            app.WindowLabel.Layout.Column = 1;
            app.WindowLabel.Text = 'Window';
        end
        
        function createLowerVoxelSlider(app, controller)
            app.LowerVoxelSlider = uislider(app.ChildGrid2);
            app.LowerVoxelSlider.MajorTicks = [];
            app.LowerVoxelSlider.MinorTicks = [];
            app.LowerVoxelSlider.Layout.Row = 1;
            app.LowerVoxelSlider.Layout.Column = 2;
            app.LowerVoxelSlider.Limits = [1 100];
            app.LowerVoxelSlider.Value = 1;
            app.LowerVoxelSlider.ValueChangedFcn = app.createCallbackFcn(@controller.vs3dLowerVoxelValueChanged, true);
            app.LowerVoxelSlider.ValueChangingFcn = app.createCallbackFcn(@controller.vs3dLowerVoxelValueChanged, true);
        end
        
        function createWindowSlider(app, controller)
            app.WindowSlider = uislider(app.ChildGrid3);
            app.WindowSlider.MajorTicks = [];
            app.WindowSlider.MinorTicks = [];
            app.WindowSlider.Layout.Row = 1;
            app.WindowSlider.Layout.Column = 2;
            app.WindowSlider.Limits = [1 100];
            app.WindowSlider.Value = 5;
            app.WindowSlider.ValueChangedFcn = app.createCallbackFcn(@controller.vs3dWindowValueChanged, true);
            app.WindowSlider.ValueChangingFcn = app.createCallbackFcn(@controller.vs3dWindowValueChanged, true);
        end
        
        function createLowerVoxelSpinner(app, controller)
            app.LowerVoxelSpinner = uispinner(app.ChildGrid2);
            app.LowerVoxelSpinner.Layout.Row = 1;
            app.LowerVoxelSpinner.Layout.Column = 3;
            app.LowerVoxelSpinner.Limits = [1 100];
            app.LowerVoxelSpinner.Step = 1;
            app.LowerVoxelSpinner.Value = 1;
            app.LowerVoxelSpinner.ValueChangedFcn = app.createCallbackFcn(@controller.vs3dLowerVoxelValueChanged, true);
        end
        
        function createWindowSpinner(app, controller)
            app.WindowSpinner = uispinner(app.ChildGrid3);
            app.WindowSpinner.Layout.Row = 1;
            app.WindowSpinner.Layout.Column = 3;
            app.WindowSpinner.Limits = [1 100];
            app.WindowSpinner.Step = 1;
            app.WindowSpinner.Value = 5;
            app.WindowSpinner.ValueChangedFcn = app.createCallbackFcn(@controller.vs3dWindowValueChanged, true);
        end
         
    end

end