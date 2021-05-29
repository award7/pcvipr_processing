classdef Controller < CenterlineApp.base.Controller.Controller
    %{
    interface between view and model classes
    contains logic rather than data
    %}
    
    properties (Access = {?Controller, ?matlab.unittest.TestCase})
        CLView;     % centerline tool view
        CLModel;    % centerline tool model
        BGCon;      % background phase correction controller
        VSCon;      % vessel selection controller
        V3DCon;     % vessel 3D controller
        PltCon;     % parameter plot controller
    end
    
    methods (Access = public)
        
        function self = Controller()
            self.CLModel = centerlineapp.centerline.Model();
            self.CLView = centerlineapp.centerline.View(self.CLModel);
            self.setCallbacks();
        end
        
    end
    
    methods (Access = private)
        
        function setCallbacks(self)
            self.CLView.UIFigure.CloseRequestFcn = @self.uiClose;
            self.CLView.UIFigure.WindowKeyPressFcn = @self.uiKeyPress;
            self.CLView.restoreViewBtn.ButtonPushedFcn = @self.tbValueChanged;
            self.CLView.BackgroundPhaseCorrectionButton.ButtonPushedFcn = @self.bgPhaseBtnPushed;
            self.CLView.DrawROIButton.ButtonPushedFcn = @self.drawROIBtnPushed;
            self.CLView.ViewParametricMapButton.ButtonPushedFcn = @self.viewParametricMapBtnPushed;
            self.CLView.FeatureExtractionButton.ButtonPushedFcn = @self.featureExtractionBtnPushed;
            self.CLView.VesselSelectionButton.ButtonPushedFcn = @self.vesselSelectionBtnPushed;
            self.CLView.SegmentVesselsButton.ButtonPushedFcn = @self.segmentVesselBtnPushed;
            self.CLView.LoadDataButton.ButtonPushedFcn = @self.loadDataBtnPushed;
            self.CLView.DBConnectionButton.ButtonPushedFcn = @self.dbConnectionBtnPushed;
        end
        
    end
    
    % callbacks for view
    methods (Access = {?Controller, ?matlab.unittest.TestCase})
        
        % callbacks
        function loadDataBtnPushed(self, src, evt)
            try
                self.selectDataDir();
                data = self.readHeader();
                
                % set up progress bar
                self.CLView.createDlg(self.CLView.UIFigure);
                self.CLView.setDlgTitle('Loading VIPR Data');
                self.CLView.setDlgVal(0);
                self.CLView.setDlgShowPercentage(true);
                self.CLView.setDlgCancelable(true);
                
                self.parseArray(data);
                self.loadVelocity();
                self.loadMAG();
                self.loadMeanVelocity();
                self.CLView.clearAxes();
                self.CLView.updateDataDirLbl(self.CLModel.DataDir);
                self.CLView.deleteDlg();
            catch ME
                if strcmp(ME.identifier, 'DirSelection:chooseDir:cancel')
                    return;
                else
                    self.CLView.createAlert(self.CLView.UIFigure, ...
                        ME.message, ...
                        "title", "Load VIPR Data", ...
                        "icon", "error");
                    return;
                end
            end
            
        end
        
        function dbConnectionBtnPushed(self, src, evt)
            self.CLView.createAlert(self.CLView.UIFigure, ...
            'This function is not yet programmed', ...
            'title', 'Database Connection', ...
            'icon', 'warning');
            self.CLView.updateDBLbl("This.is.where.db.connection.would.be");
        end
        
        function bgPhaseBtnPushed(self, src, evt)
            % check if window exists
            if ~isempty(self.BGCon) && isvalid(self.BGCon)
                return;
            end
            
            % check if load data has been performed
            if isempty(self.CLModel.DataDir)
                msg = sprintf('''Load Data'' has not been performed.\n\nDo you want to load data?');
                res = self.CLView.createAlert(self.CLView.UIFigure, ...
                        msg,...
                        "title", "error", ...
                        "icon", "error", ...
                        'buttons', {'Yes', 'No'}, ...
                        'values', [1,0]);
                if res == 0
                    return;
                elseif res == 1
                    self.loadDataBtnPushed();
                    return;
                end
            end
            
            try
                self.PCApp = CenterlineApp.BackgroundPCApp.Controller(self.CLModel);
            catch ME
                delete(self.PCApp);
                self.CLView.dispGenericErr(self.CLView.UIFigure, ME.message)
                return;
            end
        end
        
        function drawROIBtnPushed(self, src, evt)
            self.CLView.createAlert(self.CLView.UIFigure, ...
                'This function is not yet programmed', ...
                'title', 'Draw ROI', ...
                'icon', 'warning');
        end
        
        function viewParametricMapBtnPushed(self, src, evt)
            self.CLView.createAlert(self.CLView.UIFigure, ...
                'This function is not yet programmed', ...
                'title', 'View Parametric Map', ...
                'icon', 'warning');
        end
        
        function featureExtractionBtnPushed(self, src, evt)
            % check if Background PC was performed
            if isempty(self.CLModel.Segment) || isempty(self.CLModel.TimeMIP)
                msg = sprintf('''Background phase correction'' has not been performed.\n\nPerform background phase correction?');
                res = self.CLView.createAlert(self.CLView.UIFigure, ...
                        msg, ...
                        'Confirm Background Phase Correction', ...
                        'icon', 'warning', ...
                        'buttons', {'Yes', 'No'}, ...
                        'values', [1, 0]);
                if res == 0
                    return;
                elseif res == 1
                    self.bgPhaseBtnPushed();
                    return;
                end
            end
            
            % check if feature extraction already performed
            if ~isempty(self.CLModel.BranchMat) && ...
                    ~isempty(self.CLModel.BranchList)
                msg = sprintf('Feature extraction already performed.\n\nPerform feature extraction again?');
                res = self.CLView.createDlgBox(self.CLView.UIFigure, ...
                        msg, ...
                        'Confirm Feature Extraction', ...
                        'icon', 'warning', ...
                        'buttons', {'Yes', 'No'}, ...
                        'values', [1, 0]);
                
                % if 'no', don't continue on
                if res == 0
                    return;
                end
            end
            
            % fcn
            sortingCriteria = 3;
            spurLength = 8;
            [~, branchMat, branchList, ~] = feature_extraction( ...
                                                sortingCriteria, ...
                                                spurLength, ...
                                                self.CLModel.VelMean, ...
                                                self.CLModel.Segment, ...
                                                self.CLModel.Res);
            self.CLModel.setBranchMat(branchMat);
            self.CLModel.setBranchList(branchList);
        end
        
        function vesselSelectionBtnPushed(self, src, evt)
            % check if window already exists
            if ~isempty(self.VSCon) && isvalid(self.VSCon)
                return;
            end
            
            % check that feature extraction was performed
            if isempty(self.CLModel.BranchMat) || ...
                    isempty(self.CLModel.BranchList)
                msg = sprintf('Feature extraction has not been performed.\n\nDo you want to perform feature extraction?');
                res = self.CLView.createAlert(self.CLView.UIFigure, ...
                        msg, ...
                        'title', 'Vessel Selection', ...
                        'icon', 'warning', ...
                        'buttons', {'Yes', 'No'}, ...
                        'values', [1,0]);
                
                if res == 0
                    return;
                elseif res ==1
                    self.featureExtractionBtnPushed();
                    return;
                end
            end
            
            % fcn
            try
                self.VSCon = CenterlineApp.VesselSelectionApp.Controller(self.CLModel);
            catch ME
                self.VSCon.uiClose();
                self.CLView.dispGenericErr(self.CLView.UIFigure, ME.message)
                return;
            end

        end
        
        function segmentVesselBtnPushed(self, src, evt)
            if self.CLModel.Vessel
            end
            
            if isfield(self.CLModel.VIPR, 'Vessel')
                if isobject(self.V3DCon)
                    if isvalid(self.V3DCon)
                        return;
                    end
                end
            else
                msg = sprintf('No vessels selected.\nPerform vessel selection first.');
                self.CLView.createAlert(self.CLView.UIFigure, ...
                    msg, ...
                    'title', 'Segment Vessel', ...
                    'icon', 'error');
                return;
            end
            
            vesselNames = fieldnames(self.CLModel.VIPR.Vessel);
            calc = calculateParameters();
            for k = 1:numel(vesselNames)
                
                % check if parameters already exist; if so, skip
                parameterNames = fieldnames(self.CLModel.VIPR.Vessel.(vesselNames{k}));
                if any(ismember(parameterNames, 'Area'))
                    continue;
                end

                fprintf('Calculating parameters for %s...\n', string(vesselNames{k}));
                branchActual_ = self.CLModel.VIPR.Vessel.(vesselNames{k}).BranchActual;
                parameters = calc.main(self.CLModel.VIPR, branchActual_);
                
                % make anonymous fcn to concat structs
                mergeStructs = @(x,y) cell2struct([struct2cell(x); struct2cell(y)], [fieldnames(x); fieldnames(y)]);
                parameters = mergeStructs(self.CLModel.VIPR.Vessel.(vesselNames{k}), parameters);
                self.CLModel.VIPR.Vessel.(vesselNames{k}) = parameters;
                fprintf('Finished calculating parameters for %s...\n', string(vesselNames{k}));
            end
            fprintf('Done calculating parameter for all vessels!\n');
            
            % TODO: wrap in try/catch to delete GUIs if error
            % linker = AppLinker(self.CLModel.VIPR, @ParameterPlotApp);
            % self.V3DCon = Vessel3DApp(self.CLModel.VIPR, linker);
        end
        
        function openVessel3D(self, src, evt)
            self.CLView.createAlert(self.CLView.UIFigure, ...
                'This function is not yet programmed', ...
                'title', 'Vessel 3D', ...
                'icon', 'warning');
        end
        
        function tbValueChanged(self, src, evt)
            btn = evt.Source.Tag;
            if strcmpi(btn, 'restoreview')
                self.CLView.viewAngiogram();
            end
        end
        
    end
    
    %{
    methods (Access = protected)
       
        function uiClose(self, src, evt)
            delete(self.CLView.UIFigure);
            delete(self.CLView)
            
            % TODO: ensure child windows are closed
            if isobject(app.PCApp)
                if isvalid(app.PCApp)
                    delete(app.PCApp);
                end
            end
            
            if isobject(app.VesselSelectionApp) 
                if isvalid(app.VesselSelectionApp)
                    delete(app.VesselSelectionApp);
                end
            end
            
            if isobject(app.Vessel3DApp)
                if isvalid(app.Vessel3DApp)
                    delete(app.Vessel3DApp);
                end
            end

        end
        
    end
    %}
    
    % vipr load data methods
    methods (Access = {?Controller, ?matlab.unittest.TestCase})
        
        function selectDataDir(self)
            val = CenterlineApp.utils.DirSelection(self.CLModel.DataDir, ...
                'Select VIPR Data Directory');
            self.CLModel.setDataDir(val);
        end
        
        function dataArray = readHeader(self)
            % Read columns of data as strings:
            % For more information, see the TEXTSCAN documentation.
            delimiter = ' ';
            formatSpec = '%s%s%[^\n\r]';
            fid = fopen([self.CLModel.DataDir '\pcvipr_header.txt'], 'r'); 
            if fid < 0
                self.CLView.createAlert(self.CLView.UIFigure, ...
                    'Could not open pcvipr_header.txt file', ...
                    'title', 'Error', ...
                    'icon', 'error');
            end
            dataArray = textscan(fid, formatSpec, 'Delimiter', delimiter, ...
                'MultipleDelimsAsOne', true,  'ReturnOnError', false);
            fclose(fid);
        end
    
        function parseArray(self, dataArray)
            dataArray{1,2} = cellfun(@str2num, dataArray{1,2}(:), ...
                'UniformOutput', 0);
            header = cell2struct(dataArray{1,2}(:), dataArray{1,1}(:), 1);
            headerFields = fieldnames(header);
            for k = 1:length(headerFields)
                disp(strcat(headerFields{k}, {': '}, ...
                    string(header.(headerFields{k}))));
            end

            % number of reconstructed frames
            self.CLModel.setNoFrames(header.frames); 
            
            % temporal Resolutionolution
            self.CLModel.setTimeRes(header.timeres);
            
            % field of view in cm
            self.CLModel.setFOV(header.fovx);
            
            % number of pixels in row,col,slices
            self.CLModel.setRes(header.matrixx);

            % Vel encoding
            self.CLModel.setVelEncoding(header.VENC);
        end
                
        function loadVelocity(self)
            % looped reading of all Vel images
            
            % set up dilaog box
            self.CLView.setDlgMsg('Reading Velocity Data...');
            self.CLView.setDlgVal(0);
            
            % init 4D flow matrix, three directions x No.time frames
            velocityArray = zeros(self.CLModel.Res, self.CLModel.Res, self.CLModel.Res, 3, self.CLModel.NoFrames, 'int16');
            
            counter = 0;
            total = self.CLModel.NoFrames;
            for m = 1:self.CLModel.NoFrames
                self.CLView.setDlgMsg(strcat("Reading frame ", num2str(m), " of ", num2str(self.CLModel.NoFrames)));
                for n = 1:3
                    if self.CLView.Dlg.CancelRequested
                        break;
                    end
                    fname = ['ph_' num2str(m-1, '%03i') '_vd_' num2str(n) '.dat'];
                    fid = fopen(fullfile(self.CLModel.DataDir, fname), 'r');
                    data = fread(fid, self.CLModel.Res^3, 'short')';
                    fclose(fid);
                    velocityArray(:,:,:,n,m) = reshape(data, self.CLModel.Res, self.CLModel.Res, self.CLModel.Res);
                end
                counter = counter + 1;
                self.CLView.setDlgVal(counter / total);
            end
            self.CLModel.setVel(velocityArray);
        end
        
        function loadMAG(self)
            self.CLView.setDlgMsg('Reading composite data: MAG');
            self.CLView.setDlgVal(0);
            if self.CLView.Dlg.CancelRequested
                return;
            end
            fname = fullfile(self.CLModel.DataDir, 'MAG.dat');
            val = self.loadDat(fname);
            self.CLModel.setMAG(val);
            self.CLView.setDlgVal(1);
        end
        
        function loadMeanVelocity(self)
            % set up dialog box
            self.CLView.setDlgMsg('Reading composite data: Mean Velocity');
            self.CLView.setDlgVal(0);

            % init array
            arr = single(zeros(self.CLModel.Res, self.CLModel.Res, self.CLModel.Res, 3));
            
            counter = 0;
            total = 3;
            for k = 1:3
                if self.CLView.Dlg.CancelRequested
                    break;
                end
                fname = fullfile(self.CLModel.DataDir, ['comp_vd_' num2str(k) '.dat']);
                arr(:,:,:,k) = self.loadDat(fname);
                self.CLView.setDlgVal(counter / total);
                counter = counter + 1;
            end
            self.CLModel.setVelMean(arr);
        end
        
        function val = loadDat(self, fname)
            [fid, errmsg] = fopen(fname, 'r');
            if fid < 0
                error(['Error Opening Data: ', errmsg]);
            end
            val = single(reshape(fread(fid, 'short'), [self.CLModel.Res self.CLModel.Res self.CLModel.Res]));
            fclose(fid);
        end
        
    end
    
    % saveApp and loadApp
    methods (Access = {?Controller, ?matlab.unittest.TestCase})
        %{
            have no use for save and load of MainApp but need to implement
            these as the base class dictates
        %}
        function loadApp()
        end
        
        function saveApp()
        end
            
    end
    
end