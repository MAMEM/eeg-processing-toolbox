%Add dependencies to the Matlab path, LibLSL is required for this example
%to work
addpath liblsl-Matlab\;
addpath liblsl-Matlab\bin\;
addpath liblsl-Matlab\mex\;
%Initialize LSL Wrapper class
lsl = eegtoolkit.util.LSLWrapper;
%Declare the name of the stream that will contain the EEG data
datastream = 'EMOTIVStream';
%Declare the name of the stream through which the events will be
%communicated
eventstream = 'MyEventStream';
%Size of signal that will be used for the recognition task
bufferSize = 5; %in seconds
%The event code that will trigger the recognition task
eventCode = 100;
 
 
% RECOGNITION ALGORITHM CONFIGURATION
 
%Indicate the number of stimuli (5) and their frequencies
stimulus_frequencies = [12 10 8.57 7.5 6.66];
 
%Filtering the eeg data
% df = eegtoolkit.preprocessing.DigitalFilter;
% %This filter was created via the 'filterbuilder' method of Matlab
% df.filt = Hbp; 
 
%Indicate which channels of the data (different electrodes) will be used
ss = eegtoolkit.preprocessing.SampleSelection;
%We will use all EPOC channels for this example
channels = 1:1:14;
ss.channels = channels;
ss.sampleRange = [1,128];
 
%Sampling rate for the EPOC headset is 128Hz
samplingRate = 128;
 
%Another required parameter for the CCA algorithm
numberOfHarmonics = 4;
%Initialize the Canonical Correlation Analysis class for the stimuli
%recognition
cca = eegtoolkit.featextraction.CCA(stimulus_frequencies,channels,samplingRate,numberOfHarmonics);
 
%Simple classifier that uses the max value of the features to assign the
%label
maxC = eegtoolkit.classification.MaxChooser;
 
%Assign the algorithm configuration to the LSL Wrapper class
lsl.preprocessing = {ss};
lsl.featextraction = cca;
lsl.classification = maxC;
 
%Find the streams in the network
lsl.resolveStreams(datastream,bufferSize,eventstream);
%Pause for 5 seconds to allow the stream to gather some data
pause(bufferSize); 
%Run the recognition task. The task runs indefinetely until is specifically
%interrupted
lsl.runSSVEP(eventCode);
