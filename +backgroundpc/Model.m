classdef Model < handle
    
    properties (GetAccess = public, SetAccess = private, SetObservable)
        ApplyCorrection;
        CDThreshold;
        FitOrder;
        Image;
        NoiseThreshold;
        Vmax;
        PolyFit;
        CLModel;
    end
    
    properties (Dependent)
        VX;
        VY;
        VZ;
        MXStop;  
        MYStop;
        MZStop;
    end
    
    properties (Access = private, Transient, Constant)
        MXStart = 1;
        MYStart = 1;
        MZStart = 1;
    end
    
    methods (Access = public)
        
        function self = Model(CLModel)
            self.setCLModel(CLModel);
            self.setPolyFit("reset", true);
        end
        
        function setApplyCorrection(self, val)
            arguments
                self;
                val (1,1) {mustBeA(val, "logical")};
            end
            self.ApplyCorrection = val;
        end
        
        function setCDThreshold(self, val)
            arguments
                self;
                val (1,1) double {mustBeInRange(val, 0, 1)} = 0.15;
            end
            self.CDThreshold = val;
        end
        
        function setFitOrder(self, val)
            arguments
                self;
                val (1,1) uint8 = 2;
            end
            self.FitOrder = val;
        end
        
        function setImage(self, val)
            arguments
                self;
                val (1,1) double {mustBeInRange(val, 0, 1)} = 0.5;
            end
            self.Image = val;
        end
        
        function setNoiseThreshold(self, val)
            arguments
                self;
                val (1,1) double {mustBeInRange(val, 0, 1)} = 0.15;
            end
            self.NoiseThreshold = val;
        end
        
        function setVmax(self, val)
            arguments
                self;
                val (1,1) double {mustBeInRange(val, 0, 1)} = 0.1;
            end
            self.Vmax = val;
        end
        
        function setPolyFit(self, val, reset)
            arguments
                self;
                val = [];
                reset {mustBeA(reset, "logical")} = false;
            end
            if reset == true
                coordinates = {'x', 'y', 'z'};
                fields = {'vals', 'px', 'py', 'pz'};
                for m = 1:numel(coordinates)
                    for n = 1:numel(fields)
                        self.PolyFit(1).(coordinates{m}).(fields{n}) = 0;
                    end
                end
            else
                self.PolyFit = val;
            end
        end
        
        function setCLModel(self, val)
            % necessary? Probably not. But! It follows the theme and consistency
            % is key
            arguments
                self;
                val;
            end
            self.CLModel = val;
        end
        
    end
    
    % getters
    methods
        
        function val = get.VX(self)
            val = self.CLModel.VelocityMean(:,:,:,1);
        end
        
        function val = get.VY(self)
            val = self.CLModel.VelocityMean(:,:,:,2);
        end
        
        function val = get.VZ(self)
            val = self.CLModel.VelocityMean(:,:,:,3);
        end
        
        function val = get.MXStop(self)
            val = self.CLModel.Resolution;
        end
        
        function val = get.MYStop(self)
            val = self.CLModel.Resolution;
        end
        
        function val = get.MZStop(self)
            val = self.CLModel.Resolution;
        end
        
    end
    
end