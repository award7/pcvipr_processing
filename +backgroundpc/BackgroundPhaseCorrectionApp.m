classdef BackgroundPhaseCorrectionApp < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = private)
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
    end
    
    % non-GUI props
    properties (Access = private)
        CenterlineToolApp           CenterlineToolApp;
        PhaseCorrection             BackgroundPhaseCorrection;
        MagImage                    matlab.graphics.primitive.Image;
        VelocityImage               matlab.graphics.primitive.Image;
        Map                         (:,3) double {mustBeReal} = [gray(200); jet(10)];
    end
    
    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = BackgroundPhaseCorrectionApp(centerlineToolApp)
            arguments
                centerlineToolApp CenterlineToolApp;
            end
            
            % Create UIFigure and components
            app.createComponents();

            % Register the app with App Designer
            app.registerApp(app.UIFigure);

            app.runStartupFcn(@(app)startupFcn(app, centerlineToolApp));
            
            if nargout == 0
                clear app;
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
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
            app.UIFigure.CloseRequestFcn = app.createCallbackFcn(@uiFigureCloseRequest, true);
            app.UIFigure.WindowKeyPressFcn = app.createCallbackFcn(@uiWindowKeyPressFcn, true);
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
            app.ImageSlider.MajorTicks = [0:20:100];
            app.ImageSlider.MinorTicks = [5:5:100];
            app.ImageSlider.MajorTickLabels = string(0:0.20:1);
            app.ImageSlider.Limits = [0 100];
            app.ImageSlider.Value = app.Image * 100;
            app.ImageSlider.ValueChangedFcn = app.createCallbackFcn(@imageValueChanged, true);
            app.ImageSlider.ValueChangingFcn = app.createCallbackFcn(@imageValueChanged, true);
        end
        
        function createVmaxSlider(app)
            app.VmaxSlider = uislider(app.ChildGridLayout1);
            app.VmaxSlider.Layout.Row = 2;
            app.VmaxSlider.Layout.Column = 2;
            app.VmaxSlider.MajorTicks = [0:20:100];
            app.VmaxSlider.MinorTicks = [5:5:100];
            app.VmaxSlider.MajorTickLabels = string(0:0.20:1);
            app.VmaxSlider.Value = app.Vmax;
            app.VmaxSlider.Limits = [0 100];
            app.VmaxSlider.ValueChangedFcn = app.createCallbackFcn(@vmaxValueChanged, true);
            app.VmaxSlider.ValueChangingFcn = app.createCallbackFcn(@vmaxValueChanged, true);
        end
        
        function createCDSlider(app)
            app.CDSlider = uislider(app.ChildGridLayout1);
            app.CDSlider.Layout.Row = 3;
            app.CDSlider.Layout.Column = 2;
            app.CDSlider.MajorTicks = [0:20:100];
            app.CDSlider.MinorTicks = [5:5:100];
            app.CDSlider.MajorTickLabels = string(0:0.20:1);
            app.CDSlider.Value = app.CDThreshold * 100;
            app.CDSlider.Limits = [0 100];
            app.CDSlider.ValueChangedFcn = app.createCallbackFcn(@cdThresholdValueChanged, true);
            app.CDSlider.ValueChangingFcn = app.createCallbackFcn(@cdThresholdValueChanged, true);
        end
        
        function createNoiseSlider(app)
            app.NoiseSlider = uislider(app.ChildGridLayout1);
            app.NoiseSlider.MajorTicks = [0:20:100];
            app.NoiseSlider.MinorTicks = [5:5:100];
            app.NoiseSlider.MajorTickLabels = string(0:0.20:1);
            app.NoiseSlider.Layout.Row = 4;
            app.NoiseSlider.Layout.Column = 2;
            app.NoiseSlider.Value = app.NoiseThreshold * 100;
            app.NoiseSlider.Limits = [0 100];
            app.NoiseSlider.ValueChangedFcn = app.createCallbackFcn(@noiseThresholdValueChanged, true);
            app.NoiseSlider.ValueChangingFcn = app.createCallbackFcn(@noiseThresholdValueChanged, true);
        end
        
        function createImageSpinner(app)
            app.ImageSpinner = uispinner(app.ChildGridLayout1);
            app.ImageSpinner.Layout.Row = 1;
            app.ImageSpinner.Layout.Column = 3;
            app.ImageSpinner.Limits = [0 1];
            app.ImageSpinner.Step = 0.01;
            app.ImageSpinner.Value = app.Image;
            app.ImageSpinner.ValueChangedFcn = app.createCallbackFcn(@imageValueChanged, true);
        end
        
        function createVmaxSpinner(app)
            app.VmaxSpinner = uispinner(app.ChildGridLayout1);
            app.VmaxSpinner.Layout.Row = 2;
            app.VmaxSpinner.Layout.Column = 3;
            app.VmaxSpinner.Limits = [0 1];
            app.VmaxSpinner.Step = 0.01;
            app.VmaxSpinner.Value = app.Vmax;
            app.VmaxSpinner.ValueChangedFcn = app.createCallbackFcn(@vmaxValueChanged, true);
        end
        
        function createCDSpinner(app)
            app.CDSpinner = uispinner(app.ChildGridLayout1);
            app.CDSpinner.Layout.Row = 3;
            app.CDSpinner.Layout.Column = 3;
            app.CDSpinner.Limits = [0 1];
            app.CDSpinner.Step = 0.01;
            app.CDSpinner.Value = app.CDThreshold;
            app.CDSpinner.ValueChangedFcn = app.createCallbackFcn(@cdThresholdValueChanged, true);
        end
        
        function createNoiseSpinner(app)
            app.NoiseSpinner = uispinner(app.ChildGridLayout1);
            app.NoiseSpinner.Layout.Row = 4;
            app.NoiseSpinner.Layout.Column = 3;
            app.NoiseSpinner.Limits = [0 1];
            app.NoiseSpinner.Step = 0.01;
            app.NoiseSpinner.Value = app.NoiseThreshold;
            app.NoiseSpinner.ValueChangedFcn = app.createCallbackFcn(@noiseThresholdValueChanged, true);
        end
        
        function createFitOrderSpinner(app)
            app.FitOrderSpinner = uispinner(app.ChildGridLayout1);
            app.FitOrderSpinner.Layout.Row = 5;
            app.FitOrderSpinner.Layout.Column = 3;
            app.FitOrderSpinner.Limits = [0 inf];
            app.FitOrderSpinner.Step = 1;
            app.FitOrderSpinner.Value = app.FitOrder;
            app.FitOrderSpinner.ValueChangedFcn = app.createCallbackFcn(@fitOrderValueChanged, true);
        end
        
        function createApplyCorrectionCheckbox(app)
            app.ApplyCorrectionCheckbox = uicheckbox(app.ChildGridLayout2);
            app.ApplyCorrectionCheckbox.Layout.Row = 1;
            app.ApplyCorrectionCheckbox.Layout.Column = 1;
            app.ApplyCorrectionCheckbox.Text = 'Apply Correction';
            app.ApplyCorrectionCheckbox.Value = app.ApplyCorrection;
            app.ApplyCorrectionCheckbox.ValueChangedFcn = app.createCallbackFcn(@applyCorrectionValueChanged, true);
        end
        
        function createUpdateButton(app)
            app.UpdateButton = uibutton(app.ChildGridLayout2, 'push');
            app.UpdateButton.Layout.Row = 2;
            app.UpdateButton.Layout.Column = 1;
            app.UpdateButton.Text = 'Update Images';
            app.UpdateButton.ButtonPushedFcn = app.createCallbackFcn(@updateButtonPushed, true);
        end
        
        function createResetFitButton(app)
            app.ResetFitButton = uibutton(app.ChildGridLayout2, 'push');
            app.ResetFitButton.Layout.Row = 3;
            app.ResetFitButton.Layout.Column = 1;
            app.ResetFitButton.Text = 'Reset Fit';
            app.ResetFitButton.ButtonPushedFcn = app.createCallbackFcn(@resetFitButtonPushed, true);
        end
        
        function createDoneButton(app)
            app.DoneButton = uibutton(app.ChildGridLayout2, 'push');
            app.DoneButton.Layout.Row = 4;
            app.DoneButton.Layout.Column = 1;
            app.DoneButton.Text = 'Done';
            app.DoneButton.ButtonPushedFcn = app.createCallbackFcn(@doneButtonPushed, true);
        end

    end
    
    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, centerlineToolApp)
            app.CenterlineToolApp = centerlineToolApp;
            app.VX = app.CenterlineToolApp.VIPR.VelocityMean(:,:,:,1);
            app.VY = app.CenterlineToolApp.VIPR.VelocityMean(:,:,:,2);
            app.VZ = app.CenterlineToolApp.VIPR.VelocityMean(:,:,:,3);
            app.PhaseCorrection = BackgroundPhaseCorrection();
            app.loadApp();
            app.updateImages();
        end

        % Value changed function: ImageSlider and ImageSpinner
        function imageValueChanged(app, event)
            src = event.Source.Type;
            value = event.Value;
            
            switch src
                case 'uislider'
                    app.ImageSlider.Value = value;
                    value = floor(value) / 100;
                    app.ImageSpinner.Value = value;
                case 'uispinner'
                    app.ImageSpinner.Value = value;
                    value = round(value, 2) * 100;
                    app.ImageSlider.Value = value;
                    value = value / 100;
            end

            app.PhaseCorrection.Image = value;
            app.updateImages();
        end

        % Value changed function: VmaxSlider and VmaxSpinner
        function vmaxValueChanged(app, event)
            src = event.Source.Type;
            value = event.Value;
            
            switch src
                case 'uislider'
                    app.VmaxSlider.Value = value;
                    value = floor(value) / 100;
                    app.VmaxSpinner.Value = value;
                case 'uispinner'
                    app.VmaxSpinner.Value = value;
                    value = round(value, 2) * 100;
                    app.VmaxSlider.Value = value;
                    value = value / 100;
            end

            app.PhaseCorrection.Vmax = value;
            app.updateImages();
        end

        % Value changed function: CDSlider and CDSpinner
        function cdThresholdValueChanged(app, event)
            src = event.Source.Type;
            value = event.Value;
            
            switch src
                case 'uislider'
                    app.CDSlider.Value = value;
                    value = floor(value) / 100;
                    app.CDSpinner.Value = value;
                case 'uispinner'
                    app.CDSpinner.Value = value;
                    value = round(value, 2) * 100;
                    app.CDSlider.Value = value;
                    value = value / 100;
            end
            
            app.PhaseCorrection.CDThreshold = value;
            app.updateImages();
        end

        % Value changed function: NoiseSlider and NoiseSpinner
        function noiseThresholdValueChanged(app, event)
            src = event.Source.Type;
            value = event.Value;
            
            switch src
                case 'uislider'
                    app.NoiseSlider.Value = value;
                    value = floor(value) / 100;
                    app.NoiseSpinner.Value = value;
                case 'uispinner'
                    app.NoiseSpinner.Value = value;
                    value = round(value, 2) * 100;
                    app.NoiseSlider.Value = value;
                    value = value / 100;
            end
            app.PhaseCorrection.NoiseThreshold = value;
            app.updateImages();
        end

        % Value changed function: FitOrderSlider and FitOrderSpinner
        function fitOrderValueChanged(app, event)
            value = floor(event.Value);
            app.PhaseCorrection.FitOrder = value;
            app.updateImages();
        end
        
        % Value Changed function: ApplyCorrectionCheckBox
        function applyCorrectionValueChanged(app, event)
            value = event.Value;
            app.PhaseCorrection.ApplyCorrection = value;
        end
        
        % Button pushed function: ResetFitButton
        function resetFitButtonPushed(app, ~)
            app.PhaseCorrection.resetFit();
            app.updateImages();
        end

        % Button pushed function: UpdateButton
        function updateButtonPushed(app, ~)
            mask = app.PhaseCorrection.createAngiogram(app.CenterlineToolApp.VIPR.MAG, app.CenterlineToolApp.VIPR.VelocityEncoding);
            app.PhaseCorrection.polyFit3d(mask);
            app.updateImages();
        end

        % Button pushed function: DoneButton
        function doneButtonPushed(app, ~)
            % init waitbar dialog
            dlg = uiprogressdlg(app.UIFigure);
            dlg.Title = 'Background Phase Correction';
            dlg.Indeterminate = 'on';
            
            dlg.Message = 'Correcting for polynomial';
            velocityMean = app.PhaseCorrection.polyCorrection( ...
                app.CenterlineToolApp.VIPR.MAG, ...
                app.CenterlineToolApp.VIPR.Velocity,...
                app.CenterlineToolApp.VIPR.VelocityMean, ...
                app.CenterlineToolApp.VIPR.NoFrames, ...
                dlg);
            
            dlg.Message = 'Calculating angiogram';
            timeMIP = app.PhaseCorrection.calculateAngiogram(...
                app.CenterlineToolApp.VIPR.MAG, ...
                app.CenterlineToolApp.VIPR.VelocityMean, ...
                app.CenterlineToolApp.VIPR.VelocityEncoding, ...
                dlg);
            
            dlg.Message = 'Calculating segment';
            segment = app.PhaseCorrection.calculateSegment(...
                app.CenterlineToolApp.VIPR.Resolution, ...
                app.CenterlineToolApp.VIPR.TimeMIP, ...
                dlg);
            
            app.CenterlineToolApp.setPhaseCorrectionParameters(velocityMean, timeMIP, segment);
            
            dlg.Message = 'Saving parameters';
            app.saveApp();
            app.uiFigureCloseRequest();
        end
        
        % Window key pressed function
        function uiWindowKeyPressFcn(app, event)
            switch char(event.Modifier)
                case 'control'
                    if strcmpi(event.Key, 'w')
                        uiFigureCloseRequest(app);
                    end
            end
        end

        % Close request function: UIFigure
        function uiFigureCloseRequest(app, ~)
            delete(app);
        end
        
    end

    % general methods
    methods (Access = private)
             
        function updateImages(app)
            [magSlice, velocitySlice] = app.PhaseCorrection.getSlices(...
                                            app.CenterlineToolApp.VIPR.MAG, ...
                                            app.CenterlineToolApp.VIPR.VelocityEncoding);
            app.MagImage.CData = magSlice;
            app.VelocityImage.CData = velocitySlice;
        end
        
    end

    % custom IO methods for Apps
    methods (Access = private)
       %{
            app designer objects cannot utilize 'saveobj' and 'loadoabj'
            properly
            this is a workaround to that to save only necessary data that,
            when combined with the required input arg to the app, will
            restore the previous state
        %}
        
        function saveApp(app)
            disp("Saving background phase correction parameters...");
            directory = fullfile(app.CenterlineToolApp.VIPR.DataDirectory, 'saved_analysis');
            if ~exist(directory, 'dir')
                mkdir(directory);
            end
            fname = 'phase_correction.mat';
            s.Image = app.PhaseCorrection.Image;
            s.Vmax = app.PhaseCorrection.Vmax;
            s.CDThreshold = app.PhaseCorrection.CDThreshold;
            s.NoiseThreshold = app.PhaseCorrection.NoiseThreshold;
            s.FitOrder = app.PhaseCorrection.FitOrder;
            s.ApplyCorrection = app.PhaseCorrection.ApplyCorrection;
            s.PolyFit = app.PhaseCorrection.PolyFit;
            save(fullfile(directory, fname), 's', '-v7.3', '-nocompression');
        end
        
        function loadApp(app)
            directory = fullfile(app.CenterlineToolApp.VIPR.DataDirectory, 'saved_analysis');
            fname = 'phase_correction.mat';
            
            if exist(fullfile(directory, fname), 'file')
                load(fullfile(directory, fname), 's');
                app.PhaseCorrection.Image = s.Image;
                app.PhaseCorrection.Vmax = s.Vmax;
                app.PhaseCorrection.CDThreshold = s.CDThreshold;
                app.PhaseCorrection.NoiseThreshold = s.NoiseThreshold;
                app.PhaseCorrection.FitOrder = s.FitOrder;
                app.PhaseCorrection.ApplyCorrection = s.ApplyCorrection;
                app.PhaseCorrection.PolyFit = s.PolyFit;
                
                app.ImageSlider.Value = app.PhaseCorrection.Image * 100;
                app.ImageSpinner.Value = app.PhaseCorrection.Image;
                app.VmaxSlider.Value = app.PhaseCorrection.Vmax * 100;
                app.VmaxSpinner.Value = app.PhaseCorrection.Vmax;
                app.CDSlider.Value = app.PhaseCorrection.CDThreshold * 100;
                app.CDSpinner.Value = app.PhaseCorrection.CDThreshold;
                app.NoiseSlider.Value = app.PhaseCorrection.NoiseThreshold * 100;
                app.NoiseSpinner.Value = app.PhaseCorrection.NoiseThreshold;
            end
        end
        
    end

end