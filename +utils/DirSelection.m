classdef DirSelection < CenterlineApp.base.DirSelectionBase
    
    methods (Static)
            
        function val = chooseDir(startPath, title)
            val = uigetdir(startPath, title);
            
            %{
                Check if the cancel button was triggered in the uigetdir fcn
                or if a non-VIPR directory was selected
                if so, the directory would not be altered and
                the previous directory will be the same
            %}
            fname = "pcvipr_header.txt";
            if val == 0
                ME = MException('DirSelection:chooseDir:cancel', ...
                    'No folder selected');
                throw(ME);
            elseif ~isfile(fullfile(val, fname))
                msg = sprintf('Invalid VIPR Directory.\n\nNo file named ''%s'' in ''%s''', ...
                    fname, strrep(val, '\', '\\'));
                ME = MException('DirSelection:chooseDir:invalid', msg);
                throw(ME);
            end
            
        end
    end
    
end