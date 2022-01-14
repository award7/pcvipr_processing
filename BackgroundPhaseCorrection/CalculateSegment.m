classdef CalculateSegment < handle
    % calculate Segment following background phase correction
    
    properties (Access = private, Transient)
        MXStart;
        MXStop;
        MYStart;
        MYStop;
        MZStart;
        MZStop;
    end
    
    methods (Access = public)
        
        function [self, segment] = CalculateSegment(VIPR)
            self.MXStart = 1;
            self.MYStart = 1;
            self.MZStart = 1;
            self.MXStop = VIPR.Resolution;
            self.MYStop = VIPR.Resolution;
            self.MZStop = VIPR.Resolution;
            segment = self.main(VIPR);
        end
        
    end
    
    methods (Access = private)
        
        function segment = main(self, VIPR)
            disp("Calculating segment...");
            timeMIP2 = zeros(size(VIPR.TimeMIP));
            timeMIP2(self.MXStart:self.MXStop, self.MYStart:self.MYStop, self.MZStart:self.MZStop) = 1;
            timeMIP_crop = VIPR.TimeMIP.*timeMIP2;
            normed_MIP = timeMIP_crop(:)./max(timeMIP_crop(:));
            [muhat,sigmahat] = normfit(normed_MIP);
            segment = zeros(size(timeMIP_crop));
            segment(normed_MIP>muhat+4.5*sigmahat) = 1;

            % The value at the end of the commnad in the minimum area of each segment to keep 
            segment = bwareaopen(segment, round(sum(segment(:)) .* 0.005), 6); 
            
            % Fill in holes created by slow flow on the inside of vessels
            segment = imfill(segment, 'holes'); 
            segment = single(segment);
        end
        
    end
    
end

