function [struc,valid] = unpackBlock(block,numChannels)
% Takes a raw (UDP) byte sequence sent by python OSC from BrainVision data block
% and puts it into a matlab structure containing:
% - The time stamp, in miliseconds (converted from an H:M:S string)
% - The voltage matrix, divided into (numChannels) channels and N samples    - currently, numChannels will always be 31

block = char(block); % Temproarily converted to strong for easier processing
[~,block] = strtok(block,char(0)); % Read until four zeros - this is the address string (currently, the address string is ignored)
block=block(5:end); % Removes unused zeros

[contents,block] = strtok(block,char(0)); % Read again until four zeros - this is the contents list
block=block(5:end); % Removes unused zeros
% Currently, there is only one type of message being sent, so no further logic is used to decide what to do

numSamples=sum(contents=='f'); % How many samples are in the message, based on the contents list

[tstamp,block] = strtok(block,char(0)); % Read until one zero - this is the timestamp (in string format)
block=block(2:end); % Removes unused zero

[hour,rest] = strtok(tstamp',':');      % Covnert time string to double (miliseconds)
[minute,rest] = strtok(rest(2:end),':');
[second] = rest(2:end);
struc.timeStamp = str2double(second)+str2double(minute)*60+str2double(hour)*60*60;

block = uint8(block+1-1); % convert remaining data (4-byte floats i.e. singles) back to byte number format

if numel(block)==numSamples*4 % Check that the message has not been truncated, i.e. the list matches the contents
	valid= true;
	block = reshape(block,[4,numSamples/(numChannels),numChannels]);
	struc.matrix = single(zeros(numChannels,numSamples/numSamples));
	for channel = 1:numChannels
		for sample = 1:(numSamples/numChannels)
			struc.matrix(channel,sample) = typecast(fliplr(block(:,sample,channel)'),'single');
		end
	end
else
    warning('Recieved an improperly formatted messaged...')
    temp = typecast(0,'single'); % Fill it all with zeros
    struc.matrix(1:numChannels,1:round(numSamples/numChannels)) = repmat(temp(1),[numChannels, round(numSamples/numChannels)]);
    valid = false;
end
end