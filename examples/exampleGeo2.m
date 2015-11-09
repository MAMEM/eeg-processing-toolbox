%IN-PRogress

sess = Session();
sess.loadSubject(Session.ANASTASIA);
transf = PWelchTransformer();

% (optional) define the parameters
transf.channel = 116;
transf.seconds = 3;
transf.nfft = 512;

filt = FEASTFilter();
filt.algorithm = FEASTFilter.ALGORITHM_MIM;
filt.numToSelect = 100;

classif = LIBSVMClassifier();
classif.cost = 2.0;
classif.kernel = LIBSVMClassifier.KERNEL_LINEAR;

% eval = CrossValidationEvaluator();
% eval.folds = 100;
% eval.metric = Evaluator.METRIC_ACCURACY;

experiment = Experimenter();
experiment.session = sess;
experiment.transformer = transf;
% experiment.extractor = filt;
experiment.classifier = classif;
% experiment.evaluator = eval;

%run the experiment
experiment.run();
sprintf('acc = %f', experiment.getAccuracy())
% experiment.results(); %print results
% experiment.outputResults('res.csv');
% experiment.getDataset(); %get dataset
% %w/e
% 
% %run experiment with different dataset
% experiment.session.clearData();
% experiment.session.loadSubject(Session.DIMITRIS);
% %change a parameter if you want
% experiment.transformer.channel = 126;
% experiment.evaluator.metric = Evaluator.METRIC_MEAN_ERROR;
% %run experiment with Dimitris data
% experiment.run();
