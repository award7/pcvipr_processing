classdef View < CenterlineApp.base.ViewBase

    properties (GetAccess = public, SetAccess = private)
        UIFigure                    matlab.ui.Figure;
        ParentGridLayout            matlab.ui.container.GridLayout;
        ChildGridLayout1            matlab.ui.container.GridLayout;
        ChildGridLayout2            matlab.ui.container.GridLayout;
        MagAxes                     matlab.ui.control.UIAxes;
        VelocityAxes                matlab.ui.control.UIAxes;
        ImageLabel                  matlab.ui.control.Label;
        VmaxLabel                   matlab.ui.control.Label;
        CDLabel                     matlab.ui.control.Label;
        NoiseLabel                  matlab.ui.control.Label;
        FitOrderLabel               matlab.ui.control.Label;
        ImageSlider                 matlab.ui.control.Slider;
        VmaxSlider                  matlab.ui.control.Slider;
        CDSlider                    matlab.ui.control.Slider;
        NoiseSlider                 matlab.ui.control.Slider;
        FitOrderSlider              matlab.ui.control.Slider;
        ImageSpinner                matlab.ui.control.Spinner;
        VmaxSpinner                 matlab.ui.control.Spinner;
        CDSpinner                   matlab.ui.control.Spinner;
        NoiseSpinner                matlab.ui.control.Spinner;
        FitOrderSpinner             matlab.ui.control.Spinner;
        ApplyCorrectionCheckbox     matlab.ui.control.CheckBox;
        UpdateButton                matlab.ui.control.Button;
        ResetFitButton              matlab.ui.control.Button;
        DoneButton                  matlab.ui.control.Button;
        BGModel;
        MagImage                    matlab.graphics.primitive.Image;
        Map                         (:,3) double {mustBeReal} = [gray(200); jet(10)];
        VelImage                    matlab.graphics.primitive.Image;
    end
    
    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = View(BGModel)
            
            % Create UIFigure and components
            app.createComponents();

            % Register the app with App Designer
            app.registerApp(app.UIFigure);

            app.runStartupFcn(@(app)startupFcn(app, BGModel));
            
            if nargout == 0
                clear app;
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
            app.createMagAxes();
            app.createVelocityAxes();
            app.createImageLabel();
            app.createVmaxLabel();
            app.createCDLabel();
            app.createNoiseLabel();
            app.createFitOrderLabel();
            app.createImageSlider();
            app.createVmaxSlider();
            app.createCDSlider();
            app.createNoiseSlider();
            app.createImageSpinner();
            app.createVmaxSpinner();
            app.createCDSpinner();
            app.createNoiseSpinner();
            app.createFitOrderSpinner();
            app.createApplyCorrectionCheckbox();
            app.createUpdateButton();
            app.createResetFitButton();
            app.createDoneButton();
            
            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
           
        function createFigure(app)
            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Name = 'Background Phase Correction';
            app.UIFigure.WindowState = 'maximized';
        end
        
        function createParentGrid(app)
            % grid that divides the figure into quadrants
            % axes sit in column 1; buttons, sliders, etc. in column 2
            app.ParentGridLayout = uigridlayout(app.UIFigure);
            app.ParentGridLayout.ColumnWidth = {'2x', '1x'};
            app.ParentGridLayout.RowHeight = {'1x', '1x'};
        end
        
        function createChildGrid1(app)
            % grid housing labels, sliders, and spinners
            app.ChildGridLayout1 = uigridlayout(app.ParentGridLayout);
            app.ChildGridLayout1.ColumnWidth = {'1x', '1x', '1x'};
            app.ChildGridLayout1.RowHeight = {'1x', '1x', '1x', '1x'};
            app.ChildGridLayout1.Layout.Row = 1;
            app.ChildGridLayout1.Layout.Column = 2;
        end

        function createChildGrid2(app)
            % grid housing buttons
            app.ChildGridLayout2 = uigridlayout(app.ParentGridLayout);
            app.ChildGridLayout2.ColumnWidth = {'1x'};
            app.ChildGridLayout2.RowHeight = {'1x', '1x', '1x', '1x'};
            app.ChildGridLayout2.Layout.Row = 2;
            app.ChildGridLayout2.Layout.Column = 2;
        end
        
        function createMagAxes(app)
            app.MagAxes = uiaxes(app.ParentGridLayout);
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
            whiteImage = 255 * ones(480, 640, 3, 'uint8');
            app.MagImage = imagesc(app.MagAxes, 'CData', whiteImage, [0 210]);
        end
        
        function createVelocityAxes(app)
            app.VelocityAxes = uiaxes(app.ParentGridLayout);
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
            whiteImage = 255 * ones(480, 640, 3, 'uint8');
            app.VelocityImage = imagesc(app.VelocityAxes, 'CData', whiteImage, [0 210]);
        end
        
        function createImageLabel(app)
            app.ImageLabel = uilabel(app.ChildGridLayout1);
            app.ImageLabel.Layout.Row = 1;
            app.ImageLabel.Layout.Column = 1;
            app.ImageLabel.Text = 'Image';
        end
        
        function createVmaxLabel(app)
            app.VmaxLabel = uilabel(app.ChildGridLayout1);
            app.VmaxLabel.Layout.Row = 2;
            app.VmaxLabel.Layout.Column = 1;
            app.VmaxLabel.Text = 'Vmax';
        end
        
        function createCDLabel(app)
            app.CDLabel = uilabel(app.ChildGridLayout1);
            app.CDLabel.Layout.Row = 3;
            app.CDLabel.Layout.Column = 1;
            app.CDLabel.Text = 'CD Threshold';
        end
        
        function createNoiseLabel(app)
            app.NoiseLabel = uilabel(app.ChildGridLayout1);
            app.NoiseLabel.Layout.Row = 4;
            app.NoiseLabel.Layout.Column = 1;
            app.NoiseLabel.Text = 'Noise Threshold';
        end
        
        function createFitOrderLabel(app)
            app.FitOrderLabel = uilabel(app.ChildGridLayout1);
            app.FitOrderLabel.Layout.Row = 5;
            app.FitOrderLabel.Layout.Column = 1;
            app.FitOrderLabel.Text = 'Fit Order';
        end
        
        function createImageSlider(app)
            app.ImageSlider = uislider(app.ChildGridLayout1);
            app.ImageSlider.Layout.Row = 1;
            app.ImageSlider.Layout.Column = 2;
            app.ImageSlider.Limits = [0 1];
            app.ImageSlider.MajorTicks = [0:0.2:1];
            app.ImageSlider.MinorTicks = [0.05:0.05:1];
            app.ImageSlider.MajorTickLabels = string(0:0.20:1);
            app.ImageSlider.Value = app.BGModel.Image;
        end
        
        function createVmaxSlider(app)
            app.VmaxSlider = uislider(app.ChildGridLayout1);
            app.VmaxSlider.Layout.Row = 2;
            app.VmaxSlider.Layout.Column = 2;
            app.VmaxSlider.Limits = [0 1];
            app.VmaxSlider.MajorTicks = [0:0.2:1];
            app.VmaxSlider.MinorTicks = [0.05:0.05:1];
            app.VmaxSlider.MajorTickLabels = string(0:0.20:1);
            app.VmaxSlider.Value = app.BGModel.Vmax;
        end
        
        function createCDSlider(app)
            app.CDSlider = uislider(app.ChildGridLayout1);
            app.CDSlider.Layout.Row = 3;
            app.CDSlider.Layout.Column = 2;
            app.CDSlider.Limits = [0 1];
            app.CDSlider.MajorTicks = [0:0.2:1];
            app.CDSlider.MinorTicks = [0.05:0.05:1];
            app.CDSlider.MajorTickLabels = string(0:0.20:1);
            app.CDSlider.Value = app.BGModel.CDThreshold;
        end
        
        function createNoiseSlider(app)
            app.NoiseSlider = uislider(app.ChildGridLayout1);
            app.NoiseSlider.Layout.Row = 4;
            app.NoiseSlider.Layout.Column = 2;
            app.NoiseSlider.Limits = [0 1];
            app.NoiseSlider.MajorTicks = [0:0.2:1];
            app.NoiseSlider.MinorTicks = [0.05:0.05:1];
            app.NoiseSlider.MajorTickLabels = string(0:0.20:1);
            app.NoiseSlider.Value = app.BGModel.NoiseThreshold;
        end
        
        function createImageSpinner(app)
            app.ImageSpinner = uispinner(app.ChildGridLayout1);
            app.ImageSpinner.Layout.Row = 1;
            app.ImageSpinner.Layout.Column = 3;
            app.ImageSpinner.Limits = [0 1];
            app.ImageSpinner.Step = 0.01;
            app.ImageSpinner.Value = app.BGModel.Image;
        end
        
        function createVmaxSpinner(app)
            app.VmaxSpinner = uispinner(app.ChildGridLayout1);
            app.VmaxSpinner.Layout.Row = 2;
            app.VmaxSpinner.Layout.Column = 3;
            app.VmaxSpinner.Limits = [0 1];
            app.VmaxSpinner.Step = 0.01;
            app.VmaxSpinner.Value = app.BGModel.Vmax;
        end
        
        function createCDSpinner(app)
            app.CDSpinner = uispinner(app.ChildGridLayout1);
            app.CDSpinner.Layout.Row = 3;
            app.CDSpinner.Layout.Column = 3;
            app.CDSpinner.Limits = [0 1];
            app.CDSpinner.Step = 0.01;
            app.CDSpinner.Value = app.BGModel.CDThreshold;
        end
        
        function createNoiseSpinner(app)
            app.NoiseSpinner = uispinner(app.ChildGridLayout1);
            app.NoiseSpinner.Layout.Row = 4;
            app.NoiseSpinner.Layout.Column = 3;
            app.NoiseSpinner.Limits = [0 1];
            app.NoiseSpinner.Step = 0.01;
            app.NoiseSpinner.Value = app.BGModel.NoiseThreshold;
        end
        
        function createFitOrderSpinner(app)
            app.FitOrderSpinner = uispinner(app.ChildGridLayout1);
            app.FitOrderSpinner.Layout.Row = 5;
            app.FitOrderSpinner.Layout.Column = 3;
            app.FitOrderSpinner.Limits = [0 inf];
            app.FitOrderSpinner.Step = 1;
            app.FitOrderSpinner.Value = app.BGModel.FitOrder;
        end
        
        function createApplyCorrectionCheckbox(app)
            app.ApplyCorrectionCheckbox = uicheckbox(app.ChildGridLayout2);
            app.ApplyCorrectionCheckbox.Layout.Row = 1;
            app.ApplyCorrectionCheckbox.Layout.Column = 1;
            app.ApplyCorrectionCheckbox.Text = 'Apply Correction';
            app.ApplyCorrectionCheckbox.Value = app.BGModel.ApplyCorrection;
        end
        
        function createUpdateButton(app)
            app.UpdateButton = uibutton(app.ChildGridLayout2, 'push');
            app.UpdateButton.Layout.Row = 2;
            app.UpdateButton.Layout.Column = 1;
            app.UpdateButton.Text = 'Update Images';
        end
        
        function createResetFitButton(app)
            app.ResetFitButton = uibutton(app.ChildGridLayout2, 'push');
            app.ResetFitButton.Layout.Row = 3;
            app.ResetFitButton.Layout.Column = 1;
            app.ResetFitButton.Text = 'Reset Fit';
        end
        
        function createDoneButton(app)
            app.DoneButton = uibutton(app.ChildGridLayout2, 'push');
            app.DoneButton.Layout.Row = 4;
            app.DoneButton.Layout.Column = 1;
            app.DoneButton.Text = 'Done';
        end

    end
    
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, BGModel)
            app.BGModel = BGModel;
            
            % add model listeners
            addlisenter(app.BGModel, 'Image', 'PostSet', @app.onImageValPostChange);
            addlisenter(app.BGModel, 'Vmax', 'PostSet', @app.onVmaxValPostChange);
            addlisenter(app.BGModel, 'CDThreshold', 'PostSet', @app.onCDThresholdValPostChange);
            addlisenter(app.BGModel, 'NoiseThreshold', 'PostSet', @app.onNoiseThresholdValPostChange);
            addlisenter(app.BGModel, 'FitOrder', 'PostSet', @app.onFitOrderValPostChange);
            addlisenter(app.BGModel, 'ApplyCorrection', 'PostSet', @app.onApplyCorrectionValPostChange);
        end

    end

    methods (Access = private)
        
       function onImageValPostChange(app, src, evt)
            val = evt.Value;
            app.ImageSlider.Value = val;
            app.ImageSpinner.Value = val;
       end
       
       function onVmaxValPostChange(app, src, evt)
           val = evt.Value;
           app.VmaxSlider.Value = val;
           app.VmaxSpinner.Value = val;
       end
       
       function onCDThresholdValPostChange(app, src, evt)
           val = evt.Value;
           app.CDSlider.Value = val;
           app.CDSpinner.Value = val;
       end
       
       function onNoiseThresholdValPostChange(app, src, evt)
           val = evt.Value;
           app.NoiseSlider.Value = val;
           app.NoiseSpinner.Value = val;
       end
       
       function onFitOrderValPostChange(app, src, evt)
           val = evt.Value;
           app.FitOrderSlider.Value = val;
           app.FitOrderSpinner.Value = val;
       end
       
       function onApplyCorrectionValPostChange(app, src, evt)
           val = evt.Value;
           app.ApplyCorrectionCheckbox.Value = val;
       end
        
    end
    
    methods (Access = private)
        
        function setMagImg(app, val)
            app.MagImage.CData = val;
        end
        
        function setVelImg(app, val)
            app.VelImage.CData = val;
        end
        
        function setImageSliderVal(app, val)
            app.ImageSlider.Value = val;
        end
        
        function setImageSpinnerVal(app, val)
            app.ImageSpinner.Value = val;
        end
        
        function setVmaxSliderVal(app, val)
            app.VmaxSlider.Value = val;
        end
        
        function setVmaxSpinnerVal(app, val)
            app.VmaxSpinner.Value = val;
        end
        
        function setCDSliderVal(app, val)
            app.CDSlider.Value = val;
        end
        
        function setCDSpinnerVal(app, val)
            app.CDSpinner.Value = val;
        end
        
        function setNoiseSliderVal(app, val)
            app.NoiseSlider.Value = val;
        end
            
        function setNoiseSpinnerVal(app, val)
            app.NoiseSpinner.Value = val;
        end
        
        function setFitOrderSliderVal(app, val)
            app.FitOrderSlider.Value = val;
        end
        
        function setFitOrderSpinnerVal(app, val)
            app.FitOrderSpinner.Value = val;
        end
        
        function setApplyCorrectionVal(app, val)
            app.ApplyCorrectionCheckbox.Value = val;
        end
        
    end
    
end