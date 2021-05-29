classdef View < matlab.apps.AppBase & ...
                    centerlineapp.base.view.DlgBoxBase & ...
                    centerlineapp.base.view.ProgressBarBase
    
    % set window as modal
    methods (Access = public, Static)
       
        function setWindowAsModal(fig, bool)
            % derived from https://undocumentedmatlab.com/articles/customizing-uifigures-part-1
            warning off MATLAB:structOnObject      % suppress warning (yes, we know it's naughty...)
            figProps = struct(fig);
            controller = figProps.Controller;      % Controller is a private hidden property of Figure
            controllerProps = struct(controller);
            try  % up to R2019a
                container = controllerProps.Container;
            catch  % R2019b or newer
                container = struct(controllerProps.PlatformHost);
            end
            win = container.CEF;
            win.setWindowAsModal(bool);
        end
        
    end
    
end