classdef BackgroundPhaseCorrectionApp < matlab.apps.AppBase & BackgroundPhaseCorrection

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                    matlab.ui.Figure
        ParentGridLayout            matlab.ui.container.GridLayout
        ChildGridLayout1            matlab.ui.container.GridLayout
        ChildGridLayout2            matlab.ui.container.GridLayout
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
    
    properties (Access = private)
        CenterlineToolApp;
        MagImage;
        VelocityImage;
        Map = [gray(200); jet(10)];
    end
    
    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = BackgroundPhaseCorrectionApp(varargin)

            % Create UIFigure and components
            app.createComponents();

            % Register the app with App Designer
            app.registerApp(app.UIFigure);

            app.runStartupFcn(@(app)startupFcn(app, varargin{:}));
            
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
            app.init_figure();
            app.init_parent_grid();
            app.init_child_grid1();
            app.init_child_grid2();
            app.init_mag_axes();
            app.init_velocity_axes();
            app.init_image_label();
            app.init_vmax_label();
            app.init_cd_label();
            app.init_noise_label();
            app.init_fit_order_label();
            app.init_image_slider();
            app.init_vmax_slider();
            app.init_cd_slider();
            app.init_noise_slider();
            % app.init_fit_order_slider();
            app.init_image_spinner();
            app.init_vmax_spinner();
            app.init_cd_spinner();
            app.init_noise_spinner();
            app.init_fit_order_spinner();
            app.init_apply_correction_cb();
            app.init_update_button();
            app.init_reset_fit_button();
            app.init_done_button();
            
            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
           
        function init_figure(app)
            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Name = 'Background Phase Correction';
            app.UIFigure.WindowState = 'maximized';
            app.UIFigure.CloseRequestFcn = app.createCallbackFcn(@UIFigureCloseRequest, true);
            app.UIFigure.WindowKeyPressFcn = app.createCallbackFcn(@UIWindowKeyPressFcn, true);
        end

        % grid that divides the figure into quadrants
        % axes sit in column 1; buttons, sliders, etc. in column 2
        function init_parent_grid(app)
            app.ParentGridLayout = uigridlayout(app.UIFigure);
            app.ParentGridLayout.ColumnWidth = {'2x', '1x'};
            app.ParentGridLayout.RowHeight = {'1x', '1x'};
        end
        
        % grid housing labels, sliders, and spinners
        function init_child_grid1(app)
            app.ChildGridLayout1 = uigridlayout(app.ParentGridLayout);
            app.ChildGridLayout1.ColumnWidth = {'1x', '1x', '1x'};
            app.ChildGridLayout1.RowHeight = {'1x', '1x', '1x', '1x'};
            app.ChildGridLayout1.Layout.Row = 1;
            app.ChildGridLayout1.Layout.Column = 2;
        end

        % grid housing buttons
        function init_child_grid2(app)
            app.ChildGridLayout2 = uigridlayout(app.ParentGridLayout);
            app.ChildGridLayout2.ColumnWidth = {'1x'};
            app.ChildGridLayout2.RowHeight = {'1x', '1x', '1x', '1x'};
            app.ChildGridLayout2.Layout.Row = 2;
            app.ChildGridLayout2.Layout.Column = 2;
        end
        
        function init_mag_axes(app)
            % Create mag axes
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
        
        function init_velocity_axes(app)
            % Create velocity axes
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
        
        function init_image_label(app)
            app.ImageLabel = uilabel(app.ChildGridLayout1);
            app.ImageLabel.Layout.Row = 1;
            app.ImageLabel.Layout.Column = 1;
            app.ImageLabel.Text = 'Image';
        end
        
        function init_vmax_label(app)
            app.VmaxLabel = uilabel(app.ChildGridLayout1);
            app.VmaxLabel.Layout.Row = 2;
            app.VmaxLabel.Layout.Column = 1;
            app.VmaxLabel.Text = 'Vmax';
        end
        
        function init_cd_label(app)
            app.CDLabel = uilabel(app.ChildGridLayout1);
            app.CDLabel.Layout.Row = 3;
            app.CDLabel.Layout.Column = 1;
            app.CDLabel.Text = 'CD Threshold';
        end
        
        function init_noise_label(app)
            app.NoiseLabel = uilabel(app.ChildGridLayout1);
            app.NoiseLabel.Layout.Row = 4;
            app.NoiseLabel.Layout.Column = 1;
            app.NoiseLabel.Text = 'Noise Threshold';
        end
        
        function init_fit_order_label(app)
            app.FitOrderLabel = uilabel(app.ChildGridLayout1);
            app.FitOrderLabel.Layout.Row = 5;
            app.FitOrderLabel.Layout.Column = 1;
            app.FitOrderLabel.Text = 'Fit Order';
        end
        
        function init_image_slider(app)
            app.ImageSlider = uislider(app.ChildGridLayout1);
            app.ImageSlider.Layout.Row = 1;
            app.ImageSlider.Layout.Column = 2;
            app.ImageSlider.MajorTicks = [0:20:100];
            app.ImageSlider.MinorTicks = [5:5:100];
            app.ImageSlider.MajorTickLabels = string(0:20:100);
            app.ImageSlider.Limits = [0 100];
            app.ImageSlider.Value = app.Image * 100;
            app.ImageSlider.ValueChangedFcn = app.createCallbackFcn(@image_value_changed, true);
            app.ImageSlider.ValueChangingFcn = app.createCallbackFcn(@image_value_changed, true);
        end
        
        function init_vmax_slider(app)
            app.VmaxSlider = uislider(app.ChildGridLayout1);
            app.VmaxSlider.Layout.Row = 2;
            app.VmaxSlider.Layout.Column = 2;
            app.VmaxSlider.MajorTicks = [0:20:100];
            app.VmaxSlider.MinorTicks = [5:5:100];
            app.VmaxSlider.MajorTickLabels = string(0:20:100);
            app.VmaxSlider.Value = app.Vmax;
            app.VmaxSlider.Limits = [0 100];
            app.VmaxSlider.ValueChangedFcn = app.createCallbackFcn(@vmax_value_changed, true);
            app.VmaxSlider.ValueChangingFcn = app.createCallbackFcn(@vmax_value_changed, true);
        end
        
        function init_cd_slider(app)
            app.CDSlider = uislider(app.ChildGridLayout1);
            app.CDSlider.Layout.Row = 3;
            app.CDSlider.Layout.Column = 2;
            app.CDSlider.MajorTicks = [0:20:100];
            app.CDSlider.MinorTicks = [5:5:100];
            app.CDSlider.MajorTickLabels = string(0:20:100);
            app.CDSlider.Value = app.CDThreshold * 100;
            app.CDSlider.Limits = [0 100];
            app.CDSlider.ValueChangedFcn = app.createCallbackFcn(@cd_threshold_value_changed, true);
            app.CDSlider.ValueChangingFcn = app.createCallbackFcn(@cd_threshold_value_changed, true);
        end
        
        function init_noise_slider(app)
            app.NoiseSlider = uislider(app.ChildGridLayout1);
            app.NoiseSlider.MajorTicks = [0:20:100];
            app.NoiseSlider.MinorTicks = [5:5:100];
            app.NoiseSlider.MajorTickLabels = string(0:20:100);
            app.NoiseSlider.Layout.Row = 4;
            app.NoiseSlider.Layout.Column = 2;
            app.NoiseSlider.Value = app.NoiseThreshold * 100;
            app.NoiseSlider.Limits = [0 100];
            app.NoiseSlider.ValueChangedFcn = app.createCallbackFcn(@noise_threshold_value_changed, true);
            app.NoiseSlider.ValueChangingFcn = app.createCallbackFcn(@noise_threshold_value_changed, true);
        end
        
        %{
        function init_fit_order_slider(app)
            app.FitOrderSlider = uislider(app.ChildGridLayout1);
            app.FitOrderSlider.MajorTicks = [0:20:100];
            app.FitOrderSlider.MinorTicks = [5:5:100];
            app.FitOrderSlider.MajorTickLabels = string(0:20:100);
            app.FitOrderSlider.Layout.Row = 5;
            app.FitOrderSlider.Layout.Column = 2;
            app.FitOrderSlider.Value = app.FitOrder;
            app.FitOrderSlider.Limits = [0 100];
            app.FitOrderSlider.ValueChangedFcn = app.createCallbackFcn(@fit_order_value_changed, true);
            app.FitOrderSlider.ValueChangingFcn = app.createCallbackFcn(@fit_order_value_changed, true);
        end
        %}
        
        function init_image_spinner(app)
            app.ImageSpinner = uispinner(app.ChildGridLayout1);
            app.ImageSpinner.Layout.Row = 1;
            app.ImageSpinner.Layout.Column = 3;
            app.ImageSpinner.Limits = [0 1];
            app.ImageSpinner.Step = 0.01;
            app.ImageSpinner.Value = app.Image;
            app.ImageSpinner.ValueChangedFcn = app.createCallbackFcn(@image_value_changed, true);
        end
        
        function init_vmax_spinner(app)
            app.VmaxSpinner = uispinner(app.ChildGridLayout1);
            app.VmaxSpinner.Layout.Row = 2;
            app.VmaxSpinner.Layout.Column = 3;
            app.VmaxSpinner.Limits = [0 1];
            app.VmaxSpinner.Step = 0.01;
            app.VmaxSpinner.Value = app.Vmax;
            app.VmaxSpinner.ValueChangedFcn = app.createCallbackFcn(@vmax_value_changed, true);
        end
        
        function init_cd_spinner(app)
            app.CDSpinner = uispinner(app.ChildGridLayout1);
            app.CDSpinner.Layout.Row = 3;
            app.CDSpinner.Layout.Column = 3;
            app.CDSpinner.Limits = [0 1];
            app.CDSpinner.Step = 0.01;
            app.CDSpinner.Value = app.CDThreshold;
            app.CDSpinner.ValueChangedFcn = app.createCallbackFcn(@cd_threshold_value_changed, true);
        end
        
        function init_noise_spinner(app)
            app.NoiseSpinner = uispinner(app.ChildGridLayout1);
            app.NoiseSpinner.Layout.Row = 4;
            app.NoiseSpinner.Layout.Column = 3;
            app.NoiseSpinner.Limits = [0 1];
            app.NoiseSpinner.Step = 0.01;
            app.NoiseSpinner.Value = app.NoiseThreshold;
            app.NoiseSpinner.ValueChangedFcn = app.createCallbackFcn(@noise_threshold_value_changed, true);
        end
        
        function init_fit_order_spinner(app)
            app.FitOrderSpinner = uispinner(app.ChildGridLayout1);
            app.FitOrderSpinner.Layout.Row = 5;
            app.FitOrderSpinner.Layout.Column = 3;
            app.FitOrderSpinner.Limits = [0 inf];
            app.FitOrderSpinner.Step = 1;
            app.FitOrderSpinner.Value = app.FitOrder;
            app.FitOrderSpinner.ValueChangedFcn = app.createCallbackFcn(@fit_order_value_changed, true);
        end
        
        function init_apply_correction_cb(app)
            app.ApplyCorrectionCheckbox = uicheckbox(app.ChildGridLayout2);
            app.ApplyCorrectionCheckbox.Layout.Row = 1;
            app.ApplyCorrectionCheckbox.Layout.Column = 1;
            app.ApplyCorrectionCheckbox.Text = 'Apply Correction';
            app.ApplyCorrectionCheckbox.Value = app.ApplyCorrection;
            app.ApplyCorrectionCheckbox.ValueChangedFcn = app.createCallbackFcn(@apply_correction_value_changed, true);
        end
        
        function init_update_button(app)
            app.UpdateButton = uibutton(app.ChildGridLayout2, 'push');
            app.UpdateButton.Layout.Row = 2;
            app.UpdateButton.Layout.Column = 1;
            app.UpdateButton.Text = 'Update Images';
            app.UpdateButton.ButtonPushedFcn = app.createCallbackFcn(@update_button_pushed, true);
        end
        
        function init_reset_fit_button(app)
            app.ResetFitButton = uibutton(app.ChildGridLayout2, 'push');
            app.ResetFitButton.Layout.Row = 3;
            app.ResetFitButton.Layout.Column = 1;
            app.ResetFitButton.Text = 'Reset Fit';
            app.ResetFitButton.ButtonPushedFcn = app.createCallbackFcn(@reset_fit_button_pushed, true);
        end
        
        function init_done_button(app)
            app.DoneButton = uibutton(app.ChildGridLayout2, 'push');
            app.DoneButton.Layout.Row = 4;
            app.DoneButton.Layout.Column = 1;
            app.DoneButton.Text = 'Done';
            app.DoneButton.ButtonPushedFcn = app.createCallbackFcn(@done_button_pushed, true);
        end

    end
    
    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, varargin)
            app.CenterlineToolApp = varargin{1};
            app.VX = app.CenterlineToolApp.VIPR.VelocityMean(:,:,:,1);
            app.VY = app.CenterlineToolApp.VIPR.VelocityMean(:,:,:,2);
            app.VZ = app.CenterlineToolApp.VIPR.VelocityMean(:,:,:,3);
            app.load_();
            app.update_images();
        end

        % Value changed function: ImageSlider and ImageSpinner
        function image_value_changed(app, event)
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

            app.Image = value;
            app.update_images();
        end

        % Value changed function: VmaxSlider and VmaxSpinner
        function vmax_value_changed(app, event)
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

            app.Vmax = value;
            app.update_images();
        end

        % Value changed function: CDSlider and CDSpinner
        function cd_threshold_value_changed(app, event)
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
            
            app.CDThreshold = value;
            app.update_images();
        end

        % Value changed function: NoiseSlider and NoiseSpinner
        function noise_threshold_value_changed(app, event)
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
            app.NoiseThreshold = value;
            app.update_images();
        end

        % Value changed function: FitOrderSlider and FitOrderSpinner
        function fit_order_value_changed(app, event)
            value = floor(event.Value);
            app.FitOrder = value;
            app.update_images();
        end
        
        function apply_correction_value_changed(app, event)
            value = event.Value;
            app.ApplyCorrection = value;
        end
        
        % Button pushed function: ResetFitButton
        function reset_fit_button_pushed(app, event)
            app.reset_fit();
            app.update_images();
        end

        % Button pushed function: UpdateButton
        function update_button_pushed(app, event)
            mask = app.create_angiogram(app.CenterlineToolApp.VIPR.MAG);
            app.poly_fit_3d(mask);
            app.update_images();
        end

        % Button pushed function: DoneButton
        function done_button_pushed(app, event)
            app.UIFigure.WindowState = "minimized";
            waitfor(app.UIFigure, 'WindowState', 'minimized');
            app.CenterlineToolApp.VIPR = app.poly_correction(app.CenterlineToolApp.VIPR);
            app.CenterlineToolApp.VIPR.TimeMIP = CalculateAngiogram.calculate_angiogram(app.CenterlineToolApp.VIPR);
            [~, app.CenterlineToolApp.VIPR.Segment] = CalculateSegment(app.CenterlineToolApp.VIPR);
            app.save_();
            app.UIFigureCloseRequest();
        end
        
        % Window key pressed function
        function UIWindowKeyPressFcn(app, event)
            switch char(event.Modifier)
                case 'control'
                    if strcmpi(event.Key, 'w')
                        app.UIFigureCloseRequest();
                    end
            end
        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            delete(app);
        end
        
    end

    % general callbacks
    methods (Access = private)
             
        function update_images(app)
            [magSlice, velocitySlice] = app.get_slices(app.CenterlineToolApp.VIPR);
            app.MagImage.CData = magSlice;
            app.VelocityImage.CData = velocitySlice;
        end
        
    end

    % custom save method
    methods (Access = private)
       
        function save_(app)
            %{
            app designer objects cannot utilize 'saveobj' and 'loadoabj'
            properly
            this is a workaround to that to save only necessary data that,
            when combined with the required input arg to the app, will
            restore the previous state
            %}
            disp("Saving background phase correction parameters...");
            directory = fullfile(app.CenterlineToolApp.VIPR.DataDirectory, 'saved_analysis');
            if ~exist(directory, 'dir')
                mkdir(directory);
            end
            fname = 'phase_correction.mat';
            s.Image = app.Image;
            s.Vmax = app.Vmax;
            s.CDThreshold = app.CDThreshold;
            s.NoiseThreshold = app.NoiseThreshold;
            s.FitOrder = app.FitOrder;
            s.ApplyCorrection = app.ApplyCorrection;
            s.PolyFitX = app.PolyFitX;
            s.PolyFitY = app.PolyFitY;
            s.PolyFitZ = app.PolyFitZ;
            save(fullfile(directory, fname), 's', '-v7.3', '-nocompression');
        end
        
    end
    
    % custom load method
    methods (Access = private)
        
        function load_(app)
            %{
            app designer objects cannot utilize 'saveobj' and 'loadoabj'
            properly
            this is a workaround to that to load previously saved data that,
            when combined with the required input arg to the app, will
            restore the previous state
            %}
            directory = fullfile(app.CenterlineToolApp.VIPR.DataDirectory, 'saved_analysis');
            fname = 'phase_correction.mat';
            
            if exist(fullfile(directory, fname), 'file')
                load(fullfile(directory, fname), 's');
                app.Image = s.Image;
                app.Vmax = s.Vmax;
                app.CDThreshold = s.CDThreshold;
                app.NoiseThreshold = s.NoiseThreshold;
                app.FitOrder = s.FitOrder;
                app.ApplyCorrection = s.ApplyCorrection;
                app.PolyFitX = s.PolyFitX;
                app.PolyFitY = s.PolyFitY;
                app.PolyFitZ = s.PolyFitZ;
                
                app.ImageSlider.Value = app.Image * 100;
                app.ImageSpinner.Value = app.Image;
                app.VmaxSlider.Value = app.Vmax * 100;
                app.VmaxSpinner.Value = app.Vmax;
                app.CDSlider.Value = app.CDThreshold * 100;
                app.CDSpinner.Value = app.CDThreshold;
                app.NoiseSlider.Value = app.NoiseThreshold * 100;
                app.NoiseSpinner.Value = app.NoiseThreshold;
            end
        end
        
    end
    
end