%Add dependencies to the Matlab path, LibLSL is required for this example
%to work
% addpath liblsl-Matlab\;
% addpath liblsl-Matlab\bin\;
% addpath liblsl-Matlab\mex\;
%Initialize LSL Wrapper class
% h = errordlg('Cannot find GazeTheWeb','Error');
% error('Cannot find GazeTheWeb');
try
    pathtogaze = winqueryreg('HKEY_LOCAL_MACHINE','SOFTWARE\MAMEM','GAZETHEWEBPATH');
catch
    pathtogaze = '';
end
try
    pathtoepoc = winqueryreg('HKEY_LOCAL_MACHINE','SOFTWARE\MAMEM','EPOCPATH');
catch
    pathtoepoc = '';
end
datastream  = 'EMOTIVStream';
eventstream = 'BrowserOutputStream';
answer = inputdlg({'Path to GazeTheWeb','Path to EPOC','Data Stream','Event Stream'},'Setup',1,{pathtogaze,pathtoepoc,datastream,eventstream});
pathtogaze = answer{1};
pathtoepoc = answer{2};
datastream = answer{3};
eventstream = answer{4};

% system(['start "EPOC2LSL" cmd /c "' pathtoepoc '"']);
system(['pushd ' pathtoepoc ' &start cmd /c EPOC2LSL.exe']);
disp(['pushd ' pathtogaze ' & start cmd /c Client.exe http://160.40.50.238/mamem']);
system(['pushd ' pathtogaze ' &start cmd /c Client.exe http://160.40.50.238/mamem']);
% try
%     pathtogaze = winqueryreg('HKEY_LOCAL_MACHINE','SOFTWARE\MAMEM','GAZETHEWEBPATH');
%     pathtoepoc = winqueryreg('HKEY_LOCAL_MACHINE','SOFTWARE\MAMEM','EPOCPATH');
% %     system(['start "GazeTheWeb" cmd /c "' pathtogaze '"']);%build\EPOC2LSL\EPOC2LSL.exe']);
% %     system('start "GazeTheWeb" cmd /c cd "C:\Users\MAMEM\Downloads\Gaze-exe (11)\Client.exe"');
% %     system('start "GazeTheWeb" cmd /c pushd C:\Users\MAMEM\Downloads\Gaze-exe (11) & call Client.exe"');
% %     system('cd "C:\Users\MAMEM\Downloads\Gaze-exe (11) & Client.exe"');
% %     system(pathtogaze);
% %     disp(['start "EPOC2LSL" cmd /c "' pathtoepoc '"']);
%     system(['start "EPOC2LSL" cmd /c "' pathtoepoc '"']);
% %     system('pushd C:\Users\MAMEM\Downloads\Gaze-exe (11) &start cmd /c Client.exe http://160.40.50.238/mamem');
% %     system('start "Gaze" cmd /c C: & C: & cd "C:\Users\MAMEM\Downloads\Gaze-exe (11)" &start cmd /c Client.exe http://160.40.50.238/mamem/');
% %     system(['start "GazeTheWeb" cmd /c C: & cd C:\Users\MAMEM\Downloads\Gaze-exe (11) & Client.exe"&']);
% catch
%     pathtogaze = '';
%     path
%     warning('GazeTheWeb is not installed');
% end
lsl = eegtoolkit.util.LSLWrapper;
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
% pause(bufferSize); 
%Run the recognition task. The task runs indefinetely until is specifically
%interrupted
lsl.runSSVEP(eventCode);
