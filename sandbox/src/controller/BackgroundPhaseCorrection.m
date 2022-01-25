classdef BackgroundPhaseCorrection < handle
    % methods for applying background phase correction to PC VIPR data

    % methods called by >1 callback
    methods (Access = ?BaseController, Static)
        
        function [mag_slice, vel_mag] = getSlices(args)
            % called from most callbacks sans "Done"
            arguments
                % from vipr model
                args.mag;
                args.velocity_mean;
                args.velocity_encoding;
                
                % from bgpc model
                args.apply_correction;
                args.image;
                args.vmax;
                args.noise_threshold;
                args.cd_threshold;
                args.poly_fit
            end

            %%% begin correction
            rczres = size(args.mag, 3);
            slice = 1 + floor(args.image * (rczres-1));
            
            % Get magnitude
            vx_slice = single(args.velocity_mean(:,:,slice));
            vy_slice = single(args.velocity_mean(:,:,slice));
            vz_slice = single(args.velocity_mean(:,:,slice));
            mag_slice = single(args.mag(:,:,slice));

            xrange = single(linspace(-1, 1, size(args.velocity_mean, 1)));
            yrange = single(linspace(-1, 1, size(args.velocity_mean, 1))); % TODO: check if the indexes are correct as they differ from line 89
            zrange = single(linspace(-1, 1, size(args.velocity_mean, 1))); % TODO: check if the indexes are correct as they differ from line 90
            
            % Range
            if args.apply_correction
                [y, x, z] = meshgrid(yrange, xrange, zrange(slice));    
                vx_slice = vx_slice - BackgroundPhaseCorrection.evaluatePoly(x, y, z, args.poly_fit.x);
                vy_slice = vy_slice - BackgroundPhaseCorrection.evaluatePoly(x, y, z, args.poly_fit.y);
                vz_slice = vz_slice - BackgroundPhaseCorrection.evaluatePoly(x, y, z, args.poly_fit.z);
            end
            
            vmag = sqrt(vx_slice.^2 + vy_slice.^2 + + vz_slice.^2);
            
            % mag image
            max_MAG = max(args.mag(:));
            idx = find((mag_slice > (0.3 * args.noise_threshold) * max_MAG) & (vmag < args.cd_threshold * args.velocity_encoding));
            mag_slice = 200 * mag_slice/max(mag_slice(:));
            mag_slice(idx) = 257;
            
            % velocity image
            vel_mag = sqrt(vx_slice.^2 + vy_slice.^2 + vz_slice.^2);
            vel_mag = 200*vel_mag / floor(500 * args.vmax);
            idx = vel_mag >= 199;
            vel_mag(idx) = 199;
        end
        
        function poly_fit = resetFit()
            % called from "Reset Fit" and during initialization
            poly_fit = struct;
            parent_fields = ["x", "y", "z"];
            child_fields = ["px", "py", "pz", "vals"];
            
            for parent = parent_fields
                for child = child_fields
                    poly_fit.(parent).(child) = 0;
                end
            end
        end
        
    end
    
    % methods called only during intialization of the view
    methods (Access = ?BaseController, Static)
        
        function img = initImage(parent, img)
            arguments
                % TODO: add validations
                parent;
                img;
            end
            img = imagesc(parent, 'CData', img, [0 210]);
        end
        
    end
    
    % methods called only from "Done"
    methods (Access = ?BaseController, Static)
        
        function correction_factor = polyCorrection(args)
            arguments
                % from vipr model
                args.mag;
                args.no_frames;
                
                % from bgpc model
                args.poly_fit;
            end
            
            % Calculate a Polynomial
            xRange = single(linspace(-1, 1, size(args.mag, 1)));
            yRange = single(linspace(-1, 1, size(args.mag, 2)));
            zRange = single(linspace(-1, 1, size(args.mag, 3)));
            [y, x, z] = meshgrid(yRange, xRange, zRange);

            poly_fit = [args.poly_fit.x, args.poly_fit.y, args.poly_fit.z];
            dim = size(x,1);
            correction_factor = zeros(dim,dim,dim,3);
            
            for k = 1:numel(poly_fit)
                correction_factor(:,:,:,k) = BackgroundPhaseCorrection.evaluatePoly(x, y, z, poly_fit(k));
                
