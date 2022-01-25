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
        OutputParametersModel;
        VesselSelectionModel;
    end
    
    properties (Access = private)
        State   AppState;
    end
    
    % constructor
    methods (Access = public)
        
        function self = BaseController()
            clc;
            fprintf('Loading PC VIPR Processing...');
            
            self.BaseView = BaseView(self);
            
            buttons = string([...
                "ViewFullVasculatureMenuButton", ...
                "BackgroundPhaseCorrectionMenuButton", ...
                "DrawROIMenuButton", ...
                "ViewParametricMapMenuButton", ...
                "FeatureExtractionMenuButton", ...
                "VesselSelectionMenuButton", ...
                "SegmentVesselsMenuButton", ...
                "Vessel3dMenuButton", ...
                "ParameterPlotMenuButton", ...
                "TestDbConnectionMenuButton", ...
                "DisconnectDbMenuButton", ...
                "SetDataOutputParametersMenuButton"
                ]);
            self.setButtonState(buttons, ButtonState.off);
            
            self.BaseModel = BaseModel();
            
            pause(3);
            clc;
            
            self.State = AppState.FullVasculature;
        end
        
    end
    
    % deleter
    methods (Access = private)
        
        function delete(self)
            % todo: create dialog about saving current analysis/confirmation of exiting
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
    methods (Access = {?BaseView, ?BaseController})
        
        %%% file menu
        function exitMenuButtonCallback(self, ~, ~)
            self.delete();
        end
        
        %%% analysis menu
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
            dlg = ProgressBarView(self.BaseView.UIFigure, ...
                                'Message', msg, ...
                                'Indeterminate', 'on', ...
                                'Cancelable', 'off', ...
                                'Pause', 'on', ...
                                'Duration', 5);
            
            if isempty(self.BackgroundPhaseCorrectionModel)
                % assign the BackgroundPhaseCorrectionModel object to the BackgroundPhaseCorrectionModel property of this class
                self.BackgroundPhaseCorrectionModel = BackgroundPhaseCorrectionModel();
            end

            % create view
            view = BackgroundPhaseCorrectionView(self);
            
            % initialize some parameters
            poly_fit = BackgroundPhaseCorrection.resetFit;
            self.BackgroundPhaseCorrectionModel.setPolyFit(poly_fit);
            
            img = self.BackgroundPhaseCorrectionModel.WhiteImage();
            BackgroundPhaseCorrection.initImage(view.MagAxes, img);
            BackgroundPhaseCorrection.initImage(view.VelocityAxes, img);
            
            %%% get these datastores into memory for faster viewing of
            %%% images
            % allocate velocity mean array and read data from filestore
            res = self.ViprModel.Resolution;
            velocity_mean = zeros(res,res,res,3);
            self.ViprModel.VelocityMeanFS.reset;
            i = 1;
            while self.ViprModel.VelocityMeanFS.hasdata
                velocity_mean(:,:,:,i) = self.ViprModel.VelocityMeanFS.read();
                i = i + 1;
            end
            self.ViprModel.setVelocityMeanArray(velocity_mean);
            clear velocity_mean;
            
            % allocate MAG array and read MAG data from filestore
            mag = zeros(res,res,res);
            self.ViprModel.MagFS.reset;
            while self.ViprModel.MagFS.hasdata
                mag(:,:,:) = self.ViprModel.MagFS.read();
            end
            self.ViprModel.setMagArray(mag);
            clear mag;
            
            self.bgpcUpdateImages(view);
            
            % change app state
            self.State = AppState.BackgroundPhaseCorrection;
            dlg.close();
        end
        
        function drawROIMenuButtonCallback(self, src, evt)
            % todo: show error dialog 'Not Implemented'
        end
        
        function viewParametricMapMenuButtonCallback(self, src, evt)
            % todo: show error dialog 'Not Implemented'
            self.State = AppState.ParametricMap;
        end
        
        function featureExtractionMenuButtonCallback(self, src, evt)
            
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
            
            % create model
            self.VesselSelectionModel = VesselSelectionModel();
            % TODO: set model props
            
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
        
        %%% datasource menu
        function loadDataMenuButtonCallback(self, src, evt)
            % todo: add functionality to check for previous analysis and load that
            
            %%% create ViprModel, if needed, and open file selector
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
            
            %%% create progress bar for enhancing UX
            msg = 'Loading VIPR Files';
            ProgressBarView(self.BaseView.UIFigure, ...
                            'Message', msg, ...
                            'Indeterminate', 'on', ...
                            'Cancelable', 'on');
             
            %%% load VIPR files into file datastores
            velocity_fs = LoadViprDS.getVelocityFileDataStore(data_directory);
            velocity_mean_fs = LoadViprDS.getVelocityMeanFileDataStore(data_directory);
            mag_fs = LoadViprDS.getMagFileDataStore(data_directory);
            vipr_struct = LoadViprDS.parseArray(data_directory);
            
            %%% parse data directory to derive some props for OutputParametersModel
            % assumes the data lives in a hierarchy of /{root}/study/subject/visit/timepoint/dat
            % works back from dat
            folders = strsplit(data_directory, filesep);
            
            % rm empty element due to ending file separator
            folders(folders == "") = [];
            
            if strcmp(folders(end), 'dat')
                timepoint = string(folders(end-1));
                visit = string(folders(end-2));
                subject = string(folders(end-3));
                study = string(folders(end-4));
            end
            
            %%% make analysis directory in the data directory
            % if failed, notify and return as it's a catstrophic failure that 
            % will prevent saving analysis which is critical for downstream
            % processing
            [success, msg, ~] = mkdir(data_directory, 'analysis');
            if ~success
                uialert(self.BaseView.UIFigure, ...
                        msg, ...
                        'PC VIPR Processing', ...
                        'Icon', 'error', ...
                        'Modal', true);
                return;
            end
            
            if isempty(self.OutputParametersModel)
                % assign the OutputParametersModel object to the OutputParametersModel property of this class
                self.OutputParametersModel = OutputParametersModel();
            end
            
            %%% get datastores
