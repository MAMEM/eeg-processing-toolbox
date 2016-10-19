% Load the data. Call this once outside of the script so you dont have to
% load the data again and again. Make sure the dataset is included in your
% Matlab path
% sess = eegtoolkit.util.Session;
% sess.loadAll(3); %its best to do this once, outside the script (too much
% time)

%Load a filter from the samples
load filters/epocfilter;
% 7 = O1
% 8 = O2

% Stimulus frequencies for generating the CCA reference signals
sti_f = [12,10,8.57,7.5,6.66];

% CCA feat extraction method
extr = eegtoolkit.featextraction.CCA(sti_f,1:4,128,4);
extr.allFeatures = 1;

refer = eegtoolkit.preprocessing.Rereferencing;
%Subtract the mean from the signal
refer.meanSignal = 1;

ss = eegtoolkit.preprocessing.SampleSelection;
ss.sampleRange = [64,640]; % Specify the sample range to be used for each Trial
ss.channels = 6:9; % Specify the channel(s) to be used

df = eegtoolkit.preprocessing.DigitalFilter; % Apply a filter to the raw data
df.filt = Hbp; % Hbp is a filter built with "filterbuilder" matlab function

%Configure the classifier
classif = eegtoolkit.classification.LIBSVM;

%Set the Experimenter wrapper class
experiment = eegtoolkit.experiment.Experimenter;
experiment.session = sess;
% Add the preprocessing steps (order is taken into account)
experiment.preprocessing = {ss,df};
experiment.featextraction = extr;
experiment.classification = classif;
experiment.evalMethod = experiment.EVAL_METHOD_LOSO; % specify that you want a "leave one subject out" (default is LOOCV)
experiment.run();
for i=1:length(experiment.results)
    accuracies(i) = experiment.results{i}.getAccuracy();
end

accuracies'
%mean accuracy for all subjects
fprintf('mean acc = %f\n', mean(accuracies));
%get the configuration used (for reporting)
% experiment.getExperimentInfo
% experiment.getTime