classdef BackgroundPhaseCorrectionModel < handle
    
    properties (GetAccess = public, SetAccess = private)
        Image = 0.5;
        Vmax = 0.1;
        CDThreshold = 0.15;
        NoiseThreshold = 0.15;
        FitOrder = 2;
        ApplyCorrection = 1;
        MagImage;
        VelocityImage;
    end
    
    properties (Dependent)
        Map;
        WhiteImage;
    end
    
    % constructor
    methods
        
        function self = BackgroundPhaseCorrectionModel()
        end
        
    end
    
    % initialization of images
    methods (Access = public)
        
        function initMagImage(self, parent)
            arguments
                self;
                parent;
            end
            img = self.WhiteImage;
            self.MagImage = imagesc(parent, 'CData', img, [0 210]);
        end
        
        function initVelocityImage(self, parent)
            arguments
                self;
                parent;
            end
            img = self.WhiteImage;
            self.VelocityImage = imagesc(parent, 'CData', img, [0 210]);
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
    methods
        
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
        
        function setVelocityImage(self, val)
            arguments
                self;
                val
            end
            self.VelocityImage = val;
        end
        
    end
    
end