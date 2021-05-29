classdef Model < handle
    
    properties (GetAccess = public, SetAccess = private, SetObservable)
        BranchMat;
        BranchList;
        DataDir;
        FOV;
        MAG;
        NoFrames;
        Res;
        TimeMIP;
        TimeRes;
        Segment;
        Vel;
        VelMean;
        VelEncoding;
        Vessel;
    end
    
    methods (Access = public)
        
        % constructor
        function self = Model()
            
        end
        
        function setBranchList(self, val)
            arguments
                self;
                % TODO: add validations
                val;
            end
            self.BranchList = val;
        end
        
        function setBranchMat(self, val)
            arguments
                self;
                % TODO: add validations
                val;
            end
            self.BranchMat = val;
        end

        function setDataDir(self, val)
            arguments
                self;
                val {mustBeFolder};
            end
            self.DataDir = val;
        end
        
        function setFOV(self, val)
            arguments
                self;
                % TODO: add validations
                val;
            end
            self.FOV = val/10;
        end
        
        function setMAG(self, val)
            arguments
                self;
                % TODO: add validations
                val;
            end
            self.MAG = val;
        end
        
        function setNoFrames(self, val)
            arguments
                self;
                val (1,1) {mustBeInteger, mustBePositive};
            end
            self.NoFrames = val;
        end
        
        function setRes(self, val)
            arguments
                self;
                % TODO: add validations
                val;
            end
            self.Res = val;
        end
        
        function setTimeMIP(self, val)
            arguments
                self;
                % TODO: add validations
                val;
            end
            self.TimeMIP = val;
        end
        
        function setTimeRes(self, val)
            arguments
                self;
                % TODO: add validations
                val;
            end
            self.TimeRes = val;
        end
        
        function setSegment(self, val)
            arguments
                self;
                % TODO: add validations
                val;
            end
            self.Segment = val;
        end
        
        function setVel(self, val)
            arguments
                self;
                % TODO: add validations
                val;
            end
            self.Vel = val;
        end
           
        function setVelMean(self, val)
            arguments
                self;
                % TODO: add validations
                val;
            end
            self.VelMean = val;
        end
        
        function setVelEncoding(self, val)
            arguments
                self;
                val (1,1) {mustBeNumeric};
            end
            self.VelEncoding = val;
        end
        
        function setVessel(self, val)
            arguments
                self;
                val;
            end
            self.Vessel = val;
        end

    end
    
end