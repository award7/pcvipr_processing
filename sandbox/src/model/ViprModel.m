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
        
        function setVersion(self, val)
            arguments
                self;
                val (1,1) {mustBeNumeric, mustBePositive};
            end
            self.Version = val;
        end
        
        function setExam(self, val)
            arguments
                self;
                val (1,1) {mustBeNumeric};
            end
            self.Exam = val;
        end
        
        function setPfile(self, val)
            arguments
                self;
                val {mustBeTextScalar};
            end
            self.Pfile = val;
        end
        
        function setMatrixx(self, val)
            arguments
                self;
                val (1,1) {mustBeNumeric};
            end
            self.Matrixx = val;
        end
        
        function setMatrixy(self, val)
            arguments
                self;
                val (1,1) {mustBeNumeric};
            end
            self.Matrixy = val;
        end
        
        function setMatrixz(self, val)
            arguments
                self;
                val (1,1) {mustBeNumeric};
            end
            self.Matrixz = val;
        end
        
        function setFOVx(self, val)
            arguments
                self;
                val (1,1) {mustBeNumeric};
            end
            self.FOVx = val;
        end
        
        function setFOVy(self, val)
            arguments
                self;
                val (1,1) {mustBeNumeric};
            end
            self.FOVy = val;
        end
        
        function setFOVz(self, val)
            arguments
                self;
                val (1,1) {mustBeNumeric};
            end
            self.FOVz = val;
        end
        
        function setFrames(self, val)
            arguments
                self;
                val (1,1) {mustBeNumeric};
            end
            self.Frames = val;
        end
        
        function setTimeRes(self, val)
            arguments
                self;
                val (1,1) {mustBeNumeric};
            end
            self.TimeRes = val;
        end
        
        function setix(self, val)
            arguments
                self;
                val (1,1) {mustBeNumeric};
            end
            self.ix = val;
        end
        
        function setiy(self, val)
            arguments
                self;
                val (1,1) {mustBeNumeric};
            end
            self.iy = val;
        end
        
        function setiz(self, val)
            arguments
                self;
                val (1,1) {mustBeNumeric};
            end
            self.iz = val;
        end
        
        function setjx(self, val)
            arguments
                self;
                val (1,1) {mustBeNumeric};
            end
            self.jx = val;
        end
        
        function setjy(self, val)
            arguments
                self;
                val (1,1) {mustBeNumeric};
            end
            self.jy = val;
        end
        
        function setjz(self, val)
            arguments
                self;
                val (1,1) {mustBeNumeric};
            end
            self.jz = val;
        end
        
        function setkx(self, val)
            arguments
                self;
                val (1,1) {mustBeNumeric};
            end
            self.kx = val;
        end
        
        function setky(self, val)
            arguments
                self;
                val (1,1) {mustBeNumeric};
            end
            self.ky = val;
        end
        
        function setkz(self, val)
            arguments
                self;
                val (1,1) {mustBeNumeric};
            end
            self.kz = val;
        end
        
        function setsx(self, val)
            arguments
                self;
                val (1,1) {mustBeNumeric};
            end
            self.sx = val;
        end
        
        function setsy(self, val)
            arguments
                self;
                val (1,1) {mustBeNumeric};
            end
            self.sy = val;
        end
        
        function setsz(self, val)
            arguments
                self;
                val (1,1) {mustBeNumeric};
            end
            self.sz = val;
        end
        
        function setVENC(self, val)
            arguments
                self;
                val (1,1) {mustBeNumeric};
            end
            self.VENC = val;
        end
        
        function setvx0(self, val)
            arguments
                self;
                val (1,1) {mustBeNumeric};
            end
            self.vx0 = val;
        end
        
        function setvy0(self, val)
            arguments
                self;
                val (1,1) {mustBeNumeric};
            end
            self.vy0 = val;
        end
        
        function setvz0(self, val)
            arguments
                self;
                val (1,1) {mustBeNumeric};
            end
            self.vz0 = val;
        end
        
        function setvx1(self, val)
            arguments
                self;
                val (1,1) {mustBeNumeric};
            end
            self.vx1 = val;
        end
        
        function setvy1(self, val)
            arguments
                self;
                val (1,1) {mustBeNumeric};
            end
            self.vy1 = val;
        end
        
        function setvz1(self, val)
            arguments
                self;
                val (1,1) {mustBeNumeric};
            end
            self.vz1 = val;
        end
        
        function setvx2(self, val)
            arguments
                self;
                val (1,1) {mustBeNumeric};
            end
            self.vx2 = val;
        end
        
        function setvy2(self, val)
            arguments
                self;
                val (1,1) {mustBeNumeric};
            end
            self.vy2 = val;
        end
        
        function setvz2(self, val)
            arguments
                self;
                val (1,1) {mustBeNumeric};
            end
            self.vz2 = val;
        end
        
        function setScanParameters(self, val)
            arguments
                self;
                val (1,1) {mustBeA(val, 'struct')};
            end
            self.ScanParameters = val;
        end
        
    end
    
end