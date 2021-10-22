function varargout = GUI(varargin)
% GUI MATLAB code for GUI.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI

% Last Modified by GUIDE v2.5 22-Oct-2021 03:48:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
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


% --- Executes just before GUI is made visible.
function GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI (see VARARGIN)

fetched = 0;
%to check if the data is loaded properly
handles.fetched = fetched; 


% Choose default command line output for GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;




% --- Executes on button press in Browse_Pushbutton.
function Browse_Pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Browse_Pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile({'*.mat'}, 'File Browser');

%global fetched;

if (filename)
    
    fullpathname = strcat(pathname, filename);
    datastruct = load(fullpathname);
    %explain fieldnames.. how the data was before and after
    
    %the data loaded will be in the form of struct arrays
    %A structure array is a data type that groups related data using data containers called fields. 
    %Each field can contain any type of data. 
    %Access data in a field using dot notation of the form structName.fieldName.
    fields = fieldnames(datastruct);
    signal = datastruct.(fields{1});
    [infofilename, infopathname] = uigetfile('/*.info', 'Select info file');
   
    if (infofilename)
        handles.fetched = 1;
        infofullpathname = strcat (infopathname, infofilename);
        infofile = fopen(infofullpathname);
        %skip 3 lines to get to sampling
        fgetl(infofile);
        fgetl(infofile);
        fgetl(infofile);
        [sampling] = sscanf(fgetl(infofile), 'Sampling frequency: %f Hz  Sampling interval: %f sec');
        fs = sampling(1);
        interval = sampling(2);

        fgetl(infofile);
        %sprintf() translates '\t'
        %infoarray = split(fgetl(infofile), sprintf('\t'));%sprintf('\t') is a workaround to type 'tab' character
        %infoarray now is 5x1 array 

        [Row, Signal, Gain, Base, Units] = strread(fgetl(infofile), '%f%s%f%f%s', 'delimiter', '\t');
        %info = [sampfreq, sampint, Gain, Base, Units];
        %tried textscan and had errors
        fclose(infofile);

        global i;
        i = 1; %increment for the x axis
        handles.datastruct = datastruct;
        handles.interval = interval;
        handles.fs = fs;
        handles.Gain = Gain;
        handles.Base = Base;
        handles.Units = Units;
        handles.signal = signal;
    
    else
        disp('No info file chosen!')
       
    end
    
else
    disp('No data!')
end


handles.plot_pressed = 0;

guidata(hObject, handles);
  


% --- Executes on button press in Play_Togglebutton.
function Play_Togglebutton_Callback(hObject, eventdata, handles)
% hObject    handle to Play_Togglebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Play_Togglebutton
global i;
handles.plot_pressed = 1;

%global fetched; %bad practice

fprintf('fetched = %1.0f \n', handles.fetched);

if (handles.fetched)
    n = size(handles.signal,2);
    disp(n);
    
    %assigning certain axes for the signal
    %in hope of getting the spectrogram in the other axes
    handles.run = 1;
    
    y = (handles.signal-handles.Base)/handles.Gain;

        %x = (0:size(handles.data,2)-1)*handles.interval;
        x = (0 : size(handles.signal,2)-1)*handles.interval;
        low_limit = min(y)*1.5;
        high_limit = max(y)*1.5;
        fov = 1.5*handles.fs; %from 0 to fov will be the field of view on the x axis
        
        handles.x = x;
        handles.y = y;
        handles.low_limit = low_limit;
        handles.high_limit = high_limit;
        handles.fov = fov;
    
    axes(handles.axes5);
    spectrogram(handles.signal, 'yaxis')
    %only woked when moved outside of the loop 
    %apparently the loop had errors but it waited til it's done
    
        
    axes(handles.axes1);

    while((get(hObject,'Value')) && (i <= n-(1.5*handles.fs)))
            
            %hard coded for simplicity %not anymore
        
            plot(handles.axes1, x, y); %assigning axes4 is mandatory to prevent plotting in external windows
            axis([x(i) x(fov+i) low_limit high_limit]);
            ylabel(handles.Units);

            drawnow;
            
            i = i + 1;

    end
    
   % handles.plot_pressed = 0;
   % set(hObject, 'Value', 0);
   
   toggle_state = get(hObject, 'Value');
   handles.toggle_state = toggle_state;
   
   while(toggle_state==0)
       pause
   end
    
