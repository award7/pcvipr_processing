classdef MAGrgb < handle
    %{ 
    create radiographic images for vessel selection
    %}
    
    properties (Access = public)
        MAGR;
        MAGG;
        MAGB;
        ColorMap = jet(255);
    end
    
    methods (Access = public)
        
        function self = MAGrgb(MAG, segment)
            if nargin ~= 0
                self.main(MAG, segment);
            end
        end
        
        function mag_rgb(self, MAG, segment)
            MAGmax = max(max(max(MAG)));
            self.r(MAG, MAGmax, segment);
            self.g(MAG, MAGmax, segment);
            self.b(MAG, MAGmax, segment);
        end
        
    end

    methods (Access = private)
        
        function r(self, MAG, MAGmax, segment)
            self.MAGR = im2uint8(MAG/MAGmax);
            self.MAGR(find(segment)) = self.ColorMap(255,1)*255;
            self.MAGR = self.MAGR(end:-1:1,:,end:-1:1);
            self.MAGR = self.MAGR(:,:,end:-1:1);
        end
        
        function g(self, MAG, MAGmax, segment)
            self.MAGG = im2uint8(MAG/MAGmax);
            self.MAGG(find(segment)) = self.ColorMap(150,2)*150;
            self.MAGG = self.MAGG(end:-1:1,:,end:-1:1);
            self.MAGG = self.MAGG(:,:,end:-1:1);
        end
        
        function b(self, MAG, MAGmax, segment)
            self.MAGB = im2uint8(MAG/MAGmax);
            self.MAGB(find(segment)) = self.ColorMap(1,3)*1;
            self.MAGB = self.MAGB(end:-1:1,:,end:-1:1);
            self.MAGB = self.MAGB(:,:,end:-1:1);
        end
        
    end
    
end

