classdef VesselSelectionModel < handle
    
    % slice data
    properties (GetAccess = public, SetAccess = private)
        XSlice;
        YSlice;
        ZSlice;
        
        XSliceMax;
        YSliceMax;
        ZSliceMax;
    end
    
    properties (GetAccess = public, SetAccess = private)
        XCoordinate;
        YCoordinate;
        ZCoordinate;
    end
    
    properties (GetAccess = public, SetAccess = private)
        SagittalData;
        CoronalData;
        AxialData;
        
        SagittalImage;
        CoronalImage;
        AxialImage;
    end
    
    % constructor
    methods (Access = public)
        
        function self = VesselSelectionModel()
        end
        
    end
    
    % setters
    methods
        
        function setAxialImage(self, val)
            arguments
                self;
                val;
            end
            self.AxialImage = val;
        end
        
        function setCoronalImage(self, val)
            arguments
                self;
                val;
            end
            self.CoronalImage = val;
        end
        
        function setSagittalImage(self, val)
            arguments
                self;
                val;
            end
            self.SagittalImage = val;
        end
        
        function setAxialData(self, val)
            arguments
                self;
                val;
            end
            self.AxialData = val;
        end
        
        function setCoronalData(self, val)
            arguments
                self;
                val;
            end
            self.CoronalData = val;
        end
        
        function setSagittalData(self, val)
            arguments
                self;
                val;
            end
            self.SagittalData = val;
        end
        
        function setXSlice(self, val)
            arguments
                self;
                val {mustBeInteger, mustBePositive};
            end
            self.XSlice = val;
        end
        
        function setYSlice(self, val)
            arguments
                self;
                val {mustBeInteger, mustBePositive};
            end
            self.YSlice = val;
        end
        
        function setZSlice(self, val)
            arguments
                self;
                val {mustBeInteger, mustBePositive};
            end
            self.ZSlice = val;
        end
        
        function setXSliceMax(self, val)
            arguments
                self;
                val {mustBeInteger, mustBePositive};
            end
            self.XSliceMax = val;
        end
        
        function setYSliceMax(self, val)
            arguments
                self;
                val {mustBeInteger, mustBePositive};
            end
            self.YSliceMax = val;
        end
        
        function setZSliceMax(self, val)
            arguments
                self;
                val {mustBeInteger, mustBePositive};
            end
            self.ZSliceMax = val;
        end
        
        
        function setXCoordinate(self, val)
            arguments
                self;
                val {mustBeInteger, mustBePositive};
            end
            self.XCoordinate = val;
        end
        
        function setYCoordinate(self, val)
            arguments
                self;
                val {mustBeInteger, mustBePositive};
            end
            self.YCoordinate = val;
        end
        
        function setZCoordinate(self, val)
            arguments
                self;
                val {mustBeInteger, mustBePositive};
            end
            self.ZCoordinate = val;
        end
        
    end
    
end