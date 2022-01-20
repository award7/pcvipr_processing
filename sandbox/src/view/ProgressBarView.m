classdef ProgressBarView < matlab.ui.dialog.ProgressDialog
    %{
    Subclass of uiprogress dialog
    
    Assigns default title
    Creates properties of 'Pause' and 'Duration' to allow a better UX feel
    as graphics render
    
    %}
    
    properties (SetObservable)
        Pause {mustBeMember(Pause, {'on', 'off'})} = 'on';
        Duration {mustBeNumeric, mustBeNonnegative} = 1;
    end
    
    methods (Access = public)
        
        function self = ProgressBarView(fig, opts, parent_args)
            arguments
                fig;
                opts.Pause  = 'off';
                opts.Duration = 1;
                parent_args.?matlab.ui.dialog.ProgressDialog
            end
            
            % override any superclass args
            parent_args.Title = 'PC VIPR Processing';
            
            % call superclass constructor
            args = namedargs2cell(parent_args);
            self@matlab.ui.dialog.ProgressDialog(fig, args{:});
            
            % assign subclass properties
            self.Pause = opts.Pause;
            self.Duration = opts.Duration;
        end
        
    end
    
    methods (Access = public)
       
        % override delete
        function delete(self)
            if strcmp(self.Pause, 'on')
                pause(self.Duration);
                delete(self);
            end
        end
        
    end
    
end