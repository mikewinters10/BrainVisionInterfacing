# BrainVisionInterfacing

This repository is for extracting a live data stream from the BrainVision EEG equipment and storing/processing it in
other programs, such as matlab.

##MATALB Folder Contents:

###block info.txt

	Contains informaiton about the data formatting of the OSC messages generated by python driver (pycorder)

###unpackBlock.m

	Matlab function which translates OSC messages recieved from the UDP buffer into a matlab structure

###BVinterface.m

	Matlab GUI for real-time data streaming, processing, and visualization.
	- Receives EEG data from the python driver via UDP connection and translates it into a matlab array
	- Stores this data in a useful format for matlab
	- Can do real-time data processing/visualization (the code is structured for speed)
	- Has the infrastructure for doing experiments for synchronizing data with stimuli (ex. midi sequences)

###BVinterface.fig

	Figure binary file associated with BVinterface GUI, containing information
	about the positions/properties of the various elements in the GUI

###data\

	Folder storing data files saved by the GUI. Files are named by the date/time when they are created.
