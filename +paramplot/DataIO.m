classdef DataIO < handle
    % methods for saving data to DB and/or .csv files

    properties (GetAccess = public, SetAccess = private)
        RootDir     char {mustBeFolder} = pwd;
    end
    
    properties (Dependent)
        DataDir     char {mustBeFolder};
        ImgDir      char {mustBeFolder};
        PlotsDir    char {mustBeFolder};
        ProcDir     char {mustBeFolder};
        RawDir      char {mustBeFolder};
    end

    % constructor
    methods (Access = public)
        
        function self = DataIO(rootDir)
            if nargin > 0
                self.RootDir = rootDir;
            end
            self.mkDirTree();
        end
        
    end
    
    % methods for saving to .csv and db
    methods (Access = public)
        
        function validateArgs(self, type, vesselData, lowerBound, upperBound, window, saveStart, saveEnd)
            arguments
                self        DataIO;
                type        {mustBeMember(type, {'avg', 'res', 'hr'})};
                vesselData  struct;
                lowerBound  (1,1) uint16 {mustBeInteger, mustBeNonnegative};
                upperBound  (1,1) uint16 {mustBeInteger, mustBeNonnegative};
                window      (1,1) uint16 {mustBeInteger, mustBeNonnegative};
                saveStart   (1,1) uint16 {mustBeInteger, mustBeNonnegative, mustBeLessThanOrEqual(saveStart, lowerBound)} = min(vesselData.Voxels);
                saveEnd     (1,1) uint16 {mustBeInteger, mustBeGreaterThanOrEqual(saveEnd, saveStart), mustBeGreaterThanOrEqual(saveEnd, upperBound)} = max(vesselData.Voxels);
            end
        end
        
        function data2csv(self, type, vesselData, lowerBound, upperBound, window, saveStart, saveEnd)
            %{ 
                Inputs (required):
                    * type is char or string to denote the type of data to
                          save
                    * vesselData is in the form of a structure (VIPR)
                Inputs (optional):
                    * saveStart is the lower range of voxels to save
                        * will default to minimum of voxel range
                    * saveEnd is the upper range of voxels to save
                        * will default to maximum of voxel range
            %}
            
            self.validateArgs(type, vesselData, lowerBound, upperBound, window, saveStart, saveEnd);
            
            switch type
                case 'avg'
                    suffix = '_time_averaged';
                case 'res'
                    suffix = '_time_resolved';
                case 'hr'
                    suffix = 'hr';
            end
            
            tbl = self.mkTbl(type, vesselData, saveStart, saveEnd);
            basename = strrep(strcat(lower(vesselData.Vessel), suffix), ' ', '_');
            ext = '.csv';
            dataPath = fullfile(self.RawDir, strcat(basename, ext));
            writetable(tbl, dataPath);
            
            % write out voxel data/parameters
            self.mkVoxelSpecTbl(vesselData, lowerBound, upperBound, window);
        end
        
        function data2db(self, type, vesselData, lowerBound, upperBound, window, saveStart, saveEnd)
            % make db connection
            % write to tables
            % overwrite if exist (dialog box?)
            % close connection
            
            self.validateArgs(type, vesselData, lowerBound, upperBound, window, saveStart, saveEnd);
            
            % read yaml file containing info about db
            fname = fullfile();
            yml = yaml.ReadYaml(fname);
            
            % make db connection
            conn = database(yml.datasource, yml.username, yml.password);
            
            
            switch type
                case 'avg'
                case 'res'
                case 'hr'
            end
            
            % write out voxel data/parameters
            self.mkVoxelSpecTbl(vesselData, lowerBound, upperBound, window);
        end
        
    end

    methods (Access = private, Static)
        
        % formatting data into tables
        function tbl = mkTbl(type, vesselData, saveStart, saveEnd)           
            % get only the needed fields
            switch type
                case 'avg'
                    fields = {'Voxels', ...
                        'FlowPerMin', ...
                        'FlowPerHeartCycle', ...
                        'Area', ...
                        'Diameter', ...
                        'MeanVelocity', ...
                        'MaxVelocity', ...
                        'PulsatilityIndex', ...
                        'WallShearStress'};
                case 'res'
                    fields = {'Voxels', ...
                        'FlowPulsatile', ...
                        'CardiacTimeAbs', ...
                        'CardiacTimeRel'};
                case 'hr'
                    fields = {'HeartRate'};
            end
            
            for k = 1:numel(fields)
                vesselData_.(fields{k}) = vesselData.(fields{k});
            end
            
            % convert to table and filter rows
            switch type
                case 'avg'
                    tbl = struct2table(vesselData_);
                    tbl = tbl(saveStart:saveEnd, :);
                case 'res'
                    header1 = ["", "cardiac_cycle_(%)", num2str([vesselData_.CardiacTimeRel]')];
                    header2 = ["", "cardiac_cycle_(s)", num2str([vesselData_.CardiacTimeAbs]')];
                    header3 = ["Voxel", repmat("Flow_(mL/s)", 1, len(vesselData_.CardiacTimeAbs))];
                    data = horzcat(vesselData_.Voxels, vesselData_.FlowPulsatile);
                    data = data(saveStart:saveEnd, :);
                    tbl = table(vertcat(header1, header2, header3, data), 'VariableNames', header);
                case 'hr'
                    tbl = struct2table(vesselData_);
            end
            
            % convert to real nums
            tbl = varfun(@real, tbl);
        end

    end
    
    % methods for creating directories for saving data
    methods (Access = private)
        
        function mkDirTree(self)
            dataDir = "data";
            folder = fullfile(self.RootDir, dataDir);
            if exist(folder, 'dir') ~= 7
                mkdir(fullfile(folder));
            end
            
            folders = ["raw", ...
                        "proc", ...
                        "img", ...
                        "plots"];
            
            for k = 1:numel(folders)
                folder = fullfile(self.RootDir, dataDir, folders(k));
                [~, ~, msgID] = mkdir(folder);
                if ~strcmp(msgID, "MATLAB:MKDIR:DirectoryExists") && ~isempty(msgID)
                    disp(msgID);
                end
            end
            
        end

        function mkVoxelSpecTbl(self, vesselData, lowerBound, upperBound, window)
            fname = fullfile(self.ProcDir, "voxel.csv");
            if ~isfile(fname)
                header = {'vessel', 'lower_voxel', 'upper_voxel', 'window'};
                tbl = table(vesselData.Vessel, lowerBound, upperBound, window, 'VariableNames', header);
            else
                t0 = readtable(fname);
                t1 = {vesselData.Vessel, lowerBound, upperBound, window};
                tbl = [t0; t1];
            end
            writetable(tbl);
        end
        
        % deprecate??
        function savePlot(self, vesselName, axHandle)
            % R2019b cannot save plots from UI figures
            % need to copy axis (i.e. plot) to new figure then save
            
            ext = '.png';
            dispFormat = '    Saved %s plot\n';
            
            fig = copyUIAxes(axHandle);

            % reshape figure Window
            fig.figure.Position(3) = axHandle.Position(3) * 1.15; % make fig 15% wider than axis
            fig.figure.Position(4) = axHandle.Position(4) * 1.50; % make fig 50% taller than axis

            % reshape figure axes
            fig.axes.Units = 'Pixels';
            fig.axes.Position(3:4) = axHandle.Position(3:4);
            plotTitle = axHandle.Title;
            plotTitle = strrep(lower(plotTitle), ' ', '_');
            saveas(fig.axes, fullfile(self.PlotsDir, [vesselName, '_', plotTitle, ext]));
            delete(fig.figure);
            fprintf(dispFormat, plotTitle);
        end
        
        % deprecate b/c the new load functions for ease of viewing and QC???
        function saveSegment(self, vesselName, lowerBound, window, axHandle)
            % save vessel segment w/ and w/o isolation??
            ext = ".png";
            suffix = strcat('_voxel', num2str(lowerBound), '_window', num2str(window));
            fig = copyUIAxes(axHandle);
            fname = fullfile(self.ImgDir, [vesselName, suffix, ext]);
            saveas(fig.axes, fname);
            fprintf('    Saved %s image\n', vesselName);
        end

    end
    
    % getters
    methods
        
        function value = get.DataDir(self)
            value = fullfile(self.RootDir, "data");
        end
        
        function value = get.ImgDir(self)
            value = fullfile(self.RootDir, "data", "img");
        end
        
        function value = get.PlotsDir(self)
            value = fullfile(self.RootDir, "data", "plots");
        end
        
        function value = get.ProcDir(self)
            value = fullfile(self.RootDir, "data", "proc");
        end
        
        function value = get.RawDir(self)
            value = fullfile(self.RootDir, "data", "raw");
        end
        
        function value = get.RootDir(self)
            value = self.RootDir;
        end
        
    end
    
end
