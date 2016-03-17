load trainedclassifier;
load filters/filt_IIRElliptic;
lsl = ssveptoolkit.util.LSLWrapper;
datastream = 'EMOTIVStream';
eventstream = 'openvibeMarkers';
bufferSize = 5; %in seconds
stopCode = 32780;

df = ssveptoolkit.preprocessing.DigitalFilter;
df.filt = Hbp;

ss = ssveptoolkit.preprocessing.SampleSelection;
ss.channels = 3;
ss.sampleRange = [1,640];

refer = ssveptoolkit.preprocessing.Rereferencing;
refer.meanSignal = 1;

pwelch = ssveptoolkit.featextraction.PWelch;

lsl.preprocessing = {ss,refer,df};
lsl.featextraction = pwelch;
lsl.classification = trainedClassifier;

lsl.resolveStreams(datastream,bufferSize,eventstream);
disp('waiting for 5 seconds');
pause(5); 
lsl.run(stopCode);
