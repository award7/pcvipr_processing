classdef LoadViprDS < handle
    
    % velocity file datastore and array datastore
    methods (Access = public, Static)
        
        function fs = getVelocityFileDataStore(data_directory, opts)
            % Note: when calling the ReadFcn, it will only return a single 320^3 array
            % the caller needs to partition the fs into 20 parts (j), then loop over the files
            % in the partition (i) to get the 320x320x320xixj array
            arguments
                data_directory {mustBeFolder};
                opts.SearchTerm {mustBeTextScalar} = 'ph_*vd*.dat';
                opts.ExpectedNumFiles (1,1) {mustBeInteger, mustBePositive};
            end
            
            files = LoadViprDS.getFiles(data_directory, opts.SearchTerm, opts);
            fs = fileDatastore(files, 'ReadFcn', @LoadViprDS.viprFileLoader);
        end
        
        function ds = getVelocityDataStore(fs)
            arguments
                fs {mustBeUnderlyingType(fs, 'matlab.io.datastore.FileDatastore')};
            end
            
            % get resolution of scan
            % assumes the header file is in the same directory as the .dat
            % files
            fpath = fs.Folders{1};
            header = LoadViprDS.parseArray(fpath);
            res = header.matrixx;
            
            % preallocate array
            dim4 = 3;
            dim5 = 20;
            data = zeros(res, res, res, dim4, dim5);

            k = 1;
            fs.reset;
            while fs.hasdata
                for j = 1:3
                    data(:,:,:,j,k) = fs.read;
                end
                k = k + 1;
            end
            
            dim = 4;
            ds = arrayDatastore(data, 'IterationDimension', dim);
        end
        
    end
    
    % velocity mean file datastore and array datastore
    methods (Access = public, Static)
        
        function fs = getVelocityMeanFileDataStore(data_directory, opts)
            % Note: when calling the ReadFcn, it will only return a single 320^3 array
            % the caller needs to partition the fs into parts (i) to get the 320x320x320xi array
            arguments
                data_directory {mustBeFolder};
                opts.SearchTerm {mustBeTextScalar} = 'comp_vd*.dat';
                opts.ExpectedNumFiles (1,1) {mustBeInteger, mustBePositive};
            end
            
            files = LoadViprDS.getFiles(data_directory, opts.SearchTerm, opts);
            fs = fileDatastore(files, 'ReadFcn', @LoadViprDS.viprFileLoader);
        end

        function ds = getVelocityMeanDataStore(fs)
            arguments
                fs {mustBeUnderlyingType(fs, 'matlab.io.datastore.FileDatastore')};
            end
            
            % get resolution of scan
            % assumes the header file is in the same directory as the .dat
            % files
            fpath = fs.Folders{1};
            header = LoadViprDS.parseArray(fpath);
            res = header.matrixx;
            
            % preallocate array
            dim4 = 3;
            data = zeros(res, res, res, dim4);
            
            j = 1;
            fs.reset;
            while fs.hasdata
                data(:,:,:,j) = fs.read;
                j = j + 1;
            end
            
            dim = 4;
            ds = arrayDatastore(data, 'IterationDimension', dim);
        end
        
    end
    
    % MAG file datastore and array datastore
    methods (Access = public, Static)
        
        function fs = getMagFileDataStore(data_directory, opts)
            % Note: when calling the ReadFcn, it will return the array properly shaped
            % but the caller needs to cast it to the proper data type (i.e. single)
            arguments
                data_directory {mustBeFolder};
                opts.SearchTerm {mustBeTextScalar} = 'MAG.dat';
                opts.ExpectedNumFiles (1,1) {mustBeInteger, mustBePositive};
            end
            
            files = LoadViprDS.getFiles(data_directory, opts.SearchTerm, opts);
            fs = fileDatastore(files, 'ReadFcn', @LoadViprDS.viprFileLoader);
        end
        
        function ds = getMagDataStore(fs)
            arguments
                fs {mustBeUnderlyingType(fs, 'matlab.io.datastore.FileDatastore')};
            end
            
            % get resolution of scan
            % assumes the header file is in the same directory as the .dat
            % files
            fpath = fs.Folders{1};
            header = LoadViprDS.parseArray(fpath);
            res = header.matrixx;
            
            % preallocate array
            data = zeros(res, res, res);
            
            fs.reset;
            while fs.hasdata
                data(:,:,:) = fs.read;
            end
            
            dim = 3;
            ds = arrayDatastore(data, 'IterationDimension', dim);
        end
        
    end
    
    % load functions for file data stores
    methods (Access = private, Static)

        function data = viprFileLoader(filename)
            % get resolution of scan
            % assumes the header file is in the same directory as the .dat
            % files
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
    % TODO: change access??
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
        end
        
    end

end