classdef Controller < handle
    %{
    Following MVC design, this is the main class that coordinates the GUI,
    underlying data, and business logic.
    
    Business logic methods are stored here.
    Data is stored in Model.
    UI components are in the Views. Data for images, etc. are stored in the
    Model.
    
    Style Convention:
        *PascalCase for properties
        *camelCase for methods
        *snake_case for variables
        *PascalCase for names in name-value pairs to follow Matlab style
    
    Abbreviations/Acronyms
        *bgpc = BackGround Phase Correction

    %}
    
    properties (Access = public)
        View;
        Model;
    end
    
    properties (Access = private)
        State   AppState;
    end
    
    methods (Access = public)
        
        function self = Controller()
            clc;
            self.View = BaseView(self);
            self.Model = Model();
            self.State = AppState.Main;
        end
        
        function delete(self)
            delete(self.View.UIFigure);
            delete(self.View);
            delete(self.Model);
        end
        
    end
    
    % callbacks for main figure window
    methods (Access = public)
        
        function UIFigureCloseRequest(self, src, evt)
            self.delete();
        end
        
        function UIWindowKeyPressFcn(self, src, evt)
            switch char(evt.Modifier)
                case 'control'
                    if strcmpi(evt.Key, 'w')
                        self.delete();
                    end
            end
        end
        
    end
    
    % callbacks from menu
    methods (Access = public)
        
        function backgroundPhaseCorrectionMenuButtonCallback(self, src, evt)
            % display background phase correction images and widgets
            % don't reload if it's currently in this state
            if strcmp(self.State, 'BackgroundPhaseCorrection')
                return;
            end
            BackgroundPhaseCorrectionView(self);
            self.State = AppState.BackgroundPhaseCorrection;
        end
        
        function connectToDbMenuButtonCallback(self, src, evt)
            % todo: create inputdlg for db parameters
        end
        
        function loadDataMenuButtonCallback(self, src, evt)
            if isfolder(self.Model.DataDirectory)
                data_directory = uigetdir(self.Model.DataDirectory);
            else
                data_directory = uigetdir(pwd);
            end
            
            if data_directory == 0
                return;
            end
            self.Model.DataDirectory = data_directory;
            
            self.Model.VelocityFS = LoadViprDS.getVelocityFileDataStore(self.Model.DataDirectory);
            self.Model.VelocityMeanFS = LoadViprDS.getVelocityMeanFileDataStore(self.Model.DataDirectory);
            self.Model.MagDS = LoadViprDS.getMagFileDataStore(self.Model.DataDirectory);
        end
        
        function setDataOutputPathMenuButtonCallback(self, src, evt)
            out = self.Model.someFcn();
            disp(out);
        end
        
        function exitMenuButtonCallback(self, src, evt)
            self.delete();
        end
        
        function testDbConnectionMenuButtonCallback(self, src, evt)
        end
        
        function drawROIMenuButtonCallback(self, src, evt)
        end
        
        function viewFullVasculatureMenuButtonCallback(self, src, evt)
        end
        
        function viewParametricMapMenuButtonCallback(self, src, evt)
        end
        
        function vesselSelectionMenuButtonCallback(self, src, evt)
            if strcmp(self.State, 'VesselSelect')
                return;
            end
            
            VesselSelectionView(self);
            self.State = AppState.VesselSelect;
        end
        
        function segmentVesselsMenuButtonCallback(self, src, evt)
        end
        
        function vessel3dMenuButtonCallback(self, src, evt)
        end
        
        function parameterPlotMenuButtonCallback(self, src, evt)
        end
        
        function setDataOutputParametersMenuCallback(self, src, evt)
        end
        
    end

    % callbacks from BackgroundPhaseCorrectionView
    methods (Access = public)
        
        function bgpcImageValueChangedCallback(self, src, evt)
            value = evt.Value;
            
            switch evt.Source.Type
                case 'uislider'
                    src.ImageSlider.Value = value;
                    value = floor(value) / 100;
                    src.ImageSpinner.Value = value;
                case 'uispinner'
                    src.ImageSpinner.Value = value;
                    value = round(value, 2) * 100;
                    src.ImageSlider.Value = value;
                    value = value / 100;
            end

            self.Model.Image = value;
