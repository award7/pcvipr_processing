function [x, y, z] = mr3(img1, img2, img3, w_in, res)

%% intro
%function ct3(im,w) %http://www.mathworks.com/matlabcentral/fileexchange/32173-ct3-a-simple-mousewheel-based-3d-image-browser-for-medical-images
%
%Allows simple browsing of a CT scan using the mousewheel.  Assumes a grid
%spacing ratio of 3:1 axial thickness:radial thickness for display purposes
%
%Usage: ct3(im) will open Figures 1,2, and 3 and use imshow() to display the
%       CT dataset contained in "im" in all 3 orthogonal planes (sagittal,
%       coronal, axial).  Scrolling the mousewheel will move to the
%       next/previous slice in the active figure window.  Clicking the mouse
%       will print the current slice number of all 3 figure windows in
%       the console.
%
%input:
%   -im: 3D array of grayscale values.  This function assumes that the
%        1st and 2nd dimensions of the array contain the radial (or
%        sagittal/coronal) data, and the 3rd dimension of "im" contains
%        axial data.  This function also assumes a voxel size ratio of
%        1:1:3.
%
%   -w : (optional) window to use for display.  Default=[-140 160]
%        1x2 numerical array that contains the range of values of interest
%        to be displayed using ct3
%        note - use Matlab built-in function "imcontrast" (Image Proc Toolbox)
%        or plot the image data using hist() to easily determine the proper
%        window for your dataset
%
%output:
%        none
%
%ex:
%     ct3(im)
%     ct3(im, [-140 160])

%% SET PARAMETERS

%reverse the z direction
handles.im = img1(:,:,end:-1:1);
handles.im2 = img2(:,:,end:-1:1);
handles.im3 = img3(:,:,end:-1:1);

handles.slice1 = floor(size(handles.im,1)/2);
handles.slice2 = floor(size(handles.im,2)/2);
handles.slice3 = floor(size(handles.im,3)/2);

handles.mn = 1;

handles.mx1 = size(handles.im,1);
handles.mx2 = size(handles.im,2);
handles.mx3 = size(handles.im,3);

% pointless as the value gets wiped soon after
if nargin < 4
    handles.w = [-140 160];
end
handles.w = [];

handles = initialize_figs(handles);
set(handles.sagittal_figure, 'WindowScrollWheelFcn', @wheel); 
set(handles.sagittal_figure, 'WindowButtonDownFcn', @click);
set(handles.coronal_fig, 'WindowScrollWheelFcn', @wheel);
set(handles.coronal_fig, 'WindowButtonDownFcn', @click);
set(handles.axial_fig, 'WindowScrollWheelFcn', @wheel);
set(handles.axial_fig, 'WindowButtonDownFcn', @click);

% datacursormode off; % creates fig
disp('Find vessel in Axial image, then press Return...')
pause;

dcm_obj = datacursormode(handles.axial_fig);
dcm_obj.DisplayStyle = 'datatip';
dcm_obj.SnapToDataVertex = 'Off';
dcm_obj.Enable = 'On';

disp('Use crosshairs to select vessel in Axial image, then press Return...')
pause;
c_info = getCursorInfo(dcm_obj);

x = res - round(double(c_info.Position(2)));  % x and y are switched for some reason
y = round(double(c_info.Position(1)));
z = handles.slice3;

delete(handles.sagittal_figure);
delete(handles.coronal_fig);
delete(handles.axial_fig);

