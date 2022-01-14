classdef AppLinker < handle
    %{
        linker class to link interactions between Vessel3DApp and
        ParameterPlotApp
    %}
    
    properties (Access = private)
        Vessel3DAppHandle       Vessel3DApp;
        ParameterPlotAppHandle  ParameterPlotApp;
    end
    
    methods (Access = public)
        
        function self = AppLinker(VIPR)
            self.Vessel3DAppHandle = Vessel3DApp(self, VIPR);
            self.ParameterPlotAppHandle = ParameterPlotApp(self, VIPR);
        end
        
        function voxelChanged(self, event, windowValue, windowLimit)
            value = floor(event.Value);
            if windowValue + value - 1 > windowLimit
                value = event.PreviousValue;
            end
            self.Vessel3DAppHandle.updateLowerVoxelComponents(value);
            self.ParameterPlotAppHandle.updateLowerVoxelComponents(value);
        end
        
        function windowChanged(self, event, windowLimit)
            windowValue = floor(event.Value);
            upperLimitVoxel = windowLimit - windowValue + 1;
            self.Vessel3DAppHandle.updateWindowComponents(windowValue, upperLimitVoxel);
            self.ParameterPlotAppHandle.updateWindowComponents(windowValue, upperLimitVoxel);
        end
        
        function closeRequest(self)
            self.Vessel3DAppHandle.delete;
            self.ParameterPlotAppHandle.delete;
        end
        
    end

end