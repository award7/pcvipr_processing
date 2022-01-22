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
        *vs = Vessel Selection
        *vs3d = Vessel 3D
        *pp = Parameter Plot

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
            self.View.setButtonState('TestDbConnectionMenuButton', ButtonState.off); 
            self.Model = BaseModel();
            self.State = AppState.FullVasculature;
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
        
        % file menu
        function exitMenuButtonCallback(self, src, evt)
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
            ProgressBarView(self.View.UIFigure, ...
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
            ProgressBarView(self.View.UIFigure, ...
                            'Message', msg, ...
                            'Indeterminate', 'on', ...
                            'Cancelable', 'on', ...
                            'Pause', 'on', ...
                            'Duration', 5);
            % create view
            BackgroundPhaseCorrectionView(self);
            
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
            ProgressBarView(self.View.UIFigure, ...
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
            ProgressBarView(self.View.UIFigure, ...
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
            ProgressBarView(self.View.UIFigure, ...
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
            if ~isnumeric(self.Model.DataDirectory) && isfolder(self.Model.DataDirectory)
                data_directory = uigetdir(self.Model.DataDirectory);
            else
                data_directory = uigetdir(pwd);
            end
            
            if data_directory == 0
                return;
            end
            
            % create progress bar for enhancing UX
            msg = 'Loading VIPR Files';
            ProgressBarView(self.View.UIFigure, ...
                            'Message', msg, ...
                            'Indeterminate', 'on', ...
                            'Cancelable', 'on');
            
            % load VIPR files into file datastores
            self.Model.DataDirectory = data_directory;
            self.Model.VelocityFS = LoadViprDS.getVelocityFileDataStore(self.Model.DataDirectory);
            self.Model.VelocityMeanFS = LoadViprDS.getVelocityMeanFileDataStore(self.Model.DataDirectory);
            self.Model.MagDS = LoadViprDS.getMagFileDataStore(self.Model.DataDirectory);
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
                uialert(self.View.UIFigure, ...
                        'Message', ME.message, ...
                        'Icon', 'error', ...
                        'Modal', true);
                return;
            end
            self.Model.DatabaseConnection = conn;
            self.View.setButtonState('TestDbConnectionMenuButton', ButtonState.on); 
        end
        
        function testDbConnectionMenuButtonCallback(self, src, evt)
            switch self.Model.DatabaseConnection.isOpen()
                case 0
                    msg = "Connection is closed or invalid.";
                    icon = "warning";
                case 1
                    msg = "Connection is active";
                    icon = "success";
            end
            
            uialert(self.View.UIFigure, ...
                    'Message', msg, ...
                    'Icon', icon, ...
                    'Modal', true);
        end
        
        function openDatabaseExplorerMenuButtonCallback(self, src, evt)
            ProgressBarView(self.View.UIFigure, ...
                            'Message', 'Opening Database Expolerer', ...
                            'Indeterminate', 'on', ...
                            'Cancelable', 'off', ...
                            'Pause', 'off');
            databaseExplorer();
        end
        
        function setDataOutputParametersMenuCallback(self, src, evt)
%             ProgressBarView(self.View.UIFigure, ...
%                             'Message', 'Opening Output Parameters', ...
%                             'Indeterminate', 'on', ...
%                             'Cancelable', 'off', ...
%                             'Pause', 'off');
            OutputParametersView(self);
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
    
    % callbacks from Vessel3DView
    methods (Access = public)
        
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
    methods (Access = public)
        
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