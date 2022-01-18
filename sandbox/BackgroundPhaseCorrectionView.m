classdef BackgroundPhaseCorrectionView < matlab.apps.AppBase
    
    properties (Access = private)
        UIFigure
        ParentGridLayout            matlab.ui.container.GridLayout;
        ChildGridLayout1            matlab.ui.container.GridLayout;
        ChildGridLayout2            matlab.ui.container.GridLayout;
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
        
        % todo: should I move this to controller or even model??
        MagImage;
        VelocityImage;
        Map = [gray(200); jet(10)];
    end
    
    methods (Access = public)
        
        function app = BackgroundPhaseCorrectionView(controller)
            app.UIFigure = controller.View.UIFigure;
            app.createComponents(controller)
        end
        
    end
    
    methods (Access = private)
        % Create UIFigure and components
        function createComponents(app, controller)
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
            
            app.init_image_slider(controller);
            app.init_vmax_slider(controller);
            app.init_cd_slider(controller);
            app.init_noise_slider(controller);
            
            app.init_image_spinner(controller);
            app.init_vmax_spinner(controller);
            app.init_cd_spinner(controller);
            app.init_noise_spinner(controller);
            app.init_fit_order_spinner(controller);
            
            app.init_apply_correction_cb(controller);
            app.init_update_button(controller);
            app.init_reset_fit_button(controller);
            app.init_done_button(controller);
            
            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
            
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
        
        function init_image_slider(app, controller)
            app.ImageSlider = uislider(app.ChildGridLayout1);
            app.ImageSlider.Layout.Row = 1;
            app.ImageSlider.Layout.Column = 2;
            app.ImageSlider.MajorTicks = [0:20:100];
            app.ImageSlider.MinorTicks = [0:5:100];
            app.ImageSlider.MajorTickLabels = string(0:0.2:1.0);
            app.ImageSlider.Limits = [0 100];
            app.ImageSlider.Value = controller.Model.Image * 100;
            app.ImageSlider.ValueChangedFcn = app.createCallbackFcn(@image_value_changed, true);
            app.ImageSlider.ValueChangingFcn = app.createCallbackFcn(@image_value_changed, true);
        end
        
        function init_vmax_slider(app, controller)
            app.VmaxSlider = uislider(app.ChildGridLayout1);
            app.VmaxSlider.Layout.Row = 2;
            app.VmaxSlider.Layout.Column = 2;
            app.VmaxSlider.MajorTicks = [0:20:100];
            app.VmaxSlider.MinorTicks = [5:5:100];
            app.VmaxSlider.MajorTickLabels = string(0:0.2:1.0);
            app.VmaxSlider.Value = controller.Model.Vmax;
            app.VmaxSlider.Limits = [0 100];
            app.VmaxSlider.ValueChangedFcn = app.createCallbackFcn(@vmax_value_changed, true);
            app.VmaxSlider.ValueChangingFcn = app.createCallbackFcn(@vmax_value_changed, true);
        end
        
        function init_cd_slider(app, controller)
            app.CDSlider = uislider(app.ChildGridLayout1);
            app.CDSlider.Layout.Row = 3;
            app.CDSlider.Layout.Column = 2;
            app.CDSlider.MajorTicks = [0:20:100];
            app.CDSlider.MinorTicks = [5:5:100];
            app.CDSlider.MajorTickLabels = string(0:0.2:1.0);
            app.CDSlider.Value = controller.Model.CDThreshold * 100;
            app.CDSlider.Limits = [0 100];
            app.CDSlider.ValueChangedFcn = app.createCallbackFcn(@cd_threshold_value_changed, true);
            app.CDSlider.ValueChangingFcn = app.createCallbackFcn(@cd_threshold_value_changed, true);
        end
        
        function init_noise_slider(app, controller)
            app.NoiseSlider = uislider(app.ChildGridLayout1);
            app.NoiseSlider.MajorTicks = [0:20:100];
            app.NoiseSlider.MinorTicks = [5:5:100];
            app.NoiseSlider.MajorTickLabels = string(0:0.2:1.0);
            app.NoiseSlider.Layout.Row = 4;
            app.NoiseSlider.Layout.Column = 2;
            app.NoiseSlider.Value = controller.Model.NoiseThreshold * 100;
            app.NoiseSlider.Limits = [0 100];
            app.NoiseSlider.ValueChangedFcn = app.createCallbackFcn(@noise_threshold_value_changed, true);
            app.NoiseSlider.ValueChangingFcn = app.createCallbackFcn(@noise_threshold_value_changed, true);
        end
                
        function init_image_spinner(app, controller)
            app.ImageSpinner = uispinner(app.ChildGridLayout1);
            app.ImageSpinner.Layout.Row = 1;
            app.ImageSpinner.Layout.Column = 3;
            app.ImageSpinner.Limits = [0 1];
            app.ImageSpinner.Step = 0.01;
            app.ImageSpinner.Value = controller.Model.Image;
            app.ImageSpinner.ValueChangedFcn = app.createCallbackFcn(@image_value_changed, true);
        end
        
        function init_vmax_spinner(app, controller)
            app.VmaxSpinner = uispinner(app.ChildGridLayout1);
            app.VmaxSpinner.Layout.Row = 2;
            app.VmaxSpinner.Layout.Column = 3;
            app.VmaxSpinner.Limits = [0 1];
            app.VmaxSpinner.Step = 0.01;
            app.VmaxSpinner.Value = controller.Model.Vmax;
            app.VmaxSpinner.ValueChangedFcn = app.createCallbackFcn(@vmax_value_changed, true);
        end
        
        function init_cd_spinner(app, controller)
            app.CDSpinner = uispinner(app.ChildGridLayout1);
            app.CDSpinner.Layout.Row = 3;
            app.CDSpinner.Layout.Column = 3;
            app.CDSpinner.Limits = [0 1];
            app.CDSpinner.Step = 0.01;
            app.CDSpinner.Value = controller.Model.CDThreshold;
            app.CDSpinner.ValueChangedFcn = app.createCallbackFcn(@cd_threshold_value_changed, true);
        end
        
        function init_noise_spinner(app, controller)
            app.NoiseSpinner = uispinner(app.ChildGridLayout1);
            app.NoiseSpinner.Layout.Row = 4;
            app.NoiseSpinner.Layout.Column = 3;
            app.NoiseSpinner.Limits = [0 1];
            app.NoiseSpinner.Step = 0.01;
            app.NoiseSpinner.Value = controller.Model.NoiseThreshold;
            app.NoiseSpinner.ValueChangedFcn = app.createCallbackFcn(@noise_threshold_value_changed, true);
        end
        
        function init_fit_order_spinner(app, controller)
            app.FitOrderSpinner = uispinner(app.ChildGridLayout1);
            app.FitOrderSpinner.Layout.Row = 5;
            app.FitOrderSpinner.Layout.Column = 3;
            app.FitOrderSpinner.Limits = [0 inf];
            app.FitOrderSpinner.Step = 1;
            app.FitOrderSpinner.Value = controller.Model.FitOrder;
            app.FitOrderSpinner.ValueChangedFcn = app.createCallbackFcn(@fit_order_value_changed, true);
        end
        
        function init_apply_correction_cb(app, controller)
            app.ApplyCorrectionCheckbox = uicheckbox(app.ChildGridLayout2);
            app.ApplyCorrectionCheckbox.Layout.Row = 1;
            app.ApplyCorrectionCheckbox.Layout.Column = 1;
            app.ApplyCorrectionCheckbox.Text = 'Apply Correction';
            app.ApplyCorrectionCheckbox.Value = controller.Model.ApplyCorrection;
            app.ApplyCorrectionCheckbox.ValueChangedFcn = app.createCallbackFcn(@apply_correction_value_changed, true);
        end
        
        function init_update_button(app, controller)
            app.UpdateButton = uibutton(app.ChildGridLayout2, 'push');
            app.UpdateButton.Layout.Row = 2;
            app.UpdateButton.Layout.Column = 1;
            app.UpdateButton.Text = 'Update Images';
            app.UpdateButton.ButtonPushedFcn = app.createCallbackFcn(@update_button_pushed, true);
        end
        
        function init_reset_fit_button(app, controller)
            app.ResetFitButton = uibutton(app.ChildGridLayout2, 'push');
            app.ResetFitButton.Layout.Row = 3;
            app.ResetFitButton.Layout.Column = 1;
            app.ResetFitButton.Text = 'Reset Fit';
            app.ResetFitButton.ButtonPushedFcn = app.createCallbackFcn(@reset_fit_button_pushed, true);
        end
        
        function init_done_button(app, controller)
            app.DoneButton = uibutton(app.ChildGridLayout2, 'push');
            app.DoneButton.Layout.Row = 4;
            app.DoneButton.Layout.Column = 1;
            app.DoneButton.Text = 'Done';
            app.DoneButton.ButtonPushedFcn = app.createCallbackFcn(@controller.test, true);
        end

    end
    
    
end