%                 velocity_mean(:,:,:,k) = args.velocity_mean(:,:,:,k) - back;
%                 for m = 1:args.NoFrames
%                     velocity(:,:,:,k,m) = args.velocity(:,:,:,k,m) - back;
%                 end
            end
            correction_factor = single(correction_factor);
        end

        function time_mip = calculateAngiogram(args)
            arguments
                args.mag
                args.velocity_mean
                args.velocity_encoding
            end
            vmag = sqrt(sum(args.velocity_mean.^2, 4));
            vmag(vmag > args.velocity_encoding) = args.velocity_encoding;
            time_mip = 32000 * args.mag .* sin(pi/2*vmag/args.velocity_encoding);
        end
        
        function segment = calculateSegment(args)
            arguments
                args.time_mip;
                args.resolution;
                args.MXStart = 1;
                args.MYStart= 1;
                args.MZStart = 1;
            end
            
            % for readability
            MXStop = args.resolution;
            MYStop = args.resolution;
            MZStop = args.resolution;

            % calculate time mip
            timeMIP2 = ones(size(args.time_mip));
            
            % I think this just creates an array of ones and can be
            % initialized easier in the previous step...
            timeMIP2(args.MXStart:MXStop, args.MYStart:MYStop, args.MZStart:MZStop) = 1;
            timeMIP_crop = args.time_mip .* timeMIP2;
            
            normed_MIP = timeMIP_crop(:) ./ max(timeMIP_crop(:));
            [muhat, sigmahat] = normfit(normed_MIP);
            segment = zeros(size(timeMIP_crop));
            segment(normed_MIP > muhat + 4.5 * sigmahat) = 1;
            
            % The value at the end of the commnad in the minimum area of each segment to keep 
            segment = bwareaopen(segment, round(sum(segment(:)) .* 0.005), 6); 
            
            % Fill in holes created by slow flow on the inside of vessels
            segment = imfill(segment, 'holes'); 
            segment = single(segment);
        end
        
    end
    
    % methods called only from "Update"
    methods (Access = ?BaseController, Static)
        
        function mask = createAngiogram(args)
            arguments
                % TODO: add validations?
                args.mag;
                args.velocity_mean;
                args.velocity_encoding;
                args.noise_threshold;
                args.cd_threshold;
            end
            
            mask = int8(zeros(size(args.mag)));
            max_MAG = max(args.mag(:));
            for slice = 1:size(mask, 3)
                % Grab a slice
                mag_slice = single(args.mag(:,:,slice));
                vx_slice = single(args.velocity_mean(:,:,slice));
                vy_slice = single(args.velocity_mean(:,:,slice));
                vz_slice = single(args.velocity_mean(:,:,slice));
                
                CD = sqrt(vx_slice.^2 + vy_slice.^2 + vz_slice.^2);
                mask(:,:,slice) = (mag_slice > args.noise_threshold * max_MAG) .* (CD < args.cd_threshold * args.velocity_encoding);
            end
        end
        
        function poly_fit = polyFit3d(args)
            % pass in name-value pairs for clarity
            arguments
                % TODO: add validations?
                args.velocity_mean;
                args.fit_order;
                args.mask;
            end
            
            % Lots of memory problems with vectorization!!! solve Ax = B by (A^hA) x = (A^h *b)
            if args.fit_order == 0
                % vx
                poly_fit.x.vals  = mean(args.velocity_mean(:,:,:,1));
                poly_fit.x.px = 0;
                poly_fit.x.py = 0;
                poly_fit.x.pz = 0;
            
                % vy
                poly_fit.y.vals  = mean(args.velocity_mean(:,:,:,2));
                poly_fit.y.px = 0;
                poly_fit.y.py = 0;
                poly_fit.y.pz = 0;
            
                % vz
                poly_fit.z.vals  = mean(args.velocity_mean(:,:,:,3));
                poly_fit.z.px = 0;
                poly_fit.z.py = 0;
                poly_fit.z.pz = 0;
            else
                [px, py, pz] = meshgrid(0:args.fit_order, 0:args.fit_order, 0:args.fit_order);
                idx2 = find((px+py+pz) <= args.fit_order);
                px = px(idx2);
                py = py(idx2);
                pz = pz(idx2);
                N = size([px(:) py(:) pz(:)], 1);
                
                % preallocate arrays
                AhA = zeros(N,N);
                AhBx = zeros(N,1);
                AhBy = zeros(N,1);
                AhBz = zeros(N,1);
                
                xrange = single(linspace(-1,1,size(args.velocity_mean,1)));
                yrange = single(linspace(-1,1,size(args.velocity_mean,2)));
                zrange = single(linspace(-1,1,size(args.velocity_mean,3)));
                
                % TODO: refactor for parfor?
                %   e.g. if fit_order => 3, as the higher orders will
                %   require more compute and the increase is non-linear
                % Some of this code doesn't make sense.
                for slice = 1:numel(zrange)
                    vx_slice = single(args.velocity_mean(:,:,slice,1));
                    vy_slice = single(args.velocity_mean(:,:,slice,2));
                    vz_slice = single(args.velocity_mean(:,:,slice,3));
                    
                    [y,x,z] = meshgrid(yrange, xrange, zrange(slice));
                    idx = find(args.mask(:,:,slice) > 0);
                    x = x(idx);
                    y = y(idx);
                    z = z(idx);
                    vx_slice = vx_slice(idx);
                    vy_slice = vy_slice(idx);
                    vz_slice = vz_slice(idx);
                    
                    % this is the bottleneck
                    % AhA is overwritten for each iteration of slice (i.e.
                    % the outer loop)
                    for i = 1:N
                        for j = 1:N
                            AhA(i,j) =  AhA(i,j) + sum((x.^px(i).*y.^py(i).*z.^pz(i)).*((x.^px(j).*y.^py(j).*z.^pz(j))));
                        end
                    end
                    
                    % these arrays are overwritten for each iteration of slice (i.e.
                    % the outer loop)
                    for i = 1:N
                        AhBx(i) = AhBx(i) + sum(vx_slice.* (x.^px(i).*y.^py(i).*z.^pz(i)));
                        AhBy(i) = AhBy(i) + sum(vy_slice.* (x.^px(i).*y.^py(i).*z.^pz(i)));
                        AhBz(i) = AhBz(i) + sum(vz_slice.* (x.^px(i).*y.^py(i).*z.^pz(i)));
                    end
                end
                
                % save variables to struct
                poly_fit.x.vals = linsolve(AhA, AhBx);
                poly_fit.x.px = px;
                poly_fit.x.py = py;
                poly_fit.x.pz = pz;
                
                poly_fit.y.vals = linsolve(AhA, AhBy);
                poly_fit.y.px = px;
                poly_fit.y.py = py;
                poly_fit.y.pz = pz;
            
                poly_fit.z.vals = linsolve(AhA, AhBz);
                poly_fit.z.px = px;
                poly_fit.z.py = py;
                poly_fit.z.pz = pz;
            end
        end
        
    end
    
    % internal methods
    methods (Static, Access = private)
        
        function val = evaluatePoly(x, y, z, fit)
            val = 0;
            for k = 1:numel(fit.px)
                val = val + fit.vals(k)*(x.^fit.px(k).*y.^fit.py(k).*z.^fit.pz(k));
            end
        end

    end
    
end
