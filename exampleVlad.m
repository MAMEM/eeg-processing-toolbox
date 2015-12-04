% Leave one subject out testing
% load filtMAMEM; % load a filter
% sess = ssveptoolkit.util.Session(Hhp);
% sess.loadAll(); %its best to do this once, outside the script (too much
% time)
% transf = ssveptoolkit.transformer.PWelchTransformer();
transformers = {};
% occipital =[ 126 138	150	139	137	149	125	113	114	115	116	117	118	119	120	121	122	123	124	127	133	134	135	136	145	146	147	148	156	157	158	159	165	166	167	168	174	175	176	187];
occipital = [126 138];
codebookfilename = 'fisher16';
for i=1:length(occipital)
    transformers{i} = ssveptoolkit.transformer.PWelchTransformer;
    transformers{i}.channel = occipital(i);
    transformers{i}.nfft = 512;
    transformers{i}.seconds = 5;
end
aggr = ssveptoolkit.aggregation.FisherAggregator(codebookfilename);
filt = ssveptoolkit.extractor.PCAFilter;
filt.componentNum = 257;
classif = ssveptoolkit.classifier.LIBSVMClassifierFast();

experiment = ssveptoolkit.experiment.Experimenter();
experiment.session = sess;
experiment.transformer = transformers;
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
