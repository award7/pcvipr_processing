classdef Controller < handle
    %{ 
        abstract class for controller classes
        uses the MVC (model-viw-controller) paradigm
    %}
    properties (Abstract)
        % prop to hold the associated view obj
        View;
        
        % prop to hold the associated model obj
        Model;
    end
    
    methods (Abstract, Access = protected)
        %{
            custom IO methods for Apps
            app designer objects cannot utilize 'saveobj' and 'loadobj'
            properly
            this is a workaround to that to save only necessary data that,
            when combined with the required input arg to the app, will
            restore the previous state
        %}
        
        saveApp(obj);
        loadApp(obj);
        
        %%%
        setCallbacks(obj);
    end
    
    methods (Access = protected)
        
        function uiClose(obj, src, evt)
            delete(obj);
        end
        
        % Window key pressed function
        function uiWindowKeyPressFcn(app, src, evt)
            switch char(evt.Modifier)
                case 'control'
                    if strcmpi(evt.Key, 'w')
                        uiFigureCloseRequest(app);
                    end
            end
        end
        
    end
    
end

