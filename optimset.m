function options = optimset(varargin)
%OPTIMSET Create/alter optimization OPTIONS structure.
%   OPTIONS = OPTIMSET('PARAM1',VALUE1,'PARAM2',VALUE2,...) creates an
%   optimization options structure OPTIONS in which the named parameters have
%   the specified values.  Any unspecified parameters are set to [] (parameters
%   with value [] indicate to use the default value for that parameter when
%   OPTIONS is passed to the optimization function). It is sufficient to type
%   only the leading characters that uniquely identify the parameter.  Case is
%   ignored for parameter names.
%   NOTE: For values that are strings, the complete string is required.
%
%   OPTIONS = OPTIMSET(OLDOPTS,'PARAM1',VALUE1,...) creates a copy of OLDOPTS
%   with the named parameters altered with the specified values.
%
%   OPTIONS = OPTIMSET(OLDOPTS,NEWOPTS) combines an existing options structure
%   OLDOPTS with a new options structure NEWOPTS.  Any parameters in NEWOPTS
%   with non-empty values overwrite the corresponding old parameters in
%   OLDOPTS.
%
%   OPTIMSET with no input arguments and no output arguments displays all
%   parameter names and their possible values, with defaults shown in {}
%   when the default is the same for all functions that use that parameter. 
%   Use OPTIMSET(OPTIMFUNCTION) to see parameters for a specific function.
%
%   OPTIONS = OPTIMSET (with no input arguments) creates an options structure
%   OPTIONS where all the fields are set to [].
%
%   OPTIONS = OPTIMSET(OPTIMFUNCTION) creates an options structure with all
%   the parameter names and default values relevant to the optimization
%   function named in OPTIMFUNCTION. For example,
%           optimset('fminbnd')
%   or
%           optimset(@fminbnd)
%   returns an options structure containing all the parameter names and
%   default values relevant to the function 'fminbnd'.
%
%OPTIMSET PARAMETERS for MATLAB
%Display - Level of display [ off | iter | notify | final ]
%MaxFunEvals - Maximum number of function evaluations allowed
%                     [ positive integer ]
%MaxIter - Maximum number of iterations allowed [ positive scalar ]
%TolFun - Termination tolerance on the function value [ positive scalar ]
%TolX - Termination tolerance on X [ positive scalar ]
%FunValCheck - Check for invalid values, such as NaN or complex, from 
%              user-supplied functions [ {off} | on ]
%OutputFcn - Name(s) of output function [ {[]} | function ] 
%          All output functions are called by the solver after each
%          iteration.
%PlotFcns - Name(s) of plot function [ {[]} | function ]
%          Function(s) used to plot various quantities in every iteration
%
% Note to Optimization Toolbox users:
% To see the parameters for a specific function, check the documentation page 
% for that function. For instance, enter
%   doc fmincon
% to open the reference page for fmincon.
%
% You can also see the options in the Optimization Tool. Enter
%   optimtool
%          
%   Examples:
%     To create an options structure with the default parameters for FZERO
%       options = optimset('fzero');
%     To create an options structure with TolFun equal to 1e-3
%       options = optimset('TolFun',1e-3);
%     To change the Display value of options to 'iter'
%       options = optimset(options,'Display','iter');
%
%   See also OPTIMGET, FZERO, FMINBND, FMINSEARCH, LSQNONNEG.

%   Copyright 1984-2010 The MathWorks, Inc.
%   $Revision: 1.34.4.33 $  $Date: 2011/05/17 02:23:21 $

% Check to see if Optimization Toolbox options are available
optimtbx = uselargeoptimstruct;

% Print out possible values of properties.
if (nargin == 0) && (nargout == 0)
    if optimtbx
        fprintf(['                Display: [ off | iter | iter-detailed | ', ...
            'notify | notify-detailed | final | final-detailed ]\n']);
    else
        fprintf(['                Display: [ off | iter | ', ...
            'notify | final ]\n']);
    end
    fprintf('            MaxFunEvals: [ positive scalar ]\n');
    fprintf('                MaxIter: [ positive scalar ]\n');
    fprintf('                 TolFun: [ positive scalar ]\n');
    fprintf('                   TolX: [ positive scalar ]\n');
    fprintf('            FunValCheck: [ on | {off} ]\n');
    fprintf('              OutputFcn: [ function | {[]} ]\n');
    fprintf('               PlotFcns: [ function | {[]} ]\n');

    % Display specialized options if appropriate
    if optimtbx
        optimoptions;
    else
        fprintf('\n');
    end
    return;
end

% Create a cell array of all the field names
allfields = {'Display'; 'MaxFunEvals';'MaxIter';'TolFun';'TolX'; ...
    'FunValCheck';'OutputFcn';'PlotFcns'};

% Include specialized options if appropriate
if optimtbx   
    optimfields = optimoptiongetfields;  
    allfields = [allfields; optimfields];
end

% Create a struct of all the fields with all values set to []
% create cell array
structinput = cell(2,length(allfields));
% fields go in first row
structinput(1,:) = allfields';
% []'s go in second row
structinput(2,:) = {[]};
% turn it into correctly ordered comma separated list and call struct
options = struct(structinput{:});

