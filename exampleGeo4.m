% Leave one subject out testing
% load filtMAMEM; % load a filter
% sess = ssveptoolkit.util.Session(Hhp);
% sess.loadAll(); %its best to do this once, outside the script (too much
% time)
% transf = ssveptoolkit.transformer.PWelchTransformer();
transf1 = ssveptoolkit.transformer.PWelchTransformer;
% (optional) define the parameters
transf1.channel = 138;
transf2 = ssveptoolkit.transformer.PWelchTransformer;
transf2.channel = 150;
transf3 = ssveptoolkit.transformer.PWelchTransformer;
transf3.channel = 139;

aggr = ssveptoolkit.aggregation.ChannelAveraging;

filt = ssveptoolkit.extractor.FEASTFilter();
filt.algorithm = filt.ALGORITHM_JMI;
filt.numToSelect = 85;

classif = ssveptoolkit.classifier.LIBSVMClassifierFast();
classif.cost = 1.0;
classif.kernel = classif.KERNEL_LINEAR;

experiment = ssveptoolkit.experiment.Experimenter();
experiment.session = sess;
experiment.transformer = {transf1,transf2,transf3};
experiment.aggregator = aggr;
experiment.extractor = filt;
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
