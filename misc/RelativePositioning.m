classdef RelativePositioning < handle
    % methods to make gui figure and object positioning relative instead of
    % absolute
       
    properties
       Pixels;
       ScreenLeft;
       ScreenBottom;
       ScreenWidth;
       ScreenHeight;
       
       % accounts for inclusion of titlebar on windows systems
       % not tested for Mac or *nix OS
       TitlebarHeight = 22;
    end
    
    methods
        
        function self = RelativePositioning()
            [~] = self.get_effective_physical_screensize();
            self.Pixels = self.get_physical_screensize();
        end
        
    end
    
    methods(Access = public)
        
        function sz = get_effective_physical_screensize(self)
            %{
            uses java to get the usable screen size minus toolbars, insets, etc.
            must return a struct based on the java object type
            structure fields are 'width' and 'height'
            %}

            screenSize = self.get_physical_screensize();
            insets = self.get_insets();
            
            screenSize.left = insets.left;
            screenSize.bottom = insets.bottom;
            screenSize.width = screenSize.width - (insets.left + insets.right);
            screenSize.height = screenSize.height - (insets.top + insets.bottom + self.TitlebarHeight);

            self.ScreenLeft = screenSize.left;
            self.ScreenBottom = screenSize.bottom;
            self.ScreenWidth = screenSize.width;
            self.ScreenHeight = screenSize.height;

            sz = struct(screenSize);
        end
        
        function coordinates = centerChildInParent(self, parent_dims, parent_relative, child_dims, child_relative)
            % center a child figure within a parent figure
            % parent_dims = 1x4 vector representing [Left Bottom Width Height]
            % child_dims = 1x2 vector representing [Width Height]
            % parent_relative = boolean used to determine the values in parent_dims
            % child_relative = boolean used to determine the values in child_dims
            
            arguments
                self;
                parent_dims             (1,4) {mustBeVector, mustBePositive};
                parent_relative         (1,1) {mustBeNumericOrLogical};
                child_dims              (1,2) {mustBeNonempty, mustBePositive};
                child_relative          (1,1) {mustBeNumericOrLogical};
            end
            
            % check inputs to determine if pixels are needed
            if parent_relative == true
                parent_dims(1) = parent_dims(1) * self.ScreenWidth;
                parent_dims(2) = parent_dims(2) * self.ScreenHeight;
                parent_dims(3) = parent_dims(3) * self.ScreenWidth;
                parent_dims(4) = parent_dims(4) * self.ScreenHeight;
            end

            if child_relative == true
                child_dims(1) = child_dims(1) * self.ScreenWidth;
                child_dims(2) = child_dims(2) * self.ScreenHeight;
            end
            
            % calculate left and bottom positions
            %{
            % 2022-01-22: I am clueless as to why the below formulas didn't work
            % x = (width/2) + margin
            % y = (height/2) + margin
            % x_center_parent = (parent_dims(3)/2) + parent_dims(1);
            % y_center_parent = (parent_dims(4)/2) + parent_dims(2);
            
            % x_center_parent = x_center_child
            % y_center_parent = y_center_child
            
            % x = x_center - (width_child/2)
            % y = y_center - (height_child/2)
            % x = x_center_parent - (child_dims(1)/2);
            % y = y_center_parent - (child_dims(2)/2);
            %}
            x = parent_dims(1);
            y = parent_dims(2);
            
            % do some validation
            coordinates = [x y child_dims(1) child_dims(2)];
            if any(self.ScreenWidth < coordinates)
                me = MException('RelativePositioning:OutOfRange', 'Calculated child figure coordinates exceed the screen dimensions');
                throw(me);
            end
        end
        
        function coordinates = centered_screen(self, obj_width, obj_height)
            left = (self.ScreenWidth - obj_width)/2;
            bottom = (self.ScreenHeight - obj_height)/2;
            width = obj_width;
            height = obj_height;
            coordinates = [left bottom width height];
        end
        
        function coordinates = fullscreen(self)
            left = 0;
            bottom = 0;
            width = self.ScreenWidth;
            height = self.ScreenHeight;
            coordinates = [left bottom width height];
        end
        
        function coordinates = split_left(self)
            left = 0;
            bottom = 0;
            width = self.ScreenWidth/2;
            height = self.ScreenHeight/2;
            coordinates = [left bottom width height];
        end
        
        function coordinates = split_right(self)
            left = self.ScreenWidth/2;
            bottom = 0;
            width = self.ScreenWidth/2;
            height = self.ScreenHeight/2;
            coordinates = [left bottom width height];
        end
        
        function coordinates = split_top(self)
            left = 0;
            bottom = self.ScreenHeight/2;
            width = self.ScreenWidth;
            height = self.ScreenHeight;
            coordinates = [left bottom width height];
        end
        
        function coordinates = split_bottom(self)
            left = 0;
            bottom = 0;
            width = self.ScreenWidth;
            height = self.ScreenHeight/2;
            coordinates = [left bottom width height];
        end
        
        function coordinates = offset_obj(self, anchor_position, offset)
            % anchor_position = the object position that is being used as
            % reference to for another object's relative position
            % offset is the relative object's position offset in %
            
            self.check_args(anchor_position, offset);
            
            l_parent = floor(anchor_position(1));
            b_parent = floor(anchor_position(2));
            w_parent = floor(anchor_position(3));
            h_parent = floor(anchor_position(4));

            w_child = w_parent * (offset(3)/100);
            h_child = h_parent * (offset(4)/100);
            l_child = w_parent * (offset(1)/100) + l_parent;
            b_child = h_parent * (offset(2)/100) + b_parent;
            
            coordinates = floor([l_child b_child w_child h_child]);
        end
        
    end
    
    methods (Static)
        
        function sz = get_physical_screensize()
            %{
            uses java to get the usable screen size minus toolbars, insets, etc.
            must return a struct based on the java object type
            structure fields are 'width' and 'height'
            NOTE: this will return the physical screen size, not the
            virtual screen size
            %}

            import java.awt.*;
            import javax.swing.JFrame;

            toolkit = Toolkit.getDefaultToolkit();
            screenSize = toolkit.getScreenSize();
            
            sz = struct(screenSize);
        end

        function sz = get_insets()
            %{
            uses java to get the usable screen size minus toolbars, insets, etc.
            must return a struct based on the java object type
            structure fields are 'width' and 'height'
            %}

            import java.awt.*;
            import javax.swing.JFrame;
            
            toolkit = Toolkit.getDefaultToolkit();
            insets = toolkit.getScreenInsets(Frame().getGraphicsConfiguration());
            
            sz = struct(insets);
        end

        function check_args(pos1, pos2)
            if numel(pos1) ~= 4 || numel(pos2) ~=4
                error('Arguments must be a 4 element vector corresponding to [left bottom width height]');
            end
            
            if any(pos1<0) || any(pos2<0)
                error('Arguments must be positive')
            end
            
            if any(pos2>100)
                error('Offset arguments must be in range between 0-100');
            end
        end
        
    end
    
end