else
    %handles.plot_pressed = 0;
    %set(hObject, 'Value', 0);

end



% --- Executes on button press in Browse_Pushbutton.
function Browse2_Pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Browse_Pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile({'*.mat'}, 'File Browser');

%global fetched;

if (filename)
    
    fullpathname = strcat(pathname, filename);
    datastruct = load(fullpathname);
    %explain fieldnames.. how the data was before and after
    
    %the data loaded will be in the form of struct arrays
    %A structure array is a data type that groups related data using data containers called fields. 
    %Each field can contain any type of data. 
    %Access data in a field using dot notation of the form structName.fieldName.
    fields = fieldnames(datastruct);
    signal = datastruct.(fields{1});
    [infofilename, infopathname] = uigetfile('/*.info', 'Select info file');
   
    if (infofilename)
        handles.fetched2 = 1;
        infofullpathname = strcat (infopathname, infofilename);
        infofile = fopen(infofullpathname);
        %skip 3 lines to get to sampling
        fgetl(infofile);
        fgetl(infofile);
        fgetl(infofile);
        [sampling] = sscanf(fgetl(infofile), 'Sampling frequency: %f Hz  Sampling interval: %f sec');
        fs = sampling(1);
        interval = sampling(2);

        fgetl(infofile);
        %sprintf() translates '\t'
        %infoarray = split(fgetl(infofile), sprintf('\t'));%sprintf('\t') is a workaround to type 'tab' character
        %infoarray now is 5x1 array 

        [Row, Signal, Gain, Base, Units] = strread(fgetl(infofile), '%f%s%f%f%s', 'delimiter', '\t');
        %info = [sampfreq, sampint, Gain, Base, Units];
        %tried textscan and had errors
        fclose(infofile);

        global i2;
        i2 = 1; %increment for the x axis
        handles.datastruct2 = datastruct;
        handles.interval2 = interval;
        handles.fs2 = fs;
        handles.Gain2 = Gain;
        handles.Base2 = Base;
        handles.Units2 = Units;
        handles.signal2 = signal;
    
    else
        disp('No info file chosen!')
       
    end
    
else
    disp('No data!')
end


handles.plot_pressed2 = 0;

guidata(hObject, handles);
  


% --- Executes on button press in Play_Togglebutton.
function Play2_Togglebutton_Callback(hObject, eventdata, handles)
% hObject    handle to Play_Togglebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Play_Togglebutton
global i2;
handles.plot_pressed2 = 1;

%global fetched; %bad practice

fprintf('fetched = %1.0f \n', handles.fetched2);

if (handles.fetched2)
    n = size(handles.signal2,2);
    disp(n);
    
    %assigning certain axes for the signal
    %in hope of getting the spectrogram in the other axes
    handles.run2 = 1;
    
    y = (handles.signal2-handles.Base2)/handles.Gain2;

        %x = (0:size(handles.data,2)-1)*handles.interval;
        x = (0 : size(handles.signal2,2)-1)*handles.interval2;
        low_limit = min(y)*1.5;
        high_limit = max(y)*1.5;
        fov = 1.5*handles.fs2; %from 0 to fov will be the field of view on the x axis
        
        handles.x2 = x;
        handles.y2 = y;
        handles.low_limit2 = low_limit;
        handles.high_limit2 = high_limit;
        handles.fov2 = fov;
    
    axes(handles.axes5);
    spectrogram(handles.signal2, 'yaxis')
    %only woked when moved outside of the loop 
    %apparently the loop had errors but it waited til it's done
    
        
    axes(handles.axes2);

    while((get(hObject,'Value')) && (i2 <= n-(1.5*handles.fs2)))
            
            %hard coded for simplicity %not anymore
        
            plot(handles.axes2, x, y); %assigning axes4 is mandatory to prevent plotting in external windows
            axis([x(i2) x(fov+i2) low_limit high_limit]);
            ylabel(handles.Units2);

            drawnow;
            
            i2 = i2 + 1;

    end
    
   % handles.plot_pressed = 0;
   % set(hObject, 'Value', 0);
   
   toggle_state = get(hObject, 'Value');
   handles.toggle_state2 = toggle_state;
   
   while(toggle_state==0)
       pause
   end
    
