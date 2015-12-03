function varargout = BVinterface(varargin)
% BVINTERFACE MATLAB code for BVinterface.fig
%      BVINTERFACE, by itself, creates a new BVINTERFACE or raises the existing
%      singleton*.
%
%      H = BVINTERFACE returns the handle to a new BVINTERFACE or the handle to
%      the existing singleton*.
%
%      BVINTERFACE('CALLBACK',hObject,eventData,h,...) calls the local
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
% See also: GUIDE, GUIDATA, GUIh

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
function BVinterface_OpeningFcn(hObject, eventdata, h, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)
% varargin   command line arguments to BVinterface (see VARARGIN)

%%% Add Tabs, since matlab doesn't have this in the GUIDE editor
h.plotSel = [1:31];
h.plotWindowabGroup = uitabgroup('Parent',h.panelPlots); % next try making it's parent a pannel
h.plotWindowabs(1) = uitab('Parent',h.plotWindowabGroup, 'Title','Channels');
h.plotWindowabs(2) = uitab('Parent',h.plotWindowabGroup, 'Title','Spectra');
h.plotWindowabs(3) = uitab('Parent',h.plotWindowabGroup, 'Title','Activity Distribution');
set(h.plotWindowabGroup,'SelectedTab',h.plotWindowabs(1));
set(h.plotWindowabGroup,'SelectionChangedFcn',@changeTab);

