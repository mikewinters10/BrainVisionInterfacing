function [struc] = unpackBlock(block,numChannels)
% Takes a raw (UDP) data block sent by python OSC from BrainVision and puts the data into a structure containing
% - The address
% - The contents list
% - The time stamp, in miliseconds (converted from H:M:S string)
% - The voltage matrix, divided into 31 channels and N samples

sblock = char(block);
[struc.address,sblock] = strtok(sblock,char(0)); % Read until four zeros - this is the address string
sblock=sblock(5:end); % Removes unused zeros

[struc.contents,sblock] = strtok(sblock,char(0)); % Read again until four zeros - this is the contents list
sblock=sblock(5:end); % Removes unused zeros

numSamples=sum(struc.contents=='f')/31;

[tstamp,sblock] = strtok(sblock,char(0)); % Read until one zero - this is the timestamp (in string format)
sblock=sblock(2:end); % Removes unused zero

[hour,rest] = strtok(tstamp',':');
[minute,rest] = strtok(rest(2:end),':');
[second] = rest(2:end);
struc.timeStamp = str2double(second)+str2double(minute)*60+str2double(hour)*60*60;

channelData = uint8(sblock+1-1); % convert remaining data (4-byte floats) back to number format

struc.address = struc.address';
struc.contents = struc.contents';

temp = reshape(channelData,[4,numSamples,numel(channelData)/(4*numSamples)]);
struc.matrix = single(zeros(numChannels,numSamples));
for channel = 1:numChannels
	for sample = 1:numSamples
		struc.matrix(channel,sample) = typecast(fliplr(temp(:,sample,channel)'),'single');
	end
end

% ? In another function, make a structure vector contianing each unpacked block structure
%   and also populate a time-series matrix with the floats and delta-times

end