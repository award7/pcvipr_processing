classdef ViprModel < handle
    % Model to hold any VIPR-related properties e.g. Velocity array FOV
    
    % data stores
    properties (GetAccess = public, SetAccess = private)
        VelocityDS;
        VelocityMeanDS;
        MagDS;
    end
    
    % file stores
    properties (GetAccess = public, SetAccess = private)
        VelocityFS;
        VelocityMeanFS;
        MagFS;
    end
    
    % large arrays
    properties (GetAccess = public, SetAccess = private)
        % these are used temporarily in with certain views to allow faster
        % image viewing by loading the data into memory from the respective 
        % filestore
        VelocityArray;
        VelocityMeanArray;
        MagArray;
        
        % these arrays persist after creation
        % they could be written to disk and a filestore created...
        TimeMip;
        Segment;
        BranchList;
        BranchMat;
    end
    
    % vipr processing parameters
    properties (GetAccess = public,  SetAccess = private)
        % data source
        DataDirectory;
        
        % field of view in cm
        FOV;
        
        % number of reconstructed frames
        NoFrames;
        
        % number of pixels in row,col,slices
        Resolution;
        
        % temporal resolution
        TimeResolution;
        
        % velocity encoding of scan
        VelocityEncoding;
    end
    
    % raw header file info in a struct
    properties(GetAccess = public, SetAccess = private)
        ScanParameters;
    end
    
    % constructor
    methods (Access = ?BaseController)
        function self = ViprModel()
        end
    end
    
    % setters
    methods (Access = ?BaseController)
        
        function setVelocityDS(self, val)
            arguments
                self;
                val {mustBeUnderlyingType(val, 'matlab.io.datastore.ArrayDatastore')};
            end
            self.VelocityDS = val;   
        end
        
        function setVelocityMeanDS(self, val)
            arguments
                self;
                val {mustBeUnderlyingType(val, 'matlab.io.datastore.ArrayDatastore')};
            end
            self.VelocityMeanDS = val;
        end
        
        function setMagDS(self, val)
            arguments
                self;
                val {mustBeUnderlyingType(val, 'matlab.io.datastore.ArrayDatastore')};
            end
            self.MagDS = val;  
        end
        
        function setVelocityFS(self, val)
            arguments
                self;
                val {mustBeUnderlyingType(val, 'matlab.io.datastore.FileDatastore')};
            end
            self.VelocityFS = val;  
        end
        
        function setVelocityMeanFS(self, val)
            arguments
                self;
                val {mustBeUnderlyingType(val, 'matlab.io.datastore.FileDatastore')};
            end
            self.VelocityMeanFS = val; 
        end
        
        function setMagFS(self, val)
            arguments
                self;
                val {mustBeUnderlyingType(val, 'matlab.io.datastore.FileDatastore')};
            end
            self.MagFS = val; 
        end
        
        function setDataDirectory(self, val)
            arguments
                self;
                val {mustBeTextScalar, mustBeFolder};
            end
            self.DataDirectory = val;
        end
        
        function setFOV(self, val)
            arguments
                self;
                val {mustBeNumeric, mustBePositive};
            end
            self.FOV = val;
        end
        
        function setNoFrames(self, val)
            arguments
                self;
                val (1,1) {mustBeNumeric, mustBePositive};
            end
            self.NoFrames = val;
        end
        
        function setResolution(self, val)
            arguments
                self;
                val (1,1) {mustBeNumeric, mustBePositive};
            end
            self.Resolution = val;
        end
        
        function setTimeResolution(self, val)
            arguments
                self;
                val (1,1) {mustBeNumeric, mustBePositive};
            end
            self.TimeResolution = val;
        end
        
        function setVelocityEncoding(self, val)
            arguments
                self;
                val (1,1) {mustBeNumeric, mustBePositive};
            end
            self.VelocityEncoding = val;
        end
                
        function setScanParameters(self, val)
            arguments
                self;
                val (1,1) {mustBeA(val, 'struct')};
            end
            self.ScanParameters = val;
        end
        
        % TODO: add validation to these methods
        function setVelocityArray(self, val)
            arguments
                self;
                val;
            end
            self.VelocityArray = val;
        end
        
        function setVelocityMeanArray(self, val)
            arguments
                self;
                val;
            end
            self.VelocityMeanArray = val;
        end
        
        function setMagArray(self, val)
            arguments
                self;
                val;
            end
            self.MagArray = val;
        end
        
        function setTimeMip(self, val)
            arguments
                self;
                val;
            end
            self.TimeMip = val;
        end
        
        function setSegment(self, val)
            arguments
                self;
                val;
            end
            self.Segment = val;
        end
        
        function setBranchMat(self, val)
            arguments
                self;
                val;
            end
            self.BranchMat = val;
        end
        
        function setBranchList(self, val)
            arguments
                self;
                val;
            end
            self.BranchList = val;
        end
        
    end
    
end