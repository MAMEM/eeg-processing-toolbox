sess = eegtoolkit.util.Session;
sess.loadAll(6);
% 

% load('testingMotorVag1');
% % load
% sess = eegtoolkit.util.Session;
% % sess.loadMOTOR(labels,trials);
% sess.loadVag(trials,labels);

ss = eegtoolkit.preprocessing.SampleSelection;
ss.channels = [1,3];
ss.sampleRange = [384,896];

extr1  = eegtoolkit.featextraction.PWelch;
extr1.channel = 1;

extr2 = eegtoolkit.featextraction.PWelch;
extr2.channel = 2;

aggr = eegtoolkit.aggregation.ChannelConcat;

classif = eegtoolkit.classification.MLR;
experiment = eegtoolkit.experiment.Experimenter;
experiment.session = sess;
experiment.preprocessing = {ss};
experiment.featextraction = {extr1, extr2};
experiment.aggregator = aggr;
experiment.classification = classif;
experiment.evalMethod = experiment.EVAL_METHOD_LOOCV;
% experiment.run();
% experiment.evalMethod = experiment.EVAL_METHOD_XFOLD_CV;
experiment.run();
accuracy = experiment.results{1}.getAccuracy();

