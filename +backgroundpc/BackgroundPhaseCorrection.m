classdef BackgroundPhaseCorrection < handle
    % methods for applying background phase correction to PC VIPR data
    
    properties (Access = public)
        ApplyCorrection (1,1) uint8 {mustBeInRange(ApplyCorrection, 0, 1)} = 1;
        CDThreshold     (1,1) double {mustBeInRange(CDThreshold, 0, 1)} = 0.15;
        FitOrder        (1,1) uint8 = 2;
        Image           (1,1) double {mustBeInRange(Image, 0, 1)} = 0.5;
        NoiseThreshold  (1,1) double {mustBeInRange(NoiseThreshold, 0, 1)} = 0.15;
        Vmax            (1,1) double {mustBeInRange(Vmax, 0, 1)} = 0.1;
        PolyFit         struct;
        VX              {mustBeNumeric};
		VY              {mustBeNumeric};
		VZ              {mustBeNumeric};
    end
    
    properties (Access = private, Transient)
        MXStart         (1,1) uint8 {mustBeGreaterThan(MXStart, 0)} = 1;
        MXStop          (1,1) uint8 {mustBeGreaterThan(MXStop, 0)} = 1;    
        MYStart         (1,1) uint8 {mustBeGreaterThan(MYStart, 0)} = 1;
        MYStop          (1,1) uint8 {mustBeGreaterThan(MYStop, 0)} = 1;
        MZStart         (1,1) uint8 {mustBeGreaterThan(MZStart, 0)} = 1;
        MZStop          (1,1) uint8 {mustBeGreaterThan(MZStop, 0)} = 1;
    end
    
    % constructor
    methods (Access = protected)

        function self = BackgroundPhaseCorrection()
            self.resetFit();
        end
        
    end
    
    % general methods
    methods (Access = public)
        
        function mask = createAngiogram(self, MAG, VelocityEncoding)
            mask = int8(zeros(size(MAG)));
            maxMAG = max(MAG(:));
            for slice = 1:size(mask, 3)
                % Grab a slice
                magSlice = single(MAG(:, :, slice));
                vxSlice = single(self.VX(:, :, slice));
                vySlice = single(self.VY(:, :, slice));
                vzSlice = single(self.VZ(:, :, slice));
            
                CD = sqrt(vxSlice.^2 + vySlice.^2 + vzSlice.^2);
                mask(:, :, slice) = (magSlice > self.NoiseThreshold * maxMAG) .* (CD < self.CDThreshold * VelocityEncoding);
            end
        end
        
        function polyFit3d(self, mask)
            % Lots of memory problems with vectorization!!! solve Ax = B by (A^hA) x = (A^h *b)
            if self.FitOrder == 0
                self.PolyFitX.vals = mean(self.VX(:));
                self.PolyFitX.px = 0;
                self.PolyFitX.py = 0;
                self.PolyFitX.pz = 0;
            
                self.PolyFitY.vals = mean(self.VY(:));
                self.PolyFitY.px = 0;
                self.PolyFitY.py = 0;
                self.PolyFitY.pz = 0;
            
                self.PolyFitZ.vals = mean(self.VZ(:));
                self.PolyFitZ.px = 0;
                self.PolyFitZ.py = 0;
                self.PolyFitZ.pz = 0;
            else
                [px, py, pz] = meshgrid(0:self.FitOrder, 0:self.FitOrder, 0:self.FitOrder);
                idx2 = find((px+py+pz) <= self.FitOrder);
                px = px(idx2);
                py = py(idx2);
                pz = pz(idx2);
                A = [px(:) py(:) pz(:)];
            
                sz = size(A,1);
            
                AhA = zeros(sz, sz);
                AhBx = zeros(sz, 1);
                AhBy = zeros(sz, 1);
                AhBz = zeros(sz, 1);
            
                xRange = single(linspace(-1, 1, size(self.VX, 1)));
                yRange = single(linspace(-1, 1, size(self.VY, 2)));
                zRange = single(linspace(-1, 1, size(self.VZ, 3)));
            
                for slice = 1:numel(zRange)
                    vxSlice = single(self.VX(:, :, slice));
                    vySlice = single(self.VY(:, :, slice));
                    vzSlice = single(self.VZ(:, :, slice));
            
                    [y,x,z] = meshgrid(yRange, xRange, zRange(slice));
                    idx = find(mask(:, :, slice) > 0);
                    x = x(idx);
                    y = y(idx);
                    z = z(idx);
                    vxSlice = vxSlice(idx);
                    vySlice = vySlice(idx);
                    vzSlice = vzSlice(idx);
            
                    for m = 1:sz
                        for n = 1:sz
                            AhA(m,n) = AhA(m,n) + sum((x.^px(m).*y.^py(m).*z.^pz(m)).*((x.^px(n).*y.^py(n).*z.^pz(n))));
                        end
                    end
            
                    for k = 1:sz
                        AhBx(k) = AhBx(k) + sum(vxSlice.*(x.^px(k).*y.^py(k).*z.^pz(k)));
                        AhBy(k) = AhBy(k) + sum(vySlice.*(x.^px(k).*y.^py(k).*z.^pz(k)));
                        AhBz(k) = AhBz(k) + sum(vzSlice.*(x.^px(k).*y.^py(k).*z.^pz(k)));
                    end
                end
            
                % save variables to struct
                self.PolyFitX.vals = linsolve(AhA, AhBx);
                self.PolyFitX.px = px;
                self.PolyFitX.py = py;
                self.PolyFitX.pz = pz;
            
                self.PolyFitY.vals = linsolve(AhA, AhBy);
                self.PolyFitY.px = px;
                self.PolyFitY.py = py;
                self.PolyFitY.pz = pz;
            
                self.PolyFitZ.vals = linsolve(AhA, AhBz);
                self.PolyFitZ.px = px;
                self.PolyFitZ.py = py;
                self.PolyFitZ.pz = pz;
            end
        end

        function [magSlice, velMAG] = getSlices(self, MAG, velocityEncoding)
            vMax = floor(500 * self.Vmax);
            noiseThreshold_ = 0.3 * self.NoiseThreshold;
            rczres = size(MAG, 3);
            slice = 1 + floor(self.Image*(rczres-1));
            
            % Get magnitude
            vxSlice = single(self.VX(:,:,slice));
            vySlice = single(self.VY(:,:,slice));
            vzSlice = single(self.VZ(:,:,slice));
            magSlice = single(MAG(:,:,slice));

            xRange = single(linspace(-1, 1, size(self.VX, 1)));
            yRange = single(linspace(-1, 1, size(self.VY, 1)));
            zRange = single(linspace(-1, 1, size(self.VZ, 1)));
            
            % Range
            if self.ApplyCorrection == 1
                [y, x, z] = meshgrid(yRange, xRange, zRange(slice));    
                vxSlice = vxSlice - self.evaluatePoly(x, y, z, self.PolyFit.x);
                vySlice = vySlice - self.evaluatePoly(x, y, z, self.PolyFit.y);
                vzSlice = vzSlice - self.evaluatePoly(x, y, z, self.PolyFit.z);
            end
            
            vMAG = sqrt(vxSlice.^2 + vySlice.^2 + + vzSlice.^2);
            
            maxMAG = max(MAG(:));
            idx = find((magSlice > noiseThreshold_ * maxMAG) & (vMAG < self.CDThreshold * velocityEncoding));
            magSlice = 200 * magSlice/max(magSlice(:));
            magSlice(idx) = 257;
            
            velMAG = sqrt(vxSlice.^2 + vySlice.^2 + vzSlice.^2);
            velMAG = 200 * velMAG / vMax;
            idx = velMAG >= 199;
            velMAG(idx) = 199;
        end
        
        function velocityArray = polyCorrection(self, MAG, velocity, velocityMean, noFrames, dlg)
            % optional: pass in dialog waitbar
            msg = 'Correcting polynomial';
            if exist('dlg', 'var')
                dlg.Message = msg;
                dlg.Value = 0;
            else
                disp(msg);
            end
            
            % Calculate a Polynomial
            xRange = single(linspace(-1, 1, size(MAG, 1)));
            yRange = single(linspace(-1, 1, size(MAG, 2)));
            zRange = single(linspace(-1, 1, size(MAG, 3)));
            [y, x, z] = meshgrid(yRange, xRange, zRange);

            xyzNames = {'VX', 'VY', 'VZ'};
            coordinates = {'x', 'y', 'z'};
            velocityArray = velocityMean;
            for k = 1:3
                name = xyzNames{k};
                msg = strcat("Correcting polynomial: ", name);
                
                if exist('dlg', 'var')
                    dlg.Message = msg;
                else
                    disp(msg);
                end
                
                back = self.evaluatePoly(x, y, z, self.PolyFit.(coordinates{k}));
                velocityArray(:, :, :, k) = velocityMean(:, :, :, k) - back;
                back = int16(back);
                for m = 0:noFrames - 1
                    velocityArray(:, :, :, k, m+1) = velocity(:, :, :, k, m+1) - back;
                end
                
                if exist('dlg', 'var')
                    dlg.Value = k/3;
                end
            end
        end

        function resetFit(self)
            coordinates = {'x', 'y', 'z'};
            fields = {'vals', 'px', 'py', 'pz'};
            for m = 1:numel(coordinates)
                for n = 1:numel(fields)
                    self.PolyFit(1).(coordinates{m}).(fields{n}) = 0;
                end
            end
            
