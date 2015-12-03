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

% Last Modified by GUIDE v2.5 03-Dec-2015 17:48:36

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
h.colorList = jet(h.numChannels); % Generate a lsit of RGB values for plotting
h.plotWindow = 1000; % Determines how often maltab will grab new memory space for data, and how wide the channels plot is in time (specified in number of time samples; 25 samples per data block)
h.T = 1/500; % The sampling period
h.block = struct('timeStamp',{},'matrix',{}); % Structure containing data blocks recieved via UDP
h.data.matrix = zeros([h.numChannels h.plotWindow*h.T*5]); % 31xN matrix of channel voltages in time series
h.data.normMatrix = h.data.matrix;
h.data.times = zeros([1 h.plotWindow*h.T*5]); % Vector contianing the time of each sample in h.data.matrix
h.data.valid = false(size(h.data.times)); % Vector specifying whether a time has valid data with it
h.c = 0;
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
    warning('off','MATLAB:gui:array:InvalidArrayShape');  % Be sure to turn this on if debugging plotting problems
	fclose(h.udp.h) % Crude way to flush UDP Buffer
	fopen(h.udp.h)
	h.data.matrix = zeros([h.numChannels h.plotWindow*5]); % 31xN matrix of channel voltages in time series
	h.data.normMatrix = zeros([h.numChannels h.plotWindow*5]);
	h.data.times = zeros([1 h.plotWindow*5]); % Vector contianing the time of each sample in h.data.matrix
    h.data.valid = false(size(h.data.times));
    h.c=0;
    h.new = false;
    h.range = 0.5;
    cla(h.axesSpectra)
	cla(h.axesChannels) % Clear plots
	for channel = 1:h.numChannels   % Initialize line objects for plotting
		h.l.t(channel) = line(nan,nan,'Parent',h.axesChannels);
		h.l.f(channel) = line(nan,nan,'Parent',h.axesSpectra);
        %h.l.t(channel).Color = h.colorList(channel,:); % rainbow!
        h.l.f(channel).Color = h.colorList(channel,:); %
    end
	if h.udp.connected
	while h.record
		while get(h.udp.h, 'BytesAvailable') > 0  % Unpack all pending UDP Messages
			h = unpack(h); % Unpack the new UDP message, add the data to the array
            %h.data.normMatrix(:,h.c-h.nSamples+1:h.c) = h.data.matrix(:,h.c-h.nSamples+1:h.c) - repmat(mean(h.data.matrix(:,1:h.c),2),[1 h.nSamples]);
            h.data.normMatrix(:,h.c-h.nSamples+1:h.c) = h.data.matrix(:,h.c-h.nSamples+1:h.c) - repmat(mean(h.data.matrix(:,h.data.valid),2),[1 h.nSamples]);
            h.new = true;
		end
		if h.plot && h.new % Real time plotting enabled
             h = updatePlots(h);
             h.new = false;
		end
		%drawnow;
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
            h.data.matrix(:,end+1:end+h.plotWindow*5) = zeros([h.numChannels h.plotWindow*5]);
            h.data.normMatrix(:,end+1:end+h.plotWindow*5) = zeros([h.numChannels h.plotWindow*5]);
            h.data.times(:,end+1:end+h.plotWindow*5) = zeros([1 h.plotWindow*5]);
        end
	if h.c==0
        t=0;
        h.ti = block.timeStamp;
    else
        t = block.timeStamp-h.ti;
    end
    
	if h.c==0
        h.data.times(1:h.nSamples) = [0:h.nSamples-1].*h.T; % Don't know block period yet
        h.data.valid(1:h.nSamples) = true;
	elseif h.c==h.nSamples;
        h.T = (block.timeStamp-h.block.timeStamp)/h.nSamples; % Confirm sample period
		h.data.times(1:h.nSamples) = [0:h.nSamples-1].*h.T; % Adjust the first vector to block period
		h.data.times(h.c+1:h.c+h.nSamples) = [0:h.nSamples-1].*h.T+t;
        h.data.valid(h.c+1:h.c+h.nSamples) = true;
    else
       diff = abs(h.data.times(h.c)+h.T-t);
        if abs(diff)>0.5*h.T  % some sample(s) have been skipped
            skipped = round(diff/h.T);
            h.data.times(h.c+1:h.c+skipped) = (1:skipped)*h.T+h.data.times(h.c);
            h.c = h.c+skipped;
        end
		h.data.times(h.c+1:h.c+h.nSamples) = [0:h.nSamples-1].*h.T+t;
        h.data.valid(h.c+1:h.c+h.nSamples) = true;
    end
    h.data.matrix(1:31,h.c+1:h.c+h.nSamples)=block.matrix;
	h.c = h.c+h.nSamples;
    h.block = block;        
    end
end

function h = updatePlots(h)
temp = get(h.listChannels,'Value');
if any(temp==1)
	h.plotSel = [1:31];
elseif any(temp==2)
	h.plotSel = [];
else
	h.plotSel = temp-2;
end
switch get(h.plotWindowabGroup.SelectedTab,'Title')
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

	if h.c>1
        if h.c-h.plotWindow < 1
			start = 1;
		else
			start = h.c-h.plotWindow;
		end
    set(h.l.t,'XData',h.data.times(start:h.c));
    set(h.l.t,'YData',-10.*ones(size(h.l.t(1).XData)));
    h.axesChannels.XLim = [h.l.t(1).XData(1), h.l.t(1).XData(end)];
    counter = 0;
    for channel = h.plotSel
		counter = counter+1;
        h.l.t(channel).YData = h.data.normMatrix(channel,start:h.c)+counter*h.range;
    end
	end
	
case {'Spectra'} %%% Frequency Plot
	axes(h.axesSpectra)
    h.plotWindow = str2double(get(h.editWindow,'String'));
	if h.c > h.plotWindow && ~isempty(h.plotSel)
        Fs = 1/h.T; % Sampling Frequency
        f = Fs*(0:h.plotWindow/2)/h.plotWindow; % Frequcny list vector
        for channel = h.plotSel    % Fourier Transfor
            Y = fft(h.data.normMatrix(channel,h.c-h.plotWindow:h.c));
            h.Y(channel,1:numel(Y)) = Y;
        end
        h.Y = abs(h.Y./h.plotWindow);  % Make one-sided, real
        h.Y = h.Y(:,1:h.plotWindow/2+1);
        h.Y(:,2:end-1) = 2*h.Y(:,2:end-1);
        
        set(h.l.f,'XData',f);
        set(h.l.f,'YData',zeros(size(f)));
        for channel = h.plotSel
            h.l.f(channel).YData = h.Y(channel,:);
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
updatePlots(guidata(hObject));
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
struc.matrix = h.data.matrix(h.data.valid); % save only the data/time samples with good data
struc.times = h.data.times(h.data.valid);
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

function listChannels_Callback(hObject, ~, h)
h = updatePlots(h);
end

function editWindow_Callback(hObject, ~, h)
updatePlots(h);
end

function sliderWindow_Callback(hObject, ~, h)
set(h.editWindow,'Value',round(5000*get(hObject,'Value'))+1);
set(h.editWindow,'String',num2str(round(5000*get(hObject,'Value'))+1));
h.plotWindow = round(5000*get(hObject,'Value'))+1;
drawnow;
h = updatePlots(h);
end


% --- Executes during object creation, after setting all properties.
function listChannels_CreateFcn(hObject, eventdata, h)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function editWindow_CreateFcn(hObject, eventdata, h)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function sliderWindow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end