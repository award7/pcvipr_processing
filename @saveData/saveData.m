classdef saveData < handle
    % methods for saving data to DB and/or .csv files
    
    % passed parameters
    properties
        vessel_name;
        window;
        lower_bound;
        upper_bound;
        save_start;
        save_end;
    end
    
    % directory properties
    properties
        root_dir;
        data_dir;
        raw_dir;
        proc_dir;
        img_dir;
        plots_dir;
    end
    
    % make data table properties
    properties
       time_averaged_table;
       time_resolved_table;
    end
    
    properties
        hr;
        absolute_cardiac_time;
        relative_cardiac_time;
    end
    
    % constructor
    methods
        
        function self = saveData(vessel_name)
            if nargin ~= 0
                self.vessel_name = vessel_name;
            end
        end
        
    end
    
    % methods for creating directories for saving data
    methods (Access = public)
        
        function get_root_dir(self, directory)
            self.root_dir = directory;            
        end
        
        function make_data_dir(self)
            self.data_dir = fullfile(self.root_dir, 'data');
            if ~exist(self.data_dir) == 1
                mkdir(self.data_dir);
            end
        end
        
        function make_raw_dir(self)
            self.data_dir = fullfile(self.root_dir, 'data', 'raw');
            if ~exist(self.data_dir) == 1
                mkdir(self.data_dir);
            end
        end
        
        function make_proc_dir(self)
            self.data_dir = fullfile(self.root_dir, 'data', 'proc');
            if ~exist(self.data_dir) == 1
                mkdir(self.data_dir);
            end
        end
        
        function make_images_dir(self)
            self.img_dir = fullfile(self.root_dir, 'data', 'img');
            if ~exist(self.img_dir) == 1
                mkdir(self.img_dir);
            end
        end
        
        function make_plots_dir(self)
            self.plots_dir = fullfile(self.root_dir, 'data', 'plots');
            if ~exist(self.plots_dir) == 1
                mkdir(self.plots_dir);
            end
        end
        
    end
    
    % methods for formatting data into tables
    methods (Access = public)
        
        % vessel data is in the form of a structure
        function make_time_averaged_table(self, vessel_data, time_res)
            data = vessel_data;
            
            % get cardiac time and hr
            self.cardiac_time(time_res, nframes);
            
            % calculate flow/min
            flow = calculate_flow(data);
            data.flow = flow;
            
            % get voxel count
            voxels = self.get_voxel_list(data.area);
            data.voxels = voxels;
            
            % reorder fields to put voxels first and flow last
            names = fieldnames(data);
            order = [{'voxels'}; names];
            order = [order; {'flow'}];
            data = orderfields(data, order);

            % convert to table
            self.time_averaged_table = struct2table(data);
            % change variable names to basic names in previous versions of
            % the centerline summary output
            self.time_averaged_table = self.time_averaged_table(self.save_start:self.save_end, :);
            self.time_averaged_table = varfun(@real, self.time_averaged_table);
        end
        
        function make_time_resolved_table(self, vessel_data)
            self.time_resolved_table = struct2table(vessel_data);
        end
        
        function make_hr_table(self, hr_data)
            
        end
        
    end
    
    % methods for saving to .csv
    methods (Access = public)
        
        function time_averaged2csv(self)
            filename_base = strrep(strcat(lower(self.vessel_name), '_time_averaged'), ' ', '_');
            ext = '.csv';
            data_path = fullfile(self.raw_dir, strcat(filename_base, ext));
            writetable(self.time_averaged_table, data_path);
        end
        
        function time_resolved2csv(self, data_table)
            % setup file path
            filename_base = strrep(strcat(lower(self.vessel_name), '_time_resolved'), ' ', '_');
            ext = '.csv';
            data_path = fullfile(self.raw_dir, strcat(filename_base, ext));


            % make table
            header = horzcat({'Voxel', 'Flow_(mL/s)'}, num2cell(relative), {'Flow_(mL/min)'}); 
            time_resolved_table = table(horzcat(voxels, flowPulsatile, flow), 'VariableNames', header);
            time_resolved_table = varfun(@real, time_resolved_table);
            
            % save flow data
            writetable(data_table, data_path);
            
            % save hr data if not already
            if isempty(self.hr)
                hr2csv();
            end
            
        end
  
        function hr_2csv(self)
           % write hr data to csv
        end
        
        function refined_table = refineData(tab, removed_voxels)
            % remove voxels
            refined_table = tab;
            refined_table(removed_voxels, :) = [];
        end
        
    end
    
    % methods for saving to db
    methods (Access = public)
        % make db connection
        % write to tables
        % overwrite if exist (dialog box?)
        % close connection
    end
    
    % methods for performing calculations on the data
    methods(Access = private)

        function voxels = get_voxel_list(var)
            voxels = length(var);
            voxels = linspace(1, voxels, voxels);
        end

        function val = window_mean(dataTable, lower_bound, upper_bound)
            % do average from lower and upper bounds
            val = mean(dataTable{lower_bound:upper_bound, 2:end}, 1);
        end
        
        % calculate flow in mL/min for each voxel
        function flow = calculate_flow(self, data)
            flow = data.flowPerHeartCycle * self.hr;
        end
     
        function cardiac_time(self, time_res, nframes)
            self.absolute_cardiac_time = time_res/1000*linspace(1, nframes, nframes);
            self.relative_cardiac_time = round(self.absolute_cardiac_time ./ self.absolute_cardiac_time(:, end)*100, 0);
            self.hr = 60 / self.absolute_cardiac_time(end);
        end
 
    end
    
    % methods for saving plots
    methods (Access = private)

        function save_data(app)
            app.save_start = app.SaveDataStartSpinner.Value;
            app.save_end = app.SaveDataEndSpinner.Value;
            app.window = app.WindowSpinner.Value;
            app.lower_bound = app.LowerVoxelSpinner.Value;
            app.vessel_name = app.VesselNameDropDown.Value;
            fprintf('Saving %s data...\n', app.vessel_name);
            saving_data(app.handles);
            save_plots(app);
            fprintf('Done saving %s data\n', app.vessel_name)
        end
        
        function save_plots(app)
            plots_dir = app.make_plots_dir();
            
            vessel = app.VesselNameDropDown.Value;
            file_ext = '.png';
            disp_format = '    Saved %s plot\n';
            
            all_axes = [app.areaAxes, ...
                        app.diameterAxes, ... 
                        app.meanVelAxes, ...
                        app.maxVelAxes, ...
                        app.flowPerBeatAxes, ...
                        app.wssAxes, ...
                        app.pulsatilityAxes, ...
                        app.resolvedFlowAxes];
                    
            for k = 1:numel(all_axes)
                fig = copyUIAxes(all_axes(k));
                
                % reshape figure window
                fig.figure.Position(3) = all_axes(k).Position(3) * 1.15; % make fig 15% wider than axis
                fig.figure.Position(4) = all_axes(k).Position(4) * 1.50; % make fig 50% taller than axis
                
                % reshape figure axes
                fig.axes.Units = 'Pixels';
                fig.axes.Position(3:4) = all_axes(k).Position(3:4);
                plot_name = all_axes(k).Title;
                plot_name = strrep(lower(plot_name), ' ', '_');
                saveas(fig.axes, fullfile(plots_dir, [vessel, '_', plot_name, file_ext]));
                delete(fig.figure);
                fprintf(disp_format, plot_name);
            end
            
            % save parameter plots
            % R2019b cannot save plots from UI figures
            % need to copy axis (i.e. plot) to new figure then save
            % could probably make this into a loop but idk how and I'm
            % running out of time to get this done 05/21/2020
            

            %{
            %% diameter
            fig = copyUIAxes(app.diameterAxes);
            
            % reshape figure window
            fig.figure.Position(3) = app.diameterAxes.Position(3) * 1.15; % make fig 15% wider than axis
            fig.figure.Position(4) = app.diameterAxes.Position(4) * 1.50; % make fig 50% taller than axis
            
            % reshape figure axes
            fig.axes.Units = 'Pixels';
            fig.axes.Position(3:4) = app.diameterAxes.Position(3:4);
            saveas(fig.axes, fullfile(images_dir, [vessel, '_diameter', file_ext]));
            delete(fig.figure);
            fprintf(disp_format, 'diameter');
            
            %% mean velocity
            fig = copyUIAxes(app.meanVelAxes);
            
            % reshape figure window
            fig.figure.Position(3) = app.meanVelAxes.Position(3) * 1.15; % make fig 15% wider than axis
            fig.figure.Position(4) = app.meanVelAxes.Position(4) * 1.50; % make fig 50% taller than axis
            
            % reshape figure axes
            fig.axes.Units = 'Pixels';
            fig.axes.Position(3:4) = app.meanVelAxes.Position(3:4);
            saveas(fig.axes, fullfile(images_dir, [vessel, '_mean_velocity', file_ext]));
            delete(fig.figure);
            fprintf(disp_format, 'mean velocity');
            
            %% max velocity
            fig = copyUIAxes(app.maxVelAxes);
            
            % reshape figure window
            fig.figure.Position(3) = app.maxVelAxes.Position(3) * 1.15; % make fig 15% wider than axis
            fig.figure.Position(4) = app.maxVelAxes.Position(4) * 1.50; % make fig 50% taller than axis
            
            % reshape figure axes
            fig.axes.Units = 'Pixels';
            fig.axes.Position(3:4) = app.maxVelAxes.Position(3:4);
            saveas(fig.axes, fullfile(images_dir, [vessel, '_max_velocity', file_ext]));
            delete(fig.figure);
            fprintf(disp_format, 'max velocity');
            
            %% flow/beat
            fig = copyUIAxes(app.flowPerBeatAxes);
            
            % reshape figure window
            fig.figure.Position(3) = app.flowPerBeatAxes.Position(3) * 1.15; % make fig 15% wider than axis
            fig.figure.Position(4) = app.flowPerBeatAxes.Position(4) * 1.50; % make fig 50% taller than axis
            
            % reshape figure axes
            fig.axes.Units = 'Pixels';
            fig.axes.Position(3:4) = app.flowPerBeatAxes.Position(3:4);
            saveas(fig.axes, fullfile(images_dir, [vessel, '_flowPerBeat', file_ext]));
            delete(fig.figure);
            fprintf(disp_format, 'flow/beat');
            
            %% wss
            fig = copyUIAxes(app.wssAxes);
            
            % reshape figure window
            fig.figure.Position(3) = app.wssAxes.Position(3) * 1.15; % make fig 15% wider than axis
            fig.figure.Position(4) = app.wssAxes.Position(4) * 1.50; % make fig 50% taller than axis
            
            % reshape figure axes
            fig.axes.Units = 'Pixels';
            fig.axes.Position(3:4) = app.wssAxes.Position(3:4);
            saveas(fig.axes, fullfile(images_dir, [vessel, '_wss', file_ext]));
            delete(fig.figure);
            fprintf(disp_format, 'WSS');
            
            %% PI
            fig = copyUIAxes(app.pulsatilityAxes);
            
            % reshape figure window
            fig.figure.Position(3) = app.pulsatilityAxes.Position(3) * 1.15; % make fig 15% wider than axis
            fig.figure.Position(4) = app.pulsatilityAxes.Position(4) * 1.50; % make fig 50% taller than axis
            
            % reshape figure axes
            fig.axes.Units = 'Pixels';
            fig.axes.Position(3:4) = app.pulsatilityAxes.Position(3:4);
            saveas(fig.axes, fullfile(images_dir, [vessel, '_PI', file_ext]));
            delete(fig.figure);
            fprintf(disp_format, 'PI');
            
            %% time resolved flow
            fig = copyUIAxes(app.resolvedFlowAxes);
            
            % reshape figure window
            fig.figure.Position(3) = app.resolvedFlowAxes.Position(3) * 1.15; % make fig 15% wider than axis
            fig.figure.Position(4) = app.resolvedFlowAxes.Position(4) * 1.50; % make fig 50% taller than axis
            
            % reshape figure axes
            fig.axes.Units = 'Pixels';
            fig.axes.Position(3:4) = app.resolvedFlowAxes.Position(3:4);
            fig.figure.Children(1).Position(1) = fig.figure.Position(3) * 0.875; % move legend to side
            saveas(fig.axes, fullfile(images_dir, [vessel, '_pulsatile_flow', file_ext]));
            delete(fig.figure);
            fprintf(disp_format, 'Time-Resolved');
            %}
        end

        function save_vessel(app)
            % save vessel segment w/ and w/o isolation??]
            fname_suffix = strcat('_voxel', num2str(app.LowerVoxelSpinner.Value), '_window', num2str(app.WindowSpinner.Value));
            vessel_seg = copyUIAxes(app.VesselSegAxes);
            fname = fullfile(images_dir, [vessel, fname_suffix, file_ext]);
            saveas(vessel_seg.axes, fname);
            fprintf('    Saved %s image\n', 'vessel segment');
        end
        
    end
    
end

