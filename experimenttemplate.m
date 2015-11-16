% put comments here

% load filtMAMEM
% session = ssveptoolkit.util.Session(Hhp);
% session.loadAll;

transformer = ssveptoolkit.transformer.PWelchTransformer;

classifier = ssveptoolkit.classifier.LIBSVMClassifier;

experiment = ssveptoolkit.experiment.Experimenter;
experiment.session = session;
experiment.transformer = transformer;
experiment.classifier = classifier;
experiment.evalMethod = experiment.EVAL_METHOD_LOSO;
experiment.run;
accuracies = [];
for i=1:length(experiment.results)
    accuracies = [accuracies experiment.results{i}.getAccuracy()];
end
accuracies'
%mean accuracy for all subjects
fprintf('mean acc = %f\n', mean(accuracies));
%get the configuration used (for reporting)
experiment.getExperimentInfo