h.axesChannels = axes('Parent',h.plotWindowabs(1));
h.axesChannels.XLabel.String = 'Time (s)';
h.axesChannels.YLabel.String = 'Channel';  % figure out units at some point
h.axesChannels.Title.String = 'Relative Channel Voltages';
h.axesChannels.YLim				= [0, (length(h.plotSel)+1)];
h.axesChannels.YTick				= (1:length(h.plotSel));
h.axesChannels.YTickLabel			= num2str((h.plotSel)');

h.axesSpectra = axes('Parent',h.plotWindowabs(2));
h.axesSpectra.XLabel.String = 'Frequency (Hz)';
h.axesSpectra.YLabel.String = 'Intensity';
h.axesSpectra.Title.String = 'Frequency Spectrum';

h.axesActivity = axes('Parent',h.plotWindowabs(3));
h.axesActivity.Title.String = 'Node Activity';


%%% INITIAL VALUES
h.numChannels = 31; % Hard-coded as 31 channels for specific hardware
h.plotWindow = 1000; % Determines how often maltab will grab new memory space for data, and how wide the channels plot is in time (specified in number of time samples; 25 samples per data block)
h.T = 1/500; % The sampling period
h.block = struct('timeStamp',{},'matrix',{}); % Structure containing data blocks recieved via UDP
h.data.matrix = zeros([h.numChannels h.plotWindow*h.T*5]); % 31xN matrix of channel voltages in time series
h.data.normMatrix = h.data.matrix;
h.data.times = zeros([1 h.plotWindow*h.T*5]); % Vector contianing the time of each sample in h.data.matrix
h.c = 0;
h.p = 0;
h.range = 0.5;
h.record = false; % Variable for continuing to record
h.plot = false; % Variable for real-time plotting
h.udp.connected = false;
h.udp.localPort = 3000; % Make sure this port matches the one in the python code

% Choose default command line output for BVinterface
h.output = hObject;
% Update h structure
guidata(hObject, h);
% UIWAIT makes BVinterface wait for user response (see UIRESUME)
% uiwait(h.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = BVinterface_OutputFcn(hObject, eventdata, h) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% h    structure with h and user data (see GUIDATA)

% Get default command line output from h structure
varargout{1} = h.output;
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
	h = guidata(hObject);
	fclose(h.udp.h) % Crude way to flush UDP Buffer
	fopen(h.udp.h)
	h.data.matrix = zeros([h.numChannels h.plotWindow]); % 31xN matrix of channel voltages in time series
	h.data.normMatrix = zeros([h.numChannels h.plotWindow*5]);
	h.data.times = zeros([1 h.plotWindow*5]); % Vector contianing the time of each sample in h.data.matrix
    h.c=0;
    h.p=0;
    h.range = 0.5;
    cla(h.axesSpectra)
	cla(h.axesChannels) % Clear plots
	for channel = 1:h.numChannels   % Initialize line objects for plotting
		h.l.t(channel) = line(nan,nan,'Parent',h.axesChannels);
		h.l.f(channel) = line(nan,nan,'Parent',h.axesSpectra);
	end
	
	if h.udp.connected
	while h.record
		while get(h.udp.h, 'BytesAvailable') > 0  % Unpack all pending UDP Messages
			h = unpack(h); % Unpack the new UDP message, add the data to the array
            h.data.normMatrix(:,h.c-h.nSamples+1:h.c) = h.data.matrix(:,h.c-h.nSamples+1:h.c) - repmat(mean(h.data.matrix(:,1:h.c),2),[1 h.nSamples]);
		end
		if h.plot % Real time plotting enabled
             h = updatePlots(hObject,false);
		end
		drawnow;
		guidata(hObject,h)
		pause(.001) % This can be made smaller, if it runs slow on the processing side
		h = guidata(hObject);
	end
	end
	set(hObject,'Value',false)
end

function h = unpack(h)
	block = fread(h.udp.h,1);
	[block,valid] = unpackBlock(block,h.numChannels); % Unpack the UDP message
    if valid
	h.nSamples = size(block.matrix,2);
        if (h.c+h.nSamples)>length(h.data.times)  % Allocate another block of memory
            h.data.matrix(:,end+1:end+h.T) = zeros([h.numChannels h.T*5]);
            h.data.normMatrix(:,end+1:end+h.T) = zeros([h.numChannels h.T*5]);
            h.data.times(:,end+1:end+h.T*5) = zeros([1 h.T*5]);
        end
	h.data.matrix(1:31,h.c+1:h.c+h.nSamples)=block.matrix;
	if h.c==0
        t=0;
        h.ti = block.timeStamp;
    else
        t = block.timeStamp-h.ti;
    end
	if t==0
		T = 25*h.T; % guess
        h.data.times(1:h.nSamples) = [0:h.nSamples-1].*T./h.nSamples; % Don't know block period yet
	elseif length(block)==2
		T = block.timeStamp-h.block.timeStamp; % Period of block update
		h.data.times = h.data.times*T; % Adjust the first vector to block period
		h.data.times(h.c+1:h.c+h.nSamples) = [0:h.nSamples-1].*T./h.nSamples+t;
	else
		T = block.timeStamp-h.block.timeStamp; % Period of block update
		h.data.times(h.c+1:h.c+h.nSamples) = [0:h.nSamples-1].*T./h.nSamples+t;
	end
	h.c = h.c+h.nSamples;
    h.block = block;
    h.T = T/h.nSamples;
    end
end

function h = updatePlots(hObject,full)
h = guidata(hObject);
switch h.plotWindowabGroup.SelectedTab.Title
case {'Channels'} %%% Channels Plot
	axes(h.axesChannels)
	temp = max(max(abs(h.data.normMatrix)));
    if temp>h.range
        h.range = 1.6*temp;
    end
    h.axesChannels.YLim = [0, (length(h.plotSel)+1).*(h.range)];
    h.axesChannels.YTick = (1:length(h.plotSel)).*(h.range);
	h.axesChannels.YTickLabel = num2str((h.plotSel)');
	h.plotWindow = str2double(get(h.editWindow,'String'));
	h.axesChannels.XLim = [0, h.plotWindow*h.T];
    h.axesChannels.XTick = linspace(0,h.plotWindow*h.T,5);
	h.axesChannels.XTickLabel = num2str((h.axesChannels.XTick+(h.c-mod(h.c,h.plotWindow))*h.T)');

	counter = 0;
	if h.c>1
    for channel = h.plotSel
		counter = counter+1;
        %if h.c > h.plotWindow+1 && ~full  % full indicates fully replot data
        %    h.l.t(channel).YData(h.c-mod(h.c,h.plotwindow)-h.nSamples+1:h.c-mod(h.c,h.plotWindow)) = h.data.normMatrix(channel,h.c-h.nSamples+1:h.c)+counter*h.range;
		%else
			if h.c-h.plotWindow < 1
				start = 1;
			else
				start = h.c-h.plotWindow;
			end
            h.l.t(channel).XData = h.data.times(start:h.c);
            h.l.t(channel).YData = h.data.normMatrix(channel,start:h.c)+counter*h.range;
        %end
	end
	end
	
case {'Spectra'} %%% Frequency Plot
	axes(h.axesSpectra)
	if h.c > h.plotWindow
        Fs = 1/h.T; % Sampling Frequency
        h.f = Fs*(0:h.plotWindow/2)/h.plotWindow; % Frequcny list vector
        for channel = h.plotSel    % Fourier Transfor
            h.Y(channel,:) = fft(h.data.normMatrix(channel,h.c-h.plotWindow:h.c));
        end
        h.Y = abs(h.Y./h.plotWindow);  % Make one-sided, real
        h.Y = h.Y(:,1:h.plotWindow/2+1);
        h.Y(:,2:end-1) = 2*h.Y(:,2:end-1);
        
        for channel = h.plotSel
			if full || isempty(h.l.f(chanel))  % re-do frequency data too
				h.l.f(channel).XData = h.f;
			end
            h.l.f(channel).YData = h.Y;
		end
	end
	
case{'Activity Distribution'} %%% Activity Contour Plot
	% Contour plot of node activity, based on (area?)
end
end


%%% Callbacks

function closereq(src,h)
	if h.udp.connected
		disconnect(src,h,false)
	end
	delete(gcf)
end

function changeTab(hObject, ~)
updatePlots(hObject,true);
end

function toggleConnect_Callback(hObject, ~, h)
	if get(hObject,'Value')
		connect(hObject,h)
	else
		disconnect(hObject,h,true)
	end
end

function toggleRecord_Callback(hObject, ~, h)
	h.record = get(hObject,'Value');
	guidata(hObject,h)
	if h.record
		record(hObject)
	end
end

function buttonSave_Callback(hObject, ~, h)
	struc.matrix = h.data.matrix;
	struc.times = h.data.times;
	save(['data\' datestr(clock,'yy-mm-dd HH_MM_SS')],'struc');
end

function buttonTest_Callback(hObject, ~, h)
% Write code for a specific experiment
	% record
	% time-synced stimuli data
	% save structure, with name
end

function togglePlot_Callback(hObject, ~, h)
	h.plot = get(hObject,'Value');
	guidata(hObject,h)
	if h.record
		record(hObject)
	end
end

function listChannels_Callback(hObject, eventdata, h)
temp = get(hObject,'Value');
if any(temp==1)
	h.plotSel = [1:31];
elseif any(temp==2)
	h.plotSel = [];
else
	h.plotSel = temp-2;
end
guidata(hObject,h)
h = updatePlots(hObject,true);
end

function editWindow_Callback(hObject, ~, ~)
updatePlots(hObject,true);
end

% --- Executes during object creation, after setting all properties.
function listChannels_CreateFcn(hObject, eventdata, h)
% hObject    handle to listChannels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    empty - h not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes during object creation, after setting all properties.
function editWindow_CreateFcn(hObject, eventdata, h)
% hObject    handle to editWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% h    empty - h not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