%% INITALIZE THE FIGURE WINDOWS
function handles = initialize_figs(handles)
    im = handles.im;
    im2 = handles.im2;
    im3 = handles.im3;
    w = handles.w;
    slice1 = handles.slice1;
    slice2 = handles.slice2;
    slice3 = handles.slice3;
    mx1 = handles.mx1;
    mx2 = handles.mx2;
    mx3 = handles.mx3;
    
    handles.sagittal_figure = figure('Name', 'Sagittal', 'NumberTitle', 'Off');
    clf(handles.sagittal_figure);
    datacursormode(handles.sagittal_figure, 'off'); 
    rotate3d(handles.sagittal_figure, 'off');
    zoom(handles.sagittal_figure, 'off');
    handles.i1 = imshow(permute(cat(1, im(slice1,:,:), im2(slice1,:,:), im3(slice1,:,:)), [3 2 1]), w, 'parent', gca);
    set(gca, 'Units', 'normalized', 'position', [0 0 1 1]);
    handles.sagittal_figure.Units = 'Normalized';
    handles.sagittal_figure.OuterPosition = [0.0000 0.0000 (1/3) 1.0000];

    hold on;
    handles.p131 = plot([0 mx2/10],[slice3 slice3], 'g', 'linewidth',1);
    handles.p132 = plot([mx2*9/10 mx2],[slice3 slice3], 'g', 'linewidth',1);
    handles.p121 = plot([slice2 slice2], [0 mx3/10], 'g', 'linewidth',1);
    handles.p122 = plot([slice2 slice2], [mx3*9/10 mx3], 'g', 'linewidth',1);
    hold off;

    handles.coronal_fig = figure('Name', 'Coronal', 'NumberTitle', 'off'); 
    clf(handles.coronal_fig);
    datacursormode(handles.coronal_fig, 'off');
    rotate3d(handles.coronal_fig, 'off'); 
    zoom(handles.coronal_fig, 'off');
    handles.i2 = imshow(permute(cat(2, im(:,slice2,:), im2(:,slice2,:), im3(:,slice2,:)),[3 1 2]),w,'parent',gca);
    set(gca, 'Units', 'normalized', 'position',[0 0 1 1]);
    handles.coronal_fig.Units = 'Normalized';
    handles.coronal_fig.OuterPosition = [(1/3) 0.0000 (1/3) 1.0000];

    hold on;
    handles.p231 = plot([0 mx1/10], [slice3 slice3], 'g', 'linewidth', 1);
    handles.p232 = plot([mx1*9/10 mx1], [slice3 slice3], 'g', 'linewidth', 1);
    handles.p211 = plot([slice1 slice1], [0 mx3/10], 'g', 'linewidth', 1);
    handles.p212 = plot([slice1 slice1], [mx3*9/10 mx3], 'g', 'linewidth', 1);
    hold off;

    handles.axial_fig = figure('Name', 'Axial', 'NumberTitle', 'off'); 
    clf(handles.axial_fig);
    datacursormode off; 
    rotate3d off; 
    zoom off;
    handles.i3 = imshow(cat(3, im(:,:,slice3), im2(:,:,slice3), im3(:,:,slice3)),w, 'parent',gca);
    set(gca, 'Units', 'normalized', 'position',[0 0 1 1]);
    handles.axial_fig.Units = 'normalized';
    handles.axial_fig.OuterPosition = [(2/3) 0.0000 (1/3) 1.0000];

    hold on;
    handles.p311 = plot([0 mx2/10], [slice1 slice1], 'g', 'linewidth', 1);
    handles.p312 = plot([mx2*9/10 mx2], [slice1 slice1], 'g', 'linewidth', 1);
    handles.p321 = plot([slice2 slice2], [0 mx1/10], 'g', 'linewidth', 1);
    handles.p322 = plot([slice2 slice2], [mx1*9/10 mx1], 'g', 'linewidth', 1);
    hold off;

    % figure(1);
    %set(gcf,'position',[ 0.3169    0.0400    0.3025    0.3383]);

    % figure(2); set(gcf,'Units','normalized');
    %set(gcf,'position',[ 0.0044    0.4558    0.3025    0.3383]);
end

%% CAPTURE MOUSEWHEEL EVENTS
function wheel(src, evnt)
        cur=get(gcf, 'Name');
        switch cur
            case 'Sagittal'
                if evnt.VerticalScrollCount > 0
                    handles.slice1 = handles.slice1+1;
                else
                    handles.slice1 = handles.slice1-1;
                end
                handles = re_eval1(handles);
                
            case 'Coronal'
                if evnt.VerticalScrollCount > 0
                    handles.slice2 = handles.slice2-1;
                else
                    handles.slice2 = handles.slice2+1;
                end
                handles = re_eval2(handles);
                
            case 'Axial'
                if evnt.VerticalScrollCount > 0
                    handles.slice3 = handles.slice3+1;
                else
                    handles.slice3 = handles.slice3-1;
                end
                handles = re_eval3(handles);
            otherwise
                %do nothing
        end
end

