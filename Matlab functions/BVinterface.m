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

% Last Modified by GUIDE v2.5 01-Dec-2015 18:54:04

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

%%% Add Tabs, since matlab doesn't have this in the GUIDE editor
handles.plotSel = [1:31];
handles.plotWindowabGroup = uitabgroup('Parent',handles.panelPlots); % next try making it's parent a pannel
handles.plotWindowabs(1) = uitab('Parent',handles.plotWindowabGroup, 'Title','Channels');
handles.plotWindowabs(2) = uitab('Parent',handles.plotWindowabGroup, 'Title','Spectra');
handles.plotWindowabs(3) = uitab('Parent',handles.plotWindowabGroup, 'Title','Activity Distribution');
set(handles.plotWindowabGroup, 'SelectedTab',handles.plotWindowabs(1));

handles.axesChannels = axes('Parent',handles.plotWindowabs(1));
handles.axesChannels.XLabel.String = 'Time (s)';
handles.axesChannels.YLabel.String = 'Channel';  % figure out units at some point
handles.axesChannels.Title.String = 'Relative Channel Voltages';
handles.axesChannels.YLim				= [0, (length(handles.plotSel)+1)];
handles.axesChannels.YTick				= (1:length(handles.plotSel));
handles.axesChannels.YTickLabel			= num2str((handles.plotSel)');

handles.axesSpectra = axes('Parent',handles.plotWindowabs(2));
handles.axesSpectra.XLabel.String = 'Frequency (Hz)';
handles.axesSpectra.YLabel.String = 'Intensity';
handles.axesSpectra.Title.String = 'Frequency Spectrum';

handles.axesActivity = axes('Parent',handles.plotWindowabs(3));
handles.axesActivity.Title.String = 'Node Activity';


%%% INITIAL VALUES
handles.plotSel = [1:31];
handles.debug = false;
handles.numChannels = 31; % Hard-coded as 31 channels for specific hardware
handles.plotWindow = 5; % Determines how often maltab will grab new memory space for data, and how wide the channels plot is in time (specified in number of time samples; 25 samples per data block)
handles.freq = 1000; % Default, may be different
handles.block = struct('timeStamp',{},'matrix',{}); % Structure containing data blocks recieved via UDP
handles.data.matrix = zeros([handles.numChannels round(handles.plotWindow*handles.freq*5)]); % 31xN matrix of channel voltages in time series
handles.data.normMatrix = handles.data.matrix;
handles.data.times = zeros([1 round(handles.plotWindow*handles.freq*5)]); % Vector contianing the time of each sample in handles.data.matrix
handles.c = 0;
handles.p = 0;
handles.range = 0.5;
handles.record = false; % Variable for continuing to record
handles.plot = false; % Variable for real-time plotting
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
	%flushinput(handles.udp.h); % Flush buffer data for new recording; doesn't work
	fclose(handles.udp.h) % Bad way to flush the buffer; works
	fopen(handles.udp.h)
	handles.data.matrix = zeros([handles.numChannels handles.plotWindow]); % 31xN matrix of channel voltages in time series
	handles.data.normMatrix = zeros([handles.numChannels handles.plotWindow]);
	handles.data.times = zeros([1 handles.plotWindow]); % Vector contianing the time of each sample in handles.data.matrix
    handles.c=0;
    handles.p=0;
    handles.range = 0.5;
    handles.plotHandles = [];
    axes(handles.axesChannels)
	cla(handles.axesChannels) % Clear plot
	
	if handles.udp.connected
	while handles.record
		if get(handles.udp.h, 'BytesAvailable') > 0
            tic
            if handles.c > handles.plotWindow
                handles.debug = true;
            end
            
			handles = unpack(handles); % Unpack the new UDP message, add the data to the array
            sprintf('unpack: ')
            toc
            
            tic
            handles.data.normMatrix(:,handles.c-handles.nSamples+1:handles.c) = handles.data.matrix(:,handles.c-handles.nSamples+1:handles.c) - repmat(mean(handles.data.matrix(:,1:handles.c),2),[1 handles.nSamples]);            
            sprintf('norm: ')
            toc
            
            tic
			if handles.plot % Real time plotting
                handles = updatePlots(handles);
            end
            sprintf('plot: ')
            toc
		end
		guidata(hObject,handles)
		pause(.001) % This can be made smaller, if it runs slow on the processing side
		handles = guidata(hObject);
	end
	end
	set(hObject,'Value',false)
end

function handles = unpack(handles)
	block = fread(handles.udp.h,1);
	[block,valid] = unpackBlock(block,handles.numChannels); % Unpack the UDP message
    if valid
	handles.nSamples = size(block.matrix,2);
        if (handles.c+handles.nSamples)>length(handles.data.times)  % Allocate another block of memory
            handles.data.matrix(:,end+1:end+round(handles.plotWindow*handles.freq*5)) = zeros([handles.numChannels round(handles.plotWindow*handles.freq*5)]);
            handles.data.normMatrix(:,end+1:end+round(handles.plotWindow*handles.freq*5)) = zeros([handles.numChannels round(handles.plotWindow*handles.freq*5)]);
            handles.data.times(:,end+1:end+round(handles.plotWindow*handles.freq*5)) = zeros([1 round(handles.plotWindow*handles.freq*5)]);
        end
	handles.data.matrix(1:31,handles.c+1:handles.c+handles.nSamples)=block.matrix;
	if handles.c==0
        t=0;
        handles.ti = block.timeStamp;
    else
        t = block.timeStamp-handles.ti;
    end
	if t==0
		T = 0.05; % guess
        handles.data.times(1:handles.nSamples) = [0:handles.nSamples-1].*T./handles.nSamples; % Don't know block period yet
	elseif length(block)==2
		T = block.timeStamp-handles.block.timeStamp; % Period of block update
		handles.data.times = handles.data.times*T; % Adjust the first vector to block period
		handles.data.times(handles.c+1:handles.c+handles.nSamples) = [0:handles.nSamples-1].*T./handles.nSamples+t;
	else
		T = block.timeStamp-handles.block.timeStamp; % Period of block update
		handles.data.times(handles.c+1:handles.c+handles.nSamples) = [0:handles.nSamples-1].*T./handles.nSamples+t;
	end
	handles.c = handles.c+handles.nSamples;
    handles.block = block;
    handles.freq = handles.nSamples/(T);
    end
end

function handles = updatePlots(handles)
    temp = max(max(abs(handles.data.normMatrix)));
    if temp>handles.range
        handles.range = 1.6*temp;
    end
    %if handles.axesChannels.YLim ~= [0, (length(handles.plotSel)+1).*(handles.range)]; handles.axesChannels.YLim = [0, (length(handles.plotSel)+1).*(handles.range)];end
    %if handles.axesChannels.YTick~= (1:length(handles.plotSel)).*(handles.range); handles.axesChannels.YTick = (1:length(handles.plotSel)).*(handles.range); end
	%if handles.axesChannels.YTickLabel ~= num2str((handles.plotSel)');handles.axesChannels.YTickLabel = num2str((handles.plotSel)'); end
	%if handles.axesChannels.XLim ~= [0, handles.plotWindow];handles.axesChannels.XLim = [0, handles.plotWindow]; end
    %if size(handles.axesChannels.XTick) ~= size(0:0.5:floor(handles.plotWindow)); handles.axesChannels.XTick = 0:0.5:floor(handles.plotWindow);end
    handles.axesChannels.YLim = [0, (length(handles.plotSel)+1).*(handles.range)];
    handles.axesChannels.YTick = (1:length(handles.plotSel)).*(handles.range);
	handles.axesChannels.YTickLabel = num2str((handles.plotSel)');
	%handles.axesChannels.XLim = [0, handles.plotWindow];
    %handles.axesChannels.XTick = 0:0.5:floor(handles.plotWindow);

	counter = 0;
	if handles.c>1
    for channel = handles.plotSel
		counter = counter+1;
        if handles.c > handles.plotWindow*handles.freq+1
            handles.l(channel).YData(handles.p+1:handles.p+handles.nSamples) = handles.data.normMatrix(channel,handles.c-handles.nSamples+1:handles.c)+counter*handles.range;
        else
            if handles.p ==0
            handles.l(channel) = line(nan, nan);
            end
            handles.l(channel).XData = handles.data.times(1:handles.c);
            handles.l(channel).YData = handles.data.normMatrix(channel,1:handles.c)+counter*handles.range;
            
        end
    end
    handles.p = mod(handles.c,round(handles.plotWindow*handles.freq));
	%{
	if handles.c > handles.plotWindow	
        % Fourier Transform
        T = handles.data.times(handles.c)-handles.data.times(handles.c-1);
        Fs = 1/T; % Sampling Frequency
        f = Fs*(0:handles.plotWindow/2)/handles.plotWindow; % Frequcny list vector
        for channel = handles.plotSel
            handles.Y(channel,:) = fft(handles.data.normMatrix(channel,handles.c-handles.plotWindow:handles.c));
        end
        handles.Y = abs(handles.Y./handles.plotWindow);  % Make one-sided, real
        handles.Y = handles.Y(:,1:handles.plotWindow/2+1);
        handles.Y(:,2:end-1) = 2*handles.Y(:,2:end-1);
        axes(handles.axesSpectra)
        cla(handles.axesSpectra)
        hold on
        for channel = handles.plotSel
            plot(f,handles.Y(channel,:))
        end
        hold off
    end
    %}
    end
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
	struc.matrix = handles.data.matrix;
	struc.times = handles.data.times;
	save(['data\' datestr(clock,'yy-mm-dd HH_MM_SS')],'struc');
end

function buttonTest_Callback(hObject, ~, handles)
% Write code for a specific experiment
	% record
	% time-synced stimuli data
	% save structure, with name
end

function togglePlot_Callback(hObject, ~, handles)
	handles.plot = get(hObject,'Value');
	guidata(hObject,handles)
	if handles.record
		record(hObject)
	end
end

function listChannels_Callback(hObject, eventdata, handles)
temp = get(hObject,'Value');
if any(temp==1)
	handles.plotSel = [1:31];
elseif any(temp==2)
	handles.plotSel = [];
else
	handles.plotSel = temp-2;
end
handles = updatePlots(handles);
guidata(hObject,handles)
end

function editWindow_Callback(hObject, eventdata, handles)
% hObject    handle to editWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.plotWindow = str2double(get(hObject,'String'));
handles.axesChannels.XLim = [0, handles.plotWindow];
handles.axesChannels.XTick = 0:0.5:floor(handles.plotWindow);
handles = updatePlots(handles);
% Hints: get(hObject,'String') returns contents of editWindow as text
%         returns contents of editWindow as a double
end

% --- Executes during object creation, after setting all properties.
function listChannels_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listChannels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes during object creation, after setting all properties.
function editWindow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
