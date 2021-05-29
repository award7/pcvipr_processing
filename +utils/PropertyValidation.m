classdef PropertyValidation < handle
    
    methods(Access = public)
        
        function self = PropertyValidation()
        end
        
        function mustBeTextScalar(self, value)
            self.mustBeText(value);
            value = strjoin(string(value));
            if ~isscalar(value)
                error('Invalid input. ''%s'' must be a scalar', value);
            end
        end
        
        function mustBeNonZeroLengthText(self, value)
            self.mustBeText(value);
            if ~strlength(value) > 0
                error('Invalid input. Input must be non-zero length');
            end
        end
        
        function mustBeInRange(self, value, lower, upper, varargin)
            arguments
                self;
                value (1,1) double {mustBeNumeric};
                lower (1,1) double {mustBeNumeric};
                upper (1,1) double {mustBeNumeric};
            end
            
            arguments (Repeating)
                varargin;
            end
            
            if nargin == 4
                self.mustBeInRangeBounds(value, lower, upper, 'inclusive');
            else
                boundFlag1 = varargin{1};
                memberArray = {'inclusive', 'exclusive', 'exclude-lower', 'exclude-upper'};
                self.mustBeMember(boundFlag1, memberArray);
                self.mustBeInRangeBounds(value, lower, upper, boundFlag1);
                if nargin > 5
                    boundFlag2 = varargin{2};
                    self.mustBeMember(boundFlag2, memberArray);
                    self.mustBeInRangeBounds(value, lower, upper, boundFlag2);
                end
            end
            
        end
        
    end
    
    methods(Access = public, Static)
        
       function mustBePath(value)
            if ~isfolder(value)
                error('No such folder: %s\n', string(value));
            end
        end
        
        function mustBeFile(value)
            if ~isfile(value)
                error('No such file: %s\n', string(value));
            end
        end

        function mustBeText(value)
            if isstring(value) || ischar(value)
            else
                error('Invalid input. ''%s'' must be text.\n', num2str(value));
            end
        end
        
        function mustBeMember(value, arr)
            if ~ismember(lower(value), lower(arr))
                arr = string(strjoin(arr));
                error('''%s'' must be one of these options: {%s}', string(value), arr);
            end
        end
        
        function mustBeNonempty(value)
            if isempty(value)
                error('Invalid input. Must contain a value')
            end
        end
        
        function mustBeScalarOrEmpty(value)
            if ~isempty(value) && ~isscalar(value)
                error('Invalid input. Must be a scalar or empty.');
            end
        end
        
        function mustBeVector(value)
            if ~isvector(value)
                error('Invalid input. Must be a vector');
            end
        end
        
    end
    
    methods(Access = private, Static)
       
        function mustBeInRangeBounds(value, lower, upper, boundFlag)
            switch boundFlag
                case 'inclusive'
                    if ~ge(value, lower)
                        error('%f must be greater than or equal to %f', value, lower);
                    elseif ~le(value, upper)
                        error('%f must be less than or equal to %f', value, lower);
                    end 
                case 'exclusive'
                    if ~gt(value, lower)
                        error('%f must be greater than %f', value, lower);
                    elseif ~lt(value, upper)
                        error('%f must be less than %f', value, upper);
                    end
                case 'exclude-lower'
                    if ~gt(value, lower)
                        error('%f must be greater than %f', value, lower);
                    end
                case 'exclude-upper'
                    if ~lt(value, upper)
                        error('%f must be less than %f', value, upper);
                    end
            end
        end
        
    end
        
end
