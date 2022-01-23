classdef BaseController < handle
    %{
    Following MVC design, this is the main class that coordinates the GUI,
    underlying data, and business logic.
    
    Business logic methods are stored here.
    Data is stored in BaseModel.
    UI components are in the Views. Data for images, etc. are stored in the
    BaseModel.
    
    Style Convention:
        *PascalCase for properties
        *camelCase for methods
        *snake_case for variables
        *PascalCase for names in name-value pairs to follow Matlab style
    
    Abbreviations/Acronyms
        *bgpc = BackGround Phase Correction
        *vs = Vessel Selection
        *vs3d = Vessel 3D
        *pp = Parameter Plot

    %}
    
    properties (Access = public)
        BaseView;
        BaseModel;
        ViprModel;
        BackgroundPhaseCorrectionModel;
    end
    
    properties (Access = private)
        State   AppState;
    end
    
    methods (Access = public)
        
        function self = BaseController()
            clc;
            self.BaseView = BaseView(self);
            self.BaseView.setButtonState('TestDbConnectionMenuButton', ButtonState.off); 
            self.BaseModel = BaseModel();
            self.State = AppState.FullVasculature;
        end
        
    end
    
    methods (Access = private)
        
        function delete(self)
            delete(self.BaseView.UIFigure);
            delete(self.BaseView);
            delete(self.BaseModel);
        end
        
    end
    
    % callbacks for main figure window
    methods (Access = public)
        
        function UIFigureCloseRequest(self, ~, ~)
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
    methods (Access = ?BaseView)
        
        % file menu
        function exitMenuButtonCallback(self, ~, ~)
            self.delete();
        end
        
        % analysis menu
        function viewFullVasculatureMenuButtonCallback(self, src, evt)
            % display full vasculature
            % don't reload if it's currently in this state
            if strcmp(self.State, 'FullVasculature')
                return;
            end
            
            % create progress bar for enhancing UX
            msg = 'Building Full Vascular Angiogram';
            ProgressBarView(self.BaseView.UIFigure, ...
                            'Message', msg, ...
                            'Indeterminate', 'on', ...
                            'Cancelable', 'on', ...
                            'Pause', 'on', ...
                            'Duration', 5);
            % create view
            % TODO: call view
            
            % change app state
            self.State = AppState.FullVasculature;
        end
        
        function backgroundPhaseCorrectionMenuButtonCallback(self, src, evt)
            % display background phase correction images and widgets
            % don't reload if it's currently in this state
            if strcmp(self.State, 'BackgroundPhaseCorrection')
                return;
            end
            
            % create progress bar for enhancing UX
            msg = 'Preparing Background Phase Correction';
            ProgressBarView(self.BaseView.UIFigure, ...
                            'Message', msg, ...
                            'Indeterminate', 'on', ...
                            'Cancelable', 'on', ...
                            'Pause', 'on', ...
                            'Duration', 5);
            
            if isempty(self.BackgroundPhaseCorrectionModel)
                % assign the BackgroundPhaseCorrectionModel object to the BackgroundPhaseCorrectionModel property of this class
                self.BackgroundPhaseCorrectionModel = BackgroundPhaseCorrectionModel();
            end
                        
            % create view
            view = BackgroundPhaseCorrectionView(self);
            self.BackgroundPhaseCorrectionModel.initMagImage(view.MagAxes);
            self.BackgroundPhaseCorrectionModel.initVelocityImage(view.VelocityAxes);
            
            % change app state
            self.State = AppState.BackgroundPhaseCorrection;
        end
        
        function drawROIMenuButtonCallback(self, src, evt)
            % todo: show error dialog 'Not Implemented'
        end
        
        function viewParametricMapMenuButtonCallback(self, src, evt)
            % todo: show error dialog 'Not Implemented'
            return;
        end
        
        function vesselSelectionMenuButtonCallback(self, src, evt)
            if strcmp(self.State, 'VesselSelect')
                return;
            end
            
            % create progress bar for enhancing UX
            msg = 'Rendering MR Images for Vessel Selection';
            ProgressBarView(self.BaseView.UIFigure, ...
                            'Message', msg, ...
                            'Indeterminate', 'on', ...
                            'Cancelable', 'on', ...
                            'Pause', 'on', ...
                            'Duration', 5);
            
            % create view
            VesselSelectionView(self);
            
            % change app state
            self.State = AppState.VesselSelect;
        end
        
        function segmentVesselsMenuButtonCallback(self, src, evt)
        end
        
        function vessel3dMenuButtonCallback(self, src, evt)
            % display segmented vasculature
            % don't reload if it's currently in this state
            if strcmp(self.State, 'Vessel3D')
                return;
            end
            
            % create progress bar for enhancing UX
            msg = 'Rendering Selected Vessels in 3D';
            ProgressBarView(self.BaseView.UIFigure, ...
                            'Message', msg, ...
                            'Indeterminate', 'on', ...
                            'Cancelable', 'on', ...
                            'Pause', 'on', ...
                            'Duration', 5);
            % create view
            Vessel3DView(self);
            
            % change app state
            self.State = AppState.Vessel3D;
        end
        
        function parameterPlotMenuButtonCallback(self, src, evt)
            % display parameter plots
            % don't reload if it's currently in this state
            if strcmp(self.State, 'ParameterPlot')
                return;
            end
            
            % create progress bar for enhancing UX
            msg = 'Plotting Vessel Parameters';
            ProgressBarView(self.BaseView.UIFigure, ...
                            'Message', msg, ...
                            'Indeterminate', 'on', ...
                            'Cancelable', 'on', ...
                            'Pause', 'on', ...
                            'Duration', 10);
            % create view
            ParameterPlotView(self);
            
            % change app state
            self.State = AppState.ParameterPlot;
        end
        
        % datasource menu
        function loadDataMenuButtonCallback(self, src, evt)
            if isempty(self.ViprModel)
                % assign the ViprModel object to the ViprModel property of this class
                self.ViprModel = ViprModel();
                data_directory = "";
            else
                data_directory = self.ViprModel.DataDirectory();
            end
            
            if ~isnumeric(data_directory) && isfolder(data_directory)
                data_directory = uigetdir(data_directory);
            else
                data_directory = uigetdir(pwd);
            end
            
            if data_directory == 0
                return;
            end
            
            % create progress bar for enhancing UX
            msg = 'Loading VIPR Files';
            ProgressBarView(self.BaseView.UIFigure, ...
                            'Message', msg, ...
                            'Indeterminate', 'on', ...
                            'Cancelable', 'on');
             
            % load VIPR files into file datastores
            velocity_fs = LoadViprDS.getVelocityFileDataStore(data_directory);
            self.ViprModel.setVelocityFS(velocity_fs);
            
            velocity_mean_fs = LoadViprDS.getVelocityMeanFileDataStore(data_directory);
            self.ViprModel.setVelocityMeanFS(velocity_mean_fs);
            
            mag_fs = LoadViprDS.getMagFileDataStore(data_directory);
            self.ViprModel.setMagFS(mag_fs);
            
            % get vipr parameters for processing and assign to model properties
            self.ViprModel.setDataDirectory(data_directory);
            vipr_struct = LoadViprDS.parseArray(data_directory);
            self.ViprModel.setFOV(vipr_struct.fovx/10);
            self.ViprModel.setTimeResolution(vipr_struct.timeres);
            self.ViprModel.setNoFrames(vipr_struct.frames);
            self.ViprModel.setResolution(vipr_struct.matrixx);
            self.ViprModel.setVelocityEncoding(vipr_struct.VENC);
            self.ViprModel.setScanParameters(vipr_struct);
        end
        
        function connectToDbMenuButtonCallback(self, src, evt)
            data_sources = (listDataSources().Name);
            [idx, status] = listdlg('ListString', data_sources, ...
                                    'SelectionMode', 'single', ...
                                    'ListSize', [300 300], ...
                                    'Name', 'Connect to Database', ...
                                    'PromptString', 'Select Data Source', ...
                                    'OKString', 'Connect', ...
                                    'CancelString', 'Cancel');
            
            if status == 0
                return;
            end
            
            try
                conn = database(data_sources(idx));
            catch ME
                uialert(self.BaseView.UIFigure, ...
                        'Message', ME.message, ...
                        'Icon', 'error', ...
                        'Modal', true);
                return;
            end
            self.BaseModel.DatabaseConnection = conn;
            self.BaseView.setButtonState('TestDbConnectionMenuButton', ButtonState.on); 
        end
        
        function testDbConnectionMenuButtonCallback(self, src, evt)
            switch self.BaseModel.DatabaseConnection.isOpen()
                case 0
                    msg = "Connection is closed or invalid.";
                    icon = "warning";
                case 1
                    msg = "Connection is active";
                    icon = "success";
            end
            
            uialert(self.BaseView.UIFigure, ...
                    'Message', msg, ...
                    'Icon', icon, ...
                    'Modal', true);
        end
        
        function openDatabaseExplorerMenuButtonCallback(self, src, evt)
            ProgressBarView(self.BaseView.UIFigure, ...
                            'Message', 'Opening Database Expolerer', ...
                            'Indeterminate', 'on', ...
                            'Cancelable', 'off', ...
                            'Pause', 'off');
            databaseExplorer();
        end
        
        function setDataOutputParametersMenuCallback(self, src, evt)
