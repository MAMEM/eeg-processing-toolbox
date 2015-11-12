%IN-PRogress
sess = ssveptoolkit.util.Session();
sess.loadSubject(1);
% transf = ssveptoolkit.transformer.PWelchTransformer();
transf = ssveptoolkit.transformer.DWT_Transformer;
% (optional) define the parameters
transf.channel = 126;
transf.seconds = 5;
% transf.nfft = 512;

filt = ssveptoolkit.extractor.FEASTFilter();
filt.algorithm = filt.ALGORITHM_MIM;
filt.numToSelect = 250;

classif = ssveptoolkit.classifier.LIBSVMClassifier();
classif.cost = 1.0;
classif.kernel = classif.KERNEL_LINEAR;

experiment = ssveptoolkit.experiment.Experimenter();
experiment.session = sess;
experiment.transformer = transf;
%comment this line if you dont want a filter
% experiment.extractor = filt;
experiment.classifier = classif;

%run the experiment
experiment.run();
sprintf('acc = %f', experiment.results{1}.getAccuracy())