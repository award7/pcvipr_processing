classdef BackgroundPhaseCorrectionModel < handle
    
    properties (GetAccess = {?BaseController, ?BackgroundPhaseCorrectionView}, SetAccess = private)
        Image = 0.5;
        Vmax = 0.1;
        CDThreshold = 0.15;
        NoiseThreshold = 0.15;
        FitOrder = 2;
        ApplyCorrection = true;
        MagImage;
        VelocityImage;
        PolyFit = struct;
    end
    
    properties (GetAccess = public, SetAccess = private)
        CorrectionFactor;
    end
    
    properties (Access = {?BaseController, ?BackgroundPhaseCorrectionView}, Dependent)
        Map;
        WhiteImage;
    end
    
    % constructor
    methods
        
        function self = BackgroundPhaseCorrectionModel()
        end
        
    end
    
    % getters for dependent props
    methods
        
        function val = get.Map(self)
            val = [gray(200); jet(10)];
        end
        
        function val = get.WhiteImage(self)
            val = 255 * ones(480, 640, 3, 'uint8');
        end
        
    end
    
    % setters
    methods (Access = {?BaseController, ?BackgroundPhaseCorrectionModel})
        
        function setImage(self, val)
            arguments
                self;
                val {mustBeInRange(val, 0, 1)};
            end
            self.Image = val;
        end
        
        function setVmax(self, val)
            arguments
                self;
                val {mustBeInRange(val, 0, 1)};
            end
            self.Vmax = val;
        end
        
        function setCDThreshold(self, val)
            arguments
                self;
                val {mustBeInRange(val, 0, 1)};
            end
            self.CDThreshold = val;
        end
        
        function setNoiseThreshold(self, val)
            arguments
                self;
                val {mustBeInRange(val, 0, 1)};
            end
            self.NoiseThreshold = val;
        end
        
        function setFitOrder(self, val)
            arguments
                self;
                val {mustBeNumeric};
            end
            self.FitOrder = val;
        end
        
        function setApplyCorrection(self, val)
            arguments
                self;
                val (1,1) logical;
            end
            self.ApplyCorrection = val;
        end
        
        function setMagImage(self, val)
            arguments
                self;
                val;
            end
            self.MagImage = val;
        end
        
        function setMagImageCData(self, val)
            arguments
                self;
                val;
            end
            self.MagImage.CData = val;
        end
        
        function setVelocityImage(self, val)
            arguments
                self;
                val
            end
            self.VelocityImage = val;
        end
        
        function setVelocityImageCData(self, val)
            arguments
                self;
                val
            end
            self.VelocityImage.CData = val;
        end
        
        function setPolyFit(self, val)
            arguments
                self;
                val {mustBeA(val, 'struct')};
            end
            self.PolyFit = val;
        end
        
        function setCorrectionFactor(self, val)
            arguments
                self;
                val;
            end
            self.CorrectionFactor = val;
        end
        
    end
    
end