classdef OutputParametersModel < handle
    
    properties (GetAccess = public, SetAccess = private)
        Study;
        Subject;
        ConditionOrVisit;
        TimePoint;
        DataSourceName;
        DatabaseName;
        DatabaseTables;
        OutputAsCsv;
        OutputPath;
        DatabaseConnection;
    end
    
    % constructor
    methods (Access = public)
        
        function self = OutputParametersModel()
        end
        
    end
    
    % setters
    methods (Access = public)
        
        function setStudy(self, val)
            arguments
                self;
                val {mustBeTextScalar};
            end
            self.Study = val;
        end
        
        function setSubject(self, val)
            arguments
                self;
                val {mustBeTextScalar};
            end
            self.Subject = val;
        end
        
        function setConditionOrVisit(self, val)
            arguments
                self;
                val {mustBeTextScalar};
            end
            self.ConditionOrVisit = val;
        end
        
        function setTimePoint(self, val)
            arguments
                self;
                val {mustBeTextScalar};
            end
            self.TimePoint = val;
        end
        
        function setDataSourceName(self, val)
            arguments
                self;
                val {mustBeTextScalar};
            end
            self.DataSourceName = val;
        end
        
        function setDatabaseName(self, val)
            arguments
                self;
                val {mustBeTextScalar};
            end
            self.DatabaseName = val;
        end
        
        function setDatabaseTables(self, val)
            arguments
                self;
                val (1,:) {mustBeText};
            end
            self.DatabaseTables = val;
        end

        function setOutputAsCsv(self, val)
            arguments
                self;
                val (1,1) logical;
            end
            self.OutputAsCsv = val;
        end
        
        function setOutputPath(self, val)
            arguments
                self;
                val {mustBeFolder};
            end
            self.OutputPath = val;
        end
        
        function setDatabaseConnection(self, val)
            arguments
                self;
                val (1,1) {mustBeA(val, 'database')};
            end
            self.DatabaseConnection = val;
        end
        
    end
    
end