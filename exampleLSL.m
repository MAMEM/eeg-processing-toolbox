%load trainedclassifier;
% load filters/filt_IIRElliptic;
addpath liblsl-Matlab\;
addpath liblsl-Matlab\bin\;
addpath liblsl-Matlab\mex\;
lsl = ssveptoolkit.util.LSLWrapper;
datastream = 'EMOTIVStream';
eventstream = 'MyEventStream';
% eventstream = 'openvibeMarkers';
bufferSize = 5; %in seconds
% stopCode = 32779;
stopCode = 700;
sti_f = [12 10 8.57 7.50 6.66];
% sti_f = [12 6.66 7.5 8.57 10];

% df = ssveptoolkit.preprocessing.DigitalFilter;
% df.filt = Hbp;

ss = ssveptoolkit.preprocessing.SampleSelection;
ss.channels = [1:1:14];
ss.sampleRange = [1,640];

refer = ssveptoolkit.preprocessing.Rereferencing;
refer.meanSignal = 1;

% pwelch = ssveptoolkit.featextraction.PWelch;

lsl.preprocessing = {ss,refer};
lsl.featextraction = ssveptoolkit.featextraction.CCA(sti_f,[1:1:14],128,4);
lsl.classification = ssveptoolkit.classification.Dummy;

lsl.resolveStreams(datastream,bufferSize,eventstream);
disp('waiting for 5 seconds');
pause(5); 
disp('ready');
lsl.runSSVEP(stopCode);
