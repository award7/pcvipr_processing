classdef DlgBoxBase < centerlineapp.base.view.IconBase
    
    % wrapper for creating uiconfirm and uialert (i.e. dialog boxes)
    % allows the return of an int which neither built-in allows
    % provides simplified methods to create error dialogs, confirmations, etc.
    
    methods (Access = protected)
        
        function val = createConfirmation(self, fig, msg, opts)
            arguments
                self;
                fig matlab.ui.Figure;
                msg {mustBeText};
                opts.title {mustBeText} = 'Confirm';
            end
            
            icon = self.QuestionIcon;
            buttons = {'Yes', 'No'};
            values = [1, 0];
            defaultBtn = 1;
            cancelBtn = 2;
            closeFcn = [];
            val = self.createDlgBox(fig, msg, opts.title, icon, buttons, ...
                values, defaultBtn, cancelBtn, closeFcn);
        end
        
        function val = createCustomDlg(self, fig, msg, opts)
            arguments
                self;
                fig matlab.ui.Figure;
                msg {mustBeText};
                opts.title {mustBeText} = '';
                opts.icon = '';
                opts.buttons {mustBeText} = {'Ok'};
                opts.values {mustBeInteger} = [0];
                opts.DefaultBtn = 1;
                opts.CancelBtn = 1;
                opts.CloseFcn = [];
            end
            
            % set icon to 'None' if parameter is empty
            if isempty(opts.icon)
                opts.icon = self.NoneIcon;
            end
            
            % check if each value is unique
            if numel(opts.buttons) ~= numel(opts.values)
                msg = sprintf('Each value must be unique');
                ME = MException('DlgBoxBase:createCustomDlg', msg);
                throw(ME);
            end
            
             % check if each button has an associated value 
            if length(opts.values) ~= length(unique(opts.values))
                msg = sprintf('The number of buttons must equal the number of associated values');
                ME = MException('DlgBoxBase:createCustomDlg', msg);
                throw(ME);
            end
            
            % check if there's > 1 button and if the default and cancel button
            % have equal values
            if numel(opts.buttons) > 1 && opts.DefaultBtn == opts.CancelBtn
                opts.DefaultBtn = opts.buttons{1};
                opts.CancelBtn = opts.buttons{end};
            end

            val = self.createDlgBox(fig, msg, opts.title, opts.icon, ...
                opts.buttons, opts.values, opts.DefaultBtn, ...
                opts.CancelBtn, opts.CloseFcn);
        end
        
        function val = createErr(self, fig, msg, opts)
            arguments
                self;
                fig matlab.ui.Figure;
                msg {mustBeText};
                opts.title {mustBeText} = 'Error';
            end
            
            icon = self.ErrorIcon;
            buttons = {'Ok'};
            values = [0];
            defaultBtn = 1;
            cancelBtn = 1;
            closeFcn = [];
            val = self.createDlgBox(fig, msg, opts.title, icon, buttons, ...
                values, defaultBtn, cancelBtn, closeFcn);
        end
        
        function val = createInfo(self, fig, msg, opts)
            arguments
                self;
                fig matlab.ui.Figure;
                msg {mustBeText};
                opts.title {mustBeText} = 'Info';
            end
            
            icon = self.InfoIcon;
            buttons = {'Ok'};
            values = [0];
            defaultBtn = 1;
            cancelBtn = 1;
            closeFcn = [];
            val = self.createDlgBox(fig, msg, opts.title, icon, buttons, ...
                values, defaultBtn, cancelBtn, closeFcn);
        end
        
        function val = createSuccess(self, fig, msg, opts)
            arguments
                self;
                fig matlab.ui.Figure;
                msg {mustBeText};
                opts.title {mustBeText} = 'Success';
            end
            
            icon = self.SuccessIcon;
            buttons = {'Ok'};
            values = [0];
            defaultBtn = 1;
            cancelBtn = 1;
            closeFcn = [];
            val = self.createDlgBox(fig, msg, opts.title, icon, buttons, ...
                values, defaultBtn, cancelBtn, closeFcn);
        end
        
        function val = createWarning(self, fig, msg, opts)
            arguments
                self;
                fig matlab.ui.Figure;
                msg {mustBeText};
                opts.title {mustBeText} = 'Warning';
            end
            
            icon = self.WarningIcon;
            buttons = {'Ok'};
            values = [0];
            defaultBtn = 1;
            cancelBtn = 1;
            closeFcn = [];
            val = self.createDlgBox(fig, msg, opts.title, icon, buttons, ...
                values, defaultBtn, cancelBtn, closeFcn);
        end
        
    end
    
    methods (Access = private)
        
        function val = createDlgBox(self, fig, msg, title, icon, buttons, ...
                values, DefaultBtn, CancelBtn, CloseFcn)
            
            res = uiconfirm(fig, msg, title, ...
                'icon', icon, ...
                'options', buttons, ...
                'DefaultOption', DefaultBtn, ...
                'CancelOption', CancelBtn, ...
                'CloseFcn', CloseFcn);
            
            val = self.parseRes(res, buttons, values);
        end
        
    end
    
    % parse dlg box return
    methods (Access = private, Static)

        % this parser allows the return of an int instead of a char vector
        function val = parseRes(res, buttons, values)
            idx = find(strcmp(res, buttons));
            val = values(idx);
        end
        
    end
    
end