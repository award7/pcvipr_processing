classdef LoadViprDS
    
    % create file datastores
    methods (Static)
        
        function fs = getVelocityMeanFileDataStore(data_directory)
            arguments
                data_directory {mustBeFolder};
            end
            
            search_term = 'comp_vd*.dat';
            num_files = 3;
            
            fs = LoadViprDS.getFileDatastore(data_directory, 'SearchTerm', search_term, 'ExpectedNumFiles', num_files);
        end
        
        function fs = getVelocityFileDataStore(data_directory)
            arguments
                data_directory {mustBeFolder};
            end
            
            % create velocity file store 
            search_term = 'ph_*vd*.dat';
            
            % 60 total files = 20 frames x 3 directions
            num_files = 20 * 3;
            
            fs = LoadViprDS.getFileDatastore(data_directory, 'SearchTerm', search_term, 'ExpectedNumFiles', num_files);
        end
        
        function fs = getMagDataStore(data_directory)
            arguments
                data_directory {mustBeFolder};
            end
            
            search_term = 'MAG.dat';
            num_files = 1;
            
            fs = LoadViprDS.getFileDatastore(data_directory, 'SearchTerm', search_term, 'ExpectedNumFiles', num_files);
        end
        
    end
    
    % create datastores by loadin data from files
    methods (Static)
        
        function ds = loadVelocityData(fs, resolution)
            arguments
                fs {mustBeUnderlyingType(fs, 'matlab.io.datastore.FileDatastore')};
                resolution {mustBeInteger, mustBePositive};
            end
            
            % get # of partitions
            % 60 total files = 20 frames x 3 directions --> do 20 partitions
            n_partitions = num_files/3;
           
            % init data array
            data = zeros(resolution, resolution, resolution, 3, 20);
            for i = 1:n_partitions
               % get a partition
               sub_ds = fs.partition(n_partitions, i);
               data(:,:,:,:,i) = LoadViprDS.readDat(sub_ds, resolution);
            end
            
            % place into arrayDatastore
            % make IterationDimension = to the frame dimension
            % make ReadSize so it reads all three directions for a given
            % frame
            ds = arrayDatastore(data, 'IterationDimension', 5, 'ReadSize', 3);
        end
        
        function ds = loadMagData(fs, resolution)
            arguments
                fs {mustBeUnderlyingType(fs, 'matlab.io.datastore.FileDatastore')};
                resolution {mustBeInteger, mustBePositive};
            end

            data = LoadViprDS.readDat(fs, resolution);
            data = single(data);
            ds = arrayDatastore(data, 'IterationDimension', 3, 'ReadSize', 1);
        end
        
        function ds = loadVelocityMeanData(fs, resolution)
            arguments
                fs {mustBeUnderlyingType(fs, 'matlab.io.datastore.FileDatastore')};
                resolution {mustBeInteger, mustBePositive};
            end
            
            % init data array
            data = zeros(resolution, resolution, resolution, num_files);
            
            data(:,:,:,:) = LoadViprDS.readDat(fs, resolution);
            
            % place into arrayDataStore
            % make IterationDimension = to the direction dimension
            % make ReadSize so it reads only one direction
            ds = arrayDatastore(data, 'IterationDimension', 4, 'ReadSize', 1);
        end
        
    end
    
    % helper functions
    methods (Static)
        
        function fs = getFileDatastore(data_directory, opts)
            arguments
                data_directory {mustBeFolder};
                opts.SearchTerm {mustBeTextScalar} = '*';
                opts.ExpectedNumFiles {mustBeInteger, mustBePositive} = 1;
            end
            
            file_struct = dir(fullfile(data_directory, opts.SearchTerm));
            n_files = length(file_struct);
            
            % do a check
            if ne(n_files, opts.ExpectedNumFiles)
                % todo: throw error indicating that that the #files found does not
                % match what was expected, check search term or file path
                % throw ME;
            end
            
            files = cell(n_files, 1);
            
            for i = 1:n_files
                files{i} = fullfile(file_struct(i).folder, file_struct(i).name);
            end
            
            fs = fileDatastore(files, 'ReadFcn', @LoadViprDS.customLoad);
        end
        
        function data = customLoad(filename)
            arguments
                filename {mustBeFile};
            end
            
            fid = fopen(filename);
            data = fread(fid, 'short');
            fclose(fid);
        end
        
        function data = readDat(fs, resolution)
            arguments
                fs {mustBeUnderlyingType(fs, 'matlab.io.datastore.FileDatastore')};
                resolution {mustBeInteger, mustBePositive};
            end
            
            data = zeros(resolution, resolution, resolution, 3);
            i = 1;
            
            while fs.hasdata
                raw_data = fs.read;
                data(:,:,:,i) = reshape(raw_data, 320, 320, 320);
                i = i + 1;
            end
        end
        
    end

end