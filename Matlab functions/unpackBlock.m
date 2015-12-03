function [struc,good] = unpackBlock(block,numChannels)
% Takes a raw (UDP) data block sent by python OSC from BrainVision and puts the data into a structure containing
% - The address
% - The contents list
% - The time stamp, in miliseconds (converted from H:M:S string)
% - The voltage matrix, divided into 31 channels and N samples

sblock = char(block);
[address,sblock] = strtok(sblock,char(0)); % Read until four zeros - this is the address string
sblock=sblock(5:end); % Removes unused zeros

[contents,sblock] = strtok(sblock,char(0)); % Read again until four zeros - this is the contents list
sblock=sblock(5:end); % Removes unused zeros

numSamples=sum(contents=='f')/31;

[tstamp,sblock] = strtok(sblock,char(0)); % Read until one zero - this is the timestamp (in string format)
sblock=sblock(2:end); % Removes unused zero

[hour,rest] = strtok(tstamp',':');
[minute,rest] = strtok(rest(2:end),':');
[second] = rest(2:end);
struc.timeStamp = str2double(second)+str2double(minute)*60+str2double(hour)*60*60;

sblock = uint8(sblock+1-1); % convert remaining data (4-byte floats) back to number format

if numel(block)==3908
    good= true;
temp = reshape(sblock,[4,numSamples,numel(sblock)/(4*numSamples)]);
struc.matrix = single(zeros(numChannels,numSamples));
for channel = 1:numChannels
	for sample = 1:numSamples
		struc.matrix(channel,sample) = typecast(fliplr(temp(:,sample,channel)'),'single');
	end
end

else
    %warning('Recieved an improperly formatted messaged...')
    temp = typecast(0,'single');
    struc.matrix(1:31,1:25) = repmat(temp(1),[31 25]);
    good = false;
end
end