function app = launchApp(fileChooser)
    if nargin==0
        fileChooser = CenterlineApp.utils.DefaultFileChooser();
    end
    f = uifigure;
    button = uibutton(f,'Text','Input file');
    button.ButtonPushedFcn = @(src,evt)pickFile(fileChooser);
    label = uilabel(f,'Text','No file selected');
    label.Position(1) = button.Position(1) + button.Position(3) + 25;
    label.Position(3) = 200;
    
    % Add components to an App struct for output
    app.UIFigure = f;
    app.Button = button;
    app.Label = label;
    
    function file = pickFile(fileChooser)
        [file,folder,status] = fileChooser.chooseFile('*.*');
        if status
            label.Text = file;
        end
    end
end