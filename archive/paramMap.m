function varargout = paramMap(varargin)
% PARAMMAP MATLAB code for paramMap.fig
%      PARAMMAP, by itself, creates a new PARAMMAP or raises the existing
%      singleton*.
%
%      H = PARAMMAP returns the handle to a new PARAMMAP or the handle to
%      the existing singleton*.
%
%      PARAMMAP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PARAMMAP.M with the given input arguments.
%
%      PARAMMAP('Property','Value',...) creates a new PARAMMAP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before paramMap_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to paramMap_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help paramMap

% Last Modified by GUIDE v2.5 04-Apr-2017 14:00:10

% Copyright Eric Schrauben; University of Wisconsin - Madison, 2015
% updated Eric Schrauben; The Hospital for Sick Children, Toronto, 2017

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @paramMap_OpeningFcn, ...
    'gui_OutputFcn',  @paramMap_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
% if nargin && ischar(varargin{1})
%     gui_State.gui_Callback = str2func(varargin{1});
% end
% 
% if nargout
%     [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
% else
%     gui_mainfcn(gui_State, varargin{:});
% end
% End initialization code - DO NOT EDIT


% --- Executes just before paramMap is made visible.
function paramMap_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to paramMap (see VARARGIN)

% Choose default command line output for paramMap
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes paramMap wait for user response (see UIRESUME)
% uiwait(handles.ParameterTool);

global nframes timeres fov res directory timeMIP v 
global branchList branchTextList branchMat
global segment area_vol flowPerHeartCycle_vol PI_vol diam_vol maxVel_vol RI_vol flowPulsatile_vol
global Planes hfull p branchLabeled Ntxt

branchLabeled = 0;
hfull = handles;
Ntxt = [];
p = [];
mkdir( directory , 'Processed_Images');
% flow parameter calculation, bulk of code is in paramMap_parameters.m
[area_vol, diam_vol, flowPerHeartCycle_vol, maxVel_vol, PI_vol, RI_vol, flowPulsatile_vol] = paramMap_params_new(...
    branchTextList, branchList, res, timeMIP, v,branchMat, nframes, fov);
[Planes] = makeITPlane(branchList);

% toc

% --- Outputs from this function are returned to the command line.
function varargout = paramMap_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in parameter_choice.
function parameter_choice_Callback(hObject, eventdata, handles)
% hObject    handle to parameter_choice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns parameter_choice contents as cell array
%        contents{get(hObject,'Value')} returns selected item from parameter_choice


% --- Executes during object creation, after setting all properties.
function parameter_choice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to parameter_choice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in view_map.
function view_map_Callback(hObject, eventdata, handles)
% hObject    handle to view_map (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Yhis function allows for the 3D plotting of the values calculated from
% paramMap_params.m, with the option of visualizing individual waveforms

global  area_vol flowPerHeartCycle_vol PI_vol  diam_vol maxVel_vol RI_vol ...
        p dcm_obj Planes r fig hfull segment hpatch Sval branchLabeled

% Get parameter option and whether plotting flow waveform is turned on
val = get(handles.parameter_choice, 'Value');
str = get(handles.parameter_choice, 'String');

% Initialize figure
fig = figure(1);
cla
hpatch = patch(isosurface(segment,0.5),'FaceAlpha',Sval);
reducepatch(hpatch,0.7);
set(hpatch,'FaceColor','white','EdgeColor', 'none','PickableParts','none');
set(fig,'Name',[str{val} ' Map'], 'NumberTitle','off')

% turn on data cursormode within the figure
dcm_obj = datacursormode(fig);
datacursormode on;
set(handles.CBARmin,'String','min')
set(handles.CBARmax,'String','max')
branchLabeled = 0;
switch str{val}
    case 'Area'
        
        [x y z] = ind2sub(size(area_vol),find(area_vol));
        cdata = area_vol(find(area_vol));
        hold on 
        hscatter = scatter3(y,x,z,45,cdata,'filled');
        hold off
        caxis([min(cdata) 0.7*max(cdata)]);
        set(gcf,'color','black');
        axis off tight
        view([-1 .1 0]);
        axis vis3d
        daspect([1 1 1])
        zoom(1.0);
        set(gca,'ZDir','reverse');
        cbar = colorbar;
        caxis([0 1.5*mean(area_vol(find(area_vol(:))))])
        set(get(cbar,'xlabel'),'string','Area (cm^2)','fontsize',16,'Color','white');
        set(cbar,'FontSize',16,'color','white');
        ax = gca;
        xlim([ax.XLim(1)-r ax.XLim(2)+r])
        ylim([ax.YLim(1)-r ax.YLim(2)+r])
        zlim([ax.ZLim(1)-r ax.ZLim(2)+r])
        
        % update string
        set(dcm_obj,'UpdateFcn',@myupdatefcn_area)
        dcm_obj.createDatatip(hscatter);
        
        
    case 'Diameter'
        [x y z] = ind2sub(size(diam_vol),find(diam_vol));
        cdata = diam_vol(find(diam_vol));        
        hold on 
        hscatter = scatter3(y,x,z,45,cdata,'filled');
        hold off
        % make it look good
        caxis([min(cdata) max(cdata)]);
        set(gcf,'color','black');
        axis off tight
        view([-1 .1 0]);
        axis vis3d
        daspect([1 1 1])
        zoom(1.0);
        set(gca,'ZDir','reverse');
        cbar = colorbar;
        set(get(cbar,'xlabel'),'string','Diameter (cm)','fontsize',16,'Color','white');
        set(cbar,'FontSize',16,'color','white');
        ax = gca;
        xlim([ax.XLim(1)-r ax.XLim(2)+r])
        ylim([ax.YLim(1)-r ax.YLim(2)+r])
        zlim([ax.ZLim(1)-r ax.ZLim(2)+r])
        % update string
        set(dcm_obj,'UpdateFcn',@myupdatefcn_diam)
        dcm_obj.createDatatip(hscatter);
        
    case 'Total Flow'
        [x y z] = ind2sub(size(flowPerHeartCycle_vol),find(flowPerHeartCycle_vol));
        cdata = flowPerHeartCycle_vol(find(flowPerHeartCycle_vol));
        
        hold on 
        hscatter = scatter3(y,x,z,45,cdata,'filled');
        hold off
        % make it look good
        caxis([min(cdata) max(cdata)]);
        set(gcf,'color','black');
        axis off tight
        view([-1 .1 0]);
        axis vis3d
        daspect([1 1 1])
        zoom(1.0);
        set(gca,'ZDir','reverse');
        cbar = colorbar;
        caxis([0 0.8*max(flowPerHeartCycle_vol(:))])
        set(get(cbar,'xlabel'),'string','Flow (mL/cycle)','fontsize',16,'Color','white');
        set(cbar,'FontSize',16,'color','white');
        ax = gca;
        xlim([ax.XLim(1)-r ax.XLim(2)+r])
        ylim([ax.YLim(1)-r ax.YLim(2)+r])
        zlim([ax.ZLim(1)-r ax.ZLim(2)+r])
        hold on    
        p = fill3(Planes(1,:,2)',Planes(1,:,1)',Planes(1,:,3)','r'); % fill3(pty',ptx',ptz','r') when used with isosurface
        delete(p)
        % update string
        set(dcm_obj,'UpdateFcn',@myupdatefcn_flow)
        dcm_obj.createDatatip(hscatter);
        
    case 'Maximum Velocity '
        [x y z] = ind2sub(size(maxVel_vol),find(maxVel_vol));
        cdata = maxVel_vol(find(maxVel_vol));
        hold on 
        hscatter = scatter3(y,x,z,45,cdata,'filled');
        hold off
        caxis([min(cdata) max(cdata)]);
        set(gcf,'color','black');
        axis off tight
        view([-1 .1 0]);
        axis vis3d
        daspect([1 1 1])
        zoom(1.0);
        set(gca,'ZDir','reverse');
        cbar = colorbar;
        caxis([min(maxVel_vol(:)) 110])
        set(get(cbar,'xlabel'),'string','Max Velocity (cm/s)','fontsize',16,'Color','white');
        set(cbar,'FontSize',16,'color','white');
        ax = gca;
        xlim([ax.XLim(1)-r ax.XLim(2)+r])
        ylim([ax.YLim(1)-r ax.YLim(2)+r])
        zlim([ax.ZLim(1)-r ax.ZLim(2)+r])
        hold on    
        p = fill3(Planes(1,:,2)',Planes(1,:,1)',Planes(1,:,3)','r'); % fill3(pty',ptx',ptz','r') when used with isosurface
        delete(p)
        set(dcm_obj,'UpdateFcn',@myupdatefcn_maxVel)
        dcm_obj.createDatatip(hscatter);

        case 'Resistance Index'
        
        [x y z] = ind2sub(size(RI_vol),find(RI_vol));
        cdata = RI_vol(find(RI_vol));
        hold on 
        hscatter = scatter3(y,x,z,45,cdata,'filled');
        hold off
        caxis([min(cdata) max(cdata)]);
        set(gcf,'color','black');
        axis off tight
        view([-1 .1 0]);
        axis vis3d
        daspect([1 1 1])
        zoom(1.0);
        set(gca,'ZDir','reverse');
        cbar = colorbar;
        caxis([-0.5 1])
        set(get(cbar,'xlabel'),'string','Resistance Index','fontsize',16,'Color','white');
        set(cbar,'FontSize',16,'color','white');
        ax = gca;
        xlim([ax.XLim(1)-r ax.XLim(2)+r])
        ylim([ax.YLim(1)-r ax.YLim(2)+r])
        zlim([ax.ZLim(1)-r ax.ZLim(2)+r])
        hold on    
        p = fill3(Planes(1,:,2)',Planes(1,:,1)',Planes(1,:,3)','r'); % fill3(pty',ptx',ptz','r') when used with isosurface
        delete(p)
        hold off
        set(dcm_obj,'UpdateFcn',@myupdatefcn_RI)
        dcm_obj.createDatatip(hscatter);
    case str{val}
        
        [x y z] = ind2sub(size(PI_vol),find(PI_vol));
        cdata = PI_vol(find(PI_vol));
        
        hold on 
        hscatter = scatter3(y,x,z,45,cdata,'filled');
        hold off
        caxis([min(cdata) max(cdata)]);
        set(gcf,'color','black');
        axis off tight
        view([-1 .1 0]);
        axis vis3d
        daspect([1 1 1])
        zoom(1.0);
        set(gca,'ZDir','reverse');
        cbar = colorbar;
        caxis([0 2])
        set(get(cbar,'xlabel'),'string','Pulsatility Index','fontsize',16,'Color','white');
        set(cbar,'FontSize',16,'color','white');
        ax = gca;
        xlim([ax.XLim(1)-r ax.XLim(2)+r])
        ylim([ax.YLim(1)-r ax.YLim(2)+r])
        zlim([ax.ZLim(1)-r ax.ZLim(2)+r])
        hold on    
        p = fill3(Planes(1,:,2)',Planes(1,:,1)',Planes(1,:,3)','r'); % fill3(pty',ptx',ptz','r') when used with isosurface
        delete(p)
        hold off
        set(dcm_obj,'UpdateFcn',@myupdatefcn_PI)
        dcm_obj.createDatatip(hscatter);
  
end

% --- Executes during object creation, after setting all properties.
function plot_flowWaveform_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plot_flowwaveform (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes on slider movement.
function Transparent_Callback(hObject, eventdata, handles)
% hObject    handle to Transparent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global hpatch Sval

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
Sval = get(hObject,'Value');
set(hpatch,'FaceAlpha',Sval);



% --- Executes during object creation, after setting all properties.
function Transparent_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Transparent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

global Sval
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
set(hObject, 'Min', 0);
set(hObject, 'Max', 1);
set(hObject,'Value',0);
Sval = get(hObject,'Value');




function CBARmin_Callback(hObject, eventdata, handles)
% hObject    handle to CBARmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global fig
% Hints: get(hObject,'String') returns contents of CBARmin as text
%        str2double(get(hObject,'String')) returns contents of CBARmin as a double
caxis(fig.Children(end),[str2double(get(hObject,'String')),fig.Children(end-1).Limits(2)])
fig.Children(end-1).Limits(1) = str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function CBARmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CBARmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CBARmax_Callback(hObject, eventdata, handles)
% hObject    handle to CBARmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global fig
% Hints: get(hObject,'String') returns contents of CBARmax as text
%        str2double(get(hObject,'String')) returns contents of CBARmax as a double
caxis(fig.Children(end),[fig.Children(end-1).Limits(1),str2double(get(hObject,'String'))])
fig.Children(end-1).Limits(2) = str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function CBARmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CBARmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in CBARselection.
function CBARselection_Callback(hObject, eventdata, handles)
% hObject    handle to CBARselection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global fig
% Hints: contents = cellstr(get(hObject,'String')) returns CBARselection contents as cell array
%        contents{get(hObject,'Value')} returns selected item from CBARselection
contents = cellstr(get(hObject,'String'));
colormap(fig.Children(end),contents{get(hObject,'Value')})


% --- Executes during object creation, after setting all properties.
function CBARselection_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CBARselection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in NamePoint.
function NamePoint_Callback(hObject, eventdata, handles)
% hObject    handle to NamePoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global PointLabel

% Hints: contents = cellstr(get(hObject,'String')) returns NamePoint contents as cell array
%        contents{get(hObject,'Value')} returns selected item from NamePoint
contents = cellstr(get(hObject,'String'));
PointLabel = contents{get(hObject,'Value')};



% --- Executes during object creation, after setting all properties.
function NamePoint_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NamePoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SavePoint.
function SavePoint_Callback(hObject, eventdata, handles)
% hObject    handle to SavePoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global PointLabel nframes timeres directory branchList timeMIPcrossection
global area_vol flowPerHeartCycle_vol PI_vol diam_vol
global branchMat maxVel_vol RI_vol flowPulsatile_vol vTimeFrameave
global dcm_obj fig segment1

%Find the Current cursor point
info_struct = getCursorInfo(dcm_obj);
ptList = [info_struct.Position];
ptList = reshape(ptList,[3,numel(ptList)/3])';
pindex = zeros(size(ptList,1),1);

% This can be used later if multiple points want to be placed. The labeling
% might be tricky and need to be updated.
 for n = 1:size(ptList,1);
     blah = find(branchList(:,1) == ptList(n,2));
     blah2 = find(branchList(blah,2) == ptList(n,1));
     blah3 = find(branchList(blah(blah2),3) == ptList(n,3));
     pindex(n) = blah(blah2(blah3));
 end
 
 %Gives the associated branch number if full branch point is wanted could
 %make that a save option
 bnum = branchList(pindex(1),4);
 index_branch = branchList(:,4) == bnum;
 branchActual = branchList(index_branch,1:3);

 % Finds the index value in the branch only
 blah = find(branchActual(:,1) == ptList(n,2));
 blah2 = find(branchActual(blah,2) == ptList(n,1));
 blah3 = find(branchActual(blah(blah2),3) == ptList(n,3));
 index(n) = blah(blah2(blah3));
 
 % This creates range of points to be used for saving and will not add
 % errors for end points
 index_range = index-2:index+2;
 index_range(index_range>length(branchActual)|index_range<1) = [];

x2 = branchActual(index_range,1);
y2 = branchActual(index_range,2);
z2 = branchActual(index_range,3);

% Time averaged data
index_vol = sub2ind(size(branchMat),x2,y2,z2);
area = area_vol(index_vol);
area = [area;mean(area);std(area)];
diam = diam_vol(index_vol);
diam = [diam;mean(diam);std(diam)];
flowPerHeartCycle = flowPerHeartCycle_vol(index_vol);
flowPerHeartCycle = [flowPerHeartCycle;mean(flowPerHeartCycle);std(flowPerHeartCycle)];
PI = PI_vol(index_vol) ;
PI = [PI;mean(PI);std(PI)];
maxVel = maxVel_vol(index_vol);
maxVel = [maxVel;mean(maxVel);std(maxVel)];
RI = RI_vol(index_vol);
RI = [RI;mean(RI);std(RI)];

flowPulsatile = flowPulsatile_vol(index_vol,:);
flowPulsatile = [flowPulsatile;mean(flowPulsatile,1);std(flowPulsatile,1)];

% This is the Name of the current point from the ParameterTool Label Point
% option
savename = PointLabel;

% Shut off added excel sheet warning in MATLAB
warning('off','MATLAB:xlswrite:AddSheet')

 % save time-averaged
 col_header = ({'Point along Vessel', 'Area (cm^2)', 'Diameter (cm)', 'Max Velocity (cm/s)',...
        'Average Flow(mL)','Pulsatility Index','Resistivity Index'});
 time_avg = vertcat(col_header,num2cell(real(horzcat(linspace(1,length(area),length(area))',...
     area,diam,maxVel,flowPerHeartCycle,PI,RI))));
 time_avg{end-1,1} = 'Mean';
 time_avg{end,1} = 'Standard Deviation';
 xlswrite([directory '\Summary.xls'],time_avg,[savename '_time_averaged']);
 
% save time-resolved
spaces = repmat({''},1,nframes-1);
col_header2 = ({'Cardiac Time (ms)'});
col_header3 = horzcat({'Point along Vessel','Flow (mL/s)'},spaces);
col_header2 = horzcat(col_header2, num2cell(real(timeres/1000*linspace(1,nframes,nframes))));
time_resolve = vertcat(col_header2, col_header3, num2cell(real(horzcat(linspace(1,length(area),length(area))',flowPulsatile))));
time_resolve{end-1,1} = 'Mean';
time_resolve{end,1} = 'Standard Deviation';
xlswrite([directory '\Summary.xls'],time_resolve,[savename '_time_resolved']);
 
 % Save images of the interactive window, main GUI window and all cross
 % sections as a montage
 
fig.Color = 'black';
fig.InvertHardcopy = 'off';
saveas(fig,[ directory '\Processed_Images\' savename '_3dview.jpg'])

fig2 = handles.ParameterTool;
fig2.Color = [0.94,0.94,0.94];
fig2.InvertHardcopy = 'off';
saveas(fig2,[ directory '\Processed_Images\' savename '_GUIview.jpg'])

% Get the dimensions of the sides of the slices created
imdim = sqrt(size(segment1,2));

% Get the cross sections for all points for branch
BranchSliceAll = segment1(index_branch,:);
BranchSlice = BranchSliceAll(index_range,:); %Restricts for branch edges

% Get the cross sections for all points for branch
cdAll = timeMIPcrossection(index_branch,:);
cdSlice = cdAll(index_range,:); %Restricts for branch edges

% Get the cross sections for all points for branch
velSliceAll = vTimeFrameave(index_branch,:);
velSlice = velSliceAll(index_range,:); %Restricts for branch edges

subL = size(BranchSlice,1);
f1 = figure('Position',[100,100,700,700],'Visible','off');
FinalImage = zeros(imdim,imdim,1,3*subL);
temp = 1;
%Put all images into a single image for saving cross sectional data
for q = 1:subL
    
% Create some images of the cross section that is used
CDcross = cdSlice(q,:);
CDcross = reshape(CDcross,imdim,imdim)./max(CDcross);
Vcross = velSlice(q,:);
Vcross = reshape(Vcross,imdim,imdim)./max(Vcross);
Maskcross = BranchSlice(q,:);
Maskcross = reshape(Maskcross,imdim,imdim)./max(Maskcross);

% Put all images into slices
FinalImage(:,:,1,temp) = CDcross;
FinalImage(:,:,1,temp+1) = Vcross;
FinalImage(:,:,1,temp+2) = Maskcross;
temp = temp+3;

end
subplot('position', [0 0 1 1]) 
montage(FinalImage, 'Size', [subL 3]);
saveas(f1,[ directory '\Processed_Images\' savename '_Slicesview.jpg'])
close(f1)

display(['Completed saving ' savename ' data to summary file. Saved in ',directory])




 



