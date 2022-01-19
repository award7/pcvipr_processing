classdef Controller < handle
    
    properties (Access = public)
        View;
        Model;
    end
    
    properties (Access = public)
        State   AppState;
    end
    
    methods (Access = public)
        
        function self = Controller()
            clc;
            self.View = BaseView(self);
            self.Model = Model();
            self.State = AppState.Main;
        end
        
        function delete(self)
            delete(self.View.UIFigure);
            delete(self.View);
            delete(self.Model);
        end
        
    end
    
    % callbacks from menu
    methods (Access = public)
        
        function backgroundPhaseCorrectionMenuButtonCallback(self, src, evt)
            % display background phase correction images and widgets
            % don't reload if it's currently in this state
            if strcmp(self.State, 'BackgroundPhaseCorrection')
                return;
            end
            BackgroundPhaseCorrectionView(self);
            self.State = AppState.BackgroundPhaseCorrection;
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
        
        function testDbConnectionMenuButtonCallback(self, src, evt)
            
        end
        
        function drawROIMenuButtonCallback(self, src, evt)
        end
        
        function viewFullVasculatureMenuButtonCallback(self, src, evt)
        end
        
        function viewParametricMapMenuButtonCallback(self, src, evt)
        end
        
        function vesselSelectionMenuButtonCallback(self, src, evt)
        end
        
        function segmentVesselsMenuButtonCallback(self, src, evt)
        end
        
        function vessel3dMenuButtonCallback(self, src, evt)
        end
        
        function parameterPlotMenuButtonCallback(self, src, evt)
        end
        
        function setDataOutputParametersMenuCallback(self, src, evt)
        end
        
    end
    
    % callbacks from BackgroundPhaseCorrectionView
    methods (Access = public)
        
        % bgpc = BackGround Phase Correction
        function bgpcImageValueChangedCallback(self, src, evt)
            value = evt.Value;
            
            switch evt.Source.Type
                case 'uislider'
                    src.ImageSlider.Value = value;
                    value = floor(value) / 100;
                    src.ImageSpinner.Value = value;
                case 'uispinner'
                    src.ImageSpinner.Value = value;
                    value = round(value, 2) * 100;
                    src.ImageSlider.Value = value;
                    value = value / 100;
            end

            self.Model.Image = value;
%             src.update_images();
        end
        
        function bgpcVmaxValueChangedCallback(self, src, evt)
            value = evt.Value;
            
            switch evt.Source.Type
                case 'uislider'
                    src.VmaxSlider.Value = value;
                    value = floor(value) / 100;
                    src.VmaxSpinner.Value = value;
                case 'uispinner'
                    src.VmaxSpinner.Value = value;
                    value = round(value, 2) * 100;
                    src.VmaxSlider.Value = value;
                    value = value / 100;
            end

            self.Model.Vmax = value;
%             src.update_images();
        end
        
    end
    
    % load data methods
    methods (Access = private)
        
        function load(app)
        end
        
    end
    
    % bgpc methods
    methods (Access = private)
        
        function bgpcMain(self)
            
        end
        
    end
    
end