function varargout = BVinterface(varargin)
% How to use this GUI:
% (1) Click the 'connect' button (once finished, it should change to 'connected').
% (2) Click the 'record' button. The GUI is now awaiting data over the UDP connection.
% (3) Begin collecting data on the python driver.
% (4) When finished, click the 'record' button again to stop reading the UDP connection.
% (5) ** Before closing, click the 'connected' button to disconnect. **
%		 If you don't, the port will remain bound and you must restart matlab entirely before you can connect again.
%
% (optional) Save the data to the \data\ folder by clicking the 'save' button.
% (optional) Enable real-time plotting by toggling the 'plot' button. Do this before redocrding.
% (optional) Select which channels to plot data from by selecting from the 'Channels to Plot' list.
%			 This can be done before or after recording.
% (optional) Change the number of samples used in the plots by editing the 'Plot Window' field, or by moving the slider.
%		     This can be done before or after recording.

% (future)	 Run a pre-written exprimental procedure by clicking the 'Start Test' button.
%			 (This should also come with a list to select from, populated with experimental procedure files in a folder.)


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

function BVinterface_OpeningFcn(hObject, ~, h, varargin)
% Executes just before BVinterface is made visible.

%%% INITIAL VALUES
h.numChannels = 31;	% Hard-coded as 31 channels for specific hardware. Change this if you get more channels.
h.colorList = jet(h.numChannels); % Generate a lsit of RGB values for plotting individual channels
h.plotWindow = 1000; % Determines how many samples are considered in plotting the channels/frequency plots
					 % This also determines the size of the memory block maltab will allocate for data
h.T = 0.002; % The sampling period, in seconds (this is a guessed vlaue, but it is updated once recording starts)
h.data.matrix = zeros([h.numChannels h.plotWindow*h.T*5]); % Empty matrix to store time series of node potentials
h.data.normMatrix = h.data.matrix; % Tempty matrix to store data after removing DC offsets
h.data.times = zeros([1 h.plotWindow*h.T*5]); % Vector contianing the time of each sample in h.data.matrix
h.data.valid = false(size(h.data.times)); % Vector specifying whether a time has valid data with it
h.c = 0; % Variable used to mark the "current" sample index (e.g. the most recent)
h.range = 0.5; % Variable specifying the range of the data set (it gets updated from this arbitrarty value)
h.record = false; % Variable for continuing to do the record loop
h.plot = false; % Variable for doing real-time plotting
h.udp.connected = false; % Stores the UDP connection status (connected/disconnected)
h.udp.localPort = 3000; % Hard-coded UDP port - make sure this port matches the port in the python code!
h.plotSel = 1:h.numChannels; % Variable specifying which channels to plot (default is all of them)

%%% Manually add tabs, since matlab doesn't have them in the GUIDE editor
h.plotWindowabGroup = uitabgroup('Parent',h.panelPlots);
h.plotWindowabs(1)  = uitab     ('Parent',h.plotWindowabGroup, 'Title','Channels');
h.plotWindowabs(2)  = uitab     ('Parent',h.plotWindowabGroup, 'Title','Spectra');
h.plotWindowabs(3)  = uitab     ('Parent',h.plotWindowabGroup, 'Title','Activity'); % Add as many of these as you want for displayign different stuff
set(h.plotWindowabGroup,'SelectedTab',h.plotWindowabs(1));
set(h.plotWindowabGroup,'SelectionChangedFcn',@changeTab);

