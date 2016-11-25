% Leave one subject out testing
% load filtMAMEM; % load a filter
% sess = eegtoolkit.util.Session(Hhp);
% sess.loadAll(1); %its best to do this once, outside the script (too much
% time)
% transf = eegtoolkit.transformer.PWelchTransformer();
% Load the data. Call this once outside of the script so you dont have to
% load the data again and again. Make sure the dataset is included in your
% Matlab path
% sess = eegtoolkit.util.Session;
% sess.loadAll(1); %Loads dataset I

%Load a filter from the samples
load filters/filt_IIRElliptic;



refer = eegtoolkit.preprocessing.Rereferencing;
%Subtract the mean from the signal
refer.meanSignal = 1;

ss = eegtoolkit.preprocessing.SampleSelection;
ss.sampleRange = [1,1250]; % Specify the sample range to be used for each Trial
ss.channels = [138,139,150]; % Specify the channel(s) to be used

df = eegtoolkit.preprocessing.DigitalFilter; % Apply a filter to the raw data
df.filt = Hbp; % Hbp is a filter built with "filterbuilder" matlab function


%Extract features with the pwelch method
extr1 = eegtoolkit.featextraction.PWelch;
extr1.channel = 1; %will use channel 138

extr2 = eegtoolkit.featextraction.PWelch;
extr2.channel = 2; %will use channel 139

extr3 = eegtoolkit.featextraction.PWelch;
extr3.channel = 3; %will use channel 150

extr = {extr1,extr2,extr3};
% Average all three channels so as to get a new feature vector
aggr = eegtoolkit.aggregation.ChannelAveraging;
%Configure the classifier
classif = eegtoolkit.classification.LIBSVM;

%Set the Experimenter wrapper class
experiment = eegtoolkit.experiment.Experimenter;
experiment.session = sess;
% Add the preprocessing steps (order is taken into account)
experiment.preprocessing = {ss,refer,df};
experiment.featextraction = {extr1,extr2,extr3};
experiment.aggregator = aggr;
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