%             self.PolyFitX.vals = 0;
%             self.PolyFitX.px = 0;
%             self.PolyFitX.py = 0;
%             self.PolyFitX.pz = 0;
% 
%             self.PolyFitY.vals = 0;
%             self.PolyFitY.px = 0;
%             self.PolyFitY.py = 0;
%             self.PolyFitY.pz = 0;
% 
%             self.PolyFitZ.vals = 0;
%             self.PolyFitZ.px = 0;
%             self.PolyFitZ.py = 0;
%             self.PolyFitZ.pz = 0;
        end
        
        function segment = calculateSegment(self, resolution, timeMIP, dlg)
            msg = "Calculating segment";
            if exist('dlg', 'var')
                dlg.Message = msg;
                dlg.Value = 0;
            else
                disp(msg);
            end
            
            self.MXStop = resolution;
            self.MYStop = resolution;
            self.MZStop = resolution;
            
            timeMIP2 = zeros(size(timeMIP));
            timeMIP2(self.MXStart:self.MXStop, self.MYStart:self.MYStop, self.MZStart:self.MZStop) = 1;
            timeMIPCrop = timeMIP .* timeMIP2;
            normedMIP = timeMIPCrop(:) ./ max(timeMIPCrop(:));
            [muhat, sigmahat] = normfit(normedMIP);
            segment = zeros(size(timeMIPCrop));
            segment(normedMIP > muhat + 4.5 * sigmahat) = 1;

            %The value at the end of the commnad in the minimum area of each segment to keep 
            segment = bwareaopen(segment, round(sum(segment(:)) .* 0.005), 6); 
            
            % Fill in holes created by slow flow on the inside of vessels
            segment = imfill(segment, 'holes'); 
            segment = single(segment);
            
            if exist('dlg', 'var')
                dlg.Value = 1;
            end
        end

    end
    
    % static methods, protected
    methods (Access = public, Static)
        
        function timeMIP = calculateAngiogram(MAG, velocityMean, velocityEncoding, dlg)
            msg = "Calculating max intensity projection";
            if exist('dlg', 'var')
                dlg.Message = msg;
                dlg.Value = 0;
            else
                disp(msg);
            end

            % timeMIP = zeros(size(MAG), 'single');
            Vmag = sqrt(sum(velocityMean.^2, 4));
            idx = find(Vmag > velocityEncoding);
            Vmag(idx) = velocityEncoding;
            timeMIP = single(32000 * MAG .* sin(pi/2*Vmag/velocityEncoding));
            
            if exist('dlg', 'var')
                dlg.Value = 1;
            end
        end
        
    end
    
    % static methods, private
    methods (Access = private, Static)
        
        function val = evaluatePoly(x, y, z, fit)
            val = 0;
            for k = 1:numel(fit.px)
                val = val + fit.vals(k)*(x.^fit.px(k).*y.^fit.py(k).*z.^fit.pz(k));
            end
        end

    end
    
end
