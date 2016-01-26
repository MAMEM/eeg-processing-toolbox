% Leave one subject out testing
% sess = ssveptoolkit.util.Session(Hhp);
% sess.loadAll(); %its best to do this once, outside the script (too much
% time)
extr = ssveptoolkit.featextraction.PWelch;
% extr.nfft = [4:0.4883:44.529];
extr.nfft = 512;
% extr.win_len = 400;
% extr.over_len = 0.75;

% prepr0 = ssveptoolkit.preprocessing.Amuse;
% prepr0.first = 15;
% prepr0.last = 252;

prepr0 = ssveptoolkit.preprocessing.Rereferencing;
prepr0.meanSignal = 1;

prepr1 = ssveptoolkit.preprocessing.SampleSelection;
prepr1.sampleRange = [1,1250]; % Specify the sample range to be used for each Trial
prepr1.channels = 126; % Specify the channel(s) to be used

prepr2 = ssveptoolkit.preprocessing.DigitalFilter;
prepr2.filt = Hbp; % Hbp is a filter built with "filterbuilder" matlab function

classif = ssveptoolkit.classification.LIBSVMFast;
classif.kernel = 'linear';
classif.cost = 1.0;


% classif.kernel = 'linear';
% classif.cost = 1;

experiment = ssveptoolkit.experiment.Experimenter;
experiment.session = sess;
experiment.preprocessing = {prepr0, prepr1,prepr2};
experiment.featextraction = extr;
% experiment.featselection = featsel;
% experiment.featsel = ssveptoolkit.featselection.FEAST;
experiment.classification = classif;
experiment.evalMethod = experiment.EVAL_METHOD_LOSO; % specify that you want a "leave one subject out" (default is LOOCV)
%run the experiment
experiment.run();
accuracies = [];
for i=1:length(experiment.results)
    accuracies(i) = experiment.results{i}.getAccuracy();
end
accuracies'
%mean accuracy for all subjects
fprintf('mean acc = %f\n', mean(accuracies));
%get the configuration used (for reporting)
% experiment.getExperimentInfo
experiment.getTime
