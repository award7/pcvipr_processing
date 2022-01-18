classdef VesselSelectionApp < matlab.apps.AppBase & MAGrgb

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                    matlab.ui.Figure
        DoneButton                  matlab.ui.control.Button
        CancelButton                matlab.ui.control.Button
        VesselTable                 matlab.ui.control.Table
        SagittalAxes                matlab.ui.control.UIAxes
        CoronalAxes                 matlab.ui.control.UIAxes
        AxialAxes                   matlab.ui.control.UIAxes
        XLabel                      matlab.ui.control.Label
        YLabel                      matlab.ui.control.Label
        ZLabel                      matlab.ui.control.Label
        SagittalImage;
        CoronalImage;
        AxialImage;
        AbsLowerBound = 1;
        XSliceMax;
        YSliceMax;
        ZSliceMax;
        XCoordinate;
        YCoordinate;
        ZCoordinate;
        XSlice;
        YSlice;
        ZSlice;
    end
    
    % Properties that correspond to app components (con't)
    properties (Access = private, Hidden)
        ParentGridLayout            matlab.ui.container.GridLayout
        ChildGridLayout1            matlab.ui.container.GridLayout
        ChildGridLayout2            matlab.ui.container.GridLayout
        ChildGridLayout3            matlab.ui.container.GridLayout
        ContextMenu                 matlab.ui.container.ContextMenu
        ArteryMenu                  matlab.ui.container.Menu
        VeinMenu                    matlab.ui.container.Menu
        LeftICAOpt                  matlab.ui.container.Menu
        RightICAOpt                 matlab.ui.container.Menu
        LeftMCAOpt                  matlab.ui.container.Menu
        RightMCAOpt                 matlab.ui.container.Menu
        LeftACAOpt                  matlab.ui.container.Menu
        RightACAOpt                 matlab.ui.container.Menu
        LeftPCAOpt                  matlab.ui.container.Menu
        RightPCAOpt                 matlab.ui.container.Menu
        BasilarAOpt                 matlab.ui.container.Menu
        LeftVAOpt                   matlab.ui.container.Menu
        RightVAOpt                  matlab.ui.container.Menu
        SuperiorSagittalSOpt        matlab.ui.container.Menu
        StraightSOpt                matlab.ui.container.Menu
        TransverseSOpt              matlab.ui.container.Menu
        NondominantTransvereSOpt    matlab.ui.container.Menu
        SagittalAxesTB;
        CoronalAxesTB;
        AxialAxesTB;
        SagittalCrosshairs;
        CoronalCrosshairs;
        AxialCrosshairs;
    end
    
    properties (Access = public)
        CenterlineToolApp;
    end
    
    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = VesselSelectionApp(varargin)

            % Create UIFigure and components
            app.createComponents()

            % Register the app with App Designer
            app.registerApp(app.UIFigure)

            % Execute the startup function
            app.runStartupFcn(@(app)startupFcn(app, varargin{:}))
            
            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
        
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)
            app.init_figure();
            app.init_parent_grid();
            app.init_child_grid1();
            app.init_child_grid2();
            app.init_child_grid3();
            app.init_sagittal_axes();
            app.init_coronal_axes();
            app.init_axial_axes();
            app.init_sagittal_tb();
            app.init_coronal_tb();
            app.init_axial_tb();
            app.init_context_menu();
            app.init_done_button();
            app.init_cancel_button();
            app.init_x_label();
            app.init_y_label();
            app.init_z_label();
            app.init_vessel_table();

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
        
        % create figure
        function init_figure(app)
            app.UIFigure = uifigure('Visible', 'on');
            app.UIFigure.Name = 'Vessel Selection';
            app.UIFigure.WindowState = 'maximized';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @uifigure_close_request, true);
            app.UIFigure.WindowScrollWheelFcn = createCallbackFcn(app, @uifigure_window_scroll_wheel, true);
            app.UIFigure.WindowKeyPressFcn = createCallbackFcn(app, @uifigure_window_key_press, true);
        end
        
        % create grids
        function init_parent_grid(app)
            app.ParentGridLayout = uigridlayout(app.UIFigure);
            app.ParentGridLayout.RowHeight = {'4x', '4x', '1x'};
        end
        
        function init_child_grid1(app)
            app.ChildGridLayout1 = uigridlayout(app.ParentGridLayout);
            app.ChildGridLayout1.Layout.Row = 2;
            app.ChildGridLayout1.Layout.Column = 2;
            app.ChildGridLayout1.ColumnWidth = {'1x', '4x'};
            app.ChildGridLayout1.RowHeight = {'1x'};
        end
        
        function init_child_grid2(app)
            app.ChildGridLayout2 = uigridlayout(app.ChildGridLayout1);
            app.ChildGridLayout2.Layout.Row = 1;
            app.ChildGridLayout2.Layout.Column = 1;
            app.ChildGridLayout2.ColumnWidth = {'1x'};
            app.ChildGridLayout2.RowHeight = {'1x', '1x', '1x'};
        end
        
        function init_child_grid3(app)
            app.ChildGridLayout3 = uigridlayout(app.ParentGridLayout);
            app.ChildGridLayout3.Layout.Row = 3;
            app.ChildGridLayout3.Layout.Column = 2;
            app.ChildGridLayout3.RowHeight = {'1x'};
        end
        
        % create axes
        function init_sagittal_axes(app)
            app.SagittalAxes = uiaxes(app.ParentGridLayout);
            app.SagittalAxes.Layout.Row = 1;
            app.SagittalAxes.Layout.Column = 1;
            title(app.SagittalAxes, 'Sagittal')
            app.SagittalAxes.XLimMode = 'manual';
            app.SagittalAxes.XLim = [1 320];
            app.SagittalAxes.XTick = [];
            app.SagittalAxes.YLimMode = 'manual';
            app.SagittalAxes.YLim = [1 320];
            app.SagittalAxes.YTick = [];
            xlabel(app.SagittalAxes, '')
            ylabel(app.SagittalAxes, '')
            app.SagittalAxes.Color = [0.149 0.149 0.149];
            app.SagittalAxes.Tag = 'SagittalAxes';
        end
        
        function init_coronal_axes(app)
            app.CoronalAxes = uiaxes(app.ParentGridLayout);
            app.CoronalAxes.Layout.Row = 1;
            app.CoronalAxes.Layout.Column = 2;
            title(app.CoronalAxes, 'Coronal')
            app.CoronalAxes.XLimMode = 'manual';
            app.CoronalAxes.XLim = [1 320];
            app.CoronalAxes.XTick = [];
            app.CoronalAxes.YLimMode = 'manual';
            app.CoronalAxes.YLim = [1 320];
            app.CoronalAxes.YTick = [];
            xlabel(app.CoronalAxes, '')
            ylabel(app.CoronalAxes, '')
            app.CoronalAxes.Color = [0.149 0.149 0.149];
            app.CoronalAxes.Tag = 'CoronalAxes';
        end
        
        function init_axial_axes(app)
            app.AxialAxes = uiaxes(app.ParentGridLayout);
            app.AxialAxes.Layout.Row = 2;
            app.AxialAxes.Layout.Column = 1;
            title(app.AxialAxes, 'Axial')
            app.AxialAxes.XLimMode = 'manual';
            app.AxialAxes.XLim = [1 320];
            app.AxialAxes.XTick = [];
            app.AxialAxes.YLimMode = 'manual';
            app.AxialAxes.YLim = [1 320];
            app.AxialAxes.YTick = [];
            xlabel(app.AxialAxes, '')
            ylabel(app.AxialAxes, '')
            app.AxialAxes.Color = [0.149 0.149 0.149];
            app.AxialAxes.Tag = 'AxialAxes';
        end
        
        % create custom toolbars
        function init_sagittal_tb(app)
            app.SagittalAxesTB = axtoolbar(app.SagittalAxes, {'zoomin', 'zoomout', 'export', 'datacursor'});
            app.SagittalAxesTB.Tag = 'sagittal_tb';
            sagittal_btn = axtoolbarbtn(app.SagittalAxesTB, 'push');
            sagittal_btn.Icon = 'restoreview';
            sagittal_btn.ButtonPushedFcn = createCallbackFcn(app, @toolbar_value_changed, true);
        end
        
        function init_coronal_tb(app)
            app.CoronalAxesTB = axtoolbar(app.CoronalAxes, {'zoomin', 'zoomout', 'export', 'datacursor'});
            app.CoronalAxesTB.Tag = 'coronal_tb';
            coronal_btn = axtoolbarbtn(app.CoronalAxesTB, 'push');
            coronal_btn.Icon = 'restoreview';
            coronal_btn.ButtonPushedFcn = createCallbackFcn(app, @toolbar_value_changed, true);
        end
        
        function init_axial_tb(app)
            app.AxialAxesTB = axtoolbar(app.AxialAxes, {'zoomin', 'zoomout', 'export', 'datacursor'});
            app.AxialAxesTB.Tag = 'axial_tb';
            axial_btn = axtoolbarbtn(app.AxialAxesTB, 'push');
            axial_btn.Icon = 'restoreview';
            axial_btn.ButtonPushedFcn = createCallbackFcn(app, @toolbar_value_changed, true);
        end
        
        % create context menu
        function init_context_menu(app)
            app.ContextMenu = uicontextmenu(app.UIFigure);
            app.ArteryMenu = uimenu(app.ContextMenu);
            app.ArteryMenu.Text = 'Artery';
            app.VeinMenu = uimenu(app.ContextMenu);
            app.VeinMenu.Text = 'Vein';
            
            app.LeftICAOpt = uimenu(app.ArteryMenu);
            app.LeftICAOpt.Text = 'Left ICA';
            app.LeftICAOpt.MenuSelectedFcn = app.createCallbackFcn(@context_menu_option_selected, true);
            
            app.RightICAOpt = uimenu(app.ArteryMenu);
            app.RightICAOpt.Text = 'Right ICA';
            app.RightICAOpt.MenuSelectedFcn = app.createCallbackFcn(@context_menu_option_selected, true);
            
            app.LeftMCAOpt = uimenu(app.ArteryMenu);
            app.LeftMCAOpt.Text = 'Left MCA';
            app.LeftMCAOpt.MenuSelectedFcn = app.createCallbackFcn(@context_menu_option_selected, true);
            
            app.RightMCAOpt = uimenu(app.ArteryMenu);
            app.RightMCAOpt.Text = 'Right MCA';
            app.RightMCAOpt.MenuSelectedFcn = app.createCallbackFcn(@context_menu_option_selected, true);
            
            app.LeftACAOpt = uimenu(app.ArteryMenu);
            app.LeftACAOpt.Text = 'Left ACA';
            app.LeftACAOpt.MenuSelectedFcn = app.createCallbackFcn(@context_menu_option_selected, true);
            
            app.RightACAOpt = uimenu(app.ArteryMenu);
            app.RightACAOpt.Text = 'Right ACA';
            app.RightACAOpt.MenuSelectedFcn = app.createCallbackFcn(@context_menu_option_selected, true);
            
            app.LeftPCAOpt = uimenu(app.ArteryMenu);
            app.LeftPCAOpt.Text = 'Left PCA';
            app.LeftPCAOpt.MenuSelectedFcn = app.createCallbackFcn(@context_menu_option_selected, true);
            
            app.RightPCAOpt = uimenu(app.ArteryMenu);
            app.RightPCAOpt.Text = 'Right PCA';
            app.RightPCAOpt.MenuSelectedFcn = app.createCallbackFcn(@context_menu_option_selected, true);
            
            app.LeftVAOpt = uimenu(app.ArteryMenu);
            app.LeftVAOpt.Text = 'Left VA';
            app.LeftVAOpt.MenuSelectedFcn = app.createCallbackFcn(@context_menu_option_selected, true);
            
            app.RightVAOpt = uimenu(app.ArteryMenu);
            app.RightVAOpt.Text = 'Right VA';
            app.RightVAOpt.MenuSelectedFcn = app.createCallbackFcn(@context_menu_option_selected, true);
            
            app.BasilarAOpt = uimenu(app.ArteryMenu);
            app.BasilarAOpt.Text = 'Basilar A';
            app.BasilarAOpt.MenuSelectedFcn = app.createCallbackFcn(@context_menu_option_selected, true);
            
            app.SuperiorSagittalSOpt = uimenu(app.VeinMenu);
            app.SuperiorSagittalSOpt.Text = 'Superior Sagittal S';
            app.SuperiorSagittalSOpt.MenuSelectedFcn = app.createCallbackFcn(@context_menu_option_selected, true);
            
            app.StraightSOpt = uimenu(app.VeinMenu);
            app.StraightSOpt.Text = 'Straight S';
            app.StraightSOpt.MenuSelectedFcn = app.createCallbackFcn(@context_menu_option_selected, true);
            
            app.TransverseSOpt = uimenu(app.VeinMenu);
            app.TransverseSOpt.Text = 'Transverse S';
            app.TransverseSOpt.MenuSelectedFcn = app.createCallbackFcn(@context_menu_option_selected, true);
            
            app.NondominantTransvereSOpt = uimenu(app.VeinMenu);
            app.NondominantTransvereSOpt.Text = 'Non-dominant Transverse S';
            app.NondominantTransvereSOpt.MenuSelectedFcn = app.createCallbackFcn(@context_menu_option_selected, true); 
        end
        
        % create buttons
        function init_done_button(app)
            app.DoneButton = uibutton(app.ChildGridLayout3, 'push');
            app.DoneButton.Layout.Row = 1;
            app.DoneButton.Layout.Column = 2;
            app.DoneButton.Text = 'Done';
            app.DoneButton.FontWeight = 'bold';
            app.DoneButton.ButtonPushedFcn = createCallbackFcn(app, @done_button_pushed, true);
        end
        
        function init_cancel_button(app)
            app.CancelButton = uibutton(app.ChildGridLayout3, 'push');
            app.CancelButton.Layout.Row = 1;
            app.CancelButton.Layout.Column = 1;
            app.CancelButton.Text = 'Cancel';
            app.CancelButton.FontWeight = 'bold';
            app.CancelButton.ButtonPushedFcn = createCallbackFcn(app, @cancel_button_pushed, true);
        end
               
        % create labels
        function init_x_label(app)
            app.XLabel = uilabel(app.ChildGridLayout2);
            app.XLabel.Layout.Row = 1;
            app.XLabel.Layout.Column = 1;
            app.XLabel.Text = 'X: [###]';
        end
        
        function init_y_label(app)
            app.YLabel = uilabel(app.ChildGridLayout2);
            app.YLabel.Layout.Row = 2;
            app.YLabel.Layout.Column = 1;
            app.YLabel.Text = 'Y: [###]';
        end
        
        function init_z_label(app)
            app.ZLabel = uilabel(app.ChildGridLayout2);
            app.ZLabel.Layout.Row = 3;
            app.ZLabel.Layout.Column = 1;
            app.ZLabel.Text = 'Z: [###]';
        end
        
        % create table
        function init_vessel_table(app)
            app.VesselTable = uitable(app.ChildGridLayout1);
            app.VesselTable.Layout.Row = 1;
            app.VesselTable.Layout.Column = 2;
            app.VesselTable.RowName = {};
            addprop(app.VesselTable, 'ActiveIndices');
            app.VesselTable.Tag = 'vesseltable';
            
            % initialize size, data types, and column names
            sz = [0 4];
            names = {'Vessel'; 'X'; 'Y'; 'Z'};
            types = {'string', 'double', 'double', 'double'};
            vesselTable = table('Size', sz, 'VariableTypes', types, 'VariableNames', names);
            app.VesselTable.Data = vesselTable;
            app.VesselTable.CellSelectionCallback = createCallbackFcn(app, @vessel_table_cell_selection, true);
        end
        
    end
    
    % Misc initialization
    methods (Access = private)

        function init_slices(app)
            app.XSlice = floor(size(app.MAGR, 1)/2);
            app.YSlice = floor(size(app.MAGR, 2)/2);
            app.ZSlice = floor(size(app.MAGR, 3)/2);    
        end
        
        function init_mx(app)
            app.XSliceMax = size(app.MAGR, 1);
            app.YSliceMax = size(app.MAGR, 2);
            app.ZSliceMax = size(app.MAGR, 3);
        end
        
        % create sqlite db file to store image values, thus removing the 
        % repeated calculation calls
        function create_tmp_db(app)
            % make sqlite file
            dbfile = fullfile(app.CenterlineToolApp.VIPR.DataDirectory, 'vessel_selection.db');
            conn = sqlite(dbfile, 'create');
            
            % MAGR is square, typically 320x320x320
            cols = sprintf('COL%d', [1:size(app.MAGR, 1)]);
            
            % rm trailing comma
            cols = cols(1:end-1);
            
            % create tables
            query = ['CREATE TABLE sagittal(' cols ');'];
            exec(conn, query);
            
            query = ['CREATE TABLE coronal(' cols ');'];
            exec(conn, query);
            
            query = ['CREATE TABLE axial(' cols ');'];
            exec(conn, query);
            
            % convert to cell array for data insertion
            cols = strsplit(cols);
            
            % calculate data for sagittal image
            data = permute(cat(1, app.MAGR(app.XSlice,:,:), ...
                                   app.MAGG(app.XSlice,:,:), ...
                                   app.MAGB(app.XSlice,:,:)), ...
                                   [3 2 1]);
            insert(conn, 'sagittal', cols, data);
            
            % calculate data for coronal image
            data = permute(cat(2, app.MAGR(:,app.YSlice,:), ...
                                  app.MAGG(:,app.YSlice,:), ...
                                  app.MAGB(:,app.YSlice,:)), ...
                                  [3 1 2]);
            insert(conn, 'coronal', cols, data);
                          
            % calculate data for axial image
            data = cat(3, app.MAGR(:,:,app.ZSlice), ...
                          app.MAGG(:,:,app.ZSlice), ...
                          app.MAGB(:,:,app.ZSlice));
            insert(conn, 'axial', cols, data);
            
        end
        
    end
    
    
    properties
        SagittalData;
        CoronalData;
        AxialData;
    end
    
    % Image creation and interactivity
    methods (Access = private)
        
        % create images
        function img = create_sagittal_image(app)
            app.SagittalData = zeros(320,320,3,app.XSliceMax, 'uint8');
            
            % returns a 320x320x3 array
            for slice = app.AbsLowerBound:app.XSliceMax
                app.XSlice = slice;
                app.SagittalData(:,:,:,slice) = permute(cat(1, app.MAGR(app.XSlice,:,:), ...
                                                               app.MAGG(app.XSlice,:,:), ...
                                                               app.MAGB(app.XSlice,:,:)), ...
                                                               [3 2 1]);
            end
            
            app.init_slices()
            img = app.SagittalData(:, :, :, app.XSlice);
            sz = size(img, 1);
            img = insertText(img, [sz/2 0], 'S', 'BoxColor', 'black', 'BoxOpacity', 1, 'TextColor', 'white', 'AnchorPoint', 'CenterTop');
            img = insertText(img, [sz/2 sz], 'I', 'BoxColor', 'black', 'BoxOpacity', 1, 'TextColor', 'white', 'AnchorPoint', 'CenterBottom');
            img = insertText(img, [5 sz/2], 'L', 'BoxColor', 'black', 'BoxOpacity', 1, 'TextColor', 'white', 'AnchorPoint', 'CenterTop');
            img = insertText(img, [sz-5 sz/2], 'R', 'BoxColor', 'black', 'BoxOpacity', 1, 'TextColor', 'white', 'AnchorPoint', 'CenterTop');
        end

        function img = create_coronal_image(app)
            app.CoronalData = zeros(320,320,3,app.YSliceMax, 'uint8');
            % returns a 320x320x3 array
            for slice = app.AbsLowerBound:app.YSliceMax
                app.YSlice = slice;
                app.CoronalData(:,:,:,slice) = permute(cat(2, app.MAGR(:,app.YSlice,:), ...
                                                                app.MAGG(:,app.YSlice,:), ...
                                                                app.MAGB(:,app.YSlice,:)), ...
                                                                [3 1 2]);
            end
            app.init_slices();
            img = app.CoronalData(:,:,:,app.YSlice);
            sz = size(img, 1);
            img = insertText(img, [sz/2 0], 'S', 'BoxColor', 'black', 'BoxOpacity', 1, 'TextColor', 'white', 'AnchorPoint', 'CenterTop');
            img = insertText(img, [sz/2 sz], 'I', 'BoxColor', 'black', 'BoxOpacity', 1, 'TextColor', 'white', 'AnchorPoint', 'CenterBottom');
            img = insertText(img, [5 sz/2], 'A', 'BoxColor', 'black', 'BoxOpacity', 1, 'TextColor', 'white', 'AnchorPoint', 'CenterTop');
            img = insertText(img, [sz-5 sz/2], 'P', 'BoxColor', 'black', 'BoxOpacity', 1, 'TextColor', 'white', 'AnchorPoint', 'CenterTop');
        end
        
        function img = create_axial_image(app)
            app.AxialData = zeros(320,320,3,app.ZSliceMax, 'uint8');
            % returns a 320x320x3 array
            for slice = app.AbsLowerBound:app.ZSliceMax
                app.ZSlice = slice;
                app.AxialData(:,:,:,slice) = cat(3, app.MAGR(:,:,app.ZSlice), ...
                                                      app.MAGG(:,:,app.ZSlice), ...
                                                      app.MAGB(:,:,app.ZSlice));
            end
            app.init_slices();
            img = app.AxialData(:,:,:,app.ZSlice);
            sz = size(img, 1);
            img = insertText(img, [sz/2 0], 'A', 'BoxColor', 'black', 'BoxOpacity', 1, 'TextColor', 'white', 'AnchorPoint', 'CenterTop');
            img = insertText(img, [sz/2 sz], 'P', 'BoxColor', 'black', 'BoxOpacity', 1, 'TextColor', 'white', 'AnchorPoint', 'CenterBottom');
            img = insertText(img, [5 sz/2], 'L', 'BoxColor', 'black', 'BoxOpacity', 1, 'TextColor', 'white', 'AnchorPoint', 'CenterTop');
            img = insertText(img, [sz-5 sz/2], 'R', 'BoxColor', 'black', 'BoxOpacity', 1, 'TextColor', 'white', 'AnchorPoint', 'CenterTop');
        end
        
        function img = updateSagittalImage(app)
            img = app.SagittalData(:,:,:,app.XSlice);
			img = insertText(img, [sz/2 0], 'S', 'BoxColor', 'black', 'BoxOpacity', 1, 'TextColor', 'white', 'AnchorPoint', 'CenterTop');
            img = insertText(img, [sz/2 sz], 'I', 'BoxColor', 'black', 'BoxOpacity', 1, 'TextColor', 'white', 'AnchorPoint', 'CenterBottom');
            img = insertText(img, [5 sz/2], 'L', 'BoxColor', 'black', 'BoxOpacity', 1, 'TextColor', 'white', 'AnchorPoint', 'CenterTop');
            img = insertText(img, [sz-5 sz/2], 'R', 'BoxColor', 'black', 'BoxOpacity', 1, 'TextColor', 'white', 'AnchorPoint', 'CenterTop');
        end
        
        function img = updateCoronalImage(app)
            img = app.CoronalData(:,:,:,app.YSlice);
			sz = size(img, 1);
            img = insertText(img, [sz/2 0], 'S', 'BoxColor', 'black', 'BoxOpacity', 1, 'TextColor', 'white', 'AnchorPoint', 'CenterTop');
            img = insertText(img, [sz/2 sz], 'I', 'BoxColor', 'black', 'BoxOpacity', 1, 'TextColor', 'white', 'AnchorPoint', 'CenterBottom');
            img = insertText(img, [5 sz/2], 'A', 'BoxColor', 'black', 'BoxOpacity', 1, 'TextColor', 'white', 'AnchorPoint', 'CenterTop');
            img = insertText(img, [sz-5 sz/2], 'P', 'BoxColor', 'black', 'BoxOpacity', 1, 'TextColor', 'white', 'AnchorPoint', 'CenterTop');
        end
        
        function img = updateAxialImage(app)
            img = app.AxialData(:,:,:,app.ZSlice);
			sz = size(img, 1);
            img = insertText(img, [sz/2 0], 'A', 'BoxColor', 'black', 'BoxOpacity', 1, 'TextColor', 'white', 'AnchorPoint', 'CenterTop');
            img = insertText(img, [sz/2 sz], 'P', 'BoxColor', 'black', 'BoxOpacity', 1, 'TextColor', 'white', 'AnchorPoint', 'CenterBottom');
            img = insertText(img, [5 sz/2], 'L', 'BoxColor', 'black', 'BoxOpacity', 1, 'TextColor', 'white', 'AnchorPoint', 'CenterTop');
            img = insertText(img, [sz-5 sz/2], 'R', 'BoxColor', 'black', 'BoxOpacity', 1, 'TextColor', 'white', 'AnchorPoint', 'CenterTop');
        end
        
        
        % create crosshairs
        function create_sagittal_crosshairs(app)
            x_pos = size(app.SagittalImage.CData, 1)/2;
            y_pos = size(app.SagittalImage.CData, 2)/2;
            app.SagittalCrosshairs = drawcrosshair('Parent', app.SagittalAxes, 'Position', [x_pos y_pos], 'LineWidth', 1, 'Color', 'g');
            % TODO: delete contextmenu???
        end
        
        function create_coronal_crosshairs(app)
            x_pos = size(app.CoronalImage.CData, 1)/2;
            y_pos = size(app.CoronalImage.CData, 2)/2;
            app.CoronalCrosshairs = drawcrosshair('Parent', app.CoronalAxes, 'Position', [x_pos y_pos], 'LineWidth', 1, 'Color', 'g');
        end
        
        function create_axial_crosshairs(app)
            x_pos = size(app.AxialImage.CData, 1)/2;
            y_pos = size(app.AxialImage.CData, 2)/2;
            app.AxialCrosshairs = drawcrosshair('Parent', app.AxialAxes, 'Position', [x_pos y_pos], 'LineWidth', 1, 'Color', 'g');
        end
        
        % create crosshair listeners
        function create_sagittal_crosshair_listener(app)
            addlistener(app.SagittalCrosshairs, 'MovingROI', @(src,data)app.move_crosshairs(src, data));
        end
        
        function create_coronoal_crosshair_listener(app)
            addlistener(app.CoronalCrosshairs, 'MovingROI', @(src,data)app.move_crosshairs(src, data));
        end
        
        function create_axial_crosshair_listener(app)
            addlistener(app.AxialCrosshairs, 'MovingROI', @(src,data)app.move_crosshairs(src, data));
        end

    end
    
    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, CenterlineToolApp)
            app.CenterlineToolApp = CenterlineToolApp;
            app.mag_rgb(app.CenterlineToolApp.VIPR.MAG, app.CenterlineToolApp.VIPR.Segment);
            app.init_slices();
            app.init_mx();
            app.update_coordinate_labels();
            
            % create images
            img_ = app.create_sagittal_image();
            app.SagittalImage = imshow(img_, 'Parent', app.SagittalAxes);

            img_ = app.create_coronal_image();
            app.CoronalImage = imshow(img_, 'Parent', app.CoronalAxes);
            
            img_ = app.create_axial_image();
            app.AxialImage = imshow(img_, 'Parent', app.AxialAxes);

            % 'locks' the image to prevent accidental moving
            disableDefaultInteractivity(app.SagittalAxes);
            disableDefaultInteractivity(app.CoronalAxes);
            disableDefaultInteractivity(app.AxialAxes);
            
            % create xhairs
            app.create_sagittal_crosshairs();
            app.create_coronal_crosshairs();
            app.create_axial_crosshairs();
            
            % create xhairs listeners
            app.create_sagittal_crosshair_listener();
            app.create_coronoal_crosshair_listener();
            app.create_axial_crosshair_listener();
            
            % assign context menus to images
            app.SagittalImage.ContextMenu = app.ContextMenu;
            app.CoronalImage.ContextMenu = app.ContextMenu;
            app.AxialImage.ContextMenu = app.ContextMenu;
            
            % load data, if present
            app.load_();
        end

        % Button pushed function: DoneButton
        function done_button_pushed(app, event)
            app.remove_from_struct();
            app.save_();
            app.uifigure_close_request();
        end

        % Button pushed function: CancelButton
        function cancel_button_pushed(app, event)
            app.uifigure_close_request();
        end

        % Cell selection callback: VesselTable
        function vessel_table_cell_selection(app, event)
            indices = event.Indices;
            app.VesselTable.ActiveIndices = indices;
            if indices(2) == 1
                 vesselTable = app.VesselTable.Data;
                 idx = indices(1);
                 app.XSlice = vesselTable.X(idx);
                 app.YSlice = vesselTable.Y(idx);
                 app.ZSlice = vesselTable.Z(idx);
                 app.update_sagittal_image();
                 app.update_coronoal_image();
                 app.update_axial_image();
                 app.update_crosshairs_sagittal();
                 app.update_crosshairs_coronal();
                 app.update_crosshairs_axial();
                 app.update_coordinate_labels();
            end
        end

        % Menu option selection callback: ContextMenu
        function context_menu_option_selected(app, event, varargin)
            if nargin < 3
                vessel = event.Source.Text;
            elseif nargin >= 3
                vessel = varargin{1};
            end 
            fprintf('Segmenting %s...\n', vessel);
            app.set_xyz();
            segmentObj = SegmentVessel(app.CenterlineToolApp.VIPR);
            try
                [branchNumber, branchActual, timeMIPVessel] = segmentObj.main(app.XCoordinate, app.YCoordinate, app.ZCoordinate);
            catch ME
                switch ME.identifier
                    case "SegmentVessel:CheckVessel:Invalid"
                        msg = strcat(ME.message, ": ", vessel);
                        disp(msg);
                        return;
                    case "SegmentVessel:BranchLength:Short"
                        msg = strcat(ME.message, ": ", vessel);
                        disp(msg);
                        return;
                    otherwise
                        rethrow(ME);
                end
            end
            app.add_to_struct(vessel, branchNumber, branchActual, timeMIPVessel);
            vesselTable = app.VesselTable.Data;
            newData = {vessel, app.XCoordinate, app.YCoordinate, app.ZCoordinate};
            % overwrite previous entry, if exists
            if any(ismember(vesselTable.Vessel, vessel))
                vesselTable(ismember(vesselTable.Vessel, vessel), :) = newData;
            else
                vesselTable = [vesselTable; newData];
            end
            app.VesselTable.Data = vesselTable;
            fprintf('Done segmenting %s!\n', vessel);
        end
        
        % Toolbar selection callback
        function toolbar_value_changed(app, event)
            tb = event.Source.Parent.Tag;
            limits = [0 app.CenterlineToolApp.VIPR.Resolution];
            if strcmp(tb, "sagittal_tb")
                app.SagittalAxes.XLim = limits;
                app.SagittalAxes.YLim = limits;
            elseif strcmp(tb, "coronal_tb")
                app.CoronalAxes.XLim = limits;
                app.CoronalAxes.YLim = limits;
            elseif strcmp(tb, "axial_tb")
                app.AxialAxes.XLim = limits;
                app.AxialAxes.YLim = limits;
            end
        end

        % Window key press function: UIFigure
        function uifigure_window_key_press(app, event)
            key = event.Key;
            switch char(event.Modifier)
                case 'control'
                    if strcmpi(event.Key, 'w')
                        app.uifigure_close_request();
                    elseif strcmpi(event.Key, 'space')
                        currentState = app.dcm_obj.Enable;
                        switch currentState
                            case 'on'
                                app.dcm_obj.Enable = 'off';
                            case 'off'
                                app.dcm_obj.Enable = 'on';
                        end
                    end
                case ''
                    if(strcmp(key, 'return'))
                        % app.SelectButtonPushed();
                    elseif(strcmpi(key, 'space'))
                        % make xhairs interactive if the window had lost focuse
                        % a bug with app designer and this is a workaround
                        app.SagittalCrosshairs.Selected = 1;
                        app.CoronalCrosshairs.Selected = 1;
                        app.AxialCrosshairs.Selected = 1;
                    elseif(strcmpi(key, 'escape'))
                        app.UIFigure.WindowState = 'normal';
                    end
            end
            
            switch key
                case 'delete'
                    vesselTable = app.VesselTable.Data;
                    row = app.VesselTable.ActiveIndices(1);
                    vesselTable(row, :) = [];
                    app.VesselTable.Data = vesselTable;
            end
        end

        % Window scroll wheel function: UIFigure
        function uifigure_window_scroll_wheel(app, event)
            verticalScrollAmount = event.VerticalScrollAmount;
            verticalScrollCount = event.VerticalScrollCount;
            %{
            TODO: include scroll fcn to move the xhairs in a more granular
            manner. Need to figure out how to ensure the callback is linked
            to the proper axes where the cursor is hovering (i.e. make the
            fcn only work when the cursor is over an image)
            %}
        end

        % Close request function: UIFigure
        function uifigure_close_request(app, event)
            delete(app);
        end
        
    end
    
    % update callbacks
    methods (Access = private)
        
        function update_sagittal_image(app)
            if app.XSlice > app.XSliceMax
                app.XSlice = app.XSliceMax;
            elseif app.XSlice < app.AbsLowerBound
                app.XSlice = app.AbsLowerBound;
            else
                img = app.updateSagittalImage();
                set(app.SagittalImage, 'CData', img);
            end
        end
        
        function update_coronoal_image(app)
            if app.YSlice > app.YSliceMax
                app.YSlice = app.YSliceMax;
            elseif app.YSlice < app.AbsLowerBound
                app.YSlice = app.AbsLowerBound;
            else
                img = app.updateCoronalImage();
                set(app.CoronalImage, 'CData', img);
            end
        end
        
        function update_axial_image(app)
            if app.ZSlice > app.ZSliceMax
                app.ZSlice = app.ZSliceMax;
            elseif app.ZSlice < app.AbsLowerBound
                app.ZSlice = app.AbsLowerBound;
            else
                img = app.updateAxialImage();
                set(app.AxialImage, 'CData', img);
            end
        end
                
        function update_crosshairs_sagittal(app)
            app.SagittalCrosshairs.Position = [app.YSlice app.ZSlice];
        end
        
        function update_crosshairs_coronal(app)
            app.CoronalCrosshairs.Position = [app.XSlice app.ZSlice];
        end
        
        function update_crosshairs_axial(app)
            app.AxialCrosshairs.Position = [app.YSlice app.XSlice];
        end
    
        function update_table(app)
            vesselTable = app.VesselTable.Data;
            vessel = app.ListBox.Value;
            app.set_xyz();
            newData = {vessel, app.XCoordinate, app.YCoordinate, app.ZCoordinate};
            idx = vesselTable.Vessel == string(vessel);
            vesselTable(idx, :) = [];
            vesselTable = [vesselTable; newData];
            app.VesselTable.Data = vesselTable;
        end
        
        function update_coordinate_labels(app)
            app.XLabel.Text = ['X: ' num2str(app.XSlice)];
            app.YLabel.Text = ['Y: ' num2str(app.YSlice)];
            app.ZLabel.Text = ['Z: ' num2str(app.ZSlice)];
        end
 
    end
    
    % listener callbacks
    methods (Access = private)
        
        function move_crosshairs(app, src, data)
            if src.Parent.Tag == "SagittalAxes"
                % XCoordinate movement on the image = YCoordinate movement for the orientation
                % YCoordinate movement on the image = ZCoordinate movement for the orientation
                pos = ceil(data.CurrentPosition);
                app.YSlice = pos(1);
                app.ZSlice = pos(2);
                
                app.update_crosshairs_coronal();
                app.update_crosshairs_axial();
                
                app.update_coronoal_image();
                app.update_axial_image();
                
            elseif src.Parent.Tag == "CoronalAxes"
                % XCoordinate movement on the image = XCoordinate movement for the orientation
                % YCoordinate movement on the image = ZCoordinate movement for the orientation
                pos = ceil(data.CurrentPosition);
                app.XSlice = round(pos(1));
                app.ZSlice = round(pos(2));
                
                app.update_crosshairs_sagittal();
                app.update_crosshairs_axial();
                
                app.update_sagittal_image();
                app.update_axial_image();
                
            elseif src.Parent.Tag == "AxialAxes"
                % XCoordinate movement on the image = YCoordinate movement for the orientation
                % YCoordinate movement on the image = XCoordinate movement for the orientation
                pos = ceil(data.CurrentPosition);
                app.YSlice = round(pos(1));
                app.XSlice = round(pos(2));
                
                app.update_crosshairs_coronal();
                app.update_crosshairs_sagittal();
                
                app.update_coronoal_image();
                app.update_sagittal_image();
            end
            app.update_coordinate_labels();
        end
        
        function wheel(app, ~, evnt)
            %{
            scrolling down -> scrollCount > 0 -> move in negative direction on axis
            scrolling up -> scrollCount < 0 -> move in positive direction on axis
            %}
            cur = get(gcf, 'Name');
            switch cur
                case 'Sagittal'
                    if evnt.VerticalScrollCount > 0
                        app.XSlice = app.XSlice + 1;
                    else
                        app.XSlice = app.XSlice - 1;
                    end
                    app.update_sagittal_image();
                    app.update_crosshairs_coronal();
                    app.update_crosshairs_axial();
                    
                case 'Coronal'
                    if evnt.VerticalScrollCount > 0
                        app.YSlice = app.YSlice + 1;
                    else
                        app.YSlice = app.YSlice - 1;
                    end
                    app.update_coronoal_image();
                    app.update_crosshairs_sagittal();
                    app.update_crosshairs_axial();
                
                case 'Axial'
                    if evnt.VerticalScrollCount > 0
                        app.ZSlice = app.ZSlice + 1;
                    else
                        app.ZSlice = app.ZSlice - 1;
                    end
                    app.update_axial_image();
                    app.update_crosshairs_sagittal();
                    app.update_crosshairs_coronal();
                otherwise
                    % do nothing
            end
        end
        
    end
    
    % general functions
    methods (Access = private)
    
        function set_xyz(app)
            %{
            original code said XCoordinate and YCoordinate were switched (i.e. XCoordinate = Position(2))
            and XCoordinate = res - Position(2)
            TODO: ensure the XCoordinate and YCoordinate are the same as the old method
            %}