%% REDRAW FIGURES
function handles = re_eval1(handles)
        slice1 = handles.slice1;
        mx1 = handles.mx1;
        mn = handles.mn;
        im = handles.im;
        im2 = handles.im2;
        im3 = handles.im3;
        
        if slice1 > mx1
            slice1 = mx1;
        elseif slice1 < mn
            slice1 = mn;
        else
            set(handles.i1,'CData',permute(cat(1, im(slice1,:,:), im2(slice1,:,:), im3(slice1,:,:)),[3 2 1]));
        end
        handles.slice1 = slice1;
        do_lines(handles);
end

function handles = re_eval2(handles)
        slice2 = handles.slice2;
        mx2 = handles.mx2;
        mn = handles.mn;
        im = handles.im;
        im2 = handles.im2;
        im3 = handles.im3;
        
        if slice2 > mx2
            slice2 = mx2;
        elseif slice2 < mn
            slice2 = mn;
        else
            set(handles.i2,'CData',permute(cat(2, im(:,slice2,:), im2(:,slice2,:), im3(:,slice2,:)),[3 1 2]));
        end
        handles.slice2 = slice2;
        do_lines(handles);
end

function handles = re_eval3(handles)
        slice3 = handles.slice3;
        mx3 = handles.mx3;
        mn = handles.mn;
        im = handles.im;
        im2 = handles.im2;
        im3 = handles.im3;
        
        if slice3 > mx3
            slice3 = mx3;
        elseif slice3 < mn
            slice3 = mn;
        else
            set(handles.i3,'CData',cat(3, im(:,:,slice3), im2(:,:,slice3), im3(:,:,slice3)));
        end
        handles.slice3 = slice3;
        do_lines(handles);
end
%% CAPTURE MOUSE CLICKS
function click(src,evnt)
        %account for reversal of z dimension
%         disp(num2str([slice1 slice2 (mx3+1-slice3)]))
        cur = get(gcf, 'Name');
        
        switch cur
            case 'Sagittal'
                pos_axes_unitfig        = get(handles.sagittal_figure, 'position');
                left_origin_unitfig     = pos_axes_unitfig(1);
                bottom_origin_unitfig   = pos_axes_unitfig(2);
                width_axes_unitfig      = pos_axes_unitfig(3);
                height_axes_unitfig     = pos_axes_unitfig(4);
                pos_cursor_unitfig      = get(handles.sagittal_figure, 'currentpoint');
                xlim_axes               = get(handles.sagittal_figure,'XLim');
                
            case 'Coronal'
                pos_axes_unitfig        = get(handles.coronal_fig,'position');
                left_origin_unitfig     = pos_axes_unitfig(1);
                bottom_origin_unitfig   = pos_axes_unitfig(2);
                width_axes_unitfig      = pos_axes_unitfig(3);
                height_axes_unitfig     = pos_axes_unitfig(4);
                pos_cursor_unitfig      = get(handles.coronal_fig, 'currentpoint');
                xlim_axes               = get(handles.coronal_fig,'XLim');
                
            case 'Axial'
                pos_axes_unitfig        = get(handles.axial_fig,'position');
                left_origin_unitfig     = pos_axes_unitfig(1);
                bottom_origin_unitfig   = pos_axes_unitfig(2);
                width_axes_unitfig      = pos_axes_unitfig(3);
                height_axes_unitfig     = pos_axes_unitfig(4);
                pos_cursor_unitfig      = get(handles.axial_fig, 'currentpoint');
                xlim_axes               = get(handles.axial_fig,'XLim');
                
            otherwise
                %
        end
end

%% REDRAW MARKER LINES
function do_lines(handles)
        set(handles.p131,'YData',[handles.slice3 handles.slice3]);
        set(handles.p121,'XData',[handles.slice2 handles.slice2]);
        set(handles.p132,'YData',[handles.slice3 handles.slice3]);
        set(handles.p122,'XData',[handles.slice2 handles.slice2]);
        
        set(handles.p231,'YData',[handles.slice3 handles.slice3]);
        set(handles.p211,'XData',[handles.slice1 handles.slice1]);
        set(handles.p232,'YData',[handles.slice3 handles.slice3]);
        set(handles.p212,'XData',[handles.slice1 handles.slice1]);
        
        set(handles.p311,'YData',[handles.slice1 handles.slice1]);
        set(handles.p321,'XData',[handles.slice2 handles.slice2]);
        set(handles.p312,'YData',[handles.slice1 handles.slice1]);
        set(handles.p322,'XData',[handles.slice2 handles.slice2]);
    end

end