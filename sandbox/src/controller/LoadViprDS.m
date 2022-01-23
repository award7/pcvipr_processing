classdef LoadViprDS
    
    % create file datastores
    methods (Access = ?BaseController, Static)
        
        function fs = getVelocityFileDataStore(data_directory, opts)
            arguments
                data_directory {mustBeFolder};
                opts.SearchTerm {mustBeTextScalar} = 'ph_*vd*.dat';
                opts.ExpectedNumFiles (1,1) {mustBeInteger, mustBePositive};
            end
            
            files = LoadViprDS.getFiles(data_directory, opts.SearchTerm, opts);
            fs = fileDatastore(files, 'ReadFcn', @LoadViprDS.loadVelocityData);
        end
        
        function fs = getVelocityMeanFileDataStore(data_directory, opts)
            arguments
                data_directory {mustBeFolder};
                opts.SearchTerm {mustBeTextScalar} = 'comp_vd*.dat';
                opts.ExpectedNumFiles (1,1) {mustBeInteger, mustBePositive};
            end
            
            files = LoadViprDS.getFiles(data_directory, opts.SearchTerm, opts);
            fs = fileDatastore(files, 'ReadFcn', @LoadViprDS.loadVelocityMeanData);
        end

        function fs = getMagFileDataStore(data_directory, opts)
            arguments
                data_directory {mustBeFolder};
                opts.SearchTerm {mustBeTextScalar} = 'MAG.dat';
                opts.ExpectedNumFiles (1,1) {mustBeInteger, mustBePositive};
            end
            
            files = LoadViprDS.getFiles(data_directory, opts.SearchTerm, opts);
            fs = fileDatastore(files, 'ReadFcn', @LoadViprDS.loadMagData);
        end
        
    end
    
    % load functions for file data stores
    methods (Access = private, Static)
        
        % TODO: consolidate
        
        function data = loadVelocityData(filename)
            % get resolution of scan
            % assumes the header file is in the same directory as the MAG file
            [fpath, ~, ~] = fileparts(filename);
            header = LoadViprDS.parseArray(fpath);
            res = header.matrixx;
            
            % read in data
            fid = fopen(filename);
            raw_data = fread(fid, 'short');
            fclose(fid);
            
            % reshape the data
            data = zeros(res, res, res);
            data(:,:,:) = reshape(raw_data, res, res, res);
        end

        function data = loadVelocityMeanData(filename)
            % get resolution of scan
            % assumes the header file is in the same directory as the MAG file
            [fpath, ~, ~] = fileparts(filename);
            header = LoadViprDS.parseArray(fpath);
            res = header.matrixx;
            
            % read in data
            fid = fopen(filename);
            raw_data = fread(fid, 'short');
            fclose(fid);
            
            % reshape the data
            data = zeros(res, res, res);
            data(:,:,:) = reshape(raw_data, res, res, res);
        end
        
        function data = loadMagData(filename)
            % get resolution of scan
            % assumes the header file is in the same directory as the MAG file
            [fpath, ~, ~] = fileparts(filename);
            header = LoadViprDS.parseArray(fpath);
            res = header.matrixx;
            
            % read in data
            fid = fopen(filename);
            raw_data = fread(fid, 'short');
            fclose(fid);
            
            % reshape the data
            data = zeros(res, res, res);
            data(:,:,:) = single(reshape(raw_data, res, res, res));
        end
        
    end
    
    % helper functions
    methods (Access = private, Static)
        
        function files = getFiles(data_directory, search_term, opts)
            % get files into struct
            file_struct = dir(fullfile(data_directory, search_term));
            
            % do a check
            num_files = length(file_struct);
            try
                if ne(num_files, opts.ExpectedNumFiles)
                    errid = 'LoadVipr:checkFileCount:failed';
                    msg = 'Number of files found (%d) does not equal the expected number of files (%d)';
                    me = MException(errid, msg, num_files, opts.ExpectedNumFiles);
                    throw(me);
                end
            catch me
                switch me.identifier
                    case 'MATLAB:nonExistentField'
                        % do nothing
                    otherwise
                        rethrow(me);
                end
            end
            
            files = cell(num_files, 1);
            
            for i = 1:num_files
                files{i} = fullfile(file_struct(i).folder, file_struct(i).name);
            end
        end
        
    end
        
    % methods to read header info
    methods (Static)
    
        function header = parseArray(data_directory)
            % Read columns of data as strings:
            % For more information, see the TEXTSCAN documentation.
            
            arguments
                data_directory {mustBeFolder};
            end
            
            delimiter = ' ';
            formatSpec = '%s%s%[^\n\r]';
            fid = fopen(fullfile(data_directory, 'pcvipr_header.txt'), 'r'); 
            if fid < 0
                error('Could not open pcvipr_header.txt file');
            end
            
            dataArray = textscan(fid, formatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true,  'ReturnOnError', false);
            fclose(fid);
            
            pfile = string(dataArray{1,2}(3));
            dataArray{1,2} = cellfun(@str2num, dataArray{1,2}(:), 'UniformOutput', false);
            header = cell2struct(dataArray{1,2}(:), dataArray{1,1}(:), 1);
            header.pfile = pfile;
            
%             % number of reconstructed frames
%             no_frames = header.frames;                                             
%             
%             % temporal Resolutionolution
%             time_resolution = header.timeres;
%             
%             % field of view in cm
%             fov = (header.fovx)/10;                                              
%             
%             % number of pixels in row,col,slices
%             resolution = header.matrixx;                                                
%             
%             % Velocity encoding
%             velocity_encoding = header.VENC;
        end
        
    end

end