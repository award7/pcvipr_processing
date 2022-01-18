classdef Model < handle
    
    % main properties
    properties (Access = public)
        VelocityDS;
        VelocityMeanDS;
        MagDS;
    end
    
    % BackgroundPhaseCorrection-specific properties
    properties (Access = public)
        Image = 0.5;
        Vmax = 0.1;
        CDThreshold = 0.15;
        NoiseThreshold = 0.15;
        FitOrder = 2;
        ApplyCorrection = 1;
    end
    
    methods
        
        function self = Model() 
        end
        
        function out = someFcn(self)
            out = 'Called someFcn';
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
            self.VelocityDS = ds;
        end
        
        function set.VelocityMeanDS(self, ds)
            self.VelocityMeanDS = ds;
        end
        
        function set.MagDS(self, ds)
            self.MagDS = ds;
        end
        
    end
    
end