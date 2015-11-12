%IN-PRogress

sess = ssveptoolkit.util.Session();
sess.loadSubject(2);
%sess.loadAll();
%transf = sveptoolkit.transformer.DWT_Transformer(sess.trials);
transf = ssveptoolkit.transformer.PWelchTransformer();
%transf = sveptoolkit.transformer.PYAR_Transformer(sess.trials);
% (optional) define the parameters
transf.channel = 126;
transf.seconds = 5;
transf.nfft = 512;

% filt = ssveptoolkit.extractor.FEASTFilter();
% filt.algorithm = filt.ALGORITHM_MIM;
% filt.numToSelect = 250;

% classif = ssveptoolkit.classifier.LIBSVMClassifier(); % Classifier based on libsvm
% classif.cost = 2.0;
% classif.kernel = classif.KERNEL_LINEAR;


% classif = ssveptoolkit.classifier.MLTREEClassifier(); % Classifier based on trees
% classif.AlgorithmForCategorical='PCA';
% classif.MaxNumSplits=100;
% classif.MinLeafSize=1;
% classif.MinParentSize=20;
% classif.NumVariablesToSample='all';
% classif.ScoreTransform='symmetriclogit';
% classif.Prior='uniform';

%classif = ssveptoolkit.classifier.MLENSClassifier(); % Classifier based on ensemples (e.g.Adaboost)

% classif = ssveptoolkit.classifier.MLSVMClassifier(); % Classifier based on SVM from the Machine learning toolbox
% classif.Coding='onevsall';
% classif.FitPosterior=1;
% classif.Prior='uniform';

experiment = ssveptoolkit.experiment.Experimenter();
experiment.session = sess;
experiment.transformer = transf;
%comment this line if you dont want a filter
% experiment.extractor = filt;
experiment.classifier = classif;

%run the experiment
experiment.run();
sprintf('acc = %f', experiment.results{1}.getAccuracy())