numberargs = nargin; % we might change this value, so assign it
% If we pass in a function name then return the defaults.
if (numberargs==1) && (ischar(varargin{1}) || isa(varargin{1},'function_handle') )
    if ischar(varargin{1})
        funcname = lower(varargin{1});
        if ~exist(funcname,'file')
            error(message('MATLAB:optimset:FcnNotFoundOnPath', funcname));
        end
    elseif isa(varargin{1},'function_handle')
        funcname = func2str(varargin{1});
    end
    try 
        optionsfcn = feval(varargin{1},'defaults');
    catch ME
        error(message('MATLAB:optimset:NoDefaultsForFcn', funcname));
    end
    % The defaults from the optim functions don't include all the fields
    % typically, so run the rest of optimset as if called with
    % optimset(options,optionsfcn)
    % to get all the fields.
    varargin{1} = options;
    varargin{2} = optionsfcn;
    numberargs = 2;
end

Names = allfields;
m = size(Names,1);
names = lower(Names);

i = 1;
while i <= numberargs
    arg = varargin{i};
    if ischar(arg)                         % arg is an option name
        break;
    end
    if ~isempty(arg)                      % [] is a valid options argument
        if ~isa(arg,'struct')
            error(message('MATLAB:optimset:NoParamNameOrStruct', i));
        end
        for j = 1:m
            if any(strcmp(fieldnames(arg),Names{j,:}))
                val = arg.(Names{j,:});
            else
                val = [];
            end
            if ~isempty(val)
                if ischar(val)
                    val = lower(deblank(val));
                end
                checkfield(Names{j,:},val,optimtbx);
                options.(Names{j,:}) = val;
            end
        end
    end
    i = i + 1;
end

% A finite state machine to parse name-value pairs.
if rem(numberargs-i+1,2) ~= 0
    error(message('MATLAB:optimset:ArgNameValueMismatch'));
end
expectval = 0;                          % start expecting a name, not a value
while i <= numberargs
    arg = varargin{i};

    if ~expectval
        if ~ischar(arg)
            error(message('MATLAB:optimset:ParamNotString', i));
        end

        lowArg = lower(arg);
        j = strmatch(lowArg,names);
        if isempty(j)                       % if no matches
            % Check for recently deprecated options. These will be ignored
            % in a later release, but for now we will throw a specific
            % error.
            deprecatedOptionCheck(lowArg);
            
            % Error out - compose internationalization-friendly message with hyperlinks
            stringWithLink = formatStringWithHyperlinks(sprintf('Link to reference page'),'doc optimset');
            error(message('MATLAB:optimset:InvalidParamNameWithLink', ...
                  arg, stringWithLink));
        elseif length(j) > 1                % if more than one match
            % Check for any exact matches (in case any names are subsets of others)
            k = strmatch(lowArg,names,'exact');
            if length(k) == 1
                j = k;
            else
                allnames = ['(' Names{j(1),:}];
                for k = j(2:length(j))'
                    allnames = [allnames ', ' Names{k,:}];
                end
                allnames = [allnames,')'];
                error(message('MATLAB:optimset:AmbiguousParamName', arg, allnames));
            end
        end
        expectval = 1;                      % we expect a value next
        % Check for soon to be deprecated option, LineSearchType. 
        % For now, we warn about it's impending obsolecense.
        if strcmp(lowArg,'linesearchtype')
            warning(message('MATLAB:optimset:LStypeInvalid'));
        end

    else
        if ischar(arg)
            arg = lower(deblank(arg));
        end
        checkfield(Names{j,:},arg,optimtbx);
        options.(Names{j,:}) = arg;
        expectval = 0;
    end
    i = i + 1;
end

if expectval
    error(message('MATLAB:optimset:NoValueForParam', arg));
end

%-------------------------------------------------
function checkfield(field,value,optimtbx)
%CHECKFIELD Check validity of structure field contents.
%   CHECKFIELD('field',V,OPTIMTBX) checks the contents of the specified
%   value V to be valid for the field 'field'. OPTIMTBX indicates if 
%   the Optimization Toolbox is on the path.
%

% empty matrix is always valid
if isempty(value)
    return
end

% See if it is one of the valid MATLAB fields.  It may be both an Optim
% and MATLAB field, e.g. MaxFunEvals, in which case the MATLAB valid
% test may fail and the Optim one may pass.
validfield = true;
switch field
    case {'TolFun'} % real scalar
        [validvalue, errmsg, errid] = nonNegReal(field,value);
    case {'TolX'} % real scalar
        % this string is for LSQNONNEG
        [validvalue, errmsg, errid] = nonNegReal(field,value,'10*eps*norm(c,1)*length(c)');
    case {'Display'} % several character strings
        [validvalue, errmsg, errid] = displayType(field,value);
    case {'MaxFunEvals','MaxIter'} % integer including inf or default string
        % this string is for FMINSEARCH
        [validvalue, errmsg, errid] = nonNegInteger(field,value,'200*numberofvariables');
    case {'FunValCheck'} % off,on
        [validvalue, errmsg, errid] = onOffType(field,value);
    case {'OutputFcn','PlotFcns'}% function
        [validvalue, errmsg, errid] = functionOrCellArray(field,value);
    otherwise
        validfield = false;  
        validvalue = false;
        errid = 'MATLAB:optimset:InvalidParamName';
        errmsg = getString(message(errid, field));
