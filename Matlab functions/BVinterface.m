function varargout = BVinterface(varargin)
% BVINTERFACE MATLAB code for BVinterface.fig
%      BVINTERFACE, by itself, creates a new BVINTERFACE or raises the existing
%      singleton*.
%
%      H = BVINTERFACE returns the handle to a new BVINTERFACE or the handle to
%      the existing singleton*.
%
%      BVINTERFACE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BVINTERFACE.M with the given input arguments.
%
%      BVINTERFACE('Property','Value',...) creates a new BVINTERFACE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BVinterface_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BVinterface_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BVinterface

% Last Modified by GUIDE v2.5 20-Nov-2015 13:44:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BVinterface_OpeningFcn, ...
                   'gui_OutputFcn',  @BVinterface_OutputFcn, ...
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
end

% --- Executes just before BVinterface is made visible.
function BVinterface_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BVinterface (see VARARGIN)

%%% INITIAL VALUES

handles.blocks = struct('address',{},'contents',{},'timeStamp',{},'matrix',{}); % Structure containing data blocks recieved via UDP
handles.matrix = []; % 31xN matrix of channel voltages in time series
handles.times = []; % Vector contianing the time of each sample in handles.matrix
handles.record = false; % Variable for continuing to record
handles.plot = false; % Variable for plotting
handles.udp.connected = false;
handles.udp.localPort = 3000; % Make sure this port matches the one in the python code

% Choose default command line output for BVinterface
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes BVinterface wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = BVinterface_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

%%% Functions
function connect(ho,h)
h.udp.h = udp('localhost',h.udp.localPort,'LocalPort',h.udp.localPort,'InputBufferSize',131072,'InputDatagramPacketSize',65535); % Connect to port used by python program
fopen(h.udp.h);
h.udp.connected = true;
set(ho,'String','Connected')
guidata(ho,h);
end

function disconnect(ho,h,isButton)
fclose(h.udp.h);
clear h.udp.h
h.udp.connected = false;
if isButton
set(ho,'String','Connect')
end
guidata(ho,h);
end

function record(hObject)
handles = guidata(hObject);
%flushinput(handles.udp.h); % Flush buffer data for new recording
fclose(handles.udp.h)
fopen(handles.udp.h)
handles.blocks = struct('address',{},'contents',{},'timeStamp',{},'matrix',{}); % Structure containing data blocks recieved via UDP
handles.matrix = []; % 31xN matrix of channel voltages in time series
handles.times = []; % Vector contianing the time of each sample in handles.matrix
if handles.udp.connected;
while handles.record
    if get(handles.udp.h, 'BytesAvailable') > 0
        block = fread(handles.udp.h,1);
        handles.blocks(end+1) = unpackBlock(block); % Unpack the UDP message
		nSamples = size(handles.blocks(end).matrix,2);
		handles.matrix(1:31,end+1:end+nSamples)=handles.blocks(end).matrix;
		
		t = handles.blocks(end).timeStamp-handles.blocks(1).timeStamp;
		if t==0
			handles.times(1:nSamples) = [0:nSamples-1]./nSamples; % Don't know block period yet
		elseif length(handles.blocks)==2
			T = handles.blocks(end).timeStamp-handles.blocks(end-1).timeStamp; % Period of block update
			handles.times = handles.times*T; % Adjust the first vector to block period
            handles.times(end+1:end+nSamples) = [0:nSamples-1].*T./nSamples+t;
		else
			T = handles.blocks(end).timeStamp-handles.blocks(end-1).timeStamp; % Period of block update
			handles.times(end+1:end+nSamples) = [0:nSamples-1].*T./nSamples+t;
		end
		
		if handles.plot
			% Real time plotting?
		end
		
    end
    guidata(hObject,handles)
    pause(.02)
    handles = guidata(hObject);
end
end
set(hObject,'Value',false)
end


%%% Callbacks

function closereq(src,h)
if h.udp.connected
	disconnect(src,h,false)
end
delete(gcf)
end

function toggleConnect_Callback(hObject, ~, handles)
if get(hObject,'Value')
    connect(hObject,handles)
else
    disconnect(hObject,handles,true)
end
end

function toggleRecord_Callback(hObject, ~, handles)
handles.record = get(hObject,'Value');
guidata(hObject,handles)
if handles.record
    record(hObject)
end
end


function buttonSave_Callback(hObject, ~, handles)
struc.matrix = handles.matrix;
struc.times = handles.times;
save(['data\' datestr(clock,'yy-mm-dd HH_MM_SS')],'struc');
end

function buttonPlot_Callback(hObject, ~, handles)
figure
hold on
%plot(handles.times,handles.matrix(1,:),'k')
for channel = 1:31
	plot(handles.times,handles.matrix(channel,:),'k')
end
end