h.axesChannels = axes('Parent',h.plotWindowabs(1));
h.axesChannels.XLabel.String = 'Time (s)';
h.axesChannels.YLabel.String = 'Channel';
h.axesChannels.Title.String  = 'Relative Channel Voltages';
h.axesChannels.YLim			 = [0, (length(h.plotSel)+1)];
h.axesChannels.YTick		 = (1:length(h.plotSel));
h.axesChannels.YTickLabel	 = num2str((h.plotSel)');

h.axesSpectra = axes('Parent',h.plotWindowabs(2));
h.axesSpectra.XLabel.String = 'Frequency (Hz)';
h.axesSpectra.YLabel.String = 'Intensity';
h.axesSpectra.Title.String = 'Frequency Spectrum';

h.axesActivity = axes('Parent',h.plotWindowabs(3));
h.axesActivity.Title.String = 'Node Activity';

h.output = hObject;   % Choose default command line output for BVinterface
guidata(hObject, h);  % Update h structure
end

function varargout = BVinterface_OutputFcn(~, ~, h) 
% Outputs from this function are returned to the command line.
varargout{1} = h.output;
end

%%% Functions
function connect(ho,h)
% Opens a UDP connection to the specified address and port (hard-coded in initialization code)
h.udp.h = udp('localhost',h.udp.localPort,'LocalPort',h.udp.localPort,'InputBufferSize',131072,'InputDatagramPacketSize',65535);
fopen(h.udp.h);
h.udp.connected = true;
set(ho,'String','Connected')  % Update the button to reflect the connection
guidata(ho,h);
end

function disconnect(ho,h,isButton)
% Closes the UDP connection - this is a necessary step to unbind the port, so you can connect in the future
fclose(h.udp.h);
clear h.udp.h
h.udp.connected = false;
if isButton % If the disconnect call comes from the button rather than another function
	set(ho,'String','Connect')
end
guidata(ho,h);
end

function record(hObject)
	h = guidata(hObject);
    
	% New recording, reset all the variables
	fclose(h.udp.h); % Crude way to flush UDP Buffer, since the normal command does work here
	fopen(h.udp.h);
	h.data.matrix = zeros([h.numChannels h.plotWindow*5]); % 31xN matrix of channel voltages in time series
	h.data.normMatrix = zeros([h.numChannels h.plotWindow*5]);
	h.data.times = zeros([1 h.plotWindow*5]); % Vector contianing the time of each sample in h.data.matrix
    h.data.valid = false(size(h.data.times)); % Vector denoting which indicies are populated with valid data
    h.c=0;   % Variable used to mark the "current" sample index (e.g. the most recent)
    h.new = false;  % Variable used to decide whether to update the plot graphics during a loop
    h.range = 0.5; % Variable specifying the range of the data set (it gets updated from this arbitrarty value)
    cla(h.axesSpectra)
	cla(h.axesChannels) % Clear plots
	
	for channel = 1:h.numChannels   % Initialize line objects for plotting
		h.l.t(channel) = line(nan,nan,'Parent',h.axesChannels);
		h.l.f(channel) = line(nan,nan,'Parent',h.axesSpectra);
        h.l.f(channel).Color = h.colorList(channel,:); % Makes the lines for the spectra different colors, for contrast
	end
	
	warning('off','MATLAB:gui:array:InvalidArrayShape');  
	% Matlab throws a warning whenever the X and Y data vectors for a line object are not the same size
	% For faster plotting, the program edits these directly, meaning whenver the lengths change the warnign will pop up once
	% This is annoying, so it's turned off - be sure to turn this on again if debugging plotting problems
	
	if h.udp.connected
	while h.record
		while get(h.udp.h, 'BytesAvailable') > 0  
			% Unpack/process all pending UDP messages before proceeding
			% You should do all 'mandatory' processing here (stuff you want just as much as you want the data itself)
			
			h = unpack(h); % Unpack the new UDP message, add the data to the array
			
			% Averages each channel and subtracts, to remove DC offsets from potentials
            h.data.normMatrix(:,h.c-h.nSamples+1:h.c) = h.data.matrix(:,h.c-h.nSamples+1:h.c) - repmat(mean(h.data.matrix(:,h.data.valid),2),[1 h.nSamples]);
            h.new = true; % Tell the loop to update the plots
		end
		
		% All non-mandatory stuff goes outside the UDP processing loop - e.g. updating graphics like the plots
		if h.plot && h.new % Real-time plotting is enabled and changes have been made to the plots
             h = updatePlots(h);
             h.new = false;
		end
		
		guidata(hObject,h)  % Save data back to the GUI
		pause(.001) % A small pause, to allow for any other functions to be processed; drawnow may be a better command
		h = guidata(hObject); % Get data from GUI again
	end
	end
	set(hObject,'Value',false) % Set the button back to un-pressed
end

function h = unpack(h)
	block = fread(h.udp.h,1); % Get the next message out of the UDP buffer
	[block,valid] = unpackBlock(block,h.numChannels); % Unpack the UDP OSC message at the byte-level
    if valid  % Sometimes the messages might not contain the data they said they would, in which case the data is tossed out
	h.nSamples = size(block.matrix,2); % The number of samples in the time-dimension contained in the data block
	
	if (h.c+h.nSamples)>length(h.data.times)  % Pre-allocate another block of RAM - this helps with speed
		h.data.matrix(:,end+1:end+h.plotWindow*5) = zeros([h.numChannels h.plotWindow*5]);
		h.data.normMatrix(:,end+1:end+h.plotWindow*5) = zeros([h.numChannels h.plotWindow*5]);
		h.data.times(:,end+1:end+h.plotWindow*5) = zeros([1 h.plotWindow*5]);
	end
	
	%#ok<*ALIGN>
	% ^ This supresses an orange squigly underline about end-alignment on if statements
	
	if h.c==0
        t=0;
        h.ti = block.timeStamp;
    else
        t = block.timeStamp-h.ti; % The time since the first timestamp of the first block
    end
    
	if h.c==0
        h.data.times(1:h.nSamples) = (0:h.nSamples-1).*h.T; % Don't know block period yet
        h.data.valid(1:h.nSamples) = true;
	elseif h.c==h.nSamples;
        h.T = (block.timeStamp-h.block.timeStamp)/h.nSamples; % Confirm sample period
		h.data.times(1:h.nSamples) = (0:h.nSamples-1).*h.T; % Adjust the time values of the first block to reflect sample period
		h.data.times(h.c+1:h.c+h.nSamples) = (0:h.nSamples-1).*h.T+t; % New times
        h.data.valid(h.c+1:h.c+h.nSamples) = true; % Data is valid for these times
    else
       diff = abs(h.data.times(h.c)+h.T-t);
        if abs(diff)>0.5*h.T  % Some sample(s) have been skipped (dropped messages, paused, etc.)
            skipped = round(diff/h.T);  % Find out roughly how many samples
            h.data.times(h.c+1:h.c+skipped) = (1:skipped)*h.T+h.data.times(h.c);   % Insert the time values
            h.c = h.c+skipped;  % The skipped indicies in h.data.valid will remain false, and thus will be ignored during processing/saving
        end
		h.data.times(h.c+1:h.c+h.nSamples) = (0:h.nSamples-1).*h.T+t;
        h.data.valid(h.c+1:h.c+h.nSamples) = true; 
    end
    h.data.matrix(1:31,h.c+1:h.c+h.nSamples)=block.matrix; % Add the data to the set
	h.c = h.c+h.nSamples;
    h.block = block;        
    end
end

function h = updatePlots(h)
% Update the list of channels to be plotted
temp = get(h.listChannels,'Value');
if any(temp==1) % "plot all channels"
	h.plotSel = 1:h.numChannels;
elseif any(temp==2) % "plot no channels"
	h.plotSel = [];
else % "plot some channels"
	h.plotSel = temp-2;
end

switch get(h.plotWindowabGroup.SelectedTab,'Title')
% Will only compute/update the selected tab, when the plots are updated; any real-time processing should be done in the UDP loop
case {'Channels'} %%% Update Channels Plot
	axes(h.axesChannels) % Set the focus to this tab (not sure if this is necessary)
	temp = max(max(abs(h.data.normMatrix))); 
    if temp>h.range   % Checks to see if the range of vlaues is larger than the current range. This is necessary for plotting channels stacked atop each other properly
        h.range = 1.6*temp;    % If it's outside the current range, make it bigger! (will result in the graph suddenly being more spaced out, vertically) 
    end
    h.axesChannels.YLim = [0, (length(h.plotSel)+1).*(h.range)];  % Update the axis labeling to reflect the data beign plotted
    h.axesChannels.YTick = (1:length(h.plotSel)).*(h.range);
	h.axesChannels.YTickLabel = num2str((h.plotSel)');
	h.plotWindow = str2double(get(h.editWindow,'String'));

	if h.c>1  % Won't plot lines until it has data to work with
        if h.c-h.plotWindow < 1    % If the data set is smaller than the window, it simply plots all available data
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
	if h.c > h.plotWindow && ~isempty(h.plotSel)  %  Will remain blank until the data set is larger than the plotWindow size!
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
	
case{'Activity'} %%% Activity Contour Plot
	% Contour plot of node activity - not yet developed
	
end

% To include more tab plots, simply repeat the code in the opening funciton and add another case here.

end


%%% Callbacks   (Called when an event happens in the GUI)

function closereq(src,h)
% Attempts to close the UDP connection before shutting down the GUI.
% If it doesn't, the port will remain bound until matlab is restarted
% (You can avoid this by disconnecting before closing)
if h.udp.connected
	disconnect(src,h,false)
end
delete(gcf)
end

function changeTab(hObject, ~) % Called whenever the selected tab changes
updatePlots(guidata(hObject));
end

function toggleConnect_Callback(hObject, ~, h) % Connect button
if get(hObject,'Value')
	connect(hObject,h)
else
	disconnect(hObject,h,true)
end
end

function toggleRecord_Callback(hObject, ~, h)
h.record = get(hObject,'Value');  % The record button has been pressed - get state and start/stop recording
guidata(hObject,h)
if h.record
	record(hObject)
end
end

function buttonSave_Callback(~, ~, h)
struc.matrix = h.data.matrix(h.data.valid); % Save only the data/time samples with good data
struc.times = h.data.times(h.data.valid); %#ok<STRNU>
save(['data\' datestr(clock,'yy-mm-dd HH_MM_SS')],'struc');  % Writes a .mat file in the data folder, with name based on current time
end

function buttonTest_Callback(~, ~, h)
% Write code for a specific experiment and implement it here, for instance
	% (record EEG data while playing stimulus)
	% (save to a 'results' structure, with EEG data and stimulus time-synced)
end

function togglePlot_Callback(hObject, ~, h) % Toggles plotting handle
h.plot = get(hObject,'Value');
guidata(hObject,h)
if h.record
	record(hObject)
end
end

function listChannels_Callback(~, ~, h)
updatePlots(h); % The user has changed which channels are to be plotted - update plots
end

function editWindow_Callback(~, ~, h)
updatePlots(h);  % The user has changed the plot window width - update plots
end

function sliderWindow_Callback(hObject, ~, h)  % Changes the value of the plot window szie, between 1 and 5000 samples
set(h.editWindow,'Value',round(5000*get(hObject,'Value'))+1);
set(h.editWindow,'String',num2str(round(5000*get(hObject,'Value'))+1));
h.plotWindow = round(5000*get(hObject,'Value'))+1;
drawnow;
updatePlots(h);
end

%#ok<*DEFNU>
% ^ This supresses orange squiggly-lines about functions that 'might be unused'  (all callbacks get this)

%%% CreateFcn calls, mostly useless (executes during object creation, after setting all properties)
function listChannels_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function editWindow_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function sliderWindow_CreateFcn(hObject, ~, ~)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end