end

if validvalue 
    return;
elseif ~optimtbx && validfield  
    % Throw the MATLAB invalid value error
    error(errid, '%s', errmsg);
else % Check if valid for Optim Tbx
    [optvalidvalue, opterrmsg, opterrid, optvalidfield] = optimoptioncheckfield(field,value);
    if optvalidvalue
        return;
    elseif optvalidfield
        % Throw the Optim invalid value error
        ME = MException(opterrid,'%s',opterrmsg);
        throwAsCaller(ME);
    else % Neither field nor value is valid for Optim
        % Throw the MATLAB invalid value error (can't be invalid field for
        % MATLAB & Optim or would have errored already in optimset).
        ME = MException(errid,'%s',errmsg);
        throwAsCaller(ME);
    end
end

%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = nonNegReal(field,value,string)
% Any nonnegative real scalar or sometimes a special string
valid =  isreal(value) && isscalar(value) && (value >= 0) ;
if nargin > 2
    valid = valid || isequal(value,string);
end

if ~valid
    if ischar(value)
        errid = 'MATLAB:optimset:nonNegRealStringType';
        errmsg = getString(message('MATLAB:optimoptioncheckfield:nonNegRealStringType', field));
    else
        errid = 'MATLAB:optimset:notAnonNegReal';
        errmsg = getString(message('MATLAB:optimoptioncheckfield:notAnonNegReal', field));
    end
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = nonNegInteger(field,value,string)
% Any nonnegative real integer scalar or sometimes a special string
valid =  isreal(value) && isscalar(value) && (value >= 0) && value == floor(value) ;
if nargin > 2
    valid = valid || isequal(value,string);
end
if ~valid
    if ischar(value)
        errid = 'MATLAB:optimset:nonNegIntegerStringType';
        errmsg = getString(message('MATLAB:optimoptioncheckfield:nonNegIntegerStringType',field));
    else
        errid = 'MATLAB:optimset:notANonNegInteger';
        errmsg = getString(message('MATLAB:optimoptioncheckfield:notANonNegInteger',field));
    end
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = displayType(field,value)
% One of these strings: on, off, none, iter, final, notify
valid =  ischar(value) && any(strcmp(value, ...
    {'on';'off';'none';'iter';'iter-detailed';'final';'final-detailed';'notify';'notify-detailed';'testing';'simplex'}));
if ~valid
    errid = 'MATLAB:optimset:notADisplayType';
    errmsg = getString(message(errid, field));
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = onOffType(field,value)
% One of these strings: on, off
valid =  ischar(value) && any(strcmp(value,{'on';'off'}));
if ~valid
    errid = 'MATLAB:optimset:notOnOffType';
    errmsg = getString(message(errid, field));
else
    errid = '';
    errmsg = '';
end

%--------------------------------------------------------------------------------

function [valid, errmsg, errid] = functionOrCellArray(field,value)
% Any function handle, string or cell array of functions 
valid =  ischar(value) || isa(value, 'function_handle') || iscell(value);
if ~valid
    errid = 'MATLAB:optimset:notAFunctionOrCellArray';
    errmsg = getString(message(errid, field));
else
    errid = '';
    errmsg = '';
end

%--------------------------------------------------------------------------------

function formattedString = formatStringWithHyperlinks(textToHyperlink,commandToRun)
% Check if user is running MATLAB desktop. In this case wrap
% textToHyperlink with HTML tags so that when user clicks on
% textToHyperlink, commandToRun gets executed. If not running
% MATLAB desktop, leave textToHyperlink unchanged.

if feature('hotlinks') && ~isdeployed
    % If using MATLAB desktop and not deployed, use hyperlinks
    formattedString = sprintf('<a href="matlab: %s ">%s</a>.',commandToRun,textToHyperlink);
else
    % Use plain string
    formattedString = sprintf('');
end

%--------------------------------------------------------------------------------

function deprecatedOptionCheck(lowerCaseOption)
%CHECKFORDEPRECATEDOPTIONS Checks option against a list of recently
%deprecated options. A specific error message is thrown if there is a
%match.
removedOptExcept = [];
switch lowerCaseOption
    case 'levenbergmarquardt'
        removedOptExcept = MException('MATLAB:optimset:LevMarqInvalid', ...
            '%s', getString(message('MATLAB:optimset:LevMarqInvalid')));
    case 'nonleqnalgorithm'
        removedOptExcept = MException('MATLAB:optimset:NonlEqnInvalid', ...
            '%s', getString(message('MATLAB:optimset:NonlEqnInvalid')));
end

if ~isempty(removedOptExcept)
    throwAsCaller(removedOptExcept);
end
