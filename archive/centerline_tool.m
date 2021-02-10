function varargout = centerline_tool(varargin)
%CENTERLINE_TOOL M-file for centerline_tool.fig
%      CENTERLINE_TOOL, by itself, creates a new CENTERLINE_TOOL or raises the existing
%      singleton*.
%
%      H = CENTERLINE_TOOL returns the handle to a new CENTERLINE_TOOL or the handle to
%      the existing singleton*.
%
%      CENTERLINE_TOOL('Property','Value',...) creates a new CENTERLINE_TOOL using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to centerline_tool_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      CENTERLINE_TOOL('CALLBACK') and CENTERLINE_TOOL('CALLBACK',hObject,...) call the
%      local function named CALLBACK in CENTERLINE_TOOL.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help centerline_tool

% Written by Eric Schrauben, University of Wisconsin - Madison
% 2015
% updated Eric Schrauben; The Hospital for Sick Children, Toronto, 2017

% Last Modified by GUIDE v2.5 06-Mar-2017 13:49:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @centerline_tool_OpeningFcn, ...
    'gui_OutputFcn',  @centerline_tool_OutputFcn, ...
    'gui_LayoutFcn',  [], ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before centerline_tool is made visible.
function centerline_tool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for centerline_tool
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes centerline_tool wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = centerline_tool_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in flow_parameters.
function flow_parameters_Callback(hObject, eventdata, handles)
% hObject    handle to flow_parameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Global variable declarations

% from load pc vipr
global v MAG timeMIP nframes
% from visualization
global branchActual
% from flow_parameters
global area diam flowPerHeartCycle flowPulsatile  ...
    maxVel wss_simple wss_simple_avg meanVel PI

r = 6;
[area, diam, flowPerHeartCycle, flowPulsatile, ...
    maxVel,wss_simple, wss_simple_avg, meanVel,PI] = ...
    flow_parameters(branchActual, v, timeMIP, r,nframes);
guidata(hObject,handles);

% --- Executes on selection change in plot_popup.
function plot_popup_Callback(hObject, eventdata, handles)
% hObject    handle to plot_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns plot_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from plot_popup


% --- Executes during object creation, after setting all properties.
function plot_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plot_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in plot_popup2.
function plot_popup2_Callback(hObject, eventdata, handles)
% hObject    handle to plot_popup2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns plot_popup2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from plot_popup2
val = get(hObject, 'Value');
str = get(hObject, 'String');
switch str{val}
    case 'Over Vessel Length'
        set(handles.plot_popup,'String',{'Area';'Diameter'; 'Total Flow'; ...
            'Maximum Velocity '; 'Maximum Velocity (paraboloid fit)'; 'Mean Velocity'; ...
            'Mean Velocity (paraboloid fit)'; 'Mean WSS'; 'Mean WSS (paraboloid fit)'; ...
            'Pulsatility Index'},'Value',1);
        set(handles.text7,'Enable','off');
        set(handles.inputPoint,'Enable','off');
    case 'Over Cardiac Time'
        set(handles.text7,'Enable','on');
        set(handles.inputPoint,'Enable','on');
        set(handles.plot_popup,'String',{'Pulsatile Flow'},'Value',1);
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function plot_popup2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plot_popup2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plot_pushbutton.
function plot_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to plot_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Global variable declarations
% from load pc vipr
global timeres nframes
% from flow_parameters
global area diam flowPerHeartCycle  flowPulsatile distance...
    maxVel  wss_simple_avg  meanVel PI
