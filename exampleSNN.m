%IN-PRogress

sess = Session();
sess.loadSubject(Session.DIMITRIS);
%sess.loadAll();
%transf = DWT_Transformer(sess.trials);
transf = PWelchTransformer();
%transf =PYAR_Transformer(sess.trials);

% (optional) define the parameters
transf.channel = 116;
transf.seconds = 3;
transf.nfft = 512;

filt = FEASTFilter();
%filt.algorithm = FEASTFilter.ALGORITHM_MIM;
filt.algorithm = FEASTFilter.ALGORITHM_ICAP;
filt.numToSelect = 250;

% classif = LIBSVMClassifier(); % Classifier based on libsvm
% classif.cost = 2.0;
% classif.kernel = LIBSVMClassifier.KERNEL_LINEAR;

% classif = MLDAClassifier(); % Classifier based on Discriminant Analysis
% classif.DiscrimType='linear';
% classif.Delta=1;
% classif.Gamma=0;
% classif.FillCoeffs='on';
% classif.ScoreTransform='symmetriclogit';
% classif.Prior='uniform';

% classif = MLTREEClassifier(); % Classifier based on trees
% classif.AlgorithmForCategorical='PCA';
% classif.MaxNumSplits=100;
% classif.MinLeafSize=1;
% classif.MinParentSize=20;
% classif.NumVariablesToSample='all';
% classif.ScoreTransform='symmetriclogit';
% classif.Prior='uniform';

%classif = MLENSClassifier(); % Classifier based on ensemples (e.g.Adaboost)

classif = MLSVMClassifier(); % Classifier based on SVM from the Machine learning toolbox
classif.Coding='onevsall';
classif.FitPosterior=1;
classif.Prior='uniform';

experiment = Experimenter();
experiment.session = sess;
experiment.transformer = transf;
%comment this line if you dont want a filter
experiment.extractor = filt;
experiment.classifier = classif;

%run the experiment
experiment.run();
sprintf('acc = %f', experiment.getAccuracy())