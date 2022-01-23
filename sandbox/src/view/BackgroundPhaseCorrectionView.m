classdef BackgroundPhaseCorrectionView < matlab.apps.AppBase
    
    % base figure
    properties (Access = public)
        UIFigure    matlab.ui.Figure;
    end
    
    % axes
    properties
        MagAxes         matlab.ui.control.UIAxes
        VelocityAxes    matlab.ui.control.UIAxes
    end
   
    % sliders
    properties
        ImageSlider     matlab.ui.control.Slider
        VmaxSlider      matlab.ui.control.Slider
        CDSlider        matlab.ui.control.Slider
        NoiseSlider     matlab.ui.control.Slider
        FitOrderSlider  matlab.ui.control.Slider
    end
    
    % spinners
    properties 
        ImageSpinner        matlab.ui.control.Spinner
        VmaxSpinner         matlab.ui.control.Spinner
        CDSpinner           matlab.ui.control.Spinner
        NoiseSpinner        matlab.ui.control.Spinner
        FitOrderSpinner     matlab.ui.control.Spinner
    end
    
    % constructor
    methods (Access = public)
        
        function app = BackgroundPhaseCorrectionView(controller)
            app.UIFigure = controller.BaseView.UIFigure;
            app.createComponents(controller)
        end
        
    end
    
    % component initialization
    methods (Access = private)
        
        function createComponents(app, controller)
            parent_grid = app.createParentGrid();
            child_grid1 = app.createChildGrid1(parent_grid);
            child_grid2 = app.createChildGrid2(parent_grid);
            app.createMagAxes(controller, parent_grid);
            app.createVelocityAxes(controller, parent_grid);
            
            app.createImageLabel(child_grid1);
            app.createVmaxLabel(child_grid1);
            app.createCdLabel(child_grid1);
            app.createNoiseLabel(child_grid1);
            app.createFitOrderLabel(child_grid1);
            
            app.createImageSlider(controller, child_grid1);
            app.createVmaxSlider(controller, child_grid1);
            app.createCdSlider(controller, child_grid1);
            app.createNoiseSlider(controller, child_grid1);
            
            app.createImageSpinner(controller, child_grid1);
            app.createVmaxSpinner(controller, child_grid1);
            app.createCdSpinner(controller, child_grid1);
            app.createNoiseSpinner(controller, child_grid1);
            app.createFitOrderSpinner(controller, child_grid1);
            
            app.createApplyCorrectionCheckbox(controller, child_grid2);
            app.createUpdateButton(controller, child_grid2);
            app.createResetFitButton(controller, child_grid2);
            app.createDoneButton(controller, child_grid2);
        end
            
        function parent_grid = createParentGrid(app)
            parent_grid = uigridlayout(app.UIFigure);
            parent_grid.ColumnWidth = {'2x', '1x'};
            parent_grid.RowHeight = {'1x', '1x'};
        end
        
        function child_grid1 = createChildGrid1(app, parent_grid)
            % grid housing labels, sliders, and spinners
            child_grid1 = uigridlayout(parent_grid);
            child_grid1.ColumnWidth = {'1x', '1x', '1x'};
            child_grid1.RowHeight = {'1x', '1x', '1x', '1x'};
            child_grid1.Layout.Row = 1;
            child_grid1.Layout.Column = 2;
        end

        function child_grid2 = createChildGrid2(app, parent_grid)
            % grid housing buttons
            child_grid2 = uigridlayout(parent_grid);
            child_grid2.ColumnWidth = {'1x'};
            child_grid2.RowHeight = {'1x', '1x', '1x', '1x'};
            child_grid2.Layout.Row = 2;
            child_grid2.Layout.Column = 2;
        end
        
        function createMagAxes(app, controller, parent_grid)
            app.MagAxes = uiaxes(parent_grid);
            app.MagAxes.Layout.Row = 1;
            app.MagAxes.Layout.Column = 1;
            title(app.MagAxes, 'Magnitude Image');
            app.MagAxes.FontSize = 16;
            xlabel(app.MagAxes, '');
            ylabel(app.MagAxes, '');
            app.MagAxes.XLimMode = 'manual';
            app.MagAxes.XLim = [1 320];
            app.MagAxes.XTick = [];
            app.MagAxes.YLimMode = 'manual';
            app.MagAxes.YLim = [1 320];
            app.MagAxes.YTick = [];
            app.MagAxes.Box = 'on';
            app.MagAxes.Color = [0 0 0];
            app.MagAxes.Colormap = controller.BackgroundPhaseCorrectionModel.Map;
            app.MagAxes.DataAspectRatio = [1 1 1];
        end
        
        function createVelocityAxes(app, controller, parent_grid)
            app.VelocityAxes = uiaxes(parent_grid);
            app.VelocityAxes.Layout.Row = 2;
            app.VelocityAxes.Layout.Column = 1;
            title(app.VelocityAxes, 'Velocity Image');
            app.VelocityAxes.FontSize = 16;
            xlabel(app.VelocityAxes, '');
            ylabel(app.VelocityAxes, '');
            app.VelocityAxes.XLimMode = 'manual';
            app.VelocityAxes.XLim = [1 320];
            app.VelocityAxes.XTick = [];
            app.VelocityAxes.YLimMode = 'manual';
            app.VelocityAxes.YLim = [1 320];
            app.VelocityAxes.YTick = [];
            app.VelocityAxes.Box = 'on';
            app.VelocityAxes.Color = [0 0 0];
            app.VelocityAxes.Colormap = controller.BackgroundPhaseCorrectionModel.Map;
            app.VelocityAxes.DataAspectRatio = [1 1 1];
        end
        
        function createImageLabel(app, child_grid1)
            label = uilabel(child_grid1);
            label.Layout.Row = 1;
            label.Layout.Column = 1;
            label.Text = 'Image';
        end
        
        function createVmaxLabel(app, child_grid1)
            label = uilabel(child_grid1);
            label.Layout.Row = 2;
            label.Layout.Column = 1;
            label.Text = 'Vmax';
        end
        
        function createCdLabel(app, child_grid1)
            label = uilabel(child_grid1);
            label.Layout.Row = 3;
            label.Layout.Column = 1;
            label.Text = 'CD Threshold';
        end
        
        function createNoiseLabel(app, child_grid1)
            label = uilabel(child_grid1);
            label.Layout.Row = 4;
            label.Layout.Column = 1;
            label.Text = 'Noise Threshold';
        end
        
        function createFitOrderLabel(app, child_grid1)
            label = uilabel(child_grid1);
            label.Layout.Row = 5;
            label.Layout.Column = 1;
            label.Text = 'Fit Order';
        end

        function createImageSlider(app, controller, child_grid1)
            app.ImageSlider = uislider(child_grid1);
            app.ImageSlider.Layout.Row = 1;
            app.ImageSlider.Layout.Column = 2;
            app.ImageSlider.MajorTicks = [0:20:100];
            app.ImageSlider.MinorTicks = [5:5:100];
            app.ImageSlider.MajorTickLabels = string(0:0.2:1.0);
            app.ImageSlider.Limits = [0 100];
            app.ImageSlider.Value = controller.BackgroundPhaseCorrectionModel.Image * 100;
            app.ImageSlider.ValueChangedFcn = app.createCallbackFcn(@controller.bgpcImageValueChangedCallback, true);
            app.ImageSlider.ValueChangingFcn = app.createCallbackFcn(@controller.bgpcImageValueChangedCallback, true);
        end
        
        function createVmaxSlider(app, controller, child_grid1)
            app.VmaxSlider = uislider(child_grid1);
            app.VmaxSlider.Layout.Row = 2;
            app.VmaxSlider.Layout.Column = 2;
            app.VmaxSlider.MajorTicks = [0:20:100];
            app.VmaxSlider.MinorTicks = [5:5:100];
            app.VmaxSlider.MajorTickLabels = string(0:0.2:1.0);
            app.VmaxSlider.Value = controller.BackgroundPhaseCorrectionModel.Vmax;
            app.VmaxSlider.Limits = [0 100];
            app.VmaxSlider.ValueChangedFcn = app.createCallbackFcn(@controller.bgpcVmaxValueChangedCallback, true);
            app.VmaxSlider.ValueChangingFcn = app.createCallbackFcn(@controller.bgpcVmaxValueChangedCallback, true);
        end
        
        function createCdSlider(app, controller, child_grid1)
            app.CDSlider = uislider(child_grid1);
            app.CDSlider.Layout.Row = 3;
            app.CDSlider.Layout.Column = 2;
            app.CDSlider.MajorTicks = [0:20:100];
            app.CDSlider.MinorTicks = [5:5:100];
            app.CDSlider.MajorTickLabels = string(0:0.2:1.0);
            app.CDSlider.Value = controller.BackgroundPhaseCorrectionModel.CDThreshold * 100;
            app.CDSlider.Limits = [0 100];
            app.CDSlider.ValueChangedFcn = app.createCallbackFcn(@controller.bgpcCdThresholdValueChangedCallback, true);
            app.CDSlider.ValueChangingFcn = app.createCallbackFcn(@controller.bgpcCdThresholdValueChangedCallback, true);
        end
        
        function createNoiseSlider(app, controller, child_grid1)
            app.NoiseSlider = uislider(child_grid1);
            app.NoiseSlider.MajorTicks = [0:20:100];
            app.NoiseSlider.MinorTicks = [5:5:100];
            app.NoiseSlider.MajorTickLabels = string(0:0.2:1.0);
            app.NoiseSlider.Layout.Row = 4;
            app.NoiseSlider.Layout.Column = 2;
            app.NoiseSlider.Value = controller.BackgroundPhaseCorrectionModel.NoiseThreshold * 100;
            app.NoiseSlider.Limits = [0 100];
            app.NoiseSlider.ValueChangedFcn = app.createCallbackFcn(@controller.bgpcNoiseThresholdValueChangedCallback, true);
            app.NoiseSlider.ValueChangingFcn = app.createCallbackFcn(@controller.bgpcNoiseThresholdValueChangedCallback, true);
        end
        
        function createImageSpinner(app, controller, child_grid1)
            app.ImageSpinner = uispinner(child_grid1);
            app.ImageSpinner.Layout.Row = 1;
            app.ImageSpinner.Layout.Column = 3;
            app.ImageSpinner.Limits = [0 1];
            app.ImageSpinner.Step = 0.01;
            app.ImageSpinner.Value = controller.BackgroundPhaseCorrectionModel.Image;
            app.ImageSpinner.ValueChangedFcn = app.createCallbackFcn(@controller.bgpcImageValueChangedCallback, true);
        end
        
        function createVmaxSpinner(app, controller, child_grid1)
            app.VmaxSpinner = uispinner(child_grid1);
            app.VmaxSpinner.Layout.Row = 2;
            app.VmaxSpinner.Layout.Column = 3;
            app.VmaxSpinner.Limits = [0 1];
            app.VmaxSpinner.Step = 0.01;
            app.VmaxSpinner.Value = controller.BackgroundPhaseCorrectionModel.Vmax;
            app.VmaxSpinner.ValueChangedFcn = app.createCallbackFcn(@controller.bgpcVmaxValueChangedCallback, true);
        end
        
        function createCdSpinner(app, controller, child_grid1)
            app.CDSpinner = uispinner(child_grid1);
            app.CDSpinner.Layout.Row = 3;
            app.CDSpinner.Layout.Column = 3;
            app.CDSpinner.Limits = [0 1];
            app.CDSpinner.Step = 0.01;
            app.CDSpinner.Value = controller.BackgroundPhaseCorrectionModel.CDThreshold;
            app.CDSpinner.ValueChangedFcn = app.createCallbackFcn(@controller.bgpcCdThresholdValueChangedCallback, true);
        end
        
        function createNoiseSpinner(app, controller, child_grid1)
            app.NoiseSpinner = uispinner(child_grid1);
            app.NoiseSpinner.Layout.Row = 4;
            app.NoiseSpinner.Layout.Column = 3;
            app.NoiseSpinner.Limits = [0 1];
            app.NoiseSpinner.Step = 0.01;
            app.NoiseSpinner.Value = controller.BackgroundPhaseCorrectionModel.NoiseThreshold;
            app.NoiseSpinner.ValueChangedFcn = app.createCallbackFcn(@controller.bgpcNoiseThresholdValueChangedCallback, true);
        end
        
        function createFitOrderSpinner(app, controller, child_grid1)
            app.FitOrderSpinner = uispinner(child_grid1);
            app.FitOrderSpinner.Layout.Row = 5;
            app.FitOrderSpinner.Layout.Column = 3;
            app.FitOrderSpinner.Limits = [0 inf];
            app.FitOrderSpinner.Step = 1;
            app.FitOrderSpinner.Value = controller.BackgroundPhaseCorrectionModel.FitOrder;
            app.FitOrderSpinner.ValueChangedFcn = app.createCallbackFcn(@controller.bgpcFitOrderValueChangedCallback, true);
        end

        function createApplyCorrectionCheckbox(app, controller, child_grid2)
            checkbox = uicheckbox(child_grid2);
            checkbox.Layout.Row = 1;
            checkbox.Layout.Column = 1;
            checkbox.Text = 'Apply Correction';
            checkbox.Value = controller.BackgroundPhaseCorrectionModel.ApplyCorrection;
            checkbox.ValueChangedFcn = app.createCallbackFcn(@controller.bgpcApplyCorrectionValueChangedCallback, true);
        end
        
        function createUpdateButton(app, controller, child_grid2)
            button = uibutton(child_grid2, 'push');
            button.Layout.Row = 2;
            button.Layout.Column = 1;
            button.Text = 'Update Images';
            button.ButtonPushedFcn = app.createCallbackFcn(@controller.bgpcUpdateButtonPushed, true);
        end
        
        function createResetFitButton(app, controller, child_grid2)
            button = uibutton(child_grid2, 'push');
            button.Layout.Row = 3;
            button.Layout.Column = 1;
            button.Text = 'Reset Fit';
            button.ButtonPushedFcn = app.createCallbackFcn(@controller.bgpcResetFitButtonPushed, true);
        end
        
        function createDoneButton(app, controller, child_grid2)
            button = uibutton(child_grid2, 'push');
            button.Layout.Row = 4;
            button.Layout.Column = 1;
            button.Text = 'Done';
            button.ButtonPushedFcn = app.createCallbackFcn(@controller.bgpcDoneButtonPushed, true);
        end

    end
    
    
end