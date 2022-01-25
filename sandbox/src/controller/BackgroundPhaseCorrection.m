classdef BackgroundPhaseCorrection < handle
    % methods for applying background phase correction to PC VIPR data
    % TODO: make naming conventions consistent
        % PascalCase for properties
        % camelCase for methods
        % snake_case for local variables
    % TODO: add validations to properties   
   
    methods (Access = ?BaseController, Static)
        
        function [mag_slice, vel_mag] = getSlices(args)
            arguments
                % from vipr model
                args.MAG;
                args.velocity_mean;
                args.velocity_encoding;
                
                % from bgpc model
                args.apply_correction;
                args.image;
                args.vmax;
                args.noise_threshold;
                args.cd_threshold;
                args.poly_fit_x;
                args.poly_fit_y;
                args.poly_fit_z;
            end

            rczres = size(args.MAG, 3);
            slice = 1 + floor(args.image * (rczres-1));
            
            % Get magnitude
            vx_slice = single(args.velocity_mean(:,:,slice));
            vy_slice = single(args.velocity_mean(:,:,slice));
            vz_slice = single(args.velocity_mean(:,:,slice));
            mag_slice = single(args.MAG(:,:,slice));

            xrange = single(linspace(-1, 1, size(args.velocity_mean, 1)));
            yrange = single(linspace(-1, 1, size(args.velocity_mean, 1))); % TODO: check if the indexes are correct as they differ from line 89
            zrange = single(linspace(-1, 1, size(args.velocity_mean, 1))); % TODO: check if the indexes are correct as they differ from line 90
            
            % Range
            if args.apply_correction
                [y, x, z] = meshgrid(yrange, xrange, zrange(slice));    
                vx_slice = vx_slice - BackgroundPhaseCorrection.evaluatePoly(x, y, z, args.poly_fit_x);
                vy_slice = vy_slice - BackgroundPhaseCorrection.evaluatePoly(x, y, z, args.poly_fit_y);
                vz_slice = vz_slice - BackgroundPhaseCorrection.evaluatePoly(x, y, z, args.poly_fit_z);
            end
            
            vmag = sqrt(vx_slice.^2 + vy_slice.^2 + + vz_slice.^2);
            
            % mag image
            max_MAG = max(args.MAG(:));
            idx = find((mag_slice > (0.3 * args.noise_threshold) * max_MAG) & (vmag < args.cd_threshold * args.velocity_encoding));
            mag_slice = 200 * mag_slice/max(mag_slice(:));
            mag_slice(idx) = 257;
            
            % velocity image
            vel_mag = sqrt(vx_slice.^2 + vy_slice.^2 + vz_slice.^2);
            vel_mag = 200*vel_mag / floor(500 * args.vmax);
            idx = vel_mag >= 199;
            vel_mag(idx) = 199;
        end
        
        function [velocity, velocity_mean] = polyCorrection(args)
            arguments
                args.MAG;
                args.velocity;
                args.velocity_mean;
                args.no_frames;
                args.poly_fit_x;
                args.poly_fit_y;
                args.poly_fit_z;
            end
            velocity = zeros(size(args.velocity));
            velocity_mean = zeros(size(args.velocity_mean));
            
            % Calculate a Polynomial 
            disp("Correcting polynomial...");
            xRange = single(linspace(-1, 1, size(args.MAG, 1)));
            yRange = single(linspace(-1, 1, size(args.MAG, 2)));
            zRange = single(linspace(-1, 1, size(args.MAG, 3)));
            [y, x, z] = meshgrid(yRange, xRange, zRange);

            poly_fit = [args.poly_fit_x, args.poly_fit_y, args.poly_fit_z];
            xyzNames = {'VX', 'VY', 'VZ'};
            for k = 1:numel(poly_fit)
                name = xyzNames{k};
                fprintf('    %s\n', name);
                back = self.evaluate_poly(x, y, z, poly_fit(k));
                back = single(back);
                
                velocity_mean(:,:,:,k) = args.velocity_mean(:,:,:,k) - back;
                for m = 1:args.NoFrames
                    velocity(:,:,:,k,m) = args.velocity(:,:,:,k,m) - back;
                end
            end
        end

        function mask = createAngiogram(args)
            arguments
                % TODO: add validations?
                args.MAG;
                args.velocity_mean;
                args.velocity_encoding;
                args.noise_threshold;
                args.cd_threshold;
            end
            
            mask = int8(zeros(size(args.MAG)));
            max_MAG = max(args.MAG(:));
            for slice = 1:size(mask, 3)
                % Grab a slice
                mag_slice = single(args.MAG(:,:,slice));
                vx_slice = single(args.velocity_mean(:,:,slice));
                vy_slice = single(args.velocity_mean(:,:,slice));
                vz_slice = single(args.velocity_mean(:,:,slice));
                
                CD = sqrt(vx_slice.^2 + vy_slice.^2 + vz_slice.^2);
                mask(:,:,slice) = (mag_slice > args.noise_threshold * max_MAG) .* (CD < args.cd_threshold * args.velocity_encoding);
            end
        end
        
        function [poly_fit_x, poly_fit_y, poly_fit_z] = ployFit3d(args)
            %{
            pass in name-value pairs for clarity
            %}
            arguments
                % TODO: add validations
                args.poly_fit_x;
                args.poly_fit_y;
                args.poly_fit_z;
                args.vx;
                args.vy;
                args.vz;
                args.fit_order;
                args.mask;
            end
            
            % Lots of memory problems with vectorization!!! solve Ax = B by (A^hA) x = (A^h *b)
            if args.fit_order == 0
                args.poly_fit_x.vals  = mean(args.velocity_mean(:));
                args.poly_fit_x.px = 0;
                args.poly_fit_x.py = 0;
                args.poly_fit_x.pz = 0;
            
                args.poly_fit_y.vals  = mean(args.velocity_mean(:));
                args.poly_fit_y.px = 0;
                args.poly_fit_y.py = 0;
                args.poly_fit_y.pz = 0;
            
                args.poly_fit_z.vals  = mean(args.velocity_mean(:));
                args.poly_fit_z.px = 0;
                args.poly_fit_z.py = 0;
                args.poly_fit_z.pz = 0;
            else
                [px, py, pz] = meshgrid(0:args.fit_order, 0:args.fit_order, 0:args.fit_order);
                idx2 = find((px+py+pz) <= args.fit_order);
                px = px(idx2);
                py = py(idx2);
                pz = pz(idx2);
                A = [px(:) py(:) pz(:)];
            
                N = size(A,1);
            
                AhA = zeros(N,N);
                AhBx = zeros(N,1);
                AhBy = zeros(N,1);
                AhBz = zeros(N,1);
            
                xrange = single(linspace(-1,1,size(args.velocity_mean,1)));
                yrange = single(linspace(-1,1,size(args.velocity_mean,2)));
                zrange = single(linspace(-1,1,size(args.velocity_mean,3)));
            
                % TODO: refactor for parfor?
                for slice = 1:numel(zrange)
                    vx_slice = single(args.velocity_mean(:,:,slice));
                    vy_slice = single(args.velocity_mean(:,:,slice));
                    vz_slice = single(args.velocity_mean(:,:,slice));
            
                    [y,x,z] = meshgrid(yrange, xrange, zrange(slice));
                    idx = find(args.mask(:, :, slice) > 0);
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
            
                % TODO: move to parallel processes?
                % save variables to struct
                poly_fit_x.vals = linsolve(AhA, AhBx);
                poly_fit_x.px = px;
                poly_fit_x.py = py;
                poly_fit_x.pz = pz;
            
                poly_fit_y.vals = linsolve(AhA, AhBy);
                poly_fit_y.px = px;
                poly_fit_y.py = py;
                poly_fit_y.pz = pz;
            
                poly_fit_z.vals = linsolve(AhA, AhBz);
                poly_fit_z.px = px;
                poly_fit_z.py = py;
                poly_fit_z.pz = pz;
            end
        end
        
        function poly_fit = resetFit(poly_fit)
            %{
            refactor! pass in a single poly_fit struct and set all fields to 0 and return
            from the caller, do for each poly_fit struct
            %}
            
            fields = fieldnames(poly_fit);
            
            for field = fields
                poly_fit.(field) = 0;
            end

        end
        
    end
    
    % misc static methods
    methods (Static, Access = private)
        
        function val = evaluatePoly(x, y, z, fit)
            val = 0;
            for k = 1:numel(fit.px)
                val = val + fit.vals(k)*(x.^fit.px(k).*y.^fit.py(k).*z.^fit.pz(k));
            end
        end

    end
    
end
