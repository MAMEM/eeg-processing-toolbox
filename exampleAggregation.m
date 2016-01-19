% Leave one subject out testing
% load filtMAMEM; % load a filter
% sess = ssveptoolkit.util.Session(Hhp);
% sess.loadAll(); %its best to do this once, outside the script (too much
% time)
% transf = ssveptoolkit.transformer.PWelchTransformer();
transf1 = ssveptoolkit.featextraction.PWelch;
transf1.channel = 1;
transf2 = ssveptoolkit.featextraction.PWelch;
transf2.channel = 2;
transf3 = ssveptoolkit.featextraction.PWelch;
transf3.channel = 3;
% (optional) define the parameters

prepr1 = ssveptoolkit.preprocessing.SampleSelection;
prepr1.channels = [126,150,139];
prepr2 = ssveptoolkit.preprocessing.DigitalFilter;
prepr2.filt = Hbp;

aggr = ssveptoolkit.aggregation.ChannelAveraging;

select = ssveptoolkit.featselection.FEAST;
select.algorithm = select.ALGORITHM_JMI;
select.numToSelect = 85;

classif = ssveptoolkit.classification.LIBSVMFast;

experiment = ssveptoolkit.experiment.Experimenter();
experiment.session = sess;
experiment.preprocessing = {prepr1,prepr2};
experiment.featextraction = {transf1,transf2,transf3};
experiment.aggregator = aggr;
experiment.featselection = select;
% experiment.extractor = filt;
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
experiment.getExperimentInfo
experiment.getTime;
