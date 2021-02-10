classdef LoadVIPR < handle
    %{
        methods for loading PC VIPR files
        INPUT: dlg = uiprogressdlg from CenterlineToolApp
        OUTPUT: s = structure of PC VIPR loaded data
    %}
    
    properties (Access = public)
        DataDirectory;
        FOV;
        MAG;
        NoFrames;
        Resolution;
        TimeResolution;
        Velocity;
        VelocityMean;
        VelocityEncoding;
    end
    
    properties (Access = private, Transient)
        dlgTotal;
        dlgCounter = 0;
    end
    
    methods
        % constructor
        function self = LoadVIPR()
        end
        
        % main fcn
        function s = loadVIPR(self, dlg)
           self.getDataDirectory();
           clc;
           fprintf('Loading data from: %s\n', self.DataDirectory);
           dlg.Message = strcat('Loading data from: ', self.DataDirectory);
           dataArray = self.readHeader();
           self.parseArray(dataArray);
           self.loadVelocity(dlg);
           self.loadMAG(dlg);
           self.loadMeanVelocity(dlg);
           s = self.getStruct();
           fprintf('Load Data: Done!\n');
        end
        
    end
    
    % load data methods
    methods (Access = private)
        
        function getDataDirectory(self)
            % Get and load input DataDirectory
            % Check if the cancel button was triggered in the uigetdir fcn
            % if cancelled, the VIPR.DataDirectory would not be altered and
            % the previous directory will be the same
            
            self.DataDirectory = uigetdir;
            if self.DataDirectory == 0
                ME = MException('LoadVIPR:getDataDirectory:cancel', 'No folder selected');
                throw(ME);
            end
        end
        
        function dataArray = readHeader(self)
            % Read columns of data as strings:
            % For more information, see the TEXTSCAN documentation.
            delimiter = ' ';
            formatSpec = '%s%s%[^\n\r]';
            fid = fopen([self.DataDirectory '\pcvipr_header.txt'], 'r'); 
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
            self.NoFrames = header.frames;                                             
            
            % temporal Resolutionolution
            self.TimeResolution = header.timeres;
            
            % field of view in cm
            self.FOV = (header.fovx)/10;                                              
            
            % number of pixels in row,col,slices
            self.Resolution = header.matrixx;                                                
            
            % init 4D flow matrix, three directions, 20 time frames
            self.Velocity = zeros(self.Resolution, self.Resolution, self.Resolution, 3, self.NoFrames, 'int16');   
            
            % Velocity encoding
            self.VelocityEncoding = header.VENC;
            
            % set uiprogressdlg counter
            % 3 vd_???.dat files per frame + 1 MAG file + 3 average
            % velocity .dat files
            self.dlgTotal = (3 * self.NoFrames) + 1 + 3;
        end
                
        function loadVelocity(self, dlg)
            % looped reading of all Velocity images
            disp('Loading velocity data...');
            for m = 1:self.NoFrames
                for n = 1:3
                    if dlg.CancelRequested
                        break;
                    end
                    dlg.Message = strcat('Reading frame ', num2str(m), ' of ', num2str(self.NoFrames));
                    dlg.Value = self.dlgCounter/self.dlgTotal;
                    
                    fname = ['ph_' num2str(m-1, '%03i') '_vd_' num2str(n) '.dat'];
                    fid = fopen(fullfile(self.DataDirectory, fname), 'r');
                    data = fread(fid, self.Resolution^3, 'short')';
                    fclose(fid);
                    self.Velocity(:,:,:,n,m) = reshape(data, self.Resolution, self.Resolution, self.Resolution);
                    self.dlgCounter = self.dlgCounter + 1;
                end
                disp(['    Completed reading frame ', num2str(m), ' of ', num2str(self.NoFrames)]);
            end
            self.Velocity = single(self.Velocity);
        end
        
        function loadMAG(self, dlg)
            if dlg.CancelRequested
                return;
            end
            dlg.Message = 'Reading composite data';
            disp('Reading composite data...');
            fname = fullfile(self.DataDirectory, 'MAG.dat');
            fprintf('    Loading %s\n', fname);
            self.MAG = self.loadDat(fname);
            self.dlgCounter = self.dlgCounter + 1;
            dlg.Value = self.dlgCounter/self.dlgTotal;
        end
        
        function loadMeanVelocity(self, dlg)
            self.VelocityMean = single(zeros(self.Resolution, self.Resolution, self.Resolution, 3));
            for k = 1:3
                if dlg.CancelRequested
                    break;
                end
                dlg.Value = self.dlgCounter/self.dlgTotal;
                fname = fullfile(self.DataDirectory, ['comp_vd_' num2str(k) '.dat']);
                fprintf('    Loading %s\n', fname);
                self.VelocityMean(:,:,:,k) = self.loadDat(fname);
                self.dlgCounter = self.dlgCounter + 1;
            end
        end
        
        function val = loadDat(self, fname)
            [fid, errmsg] = fopen(fname, 'r');
            if fid < 0
                error(['Error Opening Data: ', errmsg]);
            end
            val = single(reshape(fread(fid, 'short'), [self.Resolution self.Resolution self.Resolution]));
            fclose(fid);
        end

    end
    
    % output as struct
    methods (Access = private)
       
        function s = getStruct(self)
            warning('off', 'MATLAB:structOnObject');
            s = struct(self);
            warning('on', 'MATLAB:structOnObject');
        end
        
    end
    
end