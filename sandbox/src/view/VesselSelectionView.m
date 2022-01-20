classdef VesselSelectionView < matlab.apps.AppBase

    % todo: move to model
    properties
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
    
    % figure layout properties
    properties (Access = private)
        UIFigure                           matlab.ui.Figure
        ParentGrid                         matlab.ui.container.GridLayout
        ChildGrid1                         matlab.ui.container.GridLayout
        ChildGrid2                         matlab.ui.container.GridLayout
        ChildGrid3                         matlab.ui.container.GridLayout
    end
    
    % table
    properties (Access = public)
        VesselTable                        matlab.ui.control.Table
    end
    
    % push buttons
    properties (Access = private)
        DoneButton                         matlab.ui.control.Button
    end
    
    % axes and related objects
    properties (Access = public)
        SagittalAxes                       matlab.ui.control.UIAxes
        CoronalAxes                        matlab.ui.control.UIAxes
        AxialAxes                          matlab.ui.control.UIAxes
        SagittalAxesToolbar;
        CoronalAxesToolbar;
        AxialAxesToolbar;
        SagittalCrosshairs;
        CoronalCrosshairs;
        AxialCrosshairs;
    end
    
    % labels
    properties (Access = public)
        XLabel                             matlab.ui.control.Label
        YLabel                             matlab.ui.control.Label
        ZLabel                             matlab.ui.control.Label
    end
    
    % menus and menu buttons
    properties (Access = private)
        ContextMenu                        matlab.ui.container.ContextMenu
        ArteryMenu                         matlab.ui.container.Menu
        VeinMenu                           matlab.ui.container.Menu
        LeftICAMenuButton                  matlab.ui.container.Menu
        RightICAMenuButton                 matlab.ui.container.Menu
        LeftMCAMenuButton                  matlab.ui.container.Menu
        RightMCAMenuButton                 matlab.ui.container.Menu
        LeftACAMenuButton                  matlab.ui.container.Menu
        RightACAMenuButton                 matlab.ui.container.Menu
        LeftPCAMenuButton                  matlab.ui.container.Menu
        RightPCAMenuButton                 matlab.ui.container.Menu
        BasilarAMenuButton                 matlab.ui.container.Menu
        LeftVAMenuButton                   matlab.ui.container.Menu
        RightVAMenuButton                  matlab.ui.container.Menu
        SuperiorSagittalSMenuButton        matlab.ui.container.Menu
        StraightSMenuButton                matlab.ui.container.Menu
        TransverseSMenuButton              matlab.ui.container.Menu
        NondominantTransvereSMenuButton    matlab.ui.container.Menu
    end
    
    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = VesselSelectionView(controller)
            app.UIFigure = controller.View.UIFigure;
            app.createComponents(controller);
        end
   
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app, controller)
            % grids
            app.createParentGrid();
            app.createChildGrid1();
            app.createChildGrid2();
            app.createChildGrid3();
            
            % axes
            app.createSagittalAxes();
            app.createCoronalAxes();
            app.createAxialAxes();
            
            % toolbars
            % todo: the toolbars don't seem to be assigned to the axes
            app.createSagittalToolbar(controller);
            app.createCoronalToolbar(controller);
            app.createAxialToolbar(controller);
            
            % context menu and buttons
            app.createContextMenu();
            app.createLeftICAMenuButton(controller);
            app.createRightICAMenuButton(controller);
            app.createLeftMCAMenuButton(controller);
            app.createRightMCAMenuButton(controller);
            app.createLeftACAMenuButton(controller);
            app.createRightACAMenuButton(controller);
            app.createLeftPCAMenuButton(controller);
            app.createRightPCAMenuButton(controller);
            app.createLeftVAMenuButton(controller);
            app.createRightVAMenuButton(controller);
            app.createBasilarAMenuButton(controller);
            app.createSuperiorSagittalSMenuButton(controller);
            app.createStraightSMenuButton(controller);
            app.createTransverseSMenuButton(controller);
            app.createNondominantTransvereSMenuButton(controller);
            
            % push buttons
            app.createDoneButton(controller);
            
            % labels
            app.createXLabel();
            app.createYLabel();
            app.createZLabel();
            
            % table
            app.createVesselTable(controller);
            
            % make objects visible after creation
            app.SagittalAxes.Visible = 'on';
            app.CoronalAxes.Visible = 'on';
            app.AxialAxes.Visible = 'on';
            app.DoneButton.Visible = 'on';
            app.XLabel.Visible = 'on';
            app.YLabel.Visible = 'on';
            app.ZLabel.Visible = 'on';
            app.VesselTable.Visible = 'on';
        end

        % create grids
        function createParentGrid(app)
            app.ParentGrid = uigridlayout(app.UIFigure);
            app.ParentGrid.RowHeight = {'4x', '4x', '1x'};
        end
        
        function createChildGrid1(app)
            app.ChildGrid1 = uigridlayout(app.ParentGrid);
            app.ChildGrid1.Layout.Row = 2;
            app.ChildGrid1.Layout.Column = 2;
            app.ChildGrid1.ColumnWidth = {'1x', '4x'};
            app.ChildGrid1.RowHeight = {'1x'};
        end
        
        function createChildGrid2(app)
            app.ChildGrid2 = uigridlayout(app.ChildGrid1);
            app.ChildGrid2.Layout.Row = 1;
            app.ChildGrid2.Layout.Column = 1;
            app.ChildGrid2.ColumnWidth = {'1x'};
            app.ChildGrid2.RowHeight = {'1x', '1x', '1x'};
        end
        
        function createChildGrid3(app)
            app.ChildGrid3 = uigridlayout(app.ParentGrid);
            app.ChildGrid3.Layout.Row = 3;
            app.ChildGrid3.Layout.Column = 2;
            app.ChildGrid3.RowHeight = {'1x'};
        end
        
        % create axes
        function createSagittalAxes(app)
            app.SagittalAxes = uiaxes(app.ParentGrid);
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
            app.SagittalAxes.Visible = 'off';
        end
        
        function createCoronalAxes(app)
            app.CoronalAxes = uiaxes(app.ParentGrid);
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
            app.CoronalAxes.Visible = 'off';
        end
        
        function createAxialAxes(app)
            app.AxialAxes = uiaxes(app.ParentGrid);
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
            app.AxialAxes.Visible = 'off';
        end
        
        % create custom toolbars
        function createSagittalToolbar(app, controller)
            app.SagittalAxesToolbar = axtoolbar(app.SagittalAxes, {'zoomin', 'zoomout', 'export', 'datacursor'});
            app.SagittalAxesToolbar.Tag = 'sagittal_tb';
            sagittal_btn = axtoolbarbtn(app.SagittalAxesToolbar, 'push');
            sagittal_btn.Icon = 'restoreview';
            sagittal_btn.ButtonPushedFcn = createCallbackFcn(app, @controller.vsToolbarValueChanged, true);
        end
        
        function createCoronalToolbar(app, controller)
            app.CoronalAxesToolbar = axtoolbar(app.CoronalAxes, {'zoomin', 'zoomout', 'export', 'datacursor'});
            app.CoronalAxesToolbar.Tag = 'coronal_tb';
            coronal_btn = axtoolbarbtn(app.CoronalAxesToolbar, 'push');
            coronal_btn.Icon = 'restoreview';
            coronal_btn.ButtonPushedFcn = createCallbackFcn(app, @controller.vsToolbarValueChanged, true);
        end
        
        function createAxialToolbar(app, controller)
            app.AxialAxesToolbar = axtoolbar(app.AxialAxes, {'zoomin', 'zoomout', 'export', 'datacursor'});
            app.AxialAxesToolbar.Tag = 'axial_tb';
            axial_btn = axtoolbarbtn(app.AxialAxesToolbar, 'push');
            axial_btn.Icon = 'restoreview';
            axial_btn.ButtonPushedFcn = createCallbackFcn(app, @controller.vsToolbarValueChanged, true);
        end
        
        % create context menu
        function createContextMenu(app)
            app.ContextMenu = uicontextmenu(app.UIFigure);
            app.ArteryMenu = uimenu(app.ContextMenu);
            app.ArteryMenu.Text = 'Artery';
            app.VeinMenu = uimenu(app.ContextMenu);
            app.VeinMenu.Text = 'Vein';
        end
        
        function createLeftICAMenuButton(app, controller)
            app.LeftICAMenuButton = uimenu(app.ArteryMenu);
            app.LeftICAMenuButton.Text = 'Left ICA';
            app.LeftICAMenuButton.MenuSelectedFcn = app.createCallbackFcn(@controller.vsContextMenuOptionSelected, true);
        end
        
        function createRightICAMenuButton(app, controller) 
            app.RightICAMenuButton = uimenu(app.ArteryMenu);
            app.RightICAMenuButton.Text = 'Right ICA';
            app.RightICAMenuButton.MenuSelectedFcn = app.createCallbackFcn(@controller.vsContextMenuOptionSelected, true);
        end
        
        function createLeftMCAMenuButton(app, controller)
            app.LeftMCAMenuButton = uimenu(app.ArteryMenu);
            app.LeftMCAMenuButton.Text = 'Left MCA';
            app.LeftMCAMenuButton.MenuSelectedFcn = app.createCallbackFcn(@controller.vsContextMenuOptionSelected, true);
        end
        
        function createRightMCAMenuButton(app, controller)
            app.RightMCAMenuButton = uimenu(app.ArteryMenu);
            app.RightMCAMenuButton.Text = 'Right MCA';
            app.RightMCAMenuButton.MenuSelectedFcn = app.createCallbackFcn(@controller.vsContextMenuOptionSelected, true);
        end
        
        function createLeftACAMenuButton(app, controller)
            app.LeftACAMenuButton = uimenu(app.ArteryMenu);
            app.LeftACAMenuButton.Text = 'Left ACA';
            app.LeftACAMenuButton.MenuSelectedFcn = app.createCallbackFcn(@controller.vsContextMenuOptionSelected, true);
        end
        
        function createRightACAMenuButton(app, controller)
            app.RightACAMenuButton = uimenu(app.ArteryMenu);
            app.RightACAMenuButton.Text = 'Right ACA';
            app.RightACAMenuButton.MenuSelectedFcn = app.createCallbackFcn(@controller.vsContextMenuOptionSelected, true);
        end
        
        function createLeftPCAMenuButton(app, controller)
            app.LeftPCAMenuButton = uimenu(app.ArteryMenu);
            app.LeftPCAMenuButton.Text = 'Left PCA';
            app.LeftPCAMenuButton.MenuSelectedFcn = app.createCallbackFcn(@controller.vsContextMenuOptionSelected, true);
        end
        
        function createRightPCAMenuButton(app, controller)
            app.RightPCAMenuButton = uimenu(app.ArteryMenu);
            app.RightPCAMenuButton.Text = 'Right PCA';
            app.RightPCAMenuButton.MenuSelectedFcn = app.createCallbackFcn(@controller.vsContextMenuOptionSelected, true);
        end
        
        function createLeftVAMenuButton(app, controller)
            app.LeftVAMenuButton = uimenu(app.ArteryMenu);
            app.LeftVAMenuButton.Text = 'Left VA';
            app.LeftVAMenuButton.MenuSelectedFcn = app.createCallbackFcn(@controller.vsContextMenuOptionSelected, true);
        end
        
        function createRightVAMenuButton(app, controller)
            app.RightVAMenuButton = uimenu(app.ArteryMenu);
            app.RightVAMenuButton.Text = 'Right VA';
            app.RightVAMenuButton.MenuSelectedFcn = app.createCallbackFcn(@controller.vsContextMenuOptionSelected, true);
        end
        
        function createBasilarAMenuButton(app, controller)
            app.BasilarAMenuButton = uimenu(app.ArteryMenu);
            app.BasilarAMenuButton.Text = 'Basilar A';
            app.BasilarAMenuButton.MenuSelectedFcn = app.createCallbackFcn(@controller.vsContextMenuOptionSelected, true);
        end
        
        function createSuperiorSagittalSMenuButton(app, controller)
            app.SuperiorSagittalSMenuButton = uimenu(app.VeinMenu);
            app.SuperiorSagittalSMenuButton.Text = 'Superior Sagittal S';
            app.SuperiorSagittalSMenuButton.MenuSelectedFcn = app.createCallbackFcn(@controller.vsContextMenuOptionSelected, true);
        end
        
        function createStraightSMenuButton(app, controller)
            app.StraightSMenuButton = uimenu(app.VeinMenu);
            app.StraightSMenuButton.Text = 'Straight S';
            app.StraightSMenuButton.MenuSelectedFcn = app.createCallbackFcn(@controller.vsContextMenuOptionSelected, true);
        end
        
        function createTransverseSMenuButton(app, controller)
            app.TransverseSMenuButton = uimenu(app.VeinMenu);
            app.TransverseSMenuButton.Text = 'Transverse S';
            app.TransverseSMenuButton.MenuSelectedFcn = app.createCallbackFcn(@controller.vsContextMenuOptionSelected, true);
        end
        
        function createNondominantTransvereSMenuButton(app, controller)
            app.NondominantTransvereSMenuButton = uimenu(app.VeinMenu);
            app.NondominantTransvereSMenuButton.Text = 'Non-dominant Transverse S';
            app.NondominantTransvereSMenuButton.MenuSelectedFcn = app.createCallbackFcn(@controller.vsContextMenuOptionSelected, true); 
        end
        
        % create buttons
        function createDoneButton(app, controller)
            app.DoneButton = uibutton(app.ChildGrid3, 'push');
            app.DoneButton.Layout.Row = 1;
            app.DoneButton.Layout.Column = 2;
            app.DoneButton.Text = 'Done';
            app.DoneButton.FontWeight = 'bold';
            app.DoneButton.ButtonPushedFcn = createCallbackFcn(app, @controller.vsDoneButtonPushed, true);
            app.DoneButton.Visible = 'off';
        end
                      
        % create labels
        function createXLabel(app)
            app.XLabel = uilabel(app.ChildGrid2);
            app.XLabel.Layout.Row = 1;
            app.XLabel.Layout.Column = 1;
            app.XLabel.Text = 'X: [###]';
            app.XLabel.Visible = 'off';
        end
        
        function createYLabel(app)
            app.YLabel = uilabel(app.ChildGrid2);
            app.YLabel.Layout.Row = 2;
            app.YLabel.Layout.Column = 1;
            app.YLabel.Text = 'Y: [###]';
            app.YLabel.Visible = 'off';
        end
        
        function createZLabel(app)
            app.ZLabel = uilabel(app.ChildGrid2);
            app.ZLabel.Layout.Row = 3;
            app.ZLabel.Layout.Column = 1;
            app.ZLabel.Text = 'Z: [###]';
            app.ZLabel.Visible = 'off';
        end
        
        % create table
        function createVesselTable(app, controller)
            app.VesselTable = uitable(app.ChildGrid1);
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
            app.VesselTable.CellSelectionCallback = createCallbackFcn(app, @controller.vsVesselTableCellSelection, true);
            app.VesselTable.Visible = 'off';
        end
        
    end
    
    % getters
    
    % setters
    
end