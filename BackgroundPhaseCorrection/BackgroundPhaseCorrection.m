classdef BackgroundPhaseCorrection < handle
    % methods for applying background phase correction to PC VIPR data
    
    properties (Access = protected)
        Image;
        Vmax;
        CDThreshold;
        NoiseThreshold;
        FitOrder;
        ApplyCorrection;
        VX;
		VY;
		VZ;
        PolyFitX = struct;
        PolyFitY = struct;
        PolyFitZ = struct;
    end
    
    % constructor
    methods (Access = public)

        function self = BackgroundPhaseCorrection()
            self.Image = 0.5;
            self.Vmax = 0.1;
            self.CDThreshold = 0.15;
            self.NoiseThreshold = 0.15;
            self.FitOrder = 2;
            self.ApplyCorrection = 1;
            self.reset_fit();
        end
        
    end
    
    methods (Access = protected)
        
        function mask = create_angiogram(self, VIPR)
            mask = int8(zeros(size(VIPR.MAG)));
            max_MAG = max(VIPR.MAG(:));
            for slice = 1:size(mask, 3)
                % Grab a slice
                mag_slice = single(VIPR.MAG(:, :, slice));
                vx_slice = single(self.VX(:, :, slice));
                vy_slice = single(self.VY(:, :, slice));
                vz_slice = single(self.VZ(:, :, slice));
            
                CD = sqrt(vx_slice.^2 + vy_slice.^2 + vz_slice.^2);
                mask(:, :, slice) = (mag_slice > self.NoiseThreshold * max_MAG) .* (CD < self.CDThreshold * VIPR.VelocityEncoding);
            end
        end
        
        function poly_fit_3d(self, mask)
            % Lots of memory problems with vectorization!!! solve Ax = B by (A^hA) x = (A^h *b)
            if self.FitOrder == 0
                self.PolyFitX.vals  = mean(self.VX(:));
                self.PolyFitX.px = 0;
                self.PolyFitX.py = 0;
                self.PolyFitX.pz = 0;
            
                self.PolyFitY.vals  = mean(self.VY(:));
                self.PolyFitY.px = 0;
                self.PolyFitY.py = 0;
                self.PolyFitY.pz = 0;
            
                self.PolyFitZ.vals  = mean(self.VZ(:));
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
            
                N = size(A,1);
            
                AhA = zeros(N,N);
                AhBx = zeros(N,1);
                AhBy = zeros(N,1);
                AhBz = zeros(N,1);
            
                xrange = single(linspace(-1,1,size(self.VX,1)));
                yrange = single(linspace(-1,1,size(self.VY,2)));
                zrange = single(linspace(-1,1,size(self.VZ,3)));
            
                for slice = 1:numel(zrange)
                    vx_slice = single(self.VX(:,:,slice));
                    vy_slice = single(self.VY(:,:,slice));
                    vz_slice = single(self.VZ(:,:,slice));
            
                    [y,x,z] = meshgrid(yrange, xrange, zrange(slice));
                    idx = find(mask(:, :, slice) > 0);
                    x = x(idx);
                    y = y(idx);
                    z = z(idx);
                    vx_slice = vx_slice(idx);
                    vy_slice = vy_slice(idx);
                    vz_slice = vz_slice(idx);
            
                    for i = 1:N
                        for j = 1:N
                            AhA(i,j) =  AhA(i,j) + sum((x.^px(i).*y.^py(i).*z.^pz(i)).*((x.^px(j).*y.^py(j).*z.^pz(j))));
                        end
                    end
            
                    for i = 1:N
                        AhBx(i) = AhBx(i) + sum(vx_slice.* ( x.^px(i).*y.^py(i).*z.^pz(i)));
                        AhBy(i) = AhBy(i) + sum(vy_slice.* ( x.^px(i).*y.^py(i).*z.^pz(i)));
                        AhBz(i) = AhBz(i) + sum(vz_slice.* ( x.^px(i).*y.^py(i).*z.^pz(i)));
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

        function [mag_slice, vel_mag] = get_slices(self, VIPR)
            Vmax_ = floor(500 * self.Vmax);
            NoiseThreshold_ = 0.3 * self.NoiseThreshold;
            rczres = size(VIPR.MAG, 3);
            slice = 1 + floor(self.Image*(rczres-1));
            
            % Get magnitude
            vx_slice = single(self.VX(:,:,slice));
            vy_slice = single(self.VY(:,:,slice));
            vz_slice = single(self.VZ(:,:,slice));
            mag_slice = single(VIPR.MAG(:,:,slice));

            xrange = single(linspace(-1, 1, size(self.VX, 1)));
            yrange = single(linspace(-1, 1, size(self.VY, 1)));
            zrange = single(linspace(-1, 1, size(self.VZ, 1)));
            
            % Range
            if self.ApplyCorrection == 1
                [y, x, z] = meshgrid(yrange, xrange, zrange(slice));    
                vx_slice = vx_slice - self.evaluate_poly(x, y, z, self.PolyFitX);
                vy_slice = vy_slice - self.evaluate_poly(x, y, z, self.PolyFitY);
                vz_slice = vz_slice - self.evaluate_poly(x, y, z, self.PolyFitZ);
            end
            
            vmag = sqrt(vx_slice.^2 + vy_slice.^2 + + vz_slice.^2);
            
            max_MAG = max(VIPR.MAG(:));
            idx = find((mag_slice > NoiseThreshold_ * max_MAG) & (vmag < self.CDThreshold * VIPR.VelocityEncoding));
            mag_slice = 200 * mag_slice/max(mag_slice(:));
            mag_slice(idx) = 257;
            
            vel_mag = sqrt(vx_slice.^2 + vy_slice.^2 + vz_slice.^2);
            vel_mag = 200*vel_mag / Vmax_;
            idx = vel_mag >= 199;
            vel_mag(idx) = 199;
        end
        
        function VIPR = poly_correction(self, VIPR)
            % Calculate a Polynomial 
            disp("Correcting polynomial...");
            xRange = single(linspace(-1, 1, size(VIPR.MAG, 1)));
            yRange = single(linspace(-1, 1, size(VIPR.MAG, 2)));
            zRange = single(linspace(-1, 1, size(VIPR.MAG, 3)));
            [y, x, z] = meshgrid(yRange, xRange, zRange);

            polyFit = [self.PolyFitX, self.PolyFitY, self.PolyFitZ];
            xyzNames = {'VX', 'VY', 'VZ'};
            for k = 1:numel(polyFit)
                name_ = xyzNames{k};
                fprintf('    %s\n', name_);
                back = self.evaluate_poly(x, y, z, polyFit(k));
                back = single(back);
                VIPR.VelocityMean(:, :, :, k) = VIPR.VelocityMean(:, :, :, k) - back;
                for m = 0:VIPR.NoFrames - 1
                    VIPR.Velocity(:, :, :, k, m+1) = VIPR.Velocity(:, :, :, k, m+1) - back;
                end
            end
        end

        function reset_fit(self)
            self.PolyFitX.vals = 0;
            self.PolyFitX.px = 0;
            self.PolyFitX.py = 0;
            self.PolyFitX.pz = 0;

            self.PolyFitY.vals = 0;
            self.PolyFitY.px = 0;
            self.PolyFitY.py = 0;
            self.PolyFitY.pz = 0;

            self.PolyFitZ.vals = 0;
            self.PolyFitZ.px = 0;
            self.PolyFitZ.py = 0;
            self.PolyFitZ.pz = 0;
        end
        
    end
    
    % misc static methods
    methods (Static, Access = private)
        
        function val = evaluate_poly(x, y, z, fit)
            val = 0;
            for k = 1:numel(fit.px)
                val = val + fit.vals(k)*(x.^fit.px(k).*y.^fit.py(k).*z.^fit.pz(k));
            end
        end

    end
    
end
