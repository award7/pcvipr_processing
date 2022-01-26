classdef VesselSelectionModel < handle
    
    % MAG data
    properties
        % fields of "R", "G", "B"
        MAGrgb = struct;
    end
    
    % MAGrgb color maps
    properties (Dependent)
        MAGrColorMap;
        MAGgColorMap;
        MAGbColorMap;
    end
    
    % slice data
    properties (GetAccess = public, SetAccess = private)
        % TODO: refactor to store xyz components into a struct with first 
        % order fields of "X", "Y", "Z" with secondary order "Value" and 
        % "Max"
        % e.g. Slice.X.Value = (current slice value)
        Slice = struct;
        XSlice;
        YSlice;
        ZSlice;
        XSliceMax;
        YSliceMax;
        ZSliceMax;
    end
    
    % constants
    properties (Constant)
        AbsLowerBound = 1;
    end
    
    % coordinates
    properties (GetAccess = public, SetAccess = private)
        % TODO: refactor to store xyz components into a struct with first 
        % order fields of "X", "Y", "Z"
        % e.g. Coordinate.X = (current X coordinate value)
        Coordinate = struct;
        
        XCoordinate;
        YCoordinate;
        ZCoordinate;
    end
    
    % image data
    properties (GetAccess = public, SetAccess = private)
        % TODO: refactor these into a struct???
        % e.g. Data.Sagittal, Image.Sagittal
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
    
    % getters
    methods
        
        function val = get.MAGrColorMap(self)
            map = jet(255);
            val = map(255,1)*255;
        end
        
        function val = get.MAGgColorMap(self)
            map = jet(255);
            val = map(150,2)*150;
        end
        
        function val = get.MAGbColorMap(self)
            map = jet(255);
            val = map(1,3)*1;
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
        
        function setMAGrgb(self, field, val)
            arguments
                self;
                field {mustBeMember(field, {'R', 'G', 'B'})};
                val;
            end
            
            self.MAGrgb.(field) = val;
        end

    end
    
end