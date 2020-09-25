function saving_data(handles)
%function saving_data(timeres, nframes, directory, handles, area, diam, flowPerHeartCycle,  flowPulsatile, ...
%    maxVel, wss_simple, wss_simple_avg, meanVel, PI, removed_voxels)
	% Version 2.0
	% Version Date 2020-03-28
	% Edited by ATW award7@wisc.edu
	% UNTITLED2 Summary of this function goes here
	%   Detailed explanation goes here
	
    %% create directories if they don't exist
	handles.saving_location_raw = strcat(handles.directory, '\data\raw');
    handles.saving_location_proc = strcat(handles.directory, '\data\proc');
	
    if ~exist(handles.saving_location_raw) == 1
        mkdir(handles.saving_location_raw);
    end
    if ~exist(handles.saving_location_proc) == 1
        mkdir(handles.saving_location_proc);
    end
    
    handles.upper_bound = handles.lower_bound + handles.window - 1;
    save_time_averaged(handles);
    save_time_resolved(handles);
    
end

%% time averaged data
function save_time_averaged(handles)

    col_header = ({'Voxel', ...
        'Area_(cm^2)', ...
        'Diameter_(cm)', ...
        'Mean_Velocity_(cm/s)', ...
        'Max_Velocity_(cm/s)', ...
        'Total_Flow_per_heartbeat_(mL)', ...
        'WSS_(Pa)', ...
        'Pulsatility_Index_(au)'});
    voxels = length(handles.values.area);
    voxels = linspace(1, voxels, voxels);
    
    % unrefined data
    time_avg_data_unrefined = horzcat(voxels', ...
        handles.values.area', ...
        handles.values.diam', ...
        handles.values.meanVel', ...
        handles.values.maxVel', ...
        handles.values.flowPerHeartCycle', ...
        handles.values.wss_simple_avg', ...
        handles.values.PI'); % concat arrays
    time_avg_unrefined = vertcat(col_header, num2cell(real(time_avg_data_unrefined))); % full matrix
    time_avg_unrefined = time_avg_unrefined(handles.save_start:handles.save_end, :); % restrict to specified voxels
    
    % refined data
    % voxels(handles.values.removed_voxels) = [];
    % time_avg_data_refined = time_avg_data_unrefined(voxels, :); % remove voxels
    % time_avg_refined = vertcat(col_header, num2cell(real(time_avg_data_refined))); % full matrix
    % time_avg_refined =
    % time_avg_refined(handles.save_start:handles.save_end,:); % restrict
    % to specified voxels % cannot restrict on this refined data because
    % the array indices no longer match
    
    % do average from lower and upper bounds
    bounded_voxel_data = num2cell(real(mean(time_avg_data_unrefined(handles.lower_bound:handles.upper_bound, 2:end)))); % exclude voxels
    bounded_voxel_data = vertcat(col_header(2:end), bounded_voxel_data);
    
    % save data
    filename_base = strrep(strcat(lower(handles.vessel_name), '_time_averaged'), ' ', '_');
    save(fullfile(handles.saving_location_raw, strcat(filename_base, '.mat')), 'time_avg_unrefined'); % save .mat file
    % save(fullfile(handles.saving_location_proc, strcat(filename_base, '_refined.mat'), 'time_avg_refined')); % save .mat file
    writecell(time_avg_unrefined, fullfile(handles.saving_location_raw, strcat(filename_base, '.xls'))); % save .xls file
    % writecell(time_avg_refined, fullfile(handles.saving_location_proc, strcat(filename_base, '_refined.xls'))); % save .xls file
    writecell(bounded_voxel_data, fullfile(handles.saving_location_proc, strcat(filename_base, '_analyzed.xls'))); % save .xls file
    
    % save messages
    fprintf('Time-averaged flow data (%s) saved to %s as %s\n', 'unrefined', handles.saving_location_raw, strcat(filename_base, '.mat'));
    fprintf('Time-averaged flow data (%s) saved to %s as %s\n', 'unrefined', handles.saving_location_raw, strcat(filename_base, '.xls'));
    % fprintf('Time-averaged flow data (%s) saved to %s as %s\n', 'refined', handles.saving_location_proc, strcat(filename_base, '_refined.mat'));
    % fprintf('Time-averaged flow data (%s) saved to %s as %s\n', 'refined', handles.saving_location_proc, strcat(filename_base, '_refined.xls'));
    fprintf('Time-averaged flow data (%s) saved to %s as %s\n', 'analyzed', handles.saving_location_proc, strcat(filename_base, '_analyzed.xls'));

end

%% time resolved data
function save_time_resolved(handles)
    
    col_spaces = repmat({''}, 1, handles.nframes-1); % filler b/c matlab needs even arrays for concat
    row_spaces = repmat({''}, 1, 1);
    cardiac_time_values_absolute = handles.timeres/1000*linspace(1, handles.nframes, handles.nframes);
    cardiac_time_values_relative = round(cardiac_time_values_absolute./cardiac_time_values_absolute(:,end)*100, 0); 
    col_header1 = ({'Cardiac_Time_(s)'});    
    col_header1 = horzcat(col_header1, num2cell(real(cardiac_time_values_absolute)), {'HR_(bpm)'}); % row 1
    col_header2 = ({'Cardiac_Time_(%)'});
    col_header2 = horzcat(col_header2, num2cell(real(cardiac_time_values_relative)), row_spaces); % row 2
    
    col_header3 = horzcat({'Voxel', 'Flow_(mL/s)'}, col_spaces, {'Flow_(mL/min)'}); % row 3
    voxels = length(handles.values.flowPulsatile);
    voxels = linspace(1, voxels, voxels); % make array of voxels
    [flow_matrix, hr] = calculate_flow(cardiac_time_values_absolute, voxels, handles.values.flowPulsatile); % calculate flow in mL/min
    
    % unrefined data
    col_header2(end) = num2cell(hr);
    time_resolve_unrefined = vertcat(col_header1, col_header2, col_header3, num2cell(real(flow_matrix))); % full matrix
    time_resolve_unrefined = time_resolve_unrefined(handles.save_start:handles.save_end,:); % restrict to specified voxels
    
    % refined data
    % flow_matrix_refined = time_resolve_unrefined(handles.values.emoved_voxels, :);
    % time_resolve_refined = vertcat(col_header2, col_header3, col_header4, num2cell(real(flow_matrix))); % full matrix
    % time_resolve_refined =
    % time_resolve_refined(handles.save_start:handles.save_end,:); % restrict to specified voxels  % cannot restrict on this refined data because
    % the array indices no longer match
    
    % do average from lower and upper bounds
    
    bounded_voxel_data = mean(flow_matrix(handles.lower_bound:handles.upper_bound, :));
    bounded_voxel_data = vertcat(col_header1, col_header2, col_header3, num2cell(real(bounded_voxel_data)));
    
    % save data
    filename_base = strrep(strcat(lower(handles.vessel_name), '_time_resolved'), ' ', '_');
    save(fullfile(handles.saving_location_raw, strcat(filename_base, '.mat')), 'time_resolve_unrefined'); % save raw .mat file
    % save(fullfile(handles.saving_location_proc, strcat(filename_base, '_refined.mat'), 'time_resolve_refined')); % save .mat file
    writecell(time_resolve_unrefined, fullfile(handles.saving_location_raw, strcat(filename_base, '.xls'))); % save raw .xls file
    % writecell(time_resolve_refined, fullfile(handles.saving_location_proc, strcat(filename_base, '_time_resolved_refined.xls'))); % save .xls file
    writecell(bounded_voxel_data, fullfile(handles.saving_location_proc, strcat(filename_base, '_analyzed.xls'))); % save analyzed .xls file
    
    % save messages
    fprintf('Time-resolved flow data (%s) saved to %s as %s\n', 'unrefined', handles.saving_location_raw, strcat(filename_base, '_unrefined.mat'));
    fprintf('Time-resolved flow data (%s) saved to %s as %s\n', 'unrefined', handles.saving_location_raw, strcat(filename_base, '_unrefined.xls'));
    % fprintf('Time-resolved flow data (%s) saved to %s as %s\n', 'refined', handles.saving_location_proc, strcat(filename_base, '_refined.mat'));
    % fprintf('Time-resolved flow data (%s) saved to %s as %s\n', 'refined', handles.saving_location_proc, strcat(filename_base, '_refined.xls'));
    fprintf('Time-resolved flow data (%s) saved to %s as %s\n', 'analzyed', handles.saving_location_proc, strcat(filename_base, '_analyzed.xls'));

end

%% calculate flow ml/min
function [flow_matrix, hr] = calculate_flow(cardiac_time_values, voxels, flowPulsatile)
    % calculate flow in mL/min for each voxel
    flow_array = [];
    row_count = size(flowPulsatile,1);
    hr = 60 / cardiac_time_values(end);
    vector1 = cardiac_time_values(1, 2:end); % cardiac values1
    vector2 = cardiac_time_values(1, 1:end-1); % cardiac values2
    for row = 1:row_count
        vector3 = flowPulsatile(row, 2:end); % flow values1
        vector4 = flowPulsatile(row, 1:end-1); % flow values2
        vector5 = vector1 - vector2;
        vector6 = vector3 + vector4;
        vector7 = vector5 .* vector6;
        flow_per_beat = sum(vector7) * 0.5;
        flow = flow_per_beat * hr;
        flow_array(row) = flow;
    end

    % matrix with voxels, flow as a fcn of cardiac cycle, and flow ml/min
    flow_matrix = horzcat(voxels', flowPulsatile, flow_array');
end


%% sliding window algo
% sliding window
% window_size = 3;
% for i = 1:1:length(voxels)-(window_size - 1)
%     window = voxels(i:i+(window_size -1));
% end