clc;
axes(handles.parameter_plot);
cla;
daspect([1 1 1])
val = get(handles.plot_popup, 'Value');
str = get(handles.plot_popup, 'String');
switch str{val}
    case 'Area'
        %         plot(distance,area)
        %         xlabel('Distance Along Vessel (cm)'), ylabel('Area (cm^2)')
        plot (area);
        xlabel('Centerline Point'),ylabel('Area (cm^2)')
    case 'Diameter'
        %         plot(distance,diam)
        %         xlabel('Distance Along Vessel (cm)'),ylabel('Diameter (cm)')
        plot(diam);
        xlabel('Centerline Point'),ylabel('Diameter (cm)')
    case 'Total Flow'
        %         plot(distance,flowPerHeartCycle)
        %        xlabel('Distance Along Vessel (cm)'), ylabel('Total Flow (mL/s)')
        plot(flowPerHeartCycle);
        xlabel('Centerline Point'),ylabel('Total Flow (mL/s)')
    case 'Maximum Velocity '
        %         plot(distance,maxVel)
        %         xlabel('Distance Along Vessel (cm)'),ylabel('Max Velocity (cm/s)')
        plot(maxVel)
        xlabel('Centerline Point'),ylabel('Max Velocity (cm/s)')
    case 'Mean Velocity'
        %         plot(distance,meanVel)
        %         xlabel('Distance Along Vessel (cm)'),ylabel('Mean Velocity (cm/s)')
        plot(meanVel)
        xlabel('Centerline Point'),ylabel('Mean Velocity (cm/s)')
    case 'Mean WSS'
        %         plot(distance,wss_simple_avg)
        %         xlabel('Distance Along Vessel (cm)'), ylabel('Mean WSS (Pa)')
        plot(wss_simple_avg)
        xlabel('Centerline Point'), ylabel('Mean WSS (Pa)')
    case 'Pulsatility Index'
        %         plot(distance,PI)
        %        xlabel('Distance Along Vessel (cm)'), ylabel('Pulsatility Index')
        plot(PI)
        xlabel('Centerline Point'), ylabel('Pulsatility Index')
    case 'Pulsatile Flow'
        colors = {'b','k','r','m','c'};
        points = eval(get(handles.inputPoint,'String'));
        for i = 1:length(points)
            plot(timeres/1000*linspace(1,nframes,nframes),smooth(flowPulsatile(points(i),:)),colors{i}); hold on
        end
        hold off;
        xlabel('Cardiac Time (ms)'), ylabel('Flow (mL/s)'), legend(cellstr(num2str(points')))
end
axis  tight ;
set(0,'defaultlinelinewidth',2);set(0,'DefaultAxesFontSize',14);
set(findall(gcf,'type','text'),'fontSize',14,'fontName','Arial')
guidata(hObject,handles);

function inputPoint_Callback(hObject, eventdata, handles)
% hObject    handle to inputPoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of inputPoint as text
%        str2double(get(hObject,'String')) returns contents of inputPoint as a double


% --- Executes during object creation, after setting all properties.
function inputPoint_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inputPoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in vesselSegment.
function vesselSegment_Callback(hObject, eventdata, handles)
% hObject    handle to vesselSegment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Global variable declarations
% from load pc vipr
datacursormode off; rotate3d off; zoom off;
global res MAG segment
%from feature extraction
global branchMat branchList
% from visualization
global  timeMIPvessel branchActual branchNum vessel
clc;
clear vessel
% delete(figure(1))
% delete(figure(2))
% delete(figure(3))

MAGmax = max(max(max(MAG)));
MAGr = im2uint8(MAG/MAGmax);
MAGg = im2uint8(MAG/MAGmax);
MAGb = im2uint8(MAG/MAGmax);
cm = colormap(jet(255));

counter = 0;
result = 5;
% while result ~= 2
MAGr(find(segment)) = cm(255,1)*255;
MAGg(find(segment)) = cm(150,2)*150;
MAGb(find(segment)) = cm(1,3)*1;
branchNum = 0;
while branchNum == 0
    clc;
    datacursormode off
    z = mr3(MAGr(end:-1:1,:,end:-1:1), MAGg(end:-1:1,:,end:-1:1), MAGb(end:-1:1,:,end:-1:1), []);
    
    dcm_obj = datacursormode;
    set(dcm_obj,'DisplayStyle','datatip',...
        'SnapToDataVertex','off','Enable','on')
    disp('Click in vessel you wish to measure, then press Return.')
    pause
    figure(3)
    c_info = getCursorInfo(dcm_obj);
    
    x = res-round(double(c_info.Position(2)));  % x and y are switched for some reason
    y = round(double(c_info.Position(1)));
    fprintf('x: %i\ny: %i\nz: %i\n', x, y, z);
    
    %finds closest point in branchMat then uses that value for vessel selection
    Points = regionprops(branchMat>0,'PixelList');
    Points = struct2cell(Points);
    Points = cell2mat(Points');

    Distance = sqrt(sum((bsxfun(@minus,Points,[y,x,z])).^2,2));
    Val = find(Distance == min(Distance));
    Points = Points(Val(1),:);
    branchNum = branchMat(Points(2),Points(1),Points(3));
end
counter = counter + 1;
vessel(counter) = branchNum;
disp('Found vessel!')
disp('Segmenting Vessel...')
indices = 0; indexes = 0;
for i = 1:length(vessel)
    indices = vertcat(indices,find(branchList(:,4) == vessel(i)));
    indexes = vertcat(indexes,find(branchMat == vessel(i)));
end
indices(1) = []; indexes(1) = [];

branchActual = zeros(numel(indices),3);
branchActual(:,1) = branchList(indices,1);
branchActual(:,2) = branchList(indices,2);
branchActual(:,3) = branchList(indices,3);

% Image dilate and multiply by mask to extract entire vessel length
branchMat2 = zeros(res,res,res);
% indexes = (branchMat == vessel(:));
branchMat2(indexes) = 1;
I1 = imdilate(branchMat2,ones(7,7,7));

timeMIPvessel = I1.*segment;
timeMIPvessel(timeMIPvessel~=0) = 1;

delete(figure(1)); delete(figure(2)); delete(figure(3)); colormap gray

% --- Executes on button press in vessel3D.
function vessel3D_Callback(hObject, eventdata, handles)
% hObject    handle to vessel3D (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
datacursormode off
global  timeMIPvessel  res branchActual segment fov distance
global m_ystart m_ystop m_xstart m_xstop m_zstart m_zstop
clc;
disp('Visualizing Segmented vessel in 3d...')

axes(handles.vessel_seg);
cla;
% hpatch2 = patch(smoothpatch(isosurface(BWmip,.5),1,3));
hpatch2 = patch(isosurface(segment,.5));
set(hpatch2,'FaceColor','k','EdgeColor','none','FaceAlpha',0.1)

% hpatch = patch(smoothpatch(isosurface(timeMIPvessel,.25),0,1,1,3));
hpatch = patch(isosurface(timeMIPvessel,.25));
set(hpatch,'FaceColor','r','EdgeColor','none','FaceAlpha',0.4)

scale = fov/res;
distance = zeros(1,length(branchActual));
distance(1) = scale;
for i = 2:length(branchActual) - 1
    distance(i) = sqrt((branchActual(i,1)-branchActual(i+1,1))^2+ ...
        (branchActual(i,2)-branchActual(i+1,2))^2+(branchActual(i,3)-branchActual(i+1,3))^2)*scale + distance(i-1);
end
distance(end) = distance(end-1)+scale;


set(gca,'ZDir','reverse');
axis vis3d
axis off
view([-1 0 0]);
daspect([1 1 1]);
num = 0;
hold on;
for i = 1:numel(branchActual(:,1))
    num = num + 1;
    %     if num > 2 && num <= length(branchActual)-2
    if mod(num-2,5) == 0
        stringval = {num2str(num-2)};
        text(branchActual(i,2),branchActual(i,1),branchActual(i,3),stringval,'Color','b');
        
    end
    %     end
end
% scatter3(branchActual(:,2),branchActual(:,1),branchActual(:,3),'.k');
xlim([m_ystart m_ystop]);
ylim([m_xstart m_xstop]);
zlim([m_zstart m_zstop]);
% rotate3d on
pan on


% --- Executes on button press in saving_data.
function saving_data_Callback(hObject, eventdata, handles)
% hObject    handle to saving_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clc;
% Global variable declarations
% from load pc vipr
global timeres nframes directory
% from flow_parameters
global area diam flowPerHeartCycle  flowPulsatile ...
    maxVel wss_simple wss_simple_avg meanVel PI

saving_data(timeres, nframes, directory, handles, area, diam, flowPerHeartCycle,  flowPulsatile, ...
    maxVel, wss_simple, wss_simple_avg, meanVel, PI )
cd ..


function save_name_Callback(hObject, eventdata, handles)
% hObject    handle to save_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of save_name as text
%        str2double(get(hObject,'String')) returns contents of save_name as a double


% --- Executes during object creation, after setting all properties.
function save_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to save_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in savedata.
function savedata_Callback(hObject, eventdata, handles)
% hObject    handle to savedata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns savedata contents as cell array
%        contents{get(hObject,'Value')} returns selected item from savedata


% --- Executes during object creation, after setting all properties.
function savedata_CreateFcn(hObject, eventdata, handles)
% hObject    handle to savedata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in load_data.
function load_data_Callback(hObject, eventdata, handles)
% hObject    handle to load_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clc;

% Global variable declarations
% from load pc vipr
global directory nframes res fov timeres v MAG timeMIP vMean segment
global m_xstart;
global m_xstop;
global m_ystart;
global m_ystop;
global m_zstart;
global m_zstop;
m_xstart = 1; m_ystart = 1; m_zstart = 1;

[directory, nframes, res, fov, timeres, v, MAG, timeMIP, vMean] = loadpcvipr();

set(handles.text26,'string',['Directory = ' directory])
m_xstop = res; m_ystop = res; m_zstop = res;
%%Set mips
axes(handles.mipx)
imagesc(reshape(max(timeMIP,[],1),[res res]));
set(gca,'XTickLabel','')
set(gca,'YTickLabel','')
colormap('gray');
daspect([1 1 1]);
set(handles.stopX,'string',res)

axes(handles.mipy)
imagesc(reshape(max(timeMIP,[],2),[res res]));
set(gca,'XTickLabel','')
set(gca,'YTickLabel','')
colormap('gray');
daspect([1 1 1]);
set(handles.stopY,'string',res)

axes(handles.mipz)
imagesc(reshape(max(timeMIP,[],3),[res res]));
set(gca,'XTickLabel','')
set(gca,'YTickLabel','')
colormap('gray');
daspect([1 1 1]);
set(handles.stopZ,'string',res)

clc;
disp('View 3D Vasculature')

timeMIP2 = zeros(size(timeMIP));
timeMIP2(m_xstart:m_xstop, m_ystart:m_ystop, m_zstart:m_zstop) = 1;
timeMIP_crop = timeMIP.*timeMIP2;
% vMean_crop = zeros(size(vMean));
% vMean_crop(:,:,:,1) = timeMIP2.*vMean(:,:,:,1);
% vMean_crop(:,:,:,2) = timeMIP2.*vMean(:,:,:,2);
% vMean_crop(:,:,:,3) = timeMIP2.*vMean(:,:,:,3);

normed_MIP = timeMIP_crop(:)./max(timeMIP_crop(:));
[muhat,sigmahat] = normfit(normed_MIP);

segment = zeros(size(timeMIP_crop));
segment(normed_MIP>muhat+4.5*sigmahat) = 1;

segment = bwareaopen(segment,round(sum(segment(:)).*0.005),6); %The value at the end of the commnad in the minimum area of each segment to keep 
segment = imfill(segment,'holes'); % Fill in holes created by slow flow on the inside of vessels
segment = single(segment);

axes(handles.axes_3D)
cla;
hpatch = patch(isosurface(segment,0.5));
colormap('gray');
reducepatch(hpatch,0.6);
set(hpatch,'FaceColor','red','EdgeColor', 'none');
set(gca, 'ZDir', 'reverse')
set(gca,'color','black')
% Make it all look good
camlight headlight;
lighting gouraud
alpha(0.9)
% set(fig,'color','black');
view([-.5 0 0]);
% zoom(1.0);
daspect([1 1 1])
axis vis3d
xlim([m_ystart m_ystop]);
ylim([m_xstart m_xstop]);
zlim([m_zstart m_zstop]);
axis off;
rotate3d on

function feature_extraction_Callback(hObject, eventdata, handles)
% hObject    handle to feature_extraction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clc;

% Global variable declarations
% from load pc vipr
global segment vMean
%from feature extraction
global branchMat branchList branchTextList

% Calculate phase coherence and extract centerline for the vascular tree
% specify sortingCriteria as either
% = 2 to get all branches connected to each other sorting (few branches)
% = 3 to get branch by branch sorting (many branches)
sortingCriteria = 3;
spurLength = 8;

% vascularTreeReconstr
% 1. 'coarse'. Uses a PCthreshDev of 0.25 and a box filter to remove noise
%   in the reconstructed vascular tree. Misses some vessels.
% 2. 'fine' Uses a PCthreshDev of 0.3 and no filter. Noisier than 'coarse',
%   but finds small vessels more easily.
vascularTreeReconstr = 'coarse';

[CL,branchMat, branchList, branchTextList] = feature_extraction( ...
    sortingCriteria, spurLength, vMean, segment);


% --- Executes on button press in draw_roi.
function draw_roi_Callback(hObject, eventdata, handles)
% hObject    handle to draw_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
datacursormode off; rotate3d off; zoom off;
global x_rect;
global z_rect;
m_xstart = str2double(get(handles.startX,'String'));
m_xstop  = str2double(get(handles.stopX,'String'));
m_ystart = str2double(get(handles.startY,'String'));
m_ystop  = str2double(get(handles.stopY,'String'));
m_zstart = str2double(get(handles.startZ,'String'));
m_zstop  = str2double(get(handles.stopZ,'String'));

%%%
x_rect = imrect(handles.mipx,[m_zstart m_ystart (m_zstop - m_zstart) (m_ystop -m_ystart)]);
y_rect = imrect(handles.mipy,[m_zstart m_xstart (m_zstop - m_zstart) (m_xstop -m_xstart)]);
z_rect = imrect(handles.mipz,[m_ystart m_xstart (m_ystop - m_ystart) (m_xstop -m_xstart)]);

%%%Cross ROI Resizing
addNewPositionCallback(x_rect,@(p) (set_crossx(x_rect,y_rect,z_rect,handles)));
addNewPositionCallback(y_rect,@(p) (set_crossy(x_rect,y_rect,z_rect,handles)));
addNewPositionCallback(z_rect,@(p) (set_crossz(x_rect,y_rect,z_rect,handles)));


function set_crossx(x_rect,y_rect,z_rect,handles)
px = getPosition(x_rect);
py = getPosition(y_rect);
pz = getPosition(z_rect);
setPosition(y_rect,[px(1) py(2) px(3) py(4)] );
setPosition(z_rect,[px(2) pz(2) px(4) pz(4)] );
set_start_stop(px,pz,handles);

return

function set_crossy(x_rect,y_rect,z_rect,handles)
px = getPosition(x_rect);
py = getPosition(y_rect);
pz = getPosition(z_rect);
setPosition(x_rect,[py(1) px(2) py(3) px(4)] );
setPosition(z_rect,[pz(1) py(2) pz(3) py(4)] );
set_start_stop(px,pz,handles);

return


function set_crossz(x_rect,y_rect,z_rect,handles)
px = getPosition(x_rect);
py = getPosition(y_rect);
pz = getPosition(z_rect);
setPosition(x_rect,[px(1) pz(1) px(3) pz(3)] );
setPosition(y_rect,[py(1) pz(2) py(3) pz(4)] );
set_start_stop(px,pz,handles);

return

function set_start_stop(px,pz,handles)
set(handles.startX,'string',floor(pz(2)));
set(handles.startY,'string',floor(pz(1)));
set(handles.startZ,'string',floor(px(1)));
set(handles.stopX,'string',floor(pz(4)+pz(2)));
set(handles.stopY,'string',floor(pz(3)+pz(1)));
set(handles.stopZ,'string',floor(px(3)+px(1)));
return



function startX_Callback(hObject, eventdata, handles)
% hObject    handle to startX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startX as text
%        str2double(get(hObject,'String')) returns contents of startX as a double


% --- Executes during object creation, after setting all properties.
function startX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stopX_Callback(hObject, eventdata, handles)
% hObject    handle to stopX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stopX as text
%        str2double(get(hObject,'String')) returns contents of stopX as a double


% --- Executes during object creation, after setting all properties.
function stopX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stopX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function startY_Callback(hObject, eventdata, handles)
% hObject    handle to startY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startY as text
%        str2double(get(hObject,'String')) returns contents of startY as a double


% --- Executes during object creation, after setting all properties.
function startY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stopY_Callback(hObject, eventdata, handles)
% hObject    handle to stopY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stopY as text
%        str2double(get(hObject,'String')) returns contents of stopY as a double


% --- Executes during object creation, after setting all properties.
function stopY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stopY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function startZ_Callback(hObject, eventdata, handles)
% hObject    handle to startZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startZ as text
%        str2double(get(hObject,'String')) returns contents of startZ as a double


% --- Executes during object creation, after setting all properties.
function startZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stopZ_Callback(hObject, eventdata, handles)
% hObject    handle to stopZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stopZ as text
%        str2double(get(hObject,'String')) returns contents of stopZ as a double


% --- Executes during object creation, after setting all properties.
function stopZ_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stopZ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function mipx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mipx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate mipx


% --- Executes on button press in update_button.
function update_button_Callback(hObject, eventdata, handles)
% hObject    handle to update_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_images(handles);

function update_images(handles)

global m_xstart segment vMean
global m_xstop;
global m_ystart;
global m_ystop;
global m_zstart;
global m_zstop;

global m_xlength;
global m_ylength;
global m_zlength;
global timeMIP;
global res;

%%%COPY VALUES%%%%%%
m_xstart = str2double(get(handles.startX,'String'));
m_xstop  = str2double(get(handles.stopX,'String'));
m_ystart = str2double(get(handles.startY,'String'));
m_ystop  = str2double(get(handles.stopY,'String'));
m_zstart = str2double(get(handles.startZ,'String'));
m_zstop  = str2double(get(handles.stopZ,'String'));

m_xlength = m_xstop - m_xstart +1;
m_ylength = m_ystop - m_ystart +1;
m_zlength = m_zstop - m_zstart +1 ;

%%Set mips

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% XMIPS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

blank=128*ones(res+128,res+128);
axes(handles.mipx)

im = (reshape(max(timeMIP(m_xstart:m_xstop,m_ystart:m_ystop,m_zstart:m_zstop),[],1),[m_ylength m_zlength]));

im = im * 195 / max(im(:));
blank(m_ystart:m_ystop,m_zstart:m_zstop)=im;
imagesc(blank);
colormap gray;
ylim([ m_ystart (m_ystart+max([m_ylength m_zlength])-1)]);
xlim([ m_zstart (m_zstart+max([m_ylength m_zlength])-1)]);
drawnow
axis off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% YMIPS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

blank=128*ones(res+128,res+128);
axes(handles.mipy)

im = (reshape(max(timeMIP(m_xstart:m_xstop,m_ystart:m_ystop,m_zstart:m_zstop),[],2),[m_xlength m_zlength]));

im = im * 195 / max(im(:));
blank(m_xstart:m_xstop,m_zstart:m_zstop)=im;
imagesc(blank);
colormap gray;
xlim([m_zstart (m_zstart -1+ max([m_xlength m_zlength]))]);
ylim([m_xstart (m_xstart -1+ max([m_xlength m_zlength]))]);
drawnow
axis off


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% ZMIPS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

blank=128*ones(res+128,res+128);
axes(handles.mipz)

im = (reshape(max(timeMIP(m_xstart:m_xstop,m_ystart:m_ystop,m_zstart:m_zstop),[],3),[m_xlength m_ylength]));

im = im * 195 / max(im(:));
blank(m_xstart:m_xstop,m_ystart:m_ystop)=im;
imagesc(blank);
colormap gray;
xlim([(m_ystart) (m_ystart-1 +max([m_ylength m_xlength]))]);
ylim([(m_xstart) (m_xstart-1 +max([m_ylength m_xlength]))]);
drawnow
axis off

timeMIP2 = zeros(size(timeMIP));
timeMIP2(m_xstart:m_xstop, m_ystart:m_ystop, m_zstart:m_zstop) = 1;
timeMIP_crop = timeMIP.*timeMIP2;
vMean_crop = zeros(size(vMean));
vMean_crop(:,:,:,1) = timeMIP2.*vMean(:,:,:,1);
vMean_crop(:,:,:,2) = timeMIP2.*vMean(:,:,:,2);
vMean_crop(:,:,:,3) = timeMIP2.*vMean(:,:,:,3);

normed_MIP = timeMIP_crop(:)./max(timeMIP_crop(:));
[muhat,sigmahat] = normfit(normed_MIP);

segment = zeros(size(timeMIP_crop));
segment(normed_MIP>muhat+4.5*sigmahat) = 1;

segment = bwareaopen(segment,round(sum(segment(:)).*0.005),6); %The value at the end of the commnad in the minimum area of each segment to keep 
segment = imfill(segment,'holes'); % Fill in holes created by slow flow on the inside of vessels
segment = single(segment);

axes(handles.axes_3D)
cla;
hpatch = patch(isosurface(segment,0.5));
colormap('gray');
reducepatch(hpatch,0.6);
set(hpatch,'FaceColor','red','EdgeColor', 'none');
set(gca, 'ZDir', 'reverse')
set(gca,'color','black')
% Make it all look good
camlight headlight;
lighting gouraud
alpha(0.9)
% set(fig,'color','black');
view([-.5 0 0]);
% zoom(1.0);
% daspect([1 1 1])
xlim([m_ystart m_ystop]);
ylim([m_xstart m_xstop]);
zlim([m_zstart m_zstop]);
axis off;
rotate3d on

function start_save_Callback(hObject, eventdata, handles)
% hObject    handle to start_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of start_save as text
%        str2double(get(hObject,'String')) returns contents of start_save as a double


% --- Executes during object creation, after setting all properties.
function start_save_CreateFcn(hObject, eventdata, handles)
% hObject    handle to start_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double


% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function end_save_Callback(hObject, eventdata, handles)
% hObject    handle to end_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of end_save as text
%        str2double(get(hObject,'String')) returns contents of end_save as a double


% --- Executes during object creation, after setting all properties.
function end_save_CreateFcn(hObject, eventdata, handles)
% hObject    handle to end_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in parametric_map.
function parametric_map_Callback(hObject, eventdata, handles)
% hObject    handle to parametric_map (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

paramMap;
