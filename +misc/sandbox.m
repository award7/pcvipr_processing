classdef sandbox < CenterlineApp.base.ViewBase
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (GetAccess = public, SetAccess = private)
        UIFigure;
        childWin;
    end
    
    methods
        
        function self = sandbox()
            self.UIFigure = uifigure;
        end
        
        function createChildWindow(self)
            self.childWin = uifigure;
            self.setWindowAsModal(true);
        end
        
    end
end

