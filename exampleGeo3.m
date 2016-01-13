% Leave one subject out testing
% load filtMAMEM; % load a filter
% sess = ssveptoolkit.util.Session(Hhp);
% sess.loadAll(); %its best to do this once, outside the script (too much
% time)
% transf = ssveptoolkit.transformer.PWelchTransformer();
transf = ssveptoolkit.transformer.PWelchTransformer;
% (optional) define the parameters
transf.channel = 1;
% transf.filter = Hhp;
% transf.nfft = 256;

filt = ssveptoolkit.extractor.FEASTFilter();
filt.algorithm = filt.ALGORITHM_JMI;
filt.numToSelect = 85;

prepr1 = ssveptoolkit.preprocessing.SampleSelection;
prepr1.sampleRange = [1,1250];
prepr1.channels = 126;

prepr2 = ssveptoolkit.preprocessing.DigitalFilter;
prepr2.filt = Hhp;


classif = ssveptoolkit.classifier.LIBSVMClassifierFast;

experiment = ssveptoolkit.experiment.Experimenter;
experiment.session = sess;
experiment.preprocessing = {prepr1};
experiment.transformer = transf;
%comment this line if you dont want a filter
% experiment.extractor = filt;
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
