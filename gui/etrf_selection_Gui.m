function GUI
% GUI for selection of ETrf-NDVI relationship pixels

%  Create and then hide the UI as it is being constructed.
f = figure('Visible','off','Position',[10,10,1100,900]);

% Construct the components.
hselectPOINT  = uicontrol('Style','pushbutton','ForegroundColor','red',...
             'String','Select Pixel','Position',[950,170,120,25],...
            'Callback',{@selectPOINTbutton_Callback});    
        
hdeletePOINT  = uicontrol('Style','pushbutton','ForegroundColor','red',...
             'String','Delete Pixel','Position',[950,140,120,25],...
            'Callback',{@deletePOINTbutton_Callback}); 

hredraw   = uicontrol('Style','pushbutton',...
             'String','Reset Axis','Position',[950,220,70,25],...
            'Callback',{@redrawbutton_Callback});
         
htext  = uicontrol('Style','text','String','Select Data',...
           'Position',[950,300,60,15]);
hpopup = uicontrol('Style','popupmenu',...
           'String',{'RGB','ETrf','NDVI','LAI','Ts'},...
           'Position',[950,270,100,25],...
           'Callback',@popup_menu_Callback);

ha = axes('Units','pixels','Position',[100,100,828,750]);

align([hredraw,htext,hpopup,hselectPOINT,hdeletePOINT],'Center','None');


% Initialize the UI.
% Change units to normalized so components resize automatically.
f.Units = 'normalized';
ha.Units = 'normalized';
hredraw.Units = 'normalized';
htext.Units = 'normalized';
hpopup.Units = 'normalized';
hselectPOINT.Units = 'normalized';
hdeletePOINT.Units = 'normalized';

% Get the data to plot.
RGB=evalin('base','RGB');
ETrf=evalin('base','ETrf');
NDVI=evalin('base','NDVI');
LAI=evalin('base','LAI');
Ts=evalin('base','Ts');
try
    points=evalin('base','points');
catch
    points=[1;1];
end
x=points(1,:);
y=points(2,:);


%load colormap file
handles=load('cmap.mat');

%set color ranges for each thematic map.
handles.colormaprange{1}=[0,1];
handles.colormaprange{2}=[-0.05,1.05];
handles.colormaprange{3}=[-1,1];
handles.colormaprange{4}=[0,prctile(prctile(LAI,95),95)];
handles.colormaprange{5}=[prctile(prctile(Ts,5),5),prctile(prctile(Ts,95),95)];
handles.index=1;


% Create a plot in the axes.
current_data = RGB;
handles.NDVIvec(1)=1;
handles.ETrfvec(1)=1;
imagesc(current_data);
hold on;
hpoints=scatter(x,y,'*','yellow');
hold off;
axis equal;
colorbar;
colormap(handles.cmap_RGB);

% Assign a name to appear in the window title.
f.Name = 'Anchor Pixel Selection GUI';


% Move the window to the center of the screen.
movegui(f,'center');
f.Visible = 'on';
%  Pop-up menu callback. Read the pop-up menu Value property to
%  determine which item is currently displayed and make it the
%  current data. This callback automatically has access to 
%  current_data because this function is nested at a lower level.
   function popup_menu_Callback(source,eventdata) 
      % Determine the selected data set.
      str = source.String;
      val = source.Value;
      % Set current data to the selected data set.
      tmp=gca;
      XLim=tmp.XLim;
      YLim=tmp.YLim;
      switch str{val};
      case 'RGB' 
         current_data = RGB;
         handles.index=1;
         colormap(ha,handles.cmap_RGB);
      case 'ETrf' 
         current_data = ETrf;
         handles.index=2;
         colormap(ha,jet);
      case 'NDVI' 
         current_data = NDVI;
         handles.index=3;
         colormap(ha,handles.cmap_NDVI);
      case 'LAI' 
         current_data = LAI;
         handles.index=4;
         colormap(ha,handles.cmap_LAI);
      case 'Ts' 
         current_data = Ts;
         handles.index=5;
         colormap(ha,handles.cmap_Ts);
      end
      
      imagesc(current_data);
      axis equal;
      axis([XLim(1) XLim(2) YLim(1) YLim(2)]);
      hold on;
      hpoints=scatter(x,y,'*','yellow');
      colorbar;
      caxis(handles.colormaprange{handles.index});
      hold off;
   end
     
   function redrawbutton_Callback(source,eventdata,x,y) 
        imagesc(current_data);
        axis equal;
        colorbar;
        caxis(handles.colormaprange{handles.index});
        hold on;
        hpoints=scatter(x,y,'*','yellow');
        hold off;
   end

    function selectPOINTbutton_Callback(source,eventdata) 
        [x(end+1),y(end+1)]=myginput(1,'crosshair');
        disp(length(x));
        hold on;
        delete(hpoints);
        hpoints=scatter(x,y,'*','yellow');
        hold off;
        assignin('base', 'points', [x;y]);
    end

    function deletePOINTbutton_Callback(source,eventdata) 
        x=x(1:end-1);
        y=y(1:end-1);
        disp(length(x));
        hold on;
        delete(hpoints);
        hpoints=scatter(x,y,'*','yellow');
        hold off;
        assignin('base', 'points', [x;y]);
    end

end