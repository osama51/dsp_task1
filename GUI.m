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

% Last Modified by GUIDE v2.5 16-Oct-2021 15:09:54

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

%dataset 1

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


% --- Executes on button press in Pause_Pushbutton.
function Pause_Pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Pause_Pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in Browse_Pushbutton.
function Browse_Pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Browse_Pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile({'*.mat'}, 'File Browser');

global fetched;
fetched = 0;
if (filename)
    
    fullpathname = strcat(pathname, filename);
    data = load(fullpathname);
    %explain fieldnames.. how the data was before and after
    fields = fieldnames(data);
    signal = data.(fields{1});
    [infofilename, infopathname] = uigetfile('/*.info', 'Select info file');
   
    if (infofilename)
        fetched = 1;
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

        handles.data = data;
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




guidata(hObject, handles);



% --- Executes on button press in Plot_Pushbutton.
function Plot_Pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Plot_Pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global fetched;

fprintf('fetched = %1.0f \n', fetched);



if (fetched)
    y = (handles.signal-handles.Base)/handles.Gain;
    %((size(handles.data)-1)*handles.sampint)
    %x = (0:size(handles.data,2)-1)*handles.interval;
    x = 0 : size(handles.signal,2)-1;
    
    n = size(handles.signal,2)-1;
    disp(n);
   
    for i = 1:n
    
        plot(1:1000+i, y(1:2*handles.fs+i))
        ylabel(handles.Units)
       axis([i 1000+i -1 1])
    
       drawnow
    end
    
    spectrogram(handles.signal, 'axes2')
end
     
    
