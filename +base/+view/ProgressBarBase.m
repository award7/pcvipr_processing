classdef ProgressBarBase < handle
    % superclass wrapper for uiprogressdlg
    
    properties (Access = protected)
        Dlg;
    end
    
    methods (Access = protected)
        
        function self = ProgressBarBase()
            % pass
        end
        
        function createDlg(self, fig)
            self.Dlg = uiprogressdlg(fig);
        end
        
        function setDlgTitle(self, txt)
            self.Dlg.Title = txt;
        end
        
        function setDlgMsg(self, txt)
            self.Dlg.Message = txt;
        end
        
        function setDlgVal(self, val)
            self.Dlg.Value = val;
        end
        
        function setDlgShowPercentage(self, bool)
            self.Dlg.ShowPercentage(bool);
        end
        
        function setDlgIndeterminate(self, bool)
            self.Dlg.Indeterminate = bool;
        end
        
        function setDlgCancelable(self, bool)
            self.Dlg.Cancelable = bool;
        end
        
        function setDlgIcon(self, bool)
            self.Dlg.Icon = bool;
        end
        
        function setCancelText(self, txt)
            self.Dlg.CancelText = txt;
        end
        
        function deleteDlg(self)
            delete(self.Dlg);
        end
        
    end
    
end