classdef Controller < handle
    
    properties (Access = public)
        View;
        Model;
    end
    
    methods (Access = public)
        
        function self = Controller()
            self.View = View(self);
            self.Model = Model();
        end
        
        function delete(self)
            delete(self.View.UIFigure);
            delete(self.View);
            delete(self.Model);
        end
        
    end
    
    % menu button callbacks
    methods (Access = public)
        
        function backgroundPhaseCorrectionMenuButtonCallback(self, src, evt)
            self.bgpcMain();
        end
        
        function connectToDbMenuButtonCallback(self, src, evt)
            % todo: create inputdlg for db parameters
        end
        
        function loadDataMenuButtonCallback(self, src, evt)
            % todo: call uigetdir
        end
        
        function setDataOutputPathMenuButtonCallback(self, src, evt)
            out = self.Model.someFcn();
            disp(out);
        end
        
        function exitMenuButtonCallback(self, src, evt)
            self.delete();
        end
        
    end
    
    % bgpc methods
    methods (Access = private)
        
        function bgpcMain(self)
            disp('bar');
        end
        
    end
    
end