
sess = ssveptoolkit.util.Session;
sess.loadBCICompData

ss = ssveptoolkit.preprocessing.SampleSelection;
ss.channels = [1,3];
ss.sampleRange = [128*4,128*7];

aggr = ssveptoolkit.aggregation.ChannelConcat;

extr = {};
extr{1} = ssveptoolkit.featextraction.DWT; 
extr{1}.channel = 1;
extr{2} = ssveptoolkit.featextraction.DWT; 
extr{2}.channel = 2;

classif = ssveptoolkit.classification.LIBSVM;

experiment = ssveptoolkit.experiment.Experimenter;
experiment.session = sess;
% Add the preprocessing steps (order is taken into account)
experiment.preprocessing = {ss};
experiment.featextraction = extr;
experiment.aggregator = aggr;
experiment.classification = classif;
experiment.evalMethod = experiment.EVAL_METHOD_LOOCV; % specify that you want a "leave one subject out" (default is LOOCV)
experiment.run();

for i=1:length(experiment.results)
    accuracies(i) = experiment.results{i}.getAccuracy();
end
%mean accuracy for all subjects
fprintf('mean acc = %f\n', mean(accuracies));