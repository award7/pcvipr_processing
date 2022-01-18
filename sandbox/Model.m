classdef Model < handle
    
    % BackgroundPhaseCorrection properties
    properties
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
    
end