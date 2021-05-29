classdef LoadVIPR < handle
    %{
        methods for loading PC VIPR files
        INPUT: dlg = uiprogressdlg from CenterlineToolApp
    
        Can't add property validation as it expects a default value. Also, 
        such validation is only evaluated when the class is first 
        instantiated, not for new instances. So moving the validation to 
        setters made more sense.
    %}

    properties (Access = private)
        Model;
    end
    
    %{
    properties (Access = private, Transient)
        DlgCounter       (1,1) double{mustBeInteger} = 0;
        DlgCountTotal    (1,1) double{mustBeInteger};
    end
    %}
    
    methods (Access = public)
        
        % constructor
        function self = LoadVIPR(model, dlg)
            self.Model = model;
            self.pickDataDirectory();
            clc;
            dlg.Message = strcat('Loading data from: ', self.Model.DataDir);
            dataArray = self.readHeader();
            self.parseArray(dataArray);
            self.loadVelocity(dlg);
            self.loadMAG(dlg);
            self.loadMeanVelocity(dlg);
            close(dlg);
        end
        
    end
    
    methods (Access = private)
        
        function pickDataDirectory(self)
            % Get and load input DataDir
            value = uigetdir;
            
            %{ 
                Check if the cancel button was triggered in the uigetdir fcn
                or if a non-VIPR directory was selected
                if so, the VIPR.DataDir would not be altered and
                the previous directory will be the same
            %}
            
            if value == 0
                ME = MException('LoadVIPR:pickDataDirectory:cancel', 'No folder selected');
                throw(ME);
            elseif ~isfile(fullfile(value, "pcvipr_header.txt"))
                ME = MException('LoadVIPR:pickDataDirectory:invalid', 'Invalid directory');
                throw(ME);
            else
                self.Model.DataDir = value;
            end
        end
        
        function dataArray = readHeader(self)
            % Read columns of data as strings:
            % For more information, see the TEXTSCAN documentation.
            delimiter = ' ';
            formatSpec = '%s%s%[^\n\r]';
            fid = fopen([self.Model.DataDir '\pcvipr_header.txt'], 'r'); 
            if fid < 0
                error('Could not open pcvipr_header.txt file');
            end
            dataArray = textscan(fid, formatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true,  'ReturnOnError', false);
            fclose(fid);
        end
    
        function parseArray(self, dataArray)
            dataArray{1,2} = cellfun(@str2num, dataArray{1,2}(:), 'UniformOutput', 0);
            header = cell2struct(dataArray{1,2}(:), dataArray{1,1}(:), 1);
            headerFields = fieldnames(header);
            for k = 1:length(headerFields)
                disp(strcat(headerFields{k}, {': '}, string(header.(headerFields{k}))));
            end

            % number of reconstructed frames
            self.Model.NoFrames = header.frames;                                             
            
            % temporal Resolutionolution
            self.Model.TimeRes = header.timeres;
            
            % field of view in cm
            self.Model.FOV = header.fovx / 10;
            
            % number of pixels in row,col,slices
            self.Model.Res = header.matrixx;

            % Vel encoding
            self.Model.VelEncoding = header.VENC;
        end
                
        function loadVelocity(self, dlg)
            % looped reading of all Vel images
            
            % set up dilaog box
            dlg.Message = 'Reading Vel data...';
            dlg.Value = 0;
            counter = 0;
            total = self.NoFrames;
            
            % init 4D flow matrix, three directions x No.time frames
            velocityArray = zeros(self.Model.Res, self.Model.Res, self.Model.Res, 3, self.NoFrames, 'int16');
            
            for m = 1:self.NoFrames
                dlg.Message = strcat("Reading frame ", num2str(m), " of ", num2str(self.Model.NoFrames));
                for n = 1:3
                    if dlg.CancelRequested
                        break;
                    end
                    fname = ['ph_' num2str(m-1, '%03i') '_vd_' num2str(n) '.dat'];
                    fid = fopen(fullfile(self.Model.DataDir, fname), 'r');
                    data = fread(fid, self.Model.Res^3, 'short')';
                    fclose(fid);
                    velocityArray(:,:,:,n,m) = reshape(data, self.Model.Res, self.Model.Res, self.Model.Res);
                end
                counter = counter + 1;
                dlg.Value = counter / total;
            end
            self.Model.Vel = velocityArray;
        end
        
        function loadMAG(self, dlg)
            if dlg.CancelRequested
                return;
            end
            dlg.Message = 'Reading composite data: MAG';
            dlg.Value = 0;
            fname = fullfile(self.Model.DataDir, 'MAG.dat');
            self.Model.MAG = self.loadDat(fname);
            dlg.Value = 1;
        end
        
        function loadMeanVelocity(self, dlg)
            % set up dialog box
            dlg.Message = 'Reading composite data: mean Vel';
            dlg.Value = 0;
            counter = 0;
            total = 3;

            % init array
            self.Model.VelMean = single(zeros(self.Model.Res, self.Model.Res, self.Model.Res, 3));

            for k = 1:3
                if dlg.CancelRequested
                    break;
                end
                fname = fullfile(self.Model.DataDir, ['comp_vd_' num2str(k) '.dat']);
                self.Model.VelMean(:,:,:,k) = self.loadDat(fname);
                dlg.Value = counter / total;
                counter = counter + 1;
            end
        end
        
        function val = loadDat(self, fname)
            [fid, errmsg] = fopen(fname, 'r');
            if fid < 0
                error(['Error Opening Data: ', errmsg]);
            end
            val = single(reshape(fread(fid, 'short'), [self.Model.Res self.Model.Res self.Model.Res]));
            fclose(fid);
        end
        
    end
    
    %{
    % setters
    methods
        
        % TODO: add validation to setters
        function set.DataDir(self, val)
            self.DataDir = val;
        end

        function set.FOV(self, val)
            self.FOV = val / 10;
        end
        
        function set.MAG(self, val)
            self.MAG = val;
        end
        
        function set.NoFrames(self, val)
            self.NoFrames = val;
        end
        
        function set.Res(self, val)
            self.Res = val;
        end
        
        function set.TimeMIP(self, val)
            self.TimeMIP = val;
        end
        
        function set.TimeRes(self, val)
            self.TimeRes = val;
        end
        
        function set.Segment(self, val)
            self.Segment = val;
        end
        
        function set.Vel(self, val)
            self.Vel = val;
        end
        
        function set.VelMean(self, val)
            self.VelMean = val;
        end
        
        function set.VelEncoding(self, val)
            self.VelEncoding = val;
        end
        
    end
    
    % getters
    methods
        
        function val = get.DataDir(self)
            val = self.DataDir;
        end
        
        function val = get.FOV(self)
            val = self.FOV;
        end
        
        function val = get.MAG(self)
            val = self.MAG;
        end
        
        function val = get.NoFrames(self)
            val = self.NoFrames;
        end
        
        function val = get.Res(self)
            val = self.Res;
        end
        
        function val = get.TimeMIP(self)
            val = self.TimeMIP;
        end
        
        function val = get.TimeRes(self)
            val = self.TimeRes;
        end
        
        function val = get.Segment(self)
            val = self.Segment;
        end
        
        function val = get.Vel(self)
            val = self.Vel;
        end
        
        function val = get.VelMean(self)
            val = self.VelMean;
        end
        
        function val = get.VelEncoding(self)
            val = self.VelEncoding;
        end
        
    end
    %}
end