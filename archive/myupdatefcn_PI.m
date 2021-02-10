function txt = myupdatefcn_PI(empt,event_obj)
% Customizes text of data tips
count = 1;
global PI_vol branchList PointLabel branchLabeled Ntxt flowPulsatile_vol res fig p dcm_obj Planes hfull timeMIPcrossection segment1 vTimeFrameave

delete(p);
info_struct = getCursorInfo(dcm_obj);
ptList = [info_struct.Position];
ptList = reshape(ptList,[3,numel(ptList)/3])';
pindex = zeros(size(ptList,1),1);

 for n = 1:size(ptList,1);
     blah = find(branchList(:,1) == ptList(n,2));
     blah2 = find(branchList(blah,2) == ptList(n,1));
     blah3 = find(branchList(blah(blah2),3) == ptList(n,3));
     pindex(n) = blah(blah2(blah3));
 end

pos = get(event_obj,'Position');
pos  = floor(pos);
x = pos(2); y = pos(1); z = pos(3);

blah = find(branchList(:,1) == x);
blah2 = find(branchList(blah,2) ==y);
blah3 = find(branchList(blah(blah2),3) ==z);
index = blah(blah2(blah3));
bnum = branchList(index,4);
x2 = branchList(index-2:index+2,1);
y2 = branchList(index-2:index+2,2);
z2 = branchList(index-2:index+2,3);

hold on    
p = fill3(Planes(pindex,:,2)',Planes(pindex,:,1)',Planes(pindex,:,3)',[1 0 0],'EdgeColor',[1 0 0],'FaceAlpha',0.3,'PickableParts','none','Parent', fig.Children(2)); % fill3(pty',ptx',ptz','r') when used with isosurface
hold off

imdim = sqrt(size(segment1,2));
% Create some images of the cross section that is used
CDcross = timeMIPcrossection(index,:);
CDcross = reshape(CDcross,imdim,imdim);
imshow(CDcross,[],'InitialMagnification','fit','Parent', hfull.CDcross)
Vcross = vTimeFrameave(index,:);
Vcross = reshape(Vcross,imdim,imdim);
imshow(Vcross,[],'InitialMagnification','fit','Parent',hfull.VELcross)
Maskcross = segment1(index,:);
Maskcross = reshape(Maskcross,imdim,imdim);
imshow(Maskcross,[],'InitialMagnification','fit','Parent',hfull.KMEANcross)

value = PI_vol(x,y,z);
for i = 1:2*count+1
    average(i) = PI_vol(x2(i),y2(i),z2(i));
end

    index = sub2ind([res res res],x2,y2,z2);
    plot(5:5:100,smooth(flowPulsatile_vol(index(1),:)),'r',5:5:100,smooth(flowPulsatile_vol(index(2),:)),'r',5:5:100,smooth(flowPulsatile_vol(index(3),:)),'k',5:5:100,smooth(flowPulsatile_vol(index(4),:)),'b',5:5:100,smooth(flowPulsatile_vol(index(5),:)),'b','LineWidth',5,'Parent',hfull.pfwaveform)
    set(get(hfull.pfwaveform,'XLabel'),'String','Cardiac Time (%)','FontSize',16)
    set(get(hfull.pfwaveform,'YLabel'),'String','Flow (mL/s)','FontSize',16)
    
       % Put the number labels on the CenterlinePlot
if branchLabeled ~= bnum
    delete(Ntxt)
    branchLabeled = bnum;
    index_branch = branchList(:,4) == branchLabeled;
    branchActual = branchList(index_branch,1:3);
    textint = [0:5:length(branchActual)-1];
    numString_val = num2str(textint);
    numString_val = strsplit(numString_val);

   Ntxt = text(branchActual(textint+1,2),branchActual(textint+1,1),branchActual(textint+1,3),numString_val,'Color','w','FontSize',14,'HitTest','off','PickableParts','none','Parent', fig.Children(2));
else
end

index_branch = branchList(:,4) == branchLabeled;
branchActual = branchList(index_branch,1:3);
blah = find(branchActual(:,1) == x2(ceil(length(x2)/2)));
blah2 = find(branchActual(blah,2) == y2(ceil(length(x2)/2)));
blah3 = find(branchActual(blah(blah2),3) ==z2(ceil(length(x2)/2)));
CurrentNum = blah(blah2(blah3))-1;

txt = {['Point Label:' , PointLabel , sprintf('\n'), ...
    'Pulsatility Index: ',sprintf('%0.3f',value), sprintf('\n'), ...
    'Average: ',sprintf('%0.3f',mean(average)), sprintf('\n'), ...
    'Current Branch #: ',sprintf('%i',CurrentNum)]};
   

end

