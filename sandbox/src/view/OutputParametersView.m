classdef OutputParametersView < matlab.apps.AppBase

    %{
    WORKING NOTES:
    
    * create a tab and all child components in one method
    
    %}
    
    % base figure and layout components
    properties (Access = public)
        UIFigure    matlab.ui.Figure;
    end
    
    % fields in subject details tab
    properties (Access = private)
        StudyEditField            matlab.ui.control.EditField;
        SubjectEditField          matlab.ui.control.EditField;
        ConditionVisitEditField   matlab.ui.control.EditField;
        TimePointEditField        matlab.ui.control.EditField;
    end
    
    % fields in database tab
    properties
        DataSourceEditField       matlab.ui.control.EditField;
        DatabaseDropDown          matlab.ui.control.DropDown;
        TableDropDown             matlab.ui.control.DropDown;
        ConnectToDatabaseButton   matlab.ui.control.Button;
    end
    
    % fields in dataoutput path
    properties
        OutputAsCsvCheckBox     matlab.ui.control.CheckBox;
        OpenFileBrowserButton   matlab.ui.control.Button;
        OutputPathEditField     matlab.ui.control.EditField;
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = OutputParametersView(controller)

            % Create UIFigure and components
            app.createComponents(controller)

            % Register the app with App Designer
            app.registerApp(app.UIFigure)

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

        function createComponents(app, controller)
            app.createFigure(controller);
            app.createTabGroup(controller);
            app.createOkButton(controller);
            
            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
        
        function createFigure(app, controller)
            app.UIFigure = uifigure('Visible', 'off');
            
            % center figure
            parent_dims = controller.BaseView.UIFigure.Position;
            parent_relative = true;
            child_dims = [300 250];
            child_relative = false;
            obj = RelativePositioning();
            coordinates = obj.centerChildInParent(parent_dims, parent_relative, child_dims, child_relative);
            app.UIFigure.Position = coordinates;
            
            app.UIFigure.Name = 'Output Parameters';
            app.UIFigure.Icon = 'db.png';
            app.UIFigure.Resize = 'off';
            app.UIFigure.WindowStyle = 'modal';
            % todo: set callbacks
        end
        
        function createTabGroup(app, controller)
            tab_group = uitabgroup(app.UIFigure);
            tab_group.Position = [2 51 300 200];
            
            app.createSubjectDetailsTab(tab_group, controller);
            app.createDatabaseTab(tab_group, controller);
            app.createDataOutputTab(tab_group, controller);
        end
        
        function createSubjectDetailsTab(app, tab_group, controller)
            tab = uitab(tab_group);
            tab.Title = 'Subject Details';

            % Create StudyEditField
            app.StudyEditField = uieditfield(tab, 'text');
            app.StudyEditField.Position = [120 136 120 20];
            app.StudyEditField.Value = controller.OutputParametersModel.Study;

            % Create SubjectEditField
            app.SubjectEditField = uieditfield(tab, 'text');
            app.SubjectEditField.Position = [120 97 120 20];
            app.SubjectEditField.Value = controller.OutputParametersModel.Subject;

            % Create ConditionVisitEditField
            app.ConditionVisitEditField = uieditfield(tab, 'text');
            app.ConditionVisitEditField.Position = [120 58 120 20];
            app.ConditionVisitEditField.Value = controller.OutputParametersModel.ConditionOrVisit;

            % Create TimePointEditField
            app.TimePointEditField = uieditfield(tab, 'text');
            app.TimePointEditField.Position = [120 19 120 20];
            app.TimePointEditField.Value = controller.OutputParametersModel.TimePoint;

            % Create SubjectLabel
            subject_label = uilabel(tab);
            subject_label.HorizontalAlignment = 'right';
            subject_label.Position = [30 97 80 20];
            subject_label.Text = 'Subject';

            % Create ConditionVisitLabel
            condition_visit_label = uilabel(tab);
            condition_visit_label.HorizontalAlignment = 'right';
            condition_visit_label.Position = [30 58 80 20];
            condition_visit_label.Text = 'Condition/Visit';

            % Create StudyLabel
            study_label = uilabel(tab);
            study_label.HorizontalAlignment = 'right';
            study_label.Position = [30 136 80 20];
            study_label.Text = 'Study';

            % Create TimePointLabel
            time_point_label = uilabel(tab);
            time_point_label.HorizontalAlignment = 'right';
            time_point_label.Position = [30 19 80 20];
            time_point_label.Text = 'Time Point';
        end
        
        function createDatabaseTab(app, tab_group, controller)
            % Create DatabaseTab
            tab = uitab(tab_group);
            tab.Title = 'Database';

            % Create DataSourceEditField
            app.DataSourceEditField = uieditfield(tab, 'text');
            app.DataSourceEditField.Position = [120 136 120 20];
            app.DataSourceEditField.Editable = false;
            if ~isempty(controller.OutputParametersModel.DatabaseConnection)
                app.DataSourceEditField.Value = controller.OutputParametersModel.DatabaseConnection.DataSource;
            else
                app.DataSourceEditField.Value = "";
            end

            % Create DatabaseDropDown
            app.DatabaseDropDown = uidropdown(tab);
            app.DatabaseDropDown.Position = [120 97 120 20];
            if ~isempty(controller.OutputParametersModel.DatabaseConnection)
                app.DatabaseDropDown.Items = controller.OutputParametersModel.DatabaseList;
            else
                app.DatabaseDropDown.Items = {''};
            end

            % Create TableDropDown
            app.TableDropDown = uidropdown(tab);
            app.TableDropDown.Position = [120 58 120 20];
            if ~isempty(controller.OutputParametersModel.DatabaseConnection)
                app.TableDropDown.Items = controller.OutputParametersModel.TableList;
            else
                app.TableDropDown.Items = [""];
            end
            
            % Create ConnectToDatabaseButton
            btn = uibutton(tab, 'push');
            btn.Position = [255 136 30 20];
            btn.Text = '...';
            btn.ButtonPushedFcn = createCallbackFcn(app, @controller.connectToDbButtonCallback, true);

            % Create DataSourceLabel
            data_source_label = uilabel(tab);
            data_source_label.HorizontalAlignment = 'right';
            data_source_label.Position = [30 136 80 20];
            data_source_label.Text = 'Data Source';

            % Create DatabaseLabel
            database_label = uilabel(tab);
            database_label.HorizontalAlignment = 'right';
            database_label.Position = [30 97 80 20];
            database_label.Text = 'Database';

            % Create TableLabel
            table_label = uilabel(tab);
            table_label.HorizontalAlignment = 'right';
            table_label.Position = [30 58 80 20];
            table_label.Text = 'Table';
        end
        
        function createDataOutputTab(app, tab_group, controller)
           % Create DataOutputTab
            tab = uitab(tab_group);
            tab.Title = 'Data Output';

            % Create OutputPathEditField
            app.OutputPathEditField = uieditfield(tab, 'text');
            app.OutputPathEditField.Position = [120 136 120 20];
            if ~isempty(controller.OutputParametersModel.OutputPath)
                app.OutputPathEditField.Value = controller.OutputParametersModel.OutputPath;
            else
                app.OutputPathEditField.Value = "";
            end
            app.OutputPathEditField.ValueChangedFcn = createCallbackFcn(app, @controller.outputPathEditFieldValueChangedCallback, true);

            % Create OpenFileBrowserButton
            btn = uibutton(tab, 'push');
            btn.Position = [255 136 30 20];
            btn.Text = '...';
            btn.ButtonPushedFcn = createCallbackFcn(app, @controller.openFileBrowserButtonButtonPushedCallback, true);

            % Create CheckBox
            app.OutputAsCsvCheckBox = uicheckbox(tab);
            app.OutputAsCsvCheckBox.Text = '';
            app.OutputAsCsvCheckBox.Position = [120 97 26 22];
            app.OutputAsCsvCheckBox.Value = controller.OutputParametersModel.OutputAsCsv;
            app.OutputAsCsvCheckBox.ValueChangedFcn = createCallbackFcn(app, @controller.outputAsCsvCheckBoxValueChangedCallback, true);

            % Create OutputAsCsvLabel
            output_as_csv_label = uilabel(tab);
            output_as_csv_label.HorizontalAlignment = 'right';
            output_as_csv_label.Position = [30 97 80 20];
            output_as_csv_label.Text = 'Output as .csv';

            % Create OutputPathLabel
            output_path_label = uilabel(tab);
            output_path_label.HorizontalAlignment = 'right';
            output_path_label.Position = [30 136 80 20];
            output_path_label.Text = 'Output Path';        
        end
        
        function createOkButton(app, controller)
            btn = uibutton(app.UIFigure, 'push');
            btn.Position = [100 11 100 30];
            btn.Text = 'Ok';
            btn.ButtonPushedFcn = createCallbackFcn(app, @controller.okButtonPushedCallback, true);
        end

    end
    
end