%             app.XCoordinate = app.CenterlineToolApp.VIPR.Resolution - app.YSlice;
%             app.YCoordinate = app.XSlice;
%             app.ZCoordinate = app.ZSlice;

            app.XCoordinate = app.XSlice;
            app.YCoordinate = app.YSlice;
            app.ZCoordinate = app.ZSlice;
        end
        
        function add_to_struct(app, vessel, branchNumber, branchActual, timeMIPVessel)
            vessel = regexprep(vessel, '\W', '');
            % important so that it deletes any previous data associated
            % with the vessel
            app.CenterlineToolApp.VIPR.Vessel.(vessel) = struct;
            app.CenterlineToolApp.VIPR.Vessel.(vessel).XCoordinate = app.XCoordinate;
            app.CenterlineToolApp.VIPR.Vessel.(vessel).YCoordinate = app.YCoordinate;
            app.CenterlineToolApp.VIPR.Vessel.(vessel).ZCoordinate = app.ZCoordinate;
            app.CenterlineToolApp.VIPR.Vessel.(vessel).BranchNumber = branchNumber;
            app.CenterlineToolApp.VIPR.Vessel.(vessel).BranchActual = branchActual;
            app.CenterlineToolApp.VIPR.Vessel.(vessel).TimeMIPVessel = timeMIPVessel;
        end
        
        function remove_from_struct(app)
            % check if any vessels were even selected
            if ~isfield(app.CenterlineToolApp.VIPR, 'Vessel')
                return;
            end
            
            % get vessels in table
            vesselTable = app.VesselTable.Data;
            vesselTableNames = vesselTable.Vessel;
            vesselTableNames = regexprep(vesselTableNames, '\W', '');
            
            % get vessels in struct
            structNames = fieldnames(app.CenterlineToolApp.VIPR.Vessel);
            
            % compare the lists, remove from struct any vessels not in
            % table
            toRemove = setdiff(structNames, vesselTableNames);
            
            for k = 1:numel(toRemove)
                app.CenterlineToolApp.VIPR.Vessel = rmfield(app.CenterlineToolApp.VIPR.Vessel, toRemove{k});
            end
            
        end

    end
    
    % custom save method
    methods (Access = private)
        
        function save_(app)
            %{
            app designer objects cannot utilize 'saveobj' and 'loadoabj'
            properly
            this is a workaround to that to save only necessary data that,
            when combined with the required input arg to the app, will
            restore the previous state
            %}
            disp("Saving vessel selection parameters...");
            directory = fullfile(app.CenterlineToolApp.VIPR.DataDirectory, 'saved_analysis');
            if ~exist(directory, 'dir')
                mkdir(directory);
            end
            fname = 'vessel_coordinates.txt';
            vesselTable = app.VesselTable.Data;
            writetable(vesselTable, fullfile(directory, fname));
        end
        
    end

    % custom load method
    methods (Access = private)
        
        function load_(app)
            %{
            app designer objects cannot utilize 'saveobj' and 'loadoabj'
            properly
            this is a workaround to that to load previously saved data that,
            when combined with the required input arg to the app, will
            restore the previous state
            %}
            directory = fullfile(app.CenterlineToolApp.VIPR.DataDirectory, 'analysis');
            fname = 'vessel_coordinates.txt';
            
            if exist(fullfile(directory, fname), 'file')
                vesselTable = readtable(fullfile(directory, fname));
                if ~isempty(vesselTable)
                    for k = 1:size(vesselTable, 1)
                        vessel = string(vesselTable.Vessel(k,1));
                        app.XSlice = vesselTable.X(k,1);
                        app.YSlice = vesselTable.Y(k,1);
                        app.ZSlice = vesselTable.Z(k,1);
                        app.context_menu_option_selected([], vessel);
                    end
                end
                app.VesselTable.Data = vesselTable;
            end
        end
        
    end
    
end