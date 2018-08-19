% Load the data. Call this once outside of the script so you dont have to
% load the data again and again. Make sure the dataset is included in your
% Matlab path
% sess = eegtoolkit.util.Session;
% sess.loadAll(1); %Loads dataset I

%Load a filter from the samples
load filters/filt_IIRElliptic;

extr = eegtoolkit.featextraction.PWelchExperimental;
extr.nfft = 512;
extr.over_len = 0.75;
extr.win_len = 350;

amu = eegtoolkit.preprocessing.Amuse;
amu.first = 15;
amu.last = 252;

refer = eegtoolkit.preprocessing.Rereferencing;
%Subtract the mean from the signal
refer.meanSignal = 1;

ss = eegtoolkit.preprocessing.SampleSelection;
ss.sampleRange = [1,1250]; % Specify the sample range to be used for each Trial
ss.channels = 138; % Specify the channel(s) to be used

df = eegtoolkit.preprocessing.DigitalFilter; % Apply a filter to the raw data
df.filt = Hbp; % Hbp is a filter built with "filterbuilder" matlab function

svd = eegtoolkit.featselection.SVD;
svd.modes = 90;

%Configure the classifier
classif = eegtoolkit.classification.LIBSVMFast;

%Set the Experimenter wrapper class
experiment = eegtoolkit.experiment.Experimenter;
experiment.session = sess;
% Add the preprocessing steps (order is taken into account)
experiment.preprocessing = {amu,ss,refer,df};
experiment.featselection = svd;
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
experiment.getExperimentInfo
experiment.getTime
