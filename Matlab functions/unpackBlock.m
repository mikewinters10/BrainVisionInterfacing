function [struc] = unpackBlock(block)
% Takes a raw (UDP) data block sent by python OSC from BrainVision and puts the data into a structure containing
% - The address
% - The contents list
% - The time stamp
% - The voltages, divided into 32 channels


% TODO:
% Read until four zeros - this is the address string (mostly uselss for now)
% Read again until four zeros - this is the contents list
% Read until one zero - this is the timestamp (in string format)
% Read (total floats/31) floats of 4 byte precision, big-endian
	% Make into a vector - this is the data for one channel
	% Repeat for the remaining channels (total of 31 channels)

% ? Convert timestamp to time format or simply miliseconds
% ? In another function, make a structure vector contianing each unpacked block structure
%   and also populate a time-series matrix with the floats and delta-times

end
