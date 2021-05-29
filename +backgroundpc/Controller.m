classdef Controller < CenterlineApp.base.ControllerBase
    
    properties (Access = private)
        BGModel;
        BGView;
    end
    
    % entry point
    methods (Access = public)
        
        function self = Controller(CLModel)
            self.BGModel = BackgroundPhaseCorrection.Model(CLModel);
            self.BGView = BackgroundPhaseCorrection.View(self.BGModel);
            self.loadApp();
            self.updateImg();
            self.setViewCallbacks();
            self.setModelListeners();
        end
        
    end
    
    % init listeners and callbacks
    methods (Access = private)
        
        function setViewCallbacks(self)
            % links the view buttons with callbacks
            self.BGView.UIFigure.CloseRequestFcn = @self.uiClose;
            self.BGView.UIFigure.WindowKeyPressFcn = @self.uiWindowKeyPressFcn;
            self.BGView.ImageSlider.ValueChangedFcn = @self.onImageValPostChange;
            self.BGView.ImageSlider.ValueChangingFcn = @self.onImageValPostChange;
            self.BGView.VmaxSlider.ValueChangedFcn = @self.onVmaxValPostChange;
            self.BGView.VmaxSlider.ValueChangingFcn = @self.onVmaxValPostChange;
            self.BGView.CDSlider.ValueChangedFcn = @self.onCDThresholdValPostChange;
            self.BGView.CDSlider.ValueChangingFcn = @self.onCDThresholdValPostChange;
            self.BGView.NoiseSlider.ValueChangedFcn = @self.onNoiseThresholdValPostChange;
            self.BGView.NoiseSlider.ValueChangingFcn = @self.onNoiseThresholdValPostChange;
            self.BGView.ImageSpinner.ValueChangedFcn = @self.onImageValPostChange;
            self.BGView.VmaxSpinner.ValueChangedFcn = @self.onVmaxValPostChange;
            self.BGView.CDSpinner.ValueChangedFcn = @self.onCDThresholdValPostChange;
            self.BGView.NoiseSpinner.ValueChangedFcn = @self.onNoiseThresholdValPostChange;
            self.BGView.FitOrderSpinner.ValueChangedFcn = @self.onFitOrderValPostChange;
            self.BGView.ApplyCorrectionCheckbox.ValueChangedFcn = @onApplyCorrectionValPostChange;
            self.BGView.UpdateButton.ButtonPushedFcn = @self.onUpdateBtnPushed;
            self.BGView.ResetFitButton.ButtonPushedFcn = @self.onResetFitBtnPushed;
            self.BGView.DoneButton.ButtonPushedFcn = @self.onDoneBtnPushed;
        end
        
        function setModelListeners(self)
            % will listen to changes of model properties then update the image in view
            addlistener(self.BGModel, 'CDThreshold', 'PostSet', @self.updateImg);
            addlistener(self.BGModel, 'FitOrder', 'PostSet', @self.updateImg);
            addlistener(self.BGModel, 'Image', 'PostSet', @self.updateImg);
            addlistener(self.BGModel, 'NoiseThreshold', 'PostSet', @self.updateImg);
            addlistener(self.BGModel, 'Vmax', 'PostSet', @self.updateImg);
            addlistener(self.BGModel, 'PolyFit', 'PostSet', @self.updateImg);
        end
        
    end
    
    % callbacks
    methods (Access = private)
        
        % Value post-change function: ImageSlider and ImageSpinner
        function onImageValPostChange(self, src, evt)
            val = round(evt.Value, 2);
            self.BGModel.setImage(val);
        end

        % Value changed function: VmaxSlider and VmaxSpinner
        function onVmaxValPostChange(self, src, evt)
            val = round(evt.Value, 2);
            self.BGModel.setVmax(val);
        end

        % Value changed function: CDSlider and CDSpinner
        function onCDThresholdValPostChange(self, src, evt)
            val = round(evt.Value, 2);
            self.BGModel.setCDThreshold(val);
        end

        % Value changed function: NoiseSlider and NoiseSpinner
        function onNoiseThresholdValPostChange(self, src, evt)
            val = round(evt.Value, 2);
            self.BGModel.setNoiseThreshold(val);
        end

        % Value changed function: FitOrderSlider and FitOrderSpinner
        function onFitOrderValPostChange(self, src, evt)
            val = floor(evt.Value);
            self.BGModel.setFitOrder(val);
        end
        
        % Value Changed function: ApplyCorrectionCheckBox
        function onApplyCorrectionValPostChange(self, src, evt)
            val = evt.Value;
            self.BGModel.setApplyCorrection(val);
        end
        
        % Button pushed function: ResetFitButton
        function onResetFitBtnPushed(self, src, evt)
            self.BGModel.setPolyFit("reset", true);
        end

        % Button pushed function: UpdateButton
        function onUpdateBtnPushed(self, src, evt)
            mask = self.createAngiogram();
            self.polyFit3d(mask);
        end

        % Button pushed function: DoneButton
        function onDoneBtnPushed(self, src, evt)
            % init waitbar dialog
            self.BGView.createDlg();
            
            self.BGView.setDlgMsg('Correcting for polynomial');
            velocityMean = self.polyCorrection();
            
            self.BGView.setDlgMsg('Calculating angiogram');
            timeMIP = self.calculateAngiogram();
            
            self.BGView.setDlgMsg('Calculating segment');
            segment = self.calculateSegment(timeMIP);

            self.BGModel.CLModel.setVelMean(velocityMean);
            self.BGModel.CLModel.setTimeMIP(timeMIP);
            self.BGModel.CLModel.setSegment(segment);
            
            self.BGView.setDlgMsg('Saving parameters');
            self.BGView.setDlgVal(0);
            self.saveApp();
            self.BGView.setDlgVal(1);
            self.uiClose();
        end

    end
    
    % bg phase correction methods
    methods (Access = private)
        
        function timeMIP = calculateAngiogram(self)
            self.BGView.setDlgMsg("Calculating max intensity projection");
            self.BGView.setDlgVal(0);
            
            % timeMIP = zeros(size(MAG), 'single');
            Vmag = sqrt(sum(self.BGModel.CLModel.VelocityMean.^2, 4));
            idx = find(Vmag > self.BGModel.CLModel.VelocityEncoding);
            Vmag(idx) = self.BGModel.CLModel.VelocityEncoding;
            timeMIP = single(32000 * self.BGModel.CLModel.MAG .* ...
                sin(pi/2*Vmag/self.BGModel.CLModel.VelocityEncoding));
            
            self.BGView.setDlgVal(1);
        end
        
        function segment = calculateSegment(self, timeMIP)
            self.BGView.setDlgMsg("Calculating segment");
            self.BGView.setDlgVal(0);
            
            timeMIP2 = zeros(size(timeMIP));
            timeMIP2(self.BGModel.MXStart:self.BGModel.MXStop, ...
                self.BGModel.MYStart:self.BGModel.MYStop, ...
                self.BGModel.MZStart:self.BGModel.MZStop) = 1;
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
            
            self.BGView.setDlgVal(1);
        end
        
        function mask = createAngiogram(self)
            mask = int8(zeros(size(self.BGModel.CLModel.MAG)));
            maxMAG = max(self.BGModel.CLModel.MAG(:));
            for slice = 1:size(mask, 3)
                % Grab a slice
                magSlice = single(self.BGModel.CLModel.MAG(:, :, slice));
                vxSlice = single(self.BGModel.VX(:, :, slice));
                vySlice = single(self.BGModel.VY(:, :, slice));
                vzSlice = single(self.BGModel.VZ(:, :, slice));
                
                CD = sqrt(vxSlice.^2 + vySlice.^2 + vzSlice.^2);
                mask(:, :, slice) = (magSlice > self.BGModel.NoiseThreshold * maxMAG) .* ...
                    (CD < self.BGModel.CDThreshold * self.BGModel.CLModel.VelEncoding);
            end
        end
       
        function [magSlice, velMAG] = getSlices(self)
            vMax = floor(500 * self.BGModel.Vmax);
            noiseThreshold_ = 0.3 * self.BGModel.NoiseThreshold;
            rczres = size(self.BGModel.CLModel.MAG, 3);
            slice = 1 + floor(self.BGModel.Image*(rczres-1));
            
            % Get magnitude
            vxSlice = single(self.BGModel.VX(:,:,slice));
            vySlice = single(self.BGModel.VY(:,:,slice));
            vzSlice = single(self.BGModel.VZ(:,:,slice));
            magSlice = single(self.BGModel.CLModel.MAG(:,:,slice));

            xRange = single(linspace(-1, 1, size(self.BGModel.VX, 1)));
            yRange = single(linspace(-1, 1, size(self.BGModel.VY, 1)));
            zRange = single(linspace(-1, 1, size(self.BGModel.VZ, 1)));
            
            % Range
            if self.BGModel.ApplyCorrection == 1
                [y, x, z] = meshgrid(yRange, xRange, zRange(slice));    
                vxSlice = vxSlice - self.evaluatePoly(x, y, z, self.BGModel.PolyFit.x);
                vySlice = vySlice - self.evaluatePoly(x, y, z, self.BGModel.PolyFit.y);
                vzSlice = vzSlice - self.evaluatePoly(x, y, z, self.BGModel.PolyFit.z);
            end
            
            vMAG = sqrt(vxSlice.^2 + vySlice.^2 + + vzSlice.^2);
            
            maxMAG = max(self.BGModel.CLModel.MAG(:));
            idx = find((magSlice > noiseThreshold_ * maxMAG) & ...
                (vMAG < self.BGModel.CDThreshold * self.BGModel.CLModel.VelEncoding));
            magSlice = 200 * magSlice/max(magSlice(:));
            magSlice(idx) = 257;
            
            velMAG = sqrt(vxSlice.^2 + vySlice.^2 + vzSlice.^2);
            velMAG = 200 * velMAG / vMax;
            idx = velMAG >= 199;
            velMAG(idx) = 199;
        end
        
        function velocityArray = polyCorrection(self)
            self.BGView.setDlgVal(0);
            
            % Calculate a Polynomial
            xRange = single(linspace(-1, 1, size(self.BGModel.CLModel.MAG, 1)));
            yRange = single(linspace(-1, 1, size(self.BGModel.CLModel.MAG, 2)));
            zRange = single(linspace(-1, 1, size(self.BGModel.CLModel.MAG, 3)));
            [y, x, z] = meshgrid(yRange, xRange, zRange);

            xyzNames = {'VX', 'VY', 'VZ'};
            coordinates = {'x', 'y', 'z'};
            velocityArray = self.BGModel.CLModel.VelMean;
            for k = 1:3
                name = xyzNames{k};
                msg = strcat("Correcting polynomial: ", name);
                self.BGView.setDlgMsg(msg);
                
                back = self.evaluatePoly(x, y, z, self.BGModel.PolyFit.(coordinates{k}));
                velocityArray(:, :, :, k) = ...
                    self.BGModel.CLModel.VelocityMean(:, :, :, k) - back;
                back = int16(back);
                for m = 0:self.BGModel.CLModel.NoFrames - 1
                    velocityArray(:, :, :, k, m+1) = ...
                        self.BGModel.CLModel.Velocity(:, :, :, k, m+1) - back;
                end
                
                val = k/3;
                self.BGView.setDlgVal(val);
            end
        end
        
        function polyFit3d(self, mask)
            % Lots of memory problems with vectorization!!! 
            % solve Ax = B by (A^hA) x = (A^h *b)
            if self.BGModel.FitOrder == 0
                self.BGModel.PolyFitX.vals = mean(self.BGModel.VX(:));
                self.BGModel.PolyFitX.px = 0;
                self.BGModel.PolyFitX.py = 0;
                self.BGModel.PolyFitX.pz = 0;
                
                self.BGModel.PolyFitY.vals = mean(self.BGModel.VY(:));
                self.BGModel.PolyFitY.px = 0;
                self.BGModel.PolyFitY.py = 0;
                self.BGModel.PolyFitY.pz = 0;
                
                self.BGModel.PolyFitZ.vals = mean(self.BGModel.VZ(:));
                self.BGModel.PolyFitZ.px = 0;
                self.BGModel.PolyFitZ.py = 0;
                self.BGModel.PolyFitZ.pz = 0;
            else
                [px, py, pz] = meshgrid(0:self.BGModel.FitOrder, ...
                    0:self.BGModel.FitOrder, 0:self.BGModel.FitOrder);
                idx2 = find((px+py+pz) <= self.BGModel.FitOrder);
                px = px(idx2);
                py = py(idx2);
                pz = pz(idx2);
                A = [px(:) py(:) pz(:)];
            
                sz = size(A,1);
            
                AhA = zeros(sz, sz);
                AhBx = zeros(sz, 1);
                AhBy = zeros(sz, 1);
                AhBz = zeros(sz, 1);
            
                xRange = single(linspace(-1, 1, size(self.BGModel.VX, 1)));
                yRange = single(linspace(-1, 1, size(self.BGModel.VY, 2)));
                zRange = single(linspace(-1, 1, size(self.BGModel.VZ, 3)));
            
                for slice = 1:numel(zRange)
                    vxSlice = single(self.BGModel.VX(:, :, slice));
                    vySlice = single(self.BGModel.VY(:, :, slice));
                    vzSlice = single(self.BGModel.VZ(:, :, slice));
            
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
                            AhA(m,n) = AhA(m,n) + ...
                                sum((x.^px(m).*y.^py(m).*z.^pz(m)).* ...
                                ((x.^px(n).*y.^py(n).*z.^pz(n))));
                        end
                    end
            
                    for k = 1:sz
                        AhBx(k) = AhBx(k) + ...
                            sum(vxSlice.*(x.^px(k).*y.^py(k).*z.^pz(k)));
                        AhBy(k) = AhBy(k) + ...
                            sum(vySlice.*(x.^px(k).*y.^py(k).*z.^pz(k)));
                        AhBz(k) = AhBz(k) + ...
                            sum(vzSlice.*(x.^px(k).*y.^py(k).*z.^pz(k)));
                    end
                end
            
                % save variables to struct
                self.BGModel.PolyFitX.vals = linsolve(AhA, AhBx);
                self.BGModel.PolyFitX.px = px;
                self.BGModel.PolyFitX.py = py;
                self.BGModel.PolyFitX.pz = pz;
            
                self.BGModel.PolyFitY.vals = linsolve(AhA, AhBy);
                self.BGModel.PolyFitY.px = px;
                self.BGModel.PolyFitY.py = py;
                self.BGModel.PolyFitY.pz = pz;
            
                self.BGModel.PolyFitZ.vals = linsolve(AhA, AhBz);
                self.BGModel.PolyFitZ.px = px;
                self.BGModel.PolyFitZ.py = py;
                self.BGModel.PolyFitZ.pz = pz;
            end
        end

        function resetFit(self)
            coordinates = {'x', 'y', 'z'};
            fields = {'vals', 'px', 'py', 'pz'};
            for m = 1:numel(coordinates)
                for n = 1:numel(fields)
                    self.BGModel.PolyFit(1).(coordinates{m}).(fields{n}) = 0;
                end
            end
        end
        
        function updateImg(self)
            [magSlice, velocitySlice] = self.getSlices();
            self.BGView.setMagImg(magSlice);
            self.BGView.setVelImg(velocitySlice);
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
    
    % custom IO methods for Apps
    methods (Access = protected)
       %{
            app designer objects cannot utilize 'saveobj' and 'loadoabj'
            properly
            this is a workaround to that to save only necessary data that,
            when combined with the required input arg to the app, will
            restore the previous state
        %}
        
        function saveApp(self)
            directory = fullfile(self.BGModel.CLModel.DataDir, 'saved_analysis');
            if ~exist(directory, 'dir')
                mkdir(directory);
            end
            fname = 'phase_correction.mat';
            s.Image = self.BGModel.Image;
            s.Vmax = self.BGModel.Vmax;
            s.CDThreshold = self.BGModel.CDThreshold;
            s.NoiseThreshold = self.BGModel.NoiseThreshold;
            s.FitOrder = self.BGModel.FitOrder;
            s.ApplyCorrection = self.BGModel.ApplyCorrection;
            s.PolyFit = self.BGModel.PolyFit;
            save(fullfile(directory, fname), 's', '-v7.3', '-nocompression');
        end
        
        function loadApp(self)
            directory = fullfile(self.BGModel.CLModel.DataDir, 'saved_analysis');
            fname = 'phase_correction.mat';
            if exist(fullfile(directory, fname), 'file')
                load(fullfile(directory, fname), 's');
                self.BGModel.Image = s.Image;
                self.BGModel.Vmax = s.Vmax;
                self.BGModel.CDThreshold = s.CDThreshold;
                self.BGModel.NoiseThreshold = s.NoiseThreshold;
                self.BGModel.FitOrder = s.FitOrder;
                self.BGModel.ApplyCorrection = s.ApplyCorrection;
                self.BGModel.PolyFit = s.PolyFit;
                
                self.ImageSlider.Value = self.BGModel.Image * 100;
                self.ImageSpinner.Value = self.BGModel.Image;
                self.VmaxSlider.Value = self.BGModel.Vmax * 100;
                self.VmaxSpinner.Value = self.BGModel.Vmax;
                self.CDSlider.Value = self.BGModel.CDThreshold * 100;
                self.CDSpinner.Value = self.BGModel.CDThreshold;
                self.NoiseSlider.Value = self.BGModel.NoiseThreshold * 100;
                self.NoiseSpinner.Value = self.BGModel.NoiseThreshold;
            end
        end
        
    end
    
end