classdef ParameterPlotView < matlab.apps.AppBase

    % layout
    properties (Access = private)
        UIFigure    matlab.ui.Figure;
        ParentGrid  matlab.ui.container.GridLayout;
        ChildGrid1  matlab.ui.container.GridLayout;
        ChildGrid2  matlab.ui.container.GridLayout;
        ChildGrid3  matlab.ui.container.GridLayout;
    end
    
    % axes
    properties (Access = private)
        AreaAxes                matlab.ui.control.UIAxes;
        DiameterAxes            matlab.ui.control.UIAxes;
        MeanVelocityAxes        matlab.ui.control.UIAxes;
        MaxVelocityAxes         matlab.ui.control.UIAxes;
        FlowPerBeatAxes         matlab.ui.control.UIAxes;
        WallShearStressAxes     matlab.ui.control.UIAxes;
        PulsatilityIndexAxes    matlab.ui.control.UIAxes;
        TimeResolvedAxes        matlab.ui.control.UIAxes;
    end
    
    % labels
    properties (Access = private)
        LowerVoxelLabel     matlab.ui.control.Label;
        WindowLabel         matlab.ui.control.Label;
        SaveDataStartLabel  matlab.ui.control.Label;
        SaveDataEndLabel    matlab.ui.control.Label;
    end
    
    % spinners
    properties (Access = protected)
        LowerVoxelSpinner       matlab.ui.control.Spinner;
        WindowSpinner           matlab.ui.control.Spinner;
        SaveDataStartSpinner    matlab.ui.control.Spinner;
        SaveDataEndSpinner      matlab.ui.control.Spinner;
    end
    
    % buttons
    properties (Access = private)
        SaveButton  matlab.ui.control.Button;
    end
    
    % misc properties
    properties (Access = private)
        DataTable   matlab.ui.control.Table;
        Legend;
        
        % todo: move to model
        % CurrentVessel;
    end
    
    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = ParameterPlotView(controller)
            app.UIFigure = controller.View.UIFigure;
            app.createComponents(controller);
        end
        
    end
    
    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app, controller)
            % layout
            app.createGridParent();
            app.createGridChild1();
            app.createGridChild2();
            app.createGridChild3();
            
            % axes
            app.createAxesArea();
            app.createAxesDiameter();
            app.createAxesMeanVelocity();
            app.createAxesMaxVelocity();
            app.createAxesFlowPerBeat();
            app.createAxesPulsatilityIndex();
            app.createAxesWallShearStress();
            app.createAxesTimeResolved();
            
            
            % labels
            app.createLabelLowerVoxel();
            app.createLabelWindow();
            app.createLabelSaveDataStart();
            app.createLabelSaveDataEnd();
            
            % spinners
            app.createSpinnerLowerVoxel(controller);
            app.createSpinnerWindow(controller);
            app.createSpinnerSaveDataStart(controller);
            app.createSpinnerSaveDataEnd(controller);
            
            % buttons
            app.createButtonSave(controller);
            
            % misc
            app.createLegend();
            app.createTableData();
            
            % show objects after creation
            app.ParentGrid.Visible = 'on';
            app.ChildGrid1.Visible = 'on';
            app.ChildGrid2.Visible = 'on';
            app.ChildGrid3.Visible = 'on';
            app.AreaAxes.Visible = 'on';
            app.DiameterAxes.Visible = 'on';
            app.MeanVelocityAxes.Visible = 'on';
            app.MaxVelocityAxes.Visible = 'on';
            app.FlowPerBeatAxes.Visible = 'on';
            app.WallShearStressAxes.Visible = 'on';
            app.PulsatilityIndexAxes.Visible = 'on';
            app.TimeResolvedAxes.Visible = 'on';
            app.LowerVoxelLabel.Visible = 'on';
            app.WindowLabel.Visible = 'on';
            app.SaveDataStartLabel.Visible = 'on';
            app.SaveDataEndLabel.Visible = 'on';
            app.LowerVoxelSpinner.Visible = 'on';
            app.WindowSpinner.Visible = 'on';
            app.SaveDataStartSpinner.Visible = 'on';
            app.SaveDataEndSpinner.Visible = 'on';
            app.SaveButton.Visible = 'on';
            app.DataTable.Visible = 'on';
            app.Legend.Visible = 'on';
        end

        function createGridParent(app)
            app.ParentGrid = uigridlayout(app.UIFigure, 'Visible', 'off');
            app.ParentGrid.ColumnWidth = {'1x'};
            app.ParentGrid.RowHeight = {'5x', '1x'};
        end
        
        function createGridChild1(app)
            app.ChildGrid1 = uigridlayout(app.ParentGrid, 'Visible', 'off');
            app.ChildGrid1.RowHeight = {'1x', '1x', '1x', '1x'};
            app.ChildGrid1.Layout.Row = 1;
            app.ChildGrid1.Layout.Column = 1;
        end
             
        function createGridChild2(app)
            app.ChildGrid2 = uigridlayout(app.ParentGrid, 'Visible', 'off');
            app.ChildGrid2.RowHeight = {'1x'};
            app.ChildGrid2.Layout.Row = 2;
            app.ChildGrid2.Layout.Column = 1;
        end
        
        function createGridChild3(app)
            app.ChildGrid3 = uigridlayout(app.ChildGrid2, 'Visible', 'off');
            app.ChildGrid3.ColumnWidth = {'1x', '1x', '1x', '1x'};
            app.ChildGrid3.RowHeight = {'1x', '1x', '1x'};
            app.ChildGrid3.Layout.Row = 1;
            app.ChildGrid3.Layout.Column = 2;
        end
        
        function createAxesArea(app)
            app.AreaAxes = uiaxes(app.ChildGrid1, 'Visible', 'off');
            title(app.AreaAxes, 'Area')
            xlabel(app.AreaAxes, 'Centerline Point')
            ylabel(app.AreaAxes, 'cm^2')
            app.AreaAxes.Layout.Row = 1;
            app.AreaAxes.Layout.Column = 1;
        end
        
        function createAxesDiameter(app)
            app.DiameterAxes = uiaxes(app.ChildGrid1, 'Visible', 'off');
            title(app.DiameterAxes, 'Diameter')
            xlabel(app.DiameterAxes, 'Centerline Point')
            ylabel(app.DiameterAxes, 'cm')
            app.DiameterAxes.Layout.Row = 2;
            app.DiameterAxes.Layout.Column = 1;
        end
        
        function createAxesMeanVelocity(app)
            app.MeanVelocityAxes = uiaxes(app.ChildGrid1, 'Visible', 'off');
            title(app.MeanVelocityAxes, 'Mean Velocity')
            xlabel(app.MeanVelocityAxes, 'Centerline Point')
            ylabel(app.MeanVelocityAxes, 'cm/s')
            app.MeanVelocityAxes.Layout.Row = 3;
            app.MeanVelocityAxes.Layout.Column = 1;
        end
        
        function createAxesMaxVelocity(app)
            app.MaxVelocityAxes = uiaxes(app.ChildGrid1, 'Visible', 'off');
            title(app.MaxVelocityAxes, 'Max Velocity')
            xlabel(app.MaxVelocityAxes, 'Centerline Point')
            ylabel(app.MaxVelocityAxes, 'cm/s')
            app.MaxVelocityAxes.Layout.Row = 4;
            app.MaxVelocityAxes.Layout.Column = 1;
        end
        
        function createAxesFlowPerBeat(app)
            app.FlowPerBeatAxes = uiaxes(app.ChildGrid1, 'Visible', 'off');
            title(app.FlowPerBeatAxes, 'Mean Volumetric Flow Rate')
            xlabel(app.FlowPerBeatAxes, 'Centerline Point')
            ylabel(app.FlowPerBeatAxes, 'mL/s')
            app.FlowPerBeatAxes.Layout.Row = 1;
            app.FlowPerBeatAxes.Layout.Column = 2;
        end
        
        function createAxesPulsatilityIndex(app)
            app.PulsatilityIndexAxes = uiaxes(app.ChildGrid1, 'Visible', 'off');
            title(app.PulsatilityIndexAxes, 'Pulsatility Index')
            xlabel(app.PulsatilityIndexAxes, 'Centerline Point')
            ylabel(app.PulsatilityIndexAxes, 'a.u.')
            app.PulsatilityIndexAxes.Layout.Row = 2;
            app.PulsatilityIndexAxes.Layout.Column = 2;
        end
        
        function createAxesWallShearStress(app)
            app.WallShearStressAxes = uiaxes(app.ChildGrid1, 'Visible', 'off');
            title(app.WallShearStressAxes, 'Wall Shear Stress')
            xlabel(app.WallShearStressAxes, 'Centerline Point')
            ylabel(app.WallShearStressAxes, 'Pa')
            app.WallShearStressAxes.Layout.Row = 3;
            app.WallShearStressAxes.Layout.Column = 2;
        end
        
        function createAxesTimeResolved(app)
            app.TimeResolvedAxes = uiaxes(app.ChildGrid1, 'Visible', 'off');
            title(app.TimeResolvedAxes, 'Time Resolved Flow')
            xlabel(app.TimeResolvedAxes, 'Centerline Point')
            ylabel(app.TimeResolvedAxes, 'Flow (mL/s)')
            app.TimeResolvedAxes.Layout.Row = 4;
            app.TimeResolvedAxes.Layout.Column = 2;    
        end
        
        function createTableData(app)
            app.DataTable = uitable(app.ChildGrid2, 'Visible', 'off');
            app.DataTable.ColumnName = {'Parameter'; 'Mean'; 'CoV'};
            app.DataTable.Layout.Row = 1;
            app.DataTable.Layout.Column = 1;
        end
        
        function createLabelLowerVoxel(app)
            app.LowerVoxelLabel = uilabel(app.ChildGrid3, 'Visible', 'off');
            app.LowerVoxelLabel.HorizontalAlignment = 'right';
            app.LowerVoxelLabel.Layout.Row = 1;
            app.LowerVoxelLabel.Layout.Column = 3;
            app.LowerVoxelLabel.Text = 'Lower Voxel';
        end
        
        function createLabelWindow(app)
            app.WindowLabel = uilabel(app.ChildGrid3, 'Visible', 'off');
            app.WindowLabel.HorizontalAlignment = 'right';
            app.WindowLabel.Layout.Row = 2;
            app.WindowLabel.Layout.Column = 3;
            app.WindowLabel.Text = 'Window';
        end
        
        function createLabelSaveDataStart(app)
            app.SaveDataStartLabel = uilabel(app.ChildGrid3, 'Visible', 'off');
            app.SaveDataStartLabel.HorizontalAlignment = 'right';
            app.SaveDataStartLabel.Layout.Row = 1;
            app.SaveDataStartLabel.Layout.Column = 1;
            app.SaveDataStartLabel.Text = 'Save Voxel: Start';
        end
        
        function createLabelSaveDataEnd(app)
            app.SaveDataEndLabel = uilabel(app.ChildGrid3, 'Visible', 'off');
            app.SaveDataEndLabel.HorizontalAlignment = 'right';
            app.SaveDataEndLabel.Layout.Row = 2;
            app.SaveDataEndLabel.Layout.Column = 1;
            app.SaveDataEndLabel.Text = 'Save Voxel: End';
        end
        
        function createSpinnerLowerVoxel(app, controller)
            app.LowerVoxelSpinner = uispinner(app.ChildGrid3, 'Visible', 'off');
            app.LowerVoxelSpinner.Layout.Row = 1;
            app.LowerVoxelSpinner.Layout.Column = 4;
            app.LowerVoxelSpinner.Limits = [1 100];
            app.LowerVoxelSpinner.Step = 1;
            app.LowerVoxelSpinner.Value = 1;
            app.LowerVoxelSpinner.ValueChangedFcn = app.createCallbackFcn(@controller.ppLowerVoxelSpinnerValueChanged, true);
        end
        
        function createSpinnerWindow(app, controller)
            app.WindowSpinner = uispinner(app.ChildGrid3, 'Visible', 'off');
            app.WindowSpinner.Layout.Row = 2;
            app.WindowSpinner.Layout.Column = 4;
            app.WindowSpinner.Limits = [1 100];
            app.WindowSpinner.Step = 1;
            app.WindowSpinner.Value = 5;
            app.WindowSpinner.ValueChangedFcn = app.createCallbackFcn(@controller.ppWindowSpinnerValueChanged, true);
        end
        
        function createSpinnerSaveDataStart(app, controller)
            app.SaveDataStartSpinner = uispinner(app.ChildGrid3, 'Visible', 'off');
            app.SaveDataStartSpinner.Layout.Row = 1;
            app.SaveDataStartSpinner.Layout.Column = 2;
            app.SaveDataStartSpinner.ValueChangedFcn = app.createCallbackFcn(@controller.ppSpinnerSaveDataStartValueChanged, true);
        end
        
        function createSpinnerSaveDataEnd(app, controller)
            app.SaveDataEndSpinner = uispinner(app.ChildGrid3, 'Visible', 'off');
            app.SaveDataEndSpinner.Layout.Row = 2;
            app.SaveDataEndSpinner.Layout.Column = 2;
            app.SaveDataEndSpinner.ValueChangedFcn = app.createCallbackFcn(@controller.ppSpinnerSaveDataEndValueChanged, true);
        end
        
        function createButtonSave(app, controller)
            app.SaveButton = uibutton(app.ChildGrid3, 'push', 'Visible', 'off');
            app.SaveButton.Layout.Row = 3;
            app.SaveButton.Layout.Column = 4;
            app.SaveButton.Text = 'Save Data';
            app.SaveButton.ButtonPushedFcn = app.createCallbackFcn(@controller.ppSaveButtonPushed, true);
        end
        
        function createLegend(app)
            app.Legend = legend(app.TimeResolvedAxes, 'Visible', 'off');
            app.Legend.AutoUpdate = 'on';
            app.Legend.Location = 'northeast';
        end
        
    end

    % getters
    
    % setters
    
end