else
    %handles.plot_pressed = 0;
    %set(hObject, 'Value', 0);

end


% --- Executes on button press in Browse_Pushbutton.
function Browse3_Pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Browse_Pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile({'*.mat'}, 'File Browser');

%global fetched;

if (filename)
    
    fullpathname = strcat(pathname, filename);
    datastruct = load(fullpathname);
    %explain fieldnames.. how the data was before and after
    
    %the data loaded will be in the form of struct arrays
    %A structure array is a data type that groups related data using data containers called fields. 
    %Each field can contain any type of data. 
    %Access data in a field using dot notation of the form structName.fieldName.
    fields = fieldnames(datastruct);
    signal = datastruct.(fields{1});
    [infofilename, infopathname] = uigetfile('/*.info', 'Select info file');
   
    if (infofilename)
        handles.fetched3 = 1;
        infofullpathname = strcat (infopathname, infofilename);
        infofile = fopen(infofullpathname);
        %skip 3 lines to get to sampling
        fgetl(infofile);
        fgetl(infofile);
        fgetl(infofile);
        [sampling] = sscanf(fgetl(infofile), 'Sampling frequency: %f Hz  Sampling interval: %f sec');
        fs = sampling(1);
        interval = sampling(2);

        fgetl(infofile);
        %sprintf() translates '\t'
        %infoarray = split(fgetl(infofile), sprintf('\t'));%sprintf('\t') is a workaround to type 'tab' character
        %infoarray now is 5x1 array 

        [Row, Signal, Gain, Base, Units] = strread(fgetl(infofile), '%f%s%f%f%s', 'delimiter', '\t');
        %info = [sampfreq, sampint, Gain, Base, Units];
        %tried textscan and had errors
        fclose(infofile);

        global i3;
        i3 = 1; %increment for the x axis
        handles.datastruct3 = datastruct;
        handles.interval3 = interval;
        handles.fs3 = fs;
        handles.Gain3 = Gain;
        handles.Base3 = Base;
        handles.Units3 = Units;
        handles.signal3 = signal;
    
    else
        disp('No info file chosen!')
       
    end
    
else
    disp('No data!')
end


handles.plot_pressed3 = 0;

guidata(hObject, handles);
  


% --- Executes on button press in Play_Togglebutton.
function Play3_Togglebutton_Callback(hObject, eventdata, handles)
% hObject    handle to Play_Togglebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Play_Togglebutton
handles.plot_pressed3 = 1;
global i3;
%global fetched; %bad practice

fprintf('fetched = %1.0f \n', handles.fetched3);

if (handles.fetched3)
    n = size(handles.signal3,2);
    disp(n);
    
    %assigning certain axes for the signal
    %in hope of getting the spectrogram in the other axes
    handles.run3 = 1;
    
    y = (handles.signal3-handles.Base3)/handles.Gain3;

        %x = (0:size(handles.data,2)-1)*handles.interval;
        x = (0 : size(handles.signal3,2)-1)*handles.interval3;
        low_limit = min(y)*1.5;
        high_limit = max(y)*1.5;
        fov = 1.5*handles.fs3; %from 0 to fov will be the field of view on the x axis
        
        handles.x3 = x;
        handles.y3 = y;
        handles.low_limit3 = low_limit;
        handles.high_limit3 = high_limit;
        handles.fov3 = fov;
    
    axes(handles.axes5);
    spectrogram(handles.signal3, 'yaxis')
    %only woked when moved outside of the loop 
    %apparently the loop had errors but it waited til it's done
    
        
    axes(handles.axes3);

    while((get(hObject,'Value')) && (i3 <= n-(1.5*handles.fs3)))
            
            %hard coded for simplicity %not anymore
        
            plot(handles.axes3, x, y); %assigning axes4 is mandatory to prevent plotting in external windows
            axis([x(i3) x(fov+i3) low_limit high_limit]);
            ylabel(handles.Units3);

            drawnow;
            
            i3 = i3 + 1;

    end
    
   % handles.plot_pressed = 0;
   % set(hObject, 'Value', 0);
   
   toggle_state = get(hObject, 'Value');
   handles.toggle_state3 = toggle_state;
   
   while(toggle_state==0)
       pause
   end
    
else
    %handles.plot_pressed = 0;
    %set(hObject, 'Value', 0);

end
