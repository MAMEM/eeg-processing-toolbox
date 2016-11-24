% d2 = designfilt('bandpassiir', 'SampleRate', 256, 'FilterOrder', 8 ,'HalfPowerFrequency1', 1, 'HalfPowerFrequency2', 10,'DesignMethod', 'butter');

sess = eegtoolkit.util.Session;
sess.loadSubjectSession(8,5,2);

[z,p,k]=butter(3,[1,10]/64);
[s,g]=zp2sos(z,p,k);
Hd = dfilt.df2sos(s,g);
df = eegtoolkit.preprocessing.DigitalFilter; %
df.filt = Hd;

ss = eegtoolkit.preprocessing.SampleSelection;
ss.channels = [1:14];
ss.sampleRange = [1:6:200];

extr = {};
for i=1:3
    extr{i} = eegtoolkit.featextraction.PWelch;
    extr{i}.channel = 1;
end

aggr = eegtoolkit.aggregation.ChannelConcat;

classif = eegtoolkit.classification.LIBSVM;
classif.kernel = classif.KERNEL_RBF;
classif.gamma = 1/9;
classif.cost = 1;

%Setup experiment
experiment = eegtoolkit.experiment.Experimenter;
experiment.session = sess;
experiment.preprocessing = {df,ss};
experiment.featextraction = extr;
experiment.aggregator = aggr;
experiment.classification = classif;
experiment.evalMethod = experiment.EVAL_METHOD_XFOLD_CV;

experiment.run(10);

accuracies = [];
for i=1:length(experiment.results)
    accuracies(i) = experiment.results{i}.getAccuracy();
end

accuracies'
fprintf('mean acc = %.2f\n',mean(accuracies));