%             velocity_ds = LoadViprDS.getVelocityDataStore(velocity_fs);
%             velocity_mean_ds = LoadViprDS.getVelocityMeanDataStore(velocity_mean_fs);
%             mag_ds = LoadViprDS.getMagDataStore(mag_fs);
%             self.ViprModel.setVelocityDS(velocity_ds);
%             self.ViprModel.setVelocityMeanDS(velocity_mean_ds);
%             self.ViprModel.setMagDS(mag_ds);
            
            %%% set model values
            self.ViprModel.setDataDirectory(data_directory);
            self.ViprModel.setVelocityFS(velocity_fs);
            self.ViprModel.setVelocityMeanFS(velocity_mean_fs);
            self.ViprModel.setMagFS(mag_fs);
            
            self.ViprModel.setFOV(vipr_struct.fovx/10);
            self.ViprModel.setTimeResolution(vipr_struct.timeres);
            self.ViprModel.setNoFrames(vipr_struct.frames);
            self.ViprModel.setResolution(vipr_struct.matrixx);
            self.ViprModel.setVelocityEncoding(vipr_struct.VENC);
            self.ViprModel.setScanParameters(vipr_struct);
            
            self.OutputParametersModel.setOutputPath(fullfile(data_directory, 'analysis'));
            self.OutputParametersModel.setStudy(study);
            self.OutputParametersModel.setSubject(subject);
            self.OutputParametersModel.setConditionOrVisit(visit);
            self.OutputParametersModel.setTimePoint(timepoint);
            
            %%% finish up
            % enable buttons
            buttons = [...
                "SetDataOutputParametersMenuButton", ...
                "ViewFullVasculatureMenuButton", ...
                "BackgroundPhaseCorrectionMenuButton", ...
                "DrawROIMenuButton", ...
                "ViewParametricMapMenuButton", ...
                "FeatureExtractionMenuButton", ...
                "VesselSelectionMenuButton", ...
                ];
            self.setButtonState(buttons, ButtonState.on);
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
            
            % create output parameters model object if not already exists
            self.createOutputParametersModelObject();
            
            try
                self.OutputParametersModel.DatabaseConnection.close;
                self.OutputParametersModel.setDatabaseConnection({''});
            catch me
                switch me.identifier
                    case 'MATLAB:structRefFromNonStruct'
                        % do nothing as the object doesn't exist
                    otherwise
                        rethrow(me);
                end
            end
            
            try
                conn = database(data_sources(idx), "", "");
            catch ME
                uialert(self.BaseView.UIFigure, ...
                        'Message', ME.message, ...
                        'Icon', 'error', ...
                        'Modal', true);
                return;
            end
            
            buttons = [...
                "SetDataOutputParametersMenuButton",...
                "TestDbConnectionMenuButton",...
                "DisconnectDbMenuButton"...
                ];
            self.setButtonState(buttons, ButtonState.on);
            self.OutputParametersModel.setDatabaseConnection(conn);
        end
        
        function testDbConnectionMenuButtonCallback(self, src, evt)
            switch self.OutputParametersModel.DatabaseConnection.isopen()
                case 0
                    msg = "Connection is closed or invalid";
                    icon = "warning";
                case 1
                    msg = sprintf("Connection is active:\n\n%s",...
                        self.OutputParametersModel.DatabaseConnection.DataSource);
                    icon = "success";
            end
            
            uialert(self.BaseView.UIFigure,...
                    msg,...
                    'Database Connection',...
                    'Icon', icon,...
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
        
        function disconnectDbMenuButtonCallback(self, src, evt)
            buttons = [...
                "DisconnectDbMenuButton"...
                ];
            self.setButtonState(buttons, ButtonState.off);
            self.OutputParametersModel.DatabaseConnection.close;
        end
        
        function setDataOutputParametersMenuCallback(self, src, evt)
            ProgressBarView(self.BaseView.UIFigure, ...
                            'Message', 'Opening Output Parameters', ...
                            'Indeterminate', 'on', ...
                            'Cancelable', 'off', ...
                            'Pause', 'off');
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
            self.bgpcUpdateImages(src);
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

            self.BackgroundPhaseCorrectionModel.setVmax(value);
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

            self.BackgroundPhaseCorrectionModel.setCDThreshold(value);
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

            self.BackgroundPhaseCorrectionModel.setNoiseThreshold(value);
%             src.update_images();
        end
        
        function bgpcFitOrderValueChangedCallback(self, src, evt)
            value = floor(evt.Value);
            self.BackgroundPhaseCorrectionModel.setFitOrder(value);
%             src.update_images();
        end
        
        function bgpcApplyCorrectionValueChangedCallback(self, src, evt)
            value = evt.Value;
            self.BackgroundPhaseCorrectionModel.setApplyCorrection(value);
        end
        
        function bgpcUpdateButtonPushed(self, src, evt)
            % todo: get args to pass in
            % mask = BackgroundPhaseCorrection.createAngiogram();
            % app.poly_fit_3d(mask);
            % app.update_images();
        end
        
        function bgpcResetFitButtonPushed(self, src, evt)
            % app.reset_fit();
            % app.update_images();
        end
        
        function bgpcDoneButtonPushed(self, src, evt)
            % get args for poly_correction
            % args.MAG = self.ViprModel.;
            args.velocity;
            args.velocity_mean;
            args.no_frames;
            args.poly_fit_x;
            args.poly_fit_y;
            args.poly_fit_z;
            args_array = namedargs2cell(args);
            correction_factor = BackgroundPhaseCorrection.polyCorrection(args_array{:});
            % time_mip = CalculateAngiogram.calculate_angiogram();
            % [~, segment] = CalculateSegment();
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
        
        %%% may not constitute callbacks
        % TODO: move to separate private methods????
%         function vsInitializeSlices(self)
%             % todo: get MAGr argument
%             self.VesselSelectionModel.setXSlice(floor(size(MAGR, 1)/2));
%             self.VesselSelectionModel.setYSlice(floor(size(MAGR, 2)/2));
%             self.VesselSelectionModel.setXSlice(floor(size(MAGR, 3)/2));
%         end
%         
%         function vsInitializeSliceMax(self)
%             % todo: get MAGr argument
%             self.VesselSelectionModel.setXSliceMax(size(MAGR, 1));
%             self.VesselSelectionModel.setYSliceMax(size(MAGR, 2));
%             self.VesselSelectionModel.setZSliceMax(size(MAGR, 3));
%         end
%         
%         function vsInitializeSagittalData(self)
%             self.SagittalData = zeros(320,320,3,self.XSliceMax, 'uint8');
%             
%             % returns a 320x320x3 array
%             for slice = self.AbsLowerBound:self.XSliceMax
%                 self.XSlice = slice;
%                 self.SagittalData(:,:,:,slice) = permute(cat(1, self.MAGR(self.XSlice,:,:), ...
%                                                                self.MAGG(self.XSlice,:,:), ...
%                                                                self.MAGB(self.XSlice,:,:)), ...
%                                                                [3 2 1]);
%             end
%         end
%         
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
    
    % callbacks from OutputParametersView
    methods (Access = ?OutputParametersView)
        
        function outputPathEditFieldValueChangedCallback(self, src, evt)
            % validate that input is a folder
            % if not, throw error dialog on view
            try
                self.OutputParametersModel.setOutputPath(evt.Value);
            catch me
                switch me.identifier
                    case {'MATLAB:validators:mustBeFolder', 'MATLAB:validators:mustBeNonzeroLengthText'}
                        msg = sprintf("The following folders do not exist: %s", evt.Value);
                        uialert(src.UIFigure, ...
                            msg, ...
                            'PC VIPR Processing', ...
                            'Icon', 'error', ...
                            'Modal', true);
                        src.OutputPathEditField.Value = evt.PreviousValue;
                end
            end
        end
        
        function openFileBrowserButtonButtonPushedCallback(self, src, evt)
            % open uigetdir
            % set chosen dir to outputpath in view and model
            
            if ~(self.OutputParametersModel.OutputAsCsv)
                return;
            end
            
            fpath = uigetdir(self.OutputParametersModel.OutputPath);
            
            if fpath == 0
                return;
            end
            src.OutputPathEditField.Value = fpath;
            self.OutputParametersModel.setOutputPath(fpath);
        end
        
        function outputAsCsvCheckBoxValueChangedCallback(self, src, evt)
            % when true = enable outputpath field
            % when false = disable outputpath field
            % update associated prop in model
            bool = logical(evt.Value);
            src.OutputPathEditField.Editable = bool;
            self.OutputParametersModel.setOutputAsCsv(bool);
        end
        
        function connectToDbButtonCallback(self, src, evt)
            self.connectToDbMenuButtonCallback(src, evt);
            src.DataSourceEditField.Value = self.OutputParametersModel.DatabaseConnection.DataSource;
            src.DatabaseDropDown.Items = self.OutputParametersModel.DatabaseList;
            src.TableDropDown.Items = self.OutputParametersModel.TableList;
        end
        
        function okButtonPushedCallback(self, src, evt)
            if src.OutputAsCsvCheckBox.Value
                try
                    self.OutputParametersModel.setOutputPath(src.OutputPathEditField.Value);
                catch me
                    switch me.identifier
                        case {'MATLAB:validators:mustBeFolder', 'MATLAB:validators:mustBeNonzeroLengthText'}
                            msg = sprintf("Invalid path: %s", src.OutputPathEditField.Value);
                            uialert(src.UIFigure,...
                                msg,...
                                'Error',...
                                'Icon', 'error',...
                                'Modal', true);
                            return;
                        otherwise
                            rethrow(me);
                    end
                end
            end
            
            self.OutputParametersModel.setStudy(src.StudyEditField.Value);
            self.OutputParametersModel.setSubject(src.SubjectEditField.Value);
            self.OutputParametersModel.setConditionOrVisit(src.ConditionVisitEditField.Value);
            self.OutputParametersModel.setTimePoint(src.TimePointEditField.Value);
            self.OutputParametersModel.setDatabaseTable(src.TableDropDown.Value);
            self.OutputParametersModel.setOutputAsCsv(logical(src.OutputAsCsvCheckBox.Value));
            src.delete();
        end

    end
    
    % bgpc methods
    methods (Access = private)
        
        function bgpcUpdateImages(self, view)            
            % package variables into struct
            args.mag = self.ViprModel.MagArray;
            args.velocity_mean = self.ViprModel.VelocityMeanArray;
            args.velocity_encoding = self.ViprModel.VelocityEncoding;
            args.resolution = self.ViprModel.Resolution;
            args.apply_correction = self.BackgroundPhaseCorrectionModel.ApplyCorrection;
            args.image = self.BackgroundPhaseCorrectionModel.Image;
            args.vmax = self.BackgroundPhaseCorrectionModel.Vmax;
            args.noise_threshold = self.BackgroundPhaseCorrectionModel.NoiseThreshold;
            args.cd_threshold = self.BackgroundPhaseCorrectionModel.CDThreshold;
            args.poly_fit = self.BackgroundPhaseCorrectionModel.PolyFit;
            
            args_array = namedargs2cell(args);
            [mag_slice, velocity_slice] = BackgroundPhaseCorrection.getSlices(args_array{:});
            self.BackgroundPhaseCorrectionModel.setMagImageCData(mag_slice);
            self.BackgroundPhaseCorrectionModel.setVelocityImageCData(velocity_slice);
            view.MagAxes.Children.CData = self.BackgroundPhaseCorrectionModel.MagImage.CData();
            view.VelocityAxes.Children.CData = self.BackgroundPhaseCorrectionModel.VelocityImage.CData();
        end
        
    end
    
    % helper methods
    methods (Access = private)
        
        function setEditFieldEditable(self, view, fields, state)
            arguments
                self;
                view    (1,1);
                fields  (1,:) {mustBeText, mustBeNonempty};
                state   (1,1) {mustBeUnderlyingType(state, 'ButtonState')};
            end
            
            for i = 1:length(fields)
                self.(view).(fields(i)).Editable = char(state);
            end
        end
        
        function setButtonState(self, buttons, state)
            arguments
                self;
                buttons (1,:) {mustBeText, mustBeNonempty};
                state   (1,1) {mustBeUnderlyingType(state, 'ButtonState')};
            end
            
            for i = 1:length(buttons)
                self.BaseView.(buttons(i)).Enable = char(state);
            end
        end
        
        function createOutputParametersModelObject(self)
            % assign the OutputParametersModel object to the OutputParametersModel property of this class
            if isempty(self.OutputParametersModel)
                self.OutputParametersModel = OutputParametersModel();
            end
            
        end
        
    end
    
end