function soundThing(dur,frameSize,fmax)
fs = 44100;
FrameSize = 1024*frameSize;
AR = dsp.AudioRecorder('SampleRate',fs,'SamplesPerFrame',FrameSize);
TS = dsp.TimeScope('YLimits',[-1,1],'SampleRate',fs,'TimeSpan',FrameSize/fs);
SA = dsp.SpectrumAnalyzer('StartFrequency',fs/(FrameSize+1),'StopFrequency',fmax,'FrequencySpan','Start and stop frequencies');
tic
while toc<dur
	%step(TS,step(AR))
	step(SA,step(AR))
end

end