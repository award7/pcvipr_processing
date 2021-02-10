classdef CalculateAngiogram
    % calculate angiogram following background phase correction
    % returns timeMIP
    
    methods (Static)
        
        function timeMIP = calculate_angiogram(VIPR)
            disp("Calculating max intensity projection...");
            timeMIP = zeros(size(VIPR.MAG), 'single');
            Vmag = sqrt(sum(VIPR.VelocityMean.^2, 4));
            idx = find(Vmag > VIPR.VelocityEncoding);
            Vmag(idx) = VIPR.VelocityEncoding;
            timeMIP = 32000 * VIPR.MAG .* sin(pi/2*Vmag/VIPR.VelocityEncoding);
        end
        
    end
    
end
