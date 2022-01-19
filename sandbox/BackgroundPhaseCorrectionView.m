classdef BackgroundPhaseCorrectionView < matlab.apps.AppBase
    
    properties (Access = public)
        UIFigure                    matlab.ui.Figure;
        ParentGrid                  matlab.ui.container.GridLayout;
        ChildGrid1                  matlab.ui.container.GridLayout;
        ChildGrid2                  matlab.ui.container.GridLayout;
        MagAxes                     matlab.ui.control.UIAxes
        VelocityAxes                matlab.ui.control.UIAxes
        ImageLabel                  matlab.ui.control.Label
        VmaxLabel                   matlab.ui.control.Label
        CDLabel                     matlab.ui.control.Label
        NoiseLabel                  matlab.ui.control.Label
        FitOrderLabel               matlab.ui.control.Label
        ImageSlider                 matlab.ui.control.Slider
        VmaxSlider                  matlab.ui.control.Slider
        CDSlider                    matlab.ui.control.Slider
        NoiseSlider                 matlab.ui.control.Slider
        FitOrderSlider              matlab.ui.control.Slider
        ImageSpinner                matlab.ui.control.Spinner
        VmaxSpinner                 matlab.ui.control.Spinner
        CDSpinner                   matlab.ui.control.Spinner
        NoiseSpinner                matlab.ui.control.Spinner
        FitOrderSpinner             matlab.ui.control.Spinner
        ApplyCorrectionCheckbox     matlab.ui.control.CheckBox
        UpdateButton                matlab.ui.control.Button
        ResetFitButton              matlab.ui.control.Button
        DoneButton                  matlab.ui.control.Button
    end
    
    properties (Dependent)
        Map;
    end
    
    methods
        
        function val = get.Map(self)
            val = [gray(200); jet(10)];
        end
        
    end
    
    methods (Access = public)
        
        function app = BackgroundPhaseCorrectionView(controller)
            app.UIFigure = controller.View.UIFigure;
            app.createComponents(controller)
        end
        
    end
    
    methods (Access = private)
        
        function createComponents(app, controller)
            app.createParentGrid();
            app.createChildGrid1();
            app.createChildGrid2();
            app.createMagAxes(controller);
            app.createVelocityAxes(controller);
            app.createImageLabel();
            app.createVmaxLabel();
            app.createCdLabel();
            app.createNoiseLabel();
            app.createFitOrderLabel();
            
            app.createImageSlider(controller);
            app.createVmaxSlider(controller);
            app.createCdSlider(controller);
            app.createNoiseSlider(controller);
            
            app.createImageSpinner(controller);
            app.createVmaxSpinner(controller);
            app.createCdSpinner(controller);
            app.createNoiseSpinner(controller);
            app.createFitOrderSpinner(controller);
            
            app.createApplyCorrectionCheckbox(controller);
            app.createUpdateButton(controller);
            app.createResetFitButton(controller);
            app.createDoneButton(controller);
        end
            
        function createParentGrid(app)
            app.ParentGrid = uigridlayout(app.UIFigure);
            app.ParentGrid.ColumnWidth = {'2x', '1x'};
            app.ParentGrid.RowHeight = {'1x', '1x'};
        end
        
        function createChildGrid1(app)
            % grid housing labels, sliders, and spinners
            app.ChildGrid1 = uigridlayout(app.ParentGrid);
            app.ChildGrid1.ColumnWidth = {'1x', '1x', '1x'};
            app.ChildGrid1.RowHeight = {'1x', '1x', '1x', '1x'};
            app.ChildGrid1.Layout.Row = 1;
            app.ChildGrid1.Layout.Column = 2;
        end

        function createChildGrid2(app)
            % grid housing buttons
            app.ChildGrid2 = uigridlayout(app.ParentGrid);
            app.ChildGrid2.ColumnWidth = {'1x'};
            app.ChildGrid2.RowHeight = {'1x', '1x', '1x', '1x'};
            app.ChildGrid2.Layout.Row = 2;
            app.ChildGrid2.Layout.Column = 2;
        end
        
        function createMagAxes(app, controller)
            app.MagAxes = uiaxes(app.ParentGrid);
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
            app.MagAxes.Colormap = app.Map;
            app.MagAxes.DataAspectRatio = [1 1 1];
            controller.Model.MagImage = imagesc(app.MagAxes, 'CData', controller.Model.WhiteImage, [0 210]);
        end
        
        function createVelocityAxes(app, controller)
            app.VelocityAxes = uiaxes(app.ParentGrid);
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
            app.VelocityAxes.Colormap = app.Map;
            app.VelocityAxes.DataAspectRatio = [1 1 1];
            controller.Model.VelocityImage = imagesc(app.VelocityAxes, 'CData', controller.Model.WhiteImage, [0 210]);
        end
        
        function createImageLabel(app)
            app.ImageLabel = uilabel(app.ChildGrid1);
            app.ImageLabel.Layout.Row = 1;
            app.ImageLabel.Layout.Column = 1;
            app.ImageLabel.Text = 'Image';
        end
        
        function createVmaxLabel(app)
            app.VmaxLabel = uilabel(app.ChildGrid1);
            app.VmaxLabel.Layout.Row = 2;
            app.VmaxLabel.Layout.Column = 1;
            app.VmaxLabel.Text = 'Vmax';
        end
        
        function createCdLabel(app)
            app.CDLabel = uilabel(app.ChildGrid1);
            app.CDLabel.Layout.Row = 3;
            app.CDLabel.Layout.Column = 1;
            app.CDLabel.Text = 'CD Threshold';
        end
        
        function createNoiseLabel(app)
            app.NoiseLabel = uilabel(app.ChildGrid1);
            app.NoiseLabel.Layout.Row = 4;
            app.NoiseLabel.Layout.Column = 1;
            app.NoiseLabel.Text = 'Noise Threshold';
        end
        
        function createFitOrderLabel(app)
            app.FitOrderLabel = uilabel(app.ChildGrid1);
            app.FitOrderLabel.Layout.Row = 5;
            app.FitOrderLabel.Layout.Column = 1;
            app.FitOrderLabel.Text = 'Fit Order';
        end

        function createImageSlider(app, controller)
            app.ImageSlider = uislider(app.ChildGrid1);
            app.ImageSlider.Layout.Row = 1;
            app.ImageSlider.Layout.Column = 2;
            app.ImageSlider.MajorTicks = [0:20:100];
            app.ImageSlider.MinorTicks = [5:5:100];
            app.ImageSlider.MajorTickLabels = string(0:0.2:1.0);
            app.ImageSlider.Limits = [0 100];
            app.ImageSlider.Value = controller.Model.Image * 100;
            app.ImageSlider.ValueChangedFcn = app.createCallbackFcn(@controller.bgpcImageValueChangedCallback, true);
            app.ImageSlider.ValueChangingFcn = app.createCallbackFcn(@controller.bgpcImageValueChangedCallback, true);
        end
        
        function createVmaxSlider(app, controller)
            app.VmaxSlider = uislider(app.ChildGrid1);
            app.VmaxSlider.Layout.Row = 2;
            app.VmaxSlider.Layout.Column = 2;
            app.VmaxSlider.MajorTicks = [0:20:100];
            app.VmaxSlider.MinorTicks = [5:5:100];
            app.VmaxSlider.MajorTickLabels = string(0:0.2:1.0);
            app.VmaxSlider.Value = controller.Model.Vmax;
            app.VmaxSlider.Limits = [0 100];
            app.VmaxSlider.ValueChangedFcn = app.createCallbackFcn(@controller.bgpcVmaxValueChangedCallback, true);
            app.VmaxSlider.ValueChangingFcn = app.createCallbackFcn(@controller.bgpcVmaxValueChangedCallback, true);
        end
        
        function createCdSlider(app, controller)
            app.CDSlider = uislider(app.ChildGrid1);
            app.CDSlider.Layout.Row = 3;
            app.CDSlider.Layout.Column = 2;
            app.CDSlider.MajorTicks = [0:20:100];
            app.CDSlider.MinorTicks = [5:5:100];
            app.CDSlider.MajorTickLabels = string(0:0.2:1.0);
            app.CDSlider.Value = controller.Model.CDThreshold * 100;
            app.CDSlider.Limits = [0 100];
            app.CDSlider.ValueChangedFcn = app.createCallbackFcn(@controller.bgpcCdThresholdValueChangedCallback, true);
            app.CDSlider.ValueChangingFcn = app.createCallbackFcn(@controller.bgpcCdThresholdValueChangedCallback, true);
        end
        
        function createNoiseSlider(app, controller)
            app.NoiseSlider = uislider(app.ChildGrid1);
            app.NoiseSlider.MajorTicks = [0:20:100];
            app.NoiseSlider.MinorTicks = [5:5:100];
            app.NoiseSlider.MajorTickLabels = string(0:0.2:1.0);
            app.NoiseSlider.Layout.Row = 4;
            app.NoiseSlider.Layout.Column = 2;
            app.NoiseSlider.Value = controller.Model.NoiseThreshold * 100;
            app.NoiseSlider.Limits = [0 100];
            app.NoiseSlider.ValueChangedFcn = app.createCallbackFcn(@controller.bgpcNoiseThresholdValueChangedCallback, true);
            app.NoiseSlider.ValueChangingFcn = app.createCallbackFcn(@controller.bgpcNoiseThresholdValueChangedCallback, true);
        end
        
        function createImageSpinner(app, controller)
            app.ImageSpinner = uispinner(app.ChildGrid1);
            app.ImageSpinner.Layout.Row = 1;
            app.ImageSpinner.Layout.Column = 3;
            app.ImageSpinner.Limits = [0 1];
            app.ImageSpinner.Step = 0.01;
            app.ImageSpinner.Value = controller.Model.Image;
            app.ImageSpinner.ValueChangedFcn = app.createCallbackFcn(@controller.bgpcImageValueChangedCallback, true);
        end
        
        function createVmaxSpinner(app, controller)
            app.VmaxSpinner = uispinner(app.ChildGrid1);
            app.VmaxSpinner.Layout.Row = 2;
            app.VmaxSpinner.Layout.Column = 3;
            app.VmaxSpinner.Limits = [0 1];
            app.VmaxSpinner.Step = 0.01;
            app.VmaxSpinner.Value = controller.Model.Vmax;
            app.VmaxSpinner.ValueChangedFcn = app.createCallbackFcn(@controller.bgpcVmaxValueChangedCallback, true);
        end
        
        function createCdSpinner(app, controller)
            app.CDSpinner = uispinner(app.ChildGrid1);
            app.CDSpinner.Layout.Row = 3;
            app.CDSpinner.Layout.Column = 3;
            app.CDSpinner.Limits = [0 1];
            app.CDSpinner.Step = 0.01;
            app.CDSpinner.Value = controller.Model.CDThreshold;
            app.CDSpinner.ValueChangedFcn = app.createCallbackFcn(@controller.bgpcCdThresholdValueChangedCallback, true);
        end
        
        function createNoiseSpinner(app, controller)
            app.NoiseSpinner = uispinner(app.ChildGrid1);
            app.NoiseSpinner.Layout.Row = 4;
            app.NoiseSpinner.Layout.Column = 3;
            app.NoiseSpinner.Limits = [0 1];
            app.NoiseSpinner.Step = 0.01;
            app.NoiseSpinner.Value = controller.Model.NoiseThreshold;
            app.NoiseSpinner.ValueChangedFcn = app.createCallbackFcn(@controller.bgpcNoiseThresholdValueChangedCallback, true);
        end
        
        function createFitOrderSpinner(app, controller)
            app.FitOrderSpinner = uispinner(app.ChildGrid1);
            app.FitOrderSpinner.Layout.Row = 5;
            app.FitOrderSpinner.Layout.Column = 3;
            app.FitOrderSpinner.Limits = [0 inf];
            app.FitOrderSpinner.Step = 1;
            app.FitOrderSpinner.Value = controller.Model.FitOrder;
            app.FitOrderSpinner.ValueChangedFcn = app.createCallbackFcn(@controller.bgpcFitOrderValueChangedCallback, true);
        end

        function createApplyCorrectionCheckbox(app, controller)
            app.ApplyCorrectionCheckbox = uicheckbox(app.ChildGrid2);
            app.ApplyCorrectionCheckbox.Layout.Row = 1;
            app.ApplyCorrectionCheckbox.Layout.Column = 1;
            app.ApplyCorrectionCheckbox.Text = 'Apply Correction';
            app.ApplyCorrectionCheckbox.Value = controller.Model.ApplyCorrection;
            app.ApplyCorrectionCheckbox.ValueChangedFcn = app.createCallbackFcn(@controller.bgpcApplyCorrectionValueChangedCallback, true);
        end
        
        function createUpdateButton(app, controller)
            app.UpdateButton = uibutton(app.ChildGrid2, 'push');
            app.UpdateButton.Layout.Row = 2;
            app.UpdateButton.Layout.Column = 1;
            app.UpdateButton.Text = 'Update Images';
            app.UpdateButton.ButtonPushedFcn = app.createCallbackFcn(@controller.bgpcUpdateButtonPushed, true);
        end
        
        function createResetFitButton(app, controller)
            app.ResetFitButton = uibutton(app.ChildGrid2, 'push');
            app.ResetFitButton.Layout.Row = 3;
            app.ResetFitButton.Layout.Column = 1;
            app.ResetFitButton.Text = 'Reset Fit';
            app.ResetFitButton.ButtonPushedFcn = app.createCallbackFcn(@controller.bgpcResetFitButtonPushed, true);
        end
        
        function createDoneButton(app, controller)
            app.DoneButton = uibutton(app.ChildGrid2, 'push');
            app.DoneButton.Layout.Row = 4;
            app.DoneButton.Layout.Column = 1;
            app.DoneButton.Text = 'Done';
            app.DoneButton.ButtonPushedFcn = app.createCallbackFcn(@controller.bgpcDoneButtonPushed, true);
        end

    end
    
    
end