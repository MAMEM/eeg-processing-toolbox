% Leave one subject out testing
% load filtMAMEM; % load a filter
% sess = ssveptoolkit.util.Session(Hhp);
% sess.loadAll(); %its best to do this once, outside the script (too much
% time)
% transf = ssveptoolkit.transformer.PWelchTransformer();
transf = ssveptoolkit.transformer.PWelchTransformer;
% (optional) define the parameters
transf.channel = 126;
transf.seconds = 5;
 %transf.nfft = 256;
% transf.nfft = 512;

filt = ssveptoolkit.extractor.PCAFilter();
   filt.componentNum = 50;
%  filt.modes = 100;
%   filt.algorithm = filt.ALGORITHM_CMI;
%   filt.numToSelect = 24
%  filt.parameter1 = 0.7;
%  filt.parameter2 = 0.5;

classif = ssveptoolkit.classifier.LIBSVMClassifier();
classif.cost = 1.0;
classif.kernel = classif.KERNEL_LINEAR;

experiment = ssveptoolkit.experiment.Experimenter();
experiment.session = sess;
experiment.transformer = transf;
%comment this line if you dont want a filter
%experiment.extractor = filt;
experiment.classifier = classif;
experiment.evalMethod = experiment.EVAL_METHOD_LOSO; % specify that you want a "leave one subject out" (default is LOOCV)
%run the experiment
experiment.run();
accuracies = [];
for i=1:length(experiment.results)
    accuracies = [accuracies experiment.results{i}.getAccuracy()];
end
accuracies'
%mean accuracy for all subjects
fprintf('mean acc = %f\n', mean(accuracies));
%get the configuration used (for reporting)
experiment.getExperimentInfo
