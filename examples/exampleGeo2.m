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
filt.numToSelect = 250;

classif = LIBSVMClassifier();
classif.cost = 2.0;
classif.kernel = LIBSVMClassifier.KERNEL_LINEAR;

experiment = Experimenter();
experiment.session = sess;
experiment.transformer = transf;
%comment this line if you dont want a filter
experiment.extractor = filt;
experiment.classifier = classif;

%run the experiment
experiment.run();
sprintf('acc = %f', experiment.getAccuracy())