%             src.update_images();
        end
        
        function bgpcVmaxValueChangedCallback(self, src, evt)
            value = evt.Value;
            
            switch evt.Source.Type
                case 'uislider'
                    src.VmaxSlider.Value = value;
                    value = floor(value) / 100;
                    src.VmaxSpinner.Value = value;
                case 'uispinner'
                    src.VmaxSpinner.Value = value;
                    value = round(value, 2) * 100;
                    src.VmaxSlider.Value = value;
                    value = value / 100;
            end

            self.Model.Vmax = value;
%             src.update_images();
        end
        
        function bgpcCdThresholdValueChangedCallback(self, src, evt)
            value = evt.Value;
            
            switch evt.Source.Type
                case 'uislider'
                    src.CDSlider.Value = value;
                    value = floor(value) / 100;
                    src.CDSpinner.Value = value;
                case 'uispinner'
                    src.CDSpinner.Value = value;
                    value = round(value, 2) * 100;
                    src.CDSlider.Value = value;
                    value = value / 100;
            end

            self.Model.CDThreshold = value;
%             src.update_images();
        end
        
        function bgpcNoiseThresholdValueChangedCallback(self, src, evt)
            value = evt.Value;
            
            switch evt.Source.Type
                case 'uislider'
                    src.NoiseThresholdSlider.Value = value;
                    value = floor(value) / 100;
                    src.NoiseThresholdSpinner.Value = value;
                case 'uispinner'
                    src.NoiseThresholdSpinner.Value = value;
                    value = round(value, 2) * 100;
                    src.NoiseThresholdSlider.Value = value;
                    value = value / 100;
            end

            self.Model.NoiseThreshold = value;
%             src.update_images();
        end
        
        function bgpcFitOrderValueChangedCallback(self, src, evt)
            value = floor(evt.Value);
            self.Model.FitOrder = value;
%             src.update_images();
        end
        
        function bgpcApplyCorrectionValueChangedCallback(self, src, evt)
            value = evt.Value;
            self.Model.ApplyCorrection = value;
        end
        
        function bgpcUpdateButtonPushed(self, src, evt)
            % todo: get args to pass in
            mask = BackgroundPhaseCorrection.createAngiogram();
            app.poly_fit_3d(mask);
            app.update_images();
        end
        
        function bgpcResetFitButtonPushed(self, src, evt)
            app.reset_fit();
            app.update_images();
        end
        
        function bgpcDoneButtonPushed(self, src, evt)
            app.CenterlineToolApp.VIPR = app.poly_correction(app.CenterlineToolApp.VIPR);
            app.CenterlineToolApp.VIPR.TimeMIP = CalculateAngiogram.calculate_angiogram(app.CenterlineToolApp.VIPR);
            [~, app.CenterlineToolApp.VIPR.Segment] = CalculateSegment(app.CenterlineToolApp.VIPR);
            app.save_();
        end

    end
    
    % callbacks from VesselSelectionView
    methods (Access = public)
        
        function vsContextMenuOptionSelected(self, src, evt)
            disp(evt);
        end
        
        function vsDoneButtonPushed(self, src, evt)
            disp(evt);
        end
        
        function vsVesselTableCellSelection(self, src, evt)
            disp(evt);
        end
        
        function vsToolbarValueChanged(self, src, evt)
            disp(evt);
        end
        
    end
    
    % bgpc methods
    methods (Access = private)
        
        function bgpcUpdateImages(self)
            [mag_slice, velocity_slice] = app.get_slices(app.CenterlineToolApp.VIPR);
            app.MagImage.CData = mag_slice;
            app.VelocityImage.CData = velocity_slice;
        end
        
    end
    
end