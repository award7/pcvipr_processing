classdef BaseModel < handle
    
    
    
    % output parameters properties
    properties (Access = public)
        Study               {mustBeTextScalar} = '';
        Subject             {mustBeTextScalar} = '';
        ConditionOrVisit    {mustBeTextScalar} = '';
        TimePoint           {mustBeTextScalar} = '';
        DataSourceName      {mustBeTextScalar} = '';
        DatabaseName        {mustBeTextScalar} = '';
        DatabaseTables      (1,:) {mustBeText} = '';
        OutputAsCsv         (1,1) logical = true;
        OutputPath          {mustBeFolder} = fullfile(pwd);
    end
    
    % database properties
    properties (Access = public)
        DatabaseConnection;
    end
    
    % only load these when needed
    properties (Dependent)
        Velocity;
        VelocityMean;
        MAG;
        MAGr;
        MAGg;
        MAGb;
        WhiteImage;
    end
    
    % BackgroundPhaseCorrection-specific properties
    properties (Access = public)
        Image = 0.5;
        Vmax = 0.1;
        CDThreshold = 0.15;
        NoiseThreshold = 0.15;
        FitOrder = 2;
        ApplyCorrection = 1;
        MagImage;
        VelocityImage;
    end
    
    methods (Access = ?Controller)
        
        function self = BaseModel() 
        end
               
    end
    
    % getters
    methods
        
        function val = get.WhiteImage(self)
            val = 255 * ones(480, 640, 3, 'uint8');
        end
        
        function val = get.MagImage(self)
            val = self.MagImage;
        end
        
        function val = get.VelocityImage(self)
            val = self.VelocityImage;
        end
        
        function val = get.Velocity(self)
            val = zeros(320, 320, 320);
        end
        
        
        
    end
    
    % setters
    methods
        
        function set.MagImage(self, val)
            % todo: add validation
            self.MagImage = val;
        end
        
        function set.VelocityImage(self, val)
            % todo: add validation
            self.VelocityImage = val;
        end
        
        function set.Image(self, val)
            try
                mustBeInRange(val, 0, 1);
                self.Image = val;
            catch ME
                switch ME.identifier
                    case 'MATLAB:validators:mustBeInRange'
                        % todo: display error msg
                end
            end
        end
        
        function set.Vmax(self, val)
            try
                mustBeInRange(val, 0, 1);
                self.Vmax = val;
            catch ME
                switch ME.identifier
                    case 'MATLAB:validators:mustBeInRange'
                        % todo: display error msg
                end
            end
        end
        
        function set.CDThreshold(self, val)
            try
                mustBeInRange(val, 0, 1);
                self.CDThreshold = val;
            catch ME
                switch ME.identifier
                    case 'MATLAB:validators:mustBeInRange'
                        % todo: display error msg
                end
            end
        end
        
        function set.NoiseThreshold(self, val)
            try
                mustBeInRange(val, 0, 1);
                self.NoiseThreshold = val;
            catch ME
                switch ME.identifier
                    case 'MATLAB:validators:mustBeInRange'
                        % todo: display error msg
                end
            end
        end
        
        function set.FitOrder(self, val)
            try
                mustBeInRange(val, 0, 1);
                self.FitOrder = val;
            catch ME
                switch ME.identifier
                    case 'MATLAB:validators:mustBeInRange'
                        % todo: display error msg
                end
            end
        end
        
        function set.ApplyCorrection(self, val)
            try
                mustBeInRange(val, 0, 1);
                self.ApplyCorrection = val;
            catch ME
                switch ME.identifier
                    case 'MATLAB:validators:mustBeInRange'
                        % todo: display error msg
                end
            end
        end
        
        
    end
    
end