classdef ViprModel < handle
    % Model to hold any VIPR-related properties e.g. Velocity array, FOV
    
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
    
    % header file info
    properties (GetAccess = public, SetAccess = private)
        DataDirectory;
        FOV;
        NoFrames;
        Resolution;
        TimeResolution;
        VelocityEncoding;
    end
   
    methods (Access = ?Controller)
        function self = ViprModel()
        end
    end
    
    % getters
    methods
        function val = get.VelocityDS(self)
            val = self.VelocityDS;
        end
        
        function val = get.VelocityMeanDS(self)
            val = self.VelocityMeanDS;
        end
        
        function val = get.MagDS(self)
            val = self.MagDS;
        end
    end
    
    % setters
    methods
        
        function set.VelocityDS(self, ds)
            switch class(ds)
                case 'matlab.io.datastore.FileDatastore'
                    self.VelocityDS = ds;
                otherwise
                    % todo: throw error
            end
        end
        
        function set.VelocityMeanDS(self, ds)
            switch class(ds)
                case 'matlab.io.datastore.FileDatastore'
                    self.VelocityMeanDS = ds;
                otherwise
                    % todo: throw error
            end
        end
        
        function set.MagDS(self, ds)
            switch class(ds)
                case 'matlab.io.datastore.FileDatastore'
                    self.MagDS = ds;
                otherwise
                    % todo: throw error
            end
        end
        
    end
    
end