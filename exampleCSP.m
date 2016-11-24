
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

[z,p,k]=butter(3,[8,16]/64);
[s,g]=zp2sos(z,p,k);
Hd = dfilt.df2sos(s,g);
df = eegtoolkit.preprocessing.DigitalFilter; %
df.filt = Hd;

refer = eegtoolkit.preprocessing.Rereferencing;
refer.meanSignal = 1;

extr = eegtoolkit.featextraction.RawSignal;

classif = eegtoolkit.classification.CSPWrapper;
classif.baseClassifier = eegtoolkit.classification.LIBSVM;

experiment = eegtoolkit.experiment.Experimenter;
experiment.session = sess;
experiment.preprocessing = {ss,refer,df};
experiment.featextraction = extr;
experiment.classification = classif;
experiment.evalMethod = experiment.EVAL_METHOD_LOOCV;
% experiment.run();
% experiment.evalMethod = experiment.EVAL_METHOD_XFOLD_CV;
experiment.run(3);
accuracy = experiment.results{1}.getAccuracy();