%             ProgressBarView(self.BaseView.UIFigure, ...
%                             'Message', 'Opening Output Parameters', ...
%                             'Indeterminate', 'on', ...
%                             'Cancelable', 'off', ...
%                             'Pause', 'off');
            OutputParametersView(self);
        end
        
    end

    % callbacks from BackgroundPhaseCorrectionView
    methods (Access = ?BackgroundPhaseCorrectionView)
        
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

            self.BackgroundPhaseCorrectionModel.setImage(value);
            % src.update_images();
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

            self.BaseModel.Vmax = value;
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

            self.BaseModel.CDThreshold = value;
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

            self.BaseModel.NoiseThreshold = value;
%             src.update_images();
        end
        
        function bgpcFitOrderValueChangedCallback(self, src, evt)
            value = floor(evt.Value);
            self.BaseModel.FitOrder = value;
%             src.update_images();
        end
        
        function bgpcApplyCorrectionValueChangedCallback(self, src, evt)
            value = evt.Value;
            self.BaseModel.ApplyCorrection = value;
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
    methods (Access = ?VesselSelectionView)
        
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
    
    % callbacks from Vessel3DView
    methods (Access = ?Vessel3DView)
        
        function vs3dToolbarValueChangedCallback(self, src, evt)
            disp(evt);
        end
        
        function vs3dVesselDropdownValueChanged(self, src, evt)
            disp(evt);
        end
        
        function vs3dIsolateButtonValueChanged(self, src, evt)
            disp(evt);
        end
        
        function vs3dLowerVoxelValueChanged(self, src, evt)
            disp(evt);
        end
        
        function vs3dWindowValueChanged(self, src, evt)
            disp(evt);
        end
        
        
    end
    
    % callbacks from ParameterPlotView
    methods (Access = ?ParameterPlotView)
        
        function ppLowerVoxelSpinnerValueChanged(self, src, evt)
            disp(evt);
        end
        
        function ppWindowSpinnerValueChanged(self, src, evt)
            disp(evt);
        end
        
        function ppSaveButtonPushed(self, src, evt)
            disp(evt);
        end
        
        function ppSpinnerSaveDataStartValueChanged(self, src, evt)
            disp(evt);
        end
        
        function ppSpinnerSaveDataEndValueChanged(self, src, evt)
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